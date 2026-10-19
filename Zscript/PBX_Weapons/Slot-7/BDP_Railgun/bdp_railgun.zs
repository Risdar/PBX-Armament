// Railgun 
// From Brutal Doom Platinum made by Dox778, EmeraldCoastt and the BDP Team

// Includes
#include "./bdprailgun_Functions.zs"
#include "./bdprailgun_Wheel.zs"
#include "./bdprailgun_helpers.zs"

// Tokens
class killhologram : inventory {default{inventory.maxamount 1;}}
class platRailgun_goHolo : inventory {default{inventory.maxamount 1;}}

Class PBX_BDPRailgun : PBX_WeaponBase
{
    Default
    {
        Weapon.AmmoGive1 40;
		Weapon.AmmoType2 "BDPRailgunAmmo";
		Weapon.AmmoType1 "PB_Cell";
		PB_WeaponBase.ReserveToMagAmmoFactor 10;
        PB_WeaponBase.UsesWheel false; // We dont want the player to be able to use the wheel on start
        PB_WeaponBase.WheelInfo "BDPRailgun_Wheel";
        PBX_WeaponBase.ScopeConfiguration true, MINZOOM, MAXZOOM; 
        PB_WeaponBase.MuzzleSmokeColor "618DB8";
		Obituary "$OB_WEAP_RAILGUN";
		Inventory.PickupSound "PLSDRAW";
		Inventory.Pickupmessage "$PBX_BDPRailgun_Pickup";
		DamageType "Railgun";
		Inventory.AltHUDIcon "XBDRA0";
		Tag "$PBX_BDPRailgun_Tag";
        scale 1.0;
    }

    PBX_Hologram hologram;
    int hologramCooldown;
    double zoomstrength;

    const MAGAZINE_SIZE = 5;
    const bdpraildamage = 500;
    const MINZOOM = 2.0;
    const MAXZOOM = 15.0;
    const HANDLE_LAYER = -5;
    const MUZZLE_LAYER = -2;

    States
    {
        Spawn:
            XBDR A -1;
            Stop;

        WeaponRespect:
            RAIS DDDCCCBBBA 1 A_DoPBWeaponAction();
            RAIL A 10 A_DoPBWeaponAction();
			TNT1 A 0 A_PlaySoundEx("Ironsights", "Auto");
            // Raise
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol");
			RAIL FGHI 1 A_DoPBWeaponAction();
			RAIL JKLMNNOOO 1 A_DoPBWeaponAction();
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol2");
			RAIL OOOO 1 A_DoPBWeaponAction();
			TNT1 A 0 A_StartSound("RAILMAG2", 5);
            // Rechamber
			RAIL PR 1 A_DoPBWeaponAction();
			RAIL TWWVUUUUUU 1 A_DoPBWeaponAction();
            // Put Shells In
            TNT1 A 0 A_PlaySoundEx("Ironsights", "Auto");
			RAIL X 7 {
                A_overlay(HANDLE_LAYER,"ReloadingHand2");
                return A_DoPBWeaponAction();
            }
			RAIR AB 1 A_DoPBWeaponAction();
			RAIR BA 1 A_DoPBWeaponAction();
			RAIL X 4 A_DoPBWeaponAction();
            RAIL WWVV 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("RAILINSR", 5);
			RAIL UUUTTSRQP 1 A_DoPBWeaponAction();
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol2reverse");
			RAIL OOOOONMLKJ 1 A_DoPBWeaponAction();
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlolreverse");
			RAIL IHGF 1 A_DoPBWeaponAction();
            Goto Ready3;

        WeaponInspect:
            // Raise
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol");
			RAIL FGHI 1 A_DoPBWeaponAction();
			RAIL JKLMNNOOO 1 A_DoPBWeaponAction();
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol2");
			RAIL OOOO 1 A_DoPBWeaponAction();
			TNT1 A 0 A_StartSound("RAILMAG2", 5);
            // Rechamber
			RAIL PR 1 A_DoPBWeaponAction();
			RAIL TWWVUUUUUU 1 A_DoPBWeaponAction();
        HoldInspect:
            RAIL U 1 A_DoPBWeaponAction();
            "####" A 0 A_JumpIf(PressingReload(),"HoldInspect");
            TNT1 A 0 A_StartSound("RAILINSR", 5);
			RAIL UUUTTSRQP 1 A_DoPBWeaponAction();
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol2reverse");
			RAIL OOOOONMLKJ 1 A_DoPBWeaponAction();
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlolreverse");
			RAIL IHGF 1 A_DoPBWeaponAction();
            Goto Ready3;

        Deselect:
			TNT1 A 0 {
				PBX_WeaponLower();
                A_ClearOverlays(HANDLE_LAYER);
                PB_SetUsableWheel(false);
			}
			RAIS EFGH 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
                A_ClearOverlays(HANDLE_LAYER);
			    PB_HandleCrosshair(97);
                PBX_WeaponRaise("RAILINSR");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            RAIS DCBA 1;
        Ready3:
            TNT1 A 0 {
                PB_SetUsableWheel(false);
                PB_HandleCrosshair(97);
            }
        ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
            RAIL A 1 {
                A_ZoomFactor(1.0);
                PB_Cooldownbarrel();
			    return A_DoPBWeaponAction();
            }
            loop;

        Ready2:
            TNT1 A 0 {
                PB_SetUsableWheel(true);
                A_SetCrosshair(-1);
            }
        ReadyToFire2:
            SNIP C 1 Bright {
				PB_CoolDownBarrel();
                A_ZoomFactor(PBX_GetZoomLevel());
                PBX_ReadySmartScope("Blue");
				return PB_ReadyFire(ads:true);
            }
            loop;

        NoAmmo:
            // TNT1 A 0 A_Dryfire("RAILDRY", 1);
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Ready2");
            Goto Ready3;

        Fire:
            TNT1 A 0 {
				PB_SetRoll(0);
				PB_HandleCrosshair(97);
                A_ClearOverlays(HANDLE_LAYER);
			}
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Fire2");
        Fire1Actual:
			// TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"Pumping");
			TNT1 A 0 PB_JumpIfNoAmmo(emptysound:"RAILDRY");
			RAIF A 1
			{
				for(int i = 0; i < 11; i++)
				{
					A_Fireprojectile ("BluePlasmaParticleWeapon", random(-60,60), 0, -1, -3, 0, random(-6,70));
				}
				A_overlay(HANDLE_LAYER,"DoNothing");
				A_firenurailgun();
				A_zoomfactor(0.7);
                A_FlashOverlay(MUZZLE_LAYER);
				A_GunLight();
			}
			RAIF B 1 {
				A_GunLight();
				A_zoomfactor(1.0);
			}
			RAIF CDEFG 1;
			RAIL BCDEBCDEBCDEBCDE 1 A_DoPBWeaponAction(WRF_NOFIRE| WRF_NOBOB);
			// TNT1 A 0 PB_JumpIfNoAmmo(emptysound:"RAILDRY");
		Pumping:
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol");
			RAIL FGHI 1;
			RAIL JKLMNNOOO 1;
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol2");
			RAIL OOOO 1;
			TNT1 A 0 A_StartSound("RAILMAG2", 5);
			RAIL PR 1;
			TNT1 A 0  {
				If(PB_GetChamberEmpty())
				{
					A_startsound("Railgun/Eject",2);
					A_FireProjectile("SpentRailgunShell",0,0,0,0,0,0);
				    if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
				}
			}
			RAIL TWWVUUUUUUUUUUUUUUU 1 {
				If(PB_GetChamberEmpty()) 
                {
                    PB_GunSmoke(0, 0, 0);
                    PB_GunSmoke(0, 0, 0);
                    PB_GunSmoke(0, 0, 0);
                }
            }
			TNT1 A 0 {
				if(invoker.ammo2.amount < 1) return resolvestate("ReloadFromPump");
				else return resolvestate(null);
			}
			TNT1 A 0 {
                if(invoker.ammo2.amount < MAGAZINE_SIZE && invoker.ammo1.amount >= invoker.ReserveToMagAmmoFactor) 
                    return A_PressingReload("ReloadFromPump");
                return resolvestate(null);
            }
			Goto FinishPump2;

		FinishPump:
			RAIL WWVV 1;
		FinishPump2:
			TNT1 A 0 A_StartSound("RAILINSR", 5);
			RAIL UUUUUTTSRQP 1;
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol2reverse");
			RAIL OOOOONMLKJ 1;
			TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlolreverse");
			RAIL IHGF 1;
			TNT1 A 0 PB_Refire();
			Goto Ready3;

        Fire2:
            TNT1 A 0 {
				PB_SetRoll(0);
				A_SetCrosshair(-1);
			}
        Fire2Actual:
            TNT1 A 0 PB_JumpIfNoAmmo(emptysound:"RAILDRY");
            SNIP B 30 Bright {
                A_firenurailgun();
                A_GunLight();
            }
            // TNT1 A 0 PB_JumpIfNoAmmo();
        FireAimCont:
            TNT1 A 0 A_StartSound("RAILMAG2", 5);
            SNIP BB 1 BRIGHT;
            TNT1 A 0 {
                A_startsound("Railgun/Eject",2); 
				PB_SpawnCasing("SpentRailgunShell",-15,-5,26,0,3,3);
				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
            }
            SNIP AAAAAAAAAAAAAAAAAAA 1 BRIGHT PB_GunSmoke(0,0,0);
            SNIP AAAA 1 BRIGHT;
            TNT1 A 0 A_StartSound("RAILINSR", 5);
            SNIP CCCCCCCCCC 1 BRIGHT;
            TNT1 A 0 PB_Refire();
            Goto Ready2;

        AltFire:
			TNT1 A 0 A_Jumpif(PB_GetZoom(),"ZoomOut");
        ZoomIn:
            TNT1 A 0 {
                A_overlay(HANDLE_LAYER,"DoNothing");
			    A_startsound("BEP",29);
                A_SetCrosshair(-1);
                PB_SetZoom(true);
                PB_SetUsableWheel(true);
            }
            TNT1 A 0 A_ZoomFactor(1.5);
            RAIZ ABC 1;
            TNT1 A 0 A_ZoomFactor(PBX_GetZoomLevel());
            RAIZ DEF 1;
			Goto Ready2;

        ZoomOut:
            TNT1 A 0 {
			    A_startsound("BEP",29);
                PB_HandleCrosshair(97);
                PB_SetUsableWheel(false);
            }
            TNT1 A 0 A_ZoomFactor(1.5);
            RAIZ FE 1;
            TNT1 A 0 PB_SetZoom(false);
            RAIZ DCBA 1;
            Goto Ready3;

        ReloadFromADS:
            TNT1 A 0 {
			    A_startsound("BEP",29);
                PB_HandleCrosshair(97);
                PB_SetUsableWheel(false);
            }
            TNT1 A 0 A_ZoomFactor(1.5);
            RAIZ FE 1;
            TNT1 A 0 PB_SetZoom(false);
            RAIZ DCBA 1;
        Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
			TNT1 A 0 {
                A_ZoomFactor(1.0);
			}
            TNT1 A 0 PB_CheckReload(null,null,"Pumping","Ready3","Ready3",MAGAZINE_SIZE);
			TNT1 A 0 A_PlaySoundEx("Ironsights", "Auto");
            TNT1 A 0 A_overlay(HANDLE_LAYER,"pumpinghandlol");
			RAIL FGHIJKLMNNOOO 1;
        ShellChecker:
            // Main reload loop
			TNT1 A 0 A_JumpIf(invoker.ammo1.amount < 1 || invoker.ammo2.amount >= MAGAZINE_SIZE,"ReloadFinished");
			RAIL O 7 {
                A_overlay(HANDLE_LAYER,"ReloadingHand2");
                return A_DoPBWeaponAction(WRF_NOBOB);
            }
			RAIR CD 1 A_DoPBWeaponAction(WRF_NOBOB);
			TNT1 A 0 {
                A_Giveinventory(invoker.ammo2.getClassName(),1);
				A_Takeinventory(invoker.ammo1.getClassName(),invoker.ReserveToMagAmmoFactor,TIF_NOTAKEINFINITE);
                PB_SetChamberEmpty(false);
				PB_SetMagEmpty(false);
            }
			RAIR DC 1 A_DoPBWeaponAction(WRF_NOBOB);
			RAIL O 4 A_DoPBWeaponAction(WRF_NOBOB);
			Loop;

		ReloadFinished:
			RAIL OOOOONMLKJ 1;
			TNT1 A 0 {
				A_PlaysoundEx("Ironsights", "Auto");
                A_overlay(HANDLE_LAYER,"pumpinghandlolreverse");
            }
			RAIL IHGF 1;
			TNT1 A 0 PB_SetReloading(false);
			Goto Ready3;

        ReloadFromPump:
			TNT1 A 0  {
                PB_SetZoom(false);
                A_SetCrosshair(-1);
                A_overlay(HANDLE_LAYER,"ReloadingHand1");
			}
            TNT1 A 0 PB_CheckReload(null,null,"Pumping","Ready3","Ready3",MAGAZINE_SIZE);
			TNT1 A 0 A_PlaySoundEx("Ironsights", "Auto");
			RAIL X 4;
		ReloadFromPumpInsertShells:
			TNT1 A 0 A_JumpIf(invoker.ammo1.amount < 1 || invoker.ammo2.amount >= MAGAZINE_SIZE,"FinishReloadFromPump");
			RAIL X 7 {
                A_overlay(HANDLE_LAYER,"ReloadingHand2");
                return A_DoPBWeaponAction(WRF_NOBOB);
            }
			RAIR AB 1 A_DoPBWeaponAction(WRF_NOBOB);
			TNT1 A 0 {
                A_Giveinventory(invoker.ammo2.getClassName(),1);
				A_Takeinventory(invoker.ammo1.getClassName(),invoker.ReserveToMagAmmoFactor,TIF_NOTAKEINFINITE);
                PB_SetChamberEmpty(false);
				PB_SetMagEmpty(false);
            }
			RAIR BA 1 A_DoPBWeaponAction(WRF_NOBOB);
			RAIL X 4 A_DoPBWeaponAction(WRF_NOBOB);
            Loop;

        FinishReloadFromPump:
			TNT1 A 0 A_overlay(HANDLE_LAYER,"ReloadingHand3");
			RAIL X 4;
			Goto FinishPump;

        WeaponSpecial:
            TNT1 A 0 {
				A_Takeinventory("GoWeaponSpecialAbility",1);
                // Go to weapon wheel handler if in ADS
                if(PB_GetZoom()) return Railgun_HandleSpecial();
                return ResolveState(null);
            }
            // Otherwise go and do hologram spawn
            TNT1 A 0 A_SpawnHologram();
		    Goto Ready3;
            
        // FLASH STATES
        MuzzleFlash:
			P1SF D 1 BRIGHT {A_SetWeaponFrame(3 + random(0, 2)); A_GunFlash();}
			P1SF G 1 BRIGHT {A_SetWeaponFrame(6 + random(0, 2)); A_GunFlash();}
            stop;

        FlashPunching:
            TNT1 A 0 PB_SetUsableWheel(false);
            RAIK ABCD 1;
            RAIK E 6;
            RAIK DCBA 1;
            goto Ready3;

		FlashKicking:
            TNT1 A 0 PB_SetUsableWheel(false);
			RAIK ABCD 1;
            RAIK E 7;
            RAIK DCBA 1;
			goto Ready3;
			
		FlashAirKicking:
            TNT1 A 0 PB_SetUsableWheel(false);
			RAIK ABCD 1;
            RAIK E 8;
            RAIK DCBA 1;
			goto Ready3;
			
		FlashSlideKicking:
            TNT1 A 0 PB_SetUsableWheel(false);
			RAIK ABCD 1;
            RAIK E 19;
            RAIK DCBA 1;
			goto Ready3;
			
		FlashSlideKickingStop:
            TNT1 A 0 PB_SetUsableWheel(false);
			RAIK ABCDEEE 1; //7 frames 
			goto Ready3;

        Pumpinghandlol:
            TNT1 A 0 A_StartSound("foley/ShotgunReloadRaise", 6);
            RAIH ABCD 1;
            Stop;
        Pumpinghandlol2:
            RAIH IHFE 1;
            Stop;
        Pumpinghandlolreverse:
            TNT1 A 0 A_StartSound("foley/ShotgunReloadLower", 6);
            RAIH DCBA 1;
            Stop;
        Pumpinghandlol2reverse:
            RAIH FHI 1;
            Stop;
        ReloadingHand1:
            RAIH JKLM 1;
            Stop;
        ReloadingHand3:
            RAIH MLKJ 1;
            Stop;
        ReloadingHand2:
            TNT1 A 5;
            TNT1 A 0 A_startsound("Railgun/Insert",3,CHANF_OVERLAP);
            RAIH RQPONN 1;
            RAIH STUV 1;
            Stop;

    }
}