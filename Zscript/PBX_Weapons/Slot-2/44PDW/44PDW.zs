// .44 PDW
// Originally a BD Addon by Jonny Nava 367 (https://www.moddb.com/mods/brutal-doom/addons/44-mag-pdw-for-brutal-doom)
// Original Credits
// Credits:
// Sprite: TSF
// Sounds: VietDoom (Reload), https://www.youtube.com/watch?v=TPMTjulTi40 (Gunshot)
// Popguy12
// Updated to PB by 517qwerty

// Includes
#include "./44PDW_Wheel.zs"

class PDW_Select_Single : inventory {default{inventory.maxamount 1;}}
class PDW_Select_Double : inventory {default{inventory.maxamount 1;}}
class PDW_Select_Triple : inventory {default{inventory.maxamount 1;}}
class PDW_Select_Quad : inventory {default{inventory.maxamount 1;}}

// Actual Weapon
class PBX_44PDW : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "PDWWheel";
	    Inventory.AltHUDIcon "44PGA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_LowCalMag";
        Weapon.AmmoType2 "PDWAmmo";
        Weapon.AmmoGive1 20;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_44PDW_Pickup";
        Inventory.PickupSound "Weapons/Revolver/Click1";
        Obituary "$OB_WEAP_44PDW";
        AttackSound "None";
        Tag "$PBX_44PDW_Tag";
        Scale 1.0;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    PDWMode mCurrentMode;

    const PDW_FULL_ZOOM = 1.75;
    const MAGAZINE_SIZE = 20;

    enum PDWMode
	{
        ERROR_WHEEL = -2
        ,CLOSE_WHEEL
        ,SINGLE_ACTION
        ,DOUBLE_ACTION
		,TRIPLE_ACTION
		,QUAD_ACTION
		,TOGGLE_LASER
	}
    
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    
//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////  
    mixin PBX_LaserSight;

    // Dont spawn the laser sight if the weapon is in one of these states
    static const StateLabel blockedLaserStates[] = {
        "Deselect",

        "SelectAnimation", "ReloadFromADS",

        "WeaponInspect",

        "RaiseFromEmpty","Reload","ContinueReload","FinishReload","Rechamber",
        "ReloadMagEmpty","RaiseToChamber","OpenChamber","ReloadFullEmpty",
        "FinishReloadEmpty",

        "ReloadUnloaded",

        "Unload",

        "WeaponRespect", "SwitchAnimation",
        "FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
    };

    override void PBX_DoEffectWeaponReady()
    {
		PBX_SpawnLaserSight(RED_DOT);
    }

    private
    action void PDW_FireWeapon(int tic)
    {
        bool ads = PB_GetZoom();
        switch(tic)
        {
            case 0:
                A_AlertMonsters();
                A_StartSound("ZSpecOps/MGun", CHAN_AUTO, CHANF_OVERLAP);
                return;

            case 1:
                PDWMode mode = getCurrentMode();

                // double / single fire the big round, triple / quad the 45
                if(mode == DOUBLE_ACTION || mode == SINGLE_ACTION) PB_FireBullets("PB_500SW", 1, 0.1, 0, 0, 0.1);
                else                                               PB_FireBullets("PB_45ACP", 1, 0.1, 0, 0, 0.1);
                PB_LowAmmoSoundWarning("pistol");
                PB_GunSmoke_Deagle(0, 0, ads ? -1 : -5);
                break;
        }

        PDW_Recoil(tic);
    }

    private
    action void PDW_Recoil(int tic)
    {
        bool ads = PB_GetZoom();
        PDWMode mode = getCurrentMode();
        vector2 recoil;

        if(ads)
        {
            switch(mode)
            {
                case DOUBLE_ACTION: // then go to Recoil2
                    if(tic == 2) recoil = (-0.20, 0.20);
                    break;

                case SINGLE_ACTION:
                    if(tic == 2) recoil = (-0.20, 0.20);
                    if(tic == 3) recoil = (-0.10, 0.10);
                    break;

                default: // triple / quad
                    if(tic == 1) recoil = (-0.20, 0.20);
                    if(tic == 2) recoil = (-0.05, 0.05);
                    if(tic == 3) recoil = (-0.05, 0.05);
                    break;
            }
        }
        else
        {
            switch(mode)
            {
                case DOUBLE_ACTION: // then go to Recoil
                    if(tic == 1) recoil = (-0.10, 0.15);
                    break;

                case SINGLE_ACTION:
                    if(tic == 1) recoil = (-0.10, 0.15);
                    else         recoil = (-0.20, 0.35);     // tic 2-3
                    break;

                case TRIPLE_ACTION:
                    if(tic == 1) recoil = (-0.50, 0.35);
                    if(tic == 2) recoil = (-0.20, 0.35);
                    if(tic == 3) recoil = (-0.35, 0.45);
                    break;

                case QUAD_ACTION:
                    if(tic == 2) recoil = (-0.70, 0.50);
                    if(tic == 3)
                    {
                        recoil = (-0.37, 0.30);
                        A_Recoil(1);
                    }
                    break;
            }
        }

        PB_WeaponRecoil(recoil.x, frandom[sfx](-recoil.y,recoil.y));
    }

    private
    action PDWMode getCurrentMode()
	{
		return invoker.mCurrentMode;
	}

    private
	action void setCurrentMode(PDWMode mode)
	{
		invoker.mCurrentMode = mode;
	}

    private
    action void setZoomFrame(int frame)
    {
        if(getCurrentMode() == SINGLE_ACTION)
        {
            A_SetWeaponFrame(frame);
        }
    }

    private
    action state PDW_JumpIfMode(StateLabel single = null, StateLabel dbl = null, StateLabel triple = null, StateLabel quad = null)
    {
        switch(getCurrentMode())
        {
            case SINGLE_ACTION: return resolvestate(single);
            case DOUBLE_ACTION: return resolvestate(dbl);
            case TRIPLE_ACTION: return resolvestate(triple);
            case QUAD_ACTION: return resolvestate(quad);
        }
        return resolvestate(null);
    }
    
    private
    action state handleWheel()
    {
        PDWMode mode = getCurrentMode();
        PDWMode tokens = getTokens();

        A_TakeInventory("GoWeaponSpecialAbility", 1);

        if(mode == tokens || tokens == CLOSE_WHEEL)
        {
			cleanTokens();
			if(mode == tokens) A_Print("$PB_ALREADYSELECTED");
			return PBX_ReturnReady();
		}

        if(tokens == TOGGLE_LASER)
        {
			cleanTokens();
            PBX_ToggleLaserSight(skipPlaySound:!PB_GetZoom());
			return PBX_ReturnReady(normal:null);
        }

        cleanTokens();
        setCurrentMode(tokens);
        printMode(tokens);
        return PBX_ReturnReady(normal:null);
    }

    private
    action void printMode(PDWMode mode)
    {
        string s;
        switch(mode)
        {
            case SINGLE_ACTION: s = "$PBX_44PDW_Single"; break; 
            case DOUBLE_ACTION: s = "$PBX_44PDW_Double"; break; 
            case TRIPLE_ACTION: s = "$PBX_44PDW_Triple"; break; 
            case QUAD_ACTION:   s = "$PBX_44PDW_Quad";   break; 
        }
        A_Print(s); 
    }
    
    private
    action int getTokens()
	{
		// Prioritize checking the tokens
		if(FindInventory("PDW_Select_Single"))
			return SINGLE_ACTION;
        else if(FindInventory("PDW_Select_Double"))
			return DOUBLE_ACTION;
		else if(FindInventory("PDW_Select_Triple"))
			return TRIPLE_ACTION;
		else if (FindInventory("PDW_Select_Quad"))
			return QUAD_ACTION;
        else if (FindInventory("PBX_Toggle_Laser"))
			return TOGGLE_LASER;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
	}

    private
    action void cleanTokens()
    {
        A_SetInventory("PDW_Select_Single",0);
        A_SetInventory("PDW_Select_Double",0);
        A_SetInventory("PDW_Select_Triple",0);
        A_SetInventory("PDW_Select_Quad",0);
        A_SetInventory("PBX_Toggle_Laser",0);
        A_SetInventory("PBX_CloseWheel",0);
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            44PG A -1;
            Stop;

        // WeaponRespect:
        //     AMGR ABCD 1 A_DoPBWeaponAction();
        //     AMGZ ABC 1 A_DoPBWeaponAction();
        //     AMGR QRSTUV 1 A_DoPBWeaponAction();
        //     TNT1 A 0 A_StartSound("MPOTUITT",CHAN_WEAPON,CHANF_OVERLAP);
        //     AMGR WXY 1 A_DoPBWeaponAction();
        //     goto Ready3;

        WeaponInspect:
        HoldInspect:
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            44PS ABCDE 1 {
                if(PB_GetMagUnloaded())
                {
                    A_SetWeaponSpriteEx("44PF");
                    A_SetWeaponFrame(9);
                }
            }
			TNT1 A 0 A_Lower();
			Wait;

        DeselectNoAmmo:
            44PF J 5;
		    TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("weapons/smg_up");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            44PS EDCBA 1 {
                if(PB_GetMagUnloaded())
                {
                    A_SetWeaponSpriteEx("44PF");
                    A_SetWeaponFrame(11);
                }
            }
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Ready2");
        ReadyToFire:
            // TNT1 A 0 PBX_CheckInspect();
			44PF A 1 {
                if(getCurrentMode() == SINGLE_ACTION)
                {
                    A_SetWeaponFrame(3);
                }
                if(PB_GetMagUnloaded())
                {
                    A_SetWeaponFrame(11);
                }

                PB_CoolDownBarrel();
                PB_HandleCrosshair(39);
                return PB_ReadyFire(ads:false);
            }
            loop;

        Ready2:
            TNT1 A 0 {
                A_SetCrosshair(-1);
            }
        ReadyToFire2:
            44PA F 1 {
				A_ZoomFactor(PDW_FULL_ZOOM);
                PB_CooldownBarrel();
                return PB_ReadyFire(ads:true);
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 A_JumpIf(PB_GetZoom(), "Fire2");
            TNT1 A 0 PB_JumpIfNoAmmo();
            // hammer already back when in single action
            TNT1 A 0 PDW_JumpIfMode(single: "FireSA", triple: "FireStart");
            TNT1 A 0 A_StartSound("Weapons/Revolver/Click1", CHAN_WEAPON, CHANF_OVERLAP);
        FireStart:
            // start animation
            44PF BCD 1;
        FireSA:
            44PF E 1 A_StartSound("weapons/empty", CHAN_WEAPON, CHANF_OVERLAP);
        FireQA: // quad refire jumps to here
            TNT1 A 0 PB_JumpIfNoAmmo();
            TNT1 A 0 PB_TakeAmmo(invoker.ammo2.getClassName());
        FireA:
            44PF F 1 BRIGHT PDW_FireWeapon(0);
            TNT1 A 0 PDW_JumpIfMode(quad: "FireAQA");
            44PF J 1 PDW_FireWeapon(1);
            44PF K 1 PDW_FireWeapon(2);
            44PF I 1 PDW_FireWeapon(3);
            TNT1 A 0 PDW_JumpIfMode(dbl: "Recoil", single: "EndFire");
            TNT1 A 0 PB_ReFire(); // triple
            44PF AAAAAAA 1 A_DoPBWeaponAction(WRF_NOBOB | WRF_ALLOWRELOAD);
            Goto Ready3;

        FireAQA:
            44PF G 1 PDW_FireWeapon(1);
            44PF H 1 PDW_FireWeapon(2);
            44PF I 1 PDW_FireWeapon(3);
            TNT1 A 0 PB_ReFire("FireQA");
            44PF A 1 {
                PB_WeaponRecoil(-0.10, frandom[sfx](-0.15,0.15));
                return A_DoPBWeaponAction(WRF_NOBOB | WRF_ALLOWRELOAD);
            }
            Goto EndFire;

        Recoil:
            44PF AA 1 {
                PB_WeaponRecoil(-0.10, frandom[sfx](-0.15,0.15));
                return A_DoPBWeaponAction(WRF_NOBOB | WRF_ALLOWRELOAD);
            }
            Goto EndFire;

        EndFire:
            TNT1 A 0 A_ZoomFactor(1.0);
            TNT1 A 0 PDW_JumpIfMode(single: "PreCock");
            44PF AAAAAAAAAA 1 A_DoPBWeaponAction(WRF_NOBOB | WRF_ALLOWRELOAD);
            TNT1 A 0 PB_ReFire();
            Goto Ready3;

        PreCock:
            44PF A 6;
        Cock:
            44PB ABCD 1;
            44PB E 1 A_StartSound("Weapons/Revolver/Click1", CHAN_WEAPON, CHANF_OVERLAP);
            44PB F 1;
            44PB G 6;
            44PB HIJKL 1;
            44PF DDDD 1 A_DoPBWeaponAction(WRF_NOBOB | WRF_ALLOWRELOAD);
            Goto Ready3;

        Fire2:
            // double and triple plays the full animation
            TNT1 A 0 PDW_JumpIfMode(single: "FireSA2", quad: "FireSA2");
            44PA F 1 A_StartSound("Weapons/Revolver/Click1", CHAN_WEAPON, CHANF_OVERLAP);
            44PA GHF 1;
        FireSA2:
            44PA F 1 A_StartSound("weapons/empty", CHAN_WEAPON, CHANF_OVERLAP);
        FireQA2:
            TNT1 A 0 PB_JumpIfNoAmmo();
            TNT1 A 0 PB_TakeAmmo(invoker.ammo2.getClassName());
        FireA2:
            44PA I 1 BRIGHT PDW_FireWeapon(0);
            TNT1 A 0 PDW_JumpIfMode(quad: "FireAQA2");
            44PA L 1 PDW_FireWeapon(1);
            44PA M 1 PDW_FireWeapon(2);
            44PA N 1 PDW_FireWeapon(3);
            TNT1 A 0 PDW_JumpIfMode(dbl: "Recoil2", single: "Cock2");
            TNT1 A 0 PB_ReFire(); // triple
            44PA F 10 A_DoPBWeaponAction(WRF_ALLOWRELOAD);
            Goto Ready2;

        FireAQA2:
            44PA J 1 PDW_FireWeapon(1);
            44PA K 1 PDW_FireWeapon(2);
            44PA N 1 PDW_FireWeapon(3);
            TNT1 A 0 PB_ReFire("FireQA2");
            44PA FFFF 1 {
                PB_WeaponRecoil(-0.05, frandom[sfx](-0.05,0.05));
                return A_DoPBWeaponAction(WRF_NOBOB | WRF_ALLOWRELOAD);
            }
            Goto EndFire2;

        Recoil2:
            44PA FFFFF 1 {
                PB_WeaponRecoil(-0.05, frandom[sfx](-0.05,0.05));
                return A_DoPBWeaponAction(WRF_NOBOB | WRF_ALLOWRELOAD);
            }
            Goto EndFire2;

        Cock2:
            44PA O 1;
            44PA P 1 A_StartSound("Weapons/Revolver/Click1", CHAN_WEAPON, CHANF_OVERLAP);
            44PA Q 2;
            44PA R 3;
            44PA Q 2;
            44PA PO 1;
            Goto EndFire2;

        EndFire2:
            TNT1 A 0 A_ZoomFactor(PDW_FULL_ZOOM);
            44PA FFFFFFFFFF 1 A_DoPBWeaponAction(WRF_NOBOB | WRF_ALLOWRELOAD);
            TNT1 A 0 PB_ReFire();
            Goto Ready2;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                A_SetCrosshair(-1);
            }
			TNT1 A 0 A_Jumpif(PB_GetZoom(),"ZoomOut");
            TNT1 A 0 A_JumpIf(PB_GetMagUnloaded(),"Ready3");
        ZoomIn:
            TNT1 A 0 {
                PB_SetZoom(true);
                A_startsound("IronSights",CHAN_AUTO);
                A_SetCrosshair(-1);
				A_ZoomFactor(PDW_FULL_ZOOM);
            }
            44PA C 1 setZoomFrame(0);
            44PA D 1 setZoomFrame(1);
            44PA E 1;
            Goto Ready2;
            
        Zoomout:
            TNT1 A 0 {
                PB_SetZoom(false);
                A_startsound("IronSights",CHAN_AUTO);
            }
            44PA E 1 A_ZoomFactor(1.0);
            44PA D 1 setZoomFrame(1);
            44PA C 1 setZoomFrame(0);
			TNT1 A 0 PB_HandleCrosshair(67);
            Goto Ready3;

        Nope:
            ATFF A 1 BRIGHT A_Print("I'm not gonna make a magazine-less aim sprite. Also, fuck the ATF, fuck the NFA, fuck the GCA, fuck the Hughes Amendment, and long live the 2A!", 2);
            Goto Ready3;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
        ReloadFromADS:
			TNT1 A 0 PB_HandleCrosshair(42);
			TNT1 A 0 A_startsound("IronSights",CHAN_WEAPON,CHANF_OVERLAP);
			44PA E 1 A_ZoomFactor(1.0);
            44PA D 1 setZoomFrame(1);
			TNT1 A 0 PB_SetZoom(false);
            44PA C 1 setZoomFrame(0);
		Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
            TNT1 A 0 A_JumpIf(getCurrentMode() == SINGLE_ACTION || PB_GetMagUnloaded(), "ContinueReload");
            44PF A 0 A_Jump(255,1,2);
            44PF ED 1;
			TNT1 A 0 A_startsound("weapons/empty",CHAN_WEAPON,CHANF_OVERLAP);
        ContinueReload:
            44PF A 1 {
                if(PB_GetMagUnloaded())
                {
                    A_SetWeaponFrame(9);
                }
            }
            TNT1 A 0 PB_CheckReload("ReloadUnloaded",null,null,"Ready3","Ready3",MAGAZINE_SIZE);
            44PR ABCDEF 1 ;
            44PR G 4;
            TNT1 A 0 {
                A_startsound("weapons/smg_out",CHAN_WEAPON,CHANF_OVERLAP);
                PB_SetMagUnloaded(true);
            }
            44PR HIJKL 1;
            44PR M 8;
        ReloadUnloaded:
            44PR M 12;
            44PR N 1;
            TNT1 A 0 A_StartSound("weapons/smg_in",CHAN_WEAPON,CHANF_OVERLAP);
            44PR OPQRS 1;
            44PR T 4;
            44PR S 1;
            TNT1 A 0 {
                // A_StartSound("weapons/smg_in",CHAN_WEAPON,CHANF_OVERLAP);
                PB_AmmoIntoMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    MAGAZINE_SIZE);
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
                PB_SetChamberEmpty(false);
            }
        FinishReload:
            44PR UVA 1;
            44PF A 1;
            TNT1 A 0 A_JumpIf(getCurrentMode() == SINGLE_ACTION,"Cock");
            Goto Ready3;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
            44PR ABCDEF 1;
            44PR G 4;
            TNT1 A 0 A_startsound("weapons/smg_out",CHAN_WEAPON,CHANF_OVERLAP);
            44PR HIJKL 1;
            44PR M 12;
            TNT1 A 0 {
				PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname());
				PB_SetMagUnloaded(true);
				PB_SetChamberEmpty(true);
                PB_SetMagEmpty(true);
			}
            goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 handleWheel();
        SwitchAnimation:
            44PS AB 1;
            44PS C 6;
            TNT1 A 0 A_startsound("MS/Button",CHAN_WEAPON,CHANF_OVERLAP);
            44PS BA 1;  
            goto Ready3;            

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        FlashPunching:
            // 14 frames
            44PS ABCD 1;
            44PS E 6;
            44PS DCBA 1;      
            goto Ready3;

        FlashKicking:
            // 15 frames
            44PS ABCD 1;
            44PS E 7;
            44PS DCBA 1;   
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            44PS ABCD 1;
            44PS E 8;
            44PS DCBA 1;  
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            44PS ABCD 1;
            44PS E 19;
            44PS DCBA 1;  
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            44PS E 3;
            44PS DCBA 1;  
            goto Ready3;
    }
}