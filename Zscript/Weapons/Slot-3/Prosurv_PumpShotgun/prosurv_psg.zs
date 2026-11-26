// Pump Shotgun 
// From Project Survival made by ThePopeOfDope
// Modified sprites from Carrots Vanilla Project made by IAmCarrotMaster, edited by ThePopeOfDope
// Tripmine from Brutal Doom Platinum by EmeraldCoasttt and the BDP Team

// Actual Weapon
class PBX_ProSurvPSG : PBX_WeaponBase
{
    Default
    {
        Weapon.BobRangeX 0.3;
        Weapon.BobRangeY 0.5;
        Weapon.BobStyle "InverseSmooth";
        Weapon.BobSpeed 2.4;
        Weapon.AmmoGive1 18;
        Weapon.AmmoGive2 9;
        Scale 0.7;
        Weapon.AmmoType1 "PB_Shell";
        Weapon.AmmoType2 "PumpShotgunAmmo";
        Inventory.PickupMessage "$PBX_PSG_PICKUP";
        Inventory.PickupSound "weapons/sgpump";
	    Inventory.AltHUDIcon "AUSXA0";
		PB_WeaponBase.UsesWheel true;
		PB_WeaponBase.WheelInfo "PSGWheel";
        Damagetype "Shotgun";
        Obituary "$OB_WEAP_PSG";
        AttackSound "None";
        Tag "$PBX_PSG_TAG";
        +DONTGIB;
        +FLOORCLIP;
        +WEAPON.NOALERT;
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
    }

	const MAGAZINE_SIZE = 9;

	enum psgSpecials
	{
		CLOSE_WHEEL
		,TOGGLE_LASER
		,SELECT_ADS
		,SELECT_STICKYBOMB
	}

	mixin PBX_LaserSight;

	static const StateLabel blockedLaserStates[] = {
		"Reload", "ShellChecker", "ChamberInsertShell", "ReloadFinished", "ReloadFromADS",
		"Unload", "RemoveBullets", "FinishUnload", "SelectAnimation", "WeaponInspect",
		"Pump", "PumpBegin", "PumpEnd", "WeaponRespect", "Deselect", "SwitchAnimation",
		"FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
	};

	override void PBX_DoEffectWeaponReady()
    {
		PBX_SpawnLaserSight(GREEN_DOT);
    }

	action void SG_Fire(int tic)
	{
		bool ads = PB_GetZoom();

		// Shared variables
		double recoilX      = ads ? frandom[sfx](-0.62,0.62) : frandom[sfx](-1.64,1.64);
		double recoilY      = ads ? +0.24 : +0.88;
		double zoomA        = ads ?  1.2  :  0.98;
		double zoomB        = ads ?  1.24 :  0.99;
		double zoomC        = ads ?  1.25 :  1.0 ;
		int    wadOfsY      = ads ?    -3 :    -4;

		switch(tic)
		{
			case 1:
				PB_SetRoll(0);
				if (ads) A_SetCrosshair(-1);

				PB_FireBullets("PB_12GAPellet", 12, 1.5, 0, 0, 1.5);

				A_FireProjectile("ShotgunWad", random(-2,2), 0, random(-2,2), wadOfsY, FPF_NOAUTOAIM, random(-2,2));
				PB_LowAmmoSoundWarning("shotgun");
				PB_TakeAmmo(invoker.ammo2.getClassName(),1,0);
				A_AlertMonsters();
				A_StartSound("weapons/sg", CHAN_WEAPON, pitch:frandom(0.95, 1.05));
				PB_IncrementHeat();
				PB_FireOffset();
				A_FireCustomMissile("YellowFlareSpawn", 0, 0, 0, 0);
				_SpawnMuzzleSparksSG(0, 0, -4);
				PB_MuzzleFlashEffects(0, 0, -4);
				PB_DynamicTail("shotgun", "shotgun");
				A_SetInventory("CantDoAction", 1);
				PB_SetChamberEmpty(true);
				A_GunFlash();
				A_ZoomFactor(zoomA);
				PB_WeaponRecoil(recoilX, recoilY);
				break;

			case 2:
				A_ZoomFactor(zoomB);
				PB_WeaponRecoil(recoilX, recoilY);
				break;

			case 3:
				A_ZoomFactor(zoomC);
				break;

			// Pump
			case 4:
				A_ZoomFactor(zoomC);
				if(ads) A_SetCrosshair(-1);
                A_StartSound("Ironsights",CHAN_AUTO);
				PB_SetReloading(true);
				break;

			case 5:
				PB_SpawnCasing("ShotgunCasing",15,-5,26,0,3,3);
				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
				break;
		}
	}

    States
    {
        Spawn:
            AUSX A -1;
            Stop;

        WeaponRespect:
			TNT1 A 0 {
				A_SetCrosshair(-1);
			}
			TNT1 AAAAAA 1 {
				PB_SetRoll(roll-0.3);
				return A_DoPBWeaponAction();
			}
			XG10 A 1 {
				PB_SetRoll(roll-0.3);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/autoshotgun/respect1", CHAN_AUTO);
			XG10 BCDEFGH 1 {
				PB_SetRoll(roll+0.3);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 {
				A_StartSound("Ironsights",CHAN_AUTO);
			}
			XG31 ABCD 1 {
				PB_SetRoll(roll+1.0);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_StartSound("weapons/sgmvpump",CHAN_AUTO);
			XG31 EF 1 {
				PB_SetRoll(roll-2.0);
				return A_DoPBWeaponAction();
			}
			XG31 GHIJKL 1 {
				PB_SetRoll(roll-1.0);
				return A_DoPBWeaponAction();
			}
			XG31 M 1 A_DoPBWeaponAction();
			XG31 N 1 {
				A_StartSound("insertshell",CHAN_AUTO);
				return A_DoPBWeaponAction();
			}
			XG31 OP 1 A_DoPBWeaponAction();
			XG31 Q 1 {
				A_StartSound("weapons/sgpump",CHAN_AUTO);
				return A_DoPBWeaponAction();
			}
			XG31 RSTU 1 A_DoPBWeaponAction();
			XG40 HHHHHHHHH 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback", CHAN_WEAPON);
			XG40 IJKL 1 {
				PB_SetRoll(roll-0.3);
				return A_DoPBWeaponAction();
			}
			XG40 LLL 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_WEAPON);
			XG40 MNH 1 {
				PB_SetRoll(roll+0.4);
				return A_DoPBWeaponAction();
			}
			XG40 HG 1 A_DoPBWeaponAction();
			XG40 FEDCBA 1 {
				PB_SetRoll(roll+1.0);
				return A_DoPBWeaponAction();
			}
			Goto Ready3;

		WeaponInspect:
			TNT1 A 0 A_StartSound("Ironsights",CHAN_AUTO);
			XG40 ABCDEFGH 1 {
				PB_SetRoll(roll-0.1);
				return A_DoPBWeaponAction();
			}
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback", CHAN_WEAPON);
			XG40 IMMM 1 {
				PB_SetRoll(roll-0.3);
				return A_DoPBWeaponAction();
			}
			XG40 MMM 1 A_DoPBWeaponAction();
        HoldInspect:
			XG40 M 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_WEAPON);
			XG40 NH 1 {
				PB_SetRoll(roll+0.4);
				return A_DoPBWeaponAction();
			}
			XG40 HGFEDCBA 1 {
				PB_SetRoll(roll+0.1);
				return A_DoPBWeaponAction();
			}
			Goto Ready3;

        Deselect:
			TNT1 A 0 {
                A_SetCrosshair(-1);
				PBX_WeaponLower();
			}
			XG10 FEDCBA 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(46);
                PBX_WeaponRaise("weapons/autoshotgun/respect1");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            TNT1 A 0 A_StartSound("weapons/autoshotgun/respect1", CHAN_AUTO);
			TNT1 A 0 PB_SetZoom(false);
			XG10 ABCDEFG 1;
		Ready3:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Ready2");
			TNT1 A 0 {
				A_ZoomFactor(1.0);
                PB_HandleCrosshair(46);
				A_SetInventory("CantWeaponSpecial",0);
				A_SetInventory("CantDoAction",0);
                PB_SetReloading(false);
			}
		ReadytoFire:
            TNT1 A 0 PBX_CheckInspect();
            XG10 H 1 {
				PB_CoolDownBarrel(0,0,-4);
                return PB_ReadyFire();
            }
            Loop;

        Ready2:
			TNT1 A 0 {
				A_ZoomFactor(1.25);
				A_SetCrosshair(-1);
				A_SetInventory("CantDoAction",0);
                PB_SetReloading(false);
			}
		ReadytoFire2:
            ASS1 E 1 {
				PB_CoolDownBarrel(0,-2,6);
				return PB_ReadyFire(ads:true);
			}
            Loop;

        WeaponSpecial:
			TNT1 A 0 {
				A_Takeinventory("GoWeaponSpecialAbility",1);
				PBX_ToggleLaserSight();
				return PBX_ReturnReady(normal:null);
			}
		SwitchAnimation:
			XG51 ABCDEFG 1;
			XG51 GFEDCBA 1;
			Goto Ready3;

        Fire:
			TNT1 A 0 {
				PB_SetRoll(0);
				PB_HandleCrosshair(46);
			}
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Fire2");
		Fire1Actual:
			TNT1 A 0 		PB_jumpIfNoAmmo();
			XG20 A 1 BRIGHT SG_Fire(1);
			XG20 B 1 BRIGHT SG_Fire(2);
			XG20 C 1 		SG_Fire(3);
			XG20 DEFGHHH 1; 
			XG20 I 1;
			TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"Ready3");
		Pump:
			TNT1 A 0 		SG_Fire(4);
			XG40 ABCDEFGH 1 PB_SetRoll(roll-0.1);
		PumpBegin:
            TNT1 A 0 		A_StartSound("weapons/spas12/pumpback",CHAN_WEAPON,CHANF_OVERLAP);
			XG40 IJKL 1 	PB_SetRoll(roll-0.3);
			TNT1 A 0 		SG_Fire(5);
			XG40 LLL 1;
			XG40 MNH 1 		PB_SetRoll(roll+0.4);
		PumpEnd:
            TNT1 A 0 		A_StartSound("weapons/spas12/pumpforward", CHAN_WEAPON);
			XG40 HGFEDCBA 1 PB_SetRoll(roll+0.1);
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
			TNT1 A 0 		PB_jumpIfNoAmmo();
			ASX1 A 1 BRIGHT SG_Fire(1);
			ASX1 B 1 BRIGHT SG_Fire(2);
			ASX1 C 2;
			ASX1 D 2;
			TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"Ready3");
		Pump2:
            TNT1 A 0 		SG_Fire(4);
            ASS2 A 5;
            TNT1 A 0 		A_StartSound("weapons/spas12/pumpback",CHAN_WEAPON,CHANF_OVERLAP);
            ASS2 BCD 1;
            TNT1 A 0 		SG_Fire(5);
            ASS2 DDDDCBAAA 1 {
				if(JustPressed(BT_ATTACK) && invoker.ammo2.amount > 0) return ResolveState("Fire2");
                return ResolveState(null);
			}
            TNT1 A 0 		A_StartSound("weapons/spas12/pumpforward",CHAN_WEAPON,CHANF_OVERLAP);
			TNT1 A 0 {
				A_SetInventory("CantDoAction",0);
				return PB_ReadyFire(ads:true);
			}
            // TNT1 A 0 PB_ReadyFire(ads:true);
			// TNT1 A 0 PB_jumpIfNoAmmo();
            Goto Ready2;

        AltFire:
			TNT1 A 0 {
				PB_SetRoll(0);
				PB_HandleCrosshair(46);
			}
			TNT1 A 0 A_StartSound("IronSights", 0);
			TNT1 A 0 A_JumpIf(PB_GetZoom(),"Zoomout");
		ZoomIn:
			TNT1 A 0 {
				A_ZoomFactor(1.25);
                A_SetCrosshair(-1);
				PB_SetZoom(true);
			}
			ASS1 ABC 1;
			Goto Ready2;
			
		ZoomOut:
			TNT1 A 0 {	
				PB_SetZoom(false);
				A_ZoomFactor(1.0);
            }
			ASS1 CBA 1;
			Goto Ready3;
        
        ReloadFromADS:
			TNT1 A 0 {
				PB_SetZoom(false);
				A_ZoomFactor(1.0);
			}
			ASS1 CBA 1;
        Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
			TNT1 A 0 {
                A_ZoomFactor(1.0);
			}
            TNT1 A 0 PB_CheckReload(null,null,"Pump","Ready3","Ready3",MAGAZINE_SIZE);
			TNT1 A 0 A_StartSound("Ironsights",CHAN_AUTO);
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(), "ChamberInsertShell"); // Go to insert chamber first
            // Raise Weapon
            XG30 ABCD 1 PB_SetRoll(roll+1.0);
			XG30 EF 1 PB_SetRoll(roll-2.0);
			XG30 GHIJKL 1 PB_SetRoll(roll-1.0);
        ShellChecker:
            // Main reload loop
			TNT1 A 0 A_JumpIf(invoker.ammo1.amount < 1 || invoker.ammo2.amount >= MAGAZINE_SIZE,"ReloadFinished");
			XG30 L 3 A_DoPBWeaponAction(WRF_NOBOB);
			XG30 MN 1 A_DoPBWeaponAction(WRF_NOBOB);
			XG30 O 1 { 
				A_StartSound("insertshell",CHAN_AUTO);
				A_Giveinventory(invoker.ammo2.getClassName(),1);
				A_Takeinventory(invoker.ammo1.getClassName(),1,TIF_NOTAKEINFINITE);
				PB_RotateCamera(addAngle:0.2,addPitch:-0.2,addRoll:-0.4);
				return A_DoPBWeaponAction(WRF_NOBOB);
			}
			XG30 PQ 1 {
				PB_RotateCamera(addAngle:-0.1,addPitch:0.1,addRoll:0.2);
				return A_DoPBWeaponAction(WRF_NOBOB);
			}
			Loop;

		ReloadFinished:
			TNT1 A 0 {
				A_StartSound("Ironsights",CHAN_AUTO);
			}
			XG30 LKJIHG 1 PB_SetRoll(roll+1.0);
			XG30 FEDCBA 1; 
			TNT1 A 0 PB_SetReloading(false);
			Goto Ready3;
            
		ChamberInsertShell:
			TNT1 A 0 A_StartSound("Ironsights",CHAN_AUTO);
			XG31 ABCD 1 {
				PB_SetRoll(roll+1.0);
				return A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
			}
			TNT1 A 0 A_StartSound("weapons/sgmvpump",CHAN_AUTO);
			XG31 EF 1 {
				PB_SetRoll(roll-2.0);
				return A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
			}
			XG31 GHIJKL 1 {
				PB_SetRoll(roll-1.0);
				return A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
			}
			XG31 M 1 A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
			XG31 N 1 {
				A_StartSound("insertshell",CHAN_AUTO);
				return A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
			}
			XG31 OP 1 A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
			XG31 Q 1 {
				A_StartSound("weapons/sgpump",CHAN_AUTO);
				A_Giveinventory(invoker.ammo2.getClassName(),1);
				A_Takeinventory(invoker.ammo1.getClassName(),1,TIF_NOTAKEINFINITE);
                PB_SetChamberEmpty(false);
				PB_SetMagEmpty(false);
				return A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
			}
			XG31 RSTUV 1 A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
			Goto ShellChecker;

        Unload:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				A_StartSound("Ironsights",CHAN_AUTO);
			}
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty(),"Ready3");
			XG40 ABCDEFGH 1 A_DoPBWeaponAction();
		RemoveBullets:
            TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"FinishUnload");
			TNT1 A 0 {
				PB_UnloadMag(
					invoker.ammo2.getClassName(),
					invoker.ammo1.getClassName(),
					1,1,1,
					invoker.ammo2.amount - 1,
					"PB_SingleShell"
				);
         		A_StartSound("weapons/spas12/pumpback", CHAN_WEAPON);
			}
			XG40 IJKLLLL 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_WEAPON);
			XG40 MN 1 A_DoPBWeaponAction();
			loop;

		FinishUnload:
			XG40 IHGFEDCBA 1 A_DoPBWeaponAction();
			TNT1 A 0 {
                PB_SetMagEmpty(true);
                PB_SetChamberEmpty(true);
				PB_SetReloading(false);
            }
			Goto Ready3;

        FlashPunching:
			XG51 ABCDEFG 1;
			XG51 GFEDCBA 1;
			Goto Ready3;
			
		FlashKicking:
			XG50 ABCDEF 1;
			XG50 G 2;
			XG50 FEDCBA 1;
			XG10 G 1;
			Goto Ready3;
		
		FlashAirKicking:
			XG50 ABCDEF 1;
			XG50 G 3;
			XG50 FEDCBA 1;
			XG10 G 1;
			Goto Ready3;
		
		FlashSlideKicking:
			XG50 ABCDEF 1;
			XG50 G 14;
			XG50 FEDCBA 1;
			XG10 G 1;
			Goto Ready3;

		FlashSlideKickingStop:
			XG50 FEDCBA 1;
			XG10 G 1;
			Goto Ready3;
    }
}


