// Freeze Rifle
// From Cat's Frozen Addon Pack
// by SchrödingCat, Eriance/Amuscaria, Realm667
// Bloax, ZZrionTheInsect, Xaser & Ethrill, Tomtefar, SchrödingCat
// You can find the full credits in Credits/credits_CatsFrozenAddon.txt
// Code and Sprites edited by ThePopeOfDope for Project Survival
// Spawn sprites edited by ThePopeOfDope

// Actual Weapon
class PBX_FreezeRifle : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        Weapon.BobRangeX 0.3;
        Weapon.BobRangeY 0.5;
        Weapon.BobStyle "InverseSmooth";
        Weapon.BobSpeed 2.4;
	    Inventory.AltHUDIcon "F12RA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_Cell";
        Weapon.AmmoType2 "FreezeRifleAmmo";
        Weapon.AmmoGive1 80;
	    Weapon.AmmoGive2 40;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_FreezeRifle_Pickup";
        Inventory.PickupSound "weapons/CryoRifle/respect1";
        Obituary "$OB_WEAP_FREEZERIFLE";
        AttackSound "None";
        Tag "$PBX_FreezeRifle_Tag";
        Scale 0.5;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    bool mInAttackMode;
    
    const CELL_SIZE = 50;
    const AMMO_TAKE_LASER = 1;
    const AMMO_TAKE_MISSILE = 3;
    const AMMO_TAKE_ICEBOMB = 15;
    const AMMO_TAKE_ICENUKE = CELL_SIZE;

//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void setSprite(name attackMode = '')
	{
		if(getAttackMode() && attackMode != '')
            A_SetWeaponSpriteEx(attackMode);
	}

    action int getAmmoTake(bool isAltfire = false)
    {
        if(getAttackMode())
            return isAltfire ? AMMO_TAKE_ICENUKE : AMMO_TAKE_LASER;
        return isAltfire ? AMMO_TAKE_ICEBOMB : AMMO_TAKE_MISSILE;
    }

    action void setFrame(int attackMode)
    {
		if(getAttackMode())
            A_SetWeaponFrame(attackMode);
	}

    action state jumpIfAttackMode(StateLabel st)
    {
        if(getAttackMode())
            return ResolveState(st);
        return ResolveState(null);
    }
    
    action bool getAttackMode()
	{
		return invoker.mInAttackMode;
	}

	action void setOverchargeMode(bool mode)
	{
		invoker.mInAttackMode = mode;
	}

    action state checkDecharge()
    {
        chargeEffects();
        if(JustPressed(BT_RELOAD))
            return resolvestate("DeCharge");
        return resolvestate(null);
    }

    action void chargeEffects()
    {
        A_FireCustomMissile("PlasmaFlareSpawner",0,0,0,0);
        A_FireCustomMissile("BluePlasmaParticle",random(10,-10),0,0,random(-3,3),0,random(7,-7) );
        A_FireProjectile("BlueFlareSpawn",0,0,0,0);
        A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-2,2), -15, 0, random(-2,2));
        A_FlashOverlay();
    }

    action state freezeRifleReady()
    {
        bool isAttackMode = getAttackMode();
        bool isEmpty = PB_GetMagEmpty() || PB_GetMagUnloaded();

        // Normal Ready
        if(!isEmpty)
        {
            A_StartSound("PLSIDLE", CHAN_7, CHANF_LOOPING|CHANF_OVERLAP);
            A_FireCustomMissile("TinyGunSmoker", 0, 0, 0, -3, 0, 0);
        }

        PB_CoolDownBarrel();

        // attackMode Ready
        if(isAttackMode)
        {
            if(!isEmpty)
            {
                A_StartSound("weapons/CryoRifle/idle", CHAN_6, CHANF_LOOPING|CHANF_OVERLAP);
                A_SetWeaponFrame(random[sfx](1,5)); // Randomize the sprite frame
            }
            else
            {
                stopSound();
                A_SetWeaponFrame(6);
            }
        }

        return A_DoPBWeaponAction();
    }

    action void fireWeapon(bool isAltfire = false)
    {
        A_GunFlash();
        A_AlertMonsters(450);
        PB_FireOffset();
        A_FlashOverlay(state:"BeamMuzzleFlash");

        PB_TakeAmmo(invoker.ammo2.getClassName(),getAmmoTake(isAltfire),0);

        // Primary
        if(getAttackMode() && !isAltfire)
        {
            PB_FireCryoRifleBeam();
            A_StartSound("weapons/cryobowflyby", CHAN_WEAPON, CHANF_LOOPING);
        }
        else if(!isAltfire)
        {
            PBX_FireBullets("IceMissileGravity", 1, 3, 0, 0, 3);
            A_StartSound("weapons/CryoRifle/missile", CHAN_WEAPON, CHANF_OVERLAP);
        }

        // Secondary
        if(getAttackMode() && isAltfire)
        {
            stopSound();
            A_SetBlend("Blue", 0.6, 12);
            EventHandler.SendInterfaceEvent(PlayerNumber(), "PB_HUDInterference", 20);
            A_StartSound("PLSULT", CHAN_WEAPON);
            PBX_FireBullets("IceOrbBig", 1, 3, 0, 0, 3);
        }
        else if(isAltfire)
        {
            PBX_FireBullets("CryoWall", 1, 3, 0, 0, 3);
            A_StartSound("weapons/CryoRifle/flak", CHAN_WEAPON, CHANF_OVERLAP);
        }

        A_FireCustomMissile("BlueFlareSpawn",0,0,0,0);
        PB_GunSmoke();
        PB_GunSmoke();
        PB_GunSmoke();
        
        A_ZoomFactor(0.98);
        if(isAltfire)
            PB_WeaponRecoil(-0.72, frandom[sfx](-0.25,0.25));
        else
            PB_WeaponRecoil(-0.32, frandom[sfx](-0.16,0.16));
    }

    action void stopSound()
    {
        A_StopSound(CHAN_WEAPON);
        A_StopSound(CHAN_5);
        A_StopSound(CHAN_6);
        A_StopSound(CHAN_7);
    }

    // This is from PB's CryoRifle beam code
    const frozenspacepx = 15;
	action void PB_FireCryoRifleBeam()
	{
		FLineTraceData t;
		double zoff = (height * 0.5 - floorclip + player.mo.AttackZOffset*player.crouchFactor) - 9;
		bool hit = LineTrace(angle,8000,pitch,TRF_NOSKY ,zoff,data:t);
		
		vector3 fpos = t.hitlocation - t.hitdir; //substract one to the final pos so the puff doesnt spawn in the wall and therefore in a higher sector if any
		vector3 spos = (pos.xy, pos.z + zoff);
		
		vector3 dif = levellocals.Vec3Diff(spos,fpos);
		vector3 dr = dif.unit();
		double dist = dif.length();
		
		int steps = int(dist / frozenspacepx) + 1;
		
		FSpawnParticleParams FrostBeam;
		FrostBeam.Texture = TexMan.CheckForTexture("X027A0"); //FIR5G0 also looks cool
		FrostBeam.Color1 = "FFFFFF";
		FrostBeam.Style = STYLE_Add;
		FrostBeam.Flags = SPF_ROLL|SPF_FULLBRIGHT|SPF_NOTIMEFREEZE;
		FrostBeam.Vel = (0,0,0); 
		FrostBeam.Startroll = random[sfx](0,360); //randompick(0,90,180,270,360);
		FrostBeam.RollVel = 0;
		FrostBeam.StartAlpha = 0.90;
		FrostBeam.FadeStep = 0.1;
		FrostBeam.Size = 20;
		FrostBeam.SizeStep = 0;
		FrostBeam.Lifetime = 1; 
		
		//basically, simulate a hitscan attack by damaging the actor the trace hits, spawning a puff and spraying a decal
		//damage victim (if any)
		if(t.hitactor)
		{
			actor v = t.hitactor;
			if(v && v.bismonster && v.health > 0 && !isfriend(v))
				v.damagemobj(self,self,2,"Freeze",DMG_THRUSTLESS);
		}
		
		//spawn puff if hit anything that is not sky
		if(hit)
		{
			actor p = Spawn("CryoRifleBeamPuff",fpos);
			if(p)
			{
				p.target = self; //no self damage
				p.A_SprayDecal("FreezerBurnSmall",2,(0,0,0),t.hitdir); //spray the decal manually
			}
		}
		
		for(int i = 0; i < steps; i++)
		{
			spos += (dr * frozenspacepx);
			FrostBeam.Pos = spos;
			if(i > 0) //skip the first iteration
				Level.SpawnParticle(FrostBeam);
		}
	}
    
//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            F12R A -1;
            Stop;

        CacheSprites:
            F11R A 0; F04R A 0;
            F02R A 0;

        WeaponRespect:
            TNT1 A 0 {
				A_SetCrosshair(-1);
                PB_SetZoom(false);
			}
			TNT1 AAAAAA 1 {
				PB_SetRoll(roll+0.3);
				return A_DoPBWeaponAction();
			}
            TNT1 A 0 A_StartSound("weapons/CryoRifle/up", CHAN_WEAPON, CHANF_OVERLAP);
			FR08 ABCDEFGHIJ 1 {
				PB_SetRoll(roll-0.3);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/CryoRifle/reload1", CHAN_WEAPON, CHANF_OVERLAP);
			FR08 KLMNO 1 A_DoPBWeaponAction();
			TNT1 A 0 A_StartSound("PLSIDLE", CHAN_7, CHANF_LOOPING|CHANF_OVERLAP);
			FR08 PQRSTUOPQRSTU 1 A_DoPBWeaponAction();
			TNT1 A 0 A_StartSound("weapons/CryoRifle/respect3", CHAN_WEAPON, CHANF_OVERLAP);
			FR08 VWXYZZZ 1 A_DoPBWeaponAction();
			TNT1 A 0 A_StartSound("IronSights",CHAN_WEAPON,CHANF_OVERLAP);
			FR07 EFGH 1 A_DoPBWeaponAction();
			TNT1 A 0 A_StartSound("weapons/CryoRifle/respect1", CHAN_WEAPON, CHANF_OVERLAP);
			FR07 ONMLKJIHGF 1 A_DoPBWeaponAction();
			FR07 EDCA 1 {
				PB_SetRoll(roll+0.3);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 jumpIfAttackMode("SwapToAttack");
            Goto Ready3;

        WeaponInspect:
            TNT1 A 0 jumpIfAttackMode("InspectStartCharged");
        InspectStartNormal:
            FR08 GHIJ 1 {
				PB_SetRoll(roll-0.3);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/CryoRifle/reload1", CHAN_WEAPON, CHANF_OVERLAP);
			FR08 KLMNO 1 A_DoPBWeaponAction();
        HoldInspect:
			TNT1 A 0 A_StartSound("PLSIDLE", CHAN_7, CHANF_LOOPING|CHANF_OVERLAP);
			FR08 PQRSTUOPQRSTU 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
			TNT1 A 0 A_StartSound("weapons/CryoRifle/respect3", CHAN_WEAPON, CHANF_OVERLAP);
			FR08 VWXYZZZ 1 A_DoPBWeaponAction();
			TNT1 A 0 A_StartSound("IronSights",CHAN_WEAPON,CHANF_OVERLAP);
			FR07 EDCA 1 {
				PB_SetRoll(roll+0.3);
				return A_DoPBWeaponAction();
			}
            Goto Ready3;

        InspectStartCharged:
            // Swap to Normal Animation
            TNT1 A 0 A_StartSound("IronSights", CHAN_WEAPON, CHANF_OVERLAP);
			FRF6 QPONMMMMM 1 A_DoPBWeaponAction();
			FRF6 LKJIHGF 1 A_DoPBWeaponAction();
			TNT1 A 0 A_StartSound("weapons/CryoRifle/respect2", CHAN_WEAPON, CHANF_OVERLAP);
			FRF6 F 1 A_DoPBWeaponAction();
        HoldInspectCharged:
            FRF6 F 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspectCharged");
			FRF6 FGHIJKLMNOPQ 1 {
                A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
				return A_DoPBWeaponAction();
            }
            Goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            F05R A 1;
			FR08 FEDCBA 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(94);
                PBX_WeaponRaise("weapons/CryoRifle/respect1");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            FR08 ABCDEF 1;
			F05R A 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 {
                // stopSound();
				PB_SetRoll(0);
                PB_HandleCrosshair(94);
                A_ClearReFire();
			}
		ReadyToFire:
			TNT1 A 0 PBX_CheckInspect();
			F05R A 1 freezeRifleReady();
            loop;

        DeCharge:
            TNT1 A 0 {
                stopSound();
				A_StartSound("weapons/CryoRifle/powerdown", CHAN_5, CHANF_OVERLAP);
            }
            F10R DDDDDCCCCCC 1 setSprite('F11R');
            "####" BBBBBBAAAAA 1 A_DoPBWeaponAction();
            TNT1 A 0 {
                A_StartSound("PLSCOOL",CHAN_WEAPON,CHANF_OVERLAP);
                A_ClearReFire();
            }
            Goto Ready3;
            

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(94);
                A_ClearReFire();
			}
            TNT1 A 0 PB_JumpIfNoAmmo(min:getAmmoTake(),emptysound:"RAILDRY");
            // Charge
            TNT1 A 0 A_StartSound("weapons/CryoRifle/powerup", CHAN_WEAPON, CHANF_OVERLAP);
            F10R AAAAABBBBBBCCCCCCDDDDD 1 setSprite('F11R');
			TNT1 AAAAAAAAAA 0 A_FireCustomMissile("BluePlasmaParticle",random(10,-10),0,0,random(-3,3),0,random(7,-7) );
            TNT1 A 0 jumpIfAttackMode("HoldLaser");
        HoldMissile:
			TNT1 A 0 PB_JumpIfNoAmmo(min:AMMO_TAKE_MISSILE,emptysound:"RAILDRY");
            FR09 A 1 Bright fireWeapon();
			FR09 B 1 Bright {
				A_ZoomFactor(0.99);
                PB_WeaponRecoil(-0.32, frandom[sfx](-0.16,0.16));
			}
			FR09 C 1 Bright A_ZoomFactor(1.0);
			FR09 D 1 Bright;
			F05R A 6;
			TNT1 A 0 PB_Refire("HoldMissile");
            Goto EndFire;

        HoldLaser:
			TNT1 A 0 PB_JumpIfNoAmmo("EndFire",AMMO_TAKE_LASER,emptysound:"RAILDRY");
            FR09 E 1 Bright fireWeapon();
			FR09 F 1 Bright {
                PB_FireCryoRifleBeam();
				A_ZoomFactor(0.99);
                PB_WeaponRecoil(-0.32, frandom[sfx](-0.16,0.16));
			}
			FR09 G 1 Bright {
                PB_FireCryoRifleBeam();
				A_ZoomFactor(1.0);
			} 
			TNT1 A 0 PB_Refire("HoldLaser");
        EndFire:
			TNT1 A 0 {
				stopSound();
				A_StartSound("weapons/CryoRifle/powerdown", CHAN_5, CHANF_OVERLAP);
			}
			TNT1 A 0 PB_JumpIfNoAmmo(min:getAmmoTake(),emptysound:"RAILDRY");
            Goto Decharge;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 {
				stopSound();
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(94);
            }
            TNT1 A 0 PB_JumpIfNoAmmo(min:getAmmoTake(true),emptysound:"RAILDRY");
            // Charge
            TNT1 A 0 A_StartSound("weapons/CryoRifle/powerup", CHAN_WEAPON, CHANF_OVERLAP);
            TNT1 A 0 jumpIfAttackMode("ChargeIceNuke");
        ChargeIceBomb:
            TNT1 A 0 A_StartSound("PLSC_1", CHAN_WEAPON, CHANF_OVERLAP);
            F10R AAAAA 1 {
                chargeEffects();
                setSprite('F11R');
            }
            "####" A 0 A_StartSound("PLSC_2", CHAN_WEAPON, CHANF_OVERLAP);
            "####" BBBBBB 1 chargeEffects();
            "####" A 0 A_StartSound("PLSC_3", CHAN_WEAPON, CHANF_OVERLAP);
            "####" CCCCCC 1 chargeEffects();
            "####" A 0 A_StartSound("PLSC_4", CHAN_WEAPON, CHANF_OVERLAP);
            "####" DDDDD 1 chargeEffects();
			TNT1 AAAAAAAAAA 0 A_FireCustomMissile("BluePlasmaParticle",random(10,-10),0,0,random(-3,3),0,random(7,-7) );
        AltHold:
            TNT1 A 0 A_StartSound("weapons/CryoRifle/idle", CHAN_WEAPON, CHANF_LOOPING);
            F10R D 1 {
                A_WeaponOffset(random[sfx](-1,1),random[sfx](31,33));
                setSprite('F11R');
                return checkDecharge();
            }
			TNT1 A 0 PB_ReFire("AltHold");
        FireIceBomb:
			TNT1 A 0 PB_JumpIfNoAmmo(min:getAmmoTake(isAltfire:true),emptysound:"RAILDRY");
            FR09 A 1 Bright fireWeapon(isAltfire:true);
			FR09 B 1 Bright {
				A_ZoomFactor(0.99);
                PB_WeaponRecoil(-0.32, frandom[sfx](-0.16,0.16));
			}
			FR09 C 1 Bright A_ZoomFactor(1.0);
			FR09 D 1 Bright;
			F05R A 6;
            Goto Decharge;

        ChargeIceNuke:
            TNT1 A 0 A_StartSound("PLSC_1", CHAN_WEAPON, CHANF_OVERLAP);
            F10R AAAAAAAAAAAAAAAAA 1 {
                setSprite('F11R');
                return checkDecharge();
            }
            "####" A 0 A_StartSound("PLSC_2", CHAN_WEAPON, CHANF_OVERLAP);
            "####" BBBBBBBBBBBBBBBBB 1 chargeEffects();
            "####" A 0 A_StartSound("PLSC_3", CHAN_WEAPON, CHANF_OVERLAP);
            "####" CCCCCCCCCCCCCCCCC 1 chargeEffects();
            "####" A 0 A_StartSound("PLSC_4", CHAN_WEAPON, CHANF_OVERLAP);
            Goto AltHoldIceNuke+1; // So it skips playing the warning sound for the first time

        AltHoldIceNuke:
            TNT1 A 0 A_StartSound("PLSFULL", CHAN_WEAPON, CHANF_LOOPING);
            F10R D 1 {
                A_WeaponOffset(random[sfx](-1,1),random[sfx](31,33));
                setSprite('F11R');
                return checkDecharge();
            }
			TNT1 A 0 PB_ReFire("AltHoldIceNuke");
        FireIceNuke:
            FR09 E 1 Bright fireWeapon(isAltfire:true);
			FR09 F 1 Bright {
				A_ZoomFactor(0.99);
                PB_WeaponRecoil(-0.72, frandom[sfx](-0.25,0.25));
			}
			FR09 G 1 Bright A_ZoomFactor(1.0);
			FR09 H 1 Bright;
			F05R BCDEFG 1; 
            TNT1 A 0 A_ClearReFire(); // Because it doesnt go to decharge
            Goto Ready3; // So it skips the stop sound

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
		Reload:
            TNT1 A 0 {
				// stopSound();
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(94);
            }
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty",null,null,"Ready3","Ready3",CELL_SIZE);
            TNT1 A 0 A_StartSound("weapons/CryoRifle/reload1", CHAN_WEAPON, CHANF_OVERLAP);
            // Raise
			FR07 A 1 {
                if(!PB_GetMagEmpty())
                    setFrame(1);
            }
			FR07 CDEFGHHHHHH 1;
            // Remove Cell
			FR07 IJJJJJ 1;
			TNT1 A 0 A_StartSound("weapons/CryoRifle/reload3", CHAN_WEAPON, CHANF_OVERLAP);
			FR07 KL 1;
            TNT1 A 0 {
                A_StartSound("weapons/plasma/cellout",CHAN_WEAPON,CHANF_OVERLAP);
                PB_SetMagEmpty(true);
                PB_SetMagUnloaded(true);
                PB_SetChamberEmpty(true);
            }
            FR07 MNOOOOO 1;
        ContinueReload:
            TNT1 A 0 A_StartSound("IronSights", CHAN_WEAPON, CHANF_OVERLAP);
			FR07 OOOOONMLK 1;
			TNT1 A 0 A_StartSound("weapons/CryoRifle/respect1", CHAN_WEAPON, CHANF_OVERLAP);
            TNT1 A 0 {
                A_StartSound("weapons/plasma/cellin",CHAN_WEAPON,CHANF_OVERLAP);
                PB_AmmoIntoMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    CELL_SIZE);
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
                PB_SetChamberEmpty(false);
            }
        FinishReload:
			FR07 JJIHHGF 1;
			FR08 ZYXWVUTSRQPOUTSRQPONMLKJIH 1;
            Goto Ready3;
        
        RaiseFromEmpty:
            TNT1 A 0 A_StartSound("weapons/CryoRifle/reload1", CHAN_WEAPON, CHANF_OVERLAP);
            FR07 A 1;
			FR07 CDEFGHHHHHH 1;
            Goto ContinueReload;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
            TNT1 A 0 stopSound();
            TNT1 A 0 A_StartSound("weapons/CryoRifle/reload1", CHAN_WEAPON, CHANF_OVERLAP);
            // Raise
			FR07 A 1 setFrame(1);
			FR07 CDEFGHHHHHH 1;
            // Remove Cell
			FR07 IJJJJJ 1;
			TNT1 A 0 A_StartSound("weapons/CryoRifle/reload3", CHAN_WEAPON, CHANF_OVERLAP);
			FR07 KL 1;
            TNT1 A 0 {
                A_StartSound("weapons/plasma/cellout",CHAN_WEAPON,CHANF_OVERLAP);
				PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname());
				PB_SetMagUnloaded(true);
				PB_SetChamberEmpty(true);
                PB_SetMagEmpty(true);
			}
            FR07 MNOOOOO 1;
        FinishUnload:
            TNT1 A 0 A_StartSound("IronSights", CHAN_WEAPON, CHANF_OVERLAP);
			FR07 HGFEDCA 1;
            goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 {
				A_Takeinventory("GoWeaponSpecialAbility",1);
				PB_HandleCrosshair(94);
				stopSound();
			}
            TNT1 A 0 PB_JumpIfNoAmmo(emptysound:"RAILDRY");
			TNT1 A 0 jumpIfAttackMode("SwapToDefense");
        SwapToAttack:
            TNT1 A 0 {
                setOverchargeMode(true);
				A_Print("$PBX_FreezeRifle_Attack");
				A_StartSound("IronSights", CHAN_WEAPON, CHANF_OVERLAP);
			}
			FRF6 ABCDEEEEE 1;
			TNT1 A 0 {
                // A_SetBlend("Blue", 0.6, 12);
                A_StartSound("weapons/CryoRifle/respect1", CHAN_WEAPON, CHANF_OVERLAP);
            }
			FRF6 FGHIJKLMNOPQ 1 A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
            Goto Ready3;           
            
        SwapToDefense:
            TNT1 A 0 {
                setOverchargeMode(false);
				A_Print("$PBX_FreezeRifle_Defense");
				A_StartSound("IronSights", CHAN_WEAPON, CHANF_OVERLAP);
			}
			FRF6 QPONMMMMM 1;
			TNT1 A 0 A_StartSound("weapons/CryoRifle/respect2", CHAN_WEAPON, CHANF_OVERLAP);
			FRF6 LKJIHGFEDCBA 1 A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
			Goto Ready3;

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        BeamMuzzleFlash:
			TNT1 A 0 A_Jump(256, "Muzzle1", "Muzzle2", "Muzzle3", "Muzzle4", "Muzzle5", "Muzzle6", "Muzzle7");
		Muzzle1:
			FR12 A 1 BRIGHT;
			Stop;
		Muzzle2:
			FR12 B 1 BRIGHT;
			Stop;
		Muzzle3:
			FR12 C 1 BRIGHT;
			Stop;
		Muzzle4:
			FR12 D 1 BRIGHT;
			Stop;
		Muzzle5:
			FR12 E 1 BRIGHT;
			Stop;
		Muzzle6:
			FR12 F 1 BRIGHT;
			Stop;
		Muzzle7:
			FR12 G 1 BRIGHT;
			Stop;

        FlashPunching:
            // 14 frames
            F01R ABCDEEE 1 setSprite('F02R');
			"####" EEEDCBA 1;
            goto Ready3;

        FlashKicking:
            // 15 frames
            F03R ABCDE 1 setSprite('F04R');
			"####" E 4;
			"####" EDCBA 1;
			F05R A 1 setFrame(1);
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            F03R ABCDE 1 setSprite('F04R');
			"####" E 5;
			"####" EDCBA 1;
			F05R A 1 setFrame(1);
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            F01R ABCDEEEEEEEEEEEEEEEEEE 1 setSprite('F02R');
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            F01R EDCBA 1 setSprite('F02R');
            TNT1 A 0 jumpIfAttackMode("FlashSlideKickingStopCharged");
			F05R AA 1;            
            goto Ready3;

        FlashSlideKickingStopCharged:
			F05R BE 1;
            goto Ready3;
    }
}