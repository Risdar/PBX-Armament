// Excavator 
// From Project Survival made by ThePopeOfDope

// Includes
#include "./Excavator_Functions.zs"
#include "./Excavator_Wheel.zs"
#include "./ExcavatorUpgraded.zs"

// Tokens
class EX_Select_DrillMode : inventory{default{inventory.maxamount 1;}}
class EX_Select_DropMode : inventory{default{inventory.maxamount 1;}}
class EX_Select_BolaMode : inventory{default{inventory.maxamount 1;}}
class EX_Select_SawMode : inventory{default{inventory.maxamount 1;}}
class EX_Select_No : inventory{default{inventory.maxamount 1;}}
class Excavator_Upgraded : inventory{default{inventory.maxamount 1;}}

class PBX_Excavator : PBX_WeaponBase
{
	Default
	{
        //$Title Excavator
        //$Category Weapons
        //$Sprite 5DUNA0
        ////SpawnID 9530;
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        PB_WeaponBase.UsesWheel true;
		PB_WeaponBase.WheelInfo "ExcavatorWheel";
		PB_WeaponBase.ReserveToMagAmmoFactor AMMO_TAKE_NORMAL;
        Inventory.AltHudIcon "5DUNA0";
		
//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
		Weapon.AmmoType1 "PB_RocketAmmo";
	    Weapon.AmmoType2 "ExcavatorRounds";
	    Weapon.AmmoGive1 10;
		
//////////////////////////// SPRITES & OFFSETS ////////////////////////////////////////////////////////////////////////////////////
        Weapon.BobRangeX 0.3;
        Weapon.BobRangeY 0.5;
        Weapon.BobStyle "InverseSmooth";
        Weapon.BobSpeed 2.4;
        Scale 0.50;
        FloatBobStrength 0.5;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Obituary "$OB_WEAP_EXCAVATOR";
        Inventory.PickupMessage "$PBX_Excavator_Pickup";
        Inventory.PickupSound "misc/ROCKBOXA";
	    Tag "$PBX_Excavator_Tag";
        
//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM
        +WEAPON.EXPLOSIVE
        +WEAPON.NOAUTOFIRE
        +FORCEXYBILLBOARD
        +FLOORCLIP
        +DONTGIB
	}
	
//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    bool isUpgraded;
    int excavatorMode;
    int burstCount; // used in the bola mode altfire
    const MAGAZINE_SIZE = 6;
    const AMMO_TAKE_NORMAL = 2;
    const AMMO_TAKE_SAW = 5;
    enum ExcMode
    {
        eNoUpgrade = -1,
        eCloseWheel,
        eDrillChargeMode, // Default Mode
        eDropShotMode,
        eBolaMode,
        eSawMode
    }
    
//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
	States
	{
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
		Spawn:
            5DUN A -1;
            Stop;
        Deselect:
            // TNT1 A 0 setExcavatorMode();
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"Deselect.Upgraded");
		    5DKF EFGHI 1;
        ActualDeselect:
			TNT1 AAA 0 A_lower();
			Wait;
		WeaponRespect:
            TNT1 A 0 {
				A_SetCrosshair(-1);
				A_PlaySoundEx("Ironsights", "Auto");
			}
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"WeaponRespect.Upgraded");
        WeaponRespect_Normal:
			5DKF IHGF 1 A_DoPBWeaponAction();
			5DKF E 15 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"WeaponRespect.UpgradedStart");
			6DKF A 1 A_PlaySound("Ironsights", 15);
            TNT1 A 0 PB_SetRoll(roll-0.6);
            6DKF BCDEF 1 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaySound("weapons/sgl/cycle", 14);
            //TNT1 A 0 A_FireCustomMissile("RocketCaseSpawn",-30,0,-4,-4);
            TNT1 A 0 PB_SetRoll(roll+0.6);
            6DKF GHIJK 1 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaySound("RLCYCLE2", 13);
            TNT1 A 0 PB_SetRoll(0);
            6DKF KKKKK 1 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaySound("weapons/minigun/respect1", 13);
            TNT1 A 0 PB_SetRoll(roll-0.5);
            6DKF LMNOPQRS 1 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaySound("weapons/nailgun/up", 10);
            TNT1 A 0 PB_SetRoll(roll-0.5);
            6DKF TUVWWWWW 1 A_DoPBWeaponAction();
            TNT1 A 0 PB_SetRoll(0);
            TNT1 A 0 A_PlaySound("Ironsights", 15);
            TNT1 A 0 PB_SetRoll(roll+1.0);
            6DKF XYZ 1 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaySound("weapons/sgl/inspect1", 15);
            7DKF A 1 A_DoPBWeaponAction();
            TNT1 A 0 PB_SetRoll(roll-1.0);
            7DKF BCD 1 A_DoPBWeaponAction();
            TNT1 A 0 PB_SetRoll(0);
            7DKF EFGHIJK 1 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaySound("excavator/detonate");
            5DKF CCDDCCDDCCDCDCD 1 A_DoPBWeaponAction();
			goto Ready3;
		Select:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"Select.Upgraded");
			TNT1 A 0 PBX_WeaponRaise("RLANDRAW");
			TNT1 A 0 PB_RespectIfNeeded();
		SelectAnimation:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"SelectAnimation.Upgraded");
		SelectAnimation_Normal:
			TNT1 A 0 A_JumpIf(pb_getmagunloaded(), "NoAmmo");
            5DKF IHGFE 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
		Ready3:
            TNT1 A 0 A_Jumpif(isExcavatorUpgraded(), "Ready2");
            TNT1 A 0 A_Jumpif(PB_GetMagUnloaded(), "NoAmmo");
        ReadyToFire:
            TNT1 A 0 A_Jumpif(isExcavatorUpgraded(), "WeaponRespect.Upgraded");
			5DKF A 1 {
                if(getExcavatorMode() == eDropShotMode)
                    A_SetWeaponFrame(1);
                PB_CoolDownBarrel();
                EX_HandleCrosshair();
                return A_DoPBWeaponAction(WRF_ALLOWRELOAD);
            }
			Loop;
            
		
//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
		Fire:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"Fire.Upgraded");
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			}
			TNT1 A 0 PB_JumpIfNoAmmo("Reload",1,false);
            6DKF A 1 BRIGHT FireWeapon();
			6DKF A 1 BRIGHT;
            5DKF L 1 BRIGHT A_ZoomFactor(0.97);
            5DKF M 1 BRIGHT A_ZoomFactor(0.98);
            5DKF N 1 BRIGHT A_ZoomFactor(0.99);
            TNT1 A 0 A_ZoomFactor(1.0);
            5DKF OPQRDDD 1 A_WeaponReady(WRF_NOPRIMARY);
            TNT1 A 0 A_PlaySound("RLCYCLE2", 5);
            5DKF DDDD 1 A_WeaponReady(WRF_NOPRIMARY);
            5DKF D 0 PB_ReFire();
			Goto Ready3;
		
//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
		Reload:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"Reload.Upgraded");
        Reload_Normal:
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null, null, "Ready3", "Ready3", MAGAZINE_SIZE, invoker.ReserveToMagAmmoFactor);
			6DKF A 1 A_PlaySound("Ironsights", 15);
            TNT1 A 0 PB_SetRoll(roll-0.6);
            6DKF BCDEF 1 ;
            TNT1 A 0 A_PlaySound("weapons/sgl/cycle", 14);
            TNT1 A 0 {
                PB_SpawnCasing("SGL_Drum",25,0,20,Frandom(3,4),Frandom(3,4),1);
                PB_SetMagUnloaded(true);
                PB_SetChamberEmpty(true);
                PB_SetMagEmpty(true);
            }
            //TNT1 A 0 A_FireCustomMissile("RocketCaseSpawn",-30,0,-4,-4);
            TNT1 A 0 PB_SetRoll(roll+0.6);
            6DKF GHIJK 1 ;
            TNT1 A 0 A_PlaySound("RLCYCLE2", 13);
            TNT1 A 0 PB_SetRoll(0);
            6DKF KKKKK 1 ;
            TNT1 A 0 A_PlaySound("weapons/minigun/respect1", 13);
            TNT1 A 0 PB_SetRoll(roll-0.5);
        ContinueReload:
            6DKF LMNOPQRS 1 ;
            TNT1 A 0 A_PlaySound("weapons/nailgun/up", 10);
            TNT1 A 0 PB_SetRoll(roll-0.5);
            6DKF TUVWWWWW 1 ;
            TNT1 A 0 PB_SetRoll(0);
            TNT1 A 0 A_PlaySound("Ironsights", 15);
            TNT1 A 0 PB_SetRoll(roll+1.0);
            6DKF XYZ 1 ;
            TNT1 A 0 A_PlaySound("weapons/sgl/inspect1", 15);
            7DKF A 1 ;
            TNT1 A 0 {
                PB_AmmoIntoMag(invoker.ammo2.getclassname(), invoker.ammo1.getclassname(), MAGAZINE_SIZE, invoker.ReserveToMagAmmoFactor);
                PB_SetMagUnloaded(false);
                PB_SetChamberEmpty(false);
                PB_SetMagEmpty(false);
            }
            TNT1 A 0 PB_SetRoll(roll-1.0);
            7DKF BCD 1 ;
            TNT1 A 0 PB_SetRoll(0);
            7DKF EFGHIJK 1 ;
            TNT1 A 0 A_PlaySound("excavator/detonate");
            5DKF CCDDCCDDCCDCDCD 1 ;
            TNT1 A 0 PB_SetReloading(false);
            Goto Ready3;

        RaiseFromEmpty:
            8DKF DCBA 1;
            goto ContinueReload;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
		Unload:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"Unload.Upgraded");
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"NoAmmo");
			6DKF A 1 A_PlaySound("Ironsights", 15);
            TNT1 A 0 PB_SetRoll(roll-0.6);
            6DKF BCDEF 1;
            TNT1 A 0 A_PlaySound("weapons/sgl/cycle", 14);
            //TNT1 A 0 A_FireCustomMissile("RocketCaseSpawn",-30,0,-4,-4);
            TNT1 A 0 PB_SetRoll(roll+0.6);
            6DKF GHI 1;
		    6DKF J 1;
			TNT1 A 0 {
				PB_UnloadMag(invoker.ammotype2, invoker.ammotype1, 2, 1, 0, 0, "PB_SGLAmmo");
				PB_SetMagUnloaded(true);
				PB_SetMagEmpty(true);
                PB_SetChamberEmpty(true);
			}
            6DKF K 1;
            8DKF ABCD 1;
            TNT1 A 0 PB_SetReloading(false);
            goto NoAmmo;

        NoAmmo:
            5DKF S 1 A_DoPBWeaponAction(WRF_ALLOWRELOAD);
		    Loop;
		
//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
		Weaponspecial:
            TNT1 A 0 handleSpecial();
        SwitchAnimation:
            7DKF LMNOP 1;
            TNT1 A 0 A_PlaySound("excavator/switch");		
            7DKF PONML 1;
            Goto Ready3;
		
//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
		FlashPunching:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"FlashPunching.Upgraded");
            7DKF L 1;
            7DKF MNOP 1;
            7DKF P 4;
            7DKF PONML 1;
			goto Ready3;

        FlashKicking:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"FlashKicking.Upgraded");
			5DKF E 1;
            5DKF FGHI 1 ;
            TNT1 A 4;
            5DKF IHGFE 1; //15 frames
			goto Ready3;
			
		FlashAirKicking:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"FlashAirKicking.Upgraded");
            5DKF E 1;
            5DKF FGHI 1;
            TNT1 A 8;
            5DKF IHGFE 1; //16 frames
			goto Ready3;
			
		FlashSlideKicking:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"FlashSlideKicking.Upgraded");
            5DKF E 1;
            5DKF EFGHI 1;
            TNT1 A 16; //27 frames
			goto Ready3;
			
		FlashSlideKickingStop:
            TNT1 A 0 A_JumpIf(isExcavatorUpgraded(),"FlashSlideKickingStop.Upgraded");
			5DKF I 1;
		    5DKF IIHGFE 1; //7 frames 
			goto Ready3;
	}
}