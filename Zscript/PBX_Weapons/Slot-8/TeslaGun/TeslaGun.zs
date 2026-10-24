// Tesla Gun 
// From Schism by Lord_Lothar and the Schism Team
// Base Sprites is by IAmCarrotMaster
// Hands is from Brutal Doom by Sergeant_Mark_IV (need to know who actually made the hand sprites)
// Animations by ikdfa
// New pickup sprites by agus4578

// Includes
#include "./TeslaGun_Functions.zs"

// class Detonate_Lightning_Ball : inventory {default{inventory.maxamount PBX_TeslaGun.LIGHTBALL_CHARGE;}}

// Actual Weapon
class PBX_TeslaGun : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
	    Inventory.AltHUDIcon "ETROA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_Cell";
        Weapon.AmmoType2 "TeslaAmmo";
        Weapon.AmmoGive1 50;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_TeslaGun_Pickup";
        Inventory.PickupSound "PLSDRAW";
        Obituary "$OB_WEAP_TESLAGUN";
        AttackSound "None";
        Tag "$PBX_TeslaGun_Tag";
        Scale 1.0;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    bool mLightShockMode;
    int mTeslaAnimCounter; // Used for the altfire animation

    const CELL_SIZE = 100;
    const ARCFIRE_DAMAGE = 15;

    const LIGHTBALL_AMMO_TAKE = 25;
    const DECHARGE_GIVE = 5; // MAKE SURE THIS VALUE CAN CLEANLY DIVIDE THE ALTFIRE AMMO TAKES
    const DECHARGE_LOOP = LIGHTBALL_AMMO_TAKE/DECHARGE_GIVE;
    const DECHARGE_LOOP_SHOCK = LIGHTSTORM_AMMO_TAKE/DECHARGE_GIVE;

    const LIGHTSTORM_AMMO_TAKE = 50;
    const LIGHTSHOCK_AMMO_TAKE = 2;
    const LIGHTSHOCK_DAMAGE = 25;
    const LIGHTSHOCK_TARGET = 10; // How many beams it'll fire
    const LIGHTSHOCK_RANGE = 50;

    const LIGHTNING_RANGE = 1024; // How long is the normal fire length
    const LIGHTBALL_DAMAGE = 200; // How much damage does the lightball do per bounce
    const LIGHTBALL_LIGHTNING_DAMAGE = 20; // How much damage does the lightball do per arc
    const LIGHTBALL_MAXCHARGE = 20; // How much charges does the lightball need before summoning lightning
    const LIGHTBALL_LIFETIME = 15; // How long should the lightball stay in flight
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            ETRO A -1;
            Stop;

        WeaponRespect:
            ETRG A 1 offset(-20, 46) A_DoPBWeaponAction();
			ETRG A 1 offset(-12, 42) A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/plasma/startup", 16,CHANF_OVERLAP);
			ETRG A 1 offset(-4, 38) A_DoPBWeaponAction();
			ETRG AAAAAAAAAAAAAA 1 A_DoPBWeaponAction();
            ET1R ABC 2 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("PLSCOOL",CHAN_WEAPON);
			ETRR K 15 A_DoPBWeaponAction();
            TNT1 A 0 {
                // A_FireProjectile("PlasmaFlareSpawner",0,0,-20,0);
				// A_FireProjectile("BlueFlareSpawn",0,0,-20,0);
                A_StartSound("BEPBEP",CHAN_WEAPON);
                return A_DoPBWeaponAction();
            }
            TNT1 A 0 A_StartSound("weapons/plasma/cellin",17,CHANF_OVERLAP);
			ETRR LMNOP 2 A_DoPBWeaponAction();
            TNT1 A 0 {
                A_StartSound("PLSCOOL",CHAN_WEAPON,CHANF_OVERLAP);
                // A_FireProjectile("BluePlasmaParticle",random(340,350),0,6,0,0,-random(7,18));
                A_FireProjectile("SmokeSpawner",0,0,0,5);
                return A_DoPBWeaponAction();
            }
			ETRR EDCBA 2 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("ULTCHAR",CHAN_WEAPON,CHANF_OVERLAP);
            Goto Ready3;

        WeaponInspect:
            TNT1 A 0 A_StartSound("BEP", 16,CHANF_OVERLAP);
            ETRR AABBCCDD 1 A_DoPBWeaponAction();
            ETRR EEEEEEEEE 1 A_DoPBWeaponAction();
        HoldInspect:
            ETRR E 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            TNT1 A 0 {
                A_StartSound("PLSCOOL",CHAN_WEAPON,CHANF_OVERLAP);
                // A_FireProjectile("PlasmaFlareSpawner",0,0,-15,3);
                A_FireProjectile("SmokeSpawner",0,0,0,5);
                return A_DoPBWeaponAction();
            }
			ETRR EDCBA 2 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("BEPBEP", 16,CHANF_OVERLAP);
            Goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
			ETRG A 1 offset(-4,38);
			ETRG A 1 offset(-12,42);
			ETRG A 1 offset(-20,46);
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(18);
                PBX_WeaponRaise("PLSDRAW");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            ETRG A 1 offset(-20, 46);
			ETRG A 1 offset(-12, 42);
			ETRG A 1 offset(-4, 38);
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 PBX_CheckInspect();
			ETRG A 1 {
                A_ClearReFire();
                PB_HandleCrosshair(18);
                return A_DoPBWeaponAction();
            }
            loop;

        CoolDown:
            ETRG ABCDEF 1;
            TNT1 A 0 A_StartSound("BEPBEP",CHAN_WEAPON,CHANF_OVERLAP);
            ETRG G 15 {
                A_StartSound("PLSCOOL",CHAN_VOICE);
                A_FireProjectile("PlasmaFlareSpawner",0,0,10,5);
				A_FireProjectile("BlueFlareSpawn",0,0,10,5);
                A_FireProjectile("BluePlasmaParticle",random(340,350),0,6,0,0,-random(7,18));
                A_FireProjectile("SmokeSpawner",0,0,0,5);
            }
            ETRG EDCBA 1;
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty(),"Ready3");
			Goto Ready3;

        Decharge:
			PLSN A 0 A_StopSound(CHAN_6);
            PLSN A 0 A_StartSound("PLSDEARG",1);
            PLSN A 0 {invoker.mTeslaAnimCounter = 0;}
        DechargeLoop:
            ETRF A 1 BRIGHT Tesla_DechargeAnim();
            TNT1 A 0 A_PlaySound("BEPBEP",CHAN_5, 1.2);
            TNT1 A 0 A_ClearReFire();
			Goto Ready3;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 PB_jumpIfNoAmmo(min:Tesla_GetMinAmmo(),chamber:false,emptysound:"BEP");
			TNT1 A 0 A_StartSound("ULTCHAR",CHAN_WEAPON,CHANF_OVERLAP);
			ETRF ABCB 1 BRIGHT A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
			ETRF CBE 1 BRIGHT A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
			ETRF BD 1 BRIGHT A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
		Hold:
            TNT1 A 0 PB_jumpIfNoAmmo(min:Tesla_GetMinAmmo(),chamber:false,emptysound:"BEP");
			ETRF D 1 BRIGHT;
            ETRF F 1 BRIGHT Tesla_FirePrimary(); // This also randomizes the frames
            TNT1 A 0 PB_ReFire("Hold");
            // TNT1 A 0 {
            //     if(invoker.mLightShockMode)
            //         PB_ReFire("Fire");
            //     else
            //         PB_ReFire("Hold");
            // }
            TNT1 A 0 A_StartSound("LGEnd1",CHAN_WEAPON);
			ETRF ABC 1 BRIGHT;
			ETRF ABCB 1 BRIGHT A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
			Goto CoolDown;

//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 PB_jumpIfNoAmmo(min:Tesla_GetMinAmmo(isAlt:true),chamber:false,emptysound:"BEP");
			TNT1 A 0 {
                PB_HandleCrosshair(90);
			    if(invoker.mLightShockMode) A_StartSound("CYBRLZR",CHAN_6,CHANF_OVERLAP);
			    A_StartSound("ULTCHAR",CHAN_AUTO,CHANF_OVERLAP);
                invoker.mTeslaAnimCounter = 0;
            }
        AltFireAnimation:
			ETRF A 1 BRIGHT Tesla_AltFireAnim();
        AltHold:
			ETRF A 0 A_StartSound("PLSFULL",1,CHANF_LOOPING);
			ETRF F 1 BRIGHT offset (0, 32) Tesla_CheckDecharge();
			ETRF G 1 BRIGHT offset (0, 33) Tesla_CheckDecharge();
			ETRF H 1 BRIGHT offset (1, 32) Tesla_CheckDecharge();
			ETRF F 1 BRIGHT offset (-1, 32) Tesla_CheckDecharge();
			PLSN A 0 PB_ReFire();
        ActualAltFire:
			ETRF A 0 A_ZoomFactor(0.9);
			ETRF EFF 2 BRIGHT A_Recoil3D(10);
			TNT1 A 0 {
                if(invoker.mLightShockMode)
                {
                    return resolvestate("FireLightning");
                }
                else
                {
                    Tesla_FireLightningBall();
                    return resolvestate(null);
                }
            }
			Goto CoolDown;

        FireLightning:
			ETRF A 0 A_StopSound(CHAN_6);
            TNT1 A 0 A_StartSound("PLSULT", CHAN_WEAPON);
			ETRF A 0 A_ZoomFactor(0.9);
			ETRF IJ 2 BRIGHT;
			TNT1 A 0 {
                Tesla_FireLightningStorm();
                A_FlashOverlay();
            }
			ETRF KL 2 BRIGHT;
			ETRF A 0 A_StopSound(CHAN_6);
			ETRF A 0 A_ZoomFactor(1.0);
			ETRF EBCDBCACABAA 1 BRIGHT;
			Goto CoolDown;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
        Reload:
            TNT1 A 0 A_StopSound(CHAN_WEAPON);
            TNT1 A 0 A_StopSound(CHAN_6);
			TNT1 A 0 A_ClearReFire();
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null,null,"Ready3","Ready3",CELL_SIZE);
            TNT1 A 0 A_PlaySound("IronSights", CHAN_WEAPON);
            TNT1 A 0 A_ZoomFactor(1.0);
            ETRR AABBCCDDEFGHHHIJ 1;
            TNT1 A 0 {
                A_StartSound("weapons/plasma/cellout",CHAN_WEAPON,CHANF_OVERLAP);
                if(PB_GetMagEmpty())
					PB_SpawnCasing("EmptyCell",29,random(10,12),20,0,random(-4,-2),2);
                PB_SetMagUnloaded(true);
                PB_SetChamberEmpty(true);
            }
        ContinueReload:
			ETRR K 10;
			ETRR LMNOP 2;
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
			ETRR EDCBA 2;
            TNT1 A 0 A_StartSound("BEPBEP", CHAN_WEAPON);
            Goto Ready3;
        
        RaiseFromEmpty:
            ET1R ABC 2;
            Goto ContinueReload;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
            TNT1 A 0 A_StartSound("IronSights", CHAN_WEAPON,CHANF_OVERLAP);
            TNT1 A 0 A_ZoomFactor(1.0);
            ETRR AABBCCDDEFGHHHIJ 1;
            TNT1 A 0 {
                A_StartSound("weapons/plasma/cellout",CHAN_WEAPON,CHANF_OVERLAP);
				PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname());
                PB_SetMagEmpty(true);
				PB_SetMagUnloaded(true);
				PB_SetChamberEmpty(true);
			}
			ETRR K 12;
            ET1R CBA 2;
            goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 {
                A_TakeInventory("GoWeaponSpecialAbility", 1);
                invoker.mLightShockMode = !invoker.mLightShockMode;
                A_Print(invoker.mLightShockMode ? "$PBX_TeslaGun_Shock" : "$PBX_TeslaGun_Arc");
            }
        SwitchAnimation:
            ETRG A 1 offset(-4,38);
			ETRG A 1 offset(-12,42);
			ETRG A 1 offset(-20,46);
            TNT1 A 0 A_StartSound("BEPBEP",CHAN_WEAPON,CHANF_OVERLAP);
            ETRG A 1 offset(-20, 46);
			ETRG A 1 offset(-12, 42);
			ETRG A 1 offset(-4, 38);
            goto Ready3;

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        MuzzleFlash:
			P1SF D 1 BRIGHT {A_SetWeaponFrame(3 + random[sfx](0, 2)); A_GunFlash();}
			P1SF G 1 BRIGHT {A_SetWeaponFrame(6 + random[sfx](0, 2)); A_GunFlash();}
            stop;

        FlashPunching:
            ETRG ABCDEFFFFEDCBA 1;      // 14 frames
            goto Ready3;

        FlashKicking:
            ETRG ABCDEFFFFFEDCBA 1;     // 15 frames
            goto Ready3;

        FlashAirKicking:
            ETRG ABCDEFFFFFFEDCBA 1;    // 16 frames
            goto Ready3;

        FlashSlideKicking:
            ETRG ABCDE 1;
            ETRG F 17;
            ETRG EDCBA 1; // 27 frames
            goto Ready3;

        FlashSlideKickingStop:
            ETRG FFEDCBA 1;             // 7 frames
            goto Ready3;
    }
}