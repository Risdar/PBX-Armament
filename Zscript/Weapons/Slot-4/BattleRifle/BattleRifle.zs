// Battle Rifle
// From Brutal Doom Platinum by EmeraldCoasttt and the BDP Team

// Includes
// #include "./BattleRifle_Functions.zs"
#include "./BattleRifle_Wheel.zs"
#include "./BattleRifle_helpers.zs"

class BR_Select_FireMode : inventory {default{inventory.maxamount 1;}}

class PBX_BDPBattleRifle : PBX_WeaponBase
{
	Default
	{
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
	    Inventory.PickupSound "BR45PICK";
	    Inventory.AltHUDIcon "BR45A0";
		inventory.maxamount 1;
		PB_WeaponBase.UsesWheel true;
		PB_WeaponBase.WheelInfo "BattleRifleWheel";
		PB_WeaponBase.ReserveToMagAmmoFactor 2;
        PBX_WeaponBase.ScopeConfiguration true, MINZOOM, MAXZOOM; 
        PBX_WeaponBase.SelectWeaponUpgrade "PBX_XM21";
		Scale 1.0;
		
        // Messages
	    Obituary "$OB_WEAP_BATTLERIFLE";
	    Inventory.Pickupmessage "$PBX_BattleRifle_Pickup";
		Tag "$PBX_BattleRifle_Tag";
		
        // Ammo
        weapon.ammotype1 "PB_HighCalMag"; // Reserve
		weapon.ammogive1 30;
		weapon.ammotype2 "BR_Ammo"; // Primary
		
        // Flags
		+WEAPON.NOALERT;
		+WEAPON.AMMO_OPTIONAL;
		+WEAPON.NOAUTOFIRE; //[Pop] Use NOAUTOFIRE if you want a semi auto gun.
		//Albeit PB has QOL stuff for holding down left click already, firing it
		//at a slower rate
	}
	
//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    bool mSemiAuto;
	bool mSemiClear;
	int mBurstCount;

	// Change these if you want to edit how strong the zoom modes are
	const MAGAZINE_SIZE = 15;
	const MAXZOOM = 9.0;
	const MINZOOM  = 1.25;
	
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
	override void postbeginplay()
	{
		mSemiClear = false;
		mSemiAuto = true;
		super.postbeginplay();
	}

	// Laser sight stuff
	mixin PBX_LaserSight;
	static const StateLabel blockedLaserStates[] = {
		"Reload", "ReloadFromADS", "ContinueReload", "RaiseFromEmpty", "WeaponInspect",
		"Unload", "SwitchAnimation","WeaponRespect", "Deselect", "SelectAnimation",
		"FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
	};
	override void PBX_DoEffectWeaponReady()
	{
		PBX_SpawnLaserSight(GREEN_DOT);
	}
   
//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
	action void cleanmodetokens()
	{
		A_SetInventory("BR_Select_FireMode",0);
		A_SetInventory("PBX_Toggle_Laser",0);
		A_SetInventory("PBX_CloseWheel",0);
	}

	action bool getSemiAuto()
	{
		return invoker.mSemiAuto;
	}

    // FIRE FUNCTION
	action void FireWeapon()
	{
		// Set up Variables
		bool ads 	  = PB_GetZoom();
		double recoil = ads ? -1.5 : -3;
		double smoke  = ads ? -2   : -1;
		double zoom	  = ads ? PBX_GetZoomLevel() : 1.0;

		A_AlertMonsters();
		PB_DynamicTail("lmg", "lmg");

		PBX_FireRicochet("PB_762x51mm","PB_EmptyBrass",1,0.1,0,0,0.1,puffType:"BR45BulletPuff");

		// Everything Else
		PB_LowAmmoSoundWarning("default");
		pb_takeammo(invoker.ammotype2,1,0);
		A_StartSound("BR45FIRE", CHAN_WEAPON, pitch: 1.2);
		invoker.mBurstCount++;
		PB_IncrementHeat(4);

		if(!ads)
		{
			A_FlashOverlay();
		}
		
		PB_GunSmoke(0,0,smoke);
		PB_WeaponRecoil(recoil,frandom[sfx](-0.3,0.3));
		A_ZoomFactor(zoom, SPF_INTERPOLATE);
	}

	action state checkSpecial()
	{
		bool toggleFireMode 	= countinv("BR_Select_FireMode")  	> 0;
		bool toggleLaser 		= countinv("PBX_Toggle_Laser")  	> 0;

		if(countinv("PBX_CloseWheel") > 0)
		{
			cleanmodetokens();
			return resolvestate("Ready3");
		}

		if(toggleFireMode)
		{
			invoker.mSemiAuto = !invoker.mSemiAuto;
			A_Print(invoker.mSemiAuto ? "$PB_FIREMODE_SEMI" : "$PB_FIREMODE_BURST");
		}

		if(toggleLaser)	PBX_ToggleLaserSight(skipPlaySound:true);

		// Always remove the tokens regardless
		cleanmodetokens();

		// Play sound when opening the wheel in ADS
		if(PB_GetZoom())
		{
			A_StartSound("MS/Button",CHAN_AUTO); 
			return resolvestate("Ready2");
		}

		// Fallthrough to Switch Animation
		// The mode switch sound is played there
		return resolvestate(null);
	}

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
	States
	{
        // SETUP
        Spawn:
			BR45 A -1;
			stop;

		Deselect:
			TNT1 A 0 PBX_WeaponLower();
			BR4S ABCDE 1; 
			TNT1 A 1;
			TNT1 A 0 A_Lower();
            Wait;
		Select:
			TNT1 A 0 PBX_WeaponRaise("BR45PICK");
			TNT1 A 0 PB_RespectIfNeeded();
		SelectAnimation:
			BR4S EDCBA 1;
			goto Ready3;
		
		WeaponRespect:
			TNT1 A 0 A_SetCrosshair(-1);
			BR4S EDCBA 1 A_DoPBWeaponAction();
			BR45 BBB 1 A_DoPBWeaponAction();
			TNT1 A 0 A_startsound("BR45OPEN",CHAN_WEAPON,CHANF_OVERLAP);
            BR4R ABCDE 1 A_DoPBWeaponAction();
			BR4R FGGGGG 1 A_DoPBWeaponAction();
			BR4R GHIJKLMNOP 1 A_DoPBWeaponAction();
			TNT1 A 0 A_startsound("BR45LOAD",CHAN_WEAPON,CHANF_OVERLAP);
			BR4R QRSTUVWX 1 A_DoPBWeaponAction();
			goto Ready3;

		WeaponInspect:
			TNT1 A 0 A_startsound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            BR4K ABCD 1 A_DoPBWeaponAction();
            BR4K EEEE 1 A_DoPBWeaponAction();
		HoldInspect:
			BR4K E 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
			BR4K DCBA 1 A_DoPBWeaponAction();
			goto Ready3;

        // READY STATES
        Ready:
        Ready3:
			TNT1 A 0 {invoker.mBurstCount = 0;}
			TNT1 A 0 A_jumpif(PB_GetZoom(),"Ready2");
		ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
			BR45 B 1 {
				PB_HandleCrosshair(42);
				PB_CoolDownBarrel();
				return PB_ReadyFire();
			}
			Loop;
		
		Ready2:
			TNT1 A 0 {
				PB_SetRoll(0);
				A_SetCrosshair(-1);
            }
		ReadyToFire2:
			BR4Z D 1 Bright  {
				PB_CoolDownBarrel();
				A_ZoomFactor(PBX_GetZoomLevel());
				PBX_ReadySmartScope();
				return PB_ReadyFire(ads:true);
            }
			Loop;
		
		BurstFireRecoil:
			BR45 EF 1;
		Fire:
			TNT1 A 0 {
				A_WeaponOffset(0, 32);
				PB_SetRoll(0);
				PB_HandleCrosshair(42);
				A_ZoomFactor(1.0);
			}
			TNT1 A 0 A_JumpIf(PB_GetZoom(), "Fire2");
			TNT1 A 0 PB_JumpIfNoAmmo(chamber:false);
			BR4F A 1 {
				A_SetWeaponFrame(random[sfx](0,2));
				FireWeapon();
			}
			BR45 D 1 {
				if (invoker.ammo2.amount < 1) PB_SpawnCasing("RifleClipSpawn");
			}
			// Semi-auto: always go to BurstDone after 1 shot
			// Burst: loop until mBurstCount hits 3
			TNT1 A 0 A_JumpIf(getSemiAuto(), "BurstDone");
			TNT1 A 0 A_JumpIf(invoker.mBurstCount < 3, "BurstFireRecoil");
		BurstDone:
			TNT1 A 0 { invoker.mBurstCount = 0; }
			BR45 DEF 1;
			BR45 GHB 1 {
				// Track button release
				if (!(player.cmd.buttons & BT_ATTACK))
					invoker.mSemiClear = true;
				// Refire only if button was released and pressed again
				if (invoker.mSemiClear && PlayerPressedOnce(BT_ATTACK))
					return resolvestate("Fire");
				return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOFIRE | WRF_NOPRIMARY);
			}
			TNT1 A 0 { invoker.mSemiClear = false; }
			goto Ready3;

		Fire2:
			TNT1 A 0 A_ZoomFactor(PBX_GetZoomLevel());
			TNT1 A 0 PB_JumpIfNoAmmo(chamber:false);
			BR4Z D 1 Bright FireWeapon();
			BR4Z D 1 Bright {
				if (invoker.ammo2.amount < 1) PB_SpawnCasing("RifleClipSpawn");
			}
			// Same logic as hipfire
			TNT1 A 0 A_JumpIf(getSemiAuto(), "BurstDoneADS");
			TNT1 A 0 A_JumpIf(invoker.mBurstCount < 3, "BurstFireRecoilADS");
		BurstDoneADS:
			TNT1 A 0 {
				invoker.mBurstCount = 0;
				// A_SetInventory("CantDoAction", 0);
			}
			BR4Z D 3 Bright;
			BR4Z DDDDDDDDD 1 Bright {
				// Track button release
				if (!(player.cmd.buttons & BT_ATTACK))
					invoker.mSemiClear = true;
				// Refire only if button was released and repressed
				if (invoker.mSemiClear && PlayerPressedOnce(BT_ATTACK))
					return resolvestate("Fire2");

				return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOFIRE | WRF_NOPRIMARY);
			}
			TNT1 A 0 { invoker.mSemiClear = false; }
			goto Ready2;

		BurstFireRecoilADS:
			BR4Z DD 1 Bright;
			goto Fire2;
	
        // ALTFIRE
        AltFire:
			TNT1 A 0 A_Jumpif(PB_GetZoom(),"ZoomOut");
		ZoomIn:
            TNT1 A 0 {
				PB_SetZoom(true);
				A_startsound("IronSights",CHAN_AUTO);
				A_ZoomFactor(1.25);
			}
            BR4Z AB 1;
            TNT1 A 0 A_ZoomFactor(PBX_GetZoomLevel());
			BR4Z C 1;
            goto Ready2;
        ZoomOut:
			TNT1 A 0 {
				A_startsound("IronSights",CHAN_AUTO);
				A_ZoomFactor(1.0);
				PB_SetZoom(false);
			}
			BR4Z CB 1;
			BR4Z A 1;
			goto Ready3;

        // RELOAD
		ReloadFromADS:
			TNT1 A 0 PB_HandleCrosshair(42);
			TNT1 A 0 A_startsound("IronSights",CHAN_AUTO);
            TNT1 A 0 A_ZoomFactor(1.0);
			TNT1 A 0 PB_SetZoom(false);
			BR4Z CB 1;
			BR4Z A 1;
		Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
			TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null, null, "Ready3", "Ready3", MAGAZINE_SIZE);
			TNT1 A 0 A_startsound("BR45OPEN",CHAN_WEAPON,CHANF_OVERLAP);
            BR4R ABCDE 1;
            TNT1 A 0 {
                PB_SetMagUnloaded(true);
                PB_SetMagEmpty(true);
                PB_SetChamberEmpty(true);
                If(invoker.ammo2.amount > 0)
				{
					PB_SpawnCasing("RifleClipSpawn");
					A_fireprojectile("RifleClipSpawn",5,false,0,-14,0);
				}
			}
            BR4R FGGGGG 1;
        ContinueReload:
			BR4R GHIJKLMNOP 1;
			TNT1 A 0 {
				A_startsound("BR45LOAD",CHAN_WEAPON,CHANF_OVERLAP);
				PB_AmmoIntoMag(invoker.ammo2.getclassname(), invoker.ammo1.getclassname(), MAGAZINE_SIZE,1);
                PB_SetMagUnloaded(false);
                PB_SetMagEmpty(false);
                PB_SetChamberEmpty(false);
			}
			BR4R QRSTUVWX 1;
            TNT1 A 0 PB_SetReloading(false);
			goto Ready3;

        RaiseFromEmpty:
			TNT1 A 0 A_startsound("BR45OPEN",CHAN_WEAPON,CHANF_OVERLAP);
            BR4R ABCDEF 1;
            goto ContinueReload;
		
		Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
			TNT1 A 0 A_startsound("BR45OPEN",CHAN_WEAPON,CHANF_OVERLAP);
            BR4R ABCDE 1;
            TNT1 A 0 {
				If(invoker.ammo2.amount > 0)
				{
					PB_SpawnCasing("RifleClipSpawn");
					A_fireprojectile("RifleClipSpawn",5,false,0,-14,0);
				}
				PB_UnloadMag(invoker.ammotype2, invoker.ammotype1);
				PB_SetMagUnloaded(true);
				PB_SetMagEmpty(true);
				PB_SetChamberEmpty(true);
			}
            BR4R STUVWX 1;
            goto Ready3;

		Weaponspecial:
			TNT1 A 0 A_Takeinventory("GoWeaponSpecialAbility",1);
			TNT1 A 0 A_SetCrosshair(-1);
			TNT1 A 0 A_JumpIf(PB_GetZoom(),"ActualModeChange");
			TNT1 A 0 PB_SetZoom(false);
		ActualModeChange:
			TNT1 A 0 checkSpecial();
        SwitchAnimation:
            BR4K ABCD 1;
		    BR4K E 1;
            TNT1 A 0 A_StartSound("MS/Button",CHAN_AUTO);
		    BR4K DCBA 1;
			goto Ready3;
		
        // FLASH STATES
		MuzzleFlash:
			TNT1 A 0 A_Jump(128, "MuzzleFlash2");
			MZ01 ABC 1 BRIGHT A_GunFlash();
			Stop;
		MuzzleFlash2:
			MZ01 DEF 1 BRIGHT A_GunFlash();
			Stop;

        FlashPunching:
            BR4K ABCD 1;
		    BR4K E 13;
		    BR4K DCBA 1; //14 frames
            goto Ready3;

		FlashKicking:
			BR4K ABCD 1;
		    BR4K E 13;
		    BR4K DCBA 1; //15 frames
			goto Ready3;
			
		FlashAirKicking:
			BR4K ABCD 1;
		    BR4K E 14;
		    BR4K DCBA 1; //16 frames
			goto Ready3;
			
		FlashSlideKicking:
			BR4K A 1; 
			BR4K B 2; 
			BR4K C 4;
			BR4K D 6; 
			BR4K E 7; 
			BR4K D 3; 
			BR4K C 2;
			BR4K B 1;
			BR4K A 1; //27 frames
			goto Ready3;
			
		FlashSlideKickingStop:
			BR4K EDCBAAA 1; //7 frames 
			goto Ready3;
	}
	
}