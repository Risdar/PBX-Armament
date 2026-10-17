// Cryo Shotgun 
// From Cat's Frozen Addon Pack
// by SchrödingCat, Eriance/Amuscaria, Realm667
// Bloax, ZZrionTheInsect, Xaser & Ethrill, Tomtefar, SchrödingCat
// Dox778
// Edited by Dreo for Schism and ported to PB by ItAres and updated by 517qwerty

// Includes
// #include "./PlasmaBlaster_Functions.zs"
// #include "./PlasmaBlaster_Projectiles.zs"
#include "./CryoSG_Wheel.zs"

class CryoSG_Select_PlasmaBlast : inventory {default{inventory.maxamount 1;}}
class CryoSG_Select_PlasmaBreath : inventory {default{inventory.maxamount 1;}}
class CryoSG_Select_Freeze : inventory {default{inventory.maxamount 1;}}

// Actual Weapon
class PBX_CryoSG : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "CryoSGWheel";
        PB_WeaponBase.ReserveToMagAmmoFactor 12;
        PBX_WeaponBase.SelectWeaponUpgrade "PBX_CryoASG";
	    Inventory.AltHUDIcon "FZSGA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_Cell";
        Weapon.AmmoType2 "CryoSGAmmo";
        Weapon.AmmoGive1 30;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_CryoSG_Pickup";
        Inventory.PickupSound "M1014RE";
        Obituary "$OB_WEAP_CRYOSG";
        AttackSound "None";
        Tag "$PBX_CryoSG_Tag";
        Scale 0.9;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    int mCurrentMode;

    const MAGAZINE_SIZE = 10;

    enum CryoSGModes {
        ERROR_WHEEL = -2,
        CLOSE_WHEEL,
        PLASMA_BLAST,
        PLASMA_BREATH,
        FREEZE_BLAST
    }
    
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void FireWeapon(int tic)
    {
        switch(tic)
        {
            case 1:
                A_AlertMonsters();
				A_StartSound("weapons/sg",CHAN_WEAPON,CHANF_OVERLAP);
                A_StartSound("weapons/CryoRifle/missile1",CHAN_AUTO,CHANF_OVERLAP);
				FireCurrentMode();
				A_SetInventory("CantDoAction", 1);
				PB_DynamicTail("shotgun", "shotgun");
				PB_SetChamberEmpty(true);
                A_FlashOverlay();
                break;

            case 2:
                PB_SpawnCasing("SubZeroCasing",random(10,14),random(-1,3),random(26,28),random(1,3),random(-5,-2),random(4,7));
				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
                break;
        }
    }

    action void FireCurrentMode()
    {
        int ofs = PB_GetZoom() ? 3 : 6;
        PB_IncrementHeat();
        A_GunFlash();
        PB_FireOffset();
        PB_LowAmmoSoundWarning("shotgun");

        PB_TakeAmmo(invoker.ammo2.getClassName(),1,0);
        A_SpawnItemEx("BlueFlareSpawn", 0, 0, -3);
        A_SpawnItemEx("BlueFlareSpawn", 0, 0, 3);

        switch(getCurrentMode())
        {
            case PLASMA_BLAST:
                PB_FireBullets("Plasma_Ball",6,ofs,0,0,ofs);
                break;

            case PLASMA_BREATH:
				A_StartSound("PLSTHRW",CHAN_WEAPON,CHANF_OVERLAP);
                PBX_FireBullets("HotPlasmaGas",6,ofs,0,0,ofs);
                break;
                
            case FREEZE_BLAST:
                PB_FireBullets("SubZeroProjectile",6,ofs,0,0,ofs);
         		A_FireBullets(8, 6, 6, 18, "SubZ_Puff",FBF_NORANDOM,8192,"CSSG_FrozenTracer",-12);
                break;
        }
    }

    action CryoSGModes getCurrentMode()
	{
		return invoker.mCurrentMode;
	}

	action void setCurrentMode(CryoSGModes mode)
	{
		invoker.mCurrentMode = mode;
	}
    
    action state handleWheel()
    {
        A_TakeInventory("GoWeaponSpecialAbility", 1);
        CryoSGModes tokens = getTokens();
        CryoSGModes curr = getCurrentMode();

        if(tokens == curr || tokens == CLOSE_WHEEL)
        {
            cleanTokens();
			if(tokens == curr) A_Print("$PB_ALREADYSELECTED");
            return PBX_ReturnReady();
        }

        setCurrentMode(tokens);
        printMode(tokens);
        cleanTokens();
        A_StartSound("BEPBEP", CHAN_WEAPON);
        return PBX_ReturnReady(normal:null);
    }

    action void printMode(CryoSGModes mode)
    {
        string str;
        switch(mode)
        {
            case PLASMA_BLAST:  str = "$PBX_CryoSG_PlasmaBlast";    break;
            case PLASMA_BREATH: str = "$PBX_CryoSG_PlasmaBreath";   break;
            case FREEZE_BLAST:  str = "$PBX_CryoSG_Freeze";         break;
        }
        A_Print(str);
    }
    
    action cryoSGModes getTokens()
	{
		if(FindInventory("CryoSG_Select_PlasmaBlast"))
			return PLASMA_BLAST;
		else if(FindInventory("CryoSG_Select_PlasmaBreath"))
			return PLASMA_BREATH;
		else if (FindInventory("CryoSG_Select_Freeze"))
			return FREEZE_BLAST;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
	}

    action void cleanTokens()
    {
        A_SetInventory("CryoSG_Select_PlasmaBlast",0);
        A_SetInventory("CryoSG_Select_PlasmaBreath",0);
        A_SetInventory("CryoSG_Select_Freeze",0);
        A_SetInventory("PBX_CloseWheel",0);
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            FZSG A -1;
            Stop;

        WeaponRespect:
            TNT1 A 0 A_PlaySound("M1014RE",5);
			FZGS ABCDEEEEE 1 A_DoPBWeaponAction();
			FZGA A 1 A_DoPBWeaponAction();
			FZGP ABCDEFGGG 1 A_DoPBWeaponAction();
			FZGP HIJ 1 A_DoPBWeaponAction();
			FZGP K 1 {
                A_PlaySound("Insertshell");
                return A_DoPBWeaponAction();
            }
			FZGP LMN 1 A_DoPBWeaponAction();
			FZGP I 1 A_DoPBWeaponAction();
			FZGP FEDBC 1 A_DoPBWeaponAction();
			FZGR BCD 1 A_DoPBWeaponAction();
			FZGR EFG 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback",CHAN_WEAPON,CHANF_OVERLAP);
            FZGR HIJ 1 A_DoPBWeaponAction();
			FZGR KLM 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward",CHAN_WEAPON,CHANF_OVERLAP);
            FZGR NCBA 1 A_DoPBWeaponAction();
			FZGP BA 1 A_DoPBWeaponAction();
            Goto Ready3;

        WeaponInspect:
			FZGP AB 1 A_DoPBWeaponAction();
			FZGR ABCDE 1 A_DoPBWeaponAction();
			FZGR FFG 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback",CHAN_WEAPON,CHANF_OVERLAP);
            FZGR HIJ 1 A_DoPBWeaponAction();
			FZGR K 1 A_DoPBWeaponAction();
        HoldInspect:
            FZGR L 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward",CHAN_WEAPON,CHANF_OVERLAP);
			FZGR M 1 A_DoPBWeaponAction();
            FZGR NEFFEDCBA 1 A_DoPBWeaponAction();
			FZGP BA 1 A_DoPBWeaponAction();
            Goto Ready3;
        
        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            FZGS EDCBA 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("M1014RE");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            FZGS ABCDE 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Ready2");
            TNT1 A 0 {
                PB_SetRoll(0);
                A_ZoomFactor(1.0);
                PB_HandleCrosshair(46);
				A_SetInventory("CantWeaponSpecial",0);
				A_SetInventory("CantDoAction",0);
                PB_SetReloading(false);
            }
        ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
			FZGA A 1 {
                PB_CoolDownBarrel();
                PB_HandleCrosshair(39);
                return PB_ReadyFire(ads:false);
            }
            loop;

        Ready2:
            TNT1 A 0 {
                PB_SetRoll(0);
                A_SetCrosshair(-1);
				A_SetInventory("CantDoAction",0);
                PB_SetReloading(false);
            }
        ReadyToFire2:
			FZGA E 1 {
                PB_CoolDownBarrel();
                return PB_ReadyFire(ads:true);
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(39);
			}
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Fire2");
		Fire1Actual:
            TNT1 A 0 PB_JumpIfNoAmmo();
			FZGF A 1 BRIGHT FireWeapon(1);
			FZGF B 1 BRIGHT PB_WeaponRecoil(-1.65,0);
			FZGF CDEF 1 PB_WeaponRecoil(-1.65,0);
            TNT1 A 0 PB_SetReloading(true);
			TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"Ready3");
		Pump:
			FZGA A 4;
			FZGP AB 1;
			FZGR ABCDE 1;
		PumpBegin:
			FZGR F 1;
			FZGR FG 1;
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback",CHAN_WEAPON,CHANF_OVERLAP);
            FZGR HIJ 1;
            TNT1 A 0 FireWeapon(2);
			FZGR KL 1;
		PumpEnd:
			FZGR M 1;
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward",CHAN_WEAPON,CHANF_OVERLAP);
            FZGR NEFFEDCBA 1;
			FZGP BA 1;
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
            FZGA F 1 BRIGHT FireWeapon(1);
			FZGA G 1 BRIGHT PB_WeaponRecoil(-1.5,0);
			TNT1 A 0 A_ZoomFactor(1.25);
			FZGA HIJ 1;
            TNT1 A 0 PB_SetReloading(true);
			FZGA E 4;
			TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"Ready3");
        Pump2:
			FZGA K 2;
			FZGA K 1;
			FZGA LMN 1;
            TNT1 A 0 {
                A_StartSound("weapons/spas12/pump",CHAN_WEAPON,CHANF_OVERLAP);
                FireWeapon(2);
            }
			FZGA MLL 1;
			FZGA K 2 {
				if(JustPressed(BT_ATTACK) && invoker.ammo2.amount > 0) return ResolveState("Fire2");
                return ResolveState(null);
			}
			TNT1 A 0 {
                A_SetInventory("CantDoAction",0);
				return PB_ReadyFire(ads:true);
            } 
            Goto Ready2;

//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
			TNT1 A 0 {
				PB_SetRoll(0);
				PB_HandleCrosshair(46);
			}
			TNT1 A 0 A_StartSound("IronSights", CHAN_WEAPON);
			TNT1 A 0 A_JumpIf(PB_GetZoom(),"Zoomout");
		ZoomIn:
			TNT1 A 0 A_ZoomFactor(1.25);
			FZGA ABCDE 1;
			TNT1 A 0 {
                PB_SetZoom(true);
                A_SetCrosshair(-1);
			}
			Goto Ready2;
			
		ZoomOut:
			TNT1 A 0 {	
				PB_HandleCrosshair(46);
				A_ZoomFactor(1.0);
            }
			FZGA DCB 1;
			TNT1 A 0 PB_SetZoom(false);
			Goto Ready3;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
        ReloadFromADS:
			TNT1 A 0 PB_HandleCrosshair(42);
			TNT1 A 0 A_startsound("IronSights",29);
            TNT1 A 0 A_ZoomFactor(1.25);
			FZGA DCB 1;
			TNT1 A 0 PB_SetZoom(false);
			FZGA A 1;
		Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
			TNT1 A 0 {
                A_ZoomFactor(1.0);
			}
            TNT1 A 0 PB_CheckReload(null,null,"Pump","Ready3","Ready3",MAGAZINE_SIZE);
			TNT1 A 0 A_PlaySoundEx("Ironsights", "Auto");
            // Raise Weapon
            FZGP ABCDEFGGG 1;
        ShellChecker:
            // Main reload loop
			TNT1 A 0 A_JumpIf(invoker.ammo1.amount < 1 || invoker.ammo2.amount >= MAGAZINE_SIZE,"FinishReload");
            FZGP HIJ 1 A_DoPBWeaponAction(WRF_NOBOB);
            FZGP K 1 {
                A_PlaySound("weapons/spas12/insert", CHAN_AUTO);
				A_Giveinventory(invoker.ammo2.getClassName(),1);
				A_Takeinventory(invoker.ammo1.getClassName(),1,TIF_NOTAKEINFINITE);
                return A_DoPBWeaponAction(WRF_NOBOB);
            }
            FZGP LMN 1 A_DoPBWeaponAction(WRF_NOBOB);
            FZGP I 1 A_DoPBWeaponAction(WRF_NOBOB);
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(), "PumpReload");
			Loop;

        FinishReload:
            TNT1 A 0 {
				A_PlaysoundEx("Ironsights", "Auto");
			}
			FZGP FEDCB 1;
			FZGP BA 1;
			TNT1 A 0 PB_SetReloading(false);
            Goto Ready3;

        PumpReload:
            FZGP FEDC 1 A_DoPBWeaponAction();
			FZGR BCDEFG 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback", CHAN_WEAPON);
            FZGR H 1 A_DoPBWeaponAction();
            FZGR I 1 {
                A_ZoomFactor(1.0);
                PB_SetChamberEmpty(false);
				PB_SetMagEmpty(false);
				return A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
            }
            FZGR JKLM 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_WEAPON);
            FZGR NEFFEDCBA 1 A_DoPBWeaponAction();
			FZGP BCDEFGGG 1;
            goto ShellChecker;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				A_PlaysoundEx("Ironsights", "Auto");
			}
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty(),"Ready3");
			FZGP AB 1 A_DoPBWeaponAction();
		    FZGR ABCDE 1 A_DoPBWeaponAction();
		RemoveBullets:
            TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"FinishUnload");
            FZGR DEFFG 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback", CHAN_WEAPON);
            FZGR HIJ 1 A_DoPBWeaponAction();
            TNT1 A 0 {
				PB_UnloadMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    1,1,1,
                    invoker.ammo2.amount - 1
                    // "PBX_CSSG_SubZeroShell" // Forgot that this uses PB_Cells lol
                );
			}
            FZGR KLM 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_WEAPON);
            FZGR N 1 A_DoPBWeaponAction();
			loop;

		FinishUnload:
            FZGR EFFEDCBA 1 A_DoPBWeaponAction();
			TNT1 A 0 {
                PB_SetMagEmpty(true);
                PB_SetChamberEmpty(true);
				PB_SetReloading(false);
            }
			Goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 handleWheel();
            FZGH ABCDE 1;
            FZGH F 4;
            FZGH EDCBA 1;
            Goto Ready3;            

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        MuzzleFlash:
			P1SF D 1 BRIGHT {A_SetWeaponFrame(3 + random(0, 2)); A_GunFlash();}
			P1SF G 1 BRIGHT {A_SetWeaponFrame(6 + random(0, 2)); A_GunFlash();}
            stop;

        FlashPunching:
            // 14 frames
            FZGH ABCDE 1;
            FZGH F 4;
            FZGH EDCBA 1;
            goto Ready3;

        FlashKicking:
            // 15 frames
            FZGH ABCDE 1;
            FZGH F 5;
            FZGH EDCBA 1; 
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            FZGH ABCDE 1;
            FZGH F 5;
            FZGH EDCBA 1;
            FZGA A 1;
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            FZGH ABCDE 1;
            FZGH F 17;
            FZGH EDCBA 1;
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            FZGH EEEDCBA 1;             
            goto Ready3;
    }
}