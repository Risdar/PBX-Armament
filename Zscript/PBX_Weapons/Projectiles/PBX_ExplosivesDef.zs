//////////////////////////// EXCAVATOR ////////////////////////////////////////////////////////////////////////////////////
class BolaStuckOnMonster : inventory{default{inventory.maxamount 1;}}
class ExcavatorBola : PB_ProjectileAlt
{
	Default
	{
		DamageType "Explosive";
		+MISSILE
		+BLOODSPLATTER
		+EXTREMEDEATH
		+FORCEXYBILLBOARD
		+DONTBOUNCEONSHOOTABLES
		-EXPLODEONWATER
		-NOEXTREMEDEATH
		+CANBOUNCEWATER
		+SOLID
		+BOUNCEONWALLS
		+BOUNCEONFLOORS
		+BOUNCEONCEILINGS
		+MOVEWITHSECTOR
		+USEBOUNCESTATE
		+DONTSPLASH
		+HITTRACER
		Gravity 0.5;
		Scale 0.35;
        PB_Projectile.BaseDamage 50;
		+PB_PROJECTILE.NOCRITICALS
		BounceFactor 0.1;
		Radius 5;
		Height 2;
		speed 35;
		Damagetype "ExplosiveImpact";
		DeathSound "";
	}
	int user_stickycounter;
	int user_stuckEnemy;

	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 A 0 A_Startsound("excavator_bolafly_loop",6,CHANF_LOOP);
		Fly:
			TNT1 A 0 {
				// if(waterlevel > 1) {A_SpawnItem ("RocketSmokeTrail52"); }
				// else {A_CustomMissile ("BUBULZ", 0, 0, random (0, 360), 2, random (0, 180));}
				A_SpawnItem("RedFlareSmall",0,0);
			}
			EX_V ABCDEFGHIJGFEDCBA 2 Bright Light("SGL_STICKY");
			Loop;
			
		Bounce:
		Death:
		Crash:
			TNT1 A 0 {
				A_NoGravity();
				A_ScaleVelocity(0);
				A_StopSound(6);
			}
			EX_V CCCCCCCCCC 1 BRIGHT;
			GoTo Detonate;
	
		XDeath:
		Bounce.Creature:
			EX_V D 1 {
				A_StopSound(6);
				A_Changeflag("THRUACTORS", 1);
				A_Changeflag("Solid", 1);
				A_Stop();
			}
			EX_V D 1 {
				A_Changeflag("THRUACTORS", 0);
				A_Changeflag("Solid", 0);
				A_GiveInventory("BolaStuckOnMonster",1);
			}
			EX_V KKKKKKKKKK 1 BRIGHT A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
			Goto DetonateMonster;
			
		Detonate:
			TNT1 A 0 A_JumpIfInventory("BolaStuckOnMonster",1,"DetonateMonster");
			TNT1 A 0 A_PlaySound("StunGrenadeDetonate", 6);
			EX_V CCCCC 1 BRIGHT ;
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,0);
			EX_V CCCC 1 BRIGHT ;
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,0);
			EX_V CCC 1 BRIGHT ;
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,0);
			EX_V CC 1 BRIGHT ;
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,0);
			EX_V C 1 BRIGHT ;
			Goto Explosion;
		DetonateMonster:
			TNT1 A 0 A_PlaySound("StunGrenadeDetonate", 6);
			EX_V KKKKKKKKKK 1 BRIGHT A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,32);
			EX_V KKKKK 1 BRIGHT A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,32);
			EX_V KKKK 1 BRIGHT A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,32);
			EX_V KKK 1 BRIGHT A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,32);
			EX_V KK 1 BRIGHT A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,32);
			EX_V K 1 BRIGHT A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
			Goto Explosion;
		Explosion:
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,0);
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,0);
			TNT1 A 0 A_SpawnItem("RedFlareSmall",0,0);
			EXPL A 0 Radius_Quake (3, 24, 0, 15, 0);//(intensity, duration, damrad, tremrad, tid)
			// TNT1 A 0 A_CustomMissile("BigRicoChet");
			// TNT1 A 0 A_SpawnItem ("BigRicoChet", 0, -30);
			TNT1 A 0 A_SpawnItemEx ("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			// TNT1 A 0 A_SpawnItemEx ("UnderwaterExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("NewGroundExplosionSmoke",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 AAAA 0 A_CustomMissile ("FireworkSFXType2", 0, 0, random (0, 360), 2, random (30, 60));
			TNT1 AAAAAAAAA 0 A_CustomMissile ("ExplosionParticleHeavy", 0, 0, random (0, 360), 2, random (0, 180));
			TNT1 AAAAAAAAA 0 A_CustomMissile ("ExplosionParticleVeryFast", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAAA 0 A_CustomMissile ("MediumExplosionFlames", 0, 0, random (0, 360), 2, random (0, 360));
			EXPL AAAAA 0 A_CustomMissile ("ExplosionSmokeFast22", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 A 0 A_SpawnItemEx ("LiquidExplosionEffectSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_CustomMissile ("ExcavatorExploFX", random(1,5), random(-10,10), random (0, 360), 2, random (0, 360));
			TNT1 A 0 A_SpawnItemEx ("ExcavatorExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_Playsound("excavator/explode", 1);
			TNT1 A 0 A_PlaySound("FAREXPL", 3);
			Stop;
	}
}

class ExcavatorGrenade  : PB_ProjectileAlt
{
	Default
	{
		DamageType "Explosive";
		+MISSILE;
		+BLOODSPLATTER;
		+EXTREMEDEATH;
		+FORCEXYBILLBOARD;
		+DONTBOUNCEONSHOOTABLES;
		-EXPLODEONWATER;
		-NOEXTREMEDEATH;
		+CANBOUNCEWATER;
		+SOLID;
		+BOUNCEONWALLS;
		+BOUNCEONFLOORS;
		+BOUNCEONCEILINGS;
		+MOVEWITHSECTOR;
		+USEBOUNCESTATE;
		+DONTSPLASH;
		+HITTRACER;
		Gravity 0.5;
		Scale 0.35;
        PB_Projectile.BaseDamage 15;
		+PB_PROJECTILE.NOCRITICALS
		BounceFactor 0.1;
		Radius 2;
		Height 2;
		speed 35;
		Damagetype "ExplosiveImpact";
		DeathSound "";
	}
	int user_stickycounter;
	int user_stuckEnemy;

	States
	{
		Spawn:
			TNT1 A 0 {
				// if(waterlevel > 1) {A_SpawnItem ("RocketSmokeTrail52"); }
				// else {A_CustomMissile ("BUBULZ", 0, 0, random (0, 360), 2, random (0, 180));}
				A_SpawnItem("RedFlareSmall",0,0);
			}
			GRNP A 1 Bright Light("SGL_STICKY");
			Loop;
			
		Bounce:
		Death:
		Crash:
			TNT1 A 0 {
				user_stickycounter = 0;
				A_NoGravity();
				A_ScaleVelocity(0);
			}
		Stuck:
			TNT1 A 0 A_Playsound ("RAILR1");
			GRNP AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 BRIGHT Light("SGL_STICKY") {
				if(user_stuckEnemy == 1) {

					if(AAPTR_TRACER) {
						A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
					}
					else {
						A_Fall();
					}
				return resolvestate(null);
			}
			return resolvestate(null);
		}
			TNT1 A 0 {
				A_SpawnItem("RedFlareSmall",0,0);
				user_stickycounter++;
			}
			TNT1 A 0 A_JumpIf(user_stickycounter < 1, "Stuck");
			TNT1 A 0 A_PlaySound("StunGrenadeDetonate", 6);
			TNT1 A 0 A_JumpIf(user_stickycounter > 1, "Detonate");
			GoTo Detonate;
	
		XDeath:
		Bounce.Creature:
			GRNP A 1 {
				A_Changeflag("THRUACTORS", 1);
				A_Changeflag("Solid", 1);
				user_stuckEnemy = 1;
				A_Stop();
			}
			GRNP A 1 {
				A_Changeflag("THRUACTORS", 0);
				A_Changeflag("Solid", 0);
			}
			Goto Stuck;
			
		Detonate:
			TNT1 A 0 A_StopSound(6);
			TNT1 A 0 A_PlaySound("Explosion",4);
			// TNT1 A 0 A_SpawnItem ("BigRicoChet", 0, -30);
			TNT1 AAA 0 A_CustomMissile ("ExplosionSmoke", 22, 0, random (0, 360), 2, random (0, 360));
			TNT1 A 0 A_SpawnItemEx ("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("StickyExplosion",0,0,-2,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("NewRocketExploFX", 0, 0, 0);
			TNT1 AAAAAAAAA 0 A_CustomMissile ("ExplosionParticleHeavy", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAAAAAAA 0 A_CustomMissile ("ExplosionParticleVeryFast", 0, 0, random (0, 360), 2, random (0, 360));
			XXXX A 0 A_CustomMissile ("ExplosionQuake", 1, 0, random (0, 360), 2, random (0, 160));
			TNT1 AAAAAAAAA 0 A_CustomMissile ("MediumExplosionFlames", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 A 0 A_Playsound("excavator/explode", 1);
			TNT1 A 0 A_PlaySound("FAREXPL",3);
			EXPL AAA 0 A_CustomMissile ("ExplosionSmoke", 0, 0, random (0, 360), 2, random (0, 360))  ;
			Stop;
	}
}

Class DiggerTrail : Actor
{
	Default
	{
		Scale 1.1;
		+noteleport
		+NOINTERACTION
		bouncetype "Doom";
		+RANDOMIZE
		height 1;
		radius 1;
	}
	
	States
	{
		Spawn:
			TNT1 A 0 A_SetScale(Scale.X*frandom(0.85,1.35), Scale.Y*frandom(0.9,1.25));
			SPIK ABBCCBBA 2;
			SPIK A 60;
			SPIK AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_FadeOut(0.02);
			Stop;
	}
}
Class ExcavatorExplode : Actor
{
	Default
	{
		Projectile;
		Scale 1.15;
		DamageType "ExplosiveImpact";
		+THRUSPECIES
		+MTHRUSPECIES
		Species "Marines";
	}

	States
	{
		Death:
			TNT1 A 0 A_SpawnItemEx("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			//TNT1 A 0 A_SpawnItemEx("UnderwaterExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx("NewGroundExplosionSmoke",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 AAAA 0 A_CustomMissile("FireworkSFXType2", 0, 0, random(0, 360), 2, random(30, 60));
			TNT1 A 0 A_CustomMissile("ExcavatorExploFX", random(1,5), random(-10,10), random(0, 360), 2, random(0, 360));
			TNT1 A 0 A_SpawnItemEx("LiquidExplosionEffectSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_Playsound("excavator/explode", 1);
			TNT1 A 0 A_PlaySound("FAREXPL", 3);
			Stop;
	}
}

// Seems like this class already exists in PB but I'll just leave this here
// Just in case it is removed in the future
// Class ExcavatorExplosion : Actor{
// 	Default{
// 		Radius 2;
// 		Height 2;
// 		Damagetype "ExplosiveImpact";
// 		+THRUSPECIES
// 		+MTHRUSPECIES
// 		Species "Marines";
// 		+FORCERADIUSDMG
// 		+NOBLOCKMAP
// 		+MISSILE
// 	}
// 	States{
// 	Spawn:
// 		Goto Death;
// 	Death:
// 		TNT1 A 2 NODELAY A_SpawnItem("WhiteShockwaveBig");
// 		TNT1 A 0 A_Explode(200, 100, xf_hurtsource, 0, 90,0,0,"None","Explosive");
// 		TNT1 A 0 A_Explode(125,140, xf_hurtsource, 0, 100);
// 		Stop;
// 	}
// }

Class DropShotExplode : ExcavatorExplode
{
	Default
	{
		Radius 20;
		Height 10;
		Speed 25;
		//SpawnID 208;
		Damagetype "ExplosiveImpact";
		+MISSILE
		+Ripper
		+NOBOSSRIP
		+SKYEXPLODE
		Damage 20;
	}

	States
	{
		Spawn:
			TNT1 A 0 NODELAY A_ChangeFlag("Thruactors", 1);
			5DKP A 2 A_SpawnItem("YellowFlareSmall",-2,0);
			5DKP B 4 A_Playsound("Weapons/StickyBombTick", 3);
			5DKP C 2 A_SpawnItem("YellowFlareSmall",-2,0);
			5DKP D 4;
			TNT1 A 0 A_ChangeFlag("Thruactors", 0);
			TNT1 A 0 A_SpawnItem("YellowFlareSmall",-2,0);
		Fall:
			5DKP D 1 A_CheckFloor("Boom");
			//TNT1 A 0 A_Explode(20, 30)
			TNT1 A 0 ThrustThingZ(0, 30, 1, 1);
			Loop;
		Boom:
		Death:
			TNT1 A 0 A_Playsound("superbaron/spike");
			TNT1 AAAAA 0 {A_CustomMissile("MudDust", 0, 0, random(0, 360), 2, random(30, 150));A_CustomMissile("DirtChunk1", 0, 0, random(0, 360), 2, random(30, 150));A_CustomMissile("DirtChunk2", 10, 0, random(0, 360), 2, random(30, 150));A_CustomMissile("BrownCloud", 0, 0, random(0, 90), 2, random(30, 150));}
			XXXX A 0 A_CustomMissile("ExplosionQuake", 1, 0, random(0, 360), 2, random(0, 160));
			TNT1 A 0 {
				A_SpawnItemEx("DiggerTrail",random(-3, 0),random(-3, -1),0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_SpawnItemEx("DiggerTrail",random(0, 3),random(1, 3),0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			}
			5DKP DDDDDDDDDDDDDD 1 A_CustomMissile("HeavyExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
			EXPL A 0 Radius_Quake(3, 24, 0, 15, 0);//(intensity, duration, damrad, tremrad, tid)
			//TNT1 A 0 A_CustomMissile("BigRicoChet");
			//TNT1 A 0 A_SpawnItem("BigRicoChet", 0, -30);
			
			TNT1 AAAAAAAAA 0 {
				A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
				A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
			}
			TNT1 AAAAA 0 {
				A_CustomMissile("MediumExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
				A_CustomMissile("ExplosionSmokeFast22", 0, 0, random(0, 360), 2, random(0, 360));
			}
			TNT1 A 0 A_SpawnItemEx("ExcavatorExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			goto Super::Death;
	}
}
Class DrillBombExplode : ExcavatorExplode
{
	Default
	{
		SeeSound "superbaron/spike";
		Radius 2;
		Height 1;
		Speed 0;
		//SpawnID 205;
		+NOCLIP
		+Thruactors
	}

	States
	{
		Spawn:
		Death:
			TNT1 AAAAA 0 NODELAY {
				A_CustomMissile("MudDust", 0, 0, random(0, 360), 2, random(30, 150));
				A_CustomMissile("DirtChunk1", 0, 0, random(0, 360), 2, random(30, 150));
				A_CustomMissile("DirtChunk2", 10, 0, random(0, 360), 2, random(30, 150));
				A_CustomMissile("BrownCloud", 0, 0, random(0, 90), 2, random(30, 150));
			}
			XXXX A 0 A_CustomMissile("ExplosionQuake", 1, 0, random(0, 360), 2, random(0, 160));
			TNT1 A 0 A_Explode(15, 32, 0, 12);
			5DKP EFGHIJIKLMNOONNML 1 BRIGHT ;
			EXPL A 0 Radius_Quake(3, 8, 0, 15, 0);//(intensity, duration, damrad, tremrad, tid)
			//TNT1 A 0 A_CustomMissile("BigRicoChet");
			//TNT1 A 0 A_SpawnItem("BigRicoChet", 0, -30);
			
			
			TNT1 AAAAAAAAA 0 {
				A_CustomMissile("ExplosionParticleHeavy", 12, 0, random(0, 360), 2, random(0, 180));
				A_CustomMissile("ExplosionParticleVeryFast", 12, 0, random(0, 360), 2, random(0, 360));
			}
			TNT1 AAAAA 0 {
				A_CustomMissile("MediumExplosionFlames", 12, 0, random(0, 360), 2, random(0, 360));
				A_CustomMissile("ExplosionSmokeFast22", 12, 0, random(0, 360), 2, random(0, 360));
			}
			TNT1 A 0 A_SpawnItemEx("ExcavatorExplosion",0,0,12,0,0,0,0,SXF_NOCHECKPOSITION,0);
			goto Super::Death;
	}
}
Class ExcavatorDrillBomb : Actor
{
	Default
	{
		Radius 8;
		Height 4;
		Speed 12;
		Damage 1;
		DamageType "ExplosiveImpact";
		+Ripper
		+FloorHugger
		+BloodlessImpact
		+THRUSPECIES
		+MTHRUSPECIES
		Species "Marines";
		Projectile;
		Missileheight 0;
	}
	
	Override Void Tick()
	{
		if(target.CountInv("GrenadeDetonator"))
		{
			A_StopSound(5);
			A_SpawnItemEx("DrillBombExplode",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			Destroy();
		}
		Super.Tick();
	}
	override int SpecialMissileHit(Actor victim)
	{
		if(victim && victim is "PB_Monster")
		{
			self.SetStateLabel("Death");
		}
		return super.SpecialMissileHit(victim);
	}

	States
	{
		Spawn:
			TNT1 A 1 NODELAY A_StartSound("excavator/digloop", 5, CHANF_LOOPING,1.0,0.5);
		Travel:
			TNT1 A 3 ;
			TNT1 A 0 {
				A_SpawnItemEx("DiggerTrail",random(-2, 2),random(-1, 1),0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_CustomMissile("MudDust", 0, 0, random(0, 360), 2, random(30, 150));
				Radius_Quake(2, 8, 0, 8, 0);
			}
			TNT1 AA 0 {
				A_CustomMissile("DirtChunk1", 0, 0, random(0, 360), 2, random(30, 150));
				A_CustomMissile("DirtChunk2", 0, 0, random(0, 360), 2, random(30, 150));
			}
			Loop;
		Death:
			TNT1 A 0 {
				A_StopSound(5);
				A_SpawnItemEx("DrillBombExplode",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			}
			Stop;
	}
}
Class ExcavatorDrill : PB_ProjectileAlt
{
	Default
	{
		+MISSILE
		//+Ripper
		+SOLID
		+BOUNCEONWALLS
		+BOUNCEONFLOORS
		+BOUNCEONCEILINGS
		+CANBOUNCEWATER
		+MOVEWITHSECTOR
		+USEBOUNCESTATE
		+DONTSPLASH
		+SKYEXPLODE
		+THRUSPECIES
		+MTHRUSPECIES
		Species "Marines";
		Scale 1.15;
		Speed 25;
		Radius 6;
		Height 6;
		Gravity 1.25;
		PB_Projectile.BaseDamage 15;
		+PB_PROJECTILE.NOCRITICALS
		DamageType "ExplosiveImpact";
		Decal "Scorch";
	}

	States
	{
		Spawn:
			TNT1 A 0 NODELAY A_CheckFloor("Dig");
			5DKP A 2 BRIGHT A_SpawnItem("RocketSmokeTrail52");
			TNT1 A 0 A_SpawnItem("RocketFlare",-2,0);
			TNT1 A 0 ThrustThingZ(0, 20, 1, 1);
			// TNT1 A 0 A_CheckFloor("Dig");
			// 5DKP A 2 BRIGHT A_SpawnItem("RocketSmokeTrail52");
			// TNT1 A 0 A_CheckFloor("Dig");
			Loop;
		Dig:
		Bounce.Floor:
		XDeath:
		Death:
			TNT1 A 0 ;
			TNT1 A 0 A_Playsound("excavator/digging");
			TNT1 A 0 A_CustomMissile("ExcavatorDrillBomb", 1, 0, 180);
			Stop;
		Crash:
		Bounce.Ceiling:
		Bounce.Walls:
			TNT1 A 0 A_StopSound(6);
			EXPL A 0 Radius_Quake(3, 24, 0, 15, 0);//(intensity, duration, damrad, tremrad, tid)
			//TNT1 A 0 A_CustomMissile("BigRicoChet");
			//TNT1 A 0 A_SpawnItem("BigRicoChet", 0, -30);
			TNT1 A 0 A_SpawnItemEx("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			//TNT1 A 0 A_SpawnItemEx("UnderwaterExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx("NewGroundExplosionSmoke",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 AAAAAAAAA 0 {
				A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
				A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
			}
			TNT1 AAAAA 0 {
				A_CustomMissile("MediumExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
				A_CustomMissile("ExplosionSmokeFast22", 0, 0, random(0, 360), 2, random(0, 360));
			}
			TNT1 A 0 A_CustomMissile("ExcavatorExploFX", random(1,5), random(-10,10), random(0, 360), 2, random(0, 360));
			TNT1 A 0 A_SpawnItemEx("ExcavatorExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx("LiquidExplosionEffectSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_Playsound("excavator/explode", 1);
			TNT1 A 0 A_PlaySound("FAREXPL", 3);
			Stop;
	}
}
Class ExcavatorDropShot : PB_ProjectileAlt
{
	Default
	{
		Projectile;
		+MISSILE
		//+Ripper
		+NOGRAVITY
		+MOVEWITHSECTOR
		+EXPLODEONWATER
		+USEBOUNCESTATE
		+DONTSPLASH
		+SKYEXPLODE
		+THRUSPECIES
		+MTHRUSPECIES
		Species "Marines";
		Speed 35;
		Radius 6;
		Height 6;
		PB_Projectile.BaseDamage 15;
		+PB_PROJECTILE.NOCRITICALS
		Scale 1.15;
		DamageType "ExplosiveImpact";
		Decal "Scorch";
	}

	Override Void Tick()
	{
		if(target.CountInv("GrenadeDetonator"))
		{
			A_StopSound(5);
			A_SpawnItemEx("DropShotExplode",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0)
			;Destroy();
		}
		Super.Tick();
	}

	States
	{
		Spawn:
			TNT1 A 1 NODELAY A_StartSound("excavator/digloop", 5, CHANF_LOOPING,1.0,0.5);
			//TNT1 A 0 Thing_ChangeTid(0,1744);
		Travel:
			5DKP A 2 BRIGHT A_SpawnItem("RocketSmokeTrail52");
			TNT1 A 0 A_SpawnItem("GreenFlareSmall",-2,0);
			TNT1 A 0 A_CustomMissile("ShotgunParticles", 0, 0, random(0, 360), 2, random(30, 150));
			5DKP A 2 BRIGHT A_SpawnItem("RocketSmokeTrail52");
			Loop;
		XDeath:
		Death:
		Crash:
		Bounce.Ceiling:
		Bounce.Walls:
		Bounce.Floor:
			TNT1 A 0 A_SpawnItemEx("DropShotExplode",0,0,-5,0,0,0,0,SXF_NOCHECKPOSITION,0);
			Stop;
	}
}

//////////////////////////// CYBERDEMON ROCKET LAUNCHER ////////////////////////////////////////////////////////////////////////////////////
class CRL_Rocket : PB_ProjectileAlt
{
    Default
    {
		+RIPPER
		PB_Projectile.BaseDamage 250;
		PB_Projectile.RipperCount 12;
        PB_Projectile.PenetrationCount 5;
		+PB_PROJECTILE.NOCRITICALS
        Scale 1.0;
        DamageType "Explosive";
        Decal "Scorch";
        Radius 10;
        Height 8;
        Speed 90;
        gravity 0;
        // +MISSILE;
        Projectile;
        +EXTREMEDEATH
        +BLOODSPLATTER 
        +THRUSPECIES
        +MTHRUSPECIES
        +RANDOMIZE
        Species "Marines";
        Scale 2.0;
        SeeSound "DSCANFIR";
        DeathSound "Explosion";
        Obituary "$OB_PROJ_CYBERRL";
    }

    States
	{
        Spawn:
            TNT1 A 0 A_JumpIf(waterlevel > 1, "SpawnUnderwater");
            WYVB A 1 Bright A_SpawnItem("RedFlareSmall22",0,0);
            TNT1 A 0 A_CustomMissile ("OldschoolRocketSmokeTrail2", 2, 0, random (160, 210), 2, random (-30, 30));
            TNT1 A 0 A_JumpIfInventory("lowgraphicsmode", 1, "SpawnCheap");
            Loop;
            
        SpawnCheap:
            TNT1 A 0;
            WYVB A 1 Bright A_SpawnItem("RedFlareSmall22",0,0);
            Loop;
        
        SpawnUnderwater:
            WYVB A 1 Bright A_SpawnItem("YellowFlareSmall",0,0);
            Goto Spawn1;
           
        Crash:
		XDeath:
		Death:
			TNT1 A 0 {
				A_Stop();
				bNOINTERACTION = true;
				bNOGRAVITY = true;
			}
			TNT1 A 0;
			TNT1 A 0
			{
				A_Explode((80), 200);
				A_StopSound(105);
				A_StartSound("FAREXPL", CHAN_AUTO,CHANF_OVERLAP,0.5,0,1.1);
				Radius_Quake (2, 4, 0, 7, 0);
				A_SpawnItemEx ("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_SpawnItemEx ("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_SpawnItemEx ("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_SpawnItemEx ("LiquidExplosionEffectSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_SpawnProjectile ("ExplosionSmokeFast22", 0, 0, random (0, 360), 2, random (0, 360));
				A_SpawnProjectile ("MediumExplosionFlames", 0, 0, random (0, 360), 2, random (0, 360));
				A_SpawnProjectile ("PBExplosionparticles", 0, 0, random (0, 360), 2, random (40, 90));
				A_SpawnProjectile ("PBExplosionparticles2", 0, 0, random (0, 360), 2, random (40, 90));
				A_SpawnProjectile ("PBExplosionparticles3", 10, 0, random (0, 360), 2, random (40, 90));
			}
			TNT1 A 0 A_Jump(256, "Spawn1", "Spawn2", "Spawn3");
		Spawn1:
			X004 ABCDE 1 bright Light("EXPLOSIONFLASH");
			X004 FGHIJKLMNOPQ 1 bright;
			stop;
		Spawn2:
			X003 ABCDE 1 bright Light("EXPLOSIONFLASH");
			X003 FGHIJKLMNOPQRSTUVWXYZ 1 bright;
			stop;
		Spawn3:
			X125 ABCDE 1 bright Light("EXPLOSIONFLASH");
			X125 FGHIJKLMNOPQR 1 bright;
			Stop;
	}
}

//////////////////////////// SPIDER MASTERMIND CHAINGUN ////////////////////////////////////////////////////////////////////////////////////
class MastermindCGProjectile : PB_MasterMindTracer
{
	Default
	{
		+RIPPER;
		PB_Projectile.BaseDamage 200;
		PB_Projectile.RipperCount 1;
        PB_Projectile.PenetrationCount 3;
		+PB_PROJECTILE.NOCRITICALS
		Species "Marines";
	}
}

// The code homing code is from Gun Bonsai
class MastermindCG_SoulSeeker : MastermindCGProjectile
{
	Default
	{
		+RIPPER;
		PB_Projectile.BaseDamage 150;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		let aux = HomingShots_Aux(GiveInventoryType("HomingShots_Aux"));
		if (aux)
		{
			aux.level = 50; // adjusts how strong is the homing
			aux.SetStateLabel("Homing");
		}
	}

	override void OnDestroy()
	{
		Super.OnDestroy();

		// Remove the homing aux if we die
		Inventory aux = FindInventory("HomingShots_Aux");
		if (aux) aux.Destroy();
	}
}

//////////////////////////// PAINGIVER ////////////////////////////////////////////////////////////////////////////////////
class SeekerRocket : PB_ProjectileAlt
{
    Default
    {
        PB_Projectile.BaseDamage 300;
		+PB_PROJECTILE.NOCRITICALS
        Radius 11;
        Height 8;
        Speed 30;
        Projectile;
        +FRIENDLY
        +FORCEPAIN
        +RANDOMIZE
        +DEHEXPLOSION
        +EXTREMEDEATH
        +ROCKETTRAIL
        +BOSS
        DamageType "Nodrop";
        SeeSound "weapons/rocklf";
        DeathSound "rlboom";
        Decal "Scorch";
    }

    override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		let aux = HomingShots_Aux(GiveInventoryType("HomingShots_Aux"));
		if (aux)
		{
			aux.level = 50; // adjusts how strong is the homing
			aux.SetStateLabel("Homing");
		}
	}

    override void OnDestroy()
	{
		Super.OnDestroy();

		// Remove the homing aux if we die
		Inventory aux = FindInventory("HomingShots_Aux");
		if (aux) aux.Destroy();
	}

	States
	{
        Spawn:
            MISL A 0;
        MissileFlying:
            TNT1 A 0 {
                If(WaterLevel < 1)
                A_SpawnItemEx("RocketTrailSparks",-10,0,0,-5,0,0);
            }
            MISL A 0;
            M1SL ABCD 1 Bright {
                A_SpawnItemEx("SeekerFlare");
                A_SpawnItemEx("SeekerRocketSmokeTrail",-14,0,0,0,FRandom(-0.5,0.5),FRandom(-0.5,0.5),0,0,64);
            }
            Loop;

        Death:
            MISL A 0;
            TNT1 A 0 A_StopSound(6);
            EXPL A 0 {
                Radius_Quake (3, 16, 0, 15, 0);
                A_SpawnItem ("RicoChet", 0, -30);
                A_SpawnItemEx ("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
                A_SpawnItemEx ("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            }
            TNT1 A 0 Bright {
                A_SpawnItemEx ("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
                A_SpawnItemEx ("RocketExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
                A_SpawnItemEx ("NewRocketExploFX", 0, 0, 0);
                A_CustomMissile ("ExplosionParticleHeavy", 0, 0, random (0, 360), 2, random (0, 180));
            }
            TNT1 A 0 Bright {
                A_CustomMissile ("ExplosionParticleHeavy", 0, 0, random (0, 360), 2, random (0, 360));
                A_CustomMissile ("ExplosionParticleVeryFast", 0, 0, random (0, 360), 2, random (0, 360));
                A_CustomMissile ("MediumExplosionFlames", 0, 0, random (0, 360), 2, random (0, 360));
                A_CustomMissile ("ExplosionSmokeFast22", 0, 0, random (0, 360), 2, random (0, 360));
            }
            TNT1 A 0 A_PlaySound("FAREXPL", 3);
            TNT1 A 20;
            Stop;
    }
}

class SeekerFlare : actor
{
    Default
    {
		Radius 6;
		Height 8;
		Scale 0.4;
        +NOGRAVITY
        -SOLID
        +RANDOMIZE
		RenderStyle "Add";
    }

    States
    {
		Spawn:
            W17M A 2 Bright;
            Stop;
    }
}

class SeekerRocketSmokeTrail : actor
{
    Default
    {
        Scale 0.50;
        Speed 0;
        Alpha 0.11;
        -NOGRAVITY
        -NOINTERACTION
        Gravity 0.005;
    }

    States
    {
        Spawn:
            TNT1 A 0;
            PUF2 EEFGHIJK 4 A_FadeOut(0.005);
            PUF2 LMNOPQRSTUVWXYZ 4 A_FadeOut(0.005);
            PUF3 ABC 2 A_FadeOut(0.005);
            Goto Death;
        Death:
            TNT1 A 0;
            Stop;
  }
}

//////////////////////////// NUCLEAR WARHEAD ////////////////////////////////////////////////////////////////////////////////////
class NuclearRocket : PB_ProjectileAlt
{
    Default
    {
        Gravity 0.2;
		PB_Projectile.BaseDamage 20000;
		PB_Projectile.RipperCount 0;
		PB_Projectile.PenetrationCount 0;
		+PB_PROJECTILE.NOCRITICALS
        Speed 100;
        Scale 1.0;
        Radius 6;
        Height 6;
        Damagetype "Nuke";
        Species "None";
        Obituary "$OB_PROJ_NUKE";
        Projectile;
        MeleeDamage 0;
        Decal "Scorch";
        +FORCERADIUSDMG
        -NOGRAVITY
        +SKYEXPLODE
        +DOHARMSPECIES
        +NODAMAGETHRUST
        +EXTREMEDEATH
        +BLOODSPLATTER 
        +THRUSPECIES
        +MTHRUSPECIES
        +RANDOMIZE
    }

	States
	{
        Spawn:
			M1SL A 0 NoDelay A_StartSound("weapons/rocketloop",CHAN_BODY,CHANF_LOOP);
		Fly:
			M1SL ABCD 1 Bright Light("PB_ROCKET") {
				if(waterlevel < 1) {
					A_SpawnItemEx("OldschoolRocketSmokeTrail2",-3,0,0,-1,0,0);
					A_SpawnItemEx("RocketTrailSparks",-10,0,0,-5,0,0);
				}
			}
			Loop;

		Death:
            TNT1 A 0 A_SPawnItemEx("NuclearExplosion",0,0,0,0,0,0,0,SXF_TRANSFERPOINTERS | SXF_NOCHECKPOSITION,0);
			Stop;
	}
}



class NuclearExplosion : actor
{
    Default
    {
        Damagetype "Nuke";
        RenderStyle "None";
        Radius 1;
        Height 1;
    }

	States
	{
        Spawn:
            TNT1 A 0;
            TNT1 A 0 A_Explode(300, 1200, 1, 1, 1200);
            TNT1 A 1 ;
            TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("NuclearFlamesImpact", 5, 0, random (0, 360), 2, random (0, 10));
            TNT1 A 0 A_CustomMissile ("SpawnedExplosionNuke2", 10, 0, random (0, 360), 2, random(80, 90));
            //TNT1 AAA 0 A_CustomMissile ("lONGExplosionSpawner", 30, 0, random (0, 360), 2, 90);
            TNT1 AAA 0  A_SpawnItemEx("SpawnedExplosionNuke", random (-400, 400), random (-400, 400), random (0, 100));
            TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0  A_SpawnItemEx("SpawnedExplosionNuke", random (-600, 600), random (-600, 600), random (0, 50));
            EXPL A 0 Radius_Quake (9, 200, 0, 300, 0);
            TNT1 AAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("NukeFlare", random (-800, 800), random (-800, 800), random (0, 100));
            // TNT1 A 0 A_SpawnItemEX("HorizontalShockwave4",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0 A_Explode(300, 2000, 1, 1, 4000);
            TNT1 A 0 A_PlaySound("Nuke/Explosion", 1);
            TNT1 A 0 A_Explode(400,3000, 1, 1, 1);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 300, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 450, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 600, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 750, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 900, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 1100, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 1200, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 1300, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 1400, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 A 6 A_SpawnItemEx("NukeFlare", 0, 0, 1500, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 AAAAA 0 A_SpawnItemEx("NukeFlare", random(-300, 300), random(-300, 300), 1600, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 AAAAA 6 A_SpawnItemEx("NukeFlare", random(-600, 600), random(-600, 600), 1600, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            EXPL A 0 Radius_Quake (6, 200, 0, 300, 0);
            TNT1 AAAaaaaaaAA 12 A_SpawnItemEx("NuclearFlamesRepeat2", random(-600, 600), random(-600, 600), 1600, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            TNT1 Aaaaaa 0 A_SpawnItemEx("NukeSmokebIG", random(-600, 600), random(-600, 600), 1600, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            //TNT1 AAAAAA 0  A_CustomMissile ("NukeSmoke", random (50, 1200), 0, random (0, 360), 2, random(80, 90));
            //TNT1 AAA 0  A_CustomMissile ("NukeSmokeBig", 1400, 0, random (0, 360), 2, random(80, 90));
            TNT1 A 1000;
            Stop;
	}
}

class SpawnedExplosionNuke : actor
{
    Default
    {
        Speed 2;
        Damagetype "Nuke";
        renderstyle "none";
        +NOCLIP
        +NOGRAVITY
        +MISSILE
        +FORCERADIUSDMG
        +NODAMAGETHRUST
        +NOBLOCKMAP
    }
    
	states
	{
        Spawn:
            TNT1 A 0;
            TNT1 A 2 A_PlaySound("FAREXPL");
            TNT1 AA 32 A_CustomMissile ("NuclearFlames", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 A 0 A_Explode(128, 1000);
            TNT1 A 0 A_CustomMissile ("NukeSmoke", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 A 32 A_CustomMissile ("NuclearFlames", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 A 0 A_Explode(128, 1000);
            TNT1 A 32 A_CustomMissile ("NuclearFlames", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 A 0 A_Explode(128, 1000);
            TNT1 A 32 A_CustomMissile ("NuclearFlames", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 A 0 A_Explode(128, 1000);
            TNT1 AA 32 A_Explode(128, 1000);
            Stop;
	}
}

class SpawnedExplosionNuke2 : actor
{
    Default
    {
        Speed 24;
        Radius 2;
        Height 2;
        renderstyle "none";
        +NOCLIP
        +NOGRAVITY
        +MISSILE
        +CLIENTSIDEONLY
        +NOINTERACTION
        +NOBLOCKMAP

    }

	states
	{
        Spawn:
            TNT1 A 0;
            TNT1 A 2;
            TNT1 AAAA 6 A_CustomMissile ("NuclearFlames", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 AAAA 6 A_CustomMissile ("NuclearFlamesBig", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 A 0 A_Stop;
            TNT1 AAAAAAAAAAAAAAA 6 A_CustomMissile ("NuclearFlamesBig", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 A 0 A_CustomMissile ("NukeSmoke", 0, 0, random (0, 360), 2, random (0, 90));
            TNT1 A 0 A_SpawnItemEx("NukeSmoke", random(-100, 100), random(-100, 100), random(-20, 20));
            TNT1 AAA 6 A_CustomMissile ("NuclearFlamesBig", 0, 0, random (0, 360), 2, random (0, 20));
            Stop;
	}
}


class NuclearFlames: ZS_ExplosionFlames
{
    Default
    {
        Scale 2.2;
        Speed 5;
        RenderStyle "Add";
    }
	States
	{
        Spawn:
            FLXP ABCDEFGHIJKLMNOPQRSTUVWXYZ 2 BRIGHT;
            Stop;
	}
}

class NuclearFlamesRepeat: ZS_ExplosionFlames
{
    Default
    {
        Scale 3.0;
        Speed 5;
        Renderstyle "None";
    }

	States
	{
        Spawn:
            TNT1 A 0;
            TNT1 AAAAAAAAAA 9 A_SpawnItemEx("NuclearFlames2", random(-50, 50), random(-50, 50), random(-50, 50), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            Stop;
	}
}

class NuclearFlames2: ZS_ExplosionFlames
{
    Default
    {
        Scale 3.5;
        Speed 5;
        RenderStyle "Add";
    }

    States
	{
        Spawn:
            FLXP ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 BRIGHT;
            Stop;
	}
}

class NuclearFlamesRepeat2: ZS_ExplosionFlames
{
    Default
    {
        Scale 3.0;
        Speed 5;
        Renderstyle "None";
    }

	States
	{
        Spawn:
            TNT1 A 0;
            TNT1 AAAAAAAAAA 9 A_SpawnItemEx("NuclearFlames3", random(-200, 200), random(-200, 200), random(-50, 50), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            Stop;
	}
}

class NuclearFlames3: ZS_ExplosionFlames
{
    Default
    {
        YScale 8.5;
        XScale 10.5;
        Speed 5;
        RenderStyle "Add";
    }

	States
	{
        Spawn:
            FLXP ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 BRIGHT;
            Stop;
	}
}

class NuclearFlamesImpact: ZS_ExplosionFlames
{
    Default
    {
        Scale 9.2;
        Speed 96;
        Damagetype "Nuke";
        RenderStyle "Add";
        Alpha 0.25;
        +FORCERADIUSDMG
        -CLIENTSIDEONLY
    }
    
	States
	{
        Spawn:
            FLXP ACFH 1 BRIGHT A_Explode(32, 256);
            FLXP ijklmNOPQRSTUVWXYZ 1 BRIGHT A_FadeOut(0.02);
            Stop;
	}
}

class NuclearFlamesBig: ZS_ExplosionFlames
{
    Default
    {
        Scale 9.2;
        Speed 3;
        RenderStyle "Add";
    }

	States
	{
        Spawn:
            FLXP ABCDEFGHIJKLMNOPQRSTUVWXYZ 4 BRIGHT;
            Stop;
	}
}

class NukeSmoke: ZS_HitpuffSmoke
{
    Default
    {
        Scale 6.0;
        Speed 1;
        Alpha 0.1;
        +SKYEXPLODE
        +FORCEXYBILLBOARD
    }
	States
	{
        Spawn:
            SMk2 CCCCCCCCCC 2 A_FadeIn(0.05);
            SMk2 C 600;

        Death:
            SMk2 CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 20 A_FadeOut(0.02);
            Stop;
	}
}


class NukeSmokeBig: NukeSmoke
{
    Default
    {
        XScale 18.0;
        YScale 12.0;
    }
}

class ZS_ExplosionFlames : ZS_FlameTrails
{
    Default
    {
        Scale 1.0;
        Speed 2;
        RenderStyle "Add";
        BounceType "Doom";
    }
	States
	{
        Spawn:
            EXPL AA 3 BRIGHT A_SpawnItem("RedFlare",0,0);
            EXPL AA 0 A_CustomMissile ("ExplosionSmokeHD", 0, 0, random (0, 360), 2, random (0, 360));
            EXPL BCDEFGH 3 BRIGHT;
            Stop;
	}
}

class ZS_FlameTrails : actor
{
    Default
    {
        Radius 1;
        Height 1;
        Speed 3;
        RenderStyle "Add";
        Damagetype "fire";
        BounceType "Doom";
        Scale 0.5;
        Gravity 0;
        PROJECTILE;
        -NOGRAVITY
        +FORCEXYBILLBOARD
        +CLIENTSIDEONLY
        +THRUACTORS
    }

	States
	{
        Spawn:
            TNT1 A 2;
            FRPR ABCDEFGH 3 BRIGHT;
            Stop;
	}
}

class ExplosionSmokeHD: ZS_HitpuffSmoke
{
    Default
    {
        Scale 2.0;
        Speed 1;
    }

	States
	{
        Spawn:  
            TNT1 A 0;
            TNT1 A 0 A_Jump(128, 2);
            TNT1 A 0 A_SetScale(-2.5, 2.0);
            TNT1 A 0;
            SM9K ABCDEFGHIJKLMNOPQRSTUVWXYZ 2;
            Stop;
	}
}

class ZS_HitpuffSmoke : actor
{
    Default
    {
        Radius 1;
        Height 1;
        Scale 0.7;
        Speed 1;
        RenderStyle "Translucent";
        BounceType "Doom";
        Alpha 0.4;
        PROJECTILE;
        +CLIENTSIDEONLY
        +FORCEXYBILLBOARD
        +MISSILE
        +THRUACTORS
    }

	States
	{
        Spawn:  
            TNT1 A 0;
            TNT1 A 0 A_Jump(128, 2);
            TNT1 A 0 A_SetScale(-0.7, -0.7);
            TNT1 A 0;
            SMOK ABCDEFGHIJKLMNOPQ 1;
            Stop;
	}
}