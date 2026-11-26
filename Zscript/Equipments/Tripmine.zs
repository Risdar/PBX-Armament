////// DATA /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TripmineCard : equipmentCard
{
	override void InfoFiller(out array<string> tags,out array<string> tokens,out array<string> ammotypes,out array<string>img,out array<double>sx,out array<double>sy)
	{
		tags.push("$PBX_TRIPMINE_TAG");
		tokens.push("PBX_TripmineToken");
		ammotypes.push("PBX_TripmineAmmo");
		img.push("graphics/Equipments/Tripmine/TripmineIcon.png");
		sx.push(0.4);
		sy.push(0.4);
	}
}

class PBX_TripmineToken : PBX_Equipment 
{
	Default 
    {
		Inventory.Icon "ALISTINC";
		PB_Equipment.AmmoType "PBX_TripmineAmmo";
		PB_Equipment.SelectString "$PBX_TRIPMINE_WHEEL";
		PB_Equipment.FailString "$PBX_TRIPMINE_OUT";
		PB_Equipment.FontColor "Red";
	}

	States 
    {
        UseEquipment:
            TNT1 A 0;
            TNT1 A 0 EQ_SetWeaponState("FlashPunching");
            TRPM FEDCBBBB 1;
			TRPM B 1 {
				FLineTraceData wallinmyway;
				invoker.owner.LineTrace(invoker.owner.angle, 64, invoker.owner.pitch, 0, offsetz: 12, data: wallinmyway);
				if (wallinmyway.HitType == TRACE_HitWall)
				{
					A_fireprojectile("TripMineProjectile",spawnofs_xy:0,spawnheight:-4);
                    EQ_TakeAmmo();
					return ResolveState("Placedsuccesfully");
				}
				Return resolvestate(null);
			}
			TRPM BBBMNOPQ 1;
            TNT1 A 0 PB_ReThrow();
            Stop;

        Placedsuccesfully:
			TRPM GGGGGHIJKL 1;
            TNT1 A 0 PB_ReThrow();
			Stop;
	}
}

class PBX_TripmineAmmo : PB_Ammo
{
	Default
	{
		Tag "$PBX_TRIPMINE_TAG";
		Inventory.Amount 1;
		Inventory.MaxAmount 5;
		Inventory.Icon "TRPMA0";
        Inventory.PickupSound "Ammocase/Open";
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 8;
		Scale 0.08;
	}
	
	override void PB_SetAmmoSprite()
	{
		sprite = GetSpriteIndex("TRPM");
	}
	
	override void AttachToOwner(actor other) //we have to do this here so that cheats will give the tokens
	{
		other.GiveInventory("PBX_TripmineToken",1);
		Super.AttachToOwner(other);
	}
}

////// ACTORS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

    // override void Tick()
    // {
    //     Super.Tick();
    //     if(IsFrozen()) return;
        
    //     if(target.FindInventory("RemoteChargeDetonator"))
    //         SetStateLabel("Death");
    // }

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
            TNT1 A 0 A_SpawnItemEx ("PBX_TripmineAmmo",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
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