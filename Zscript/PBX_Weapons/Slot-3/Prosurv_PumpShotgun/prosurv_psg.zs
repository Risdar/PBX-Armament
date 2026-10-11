// Pump Shotgun 
// From Project Survival made by ThePopeOfDope
// Modified sprites from Carrots Vanilla Project made by IAmCarrotMaster, edited by ThePopeOfDope
// Laser Charge, Swarm Charge, Acid Charge sprites are from LitDoom by Skadi and the LitDoom team modified by ThePopeOfDope
// Tripmine from Brutal Doom Platinum by EmeraldCoasttt and the BDP Team

// Includes
#include "./ProsurvPSG_Functions.zs"
#include "./ProsurvPSG_Wheel.zs"
#include "./ProsurvPSG_helpers.zs"

// Tokens
class PSG_Select_Tripmine : inventory {default{inventory.maxamount 1;}}
class PSG_Select_LaserCharge : inventory {default{inventory.maxamount 1;}}
class PSG_Select_AcidCharge : inventory {default{inventory.maxamount 1;}}
class PSG_Select_SwarmCharge : inventory {default{inventory.maxamount 1;}}
class PSG_Select_Detonator : inventory {default{inventory.maxamount 1;}}
class RemoteChargeDetonator : inventory {default{inventory.maxamount 1;}}

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

	bool laserActive;
	const ROCKET_AMMO = "PB_RocketAmmo";
	const MAGAZINE_SIZE = 9;
	const SPECIAL_LAYER = -15;

	enum psgSpecials
	{
		CLOSE_WHEEL,
		TOGGLE_LASER,
		TRY_TRIPMINE,
		LASERCHARGE,
		ACIDCHARGE,
		SWARMCHARGE,
		DETONATOR
	}

	enum specialsAmmoTake : int
	{
		TRIPMINE_TAKE 		= 5,
		LASERCHARGE_TAKE 	= 8,
		ACIDCHARGE_TAKE 	= 3,
		SWARMCHARGE_TAKE 	= 12
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
				PB_HandleCrosshair(46);
			}
			TNT1 A 0 handleSpecial();
		SwitchAnimation:
			XG51 ABCDEFG 1;
			XG51 GFEDCBA 1;
			Goto Ready3;

		DetonatorOverlay:
			DETO ABCDE 1;
			TNT1 A 0 {
                A_startsound("bepbep",6);
				A_GiveInventory("RemoteChargeDetonator",1);
			}
			DETO FG 3;
			TNT1 A 0 A_TakeInventory("RemoteChargeDetonator",1);
			DETO EDCBA 1;
			Stop;

		CacheSprites:
			LSRC A 0; REMT A 0; SWRM A 0;
		ThrowCharges:
			REMT ABCD 1 throwChargesSprite();
			REMT EFG 1 throwChargesSprite();
			REMT HIJKLMNOPQ 1 throwChargesSprite();
			THRO ABCD 1;
			TNT1 A 0 throwCharges();
			THRO EEEEFGHI 1;
			Goto SelectAnimation;

		TripMineOverlay:
			TRPM FEDCBBBB 1;
			TRPM B 1 {
				FLineTraceData wallinmyway;
				invoker.owner.LineTrace(invoker.owner.angle, 64, invoker.owner.pitch, 0, offsetz: 12, data: wallinmyway);
				if (wallinmyway.HitType == TRACE_HitWall)
				{
					A_fireprojectile("TripMineProjectile",spawnofs_xy:0,spawnheight:-4);
					A_TakeInventory(ROCKET_AMMO,TRIPMINE_TAKE);
					return ResolveState("Placedsuccesfully");
				}
				Return resolvestate(null);
			}
			TRPM BBBMNOPQ 1;
			Stop;
			
		Placedsuccesfully:
			TRPM GGGGGHIJKL 1;
			Stop;

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


