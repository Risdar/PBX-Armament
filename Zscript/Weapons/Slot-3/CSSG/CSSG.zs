// Commander's SuperShotgun 
// Original by Barge, Popguy, WolVexus, and Jaih1r0
// New sprites made by SamuelGuy
// Ice upgrade pickup sprite is made by SchrödingCat, Eriance/Amuscaria, Realm667
// Ice projectiles is from PBWP's Marauder Shotgun Freeze Shells made by JhulkerCraft
// HellFire and Acid Sprites is made by Waik (_wkn)
// HellFire shells firing sounds is from D-Tech Weapons Pack, specifically from DOOM 2016/DOOM Eternal by ID Software

// Includes
#include "./CSSG_Functions.zs"
#include "./CSSG_Wheel.zs"
#include "./CSSG_helpers.zs"

Class PBX_CSSG : PBX_WeaponBase
{
	default
	{
		Inventory.PickupMessage "$PBX_CSSG_PICKUP";
		Inventory.PickupSound "COMSSGUP";
		Inventory.AltHUDIcon "SG43A0";
		Obituary "$OB_WEAP_CSSG";
		Tag "$PBX_CSSG_TAG";
		PB_WeaponBase.OffsetRecoilX 5;
		PB_WeaponBase.OffsetRecoilY 4;
		scale 0.5;
		weapon.ammotype2 "CSSGShellsIn";
		weapon.ammotype1 "PB_Shell";
		weapon.ammogive1 4;
		PB_WeaponBase.UsesWheel true;
		PB_WeaponBase.WheelInfo "CSSGWeaponWheelPage1";
		PB_WeaponBase.ReserveToMagAmmoFactor 1;
	}
	
	int shellsmode;
	int oldshells;
	int hookCooldown;

	bool meathookMode;

	bool mWheelPage2;

	const BARREL_CAPACITY = 2;

	enum CM_Wheel 
	{
		SKIP_FUNCTION = -3, // This is used so HandleWheel can skip its function and go to HandleShells
		CLOSE_WHEEL,
		NO_UPGRADE,
		SINGLE_ALTFIRE,
		HOOK_ALTFIRE,
		SWITCH_MENU
	}
	
	states
	{
		Spawn:
			SG43 A -1;
			stop;
		
		Select:
			TNT1 A 0 PBX_WeaponRaise("COMSSGUP");
			TNT1 A 0 PB_RespectIfNeeded();
		SelectAnimation:
			TNT1 A 0 A_startsound("CLIPINSS",8);
			C0SU ABEF 1;
			goto Ready3;
		
		Deselect:
			TNT1 A 0 {
				A_startsound("weapons/changing",60);
				CSSG_CutMeathook();
			}
			C0SU FEBA 1;
			TNT1 A 0 A_Lower(120);
			wait;
			
		WeaponRespect:
			TNT1 A 1 A_DoPBWeaponAction();
			TNT1 A 0 A_Startsound("Ironsights", CHAN_AUTO);
			C0XR ABC 1 A_DoPBWeaponAction();
			C0XR DEFGHHHHHHHH 1 A_DoPBWeaponAction();
			C0XR IJK 1 A_DoPBWeaponAction();
			TNT1 A 0 A_startsound("CSSGOPEN",25);
			C0XR LM 1 A_DoPBWeaponAction();
			TNT1 A 3 A_DoPBWeaponAction();
			C0RO NO 1 A_DoPBWeaponAction();
			TNT1 AA 0 PB_GunSmoke(random(0,1),0,-2);
			C0RO P 1 A_DoPBWeaponAction();
		//insert shells
			C0RB A 1;
			C0RB BCDFGH 1 {
				ChangeCSSGShellsLook(
					'C0RB','C0RS','C0RN',
					'C0RK','C0RD','C0RX',
					'C0RW','C0RT','C0RM',
					'C1RX','C0RH','C0RA'
				);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_startsound("weapons/cssg/in",26);
			C0RB IJKLMM 1 A_DoPBWeaponAction();
			TNT1 A 4 A_DoPBWeaponAction();
			TNT1 A 0 A_startsound("CSSGCLOS",29);
			C0RC ABC 1 A_DoPBWeaponAction();
			C0RC DEEEEF 1 A_DoPBWeaponAction();
			C0RC GHIJ 1 A_DoPBWeaponAction();
			C0XR NNNN 1 A_DoPBWeaponAction();
		//random pump
			TNT1 A 0 A_startsound("weapons/sgmvpump",64);
			TNT1 A 0 A_quakeEx(0,1,1,6,0,10,"",QF_RELATIVE|QF_SCALEDOWN|QF_SCALEUP);
			C0XR NOPQRSSSSS 1 A_DoPBWeaponAction();
			TNT1 A 0 A_startsound("weapons/sgpump",65);
			C0XR TUVWX 1 A_DoPBWeaponAction();
			C0XR YYZZ 1 A_DoPBWeaponAction();
			C0ID A 2 A_DoPBWeaponAction();
			goto ready;

		WeaponInspect:
			TNT1 A 0 A_startsound("weapons/sgmvpump",64);
			TNT1 A 0 A_quakeEx(0,1,1,6,0,10,"",QF_RELATIVE|QF_SCALEDOWN|QF_SCALEUP);
			C0XR NOPQRSSSS 1 A_DoPBWeaponAction();
        HoldInspect:
			C0XR S 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
			TNT1 A 0 A_startsound("weapons/sgpump",65);
			C0XR TUVWX 1 A_DoPBWeaponAction();
			C0XR YYZZ 1 A_DoPBWeaponAction();
			C0ID A 2 A_DoPBWeaponAction();
			goto ready;

		Ready3:
            TNT1 A 0 PBX_CheckInspect();
			C0ID A 1 {
				CM_HandleCrosshair();
				PB_CoolDownBarrel();
				return CSSG_Ready();
			}
			loop;
		
		// FIRE STATES
		Fire:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				CM_HandleCrosshair();
				CSSG_CutMeathook();
			}
			TNT1 A 0 PB_JumpIfNoAmmo("LeftFire",2);
			TNT1 A 0 A_FlashOverlay(state:"MuzzleFlashFull");
			TNT1 A 0 CM_PlayFireSound();
			C0FF A 1 bright FireCSSG();
			C0FF B 1 bright {
				PB_GunSmoke(-2,0,-1);
				PB_GunSmoke(2,0,-1);
			}
			TNT1 A 0 A_ZoomFactor(0.95);
			TNT1 A 0 A_recoil(6);
			//C0FF C 1;
			C0FF F 1;
			TNT1 A 0 A_ZoomFactor(0.975);
			C0FF G 1;
			TNT1 A 0 A_ZoomFactor(0.985);
			TNT1 A 0 A_QuakeEx(3,3,3,6,0,60,"",QF_RELATIVE|QF_SCALEDOWN);
			C0FF H 1;
			TNT1 A 0 A_ZoomFactor(0.995);
			C0FF I 1;
			TNT1 A 0 A_ZoomFactor(1.0);
			C0FF IHGFEDC 1;
			C0ID A 1 A_DoPBWeaponAction(WRF_NOFIRE);
			goto reload;

		AltFire:
			TNT1 A 0 {
				if(invoker.meathookMode)
				{
					A_trymeathook(1600);
					return resolvestate("Ready3");
				}
				return resolvestate(null);
			}
			TNT1 A 0 PB_JumpIfNoAmmo("LeftFire",2,true,true);
			TNT1 A 0 CM_HandleCrosshair();
		RightFire:
			TNT1 A 0 CM_PlayAltFireSound();
			TNT1 A 0 A_FlashOverlay(state:"MuzzleFlashRight");
			C0FH AB 1 bright; 
			TNT1 A 0 bright {
				FireHalfCSSGRight();
				PB_TakeAmmo(invoker.ammotype2,1);
				A_ZoomFactor(0.975);
				PB_WeaponRecoil(-3,frandom[sfx](-0.5,0.5));
				PB_GunSmoke(-2,0,-1);
				A_FireProjectile("ShotgunWad",random(-2,2),0,3,-4,FPF_NOAUTOAIM,random(-2,2));
			}
			C0FH G 1 PB_GunSmoke(-2,0,-1);
			TNT1 A 0 A_ZoomFactor(0.975);
			C0FH F 1;
			TNT1 A 0 A_ZoomFactor(0.985);
			C0FH E 1;
			TNT1 A 0 A_ZoomFactor(0.995);
			C0FH D 1;
			TNT1 A 0 A_ZoomFactor(1.0);
			C0FH C 1;
			C0ID AA 1;
			goto ready;
		LeftFire:
			TNT1 A 0 PB_JumpIfNoAmmo();
			TNT1 A 0 CM_PlayAltFireSound();
			TNT1 A 0 A_FlashOverlay(state:"MuzzleFlashLeft");
			C0FH HI 1 bright; 
			TNT1 A 0 bright {
				FireHalfCSSGLeft();
				PB_TakeAmmo(invoker.ammotype2,1);
				A_ZoomFactor(0.975);
				PB_WeaponRecoil(-3,frandom[sfx](-0.5,0.5));
				PB_GunSmoke(2,0,-1);
				A_FireProjectile("ShotgunWad",random(-2,2),0,-3,-4,FPF_NOAUTOAIM,random(-2,2));
			}
			C0FH N 1 PB_GunSmoke(2,0,-1);
			TNT1 A 0 A_ZoomFactor(0.975);
			C0FH M 1;
			TNT1 A 0 A_ZoomFactor(0.985);
			C0FH L 1;
			TNT1 A 0 A_ZoomFactor(0.995);
			C0FH K 1;
			TNT1 A 0 A_ZoomFactor(1.0);
			C0FH J 1;
			C0ID AA 1;
			goto reload;
		
		// RELOAD STATES
		Reload:
			TNT1 A 0 PB_CheckReload(null, null, null,"Ready3","Ready3",BARREL_CAPACITY);
			// If there is still one shell in the barrel, go to reload half
			// otherwise go to reload full
			TNT1 A 0 A_JumpIf(invoker.ammo2.amount >= 1, "ReloadHalf");
			Goto ReloadFull;
		ReloadHalf:
			C0HO ABC 1;
			TNT1 A 0 A_startsound("CSSGOPEN",25);
			C0HO D 1;
			TNT1 A 0 A_spawnCSSGCasing();
			C0HO EFGH 1;
			TNT1 A 0 PB_GunSmoke(0,0,-2);
			C0HO II 1;
		//insert shell
			C0HB ABC 1 ChangeCSSGShellsLook(
				'C0HB','C0HS','C0HN',
				'C0HK','C0HD','C0HX',
				'C0HW','C0HT','C0HM',
				'C1HX','C0HH','C0HA'
			);
			"####" DEF 1;
			TNT1 A 0 A_startsound("weapons/cssg/in",24);
			TNT1 A 0 {
				PB_AmmoIntoMag(invoker.ammo2.GetClassName(),invoker.ammo1.GetClassName(),BARREL_CAPACITY);
				PB_SetMagEmpty(false);
				PB_SetChamberEmpty(false);
			}
			C0HB GHIJKLMN 1;
			TNT1 A 3;
		CloseSSG:
			TNT1 A 0 A_startsound("CSSGCLOS",29);
			C0RC ABC 1;
			C0RC DEEFF 1;
			C0RC GHIJ 1;
			TNT1 A 0 PB_SetReloading(false);
			goto ready3;
			
		ReloadFull:
			C0RO ABC 1;
			C0RO DEF 1;
			C0RO GHIJ 1;
			TNT1 A 0 A_startsound("CSSGOPEN",25);
			C0RO KLM 1;
			TNT1 A 1;
			C0RO N 1;
			TNT1 AA 0 A_spawnCSSGCasing();
			C0RO O 1;
			TNT1 AA 0 PB_GunSmoke(random(0,1),0,-2);
			C0RO P 1;
		//insert shells
			C0RB A 1;
			C0RB BCDFGH 1 ChangeCSSGShellsLook(
				'C0RB','C0RS','C0RN',
				'C0RK','C0RD','C0RX',
				'C0RW','C0RT','C0RM',
				'C1RX','C0RH','C0RA'
			);
			TNT1 A 0 {
				A_startsound("weapons/cssg/in",26);
				PB_AmmoIntoMag(invoker.ammo2.GetClassName(),invoker.ammo1.GetClassName(),BARREL_CAPACITY);
				PB_SetMagEmpty(false);
				PB_SetChamberEmpty(false);
			}
			C0RB IJKLMM 1;
			TNT1 A 2;
			goto CloseSSG;
			
		Unload:
			TNT1 A 0 A_Jumpif(PB_GetChamberEmpty() || countinv(invoker.ammotype2) < 1,"Ready3");
			C0HO ABC 1;
			TNT1 A 0 A_startsound("CSSGOPEN",25);
			C0HO D 1;
			TNT1 A 4;
			C0RB LKJI 1;
			C0RB HGFEDCB 1 ChangeCSSGShellsLook(
				'C0RB','C0RS','C0RN',
				'C0RK','C0RD','C0RX',
				'C0RW','C0RT','C0RM',
				'C1RX','C0RH','C0RA'
			);
			TNT1 A 0 {
				CM_HandleUnload();
				PB_SetChamberEmpty(true);
				PB_SetMagEmpty(true);
			}
			TNT1 A 0 A_Startsound("weapons/ssg/inspect2",26);
			C0RB A 1;
			C0RO PON 1;
			TNT1 A 3;
			goto CloseSSG;
		
		// OTHERS
		WeaponSpecial:
		TNT1 A 0 CSSG_HandleWheel();
			TNT1 A 0 CSSG_HandleShells(); // Somehow putting the HandleWheel first will break the HandleShells, no idea why
		ChangeShellAnimation:
			C0HO ABC 1;
			TNT1 A 0 A_startsound("CSSGOPEN",25);
			C0HO D 1;
			TNT1 A 1;
			TNT1 AA 0 {
				A_spawnCSSGCasing(true);
				CM_HandleUnload();
				PB_SetChamberEmpty(true);
				PB_SetMagEmpty(true);
			}
			C0RO NOP 1;
			C0RB A 1;
			C0RB BCDEFGH 1 ChangeCSSGShellsLook(
				'C0RB','C0RS','C0RN',
				'C0RK','C0RD','C0RX',
				'C0RW','C0RT','C0RM',
				'C1RX','C0RH','C0RA'
			);
			TNT1 A 0 A_startsound("weapons/cssg/in",24);
			TNT1 A 0 {
				// if(countinv(invoker.ammotype2)<2 && countinv(invoker.ammotype1)>0)
				PB_AmmoIntoMag(invoker.ammo2.GetClassName(),invoker.ammo1.GetClassName(),BARREL_CAPACITY);
				PB_SetMagEmpty(false);
				PB_SetChamberEmpty(false);
			}
			C0RB IJKLMM 1;
			TNT1 A 3;
			goto closeSSG;

		SwitchAnimation:
			C0MO ABCDE 1;
			C0MO F 2;
			C0MO EDCBA 1;
			goto ready3;
			
		// FLASH STATES
		FlashPunching:
			C0MO ABCDEFFFFEDCBA 1;
			goto ready3;
		
		FlashKicking:
			C0KO ABCDEEFFGGEDCBA 1; //A_DoPBWeaponAction();
			goto ready3;
			
		FlashAirKicking:
			C0MO ABCDEFFFFFFEDCBA 1;
			goto ready3;
			
		FlashSlideKicking:
			C0KO ABCDEEFFFGGGFFFEEEGGGFEDCBA 1; //A_DoPBWeaponAction();
			goto ready3;
			
		FlashSlideKickingStop:
			C0KO GFEDCBA 1; //A_DoPBWeaponAction();
			goto ready3;
		
		// OVERLAYS
		MuzzleFlashFull:
			C1MZ A 1 bright;
			C1MZ B 1 bright;
			stop;
			
		MuzzleFlashRight:
			C1MZ C 1 bright;
			stop;
			
		MuzzleFlashLeft:
			C1MZ D 1 bright;
			stop;
			
		LoadSprites:
			C0RB A 0; C0RD A 0; C0RX A 0;
			C0RK A 0; C0RN A 0; C0RS A 0;
			C0RW A 0; C0RT A 0; C0RM A 0;
			C1RX A 0; C0RH A 0; C0RA A 0;

			C0HB A 0; C0HD A 0; C0HX A 0;
			C0HN A 0; C0HS A 0; C0HW A 0;
			C0HK A 0; C0HT A 0; C0HM A 0;
			C1HX A 0; C0HH A 0; C0HA A 0;
			
	}
	
}

