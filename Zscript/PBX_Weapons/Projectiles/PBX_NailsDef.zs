//////////////////////////// CROSSBOW BALLISTA ////////////////////////////////////////////////////////////////////////////////////
class PBX_BallistaBolt : PB_NailgunGlue 
{
    Default
    {
        Radius 2;
        Height 2;
        Projectile;
        Speed 150;
        PB_Projectile.BaseDamage 60;
		PB_Projectile.RipperCount 5;
		PB_Projectile.PenetrationCount 3;
        Scale 1.0;
        Decal "Scorch";
        Damagetype "Nail";
        Projectile;
        +MISSILE;
        -NOGRAVITY;
        +BLOODSPLATTER;
        +THRUSPECIES;
        +MTHRUSPECIES;
        SeeSound "";
        Obituary "$OB_MPROCKET";
        Species "Marines";
    }

    States
	{
		Spawn:
			TNT1 A 0;
			CRBA A 1 A_StartSound("Weapons/NailFlight", CHAN_BODY, CHANF_LOOP, 1.0 );
			Goto Fly;
		Bounce:
			TNT1 A 0 A_SpawnItemEx("HitPuff");
		Fly:
			TNT1 A 0;
			CRBA A 1;
			Loop;
		Crash:
		Death:
			CRBA A 1 { 
				LIFETIME = CVar.GetCVar("pb_naillifetime").GetInt(); 
				A_StopSound(CHAN_BODY);
				A_SpawnItemEx("HitPuff");
				A_Stop();
                StickToWall();
			}
		DeathLoop:
			CRBA A 35 A_JumpIf(LIFETIME <= 0, "Fade");
			TNT1 A 0 {
				LIFETIME--;
				return A_CheckBlock("DeathLoop", 0, 0, (RADIUS / 2) + 1);
			}
		Drop:
			TNT1 A 0 {
				bNOINTERACTION = false;
				bNOGRAVITY = false;
				bTHRUACTORS = true;
			}
		Fade:
            CRBA A 1 A_SpawnItemEx("PBX_BallistaBoltPickup",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			stop;

		XDeath:
			CRBA A 1 { 
				LIFETIME = CVar.GetCVar("pb_naillifetime").GetInt(); 
				A_StopSound(CHAN_BODY);
				A_StartSound("Weapons/NailHitBleed");
                StickToWall();
			}
		XDeathloop:
			CRBA A 35 A_JumpIf(LIFETIME <= 0, "Fade");
			TNT1 A 0 { LIFETIME--; }
			Loop;
	}
}
				
class PBX_ExplosiveBolt : PBX_BallistaBolt
{
    int mStickyCounter;
    int mStuckEnemy;

    Default
    {
        PB_Projectile.BaseDamage 60;
		PB_Projectile.RipperCount 1;
        DamageType "Nail";
        +DONTBOUNCEONSHOOTABLES;
        +USEBOUNCESTATE;
        +HITTRACER;
    }

    States
    {
        Fly:
            CRBZ D 2 A_SpawnItemEx("BoltTrail", 0, 0, 0, 1, 0, 0, 180, 128);
            Loop;

        Death:
        Crash:
            CRBZ D 1 {
                mStickyCounter = 0;
                if(tracer && (tracer.bsolid || tracer.bshootable)) //&& tracer is "SwitchableDecoration")
					mStuckEnemy = true;
                A_NoGravity();
                A_ScaleVelocity(0);
                StickToWall();
            }
        Stuck:
            CRBZ DDDDDDD 1 {
                if(mStuckEnemy) 
				{
					if(AAPTR_TRACER) 
						A_Warp(AAPTR_TRACER,0,0,0,0,WARPF_NOCHECKPOSITION,null,0.5);
					else 
						A_Fall();
				}
                return ResolveState(null);
            }
            TNT1 A 0 {
                A_SpawnItem("GreenFlareSmall", 0, 0);
                A_PlaySound("BEP", CHAN_BODY);
                mStickyCounter++;
            }
            TNT1 A 0 A_JumpIf(mStickyCounter < 4, "Stuck");
            TNT1 A 0 A_PlaySoundEx("RA1IF1", "Auto");
            CRBZ DDDDD 1;
            TNT1 A 0 {
                A_SpawnItem("GreenFlareSmall", 0, 0);
                A_PlaySound("BEP", CHAN_BODY);
                A_Warp(AAPTR_TRACER, 0, 0, 20, 0, WARPF_NOCHECKPOSITION);
            }
            CRBZ DDDD 1;
            TNT1 A 0 {
                A_SpawnItem("GreenFlareSmall", 0, 0);
                A_PlaySound("BEP", CHAN_BODY);
                A_Warp(AAPTR_TRACER, 0, 0, 20, 0, WARPF_NOCHECKPOSITION);
            }
            CRBZ DD 1;
            TNT1 A 0 {
                A_SpawnItem("GreenFlareSmall", 0, 0);
                A_PlaySound("BEP", CHAN_BODY);
                A_Warp(AAPTR_TRACER, 0, 0, 20, 0, WARPF_NOCHECKPOSITION);
            }
            TNT1 A 0 A_JumpIf(mStickyCounter > 4, "Detonate");
            Loop;

        XDeath:
        Bounce.Creature:
            CRBZ D 1 {
                bTHRUACTORS = true;
                bSOLID = true;
                mStuckEnemy = true;
                A_Stop();
            }
            CRBZ D 1 {
                bTHRUACTORS = false;
                bSOLID = false;
            }
            Goto Stuck;

        Detonate:
            TNT1 A 0 A_StopSound();
            TNT1 A 0 A_PlaySound("Explosion", CHAN_BODY);
            TNT1 AAA 0 A_CustomMissile("ExplosionSmoke", 22, 0, random(0, 360), 2, random(0, 360));
            TNT1 A 0 A_SpawnItemEx("ExplosionFlareSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            TNT1 A 0 A_SpawnItemEx("DetectFloorCraterSmall", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            TNT1 A 0 A_SpawnItemEx("DetectCeilCraterSmall", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            // StickyExplosion is what deals damage, below are the definitions
            // TNT1 A 0 A_Explode(250, 10, 0, 0,10,0,0,"BulletPuff","Explosive")
            // TNT1 A 0 A_Explode(200,200)
            TNT1 A 0 A_SpawnItemEx("StickyExplosion", 0, 0, -2, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            TNT1 A 0 A_SpawnItemEx("NewRocketExploFX", 0, 0, 0);
            TNT1 AAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
            XXXX A 0 A_CustomMissile("ExplosionQuake", 1, 0, random(0, 360), 2, random(0, 160));
            TNT1 AAAAA 0 A_CustomMissile("MediumExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
            TNT1 A 0 A_PlaySound("FAREXPL", CHAN_BODY);
            EXPL AA 0 A_CustomMissile("ExplosionSmoke", 0, 0, random(0, 360), 2, random(0, 360));
            TNT1 A 0 {
				for(int i = 0; i < 20; i++)
				{
					A_SpawnProjectile("PB_Shrapnel", 0, 0, random (0, 360), 2, random (-90, 90));
				}
			}
            Stop;
    }
}

class PBX_DemonicBolt : PB_NailgunGlue
{
    Default
    {
        Radius 5;
        Height 3;
        Projectile;
        Speed 100;
        PB_Projectile.BaseDamage 100;
		PB_Projectile.RipperCount 5;
		PB_Projectile.PenetrationCount 3;
        DamageType "Nail";
        Scale 1.0;
        Decal "Scorch";
        +MISSILE;
        +RIPPER;
        +NOGRAVITY;
        +EXTREMEDEATH;
        +BLOODSPLATTER;
        +THRUSPECIES;
        +MTHRUSPECIES;
        SeeSound "";
        DeathSound "Weapons/NailHit";
        Obituary "$OB_MPROCKET";
        Species "Marines";
    }

    States
    {
        Spawn:
            CRBA B 1 Bright;
            TNT1 AAAAA 0 A_CustomMissile("ObeliskTrailSpark", 0, 0, random(0, 40), 2, random(0, 160));
            TNT1 A 0 A_SpawnItem("BallistaFlare", -10, 0);
            CRBA B 1 Bright;
            TNT1 A 0 A_SpawnItem("BallistaFlare", -10, 0);
            CRBA B 1 Bright;
            TNT1 A 0 A_SpawnItem("BallistaFlare", -10, 0);
            Loop;

        Crash:
        Death:
            TNT1 A 0 A_SpawnItemEx("RicoChet", 0, 0, -5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            CRBA B 45 Bright;
            CRBA A 1 StickToWall();
        XDeath:
            TNT1 A 0 A_PlaySoundEx("RAILIMP", "Auto");
            TNT1 A 0 A_SpawnItem("ExplosionParticleSpawner");
            //TNT1 A 0 A_SpawnItemEx("SmallUnderwaterExplosion", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            TNT1 A 0 A_SpawnItemEx("DetectFloorCraterSmall", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            TNT1 A 0 A_SpawnItemEx("DetectCeilCraterSmall", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            TNT1 A 0 A_CustomMissile("PBExplosionparticlesSmall", 8, 0, random(0, 180), 2, random(40, 90));
            Stop;

    }
}

class BoltTrail : RazorBladeTrail
{
    Default
    {
        radius 2;
        height 4;
        Scale 1.0;
    }

    States
    {
        Spawn:
			CRBA AAAAAAAAAAAAAAA 1 A_FadeOut(0.15);
			Stop;
    }
}

class BallistaFlare : actor
{
    Default
    {
        alpha 1.0;
        yscale 0.2;
        xscale 0.2;

        +NOINTERACTION;
        +NOGRAVITY;
        +FORCEXYBILLBOARD;
        +SQUAREPIXELS;

        renderstyle "Add";
        radius 1;
        height 1;
    }

    States
    {
        Spawn:
            FLAR A 2 BRIGHT;
            Stop;
    }
}

class PBX_ShockBolt : PBX_BallistaBolt
{
    Default
    {
        PB_Projectile.BaseDamage 60;
		PB_Projectile.RipperCount 1;
        DamageType "Nail";
        +DONTBOUNCEONSHOOTABLES;
        +USEBOUNCESTATE;
        +HITTRACER;
    }

    States
    {
        Fly:
            CRBS D 2 A_SpawnItemEx("BoltTrail", 0, 0, 0, 1, 0, 0, 180, 128);
            Loop;
        Crash:
		Stuck:
        Death:
		XDeath:
            TNT1 A 0 A_StopSound(6);
			TNT1 A 0 A_SpawnItemEx("PB_ShockBoltExplosion",0,0,1,0,0,0,0,SXF_NOCHECKPOSITION,0);
            Stop;
    }
}


// Unsure where this should actually go, but the same file worked just fine. Move it where it should be.
// The "A_SpawnItemEx("LightningGunPuff")" wasnt just a graphical thing. It carried a rather large stun area, making unusable for the intended bolt use.
// There are two A_Explode calls. The first one carries most of the damage: 250 electric in a small area.
// The other call carries the actual stun effect. 0 damage does not seem to have any effect, so it needs to be set to 1 damage.
class PB_ShockBoltExplosion : PB_StunGrenadeExplosion
{
	Default
	{
		PB_StunGrenadeExplosion.props 250, 24, "Electric"; //expDmg, expRad, expType;
	}
	States
	{
		Spawn:
			TNT1 A 0 NoDelay A_StartSound("LGBOMB");
			STFL ABCDEF 1 BRIGHT Light("LightningImpactLight") {
				A_SetScale(Scale.X+0.032,Scale.Y+0.032);
				A_SpawnProjectile("ElectroBlastTrail",6,0,random(0,359),CMF_AIMDIRECTION|CMF_TRACKOWNER,random(-180,180));
			}
		TNT1 A 0 {
			//A_SpawnItemEx("LightningGunPuff"); // Stun part
			A_SpawnItemEx("BlueFlare");
			A_Explode(expDmg,expRad,XF_THRUSTLESS,false,expRad,damagetype:expType);
			A_Explode(1,expRad,XF_THRUSTLESS,false,expRad,damagetype:"Stun");
			A_StartSound("STNBOEX");
			for(int i = 0; i < 10; i++)
			{
				A_SpawnProjectile("ElectroBlastTrail",6,0,random(0,359),CMF_AIMDIRECTION|CMF_TRACKOWNER,random(-180,180));
			}
		}
		XELC AABBCCDDEEFF 1 Bright Light("LightningImpactLight") A_SpawnProjectile("ElectroBlastTrail",6,0,random(0,359),CMF_AIMDIRECTION|CMF_TRACKOWNER,random(-180,180));
		Stop;
	}
}

//////////////////////////// SUPER NAILGUN ////////////////////////////////////////////////////////////////////////////////////
class SuperNail_Hot : PB_MGNailHot
{
    Default
    {
		PB_Projectile.BaseDamage 75;
    }
}

class SuperNail_Lightning : PB_MGNail
{
    mixin PBX_LightningProjectile;

	Default
	{
        PB_Projectile.BaseDamage 50;
        SuperNail_Lightning.DetectRange 256;
        SuperNail_Lightning.MaxVictims 5;
		SuperNail_Lightning.SplitRange 256;
		SuperNail_Lightning.Damage 1;
		SuperNail_Lightning.Duration 2;
		SuperNail_Lightning.Delay 2;
		SuperNail_Lightning.maxChains 1;
		SuperNail_Lightning.MaxLinks 2;
		SuperNail_Lightning.DamageType 'plasma';
        DamageType "Nails";
        Translation "112:127=192:207", "224:231=80:87";
		+PB_PROJECTILE.NOCRITICALS
	}

	override void Tick()
	{
		Super.Tick();
		if (isFrozen()) return;

		L_ProjTick();
	}
}

//////////////////////////// UPGRADED EXCAVATOR ////////////////////////////////////////////////////////////////////////////////////
class Razorblade : PB_ProjectileAlt
{
    Default
    {
        Radius 6;
        Height 8;
        Scale 0.75;
        Speed 60;
        PB_Projectile.BaseDamage 80;
		PB_Projectile.RipperCount 5;
		PB_Projectile.PenetrationCount 3;
		+PB_PROJECTILE.NOCRITICALS
        SeeSound "";
        DeathSound "";
        Obituary "$OB_PROJ_RAZORBLADE";
        DamageType "Cut";
		Gravity 0;
        +MISSILE;
        +RIPPER;
        -NOGRAVITY;
    }

    States
    {
        Spawn:
            CRBA A 0 NoDelay;
            CRBA CC 1 Bright {
                A_SpawnItemEx("RazorbladeTrail", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE);
                A_CustomMissile("ShotgunParticles", 0, 0, random(-160, -200), 2, random(0, 160));
                A_CustomMissile("SparkX", 0, 0, random(-160, -200), 2, random(30, 170));
                A_CustomMissile("SparkX", 0, 0, random(-160, -200), 2, random(30, 170));
                A_CustomMissile("SparkX", 0, 0, random(-160, -200), 2, random(30, 170));
            }
            CRBA LL 1 Bright
            {
                A_SpawnItemEx("RazorbladeTrail", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE);
                A_CustomMissile("ShotgunParticles", 0, 0, random(-160, -200), 2, random(0, 160));
                A_CustomMissile("SparkX", 0, 0, random(-160, -200), 2, random(30, 170));
                A_CustomMissile("SparkX", 0, 0, random(-160, -200), 2, random(30, 170));
                A_CustomMissile("SparkX", 0, 0, random(-160, -200), 2, random(30, 170));
            }
            // TNT1 A 0 { bHITOWNER = true; }
            Loop;

		Death:
		XDeath:
			TNT1 A 0 {
				A_Stop();
				A_PlaySoundEx("weapons/ballista/razor","Auto");
                A_SpawnItem("ExplosionParticleSpawner");
                A_CustomMissile("PBExplosionparticlesSmall", 8, 0, random(0, 180), 2, random(40, 90));
				A_SetGravity(1.0);
			}
			TNT1 A 0 A_SpawnItemEx ("RicoChet",0,0,-5,0,0,0,0,SXF_NOCHECKPOSITION,0);
			EX_V N 100 BRIGHT;
			EX_V NNNNNNNNNNNNNNN 1 A_FadeOut(0.15);
			Stop;

    }
}

class RazorBladeTrail : actor
{
    Default
    {
        radius 6;
        height 8;
        Scale 0.95;
        Alpha 0.95;
        +NOCLIP;
        +NOINTERACTION;
        Renderstyle "Translucent";
    }

    States
    {
        Spawn:
			CRBA CCCCCCCCCCCCCCC 1 A_FadeOut(0.15);
			Stop;
    }
}

class HeatedRazorblade : PB_ProjectileAlt 
{
	Default
	{
		radius 6;
		height 8;
		Scale 0.75;
		speed 60;
		PB_Projectile.BaseDamage 120;
		+PB_PROJECTILE.NOCRITICALS
		seesound "";
		deathsound "";
		DamageType "Cut";
		Gravity 0;
		WallBounceFactor 1;
		BounceFactor 1;
		Bouncecount 10;
        Obituary "$OB_PROJ_RAZORBLADE";
		Bouncesound "sawblade/ricochet";
		+BounceOnWalls;
		+BounceOnFloors;
		+BounceOnCeilings;
		+BounceOnActors;
		+CanBounceWater;
		+UseBounceState;
		PROJECTILE;
		+RIPPER;
		-NOGRAVITY
	}

	states 
	{
		Spawn:
			EX_V N 0 NoDelay;
			EX_V NN 1 BRIGHT {
				A_SpawnItemEx("HeatedRazorbladeTrail",0,0,0,0,0,0,0,SXF_CLIENTSIDE);
				A_CustomMissile("ShotgunParticles", 0, 0, random (-160, -200), 2, random (0, 160));
				A_CustomMissile ("SparkX", 0, 0, random (-160, -200), 2, random (30, 170));
				A_CustomMissile ("SparkX", 0, 0, random (-160, -200), 2, random (30, 170));
				A_CustomMissile ("SparkX", 0, 0, random (-160, -200), 2, random (30, 170));
			}
			EX_V OO 1 BRIGHT {
				A_SpawnItemEx("HeatedRazorbladeTrail",0,0,0,0,0,0,0,SXF_CLIENTSIDE);
				A_CustomMissile("ShotgunParticles", 0, 0, random (-160, -200), 2, random (0, 160));
				A_CustomMissile ("SparkX", 0, 0, random (-160, -200), 2, random (30, 170));
				A_CustomMissile ("SparkX", 0, 0, random (-160, -200), 2, random (30, 170));
				A_CustomMissile ("SparkX", 0, 0, random (-160, -200), 2, random (30, 170));
			}
			// TNT1 A 0 A_ChangeFlag("HitOwner",1);
			Loop;
		Bounce:
			TNT1 A 0 A_SpawnItemEx ("RicoChet",0,0,-5,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 AAAAAAAAAAAAAAAA 0 A_CustomMissile ("SparkX", 2, 0, random (0, 360), 2, random (30, 170));
			TNT1 AAAA 0 A_CustomMissile ("HitSpark", 2, 0, frandom(0,1)*frandom (0, 360), 2, frandom(0,1)*frandom (30, 360));
			TNT1 AAAA 0 A_CustomMissile ("HitSpark22", 2, 0, frandom(0,1)*frandom (0, 360), 2, frandom(0,1)*frandom (30, 360));
			TNT1 AAAA 0 A_CustomMissile ("HitSpark23", 2, 0, frandom(0,1)*frandom (0, 360), 2, frandom(0,1)*frandom (30, 360));
			EX_V PP 1 BRIGHT A_SpawnItemEx("RazorbladeTrail",0,0,0,0,0,0,0,SXF_CLIENTSIDE);
			Goto Spawn;
		Death:
		XDeath:
			TNT1 A 0 {
				A_Stop();
				A_PlaySoundEx("weapons/ballista/razor","Auto");
				A_SetGravity(1.0);
			}
			TNT1 A 0 A_SpawnItemEx ("RicoChet",0,0,-5,0,0,0,0,SXF_NOCHECKPOSITION,0);
			EX_V N 100 BRIGHT;
			EX_V NNNNNNNNNNNNNNN 1 A_FadeOut(0.15);
			Stop;	
	}
}

class HeatedRazorbladeTrail : actor 
{
	Default
	{
		radius 6;
		height 8;
		Scale 0.95;
		Alpha 0.95;
		+NOCLIP;
		+NOINTERACTION;
		Renderstyle "Translucent";
	}

	States 
	{
		Spawn:
		EX_V NNNNNNNNNNNNNNN 1 A_FadeOut(0.15);
		Stop;	
	}
}

//////////////////////////// PLATINUM RAILGUN ////////////////////////////////////////////////////////////////////////////////////
class RailgunProjectile : PB_MGNail
{
	int user_railangle;

	Default
	{
		Radius 2;
		Height 2;
		Speed 80;
		// DamageFactor 0;
		DamageType 'Railgun';
		Projectile;
		+RANDOMIZE
		+MISSILE
		+FORCERADIUSDMG
		+THRUACTORS
		PB_Projectile.BaseDamage 50;
		+PB_PROJECTILE.NOCRITICALS
		Species "Marines";
		Scale 1.0;
		renderstyle 'ADD';
		alpha 0.90;
		Scale 0.10;
		DeathSound "weapons/plasmax";
		SeeSound "None";
		Obituary "$OB_MPPLASMARIFLE";
		BounceCount 3;
	}
	States
	{
		DM:
			RAIL A 0;
			RAIL A 0 A_ChangeFLag("THRUSPECIES", 0);
			RAIL A 0 A_ChangeFLag("MTHRUSPECIES", 0);
			Goto Spawn1;
		Spawn:
			TNT1 A 0;
			RAIL A 0 A_FaceTarget;
			RAIL A 0 {user_railangle = angle;}
			RAIL A 0 A_SpawnItem("WhiteShockwave");
			// RAIL A 0 ACS_NamedExecuteAlways("CheckIfDM", 0, 0, 0, 0);//Check if Coop
			TNT1 C 1 BRIGHT A_SpawnItem("WhiteShockwave");
		Spawn1:
			TNT1 C 1 BRIGHT A_SpawnItem("WhiteShockwave");
			RAIL A 0 A_SpawnItem("WhiteShockwave");
			RAIL A 0 A_CheckFloor("Death");
			RAIL A 0 A_CustomMissile ("OldschoolRocketSmokeTrail2", 2, 0, random (160, 210), 2, random (-30, 30));
			Loop;
		Death:
		Melee:
		Xdeath:
			TNT1 AAAA 0 A_SpawnItemEx("BluePlasmaParticleSpawner", 0, 0, 0, 0, 0, 0, 0, 128);
			TNT1 AA 0 A_SpawnItem("WhiteShockwave");
			TNT1 AAAAAAAAA 0 A_CustomMissile ("ExplosionParticleHeavy", 0, 0, random (0, 360), 2, random (0, 180));
			TNT1 AAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("ExplosionParticleHeavy", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAAAAAAA 0 A_CustomMissile ("ExplosionParticleVeryFast", 0, 0, random (0, 360), 2, random (0, 360));
			EXPL AAAAA 0 A_CustomMissile ("ExplosionSmokeFast22", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAA 0 A_CustomMissile ("FireworkSFXType2", 2, 0, random (0, 360), 2, random (10, 80));
			RAIL A 0 A_SpawnItemEx ("DetectFloorCraterSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			RAIL A 0 A_SpawnItemEx ("DetectCeilCraterSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			RAIL A 0 A_CustomMissile ("BluePlasmaFire", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAAA 0 A_CustomMissile ("BluePlasmaParticle", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 ABE 0 BRIGHT A_SpawnItem("BlueFlare" ,0);
			Stop;
	}
}


class NailgunGib1 : Actor
{
	Default
	{
		Projectile;
		Gravity 1;
		damage 0;
		BounceType "Doom";
		BounceFactor 0.6;
		WallBounceFactor 0.6;
		Radius 4;
		Height 4;
		Speed 6;
		scale 0.6;
		SeeSound "NAILBOUN";
		BounceSound "NAILBOUN";
		+FORCEXYBILLBOARD
		-NOGRAVITY
		+BOUNCEONACTORS
		+ROLLSPRITE
		+ROLLCENTER
	}

	int lifetime;
	
	override void PostBeginPlay()
	{
		lifetime = 140;
		super.PostBeginPlay();
	}

	States
	{
		Spawn:
			NAIL B 1 {
				A_SetRoll(roll + 6, SPF_INTERPOLATE);
				lifetime--;
				if(lifetime <= 0) return resolvestate("Death");
				else return resolvestate(null);
			}
			Loop;
		Death:
			NAIL B 70;
			NAIL BBBBBBBBBBBBBBBBBBBB 1 A_FadeOut(0.05);
			stop;
		Bounce:
			TNT1 A 0;
			Goto Spawn;
	}
}

class NailgunGib2 : NailgunGib1
{
	Default
	{
		Speed 4;
	}

	States
	{
		Spawn:
			NAIL C 1 {
				A_SetRoll(roll + 6, SPF_INTERPOLATE);
				lifetime--;
				if(lifetime <= 0) return resolvestate("Death");
				else return resolvestate(null);
			}
		Death:
			NAIL C 70;
			NAIL CCCCCCCCCCCCCCCCCCCC 1 A_FadeOut(0.05);
			stop;
	}
}

class NailgunGib3: NailgunGib1
{
	Default
	{
		Speed 7;
	}

	States
	{
		Spawn:
			NAIL D 1 {
				A_SetRoll(roll + 6, SPF_INTERPOLATE);
				lifetime--;
				if(lifetime <= 0) return resolvestate("Death");
				else return resolvestate(null);
			}
		Death:
			NAIL D 70;
			NAIL DDDDDDDDDDDDDDDDDDDD 1 A_FadeOut(0.05);
			stop;
	}
}

class BDP_RailgunTrail : VisualThinker
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		texture = TexMan.CheckForTexture('SPKOB0');
		scale = (0.3,0.3);
		alpha = 1.0;
		flags = SPF_FULLBRIGHT;
		SetRenderStyle(STYLE_Add);
	}
	
	override void Tick()
	{
		scale -= (0.01,0.01);
		Super.Tick();
		if(scale.x <= 0)
		{
			Destroy();
		}
	}
}

CLASS PBX_RailgunRail : Actor
{
	Default
	{
		Radius 1; 
		Height 1;
		+nogravity;
		+noclip;
	}

	States
	{
		Spawn:
			TNT1 AAA 0 A_SpawnItemEX("WhiteShockwave");
			TNT1 AAAA 0 A_spawnprojectile ("FireworkSFXType2", 2, 0, random (0, 360), 2, random (-10, -80));
			RAIL A 0 A_SpawnItemEx ("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			RAIL A 0 A_SpawnItemEx ("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			//RAIL A 0 A_spawnprojectile ("BluePlasmaFire", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAAAAAAAA 0 A_spawnprojectile ("ExplosionParticleVeryFast", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAAAAAA 0 A_spawnprojectile ("ExplosionParticleHeavy", 5, 0, random (0, 360), 2, random (0, -180));
			TNT1 AAAAAAAAAA 0 A_spawnprojectile ("ExplosionParticleHeavy", 5, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAAAAAAA 0 A_spawnprojectile ("ExplosionParticleVeryFast", 5, 0, random (0, 360), 2, random (0, 360));
			MODL A 1 BRIGHT {
				Radius_Quake(3, 8, 0, 15, 0);
				A_startsound("BONECRACK",1);
				A_startsound("RICMET",2);
				A_spraydecal("RailLightning",36);
				Actor Core = spawn("PBX_RailgunRail2",pos);
				if(core)
				{
					core.angle = angle;
					core.pitch = pitch;
				}
			}
			MODL A 35 BRIGHT;
		TimeToFade:
			MODL A 1 BRIGHT {
				A_fadeout(0.01);
			}
			LOOP;
	}
}

CLASS PBX_RailgunRail2 : Actor
{
	Default
	{
		Radius 1; 
		Height 1;
		+nogravity;
		+noclip;
	}

	States
	{
		Spawn:
			MODL A 225 NODELAY;
		Death:
			TNT1 A 0 {
				A_startsound("BONECRACK",1);
				A_spawnitemex("Nailgungib1",frandom(-1,1),frandom(-3,-20),frandom(-1,1),frandom(-7,-3),frandom(-1,1),frandom(-10,10));
				// A_spawnitemex("Nailgungib2",frandom(-1,1),frandom(-3,-20),frandom(-1,1),frandom(-7,-3),frandom(-1,1),frandom(-10,10));
				// A_spawnitemex("Nailgungib3",frandom(-1,1),frandom(-3,-20),frandom(-1,1),frandom(-7,-3),frandom(-1,1),frandom(-10,10));
			}
			Stop;
			
	}
}