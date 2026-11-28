////// DATA /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class LaserChargeCard : equipmentCard
{
	override void InfoFiller(out array<string> tags,out array<string> tokens,out array<string> ammotypes,out array<string>img,out array<double>sx,out array<double>sy)
	{
		tags.push("$PB_LASERCHR_TAG");
		tokens.push("PBX_LaserChargeToken");
		ammotypes.push("PBX_LaserChargeAmmo");
		img.push("graphics/Equipments/Charges/LaserCharge/LaserChargeIcon.png");
		sx.push(0.8);
		sy.push(0.8);
	}
}

class PBX_LaserChargeToken : PBX_ChargesBase 
{
	Default 
    {
		Inventory.Icon "LASRCHRC";
		PB_Equipment.AmmoType "PBX_LaserChargeAmmo";
		PB_Equipment.SelectString "$PBX_LASERCHR_WHEEL";
		PB_Equipment.FailString "$PBX_LASERCHR_OUT";
		PB_Equipment.FontColor "Red";
	}
	
	States 
    {
        UseEquipment:
            LSRC ABCD 1;
		    TNT1 A 0 A_DoubleTapFlag();
			LSRC EFG 1;
		    "####" A 0 checkDetonate();
			LSRC HIJKLMNOPQ 1;
			THRO ABCD 1;
			TNT1 A 0 {
                A_StartSound("charge/place/remote",CHAN_AUTO);
                EQ_TakeAmmo();
                A_FireCustomMissile("ThrownLaserCharge",0,0,0,-1);
            }
			THRO EEEEFGHI 1;
            TNT1 A 0 PB_ReThrow();
            Stop;
	}
}

////// PICKUPS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class PBX_LaserChargeAmmo : PB_Ammo
{
	Default
	{
		Tag "$PBX_LASERCHR_TAG";
        Inventory.Amount 1;
		Inventory.MaxAmount 5;
		Inventory.Icon "LSRCS0";
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 8;
		Inventory.PickupSound "Ammocase/Open";
		Scale 0.45;
	}
	
	override void PB_SetAmmoSprite()
	{
		sprite = GetSpriteIndex("LSRC");
        frame = 17;
	}
	
	override void AttachToOwner(actor other) //we have to do this here so that cheats will give the tokens
	{
        Array<String> tips;
        tips.Push(string.format(StringTable.Localize("$PBX_EXPRCHRG_TIP"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+USER1")));
        PBX_Handler.SendTipArrayIfNeeded(tips,EQUIPMENTS_HELPTEXT,PBX_TIP_CHARGES);
		other.GiveInventory("PBX_LaserChargeToken",1);
		Super.AttachToOwner(other);
	}
}

////// ACTORS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
            TNT1 A 0 A_SpawnItemEx ("PBX_LaserChargeAmmo",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
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
            LSRC S 41 BRIGHT {
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
                A_PlaySound("charge/beep/laser", 4);
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
            LSRC S 1 {
                A_Changeflag("THRUACTORS", 1);
                A_Changeflag("Solid", 1);
                mStuckEnemy = true;
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