#include "./PBX_BulletsDef.zs"
#include "./PBX_DemonDef.zs"
#include "./PBX_EnergyDef.zs"
#include "./PBX_ExplosivesDef.zs"
#include "./PBX_NailsDef.zs"
#include "./PBX_ShellsDef.zs"
#include "./PBX_LightningDef.zs"
#include "./PBX_FreezesDef.zs"

// Lightning projectile base
mixin class PBX_LightningProjectile
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

    // Example
	// Default
	// {
	// 	Projectile;
	// 	PBXCore_LightningProjectile.DetectRange 320;
	// 	PBXCore_LightningProjectile.MaxVictims 8;
	// 	PBXCore_LightningProjectile.SplitRange 256;
	// 	PBXCore_LightningProjectile.Damage 5;
	// 	PBXCore_LightningProjectile.Duration 1;
	// 	PBXCore_LightningProjectile.Delay 0;
	// 	PBXCore_LightningProjectile.maxChains 0;
	// 	PBXCore_LightningProjectile.MaxLinks 0;
	// 	PBXCore_LightningProjectile.DamageType 'plasma';
	// }

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
		if(!bMissile)
		{
			A_StopSound(CHAN_VOICE);
			return;
		}

		// If target is gone for some reason, the projectile
		// is the source of the attack:
		Actor damageSource = target != null ? target : Actor(self);
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

}

// Homing Projectiles Base
// The code is from ToxicFrog's Gun Bonsai
class HomingShots_Aux : Inventory 
{
	uint level;

	States 
	{
		Homing:
			TNT1 A 0 DoHoming();
			TNT1 A 2;
			LOOP;
	}

	// Check if we're in the terminal homing phase of flight. In order to qualify
	// we need to have a target, have a clear line of sight to it, and to have
	// passed those checks twice in a row.
	bool TerminalHoming() 
	{
		return owner.tracer && owner.CheckLOF(
			0, 			 // flags
			64+level*32, // range, 2m + 1m/level
			0, 			 // minrange
			0, 0, 		 // angles
			0, 0, 		 // offset
			AAPTR_TRACER
		);
	}

	void DoHoming() 
	{
		if (!owner) 
		{
			// Our owning projectile vanished. Ideally this should have destroyed us
			// as well, but sometimes that doesn't happen.
			Destroy();
			return;
		}

		// This is kind of gross.
		// Ideally, we'd just call A_SeekerMissile and let it do its thing. However,
		// when it acquires a lock on something it adjusts the Z velocity without
		// any concern for the maximum turn angle settings, which results in a lot
		// of flying directly into a wall/ceiling.

		// So instead, when we're in target-seek mode, we save our current vectors
		// and call A_SeekerMissile() to find a target, then restore the old vectors
		// so even if we find a target the shot continues to fly straight.
		// Note that in some cases, even if it can't acquire a lock (tracer=null after
		// it returns), it'll still fuck with our vectors!
		if (!TerminalHoming()) 
		{
			//   DEBUG("%s: terminal: no, tracer: %s", TAG(owner), TAG(owner.tracer));
			owner.tracer = null;
			let vel = owner.vel;
			let angle = owner.angle;
			
			owner.A_SeekerMissile(
			0, // terminal homing cone radius
			1, // max turn angle per tic, degrees
			
			SMF_LOOK | SMF_PRECISE | SMF_CURSPEED,
			min(level*256, 256), // chance of acquiring a new target if it doesn't have one
			min(ceil((64 + level*32)/128.0), 8)); // scan range for new targets in blocks

			// Reject anything that is not a PB_Monster
			if (owner.tracer && !(owner.tracer is "PB_Monster")) owner.tracer = null;

			owner.vel = vel;
			owner.angle = angle;
		} 
		else 
		{
			//   DEBUG("%s: terminal: yes, tracer: %s", TAG(owner), TAG(owner.tracer));
			if(PBXCore_DebugCVAR)
			{
				console.printf("%s: terminal: yes, tracer: %s", owner.getTag(), owner.tracer.getTag());
			}
			// If we get here we are in "terminal homing mode", which means that:
			// - we have a target
			// - the target is within our terminal homing radius, which depends on
			//   the upgrade level
			// - we have a clear line of sight to the target
			// - all of these conditions have been true two updates in a row
			// which means we should let A_SeekerMissile take over flight control and
			// guide us in.
			owner.A_SeekerMissile(
				0, 				// terminal homing cone radius
				min(level, 90), // max turn angle per tic, degrees
				SMF_PRECISE | SMF_CURSPEED
			);
		}

		if (owner.tracer != null && PBXCore_DebugCVAR)
		{
			if(owner.tracer.CountInv("PBX_RadiusVisualizer") < 1)
				owner.tracer.GiveInventory("PBX_RadiusVisualizer",1);
		}
	}
}

// Coin
Class PBX_Coin : actor
{
	DEFAULT
	{
        Projectile;
        +BOUNCEONWALLS
        +BOUNCEONCEILINGS
        +BOUNCEONFLOORS
        WallBounceFactor 0.1;
        BounceFactor 0.2;
        DamageFactor "poison", 0.0;
        DamageFactor "Bleedout", 0.0;
        BounceSound "revolver/coinBounce";
        DeathSound "revolver/coinDeath";
        Damage 1;
        +BOUNCEAUTOOFFFLOORONLY
        -NOGRAVITY
        +DONTTHRUST
        +SHOOTABLE;
        -NOBLOCKMAP
        +NORADIUSDMG;
        +ISMONSTER;
        +FRIENDLY;
        -COUNTKILL;
        +THRUACTORS
        +FORCEPAIN
        +ROLLSPRITE
        +ROLLCENTER
        Speed 20;
        PainChance 255;
        Gravity 0.5;
        seeSound "revolver/coin";
        +BRIGHT;
        Health 4000;
        +BUDDHA
        +FORCEXYBILLBOARD
        +LOOKALLAROUND
        scale 0.5;
        +NOTARGET;
        +NEVERTARGET;
        +NOBLOOD
        +STOPRAILS
        +MTHRUSPECIES
        +THRUSPECIES
        ProjectileKickback 1;
	}
	
	void CheckForBarrels()
	{
		BlockThingsIterator it = BlockThingsIterator.Create(self, 256);
		Actor mo;
		while (it.Next())
		{
			mo = it.thing;
			if (mo 
			&& mo is "PB_BarrelBase" 
			&& mo.health > 0
			&& CheckSight(mo)
			)
			{
				target = mo;
				A_FaceTarget(0,180, flags:FAF_TOP);
				break;
			}
		}
	}
	
	States
	{
        Spawn:
            COIN ABCDMN 2 { 
                A_SpriteOffset(0, -10); 
                A_SetRoll(roll+15); 
            }
            loop;
        Pain:
            "####" A 1 { 
                A_Stop(); 
                frame = random[sfx](0,1);
            }
            "####" A 1 A_LookEx(LOF_NOSOUNDCHECK|LOF_DONTCHASEGOAL|LOF_NOSEESOUND|LOF_NOJUMP,0, 2048, 0, 360);
            "####" A 0 {
                A_FaceTarget(0,180, flags:FAF_MIDDLE);
                CheckForBarrels();
            }
            "####" A 0 {
                A_StartSound("revolver/fire", 1, pitch:1.5);
                A_SetRoll(roll+random[sfx](1,10)*15);
                int ShotDamage = GetMaxHealth() - health; //max health - health = damage taken
                let [bl,ColTrac] = self.A_SpawnItemEx("ParryTracer",0,0,0,0,0,0,0,SXF_TRANSFERPITCH);
                
                if(target && ColTrac)
                {
                    if(target.player) //uh oh! It has its sights on the player!!!
                    {
                        ColTrac.Scale.y = 256;
                        ColTrac.angle = random[sfx](0,360);
                        ColTrac.pitch = random[sfx](-90,90);
                    }
                    else
                    {
                        ColTrac.Scale.y = Distance2D(target)/5;
                        A_DamageTarget(ShotDamage*2, "HeadHitbox"); // Put it after the scale change because damaing a target can reset the target field
                    }
                }
                A_SetHealth(4000);
                vel = (frandom[sfx](1.0,-1.0), frandom[sfx](1.0,-1.0), 8);
            }
            Goto Spawn;

        Pain.melee:	
        Death:
            COIN O 175  {
                A_SpriteOffset(0, -1);
                roll = 0;
            }
            stop;
	}
}

Class ParryTracer : Actor
{
	Default 
	{
		Height 1;
		+NOINTERACTION //means it can clip through walls and floors and nothing can check for it
		+FLATSPRITE
		+NoGravity
		+WINDTHRUST
		RenderStyle "Add";
		alpha 0.8;
	}

	States
    {
		Spawn:
            LZBM D 5 BRIGHT NoDelay;
            LZBM DDDDDDDDDDDDDDDDDDDD 1 BRIGHT {
                Scale.x -= 0.05;
            }
            Stop;
	 }
}