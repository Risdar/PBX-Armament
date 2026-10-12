// Super Nailgun 
// Original by Idkfa

// Includes
// #include "./PlasmaBlaster_Functions.zs"
// #include "./PlasmaBlaster_Wheel.zs"

// Actual Weapon
class PBX_SuperNailgun : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
	    Inventory.AltHUDIcon "SNPIA0";
		PB_WeaponBase.MaxOverheat MAX_OVERHEAT;
		PB_WeaponBase.OverheatCoolingRate OVERHEATCOOLING_RATE;
		PB_WeaponBase.ReserveToMagAmmoFactor 2;
        Weapon.BobRangeX 0.3;
        Weapon.BobRangeY 0.5;
        Weapon.BobStyle "InverseSmooth";
        Weapon.BobSpeed 2.4;
        FloatBobStrength 0.5;

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_HighCalMag";
        Weapon.AmmoType2 "SuperNailgunAmmo";
        Weapon.AmmoGive1 30;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_SuperNailgun_Pickup";
        Inventory.PickupSound "CBOXPKUP";
        Obituary "$OB_WEAP_SUPERNAILGUN";
        AttackSound "None";
        Tag "$PBX_SuperNailgun_Tag";
        Scale 0.4;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
        +INVENTORY.ALWAYSPICKUP;
        +FORCEXYBILLBOARD;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    bool mWeaponIsSpinning;
    bool mChargedNailsMode;

    const MAGAZINE_SIZE         = 100; 

    const MAX_OVERHEAT	 		= 450;
	const OVERHEAT_THRESHOLD	= MAX_OVERHEAT/2;	// Overheat threshold for firing the special rounds
	const OVERHEATCOOLING_RATE 	= 4;	// How many tics before removing 5 overheat when not selected
	const OVERHEATCOOLING_RATE2 = -5;	// Decrease overheat when the weapon is selected
	const OVERHEATCOOLING_LAYER = 3;
	const OVERHEAT_GIVE_OVR 	= OVERHEAT_GIVE_NORM*1.1;	// How much heat given when over Threshold
	const OVERHEAT_GIVE_NORM	= 10;	// How much heat given when normal fire

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void superNailgun_setSprite(name mSprite)
    {
        if(PB_GetMagUnloaded())
            A_SetWeaponSpriteEx(mSprite);
    }

    action void cooldownOverheat()
	{
		A_Overlay(OVERHEATCOOLING_LAYER,"Cooling",true);
	}

    action state SuperNailgun_CheckSpin(StateLabel spin = "SpinLoop")
    {
        if(invoker.mWeaponIsSpinning) return resolvestate(spin);
        return resolvestate(null);
    }

    action void SuperNailgun_CoolDownBarrel()
	{
		int heat = PB_GetOverheat();
		
		if (heat < OVERHEAT_THRESHOLD)
		{
			PB_CoolDownBarrel(0, 0, 2, 0, 0, 0, 1.0, 1.0, true);
			return;
		}
		
		double scale = PB_Math.LinearMap(double(heat), 175.0, 500.0, 0.8, 2.5);
		double alpha = PB_Math.LinearMap(double(heat), 175.0, 500.0, 0.5, 1.5);
		
		PB_CoolDownBarrel(0, 0, 2, 0, 0, 0, scale, alpha, true);
	}

    action void SuperNailgun_Fire()
    {
        A_ZoomFactor (0.98);
        A_AlertMonsters();
        PB_LowAmmoSoundWarning("hdmr");
        SuperNailgun_FireNails();
        PB_TakeAmmo(invoker.ammo2.getClassName(),emptyMag:0,emptyChamber:0);
        A_StartSound("SNFIRE", CHAN_WEAPON, 0, 1.0);
        PB_WeaponRecoil(-0.6,frandom[sfx](-1.0,1.0));
        PB_FireOffset();
    }

    action void SuperNailgun_FireNails()
    {
        double spread;
        bool isOverheating = PB_GetOverheat() > 0;
		bool overThreshold = PB_GetOverheat() > OVERHEAT_THRESHOLD;

        if(overThreshold)		spread = 7;
		else if(isOverheating) 	spread = 1.0 + (PB_GetOverheat() / 100.0);
		else					spread = 3;

        name proj = "PB_MGNail";
        if(overThreshold)
        {
            proj = invoker.mChargedNailsMode ? "SuperNail_Lightning" : "SuperNail_Hot";
            A_StartSound("LGLoop", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
            A_GunFlash();
        }

        PB_FireBullets(proj, 1, spread, 0, 0, spread);
        PB_ModifyOverheat(overThreshold ? OVERHEAT_GIVE_OVR : OVERHEAT_GIVE_NORM);
    }

    // To Reduce boilerplate
    action void SuperNailgun_PLaysound()
    {
        A_StartSound("SNGA", CHAN_5, CHANF_OVERLAP, 0.5);
        A_StartSound("SNGB", CHAN_5, CHANF_OVERLAP, 0.5);
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            SNPI A -1;
            Stop;

        WeaponRespect:
            SNRE ABCDEFGHIIIIIIIJK 1 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaysoundEx("weapons/riflemagslap", "Auto");
            SNRE LMNOPPPQRSTUVWXYZ  1 A_DoPBWeaponAction();
            SNR1 AB 1 A_DoPBWeaponAction();
            TNT1 A 0 A_Playsound("weapons/shotgun/detach", 50);
            TNT1 A 0 A_Playsound("weapons/minigun/respect1", 51);
            SNR1 CDEFGGGHIJKL 1 A_DoPBWeaponAction();
            SNLR A 6 A_DoPBWeaponAction();
            TNT1 A 0 SuperNailgun_PLaysound();
            SNR1 MNO 1 A_DoPBWeaponAction();
            TNT1 A 0 SuperNailgun_PLaysound();
            SNR1 MNO 2 A_DoPBWeaponAction();
            TNT1 A 0 SuperNailgun_PLaysound();
            SNR1 MNO 3 A_DoPBWeaponAction();
            TNT1 A 0 SuperNailgun_PLaysound();
            SNR1 MNO 4 A_DoPBWeaponAction();
            TNT1 A 0 SuperNailgun_PLaysound();
		    SNR1 MNO 5 A_DoPBWeaponAction();
            goto Ready3;

        CacheSprites:
            SNXL A 0; SNSU A 0;

        Deselect:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(39);
                A_StopSound(1);
                PBX_WeaponLower();
			}
			SNSE GECA 1 superNailgun_setSprite("SNSU");
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(67);
				A_ClearOverlays(OVERHEATCOOLING_LAYER,OVERHEATCOOLING_LAYER);
				cooldownOverheat();
                PBX_WeaponRaise("GENREADY");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            SNSE ACEG 1 superNailgun_setSprite("SNSU");
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 SuperNailgun_CheckSpin();
        ReadyToFire:
            TNT1 A 0 {invoker.mWeaponIsSpinning = false;}
			SNLR A 1 {
                if(PB_GetOverheat() > 1) {cooldownOverheat();}
                SuperNailgun_CoolDownBarrel();
			    PB_HandleCrosshair(67);
                superNailgun_setSprite("SNXL");
                return A_DoPBWeaponAction();
            }
            loop;

        Cooling:
			TNT1 A 8;
			TNT1 A 4 {
				PBXCore_Debug.Print("Lowered Overheat");
				PB_ModifyOverheat(OVERHEATCOOLING_RATE2);
			}
			Wait;

        CheckSpin:
            TNT1 A 0 SuperNailgun_CheckSpin();
            goto Ready3;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 PB_jumpIfNoAmmo("StopSpin",1,false);
            SNLR F 1 BRIGHT SuperNailgun_Fire();
            SNLR GHI 1 A_ZoomFactor(1);
            TNT1 A 0 PB_ReFire("Fire");
            TNT1 A 0 SuperNailgun_CheckSpin();
        StopSpin:
            TNT1 A 0 {invoker.mWeaponIsSpinning = false;}
            TNT1 A 0 A_JumpIf(PB_GetMagUnloaded(),"Ready3");
            SNLR CDECD 1 A_DoPBWeaponAction(WRF_ALLOWRELOAD);
            SNLR ECDE 2 A_DoPBWeaponAction(WRF_ALLOWRELOAD);
            goto Ready3;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 A_JumpIf(PB_GetMagUnloaded(),"Reload");
            TNT1 A 0 PB_jumpIfNoAmmo("StopSpin",1,false);
            TNT1 A 0 SuperNailgun_CheckSpin("StopSpin");
        SpinLoop:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
                A_AlertMonsters();
                invoker.mWeaponIsSpinning = true;
            }
            // This is the new AltFire
            SNLR GHI 1 A_DoPBWeaponAction();
            TNT1 A 0 SuperNailgun_PLaysound();
            TNT1 A 0 PB_ModifyOverheat(OVERHEAT_GIVE_NORM);
            TNT1 A 0 PB_ReFire("SpinLoop");
            goto CheckSpin;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
        Reload:
            TNT1 A 0 PB_CheckReload("ReloadUnloaded",null,null,"Ready3","Ready3",MAGAZINE_SIZE,invoker.ReserveToMagAmmoFactor);
            TNT1 A 0 A_ZoomFactor(1.0);
            TNT1 A 0 A_StartSound("IronSights", 30);
            SNRL ABCD 2 PB_SetRoll(roll-2);
            SNRL EF 2 PB_SetRoll(roll+2);
            TNT1 A 0 {
                A_FireCustomMissile("EmptyASGDrum",-5,0,8,-4);
                A_PlaysoundEx("weapons/shotgun/detach", "Auto");
                PB_SetMagUnloaded(true);
            }
            SNRL GH 2;
        ReloadUnloaded:
            SNRL IJKLM 2;
            SNRL NOP 2 PB_SetRoll(roll+2);
            TNT1 A 0 {
                A_PlaysoundEx("weapons/riflemagslap", "Auto");
                PB_AmmoIntoMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    MAGAZINE_SIZE,
                    invoker.ReserveToMagAmmoFactor
                );
                PB_SetChamberEmpty(false);
                PB_SetMagUnloaded(false);
                PB_SetMagEmpty(false);
            }
            SNRL QR 2;
            SNRL STUVWX 2 PB_SetRoll(roll-2);
            TNT1 A 0 PB_SetRoll(0);
            goto CheckSpin;
            
//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
            TNT1 A 0 A_ZoomFactor(1.0);
            TNT1 A 0 A_StartSound("IronSights", 30);
            SNRL ABCD 1 PB_SetRoll(roll-2);
            SNRL EF 1 PB_SetRoll(roll+2);
            TNT1 A 0 {
                A_PlaysoundEx("weapons/shotgun/detach", "Auto");
                PB_UnloadMag(
                    invoker.ammo2.getclassname(),
                    invoker.ammo1.getclassname(),
                    giveReserve:invoker.ReserveToMagAmmoFactor,
                    maxsize:MAGAZINE_SIZE,
                    spawnActor:"PBX_SuperNail_DroppedMag"
                );
                PB_SetChamberEmpty(true);
                PB_SetMagUnloaded(true);
                PB_SetMagEmpty(true);
                invoker.mWeaponIsSpinning = false;
            }
            SNRL GHI 1;
            goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 {
                A_TakeInventory("GoWeaponSpecialAbility", 1);
                invoker.mChargedNailsMode = !invoker.mChargedNailsMode;
                A_StartSound("MS/Button", 22);
                A_Print(invoker.mChargedNailsMode ? "$PBX_SuperNailgun_ChargedNails" : "$PBX_SuperNailgun_HeatedNails");
            }
            TNT1 A 0 SuperNailgun_CheckSpin();
        SwitchAnimation:
            SNSE GFED 1 superNailgun_setSprite("SNSU");
            "####" C 3;
            "####" DEFG 1;
            goto Ready3;

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        FlashPunching:
			TNT1 A 0 cooldownOverheat();
            SNSE GFEDCB 1 superNailgun_setSprite("SNSU");
            "####" AA 1;
            "####" BCDEFG 1;      // 14 frames
            goto CheckSpin;

        FlashKicking:
			TNT1 A 0 cooldownOverheat();
            SNSE GFEDCB 1 superNailgun_setSprite("SNSU");
            "####" AAA 1;
            "####" BCDEFG 1;      
            goto CheckSpin;        // 15 frames

        FlashAirKicking:
			TNT1 A 0 cooldownOverheat();
            SNSE GFEDCB 1 superNailgun_setSprite("SNSU");
            "####" A 4;
            "####" BCDEFG 1;      
            goto CheckSpin;        // 16 frames

        FlashSlideKicking:
			TNT1 A 0 cooldownOverheat();
            SNSE GFEDCB 1 superNailgun_setSprite("SNSU");
            "####" A 15;
            "####" BCDEFG 1;      
            goto CheckSpin; // 27 frames

        FlashSlideKickingStop:
			TNT1 A 0 cooldownOverheat();
            MSNK BCDEFGG 1;             // 7 frames
            goto CheckSpin;
    }
}