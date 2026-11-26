////// DATA /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class AcidChargeCard : equipmentCard
{
	override void InfoFiller(out array<string> tags,out array<string> tokens,out array<string> ammotypes,out array<string>img,out array<double>sx,out array<double>sy)
	{
		tags.push("$PB_ACIDCHR_TAG");
		tokens.push("PBX_AcidChargeToken");
		ammotypes.push("PBX_AcidChargeAmmo");
		img.push("graphics/Equipments/Charges/AcidCharge/AcidChargeIcon.png");
		sx.push(0.8);
		sy.push(0.8);
	}
}

class PBX_AcidChargeToken : PBX_ChargesBase 
{
	Default 
    {
		Inventory.Icon "ACIDCHRC";
		PB_Equipment.AmmoType "PBX_AcidChargeAmmo";
		PB_Equipment.SelectString "$PBX_ACIDCHR_WHEEL";
		PB_Equipment.FailString "$PBX_ACIDCHR_OUT";
		PB_Equipment.FontColor "Green";
	}
	
	States 
    {
        UseEquipment:
            REMT ABCD 1;
		    TNT1 A 0 A_DoubleTapFlag();
			REMT EFG 1;
		    "####" A 0 A_JumpIf(HasDoubleTapped(), "Detonate");
			REMT HIJKLMNOPQ 1;
			THRO ABCD 1;
			TNT1 A 0 {
                A_StartSound("charge/place/remote",CHAN_AUTO);
                EQ_TakeAmmo();
                A_FireCustomMissile("ThrownAcidCharge",0,0,0,-1);
            }
			THRO EEEEFGHI 1;
            TNT1 A 0 PB_ReThrow();
            Stop;
	}
}

class PBX_AcidChargeAmmo : PB_Ammo
{
	Default
	{
		Tag "$PB_ACIDCHR_TAG";
        Inventory.Amount 1;
		Inventory.MaxAmount 5;
		Inventory.Icon "REMTS0";
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 10;
		Inventory.PickupSound "Ammocase/Open";
		Scale 0.45;
	}
	
	override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("REMT");
        frame = 17;
    }
	
	override void AttachToOwner(actor other) //we have to do this here so that cheats will give the tokens
	{
		other.GiveInventory("PBX_AcidChargeToken",1);
		Super.AttachToOwner(other);
	}
}

////// ACTORS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
            TNT1 A 0 A_SpawnItemEx ("PBX_AcidChargeAmmo",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
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
            REMT S 42 BRIGHT {
                if(mStuckEnemy) {
                    if(AAPTR_TRACER) 
                        A_Warp(AAPTR_TRACER,0,0,20,0,WARPF_NOCHECKPOSITION);
                    else 
                        A_Fall();
                }
            }
            TNT1 A 0 {
                A_SpawnItem("GreenFlareSmall",0,0);
                A_PlaySound("charge/beep/remote", 4);
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
            REMT S 1 {
                A_Changeflag("THRUACTORS", 1);
                A_Changeflag("Solid", 1);
                mStuckEnemy = true;
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