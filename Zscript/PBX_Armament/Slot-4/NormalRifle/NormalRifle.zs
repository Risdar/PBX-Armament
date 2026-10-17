// Assault rifle 
// From old version of BD and Brutal Doom Platinum
// Dox778 (Animations)
// Metalman (Sprite Edit and New Frames)
// Mike12 (Original Sprites)
// Craneo (ADS Sprites)

// Includes
#include "./NormalRifle_Functions.zs"
#include "./NormalRifle_Wheel.zs"

class NR_Select_FireMode : inventory {default{inventory.maxamount 1;}}
class NR_Select_DualWield : inventory {default{inventory.maxamount 1;}}

Class PBX_NormalRifle : PBX_WeaponBase
{
    Default
    {
        inventory.pickupsound "CLIPIN";
        inventory.pickupmessage "$PBX_NormalRifle_Pickup";
        Inventory.AltHudIcon "RIFXA0";
        Inventory.MaxAmount 2;
        Inventory.Amount 1;

        weapon.ammotype1 "PB_HighCalMag";
        weapon.ammogive1 32;
        weapon.ammotype2 "NormalRifleAmmo";
        PB_WeaponBase.AmmoTypeLeft "NormalRifleLeftAmmo";

        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "NormalRifleWheel";
		PB_WeaponBase.ReserveToMagAmmoFactor 1;
        
		Obituary "$OB_WEAP_ASSAULTRIFLE";
        Tag "$PBX_NormalRifle_Tag";
        scale 0.5;
        +weapon.noalert;
        +weapon.noautofire;
    }

    bool doBurst;
    int burstcount;
    int burstcountLeft;

    const MAGAZINE_SIZE = 31;
    const RIGHT_MUZZLE_LAYER = -6;
    const LEFT_MUZZLE_LAYER = -7;

    States
    {
        Spawn:
            RIFX A -1;
            Stop;

        WeaponRespect:
            RIR3 ABCDEFG 1 A_DoPBWeaponAction();
            RIFR HIJKLMNOPQR 1 A_DoPBWeaponAction();
            RIFL C 0 {
                A_StartSound("weapons/rifle/magin",CHAN_WEAPON,CHANF_OVERLAP);
                return A_DoPBWeaponAction();
            }
            RIFR STUVWXYZ 1 A_DoPBWeaponAction();
            RIFR "[]" 1 A_DoPBWeaponAction();
            RIR2 AB 1 A_DoPBWeaponAction();
            Goto Ready3;

        WeaponInspect:
            RIFL HIJKLMNOP 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
        HoldInspect:
            RIFL P 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            TNT1 A 0 A_StartSound("Sniper/BoltForward",CHAN_AUTO);
            RIFL PONMLKJIH 1 A_DoPBWeaponAction();
            Goto Ready3;

        Deselect:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(55);
                PB_SetZoom(false);
                A_ZoomFactor(1.0);
                PB_ClearDualWield();
			}
            TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "DualWieldDeselect");
        NormalDeselect:
			RIFS ABCDE 1;
			TNT1 A 0 A_Lower();
			Wait;

        DualWieldDeselect:
            DURI BCDEF 1;
        FinishDeselect:
            TNT1 AAAAAAAAAAAAAAAAAA 0 A_Lower();
            Wait;

        SelectAnimationDualWield:
            DURI FEDCB 1;
            TNT1 A 0 A_StartSound("CLIPIN",CHAN_WEAPON,CHANF_OVERLAP);
            Goto ReadyDualWield;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
                PB_ClearDualWield();
			    PB_HandleCrosshair(55);
                PBX_WeaponRaise("CLIPIN");
                invoker.burstcount = 0;
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            TNT1 A 0 PB_SetZoom(false);
		    TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "SelectAnimationDualWield");
            RIFS EDCBA 1;
        Ready3:
			TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "SwitchToDualWield");
			TNT1 A 0 A_JumpIf(PB_GetZoom(), "Ready2");
        ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
            RIFL C 1 {
                PB_CooldownBarrel();
			    PB_HandleCrosshair(55);
                return PB_ReadyFire(ads:false);
            }
            loop;

        Ready2:
            RIFZ D 1 {
                A_SetCrosshair(-1);
                PB_CooldownBarrel();
                return PB_ReadyFire(ads:true);
            }
            loop;

        ReadyDualWield:
			TNT1 A 0 PB_SetupDualWield(crosshair:55);
        ReadyToFireDualWield:
			TNT1 A 1 A_DoPBDualAction();
            Loop;

        IdleLeft_Overlay:
            DURI O 1 {
                PB_CoolDownBarrel(8, -14, 3.2);
                return A_DoPBLeftAction();
            }
            Loop;

		IdleRight_Overlay:
            DURI S 1 {
                PB_CoolDownBarrel(-8, -14, 3.2);
                return A_DoPBRightAction();
            }
            Loop;

        Fire:
			TNT1 A 0 A_JumpIf(PB_GetZoom(), "Fire2");
            TNT1 A 0 {
                PB_HandleCrosshair(55);
				A_WeaponOffset(0, 32);
				PB_SetRoll(0);
				A_ZoomFactor(1.0);
            }
			TNT1 A 0 setBurstCount(0);
        FireLoop:
            TNT1 A 0 PB_JumpIfNoAmmo();
            RIFL D 1 BRIGHT fireweapon(1);
            RIFL E 1        fireweapon(2);
            RIFL F 1        fireweapon(3);
			TNT1 A 0 A_JumpIf(getBurstCount() < 3 && getBurst(), "FireLoop");
        FireEnd:
			TNT1 A 0 setBurstCount(0);
            RIFL G 1;
            RIFL CCC 1 {
                if(!getBurst()) return PB_ReadyFire(ads:false);
                return ResolveState(null);
            }
            Goto Ready3;

        Fire2:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                A_SetCrosshair(-1);
				PB_SetRoll(0);
			}
			TNT1 A 0 setBurstCount(0);
        Fire2Loop:
            TNT1 A 0 PB_JumpIfNoAmmo();
            RIFZ E 1 BRIGHT fireweapon(1);
            RIFZ F 1        fireweapon(2);
            RIFZ G 1;
			TNT1 A 0 A_JumpIf(getBurstCount() < 3 && getBurst(), "Fire2Loop");
        Fire2End:
			TNT1 A 0 setBurstCount(0);
            RIFZ H 1;
            RIFZ DDD 1 {
                if(!getBurst()) return PB_ReadyFire(ads:true);
                return ResolveState(null);
            }
            Goto Ready2;

        FireRight_Overlay:
            TNT1 A 0 setBurstCount(0);
        BurstRight_Overlay:
            DURI P 1 BRIGHT NormalRifle_FireOverlay(1);
            DURI Q 1        NormalRifle_FireOverlay(2);
            DURI R 1        NormalRifle_FireOverlay(3);
			TNT1 A 0 A_JumpIf(getBurstCount() < 3 && getBurst() && !PB_GetChamberEmpty(), "BurstRight_Overlay");
            DURI S 1        NormalRifle_FireOverlay(4);
            DURI SSSS 1 {
                if(!getBurst())
                {
                    return A_DoPBRightAction();
                }
                return ResolveState(null);
            }
            DURI SSS 1 {
                if(!getBurst())
                {
                    return A_RefireRight();
                }
                return ResolveState(null);
            }
            Goto IdleRight_Overlay;

        FireLeft_Overlay:
            TNT1 A 0 setBurstCount(0,true);
        BurstLeft_Overlay:
            DURI L 1 BRIGHT NormalRifle_FireOverlay(1,true);
            DURI M 1        NormalRifle_FireOverlay(2,true);
            DURI N 1        NormalRifle_FireOverlay(3,true);
		    TNT1 A 0 A_JumpIf(getBurstCount(true) < 3 && getBurst() && !PB_GetChamberEmpty(true), "BurstLeft_Overlay");
		    DURI O 1        NormalRifle_FireOverlay(4,true); 
            DURI OOOO 1 {
                if(!getBurst())
                {
                    return A_DoPBLeftAction();
                }
                return ResolveState(null);
            }
            DURI OOO 1 {
                if(!getBurst())
                {
                    return A_RefireLeft();
                }
                return ResolveState(null);
            }
            Goto IdleLeft_Overlay;

        AltFire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                A_SetCrosshair(-1);
            }
			TNT1 A 0 A_Jumpif(PB_GetZoom(),"ZoomOut");
            TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "ReadyToFireDualWield");
        ZoomIn:
            TNT1 A 0 {
                PB_SetZoom(true);
                A_startsound("IronSights",CHAN_AUTO);
                A_SetCrosshair(-1);
				A_ZoomFactor(1.25);
            }
            RIFZ ABC 1;
            RIFZ D 2;
            Goto Ready2;
            
        Zoomout:
            TNT1 A 0 {
                PB_SetZoom(false);
                A_startsound("IronSights",CHAN_AUTO);
            }
            RIFZ CBA 1 A_ZoomFactor(1.0);
			TNT1 A 0 PB_HandleCrosshair(55);
            Goto Ready3;

        Weaponspecial:
			TNT1 A 0 checkSpecial();
        SwitchAnimation:
			TNT1 A 0 {
                if(A_CheckAkimbo())
                {
                    A_startsound("MS/Button",CHAN_AUTO);
                    return ResolveState("ReadyDualWield");
                }
                return ResolveState(null);
            }
	        RIFL RSTUVV 1;
            TNT1 A 0 A_StartSound("MS/Button", CHAN_AUTO, CHANF_OVERLAP);
            RIFL VVUTSR 1;
			goto Ready3;

        SwitchToDualWield:
            DURI TUVWX 1;
		    TNT1 A 0 A_StartSound("CLIPIN",CHAN_AUTO);
            DURI YZ 1;
		    DURI "[]" 1;
            TNT1 A 0 A_SetAkimbo(true);
            Goto ReadyDualWield;

        StopDualWield:
		    DURI "][" 1;
            DURI ZY 1;
		    TNT1 A 0 A_StartSound("CLIPIN",CHAN_AUTO);
            DURI XWVUT 1;
            TNT1 A 0 A_SetAkimbo(false);
            Goto Ready3;

        RaiseFromEmpty:
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            RIFR ABCDEFG 1;
            goto ContinueReload;

        ReloadFromADS:
            TNT1 A 0 {
                PB_SetZoom(false);
                A_startsound("IronSights",CHAN_AUTO);
			    PB_HandleCrosshair(55);
            }
            RIFZ BA 1;
        Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
            TNT1 A 0 A_Zoomfactor(1.0);
            TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "ReloadDualWield");
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null, "ChamberFromReload", "Ready3", "Ready3", MAGAZINE_SIZE);
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            // Raise
            RIR2 BA 1;
            RIFR "][" 1;
		    RIFR ZYXWVVV 1;
            // Remove Mag
		    RIFR UTSRQ 1;
            TNT1 A 0 {
                A_StartSound("weapons/rifle/magout",CHAN_WEAPON,CHANF_OVERLAP);
                if(PB_GetMagEmpty()) PB_SpawnCasing("EmptyDMRMag",38,26,7,frandom(0, 3.5),frandom(-7.2, -3.3),frandom(3,7));
                PB_SetMagUnloaded(true);
            }
            // Put Away Mag
            RIFR PONMLKJIHG 1;
            RIFR G 10;
        ContinueReload:
            // Insert Mag
            TNT1 A 0 A_StartSound("weapons/rifle/magchange",CHAN_WEAPON,CHANF_OVERLAP);
            RIFR HIJKLMNN 1;
            RIFR OP 1;
            RIFR Q 3;
            RIFR R 1;
            TNT1 A 0 A_StartSound("weapons/rifle/magin",CHAN_WEAPON,CHANF_OVERLAP);
            RIFR S 1 {
				PB_AmmoIntoMag(
                    invoker.ammo2.getclassname(), 
                    invoker.ammo1.getclassname(), 
                    PB_GetChamberEmpty() ? MAGAZINE_SIZE - 1 : MAGAZINE_SIZE);
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
            }
            RIFR STU 1;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(), "Rechamber");
            RIFR V 4;
            RIFR WXYZ 1;
        FinishReload:
            RIFR "[]" 1;
            RIR2 AB 1;
            goto Ready3;

        ChamberFromReload:
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
            RIFL HIJKLMNOP 1;
            TNT1 A 0 PB_SetChamberEmpty(false);
            TNT1 A 0 A_StartSound("Sniper/BoltForward",CHAN_AUTO);
            RIFL PONMLKJIH 1;   
            goto Ready3;

        Rechamber:
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            RIFR W 1;
            RIR2 CDEFGHII 1;
            RIR2 J 3;
            RIR2 LM 1;
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
            TNT1 A 0 PB_SetChamberEmpty(false);
            RIR2 N 4;
            RIR2 OPQ 1;
            TNT1 A 0 A_StartSound("Sniper/BoltForward",CHAN_AUTO);
            RIR2 R 3;
            RIR2 SSTUV 1;
            goto FinishReload;

        ReloadUnloadLeft:
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            RIR5 DEFG 1;
            goto ContinueReloadLeft;

        ReloadDualWield:
            TNT1 A 0 PB_ClearDualWield();
            TNT1 A 0 PB_CheckReload("ReloadUnloadRight",null,"StartRechamberRight","CheckLeftRel","ReadyDualWield",MAGAZINE_SIZE);
            // Deselect Dual Wield
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            DURI "][" 1;
            DURI ZY 1;
		    TNT1 A 0 A_StartSound("CLIPIN",CHAN_AUTO);
            DURI XWVUT 1;
            RIFL C 2;
            // Raise Right
            RIR3 ABC 1;
            RIR3 VUTS 1;
            // Remove Right Mag
            RIR3 RQP 1;
            TNT1 A 0 {
                A_StartSound("weapons/rifle/magout",CHAN_WEAPON,CHANF_OVERLAP);
                if(PB_GetMagEmpty()) PB_SpawnCasing("EmptyDMRMag",38,26,7,frandom(0, 3.5),frandom(-7.2, -3.3),frandom(3,7));
                PB_SetMagUnloaded(true);
            }
            RIR3 ONMLKJIHG 1;
            RIR3 G 10;
        ContinueReloadRight:
            // Insert Right Mag
            TNT1 A 0 A_StartSound("weapons/rifle/magchange",CHAN_WEAPON,CHANF_OVERLAP);
            RIR3 GHIJKLMNOPQR 1;
            RIR3 S 1 {
                A_StartSound("weapons/rifle/magin",CHAN_WEAPON,CHANF_OVERLAP);
				PB_AmmoIntoMag(
                    invoker.ammo2.getclassname(), 
                    invoker.ammo1.getclassname(), 
                    PB_GetChamberEmpty() ? MAGAZINE_SIZE - 1: MAGAZINE_SIZE
                );
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
            }
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(), "RechamberRight");
            RIR3 TU 1;
            RIR3 VW 1;
        FinishReloadRight:
            RIR3 XYZ 1;
            // Lower Right
            RIR3 "[]" 1;
            RIR4 A 1;
            RIR4 B 5;
			goto CheckLeftRel;

        ReloadUnloadRight:
            // Deselect Dual Wield
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            DURI "][" 1;
            DURI ZY 1;
		    TNT1 A 0 A_StartSound("CLIPIN",CHAN_AUTO);
            DURI XWVUT 1;
            RIFL C 2;
            // Raise
            RIR3 DEFG 1;
            goto ContinueReloadRight;

        StartRechamberRight:
            // Deselect Dual Wield
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            DURI "][" 1;
            DURI ZY 1;
		    TNT1 A 0 A_StartSound("CLIPIN",CHAN_AUTO);
            DURI XWVUT 1;
            RIFL C 2;
            // Raise Right
            RIR3 ABC 1;
            RIR3 VU 1;
        RechamberRight:
            // Rechamber Right
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            RIFR W 1;
            RIR2 CDEFGHII 1;
            RIR2 J 3;
            RIR2 LM 1;
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
            TNT1 A 0 PB_SetChamberEmpty(false);
            RIR2 N 4;
            RIR2 OPQ 1;
            TNT1 A 0 A_StartSound("Sniper/BoltForward",CHAN_AUTO);
            RIR2 R 3;
            RIR2 SSTUV 1;
			goto CheckLeftRel;

        CheckLeftRel:
            TNT1 A 0 {
				if(invoker.ammoleft.amount == MAGAZINE_SIZE)
                {
                    PB_SetReloading(false);
                    return resolvestate("SwitchToDualWield");
                }
				return resolvestate(null);
			}
			goto ReloadLeft;

        ReloadLeft:
            TNT1 A 0 PB_CheckReload("ReloadUnloadLeft",null,"StartRechamberLeft","ReadyDualWield","ReadyDualWield",MAGAZINE_SIZE,invoker.reservetomagammofactor,true);
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            // Raise Left
            RIR5 ABC 1;
			RIR5 ZYX 1;
            RIR5 WVUTS 1;
            // Remove Left Mag
            RIR5 RQP 1;
            TNT1 A 0 {
                A_StartSound("weapons/rifle/magout",CHAN_WEAPON,CHANF_OVERLAP);
                if(PB_GetMagEmpty(true)) PB_SpawnCasing("EmptyDMRMag",38,26,7,frandom(0, 3.5),frandom(-7.2, -3.3),frandom(3,7));
                PB_SetMagUnloaded(true,true);
            }
            RIR5 ONMLKJIHG 1;
            RIR5 G 10;
        ContinueReloadLeft:
            TNT1 A 0 A_StartSound("weapons/rifle/magchange",CHAN_WEAPON,CHANF_OVERLAP);
            // Insert Left Mag
            RIR5 GHIJKLMNOPQR 1;
            RIR5 S 1 {
                A_StartSound("weapons/rifle/magin",CHAN_WEAPON,CHANF_OVERLAP);
				PB_AmmoIntoMag(
                    invoker.ammoleft.getclassname(), 
                    invoker.ammo1.getclassname(), 
                    PB_GetChamberEmpty(true) ? MAGAZINE_SIZE - 1: MAGAZINE_SIZE
                );
                PB_SetMagEmpty(false,true);
                PB_SetMagUnloaded(false,true);
            }
            RIR5 TUVW 1;
            RIR5 XYZ 1;
        FinishReloadLeft:
            // Lower Left
            RIR5 "[]" 1;
            RIR6 A 1;
            RIR6 B 5;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(true), "StartRechamberLeft");
            TNT1 A 0 PB_SetReloading(false);
            goto Ready3;

        StartRechamberLeft:
            // Raise Left
            RIR3 ABC 1;
            RIR3 VU 1;
        RechamberLeft:
            // Rechamber Left
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            RIFR W 1;
            RIR2 CDEFGHII 1;
            RIR2 J 3;
            RIR2 LM 1;
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
            TNT1 A 0 PB_SetChamberEmpty(false,true);
            RIR2 N 4;
            RIR2 OPQ 1;
            TNT1 A 0 A_StartSound("Sniper/BoltForward",CHAN_AUTO);
            RIR2 R 3;
            RIR2 SSTUV 1;
            // Lower Left
            RIR3 "[]" 1;
            RIR4 A 1;
            RIR4 B 5;
            TNT1 A 0 PB_SetReloading(false);
            goto Ready3; // So it jumps to select dual wield animation

        Unload:
            TNT1 A 0 {
				A_WeaponOffset(0, 32);
                A_ZoomFactor(1.0);
                PB_SetZoom(false);
                PB_SetRoll(0);
            }
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "UnloadDualWield");
            TNT1 A 0 A_JumpIf(PB_GetMagUnloaded() && !PB_GetChamberEmpty(), "UnloadChamber");
            // Raise
            RIR2 BA 1;
            RIFR "][" 1;
		    RIFR ZYXWVVV 1;
		    RIFR UTSRQ 1;
            TNT1 A 0 A_StartSound("weapons/rifle/magout",CHAN_WEAPON,CHANF_OVERLAP);
            // Remove Mag
            RIFR PONMLKJIHG 1;
            TNT1 A 0 {
                A_StartSound("weapons/rifle/magchange",CHAN_WEAPON,CHANF_OVERLAP);
                if(PB_GetMagEmpty()) PB_SpawnCasing("EmptyDMRMag",38,26,7,frandom(0, 3.5),frandom(-7.2, -3.3),frandom(3,7));
                PB_UnloadMag(
                    invoker.ammo2.getclassname(),
                    invoker.ammo1.getclassname(),
                    goal:PB_GetChamberEmpty() ? 0 : 1
                );
                PB_SetMagUnloaded(true);
                PB_SetMagEmpty(true);
            }
            // Lower
            RIFR GFEDCBA 1;
            RIR2 B 1;
        UnloadChamber:
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
            RIFL HIJKLMNOP 1;
            TNT1 A 0 {
                A_StartSound("Sniper/BoltForward",CHAN_AUTO);
                PB_SetChamberEmpty(true);
                PB_UnloadMag(invoker.ammotype2,invoker.ammotype1,1,1,0,0,"PB_HighCalRound");
            }
            RIFL PONMLKJIH 1;
            goto Ready3;

        UnloadDualWield:
            TNT1 A 0 PB_ClearDualWield();
            TNT1 A 0 A_JumpIf(PB_GetMagUnloaded(),"UnloadLeft");
            // Deselect Dual Wield
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            DURI "][" 1;
            DURI ZY 1;
		    TNT1 A 0 A_StartSound("CLIPIN",CHAN_AUTO);
            DURI XWVUT 1;
            RIFL C 1;
            // Raise
            RIR3 ABC 1;
            RIR3 VUTS 1;
            // Remove Right Mag
            RIR3 RQP 1;
            TNT1 A 0 {
                A_StartSound("weapons/rifle/magout",CHAN_WEAPON,CHANF_OVERLAP);
                if(PB_GetMagEmpty()) PB_SpawnCasing("EmptyDMRMag",38,26,7,frandom(0, 3.5),frandom(-7.2, -3.3),frandom(3,7));
                PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname());
                PB_SetMagEmpty(true);
                PB_SetMagUnloaded(true);
                PB_SetChamberEmpty(true);
            }
            // Lower Right
            RIR3 ONMLKJIHG 1;
            RIR3 FEDCBA 1;
            TNT1 A 0 A_JumpIf(PB_GetMagUnloaded(true),"Ready3");
            Goto UnloadLeft;

        UnloadLeft:
            // Raise Left
            RIR5 ABC 1;
			RIR5 ZYX 1;
            RIR5 WVUTS 1;
            // Put Away Left Mag
            RIR5 RQP 1;
            TNT1 A 0 {
                A_StartSound("weapons/rifle/magout",CHAN_WEAPON,CHANF_OVERLAP);
                if(PB_GetMagEmpty(true)) PB_SpawnCasing("EmptyDMRMag",38,26,7,frandom(0, 3.5),frandom(-7.2, -3.3),frandom(3,7));
                PB_UnloadMag(invoker.ammoleft.getclassname(),invoker.ammo1.getclassname());
                PB_SetMagEmpty(true,true);
                PB_SetMagUnloaded(true,true);
                PB_SetChamberEmpty(true,true);
            }
            RIR5 ONMLKJIHG 1;
            RIR5 FED 1;
            TNT1 A 0 PB_SetReloading(false);
            Goto Ready3;

        // Unused
        // MuzzleFlash:
        // MuzzleFlash1:
		//     TNT1 A 0 A_Jump(256, "MuzzleFlash1a", "MuzzleFlash1b");
        // MuzzleFlash1a:
        //     MZ01 ABC 1 BRIGHT A_GunFlash();
        //     Stop;
        // MuzzleFlash1b:
        //     MZ01 DEF 1 BRIGHT A_GunFlash();
        //     Stop;

        LeftMuzzleFlash:
            MZ42 A 1 BRIGHT A_SetWeaponFrame(random[sfx](0,4));
            MZ42 F 1 BRIGHT A_SetWeaponFrame(random[sfx](5,9));
            stop;

        RightMuzzleFlash:
            MZ43 A 1 BRIGHT A_SetWeaponFrame(random[sfx](0,4));
            MZ43 F 1 BRIGHT A_SetWeaponFrame(random[sfx](5,9));
            stop;

        FlashPunching:
            TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "FlashPunchingAkimbo");
	        RIFL RSTUVVVVVVVVUTSR 1;
            goto Ready3;

        FlashPunchingAkimbo:
            TNT1 A 0 PB_ClearDualWield();
            TNT1 A 14;
            goto Ready3; // So it plays the switch to dual animation

		FlashKicking:
            TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "FlashKickingAkimbo");
	        RIFL RSTUVVVVVVVVUTSR 1;
			goto Ready3;

        FlashKickingAkimbo:
            TNT1 A 0 PB_ClearDualWield();
            DURI GHIJKKKKKKKKJIHG 1;
            goto ReadyDualWield;
			
		FlashAirKicking:
            TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "FlashAirKickingAkimbo");
	        RIFL RSTUVVVVVVVVUTSR 1;
			goto Ready3;

        FlashAirKickingAkimbo:
            TNT1 A 0 PB_ClearDualWield();
            DURI GHIJKKKKKKKKJIHG 1;
            goto ReadyDualWield;
			
		FlashSlideKicking:
            TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "FlashSlideKickingAkimbo");
	        RIFL RSTUVVVVVVVVVVVVVVVVVVVUTSR 1;
			goto Ready3;

        FlashSlideKickingAkimbo:
            TNT1 A 0 PB_ClearDualWield();
            DURI GHIJKKKKKKKKKKKKKKKKKKKJIHG 1;
            goto ReadyDualWield;
			
		FlashSlideKickingStop:
            TNT1 A 0 A_JumpIf(A_CheckAkimbo(), "FlashSlideKickingStopAkimbo");
	        RIFL VVVUTSR 1;
			goto Ready3;

        FlashSlideKickingStopAkimbo:
            TNT1 A 0 PB_ClearDualWield();
	        DURI KKKJIHG 1;
            goto ReadyDualWield;

    }
}