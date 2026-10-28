// Includes
#include "./PBX_LaserSight.zs"
#include "./PBX_SmartScope.zs"
#include "./PBX_ScrollZoom.zs"
#include "./PBX_WeaponWheel.zs"

// Generic Weapon Wheel Tokens
class PBX_Toggle_Laser : inventory {default{inventory.maxamount 1;}}
class PBX_Toggle_Scope : inventory {default{inventory.maxamount 1;}}
class PBX_Toggle_NVG   : inventory {default{inventory.maxamount 1;}}
class PBX_CloseWheel   : inventory {default{inventory.maxamount 1;}}

// What gives the player Nightvision, its basically a powerup
class PBX_Infrared : PB_PowerLightAmp  {default{Powerup.Duration -1800;}}

// Constants
const PBX_COOLDOWN_CHAN = 193; // Sound channel for the cooldowns

class PBX_WeaponBase : PB_WeaponBase abstract
{
//////////////////////////// WEAPON SETUP ////////////////////////////////////////////////////////////////////////////////////
    Default
    {
        PBX_WeaponBase.ScopeConfiguration false, 1.0, 1.0; 
        PBX_WeaponBase.SelectWeaponUpgrade "";
        PBX_WeaponBase.TakeWeaponDowngrade "";
    }

    override void PostBeginPlay()
    {
        mZoomLevel = mMinZoom;
        super.PostBeginPlay();
    }

    override void DoEffect() 
	{
		super.DoEffect();

        if (level.isFrozen()) return;
        
		If(owner.player && owner.player.readyweapon && owner.player.readyweapon.GetClass() is self.GetClass())
        {
		    PBX_HandleNightVision();
            PBX_DoEffectWeaponReady();
		}
    }

    override void OnDrop (Actor dropper)
    {
        ClearPuff(); 
        if(mLaserPuff) mLaserPuff.bInvisible = true;
    }

    protected virtual void PBX_DoEffectWeaponReady() {}

    // A wrapper for PB_WeaponRaise so we can do some default behaviours
    action void PBX_WeaponRaise(string upSnd = "")
    {
        A_WeaponOffset(0,32);
        PB_SetRoll(0);
        PB_WeaponRaise(upSnd);
        if(PBX_Armament_SendTip) PBX_WeaponHelpText(); // This function is in PBX_Weapons_Tips.zs
        PBX_UpgradeWeapon();
    }

    // Same as above
    action void PBX_WeaponLower()
    {
        PB_SetZoom(false);
        A_SetInventory("PBX_Infrared", 0);
        A_WeaponOffset(0,32);
        PB_SetRoll(0);
        A_StopSound(CHAN_WEAPON);
        PB_ClearDualWield();
        // Clears the Laser Sight Puff
        invoker.ClearPuff(); 
        if(invoker.mLaserPuff) invoker.mLaserPuff.bInvisible = true;
    }

    private name mUpgradeWeapon, mDowngradeWeapon;
    property SelectWeaponUpgrade: mUpgradeWeapon;
    property TakeWeaponDowngrade: mDowngradeWeapon;
    action void PBX_UpgradeWeapon()
    {
        if(PBX_Weapons_keepweapons) return;

        if(invoker.mUpgradeWeapon != "") PB_SelectIfUpgrade(invoker.mUpgradeWeapon);
        if(invoker.mDowngradeWeapon != "") PB_TakeIfUpgrade(invoker.mDowngradeWeapon);
    }

    // Coin Stuff
	int mCoinCooldown;
    const COIN_LAYER = -271;

    // Note: really need to decide whether to play the zoom out animation first
    // before checking dual wield
    action state PBX_SetupDualWield(string noAkimboMsg)
    {
        // Dual Wield Toggle
        if (A_CheckAkimbo()) 
        {
            PB_ClearDualWield();
            return ResolveState("StopDualWield");
        }

        if (invoker.amount >= 2) 
        {
            PB_SetZoom(false);
            return ResolveState("SwitchToDualWield");
        }

        // If you dont have 2 weapon
        A_Print(noAkimboMsg);
        return ResolveState("Ready3");
    }

    action state PBX_HandleDurability(name toCheck, int ammoTake)
    {
        if (CountInv(toCheck) < 1) 		        return ResolveState("WeaponBreak");
		if (invoker.ammo1.amount < ammoTake) 	return ResolveState("NoAmmo");
		return ResolveState(null);
    }

//////////////////////////// NVG ////////////////////////////////////////////////////////////////////////////////////
    private bool mNightVisionActivated;
    action void PBX_ToggleNightVision()
    {
        invoker.mNightVisionActivated = !invoker.mNightVisionActivated;
        A_Print(invoker.mNightVisionActivated ? "$PBX_nvgOn" : "$PBX_nvgOff");
        A_SetInventory("PBX_Infrared", invoker.mNightVisionActivated);

        if(invoker.mNightVisionActivated) 
            A_StartSound("RA1IF1", CHAN_WEAPON, CHANF_OVERLAP, 1.0);

        A_SetBlend("Black",0.75,16);
    }

    clearscope bool IsNVGActive()
    {
        return mNightVisionActivated;
    }

    // Call in DoEffect()
    private bool mShouldPlayNVGSound;
    void PBX_HandleNightVision()
    {
        bool isZoomed = owner.FindInventory("Zoomed");

        if(IsNVGActive() && isZoomed)
        {
            owner.A_SetInventory("PBX_Infrared",1);
            if(mShouldPlayNVGSound)
            {
                owner.A_StartSound("RA1IF1", CHAN_AUTO, CHANF_OVERLAP);
                mShouldPlayNVGSound = false;
            }
        }
        else
        {
            owner.A_SetInventory("PBX_Infrared",0);
            mShouldPlayNVGSound = true;
        }
    }

//////////////////////////// FIRING ////////////////////////////////////////////////////////////////////////////////////
    action void PBX_FireBeam(int damage, int target, int range)
	{
		vector3 fw = (cos(angle),sin(angle),0);
		int playerz = height * 0.5 - floorclip + player.mo.AttackZOffset * player.crouchFactor;
		playerz -= 6;
		
		//get the pitch and adjust the forward offset if looking up/down
		//cos(pitch) < 1.0, and get closer to 0 when looking up/down, ig sin(pitch) ** 2 could also work (yes,this time the calculator wasnt in radians :D)
		double pt = cos(pitch);
		if(pt < 1.0)
		{
			if(pt < 0.1) //if pt is lower than 0.1, set it as 0.1, so it doesnt spawn at player feets
				pt = 0.1;
			fw *= (pt*pt);
		}
		
		double pit = pitch;
		for(int i = 0; i < target; i++)
		{
			flinetracedata t;
			//randomize the beam direction
			double actpitch = pit + frandom(-10,10);
			double actangle = angle + frandom(-10,10);
			
			bool shouldEnd;	//indicates this beam should stop, since it either hit geometry or hit an actor or went too far
			int maxdistTravel = 450; //9 segments if it goes the full path
			bool isFirst = true;
			vector3 cursp = (pos.xy + fw.xy,pos.z + playerz);
			
			vector2 prevangles = (actangle,actpitch);
			vector3 hitloc;
			actor from;		//pointer to the last dummy puff, used to fire linetraces
			int safety = 0;	//just in case, we dont want infinite loops
			bool landed;	
			
			//fire the linetraces
			while(!shouldEnd)
			{
				bool avoid = false;
				if(safety > 12)	//normally no iteration should go this far, but just in case
				{
					shouldend = true;
					break;
				}
				
				if(isFirst)	//fire the trace from the player
				{
					linetrace(actangle,range,actpitch,0,playerz,1,0,t);
					isFirst = false;
					avoid = true;
				}
				else		//fire the trace from the dummy puff
				{
					if(!from)
					{
						shouldend = true;
						break;
						return;
					}
					from.linetrace(prevangles.x,range,prevangles.y,0,1,-1,0,t);
					
				}
				
				//substract the traveled distance
				maxdistTravel -= t.distance;
				
				//indicates the beam hit geometry
				if(t.hittype == TRACE_HitFloor ||
				t.hittype == TRACE_HitCeiling  ||
				t.hittype == TRACE_HitWall )
				{
					shouldEnd = true;
					landed = true;
				}
				
				//hit an actor
				if(t.hitactor != null)
				{
					t.hitactor.TriggerPainChance("Stun", true);
					if(from)
						t.hitactor.damagemobj(from,self,damage,'plasma');
					else
						t.hitactor.damagemobj(self,self,damage,'plasma');
					shouldEnd = true;
				}
				
				//check the distance left to travel
				if(maxdistTravel <= 0)
					shouldEnd = true;
				
				if(!avoid)	//skip the first beam
					PBX_DrawBeam(cursp,t.hitlocation - t.hitdir,prevangles);
					
				safety++;
				//update variables
				cursp = t.hitlocation - t.hitdir;
				prevangles += (frandom(-15,15),frandom(15,-15));	//randomize the next beam direction
				hitloc = t.hitlocation - t.hitdir;
				from = spawn("PBX_TeslaPosPuff",cursp);		//spawn a dummy puff
				
			}
			//vector3 ds = levellocals.vec3diff(pos + (0,0,playerz),hitloc);
			//double di = ds.length();
			//console.printf("");
			//console.printf("hit %d took %d interations (maxdist: %d, traveled: %f)",i,ite,maxdisttravel,di);
			if(landed)
			{
				actor spk = spawn("PBX_EndFx",hitloc);
				if(spk)
					spk.A_Startsound("Tesla/Sparks");
					spk.A_startsound("Tesla/FireAdd",CHAN_AUTO, CHANF_OVERLAP, 1);
			}
			
		}
		
		PB_QuakeCamera(4, 1);
		PB_WeaponRecoil(-0.1, frandom(-0.2,0.2));
	}
	
	action void PBX_FireShock(int damage, int target, int range)
	{
		blockthingsiterator bti = blockthingsiterator.create(self,500);
		array<PBX_LightningTarget> vic;
		int maxbeams = target;
		
		while(bti.next())
		{
			actor mo = bti.thing;
			double an = deltaangle(angle,angleto(mo));
			
			if(mo && mo.bismonster && mo.health > 0 && maxbeams > 0
			&& abs(an) < 45 && distance3d(mo) <= 450 && checksight(mo))
			{
				vic.push(
				PBX_LightningTarget.addnew(mo,mo.pos + (0,0,mo.height * 0.5),angleto(mo),pitchto(mo),distance3d(mo))
				);
				maxbeams--;
			}
		}
		
		PBX_FireBeam(damage,target,range);
		
		if(vic.size() <= 0)
			return;
		
		vector3 fw = (cos(angle),sin(angle),0);
		int playerz = height * 0.5 - floorclip + player.mo.AttackZOffset * player.crouchFactor;
		playerz -= 6;
	
		//get the pitch and adjust the forward offset if looking up/down
		//cos(pitch) < 1.0, and get closer to 0 when looking up/down, ig sin(pitch) ** 2 could also work (yes,this time the calculator wasnt in radians :D)
		double pt = cos(pitch);
		if(pt < 1.0)
		{
			if(pt < 0.1) //if pt is lower than 0.1, set it as 0.1, so it doesnt spawn at player feets
				pt = 0.1;
			fw *= (pt*pt);
		}
		
		for(int i = 0; i < vic.size(); i++)
		{
			if(!vic[i])
				continue;
			flinetracedata t;
			//randomize the initial beam direction
			double actpitch = pitch + frandom(-7,12);
			double actangle = angle + frandom(-12,12);
			bool isFirst = true;
			int safety = 0;
			vector3 cursp = (pos.xy + fw.xy,pos.z + playerz);
			double disttravel = vic[i].dist;
			int its = vic[i].dist / range;
			its = max(1,its);
			vector2 prevangles = (actangle,actpitch);
			vector3 hitloc;
			bool landed;	
			bool shouldend;
			actor from;

			bool setted;
			
			while(!shouldend)
			{
				bool avoid = false;
				if(safety > 14)	//normally no iteration should go this far, but just in case
				{
					shouldend = true;
					break;
				}
				
				if(isFirst)	//fire the trace from the player
				{
					linetrace(actangle,range,actpitch,0,playerz,1,0,t);
					isFirst = false;
					avoid = true;
				}
				else		//fire the trace from the dummy puff
				{
					if(!from)
					{
						shouldend = true;
						break;
						return;
					}
					from.linetrace(prevangles.x,
					max(disttravel < range ? disttravel : range,0)
					,prevangles.y,0,1,-1,0,t);
					
				}
				
				disttravel -= t.distance;
				
				if(disttravel <= 0)
				{
					shouldend = true;
					break;
				}
				safety++;
				if(!avoid)
					PBX_DrawBeam(cursp,t.hitlocation - t.hitdir,prevangles);
				//update variables
				cursp = t.hitlocation - t.hitdir;
				//prevangles += (frandom(-7,7),frandom(5,-3));	//randomize the next beam direction
				if(safety < 2)
					prevangles += (frandom(-7,7),frandom(5,-3));
				else
				{
					if(!setted && vic[i] && vic[i].targ)
					{
						if(!from)
							from = spawn("PBX_TeslaPosPuff",cursp);
						//idk why i overcomplicated too much with this
						/*vector3 diffr = levellocals.vec3diff(from.pos,vic[i].tpos);
						vector3 dir = diffr.unit();
						double angh = atan2(dir.y,dir.x);
						double angv = atan(-dir.z/dir.x);*/
						double angh = from.angleto(vic[i].targ);
						double angv = from.pitchto(vic[i].targ);
						prevangles = (angh,angv);
						setted = true;
					}
					else
						prevangles += (frandom(-1.0,1.0),frandom(1.0,-1.0));
					
				}
				
				hitloc = t.hitlocation - t.hitdir;
				from = spawn("PBX_TeslaPosPuff",cursp);		//spawn a dummy puff
				from.angle = prevangles.x;
				from.pitch = prevangles.y;
			}
			
			if(landed)
			{
				actor spk = spawn("PBX_EndFx",hitloc);
				if(spk)
					spk.A_Startsound("Tesla/Sparks");
			}
			
			if(vic[i] && vic[i].targ)
			{
				vic[i].targ.TriggerPainChance("Stun", true);
				if(from)
					vic[i].targ.damagemobj(from,self,damage,'plasma',DMG_USEANGLE,from.angleto(vic[i].targ));
				else
					vic[i].targ.damagemobj(self,self,damage,'plasma',DMG_USEANGLE,self.angleto(vic[i].targ));
			}
		}
		PB_QuakeCamera(4, 1);
		PB_WeaponRecoil(-0.1, frandom(-0.2,0.2));
	}

	action void PBX_DrawBeam(vector3 cur, vector3 next,vector2 angles, bool islong = false)
	{
		actor beam;
		cur.z -= 5;
		
		vector3 diff = levellocals.vec3diff(cur,next);
		double dist = diff.length();
		
		beam = spawn("PBX_Tesla_Beam",cur);
		if(beam)
		{
			beam.angle = angles.x;
			beam.pitch = (angles.y - 90);
			beam.scale.y = (dist + 5);
			if(islong)
				beam.setstatelabel("LongSpawn");
		}
	}

    action void PBX_FireLightningShotgun(
        int damage = 25,
        int numrays = 32,
        double coneAngle = 40,
        double distance = 1024,
        double vrange = 30,
        int duration = 1,
        int delay = 0,
        int maxChains = 5,
        int maxLinks = 0,
        name damageType = 'plasma'
    )
    {
        Vector3 beamstart = PBX_LightningController.L_GetBeamAttachPos(self);
        Array<Actor> hitTargets;

        for (int i = 0; i < numrays; i++)
        {
            double an = angle - coneAngle * 0.5 + (numrays > 1 ? coneAngle / (numrays - 1) * i : 0);

            FTranslatedLineTarget t;
            AimLineAttack(an, distance, t, vrange);

            if (t.linetarget && PBX_LightningController.L_IsValidVictim(t.linetarget, self)
                && hitTargets.Find(t.linetarget) == hitTargets.Size())
            {
                hitTargets.Push(t.linetarget);
            }
        }

        for (int i = 0; i < hitTargets.Size(); i++)
        {
            PBX_LightningController.L_StartChain(self, hitTargets[i], damage, distance, duration, delay, maxChains, maxLinks, damageType:damageType);

            Vector3 beamEnd = PBX_LightningController.L_GetBeamAttachPos(hitTargets[i]);
            PBX_LightningController.L_DrawLightning(beamstart, beamEnd, spawnSpark: true, playersource: player);
        }

    }

    // PB's firebullets modified to shoot non pb_projectile projectiles
    // Taken from one of CSSG's function
    action void PBX_FireBullets(string type, int amount, double angle, double offs, double height, double pitch)
	{
		vector2 spread;
		for(int i = amount; i > 0; i--)
		{
			spread.x = frandom(-angle, angle);
			spread.y = frandom(-pitch, pitch);

			if(i == amount) 
			{
				spread.x *= PB_Math.LinearMap(pb_weapon_recoil_mod_horizontal, 0.0, 1.0, 1.0, 0.2);
				spread.y *= PB_Math.LinearMap(pb_weapon_recoil_mod_vertical, 0.0, 1.0, 1.0, 0.2);
				// spread *= clamp((invoker.sustainedFire / 5), 0, 1);
				spread *= GetCrouchFactor();
			}

			Actor p1, p2 = A_FireProjectile(type, spread.x, 0, offs, height, FPF_NOAUTOAIM, spread.y);

            if(p2)
            {
                PB_Projectile pbProj = PB_Projectile(p2);
				if(pbProj)
					pbProj.isBloodExplosionGenerator = amount > 4 && i == amount;
            }
		}
	}

    // Fire Lighting
    action void PBX_FireLightningGun(
        int     damage, 
        double  horOfs      = 0, 
        double  spawnheight = 0, 
        double  range       = 512, 
        int     duration    = 1, 
        int     delay       = 0, 
        int     maxChains   = 1, 
        int     maxlinks    = 5,
        name    damageType  = 'plasma'
    )
	{
		// beamstart is where the lightning appears from:
		Vector3 beamstart = PBX_LightningController.L_GetBeamAttachPos(self, horOfs, spawnheight);
		Vector3 beamEnd;

		// hit victim:
		FLineTraceData tr;
		LineTrace(angle, range, pitch, offsetz: PBX_LightningController.L_GetAttackHeight(PlayerPawn(self)), data: tr);
		if (tr.HitType == TRACE_HitActor && tr.hitActor && PBX_LightningController.L_IsValidVictim(tr.hitActor, self))
		{
			beamEnd = PBX_LightningController.L_GetBeamAttachPos(tr.HitActor);
			PBX_LightningController.L_StartChain(self, tr.HitActor, damage, range, duration, delay, maxChains, maxlinks, damageType:damageType);
			tr.hitactor.TriggerPainChance("Stun", true);
		}
		// hit nothing:
		else
		{
			beamEnd = tr.HitLocation;
		}
		PBX_LightningController.L_DrawLightning(beamstart, beamend, spawnSpark: (tr.HitType != TRACE_HitNone), playersource: player);
	}

    // Ricochet function from BDP
    Action void PBX_FireRicochet(
        name projectileName, 
        name casingName = "",
        int projectileAmount = 1, 
        double angle = 1.0,
        double offsets = 0, 
        double height = 0, 
        double pitch = 0,
        name damageType = "Pistol",
        name puffType = "PB_BulletPuff"
    )
	{
		FLineTraceData ricochetdata;
		invoker.owner.LineTrace(invoker.owner.angle, 4096, invoker.owner.pitch, TRF_SOLIDACTORS, offsetz: invoker.owner.player.viewz - invoker.owner.pos.z, data: ricochetdata);
		vector3 hitNormal;

		if(ricochetdata.HitType == TRACE_HitWall )
		{
			if(!ricochetdata.LineSide)
            {
                hitnormal = (ricochetdata.Hitline.delta.y, -ricochetdata.Hitline.delta.x, 0).unit();
            }
			else
            {
                hitnormal = (-ricochetdata.Hitline.delta.y, ricochetdata.Hitline.delta.x, 0).unit();
            }
		}
        
		else if (ricochetdata.HitType == TRACE_HitFloor)
        {
            hitnormal = ricochetdata.HitSector.FloorPlane.normal;
        }
			
		else if (ricochetdata.HitType == TRACE_HitCeiling)
        {
            hitnormal = ricochetdata.HitSector.CeilingPlane.normal;
        }

		Vector3 PlayerAngle = BDPMATH.AngletoVector3(1.0,invoker.owner.angle,invoker.owner.pitch);
		Vector3 BounceAngle = BDPMATH.BounceNormal(PlayerAngle,hitNormal);
		
		Double NextShotAngle,NextShotPitch;
		[NextShotAngle, NextShotPitch] = BDPMATH.Vector3toangles(BounceAngle);

		double anglediff = BDPMath.AngleDiff(invoker.owner.angle % 360.0,nextshotangle % 360.0);
		double pitchdiff = BDPMath.AngleDiff(invoker.owner.pitch % 360.0,nextshotpitch % 360.0);
		
		Vector3 NextShotPosition = level.Vec3Offset(ricochetData.hitlocation, hitnormal * 2.0);
		
        // Actually fire
        PBXCore_Debug.Print("Projectile Fired");
		PB_FireBullets(projectileName, projectileAmount, angle, offsets, height, pitch);
        if(casingName != "")
        {
            PB_SpawnCasing(casingName,22,2,28,frandom[sfx](-2, -1),frandom[sfx](5,8),frandom[sfx](3,4));
        }

		If(pitchdiff > 45 || anglediff > 45 || pitchdiff < -45 || anglediff < -45)
        {
            return;
        }
		
		If(ricochetdata.HitType == TRACE_HitWall || ricochetdata.HitType == TRACE_HitFloor || ricochetdata.HitType == TRACE_HitCeiling)
		{
            PBXCore_Debug.Print("Ricochet");
			Invoker.Owner.LineAttack(NextShotAngle,8192,NextShotPitch,35,damageType,puffType,LAF_ABSPOSITION | LAF_ABSOFFSET,null,NextShotPosition.Z,NextShotPosition.x,NextShotPosition.y);
			let ricochettracer = Invoker.owner.spawn("decorativetracer",nextshotposition);
			If(ricochettracer)
			{
                PBXCore_Debug.Print("Ricochet Tracer");
				ricochettracer.angle = nextshotangle;
				ricochettracer.pitch = nextshotpitch;
				ricochettracer.vel3dfromangle(140,nextshotangle,nextshotpitch);
			}
		}
	}

    action void A_Recoil3D(double amt)
	{
		vel += BDPMath.VecFromAngles(angle, pitch, -amt);
	}

//////////////////////////// OTHERS ////////////////////////////////////////////////////////////////////////////////////
    Action Void PBX_DrawRedRail(vector3 where, double alfa = 1.0, int size = 10)
	{
		FSpawnParticleParams BlueRailPx;
		BlueRailPx.Texture = TexMan.CheckForTexture("CPSQB0");
		BlueRailPx.Color1 = "FFFFFF";
		BlueRailPx.Style = STYLE_Add;
		BlueRailPx.Flags = SPF_ROLL|SPF_FULLBRIGHT|SPF_NOTIMEFREEZE;
		BlueRailPx.Vel = (0,0,0); 
		BlueRailPx.Startroll = randompick(0,180);
		BlueRailPx.RollVel = 0;
		BlueRailPx.StartAlpha = 1.0;
		//fadestep and lifetime controls how fast it dissappears
		BlueRailPx.FadeStep = 0;
		BlueRailPx.Size = size;
		BlueRailPx.SizeStep = 0.01;
		BlueRailPx.Lifetime = 1;
		BlueRailPx.Pos = where;
		Level.SpawnParticle(BlueRailPx);
	}

    Action Void PBX_DrawBlueRail(vector3 where, double alfa = 1.0, int size = 10)
	{
		FSpawnParticleParams BlueRailPx;
		BlueRailPx.Texture = TexMan.CheckForTexture("CPSQC0");
		BlueRailPx.Color1 = "FFFFFF";
		BlueRailPx.Style = STYLE_Add;
		BlueRailPx.Flags = SPF_ROLL|SPF_FULLBRIGHT|SPF_NOTIMEFREEZE;
		BlueRailPx.Vel = (0,0,0); 
		BlueRailPx.Startroll = randompick(0,180);
		BlueRailPx.RollVel = 0;
		BlueRailPx.StartAlpha = 1.0;
		//fadestep and lifetime controls how fast it dissappears
		BlueRailPx.FadeStep = 0;
		BlueRailPx.Size = size;
		BlueRailPx.SizeStep = 0.01;
		BlueRailPx.Lifetime = 1;
		BlueRailPx.Pos = where;
		Level.SpawnParticle(BlueRailPx);
	}

    action state PBX_CheckInspect()
    {
		int ammoToCheck = invoker.ammotype2 ? invoker.ammo2.amount : 0;
        int maxAmmoToCheck = invoker.ammotype2 ? invoker.ammo2.maxamount : 0;
        bool pressingReload = PressingReload() || (player.oldbuttons & BT_RELOAD);

        if (pressingReload && ammoToCheck >= maxAmmoToCheck) 
        {
            return resolvestate("WeaponInspect");
        }
        return resolvestate(null);
    }

    action bool PlayerPressedOnce(int button)
	{
		int bt = player.cmd.buttons;
		int oldbt = player.oldbuttons;
		if((bt & button) && !(oldbt & button))
        {
            return true;
        }
		return false;
	}

    action state A_PressingReload(StateLabel st = "Reload")
	{
		if ((player.cmd.buttons & BT_RELOAD) || (player.oldbuttons & BT_RELOAD)) 
        {
            return resolvestate(st);
        }
        return resolvestate(null);
	}

    // Return to a ready state based on zoom
    action state PBX_ReturnReady(StateLabel zoomed = "Ready2", StateLabel normal = null)
    {
        if(A_CheckAkimbo() && normal) return resolvestate(normal);
        if(PB_GetZoom()) return resolvestate(zoomed);
        return resolvestate(normal);
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
        // Used by monster weapons since they have durability
        WeaponBreak:
			TNT1 A 0 {
				for(int i = 0; i < 5; i++)
				{
					A_CustomMissile("MetalShard1", 5, 0, random[sfx](-10, -20), 2, random[sfx](0, 30));
					A_CustomMissile("MetalShard2", 5, 0, random[sfx](-10, -20), 2, random[sfx](0, 30));
					A_CustomMissile("MetalShard3", 5, 0, random[sfx](-10, -20), 2, random[sfx](0, 30));
				}
				A_ALertMonsters();
				A_Startsound("meleeweapon/break");
            }
        // So any weapon can go to this state if they want to be safely removed
        SafelyRemoveWeapon:
            TNT1 A 0 {
                Weapon savedWeapon = player.mo.BestWeapon(null);
				let handler = PBX_PreviousWeapon_Handler.Get();
				if(handler)
				{
					savedWeapon = handler.getPreviousWeapon();
				}
				player.pendingweapon = savedWeapon;
				self.RemoveInventory(invoker);
            }
			Stop;

        // Fail safe
        WeaponInspect:
            TNT1 A 0;
            goto Ready;
    }

}

//////////////////////////// CUBES ////////////////////////////////////////////////////////////////////////////////////
// Cubes
Class PBX_CubeRadius : actor
{
	DEFAULT
	{
		Radius 20;
		Height 20;
		Scale 32.0;
		//RenderStyle "STYLE_Translucent";
		//Alpha 0.8;
		+NOINTERACTION
		+NOBLOCKMAP
		+THRUACTORS
		-RANDOMIZE
	}

	int mColor;

	enum PBX_CubeColor
	{
		RED,
		GREEN,
		BLUE
	}

	States
	{
		Spawn:
			0001 A 0;
			0000 A 1 {
				if(mColor == BLUE)
					sprite = GetSpriteIndex("0001");
			}
			stop;
	}
}

Class PBX_CubeRadiusLoop : PBX_CubeRadius
{
	States
	{
		Spawn:
			0000 A 0;
			0000 A 1;
			wait;
	}
}

class PBX_RadiusVisualizer : Inventory
{
    Actor currentCube;

    Default
    {
        +INVENTORY.UNDROPPABLE;
    }

    override void DoEffect()
    {
        Super.DoEffect();

        if (!owner) return;

        if (currentCube && currentCube.bDestroyed)
        {
            currentCube = null;
        }

        // Spawn and size — runs once when cube is null
        if (!currentCube)
        {
            currentCube = Spawn("PBX_CubeRadiusLoop", owner.pos);
            if (!currentCube) return;

            // Set size once on spawn
            currentCube.scale.x = double(owner.radius) * 2;
            currentCube.scale.y = double(owner.height);
        }

        // Every tic change position only
        currentCube.SetOrigin(owner.pos, true);
        currentCube.vel = owner.vel;
        currentCube.angle = owner.angle;
    }

    override void OnDestroy()
    {
        if (currentCube && !currentCube.bDestroyed)
        {
            currentCube.Destroy();
            currentCube = null;
        }

        Super.OnDestroy();
    }
}