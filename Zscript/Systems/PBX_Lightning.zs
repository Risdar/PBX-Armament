// MIT License

// Copyright (c) 2024 Agent_Ash aka jekyllgrim

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

class PBX_LightningController : Thinker
{
	const ACC_STATNUM = STAT_FIRST_THINKING;
	
	Actor ac_lightningOrigin; // the actor that emanates the lightning (but not responsible for damage)
	uint	ac_age;
	PBX_LightningController ac_parentController;          // used by controllers created by other controllers
	array <PBX_LightningController> ac_childControllers;  // used by the first controller only
	array <Actor> ac_lightningVictims; // used by each controller to track which victims it should be able to damage
	bool    ac_done;            // set by the controller itself when it's time to disappear
	int     ac_stage;           // tracks which arc it is in the chain
	int     ac_maxChains;       // maximum number of secondary arcs that one arc can split into at once
	int     ac_maxLinks;        // maximum number of links each arc can create in total ("depth")
	int     ac_duration;        // duration of the effect
	int     ac_duration_init;   // initial duration of the effect
	int     ac_delay;           // delay between the controller is given and the effect starts
	int     ac_delay_init;      // initial delay
	int     ac_damagePerArc;    // damage per a single arc
	int     ac_damageFrequency; // per how many tics to deal damage
	Actor   ac_damageSource;    // tracks the source actor responsible for the attack
	double  ac_maxDistance;     // max distance an arc can cover (same for all arcs)
	name	ac_DamageType;		// Damage Type

	static PBX_LightningController L_Attach(Actor who)
	{
		if (!who) return null;

		foreach (PBX_LightningController controller : ThinkerIterator.Create('PBX_LightningController', PBX_LightningController.ACC_STATNUM))
		{
			if (controller && controller.ac_lightningOrigin == who)
			{
				return controller;
				break;
			}
		}
		PBX_LightningController controller = new('PBX_LightningController');
		controller.ChangeStatNum(PBX_LightningController.ACC_STATNUM);
		controller.ac_lightningOrigin = who;
		return controller;
	}

	static clearscope bool L_IsControlled(Actor who)
	{
		if (!who) return false;

		foreach (PBX_LightningController controller : ThinkerIterator.Create('PBX_LightningController', PBX_LightningController.ACC_STATNUM))
		{
			if (controller && controller.ac_lightningOrigin == who)
			{
				return true;
				break;
			}
		}
		return false;
	}

	PBX_LightningController L_GetParentController()
	{
		PBX_LightningController ctrl = self;
		while (ctrl && ctrl.ac_parentController)
		{
			ctrl = ctrl.ac_parentController;
		}
		return ctrl;
	}

	// Dedicated function accurately calculate the exact point
	// from which player's attack come out. Used by LineTrace()
	// in weapons.
	static clearscope double L_GetAttackHeight(PlayerPawn source)
	{
		if (!source || !source.player)
			return 0;
		
		let player = source.player;
		return source.height*0.5 - source.floorclip + player.mo.AttackZOffset*player.crouchFactor;
	}

	// Allows specifying a relative offset (forward/leftright/updown) and converts it
	// to proper world coordinates:
	// startpos		: initial position
	// viewangles	: angle, pitch, roll
	// offset		: forward/backward, right/left, up/down
	// isPosition	: if false, adds startPos to result (only useful for velocity); if true, doesn't
	static clearscope Vector3 L_RelativeToGlobalCoords(Vector3 startpos, Vector3 viewAngles, Vector3 offset, bool isPosition = true)
	{
		Quat dir = Quat.FromAngles(viewAngles.x, viewAngles.y, viewAngles.z);
		vector3 ofs = dir * (offset.x, -offset.y, offset.z);
		if (isPosition)
		{
			return Level.Vec3Offset(startpos, ofs);
		}
		return ofs;
	}

	// Gets the position to which the beam is attached to.
	// By default it's just the center of the source.
	// If source is a player, horOfs and vertOfs are used
	// to define horizontal and vertical offset, like in A_SpawnProjectile
	static Vector3 L_GetBeamAttachPos(Actor source, double horOfs = 0, double vertOfs = 0)
	{
		if (!source)
			return (0,0,0);
		Vector3 spos;
		if (source.player)
		{
			spos = L_RelativeToGlobalCoords((source.pos.xy, source.player.viewz), (source.angle, source.pitch, source.roll), (source.radius, horOfs, vertOfs), true);
		}
		else
		{
			spos = source.pos.PlusZ(source.height * 0.5);
		}
		return spos;
	}

	// Starts a lightning chain. Arguments:
	// damageSource : the actor responsible for the damage (will be passed to further arcs)
	// victim       : the first victim of the lightning
	// damage       : the damage to deal per one iteration
	// range        : the range of the lightning (will be passed to further arcs)
	// duration     : how long a single arc persists
	// delay        : delay between further arcs are created from the victim
	// maxChains    : maximum number of arcs that can be fired from a single victim
	// maxlinks     : how many total victims can be hit by a single lightning chain
	// parent       : set by L_ExtendChain(), creates new chain parented to the same controller
	static PBX_LightningController L_StartChain(Actor damageSource, Actor victim, int damage, double range, int duration = 1, int delay = 0, int maxChains = 1, int maxLinks = 0, int damageFrequency = 1, name damageType = 'plasma', PBX_LightningController parent = null)
	{
		if (!damageSource || !victim)
		{
			return null;
		}

		PBX_LightningController c = PBX_LightningController.L_Attach(victim);
		if (c)
		{
			c.ac_parentController  = parent;
			c.ac_stage             = parent ? parent.ac_stage + 1 : 1;
			c.ac_damageSource      = damageSource;
			c.ac_lightningOrigin   = victim;
			c.ac_maxDistance       = range;
			c.ac_duration          = duration;
			c.ac_duration_init     = c.ac_duration;
			c.ac_damagePerArc      = damage;
			c.ac_delay             = delay;
			c.ac_delay_init        = c.ac_delay;
			c.ac_maxChains         = clamp(maxChains, 0, 100);
			c.ac_maxLinks          = clamp(maxLinks, 0, 100);
			c.ac_damageFrequency   = max(damageFrequency, 1);
			c.ac_DamageType   	   = damageType;

			let ac = c.L_GetParentController();
			ac.ac_childControllers.Push(c);

			//Console.Printf("PBX_LightningController created (\cd%d\c-). First victim: \cd%s\c- | ac_duration: \cd%d\c- | ac_delay: \cd%d\c-", Level.maptime, c.ac_lightningOrigin? c.ac_lightningOrigin.GetClassName() : 'none', c.ac_duration_init, c.ac_delay_init);
		}
		return c;
	}

	// Extends the lightning chain from ac_lightningOrigin
	// to the other actor:
	void L_ExtendChainTo(Actor nextVictim)
	{
		if (!nextVictim || !ac_damageSource)
			return;

		L_StartChain(ac_damagesource, nextVictim, ac_damagePerArc, ac_maxDistance, ac_duration_init, ac_delay_init, ac_maxChains, ac_maxLinks, ac_damageFrequency, ac_DamageType, self);
	}

	// Gets a bunch of randomly offset points from one position to a nother,
	// then calls L_DrawLightningSegment() between each of those points to create
	// a jagged particle-based lightning.
	// Arguments are the same as in L_DrawLightningSegment(), just passed to it.
	static void L_DrawLightning(Vector3 from, Vector3 to, bool spawnSpark = true, PlayerInfo playersource = null)
	{
		Vector3 diff = Level.Vec3Diff(from, to);
		Vector3 dir = diff.Unit();
		double dist = diff.Length();
		// distance between nodes
		double nodeDist = min(dist / 10.0, 80);
		double ofss = nodeDist / 4.0;

		// vecPos is pushed along the main vector in
		// a straight line; curPos and nextPos are randomly
		// offset points along it, between which the
		// lightning segments are drawn:
		Vector3 curPos, nextPos, vecPos;
		curPos = vecPos = from;
		double nextStep = nodeDist;
		for (double d = 0.0; d < dist; d += nextStep)
		{
			// randomize the length of the next step:
			nextStep = min(nodeDist * frandom[lightningpart](0.6, 1.2), dist - d);

			// push aligned position in a traight line:
			vecPos = Level.Vec3Offset(vecPos, dir*nextStep);

			// get the next lightning pos, randomly offset
			// around aligned position (for all steps but
			// the last one):
			if (d < dist - nextStep)
			{
				nextPos = Level.Vec3Offset(vecPos,
					(frandom[lightningpart](-ofss, ofss),
					 frandom[lightningpart](-ofss, ofss),
					 frandom[lightningpart](-ofss, ofss))
				);
			}
			else
			{
				nextPos = vecPos;
			}
			// draw the lightning segment:
			PBX_LightningController.L_DrawLightningSegment(curPos,
				nextPos,
				density: 1,
				size: 4,
				// spawn spark only for the last step:
				spawnSpark: (spawnSpark && d ~== dist - nextStep),
				playersource: playersource
			);
			// store next offset position as the current one
			// for the next draw call:
			curPos = nextPos;
		}
	}

	// Dedicated function to draw a particle beam between two points.
	// YOU CAN COMPLETELY REPLACE THIS to change the visuals of your lightning.
	// This function is just an example of how a lightning can look (mostly because
	// I just wanted to make a decently-looking lightning using only particles).
	// from         : starting position
	// to           : end position
	// density      : per how many units to draw a particle
	// size         : particle size
	// posOfs       : if non-zero, each particle will be randomly offset within this range
	// spawnSpark   : spawn a spark at the 'from' position, if true
	// playerSource : pass a PlayerInfo pointer here if this is being fired by the player.
	// (If playerSouce is non-null, PlayerPawn's velocity will be added to particles for
	// interpolatin purposes.)

	// THIS IS A VERY HACKY CODE THAT REPLACES THE OLD ONE SO IT USES THE NEW EFFECTS
	static void L_DrawLightningSegment(Vector3 from, Vector3 to, double density = 8, double size = 10, bool spawnSpark = true, PlayerInfo playerSource = null)
	{
		Vector3 diff = Level.Vec3Diff(from, to); // difference between two points
		double dist = diff.Length();             // distance from point 1 to point 2
		if (dist <= 0)
		{
			return;
		}
		Vector3 dir = diff / dist;               // direction from point 1 to point 2

		// Beam actor orientation:
		double beamAngle = atan2(diff.y, diff.x);
		double beamPitch = -asin(dir.z);

		double pieceLen = max(density * 16, 1); // tune the multiplier to your beam texture
		Vector3 pos = from;
		double remaining = dist;

		while (remaining > 0)
		{
			double len = min(pieceLen, remaining);

			Actor beam = Actor.Spawn("PBX_Tesla_Beam", pos);
			if (beam)
			{
				beam.angle = beamAngle;
				beam.pitch = beamPitch - 90;
				beam.scale.y = len;
				beam.scale.x *= size / 10.0;
				if (playerSource && playerSource.mo)
				{
					beam.vel = playerSource.mo.vel;
				}
			}

			pos = Level.Vec3Offset(pos, dir * len);
			remaining -= len;
		}

		// If spawnspark is true, spawn some sparks at the end position:
		if (!spawnSpark)
		{
			return;
		}
		
		actor spk = actor.spawn("PBX_EndFx",to);
		if(spk)
			spk.A_Startsound("Tesla/Sparks");

	}

	// This is the old code
	// static void L_DrawLightningSegment(Vector3 from, Vector3 to, double density = 8, double size = 10, bool spawnSpark = true, PlayerInfo playerSource = null, Vector3 sparkNormal = (0,0,0))
	// {
	// 	Vector3 diff = Level.Vec3Diff(from, to); // difference between two points
	// 	Vector3 dir = diff.Unit(); // direction from point 1 to point 2
	// 	double dist = diff.Length(); // distance from point 1 to point 2

	// 	// Generic particle properties:
	// 	FSpawnParticleParams pp;
	// 	pp.color1 = 0xFFCCCCFF;
	// 	pp.flags = SPF_FULLBRIGHT|SPF_REPLACE;
	// 	pp.lifetime = 1;
	// 	pp.size = size; // size
	// 	pp.style = STYLE_Add; //additive renderstyle
	// 	pp.startalpha = 1;
	// 	// Give particle player's velocity if a player
	// 	// is provided. This makes its position appear
	// 	// to match player's movement:
	// 	if (playerSource && playerSource.mo)
	// 	{
	// 		pp.vel = playerSource.mo.vel;
	// 	}
		
	// 	pp.pos = from;
	// 	for (double d = 0.0; d < dist; d += density)
	// 	{
	// 		Level.SpawnParticle(pp);
	// 		pp.pos = Level.Vec3Offset(pp.pos, dir*density);
	// 	}

	// 	if (!spawnSpark)
	// 	{
	// 		return;
	// 	}

	// 	// If spawnspark is true, spawn some sparks at the end position:
	// 	let [hit, hitnormal] = PBXCore_SparkTracer.L_GetHitNormal(from, dir, dist);
	// 	if (!hit)
	// 	{
	// 		return;
	// 	}

	// 	pp.size = size * 0.85;
	// 	pp.lifetime = 30;
	// 	pp.sizestep = -(pp.size / pp.lifetime);
	// 	pp.pos = to;
	// 	pp.accel.z = -0.3;
	// 	double randStep = 0.4;
	// 	for (int i = 5; i > 0; i--)
	// 	{
	// 		pp.vel = (hitnormal + 
	// 		            (frandom[lightningpart](-randStep,randStep),
	// 		             frandom[lightningpart](-randStep,randStep),
	// 		             frandom[lightningpart](-randStep,randStep))) *
	// 		            frandom[lightningpart](2.5,4);
	// 		Level.SpawnParticle(pp);
	// 	}
	// }

	// Adds an actor to the specified array so they're
	// ordered by their distance from the source actor:
	static void L_AddByDistance(Actor thing, Actor source, out array<Actor> victims)
	{
		if (victims.Size() <= 0)
		{
			victims.Push(thing);
			return;
		}

		double distSq = source.Distance3DSquared(thing);

		int lo = 0;
		int hi = victims.Size();
		int mid;
		while (lo < hi)
		{
			mid = (lo + hi) / 2;
			if (distSq <= source.Distance3DSquared(victims[mid]))
				hi = mid;
			else
				lo = mid + 1;
		}
		victims.Insert(lo, thing);
	}

	// Generic check used by lightning to determine if the specified actor
	// is a valid victim for the lightning.
	// who: potential victim to check
	// source: the actor responsible for the damage (shooter)
	static clearscope bool L_IsValidVictim(Actor who, Actor source)
	{
		return who && // valid pointer
			who != source && // not the same as source
			who.bSHOOTABLE && // is actually damageable
			(who.bISMONSTER || who.player) && // is a monster or a player
			who.health > 0 && // alive
			who.isHostile(source); //hostile to source
	}

	static void L_RemoveInvalidVictimsFromArr(Actor damageSource, Actor source, out array<Actor> victims, double dist = 0.0)
	{
		if (victims.Size() <= 0) return;
		else if (!damageSource || !source)
		{
			victims.Clear();
			return;
		}
		
		Actor thing;
		double distSq = dist*dist;
		for (int i = victims.Size() - 1; i >= 0; i--)
		{
			thing = victims[i];
			if ( !thing                                                   || // null
			     !PBX_LightningController.L_IsValidVictim(thing, damageSource)    || // not valid
			     (distSq > 0 && source.Distance3DSquared(thing) > distSq) || // too far
			     !source.CheckSight(thing)                                 ) // out of LoS
			{
				victims.Delete(i);
			}
		}
		victims.ShrinkToFit();
	}

	static void L_AddValidVictimsToArr(Actor damageSource, Actor source, out array<Actor> victims, double dist = 0.0, int maxVictims = 0)
	{
		if(dist == 0.0 || !source || !damageSource) return;
		double distSq = dist*dist;
		foreach (thing : BlockThingsIterator.Create(source, dist))
		{
			if ( PBX_LightningController.L_IsValidVictim(thing, damageSource) && // valid
			     victims.Find(thing) == victims.Size()                && //not yet in array
			     source.Distance3DSquared(thing) <= distSq            && // close enough
			     !PBX_LightningController.L_IsControlled(thing)               && // not yet affected by a controller
			     source.CheckSight(thing)                              )// in LoS
			{
				if (maxVictims > 0)
				{
					PBX_LightningController.L_AddByDistance(thing, source, victims);
				}
				else
				{
					victims.Push(thing);
				}
			}
		}
		// Limit the size of array to maxChains:
		if (maxVictims > 0 && victims.Size() > maxVictims)
		{
			victims.Delete(maxVictims, victims.Size());
			victims.ShrinkToFit();
		}
	}

	override void Tick()
	{
		if (!ac_lightningOrigin || ac_lightningOrigin.bDestroyed || 
			ac_lightningOrigin.bNoSector || !ac_damageSource || 
			ac_damageSource.bDestroyed || ac_damageSource.bNosector)
		{
			Destroy();
			return;
		}
		if (ac_lightningOrigin.IsFrozen())
		{
			return;
		}
		ac_age++;
		// The first controller gets a signal from child controllers
		// that it's time to disappear:
		if (ac_done && !ac_parentController)
		{
			bool alldone = true;
			for (int i = ac_childControllers.Size() - 1; i >= 0; i--)
			{
				let ctrl = ac_childControllers[i];
				if (!ctrl)
				{
					ac_childControllers.Delete(i);
					continue;
				}
				if (!ctrl.ac_done)
				{
					alldone = false;
					break;
				}
			}
			if (alldone)
			{
				for (int i = ac_childControllers.Size() - 1; i >= 0; i--)
				{
					let ctrl = ac_childControllers[i];
					if (ctrl)
					{
						ctrl.Destroy();
					}
				}
				Destroy();
				return;
			}
		}

		if (!ac_done && ac_lightningOrigin)
		{
			if (ac_age <= 1 || ac_damageFrequency <= 1 || ac_age % ac_damageFrequency == 0)
			{
				ac_lightningOrigin.DamageMobj(ac_damageSource, ac_damageSource, ac_damagePerArc, ac_DamageType, DMG_THRUSTLESS);
				if (!ac_lightningOrigin || ac_lightningOrigin.bDestroyed)
				{
					Destroy();
					return;
				}
			}

			// draw circular lightning around the victim to signal
			// it's still affected by the lightning:
			double angstep = frandompick[actlit](30, 45, 60);
			Vector3 curPos, nextPos, origPos;
			Vector2 hOffset = (ac_lightningOrigin.radius, 0);
			curPos.xy = Level.Vec2Offset(ac_lightningOrigin.pos.xy, hOffset);
			curPos.z = ac_lightningOrigin.pos.z + ac_lightningOrigin.height*0.5 + frandom[actlit](-10, 10);
			origPos = curPos;
			for (double ang = 0; ang < 360; ang += angstep)
			{
				if (ang < 360 - angstep)
				{
					nextPos.xy = Level.Vec2Offset(ac_lightningOrigin.pos.xy, Actor.RotateVector(hOffset, ang));
					nextPos.z = ac_lightningOrigin.pos.z + ac_lightningOrigin.height*0.5 + frandom[actlit](-8, 8);
				}
				else
				{
					nextPos = origPos;
				}
				PBX_LightningController.L_DrawLightningSegment(curPos,
					nextPos,
					density: 1,
					size: 4,
					spawnSpark: false
				);
				curPos = nextPos;
			}
		}

		if (ac_delay > 0)
		{
			ac_delay--;
		}
		
		else if (ac_duration > 0)
		{
			if (ac_maxChains > 0 && ac_stage <= ac_maxLinks)
			{
				L_RemoveInvalidVictimsFromArr(ac_damagesource, ac_lightningOrigin, ac_lightningVictims, ac_maxDistance);
				L_AddValidVictimsToArr(ac_damagesource, ac_lightningOrigin, ac_lightningVictims, ac_maxDistance, ac_maxChains);
				foreach(thing : ac_lightningVictims)
				{
					if (thing)
					{
						L_ExtendChainTo(thing);
						L_DrawLightning(L_GetBeamAttachPos(ac_lightningOrigin), L_GetBeamAttachPos(thing));
					}
				}
			}
			ac_duration--;
		}
		// Only the final controller is allowed to trigger
		// destruction of all controllers:
		else
		{
			ac_done = true;
		}
	}
}

// A dedicated base projectile class that can emit lightning
// at surrounding victims;
class PBXCore_LightningProjectile : PB_ProjectileAlt abstract
{
	double ac_detectRange; // range around the projectile at which it'll look for victims
	double ac_range; // range at which the lightning can split to further victims (if allowed)
	int ac_maxvictims; // maximum number of victims this projectile can be hitting at once
	// the other arguments are the same as the PBX_LightningController fields:
	int ac_damage;
	int ac_duration;
	int ac_delay;
	int ac_maxChains;
	int ac_maxLinks;
	name ac_DamageType;
	array<Actor> ac_victims;

	property DetectRange : ac_detectRange;
	property SplitRange : ac_range;
	property MaxVictims : ac_maxvictims;
	property Damage : ac_damage;
	property Duration : ac_duration;
	property Delay : ac_delay;
	property maxChains : ac_maxChains;
	property MaxLinks : ac_maxLinks;
	property DamageType : ac_DamageType;

	Default
	{
		Projectile;
		PBXCore_LightningProjectile.DetectRange 320;
		PBXCore_LightningProjectile.MaxVictims 8;
		PBXCore_LightningProjectile.SplitRange 256;
		PBXCore_LightningProjectile.Damage 5;
		PBXCore_LightningProjectile.Duration 1;
		PBXCore_LightningProjectile.Delay 0;
		PBXCore_LightningProjectile.maxChains 0;
		PBXCore_LightningProjectile.MaxLinks 0;
		PBXCore_LightningProjectile.DamageType "Plasma";
	}

	virtual bool L_IsValidVictim(Actor victim, Actor damageSource, double distSquared)
	{
		return victim &&
			victim != self &&
			PBX_LightningController.L_IsValidVictim(victim, damageSource) &&
			self.Distance3DSquared(victim) <= distSquared &&
			self.CheckSight(victim);
	}

	// Dedicated virtual function that seeks
	// and attacks targets:
	virtual void L_ProjTick()
	{
		// By default it stops attacking or making
		// the zap sound as soon as the projectile
		// explodes (which removes the bMissile flag):
		if (!bMissile)
		{
			A_StopSound(CHAN_VOICE);
			return;
		}

		// If target is gone for some reason, the projectile
		// is the source of the attack:
		Actor damageSource = target != null? target : Actor(self);
		// Update victim arrays:
		PBX_LightningController.L_RemoveInvalidVictimsFromArr(damageSource, self, ac_victims, ac_detectRange);
		PBX_LightningController.L_AddValidVictimsToArr(damageSource, self, ac_victims, ac_detectRange, ac_maxvictims);

		// Make sound if there are any victims:
		if (ac_victims.Size() > 0)
		{
			A_StartSound("lightnin/loop", CHAN_VOICE, CHANF_LOOPING);
		}
		else
		{
			A_StopSound(CHAN_VOICE);
		}

		// Attack victims and draw lightning towards them:
		foreach (thing : ac_victims)
		{
			PBX_LightningController.L_StartChain(damageSource, thing, ac_damage, ac_range, ac_duration, ac_delay, ac_maxChains, ac_maxLinks, damageType:ac_DamageType);
			PBX_LightningController.L_DrawLightning(self.pos.PlusZ(self.height*0.5), thing.pos.PlusZ(thing.height*0.5));
		}
	}

	override void Tick()
	{
		Super.Tick();
		if (isFrozen()) return;

		L_ProjTick();
	}
}

// A simple LineTracer that finds a normal vector of
// whatever surface it hits. Used to spawn sparks in
// a natural trajectory.
class PBXCore_SparkTracer : LineTracer
{
	static bool, Vector3 L_GetHitNormal(Vector3 from, Vector3 dir, double checkDist)
	{
		PBXCore_SparkTracer tracer = new('PBXCore_SparkTracer');
		if (!tracer)
		{
			return false, (0,0,0);
		}
		tracer.Trace(from,
			level.PointInSector(from.xy),
			dir,
			checkDist,
			TRACE_HitSky,
			Line.ML_BLOCKEVERYTHING);
		let res = tracer.results;
		bool collided = res.HitType != TRACE_HitNone;
		Vector3 normal = (0,0,0);
		// Check if a 3d floor was hit, this will affect which
		// surface's normal should be found:
		bool hit3DFloor = res.ffloor != null;
		// Get the normal based on which surface was hit:
		switch(res.HitType)
		{
			case TRACE_HitFloor:
				normal = hit3DFloor? -res.ffloor.top.normal : res.HitSector.floorplane.normal;
				break;
			case TRACE_HitCeiling:
				normal = hit3DFloor? -res.ffloor.bottom.normal : res.HitSector.ceilingplane.normal;
				break;
			case TRACE_HitWall:
				normal.xy = (-res.HitLine.delta.y, res.HitLine.delta.x).Unit();
				if (res.Side == Line.front)
				{
					normal.xy *= -1;
				}
				break;
			// For actors, simply return the negative direction
			// of the trace:
			case TRACE_HitActor:
				normal = -res.hitVector.Unit();
				break;
		}

		return collided, normal;
	}
}

class PBXCore_PropMonster : Actor
{
	Default
	{
		height 56;
		radius 16;
		Translation "0:255=#[255,128,128]";
		+SOLID
		+SHOOTABLE
		+BUDDHA
		+DONTTHRUST
		+ISMONSTER
	}

	States {
	Spawn:
		POSS A -1;
		stop;
	}
}

// RTBW stuff start
Class PBX_Tesla_Beam : Actor
{
	default
	{
		renderstyle "add";
		+bright;
		+INTERPOLATEANGLES;
		+nointeraction;
		//+notimefreeze;
		alpha 1.1;
	}
	states
	{
		Spawn:
			T3SL AAA 1 A_Fadeout(0.335);
			stop;
		LongSpawn:
			T3SL AAAAAA 1 A_Fadeout(0.175);
			stop;
	}
}

class PBX_LightningTarget
{
	actor targ;
	vector3 tpos;
	double ang,pit;
	double dist;
	
	static PBX_LightningTarget addnew(actor t,vector3 ps,double an,double pit,double dis)
	{
		let n = new("PBX_LightningTarget");
		n.targ = t;
		n.tpos = ps;
		n.ang = an;
		n.pit = pit;
		n.dist = dis;
		return n;
	}
}

class PBX_TeslaPosPuff : actor
{
	default
	{
		+nointeraction;
		radius 1;
		height 1;
	}
	states
	{
	spawn:
		TNT1 A 1;
		stop;
	}
}

Class PBX_TeslaSparkbig : actor
{
	default
	{
		+nointeraction;
		renderstyle "add";
		+bright;
		+rollsprite;
		+rollcenter;
		scale 0.5;
	}
	states
	{
		spawn:
			STFL AAAAAA 1 {
				A_Setscale(scale.x + frandom(0.05,0.1));
				A_SetRoll(roll + random(10,20));
				//A_Fadeout(0.1);
			}
			TNT1 A 0 A_Setscale(frandom(0.4,0.6));
			XELC CDEF 1;
			stop;
	}
	override void postbeginplay()
	{
		super.postbeginplay();
		bxflip = random(0,1);
		A_SetRoll(random(0,360));
		A_Attachlight('TatsuroYamashita',DynamicLight.Pointlight,0x80FAFF,60,70);
	}
}

Class PBX_EndFx : Actor
{
	default
	{
		+nointeraction;
		renderstyle "Add";
		scale 0.12;
		+bright;
		+rollsprite;
		+rollcenter;
	}
	states
	{
		spawn:
			XELC A 1;
			TNT1 A 1;
			XELC B 1;
			TNT1 A 1;
			XELC C 1;
			TNT1 A 1;
			XELC D 1;
			TNT1 A 1;
			XELC E 1;
			TNT1 A 1;
			XELC F 1;
			stop;
			//DB21 BBBB 1 bright A_fadeout(0.33);
			//PLSE ABCDE 2 Bright;
			// stop;
	}

	override void postbeginplay()
	{
		super.postbeginplay();
		A_SetRoll(random(0,360));
		A_Setscale(scale.x + frandom(-0.02,0.03));
		A_Attachlight('TatsuroYamashita',DynamicLight.Pointlight,0x80FAFF,15,22);
	}
}