////// DATA /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class SwarmChargeCard : equipmentCard
{
	override void InfoFiller(out array<string> tags,out array<string> tokens,out array<string> ammotypes,out array<string>img,out array<double>sx,out array<double>sy)
	{
		tags.push("$PBX_SWARMCHR_TAG");
		tokens.push("PBX_SwarmChargeToken");
		ammotypes.push("PBX_SwarmChargeAmmo");
		img.push("graphics/Equipments/Charges/SwarmCharge/SwarmChargeIcon.png");
		sx.push(0.8);
		sy.push(0.8);
	}
}

class PBX_SwarmChargeToken : PBX_ChargesBase 
{
	Default 
    {
		Inventory.Icon "SWRMCHRC";
		PB_Equipment.AmmoType "PBX_SwarmChargeAmmo";
		PB_Equipment.SelectString "$PBX_SWARMCHR_WHEEL";
		PB_Equipment.FailString "$PBX_SWARMCHR_OUT";
		PB_Equipment.FontColor "Orange";
	}
	
	States 
    {
        UseEquipment:
            SWRM ABCD 1;
		    TNT1 A 0 A_DoubleTapFlag();
			SWRM EFG 1;
		    "####" A 0 checkDetonate();
			SWRM HIJKLMNOPQ 1;
			THRO ABCD 1;
			TNT1 A 0 {
                A_StartSound("charge/place/remote",CHAN_AUTO);
                EQ_TakeAmmo();
                A_FireCustomMissile("ThrownSwarmCharge",0,0,0,-1);
            }
			THRO EEEEFGHI 1;
            TNT1 A 0 PB_ReThrow();
            Stop;

	}
}

class PBX_SwarmChargeAmmo : PB_Ammo
{
	Default
	{
		Tag "$PBX_SWARMCHR_TAG";
		Inventory.Amount 1;
		Inventory.MaxAmount 3;
		Inventory.Icon "SWRMR0";
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 5;
		Inventory.PickupSound "Ammocase/Open";
		Scale 0.45;
	}
	
	override void PB_SetAmmoSprite()
	{
		sprite = GetSpriteIndex("SWRM");
        frame = 17;
	}
	
	override void AttachToOwner(actor other) //we have to do this here so that cheats will give the tokens
	{
		other.GiveInventory("PBX_SwarmChargeToken",1);
		Super.AttachToOwner(other);
	}
}

////// ACTORS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class ThrownSwarmCharge : SwitchableDecoration
{
    Default
    {	
        Radius 5;
        Height 5;
        speed 24;
        Damage 0;
        Health 2;
        +MISSILE;
        +LOOKALLAROUND;
        +QUICKTORETALIATE;
        +USESPECIAL;
        +NOBLOOD;
        -EXPLODEONWATER;
        -NOEXTREMEDEATH;
        +BLOODSPLATTER;
        +EXTREMEDEATH;
        +FORCEXYBILLBOARD;
        +CANBOUNCEWATER;
        +DONTBOUNCEONSHOOTABLES;
        +USEBOUNCESTATE;
        +BOUNCEONWALLS;
        +BOUNCEONFLOORS;
        +BOUNCEONCEILINGS;
        +MOVEWITHSECTOR;
        +DONTSPLASH;
        +HITTRACER;
        Bouncetype "Doom";
        BounceFactor 0.0;
        BounceCount 300;
        Scale .45;
        Gravity 0.7;
        Decal "Scorch";
        SeeSound "weapon/grenade";
        BounceSound "weapon/grenade";
        DeathSound "Explosion";
        Obituary "$OB_MPROCKET";
        Damagetype "ExplosiveImpact";
        DeathSound "";
        damagefactor "Kick", 0;
        damagefactor "ExtremePunches", 0;
        damagefactor "Melee", 0;
        damagefactor "Trample", 0;
        Activation THINGSPEC_Activate | THINGSPEC_ThingTargets | THINGSPEC_NoDeathSpecial;
    }

	int mStickyCounter;
	bool mStuckEnemy;

    override void Tick()
    {
        Super.Tick();
        if(IsFrozen()) return;
        
        if(target.FindInventory("RemoteChargeDetonator"))
            SetStateLabel("Death");
    }

	States
	{
		Spawn:
			TNT1 A 0 NoDelay {
				if(waterlevel > 1) {A_SpawnItem ("RocketSmokeTrail52"); }
				A_SpawnItemEx ("OrangeFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			}
			SWRM S 1 Bright;
			Loop;
			
		Active:
			TNT1 A 0 A_PlaySound ("charge/beep/swarm");
			TNT1 A 0 A_SpawnItemEx ("OrangeFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			SWRM S 6 Bright;
			TNT1 A 0 A_PlaySound ("charge/beep/swarm");
			TNT1 A 0 A_SpawnItemEx ("OrangeFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			SWRM S 6 Bright;
			TNT1 A 0 A_PlaySound ("charge/beep/swarm");
			TNT1 A 0 A_SpawnItemEx ("OrangeFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			SWRM S 6 Bright;
			SWRM S 4 ;
			TNT1 A 0 A_NoBlocking();
			TNT1 A 0 A_ChangeFLag ("SHOOTABLE", 0);
			TNT1 A 0 A_SpawnItemEx ("PBX_SwarmChargeAmmo",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0;
			Stop;

		Bounce:
			TNT1 A 0 {
				mStickyCounter = 0;
				A_NoGravity();
				A_ScaleVelocity(0);
				A_ChangeFlag("NOBLOCKMAP",0);
				A_ChangeFlag("SHOOTABLE",1);
			}
		Stuck:
			SWRM S 40 BRIGHT {
				//A_Fire(22);
				if(mStuckEnemy) {
					if(AAPTR_TRACER) 
						A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
					else 
						A_Fall();
				}
			}
			TNT1 A 0 {
				A_SpawnItem("RedFlareSmall",0,0);
				A_PlaySound("charge/beep/swarm", 4);
				mStickyCounter++;
			}
			TNT1 A 0 {
                if(mStickyCounter < 10)
                    return resolvestate("stuck");
                if(mStickyCounter > 10)
                    return resolvestate("death");
                return resolvestate(null);
            }
			Loop;

		XDeath:
		Bounce.Creature:
			SWRM S 1 {
				A_Changeflag("THRUACTORS", 1);
				A_Changeflag("Solid", 1);
				mStuckEnemy = true;
				A_Stop();
			}
			SWRM S 1 {
				A_Changeflag("THRUACTORS", 0);
				A_Changeflag("Solid", 0);
			}
			Goto Stuck;

		Death:
			TNT1 A 0 A_ChangeFlag ("NOCLIP", 1);
			TNT1 A 0 A_Changeflag("NOBLOCKMAP", 1);
			TNT1 A 0 A_Changeflag("SOLID", 0);
			TNT1 A 0 A_ChangeFlag ("FLOORCLIP", 0);
			TNT1 A 0 A_Changeflag("THRUACTORS", 1);
			TNT1 A 0 A_PlaySound("charge/activate/swarm");
			SWRM S 10 BRIGHT;
			TNT1 A 0 A_Stop();
			TNT1 A 0 A_StopSound(6);
			TNT1 A 0 A_PlaysoundEx("SwarmDrone/WindUp","Auto");
			TNT1 A 0 A_PlaysoundEx("Charge/Detonate/Swarm","Auto");
			TNT1 A 0 A_SpawnItem("WhiteShockwave");
			TNT1 A 0 A_SpawnItemEx ("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("NewGroundExplosionSmoke",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			EXPL A 0 Radius_Quake (2, 24, 0, 15, 0);
			BEXP B 0 BRIGHT A_Scream();
			TNT1 A 0 A_ALertMonsters();
			TNT1 A 0 A_SpawnItem("BarrelExplosionSmokeColumn");
			TNT1 AAAAA 1 {
                for(int i = 0; i < 10; i++)
                {
				    A_SpawnItemEx("SwarmDrone",0,0,3,random(-5,5),random(-5,5),random(1,5),0,SXF_NOCHECKPOSITION,0);
                }
			}
			TNT1 A 1 A_Stop();
			Stop;
    }
}

class SwarmDrone : actor 
{
    Default
    {
        Radius 3;
        Height 3;
        Speed 12;
        Mass 10;
        Scale 0.15;
        Gravity 0.1;
        ActiveSound "SwarmDrone/Idle";
        SeeSound "SwarmDrone/Idle";
        MeleeSound "Sawblade/Ricochet";
        DeathSound "SwarmDrone/BurnOut";
        Monster;
        Species "Marines";
        +Friendly;
        +BOUNCEONWALLS;
        +FLOAT;
        +FLOATBOB;
        +THRUACTORS;
        +NOTELEPORT;
        -COUNTKILL;
        -BLOODSPLATTER;
        +NOBLOOD;
        +NOGRAVITY;
        // +DONTHURTSPECIES;
        +DONTHARMSPECIES;
    }

    int droneLife;
    
    States 
    {
        Spawn:
            SPMT A 1 NoDelay {
                A_Look;
                A_FaceTarget;
                A_Playsound("SwarmDrone/Idle");
            }
        Idle:
            SPMT AAAAAAAAAAAAAAA 1 A_Wander();
            SPMT A 1 {
                A_Look();
                A_FaceTarget();
                A_Playsound("SwarmDrone/Idle");
                droneLife++;
            }
            TNT1 A 0 A_JumpIf(droneLife >= 30,"Idle2");
            Loop;

        Idle2:
            SPMT AAAAAAAAAAAAAAA 1 A_Wander();
            SPMT A 1 {
                A_Look();
                A_FaceTarget();
                A_Playsound("SwarmDrone/Idle");
            }
            TNT1 A 0 A_Jump(164,"Idle2");
            Goto Death;

        See:
            SPMT AAAAAAAAAAAAAAA 1 A_Chase();
            SPMT A 1 {
                A_Chase();
                A_FaceTarget();
                A_Playsound("SwarmDrone/Idle");
                droneLife++;
            }
            TNT1 A 0 A_JumpIf(droneLife >= 30,"Idle2");
            Loop;

        Melee:
            SPMT A 1 {
                A_CustomMissile("SwarmDroneAttack",0,0,0,0);
                A_Playsoundex("Sawblade/Ricochet","Auto");
            }
            Stop;

        Death:
            SPMT A 1 {
                A_Scream();
                A_Fall();
                A_Stop();
                A_Changeflag("NOGRAVITY", 0);
                A_Changeflag("FLOAT", 0);
                A_Changeflag("FLOATBOB", 0);
            }
            SPMT A 100;
            SPMT A 97 A_FadeOut(0.02);
            Stop;
    }
}		

class SwarmDroneAttack : PB_ProjectileAlt 
{
    Default
    {
        Radius 8;
        Height 8;
        DamageType "Cut";
        Projectile ;
        Speed 15;
        +RANDOMIZE;
        PB_Projectile.BaseDamage 50;
		+PB_PROJECTILE.NOCRITICALS
        // Damage 10;
        +RIPPER;
        +FORCEXYBILLBOARD;
        +THRUGHOST;
        RenderStyle "Add";
        Alpha 0.6;
        SeeSound "none";
        DeathSound "none";
        Decal "none";
    }

    States 
    {
        Spawn:
            TNT1 A 4 BRIGHT;
            Stop;	
    }
}