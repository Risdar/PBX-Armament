// Plasma Blaster 
// From Project Survival made by ThePopeOfDope
// Idle sprite from Siren, new sprites made by ThePopeOfDope

// Includes
#include "./LeverAction_Functions.zs"
#include "./LeverAction_Wheel.zs"

class LA_Select_No : inventory {default{inventory.maxamount 1;}}
class LA_Select_Marlin : inventory {default{inventory.maxamount 1;}}
class LA_Select_Magnum : inventory {default{inventory.maxamount 1;}}
class LA_Upgraded : inventory {default{inventory.maxamount 1;}}

class PBX_Prosurv_LeverAction : PBX_WeaponBase
{
	Default
	{
        //$Title Lever Action
        //$Category Weapons
        //$Sprite LVR4E0
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        PB_WeaponBase.UsesWheel true;
		PB_WeaponBase.ReserveToMagAmmoFactor AMMO_TAKE_MAGNUM;
		PB_WeaponBase.WheelInfo "LeverActionWheel";
        Inventory.AltHudIcon "LVR4E0";
		
//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
		Weapon.AmmoType1 "PB_LowCalMag";
		Weapon.AmmoType2 "LeverActionAmmo";
	    Weapon.AmmoGive1 24;
		
//////////////////////////// SPRITES & OFFSETS ////////////////////////////////////////////////////////////////////////////////////
        Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.5;
		// Weapon.BobStyle InverseSmooth;
		Weapon.BobSpeed 2.4;
        Scale 0.4;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
		Obituary "$OB_WEAP_LEVERACTION";
		Inventory.PickupMessage "$PBX_LeverAction_Pickup";
		Inventory.PickupSound "weapons/leveraction/rechamber";
	    Tag "$PBX_LeverAction_Tag";
        
//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM
		+WEAPON.NOALERT
		+WEAPON.NOAUTOAIM
        +FORCEXYBILLBOARD
        +FLOORCLIP
        +DONTGIB
	}
	
//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
	int currentMaxAmmo;
	int LAMode;
	bool laserActive;
	const MAGAZINE_SIZE = 12; // mag size for marlin is half of this
	const AMMO_TAKE_MAGNUM = 2;
	const AMMO_TAKE_MARLIN = 4;
	enum eLAMode
	{
		LA_444Marlin,
		LA_357Magnum
	}
    
//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
	States
	{
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
		Spawn:
            LVR4 E -1;
            Stop;
        Deselect:
            TNT1 A 0 PBX_WeaponLower();
			LVRA BCDE 1;
			TNT1 AAA 0 A_lower();
			Wait;
		WeaponRespect:
			TNT1 A 0 {
                A_SetCrosshair(-1);
			}
			TNT1 AAAAAA 1 {
				PB_SetRoll(roll-0.3);
                return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/leveraction/inspect",CHAN_WEAPON,CHANF_OVERLAP);
			LVRA ZYXWV 1 {
				PB_SetRoll(roll+0.3);
                return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/leveraction/flip");
			LVR4 F 1 {
				PB_SetRoll(roll+0.3);
                return A_DoPBWeaponAction();
			}
			LVRA FGIKM 1 {
				PB_SetRoll(roll+0.3);
                return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/leveraction/rechamber");
			LVRA NNNNNOPQR 1 {
				PB_SetRoll(roll-0.3);
                return A_DoPBWeaponAction();
			}
			LVRA SUT 1 {
				PB_SetRoll(roll-0.3);
                return A_DoPBWeaponAction();
			}
			LVR4 G 1 {
				PB_SetRoll(roll-0.3);
                return A_DoPBWeaponAction();
			}
			LVRA AA 1 {
				PB_SetRoll(roll-0.3);
                return A_DoPBWeaponAction();
			}
			LVR2 MNOP 1 {
				PB_SetRoll(roll+1.0);
                return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/leveraction/openchamber");
			LVR2 QQ 1 {
				PB_SetRoll(roll-2.0);
                return A_DoPBWeaponAction();
			}
			LVR2 RSTUVVVV 1 {
				PB_SetRoll(roll+1.0);
                return A_DoPBWeaponAction();
			}
			LVR2 V 3 A_DoPBWeaponAction();
			LVR3 AB 1 A_DoPBWeaponAction();
			LVR3 C 1 { 
				A_StartSound("insertshell");
				PB_RotateCamera(addAngle:0.2,addPitch:-0.2,addRoll:-0.4);
                return A_DoPBWeaponAction();
			}
			LVR3 D 1 {
				PB_RotateCamera(addAngle:-0.2,addPitch:0.2,addRoll:0.4);
                return A_DoPBWeaponAction();
			}
			LVR3 EFG 1 A_DoPBWeaponAction();
			LVR2 V 5 A_DoPBWeaponAction();
			LVR2 VUTSRQ 1 {
				PB_SetRoll(roll-1.0);
                return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/leveraction/closechamber");
			LVR2 PONM 1 {
				PB_SetRoll(roll+1.0);
                return A_DoPBWeaponAction();
			}
			LVRA AA 1 {
				PB_SetRoll(roll+1.0);
                return A_DoPBWeaponAction();
			}
			Goto Ready3;

		WeaponInspect:
			TNT1 A 0 PB_HandleCrosshair(76);
			TNT1 A 0 A_StartSound("weapons/leveraction/inspect",CHAN_WEAPON,CHANF_OVERLAP);
			TNT1 A 0 A_Jump(128,"Inspect2");
		Inspect1:
			TNT1 A 0 A_StartSound("weapons/leveraction/flip");
			LVR4 F 1 {
				PB_SetRoll(roll+0.3);
                return A_DoPBWeaponAction();
			}
			LVRA FGIKM 1 {
				PB_SetRoll(roll+0.3);
                return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/leveraction/rechamber");
			LVRA NNNNNOPQR 1 {
				PB_SetRoll(roll-0.3);
                return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_PressingReload("Inspect1");
			LVRA SUT 1 {
				PB_SetRoll(roll-0.3);
                return A_DoPBWeaponAction();
			}
			LVR4 G 1 {
				PB_SetRoll(roll-0.3);
                return A_DoPBWeaponAction();
			}
			LVRA AA 1 {
				PB_SetRoll(roll-0.3);
                return A_DoPBWeaponAction();
			}
			Goto Ready3;

		Inspect2:
			LVR2 MNOP 1 A_DoPBWeaponAction();
			LVR2 QQQQQQQQQQQQQQ 1 A_DoPBWeaponAction();
		Inspect2Hold:
			LVR2 Q 1 A_DoPBWeaponAction();
			TNT1 A 0 A_PressingReload("Inspect2Hold");
			LVR2 PONM 1 A_DoPBWeaponAction();
			Goto Ready3;

		Select:
			TNT1 A 0 PBX_WeaponRaise("weapons/leveraction/inspect");
			TNT1 A 0 PB_RespectIfNeeded();
		SelectContinue:
			TNT1 A 0;
		SelectAnimation:
			TNT1 A 0 A_JumpIf(pb_getmagunloaded(), "NoAmmo");
            LVRA EDCB 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
		Ready3:
			TNT1 A 0 {
				A_SetInventory("CantDoAction", 0);
			}
			TNT1 A 0 A_jumpif(PB_GetZoom(),"Ready2");
        ReadytoFire:
			TNT1 A 0 PBX_CheckInspect();
			LVRA A 1 {
				PB_CoolDownBarrel();
				PB_HandleCrosshair(76);
                return PB_ReadyFire();
			} 
			Loop;
            
		Ready2:
			TNT1 A 0 {
				PB_SetRoll(0);
				A_SetInventory("CantDoAction", 0);
			}
		ReadytoFire2:
			LVR3 Q 1 {
                A_SetCrosshair(-1);
				PB_CoolDownBarrel();
				return PB_ReadyFire(ads:true);
			}
			Loop;
//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
		Fire:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(76);
			}
			TNT1 A 0 A_jumpif(PB_GetZoom(),"Fire2");
		Fire1Actual:
            TNT1 A 0 PB_JumpIfNoAmmo();
			// TNT1 A 0 A_JumpIf(pb_getchamberempty(), "Pump");
            LVR2 F 1 BRIGHT LA_FireWeapon(1);
			LVR2 G 1 BRIGHT LA_FireWeapon(2);
			LVR2 H 1 		LA_FireWeapon(3);
			LVR2 IJKL 1; 
			LVRA A 1; 
		Pump:
			TNT1 A 0 {
				A_StartSound("weapons/leveraction/flip",CHAN_WEAPON,CHANF_OVERLAP);
				A_ZoomFactor(1.0);
				PB_SetZoom(false);
				A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
			}
			LVR4 F 1 PB_SetRoll(roll+0.3);
		PumpBegin:
			LVRA FGHIJKLM 1 PB_SetRoll(roll+0.3);
			TNT1 A 0 {
				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
			}
			LVRA NNNNNOPQR 1 ;
			TNT1 A 0 PB_SpawnCasing("EmptyBrassPistol");
		PumpEnd:
			LVRA SUT 1 PB_SetRoll(roll-0.3);
			LVR4 G 1 PB_SetRoll(roll-0.3);
			LVRA AA 1 PB_SetRoll(roll-0.3);
			TNT1 A 0 {
				A_SetInventory("CantDoAction",0);
				PB_SetReloading(false);
				PB_Refire();
			}
			Goto Ready3;

		Fire2:
			TNT1 A 0 {
				PB_SetRoll(0);
				A_SetCrosshair(-1);
			}
		Fire2Actual:
            TNT1 A 0 PB_JumpIfNoAmmo();
			// TNT1 A 0 A_JumpIf(pb_getchamberempty(), "Pump");
			LVR3 R 1 BRIGHT LA_FireWeapon(1);
			LVR3 S 1 BRIGHT LA_FireWeapon(2);
			LVR3 TU 1;
			LVR3 VWX 1; 
		Pump2:
			TNT1 A 0 {
				A_ZoomFactor(1.25);
			}
			TNT1 A 0 {
				A_StartSound("weapons/leveraction/rechamber");
				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
			} 
			LVR4 ABCD 1;
			TNT1 A 0 PB_SpawnCasing("EmptyBrassPistol");
			LVR4 DDDDC 1;
			LVR4 BA 1 {
				if(JustPressed(BT_ATTACK) && invoker.ammo2.amount > 0) return ResolveState("Fire2");
                return ResolveState(null);
			}
			LVR3 QQ 1 {
				if(JustPressed(BT_ATTACK) && invoker.ammo2.amount > 0) return ResolveState("Fire2");
                return ResolveState(null);
			}
			TNT1 A 0 {
				A_SetInventory("CantDoAction",0);
				return PB_ReadyFire(ads:true);
			}
			// TNT1 A 0 PB_JumpIfNoAmmo();
			Goto Ready2;

		AltFire:
			TNT1 A 0 A_Jumpif(PB_GetZoom(),"ZoomOut");
		ZoomIn:
			TNT1 A 0 {
				A_StartSound("IronSights");
				A_ZoomFactor(1.25);
				A_SetCrosshair(-1);
				PB_SetZoom(true);
			}
			LVR3 MNOP 1;
			Goto Ready2;
		Zoomout:
			TNT1 A 0 PB_SetZoom(false);
			TNT1 A 0 A_startsound("IronSights");
			TNT1 A 0 A_ZoomFactor(1.0);
			LVR3 PONM 1;
			Goto Ready3;
//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
		ReloadFromADS:
			TNT1 A 0 PB_HandleCrosshair(76);
			TNT1 A 0 PB_SetZoom(false);
			TNT1 A 0 A_startsound("IronSights");
			LVR3 PONM 1;
		Reload:
			TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
			TNT1 A 0 {
				A_ZoomFactor(1.0);
				A_WeaponOffset(0,32);
			}
			TNT1 A 0 A_StartSound("weapons/leveraction/inspect");
			LVR2 MNOP 1 PB_SetRoll(roll+1.0);
            TNT1 A 0 PB_CheckReload( null, null, "Pump", "Ready3", "Ready3", invoker.currentMaxAmmo);
			TNT1 A 0 A_StartSound("weapons/leveraction/openchamber");
			LVR2 QQ 1 PB_SetRoll(roll-2.0);
			LVR2 RSTUVV 1 PB_SetRoll(roll-0.6);
		ReloadLoop:
			TNT1 A 0 A_JumpIf(invoker.ammo1.amount == 0 || invoker.ammo2.amount == invoker.currentMaxAmmo,"ReloadFinished");
			LVR2 V 2 A_DoPBWeaponAction(WRF_NOBOB);
			LVR3 AB 1 A_DoPBWeaponAction(WRF_NOBOB);
			LVR3 C 1 { 
				A_StartSound("weapons/leveraction/loadshell");
				A_Giveinventory(invoker.ammotype2,1);
				A_Takeinventory(invoker.ammotype1,invoker.ReserveToMagAmmoFactor,TIF_NOTAKEINFINITE);
				// PB_SetMagUnloaded(false);
				PB_SetMagEmpty(false);
				PB_RotateCamera(addAngle:0.2,addPitch:-0.2,addRoll:-0.4);
				if(pb_getchamberempty()) {PB_Setchamberempty(false);}
				return A_DoPBWeaponAction(WRF_NOBOB);
			}
			LVR3 D 1 {
				PB_RotateCamera(addAngle:-0.2,addPitch:0.2,addRoll:0.4);
				return A_DoPBWeaponAction(WRF_NOBOB);
			}
			LVR3 EFG 1 A_DoPBWeaponAction(WRF_NOBOB);
			LVR2 V 1 A_DoPBWeaponAction(WRF_NOBOB);
			loop;

		ReloadFinished:
			LVR2 VVVV 1 ;
			LVR2 VUTSRQ 1 PB_SetRoll(roll+0.6);
			TNT1 A 0 A_StartSound("weapons/leveraction/closechamber");
			LVR2 PONM 1 ;
			TNT1 A 0 PB_SetReloading(false);
			Goto Ready3;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
		Unload:
			TNT1 A 0 A_JumpIf(PB_GetMagEmpty(),"Ready3");
			TNT1 A 0 {
				A_StartSound("weapons/leveraction/inspect");
				A_ZoomFactor(1.0);
			}
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty(),"Ready3");
			LVR2 MNOPQ 1;
		RemoveBullets:
            TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"FinishUnload");
			TNT1 A 0 {
				name mToUnload = getLAMode() == LA_444Marlin ? "PBX_MarlinRound" : "PBX_MagnumRound";
				PB_UnloadMag(
					invoker.ammotype2,
					invoker.ammotype1,
					invoker.ReserveToMagAmmoFactor,1,
					invoker.ReserveToMagAmmoFactor,
					invoker.ammo2.amount - 1,
					mToUnload
				);
				A_StartSound("weapons/leveraction/rechamber");
			}
			LVR2 POPQQQQ 1 A_DoPBWeaponAction();
			Goto RemoveBullets;
		FinishUnload:
			TNT1 A 0 {
				PB_SetMagEmpty(true);
				PB_SetChamberEmpty(true);
				PB_SetReloading(false);
				return PB_HandleWheel(); // Actual Mode Change is handled here
			}
			LVR2 QPONM 1;
			Goto Ready3;
//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
		Weaponspecial:
			TNT1 A 0 PB_PreHandleLAWheel();
			goto Ready3;

		WeaponSwitch:
			LVRA VWXYZZ 1;
			LVRA ZZYXWV 1;
			goto Ready3;
		
//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
		FlashPunching:
			LVRA VWXYZZZ 1;
			LVRA ZZZYXWV 1; //14 frames
			goto Ready3;

        FlashKicking:
			LVR2 ABCDE 1;
			LVR2 E 4;
			LVR2 EDCBA 1;
			LVRA A 1; //15 frames
			goto Ready3;
			
		FlashAirKicking:
            LVR2 ABCDE 1;
			LVR2 E 5;
			LVR2 EDCBA 1;
			LVRA A 1; //16 frames
			goto Ready3;
			
		FlashSlideKicking:
            LVRA VWXYZZZZZZZZZZZZZZZZZZ 1; //27 frames
			goto Ready3;
			
		FlashSlideKickingStop:
			LVRA ZYXWVAA 1; //7 frames 
			goto Ready3;
	}
}