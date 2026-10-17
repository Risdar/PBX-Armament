////// Laser Charge /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Class LaserChargeShot : actor 
{
    Default
    {
        +NOBLOCKMAP;
        +MISSILE;
        +THRUACTORS;
        +NOGRAVITY;
        +MOVEWITHSECTOR;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        Scale 1;
        Damagetype "Saw";
    }

    States    
    {
        Spawn:
            TNT1 A 0 NoDelay A_ALertMonsters();
            TNT1 A 0 A_SpawnItemEx("ObeliskExplode",0,0,0,0,0,0,0,128,0);
            TNT1 A 0 A_StartSound ("charge/detonate/laser",6);
            TNT1 A 5;
            LSRB A 1 Bright {
                A_Setscale(0.25);
                A_Fadein(0.25);
            }
            LSRB B 1 Bright {
                A_Setscale(0.5);
                A_Fadein(0.25);
            }
            LSRB C 1 Bright {
                A_Setscale(0.75);
                A_Fadein(0.25);
            }
            LSRB D 1 Bright {
                A_Setscale(1.0);
                A_Fadein(0.25);
            }
            TNT1 A 0 A_PlaySound ("charge/loop/laser",6);
            LSRB EFGHIJKLMNOPQRSTUVWXYZ 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSR2 ABCD 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSRB ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSR2 ABCD 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSRB ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSR2 ABCD 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSRB ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSR2 ABCD 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSRB ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSR2 ABCD 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            LSRB ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 Bright {
                A_Explode(25,100);
                A_Explode(50,50);
                A_SpawnItemEx("ObeliskTrailSpark", random(35,-35), random(35,-35), random(10,0), 0, 0, 0, 0, 128, 0);
            }
            TNT1 A 0 A_StartSound ("charge/finish/laser",6);
            LSR2 A 1 Bright {
                A_Setscale(1.0);
                A_Fadeout(0.25);
            }
            LSR2 B 1 Bright {
                A_Setscale(0.75);
                A_Fadeout(0.25);
            }
            LSR2 C 1 Bright {
                A_Setscale(0.5);
                A_Fadeout(0.25);
            }
            LSR2 D 1 Bright {
                A_Setscale(0.25);
                A_Fadeout(0.25);
            }
            TNT1 A 20;
            Stop; 
    }
}

class ThrownLaserCharge : SwitchableDecoration
{
    Default
    {	
        Radius 5;
        Height 5;
        speed 24;
        Damage 0;
        Health 2;
        DamageType "Explosive";
        +MISSILE;
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

	int user_stickycounter;
	int user_stuckEnemy;

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
                A_SpawnItemEx ("RedFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            }
            LSRC S 1 Bright;
            Loop;

        Active:
            TNT1 A 0 A_PlaySound ("charge/beep/laser");
            TNT1 A 0 A_SpawnItemEx ("RedFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            LSRC S 6 Bright;
            TNT1 A 0 A_SpawnItemEx ("RedFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0 A_PlaySound ("charge/beep/laser");
            LSRC S 6 Bright;
            TNT1 A 0 A_PlaySound ("charge/beep/laser");
            TNT1 A 0 A_SpawnItemEx ("RedFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            LSRC S 6 Bright;
            LSRC S 4 ;
            TNT1 A 0 A_NoBlocking;
            TNT1 A 0 A_ChangeFLag ("SHOOTABLE", 0);
            TNT1 A 0 A_SpawnItemEx ("PBX_LaserCharge",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0;
            Stop;

        Bounce:
            TNT1 A 0 {
                user_stickycounter = 0;
                A_NoGravity();
                A_ScaleVelocity(0);
                A_ChangeFlag("NOBLOCKMAP",0);
                A_ChangeFlag("SHOOTABLE",1);
            }
        Stuck:
            LSRC S 41 BRIGHT {
                //A_Fire(22);
                if(user_stuckEnemy == 1) {
                    if(AAPTR_TRACER) 
                        A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
                    else 
                        A_Fall();
                }
            }
            TNT1 A 0 {
                A_SpawnItem("RedFlareSmall",0,0);
                A_PlaySound("charge/beep/laser", 4);
                user_stickycounter++;
            }
            TNT1 A 0 {
                if(user_stickycounter < 10)
                    return resolvestate("stuck");
                if(user_stickycounter > 10)
                    return resolvestate("death");
                return resolvestate(null);
            }
            Loop;

        XDeath:
        Bounce.Creature:
            LSRC S 1 {
                A_Changeflag("THRUACTORS", 1);
                A_Changeflag("Solid", 1);
                user_stuckEnemy = 1;
                A_Stop;
            }
            LSRC S 1 {
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
            TNT1 A 0 A_PlaySound("charge/activate/laser");
            LSRC S 10 BRIGHT;
            TNT1 A 0 A_SpawnItemEx("LaserChargeShot",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
            Stop;	
    }
}

////// Acid Charge /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class ThrownAcidCharge : SwitchableDecoration
{	
    Default
    {
        Radius 5;
        Height 5;
        speed 24;
        Damage 0;
        Health 2;
        DamageType "Explosive";
        +MISSILE;
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

	int user_stickycounter;
	int user_stuckEnemy;

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
                A_SpawnItemEx ("GreenFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            }
            REMT S 1 Bright;
            Loop;

        Active:
            TNT1 A 0 A_PlaySound ("charge/beep/remote");
            TNT1 A 0 A_SpawnItemEx ("GreenFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            REMT S 6 Bright;
            TNT1 A 0 A_SpawnItemEx ("GreenFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0 A_PlaySound ("charge/beep/remote");
            REMT S 6 Bright;
            TNT1 A 0 A_PlaySound ("charge/beep/remote");
            TNT1 A 0 A_SpawnItemEx ("GreenFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            REMT S 6 Bright;
            REMT S 4 ;
            TNT1 A 0 A_NoBlocking();
            TNT1 A 0 A_ChangeFLag ("SHOOTABLE", 0);
            TNT1 A 0 A_SpawnItemEx ("PBX_AcidCharge",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0;
            Stop;

        Bounce:
            TNT1 A 0 {
                user_stickycounter = 0;
                A_NoGravity();
                A_ScaleVelocity(0);
                A_ChangeFlag("NOBLOCKMAP",0);
                A_ChangeFlag("SHOOTABLE",1);
            }
        Stuck:
            REMT S 42 BRIGHT {
                if(user_stuckEnemy == 1) {
                    if(AAPTR_TRACER) 
                        A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
                    else 
                        A_Fall();
                }
            }
            TNT1 A 0 {
                A_SpawnItem("GreenFlareSmall",0,0);
                A_PlaySound("charge/beep/remote", 4);
                user_stickycounter++;
            }
            TNT1 A 0 {
                if(user_stickycounter < 10)
                    return resolvestate("stuck");
                if(user_stickycounter > 10)
                    return resolvestate("death");
                return resolvestate(null);
            }
            Loop;

        XDeath:
        Bounce.Creature:
            REMT S 1 {
                A_Changeflag("THRUACTORS", 1);
                A_Changeflag("Solid", 1);
                user_stuckEnemy = 1;
                A_Stop();
            }
            REMT S 1 {
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
            TNT1 A 0 A_PlaySound("charge/activate/remote", 6);
            REMT S 10 Bright;
            EXPL A 0 Radius_Quake (2, 54, 0, 15, 0);
            TNT1 A 0 A_ChangeFlag ("FLOORCLIP", 0);
            TNT1 A 0 A_AlertMonsters();
            TNT1 A 0 A_SpawnItemEx ("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0 A_SpawnItemEx ("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 AAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("ExplosionParticleHeavy", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 AAAAAAAAA 0 A_CustomMissile ("ExplosionParticleVeryFast", 0, 0, random (0, 360), 2, random (0, 360));
            EXPL AAAAAA 0 A_CustomMissile ("ExplosionSmokeFast22", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 A 0 A_Explode(210,310, XF_HURTSOURCE);
            TNT1 A 0 A_Explode(190,170, XF_HURTSOURCE);
            TNT1 A 0 A_SpawnItem("BFGAltShockWave",0,0);
            TNT1 A 0 A_SpawnItem("ACIDFOG", 0, 0);
            //BEXP B 0 BRIGHT A_Scream;
            TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("ShrapnelParticle2", 0, 0, random (0, 360), 2, random (5, 90));
            TNT1 A 0 A_PlaySound("FAREXPL", 3);
            TNT1 AAAAA 1 A_CustomMissile ("ExplosionSmoke", 1, 0, random (0, 360), 2, random (50, 130));
            TNT1 A 0;
            TNT1 A 1 A_Stop();
            Stop;
    }
}

////// Swarm Charge /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
	int user_stickycounter;
	int user_stuckEnemy;

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
			TNT1 A 0 A_SpawnItemEx ("PBX_SwarmCharge",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0;
			Stop;

		Bounce:
			TNT1 A 0 {
				user_stickycounter = 0;
				A_NoGravity();
				A_ScaleVelocity(0);
				A_ChangeFlag("NOBLOCKMAP",0);
				A_ChangeFlag("SHOOTABLE",1);
			}
		Stuck:
			SWRM S 40 BRIGHT {
				//A_Fire(22);
				if(user_stuckEnemy == 1) {
					if(AAPTR_TRACER) 
						A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
					else 
						A_Fall();
				}
			}
			TNT1 A 0 {
				A_SpawnItem("RedFlareSmall",0,0);
				A_PlaySound("charge/beep/swarm", 4);
				user_stickycounter++;
			}
			TNT1 A 0 {
                if(user_stickycounter < 10)
                    return resolvestate("stuck");
                if(user_stickycounter > 10)
                    return resolvestate("death");
                return resolvestate(null);
            }
			Loop;

		XDeath:
		Bounce.Creature:
			SWRM S 1 {
				A_Changeflag("THRUACTORS", 1);
				A_Changeflag("Solid", 1);
				user_stuckEnemy = 1;
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

////// Tripmine /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CLASS TripMine : SwitchableDecoration
{
	Default
	{
        +wallsprite;
		radius 10;
		Scale 0.08;
		Height 1;
		+nogravity;

        speed 24;
        Damage 0;
        Health 2;
        DamageType "Explosive";
        +MISSILE;
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

	actor beam;
	int laserangle;

    override void Tick()
    {
        Super.Tick();
        if(IsFrozen()) return;
        
        if(target.FindInventory("RemoteChargeDetonator"))
            SetStateLabel("Death");
    }

	States
	{

        Active:
            TNT1 A 0 A_PlaySound ("bep");
            TNT1 A 0 A_SpawnItemEx ("RedFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TRPM A 6 Bright;
            TNT1 A 0 A_SpawnItemEx ("RedFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0 A_PlaySound ("bep");
            TRPM A 6 Bright;
            TNT1 A 0 A_PlaySound ("bep");
            TNT1 A 0 A_SpawnItemEx ("RedFlareSmall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TRPM A 6 Bright;
            TRPM A 4 ;
            TNT1 A 0 A_NoBlocking;
            TNT1 A 0 A_ChangeFLag ("SHOOTABLE", 0);
            TNT1 A 0 A_SpawnItemEx ("PBX_Tripmine",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0;
            Stop;

        Spawn:
            TRPM A 1 NoDelay {		   
                FLineTraceData wallangle;
                LineTrace(angle, 1284, 0, TRF_THRUACTORS, offsetz: 3, data: wallangle);
                if (wallangle.HitType == TRACE_HitWall)
                    angle = atan2(wallangle.hitline.delta.y, wallangle.hitline.delta.x) - 90;
                
                If (wallangle.lineside == 1)
                    Angle = (angle - 180);

                A_startsound("bepbep",6);
                return resolvestate(null);
            }
        Spawn2:
            TRPM A 65;
            TRPM A 1 {
                FLineTraceData stillonwall;
                LineTrace((angle - 180), 12, 0, TRF_THRUACTORS, offsetz: 3, data: stillonwall);
                If(stillonwall.HitType != TRACE_HitWall)
                    return resolvestate("onfloornow");
                
                FLineTraceData peopleinmyway;
                LineTrace(angle, 5000, 0, 0, offsetz: 7, data: peopleinmyway);
                if (peopleinmyway.HitActor)
                    return ResolveState("Sight");
                
                beam = Spawn("TripMineparticle", (pos.x,pos.y,pos.z + 3));
                if (beam)
                {
                    beam.angle = angle;
                    beam.pitch = 0;
                    beam.scale.y = peopleinmyway.Distance;
                    beam.pitch = -90;
                }
                return ResolveState(null);
            }
            wait;	   
		
		Onfloornow:
            TRPM R 1 {
                bwallsprite = false;
                bflatsprite = true;
                bnogravity = false;

                FLineTraceData peopleinmyway;
                LineTrace(0, 5000, -90, 0, offsetz: 0, data: peopleinmyway);
                if (peopleinmyway.HitActor)
                    return ResolveState("Sightonfloor");
                
                beam = Spawn("TripMineparticle", (pos.x,pos.y,pos.z));
                if (beam)
                {
                    beam.angle = angle;
                    beam.pitch = 0;
                    beam.scale.y = peopleinmyway.Distance;
                    beam.pitch = 180;
                }
                return ResolveState(null);
            }
            wait;
		
        Sight:
            TNT1 A 0 A_startsound("BEEEP",8);
            TRPM AAAAAAAAAAA 1 {
                FLineTraceData peopleinmyway;
                LineTrace(angle, 5000, 0, 0, offsetz: 7, data: peopleinmyway);
                    
                beam = Spawn("TripMineparticle", (pos.x,pos.y,pos.z + 3));
                if (beam)
                {
                    beam.angle = angle;
                    beam.pitch = 0;
                    beam.scale.y = peopleinmyway.Distance;
                    beam.pitch = -90;
                }
            }
            Goto Death;

        Sightonfloor:
            TNT1 A 0 A_startsound("BEEEP",8);
            TRPM RRRRRRRRRRR 1 {
                FLineTraceData peopleinmyway;
                LineTrace(0, 5000, -90, 0, offsetz: 0, data: peopleinmyway);
                    
                beam = Spawn("TripMineparticle", (pos.x,pos.y,pos.z));            
                if (beam)
                {
                    beam.angle = angle;
                    beam.pitch = 0;
                    beam.scale.y = peopleinmyway.Distance;
                    beam.pitch = 180;
                }
            }
        Death:
            TNT1 A 0 A_spawnitemex("TripMineexplosion",60);
            TNT1 A 10;
            stop;	   
            
    }
}


CLASS Tripmineparticle : actor
{
    Default
    {
        +noblockmap;
        +forcexybillboard;
        scale 1.0;
        alpha 0.9;
        +nogravity;
        +thruactors;
        +NOTONAUTOMAP;
        Renderstyle "Add";
    }

    States
    {
        Spawn:
            TNT1 A 0;
            L2NR A 1 BRIGHT ;
            Stop;
    }
}


CLASS TripPuff : actor
{
	Default
	{
		height 1;
		Radius 1;
		//+puffonactors;
		+bloodlessimpact;
		+nointeraction;
	}
}

CLASS TripmineProjectile : actor
{
	Default
    {
        Height 2;
        Radius 2;
        Speed 20;
        Scale 0.08;
        Projectile;
    }
		
	States
    {
        Spawn:
            TRPM A 1;
            LOOP;
            
        Death:
        Xdeath:
            TNT1 A 1 A_spawnitemex("tripmine",1,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
            TNT1 A 1;
            STOP;
    }
}

class TripMineExplosion : actor
{
    Default
    {
        Radius 4;
        Height 2;
        Projectile;
        Speed 50;
        //Damage (random (200, 200));
        DamageType "Explosive";
        //MeleeDamage 0;
        Scale 0.6;
        Decal "Scorch";
        //Projectile;
        //+MISSILE;
        +NOGRAVITY;
        -EXTREMEDEATH;
        -BLOODSPLATTER ;
        +GHOST;
        +SPECTRAL;
        SeeSound "PIPEEXPLODE";
        DeathSound "PIPEEXPLODE";
        Obituary "$OB_MPROCKET";
        Species "Marines";
        +THRUSPECIES;
        +MTHRUSPECIES;
    }

	States
	{
        Spawn:
            TNT1 A 0;
            TNT1 A 0 A_AlertMonsters();
            TNT1 A 0 A_Explode(700,120,1,1,300);
            // TNT1 AAAA 0 A_SpawnItemEx ("PipebombPiece2",random(5,-5),random(6,1),random(5,2),random(14,3),random(15,6),random(3,20),random(360,1),SXF_NOCHECKPOSITION,0);
            // TNT1 AAA 0 A_SpawnItemEx ("PipebombPiece",random(5,-5),random(6,1),random(5,2),random(14,3),random(15,6),random(3,20),random(360,1),SXF_NOCHECKPOSITION,0);
            // TNT1 A 0 A_SpawnItemEx ("Footstep91",0,0, 40,0,0,0,0,SXF_NOCHECKPOSITION,0);
            //TNT1 A 1;
            TNT1 A 0 A_ChangeFlag("SHOOTABLE", 0);
            EXPL A 0 Radius_Quake (3, 8, 0, 15, 0);//(intensity, duration, damrad, tremrad, tid)
            // TNT1 A 0 A_SpawnItemEx ("UnderwaterExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0 A_SpawnItemEx ("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            // TNT1 AAAAAA 0 A_CustomMissile ("BDExplosionparticles", 0, 0, random (0, 360), 2, random (0, 360));
            // TNT1 AAAA 0 A_CustomMissile ("BDExplosionparticles2", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 AAAA 0 A_CustomMissile ("MediumExplosionFlames", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 AA 0 A_CustomMissile ("SpawnedExplosion", random(3,-3), random(6,-6), random (0, 360), 2, random (0, 360));
            // TNT1 AA 0 A_CustomMissile ("BDExplosionparticlesBig", random(-4, 4), random(-5,5), random (0, 360), 2, random (0, 360));
            // TNT1 AA 0 A_CustomMissile ("BDExplosionparticles2", random(-4, 4), random(-5,5), random (0, 360), 2, random (0, 90));
            TNT1 AAAA 0 A_CustomMissile ("MediumExplosionFlames", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 AA 0 A_AlertMonsters;
            TNT1 A 0 A_PlaySound("EXPLOSION", 1);
            TNT1 A 0;
            TNT1 A 0 A_PlaySound("FAREXPL", 3);
            //TNT1 AAAAAAAAAAAAA 3 A_CustomMissile ("HeavyExplosionSmoke", 2, 0, random (0, 360), 2, random (0, 360));
            Stop;
            	
        Death:
            TNT1 A 0;
            Stop;
	}
}