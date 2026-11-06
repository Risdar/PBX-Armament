// MP5
// From BD Plus made by yaelvolador and Maria's Hell made by DOOMERBLASCOWITZ
// -TESEFY
// -LOSSFORWORDS
// Originally for Maria's Hell by DOOMERBLASCOWITZ
// Edited Sprites for BD Plus by yaelvolador

// Includes
#include "./MP5_helpers.zs"
#include "./MP5_Wheel.zs"

class MP5_Select_Semi : inventory {default{inventory.maxamount 1;}}
class MP5_Select_Burst : inventory {default{inventory.maxamount 1;}}
class MP5_Select_FullAuto : inventory {default{inventory.maxamount 1;}}
class MP5_Throw_Smoke : inventory {default{inventory.maxamount 1;}}

// Actual Weapon
class PBX_MP5 : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "MP5Wheel";
	    Inventory.AltHUDIcon "MAPPA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_LowCalMag";
        Weapon.AmmoType2 "MP5Ammo";
        Weapon.AmmoGive1 50;
        Weapon.WeaponScaleX 0.8;
        Weapon.WeaponScaleY 1.0;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_MP5_Pickup";
        Inventory.PickupSound "MPOTUITT";
        Obituary "$OB_WEAP_MP5";
        AttackSound "None";
        Tag "$PBX_MP5_Tag";
        Scale 0.8;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    int mFireMode;
    int mBurstCount;
	bool mSemiClear;

    const MAGAZINE_SIZE = 50;
    const SMOKE_GRENADE_AMOUNT = 3;
    const SMOKE_INFIGHT_RADIUS = 356;

    enum MP5_WW
	{
        ERROR_WHEEL = -1
        ,CLOSE_WHEEL
        ,SELECT_SEMI
		,SELECT_BURST
		,SELECT_FULLAUTO
		,TOGGLE_LASER
		,THROW_SMOKE
	}
    
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    override void PostBeginPlay()
    {
        super.PostBeginPlay();
        mFireMode = SELECT_FULLAUTO;
    }
    
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

        "Unload",

        "WeaponRespect", "SwitchAnimation", "ThrowSmoke",
        "FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
    };

    override void PBX_DoEffectWeaponReady()
    {
		PBX_SpawnLaserSight(RED_DOT);
    }

    private
    action state MP5_Refire()
    {
        switch(getFireMode())
        {
            case SELECT_SEMI:
                // Track button release
                if (!(player.cmd.buttons & BT_ATTACK))
                    invoker.mSemiClear = true;
                // Refire only if button was released and pressed again
                if (invoker.mSemiClear && PlayerPressedOnce(BT_ATTACK))
                    return resolvestate("Fire");
                return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOFIRE | WRF_NOPRIMARY);

            case SELECT_BURST:
                break;

            case SELECT_FULLAUTO:
                return PB_ReadyFire(ads:PB_GetZoom());
        }
        return ResolveState(null);
    }

    private
    action void fireweapon()
    {
        bool ads        = PB_GetZoom();
        Vector2 recoil  = ads ? (-0.2,0.18) : (-0.24,0.22);
        double d3       = ads ?  4.3   :  0.0;
        int xOfs        = ads ?  19    :  21;
        int vertOfs     = ads ?  35    :  30;

        A_AlertMonsters();
        A_StartSound("ZSpecOps/MGun", CHAN_WEAPON, CHANF_DEFAULT, 1.0, ATTN_NORM, frandom[sfx](0.93, 1.07));
        // A_StartSound("FIREMP5",CHAN_WEAPON,CHANF_OVERLAP);
        PB_GunSmoke_Compensator(0, 0, d3);
        PB_MuzzleFlashEffects(0, 0, d3);
        A_FireCustomMissile("YellowFlareSpawn", 0, 0, 0, 0);
        A_FlashOverlay();
        PB_DynamicTail("smg","smg");
        PB_FireOffset();
        PB_FireBullets("PB_9x19mmSubsonic", 1, 0.1, 0, 0, 0.1);
        PB_SpawnCasing("EmptyBrassPistol", xOfs, 3, vertOfs, frandom[sfx](-3,3), frandom[sfx](2,7), frandom[sfx](1,2), true, true);
        PB_LowAmmoSoundWarning("smg");
        PB_TakeAmmo(invoker.ammo2.getClassName());
        PB_WeaponRecoil(recoil.x, frandom[sfx](-recoil.y,recoil.y));
        PB_IncrementHeat();
        invoker.mBurstCount++;
    }

    action MP5_WW getFireMode()
	{
		return invoker.mFireMode;
	}

	action void setFireMode(MP5_WW mode)
	{
		invoker.mFireMode = mode;
	}
    
    private
    action void setBurstCount(int set)
    {
        invoker.mBurstCount = set;
    }

    private
    action bool getBurst()
    {
        return invoker.mBurstCount < 3 && getFireMode() == SELECT_BURST;
    }

    private
    action state handleWheel()
    {
        A_TakeInventory("GoWeaponSpecialAbility", 1);
        MP5_WW tokens = getTokens();
        MP5_WW mode = getFireMode();

        if(tokens == mode)
        {
            A_Print("$PBX_AlreadySelected");
            cleanTokens();
            return resolvestate("Ready3"); // Skip the change animation
        }

        switch(tokens)
        {
            case CLOSE_WHEEL:
                cleanTokens();
                return PBX_ReturnReady(normal:"Ready3"); 

            case SELECT_SEMI: case SELECT_BURST: case SELECT_FULLAUTO:
                setFireMode(tokens); 
                printMode();
                break;

            case THROW_SMOKE:
                cleanTokens();
                if(CountInv("MP5Smoke") < 1)
                {
                    A_Print("$PBX_MP5_NoSmoke");
                    return resolvestate("Ready3");
                }
                return resolvestate("ThrowSmoke");

            case TOGGLE_LASER:
                PBX_ToggleLaserSight(skipPlaySound:true);
                break;
        }

        cleanTokens();

        if(PB_GetZoom())
		{
			A_StartSound("MS/Button",CHAN_WEAPON,CHANF_OVERLAP);
			return resolvestate("Ready2");
		}

		// Fallthrough to Switch Animation
		return resolvestate(null);
    }

    private
    action void printMode()
    {
        string s;
        switch(getFireMode())
        {
            case SELECT_SEMI:       s = "$PB_FIREMODE_SEMI";    break;
            case SELECT_BURST:      s = "$PB_FIREMODE_BURST";   break;
            case SELECT_FULLAUTO:   s = "$PB_FIREMODE_FULL";    break;
        }
        A_Print(s);
    }

    private
    action MP5_WW getTokens()
	{
		// Prioritize checking the tokens
		if(FindInventory("MP5_Select_Semi"))
			return SELECT_SEMI;
		else if(FindInventory("MP5_Select_Burst"))
			return SELECT_BURST;
		else if (FindInventory("MP5_Select_FullAuto"))
			return SELECT_FULLAUTO;
		else if (FindInventory("PBX_Toggle_Laser"))
			return TOGGLE_LASER;
        else if (FindInventory("MP5_Throw_Smoke"))
			return THROW_SMOKE;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
	}

    private
    action void cleanTokens()
    {
        A_SetInventory("MP5_Throw_Smoke",0);
        A_SetInventory("MP5_Select_Semi",0);
        A_SetInventory("MP5_Select_Burst",0);
        A_SetInventory("MP5_Select_FullAuto",0);
        A_SetInventory("PBX_Toggle_Laser",0);
        A_SetInventory("PBX_CloseWheel",0);
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            MAPP A -1;
            Stop;

        WeaponRespect:
            TNT1 A 0 A_startsound("IronSights",CHAN_WEAPON,CHANF_OVERLAP);
            TNT1 A 0 A_StartSound("MP5SINSPEC",CHAN_WEAPON,CHANF_OVERLAP);
            // Raise Weapon
			CONT HIJKLMNOP 1 A_DoPBWeaponAction();
            // Open Chamber
            CONT QRSTUVX 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MP5OUT",CHAN_WEAPON,CHANF_OVERLAP);
			CONT YZ 1 A_DoPBWeaponAction();
			COYO ABCCDDEEFG 1 A_DoPBWeaponAction();
            // Remove Mag
            COYO HIJKLM 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MAGINP5",CHAN_WEAPON,CHANF_OVERLAP);
			COYO NOPPQQRR 1 A_DoPBWeaponAction();
            // Insert Mag
            COYO STUVW 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MPOTUITT",CHAN_WEAPON,CHANF_OVERLAP);
            COYO WXXYY 1 A_DoPBWeaponAction();
            // HK Slap
			COZO AAB 1 A_DoPBWeaponAction();
            COZO CCDDEFGHI 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MPOTUITT",CHAN_WEAPON,CHANF_OVERLAP);
            COZO JKL 1 A_DoPBWeaponAction();
            // Lower Weapon
            COZO MNPQRST 1 A_DoPBWeaponAction();
            goto Ready3;

        WeaponInspect:
            // Raise Weapon
			CONT HIJKLMN 1 A_DoPBWeaponAction();
            // Open Chamber
			CONT OPQRSTUVXYZ 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MP5OUT",CHAN_WEAPON,CHANF_OVERLAP);
			COYO ABCCDDEEFG 1 A_DoPBWeaponAction();
        HoldInspect:
            COYO H 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            COZO CCDDEFGHI 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MPOTUITT",CHAN_WEAPON,CHANF_OVERLAP);
            COZO JKL 1 A_DoPBWeaponAction();
            goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            CONO EDC 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
			    PB_HandleCrosshair(67);
                PBX_WeaponRaise("MPOTUITT");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            CONO EDC 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
			TNT1 A 0 A_JumpIf(PB_GetZoom(), "Ready2");
        ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
			CONT A 1 {
                PB_CoolDownBarrel();
                PB_HandleCrosshair(67);
                return PB_ReadyFire(ads:false);
            }
            loop;

        Ready2:
			ISSA F 1 {
                A_SetCrosshair(-1);
                PB_CoolDownBarrel();
                return PB_ReadyFire(ads:true);
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
			TNT1 A 0 A_JumpIf(PB_GetZoom(), "Fire2");
            TNT1 A 0 {
                PB_HandleCrosshair(67);
				A_WeaponOffset(0, 32);
				PB_SetRoll(0);
				A_ZoomFactor(1.0);
            }
			TNT1 A 0 setBurstCount(0);
        FireLoop:
            TNT1 A 0 PB_JumpIfNoAmmo();
			CONT B 1 BRIGHT fireweapon();
			XIMA A 1 bright A_ZoomFactor(0.98);
			XIMA B 1 bright A_ZoomFactor(1.0);
			TNT1 A 0 A_JumpIf(getFireMode() == SELECT_SEMI, "FireEnd");
			TNT1 A 0 A_JumpIf(getBurst(), "FireLoop");
        FireEnd:
			TNT1 A 0 setBurstCount(0);
			XIMA C 1 bright;
			CONT AAA 1 MP5_Refire();
			TNT1 A 0 { invoker.mSemiClear = false; }
            goto Ready3;

        Fire2:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                A_SetCrosshair(-1);
				PB_SetRoll(0);
			}
			TNT1 A 0 setBurstCount(0);
        Fire2Loop:
            TNT1 A 0 PB_JumpIfNoAmmo();
			ISSA G 1 BRIGHT fireweapon();
			ISSA H 1 bright;
			ISSA I 1 bright;
			TNT1 A 0 A_JumpIf(getBurst(), "Fire2Loop");
        Fire2End:
			TNT1 A 0 setBurstCount(0);
			ISSA J 1 bright;
			ISSA FFF 1 MP5_Refire();
			TNT1 A 0 { invoker.mSemiClear = false; }
            goto Ready2;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                A_SetCrosshair(-1);
            }
			TNT1 A 0 A_Jumpif(PB_GetZoom(),"ZoomOut");
        ZoomIn:
            TNT1 A 0 {
                PB_SetZoom(true);
                A_startsound("IronSights",CHAN_AUTO);
                A_SetCrosshair(-1);
				A_ZoomFactor(1.25);
            }
            ISSA ABCDEF 1;
            Goto Ready2;
            
        Zoomout:
            TNT1 A 0 {
                PB_SetZoom(false);
                A_startsound("IronSights",CHAN_AUTO);
            }
            ISSA FEDCBA 1 A_ZoomFactor(1.0);
			TNT1 A 0 PB_HandleCrosshair(67);
            Goto Ready3;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
        ReloadFromADS:
			TNT1 A 0 PB_HandleCrosshair(67);
			TNT1 A 0 A_startsound("IronSights",CHAN_WEAPON,CHANF_OVERLAP);
            ISSA FED 1;
			TNT1 A 0 PB_SetZoom(false);
			ISSA CBA 1;
			CONT A 1;
		Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
            TNT1 A 0 PB_CheckReload("ContinueReload","ReloadFullEmpty","RaiseToChamber","Ready3","Ready3",MAGAZINE_SIZE);
            // Raise
			TNT1 A 0 A_startsound("IronSights",CHAN_WEAPON,CHANF_OVERLAP);
			PUTO BCDEFGHIJKLMNO 1;
            TNT1 A 0 A_JumpIf(invoker.ammo2.amount == 1,"ReloadMagEmpty");
            // Remove Mag
            TNT1 A 0 {
                A_StartSound("MAGINP5",CHAN_WEAPON,CHANF_OVERLAP);
                PB_SetMagUnloaded(true);
            }
			ANUA CBA 1;
            ANOL ZYXXXWWWW 1;
        ContinueReload:
            ANOL WWWWXXXYZ 1;
			ANUA ABC 1;
            TNT1 A 0 {
                A_StartSound("MPOTUITT",CHAN_WEAPON,CHANF_OVERLAP);
                PB_AmmoIntoMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    MAGAZINE_SIZE);
                PB_SetMagUnloaded(false);
            }
			ANUA DEFGHIJ 1;
            PUTO O 1;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"OpenChamber");
            // Lower Weapon
			PUTO NMLKJIHGFEDCB 1;
            goto Ready3;

        ReloadMagEmpty:
            // Remove Mag
            ANOL OPQRST 1;
			TNT1 A 0 {
                A_StartSound("MAGINP5",CHAN_WEAPON,CHANF_OVERLAP);
                PB_SetMagUnloaded(true);
            }
			ANOL UV 1;
            goto ContinueReload;

        RaiseToChamber:
            // Raise Weapon
			CONT HIJKLMN 1;
        OpenChamber:
            // Open Chamber
			CONT OPQRSTUVXYZ 1;
            TNT1 A 0 A_StartSound("MP5OUT",CHAN_WEAPON,CHANF_OVERLAP);
			COYO ABCCDDEEFGH 1;
            goto Rechamber;

		ReloadFullEmpty:
			TNT1 A 0 A_startsound("IronSights",CHAN_WEAPON,CHANF_OVERLAP);
            TNT1 A 0 A_StartSound("MP5SINSPEC",CHAN_WEAPON,CHANF_OVERLAP);
            // Raise Weapon
			CONT HIJKLMNOP 1;
            // Open Chamber
            CONT QRSTUVX 1;
            TNT1 A 0 A_StartSound("MP5OUT",CHAN_WEAPON,CHANF_OVERLAP);
			CONT YZ 1;
			COYO ABCCDDEEFG 1;
            // Remove Mag
            COYO HIJKLM 1;
            TNT1 A 0 {
                A_StartSound("MAGINP5",CHAN_WEAPON,CHANF_OVERLAP);
                PB_SetMagUnloaded(true);
            }
			COYO NOPPQQRR 1;
            // Insert Mag
            COYO STUVW 1;
            TNT1 A 0 {
                A_StartSound("MPOTUITT",CHAN_WEAPON,CHANF_OVERLAP);
                PB_AmmoIntoMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    MAGAZINE_SIZE-1);
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
            }
            COYO WXXYY 1;
            // HK Slap
			COZO AAB 1;
        Rechamber:
            COZO CCDDEFGHI 1;
            TNT1 A 0 {
                A_StartSound("MPOTUITT",CHAN_WEAPON,CHANF_OVERLAP);
                PB_SetChamberEmpty(false);
            }
            COZO JKL 1;
        FinishReloadEmpty:
            // Lower Weapon
            COZO MNPQRST 1;
            goto Ready3;
            
//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
			PUTO BCDEFGHIJKLMNO 1;
			ANUA JIHGFED 1;
            TNT1 A 0 {
                A_StartSound("MP5OUT",CHAN_WEAPON,CHANF_OVERLAP);
				PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname(),goal:MAGAZINE_SIZE-1);
				PB_SetMagUnloaded(true);
                PB_SetMagEmpty(true);
			}
			ANUA CBA 1;
            ANOL ZYXXXWWWW 1;
            goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 handleWheel();
        SwitchAnimation:
            MAPP BCDE 1;
			TNT1 A 0 A_StartSound("MS/Button",CHAN_WEAPON,CHANF_OVERLAP);
			MAPP F 6;
			MAPP EDCB 1;
            goto Ready3;            

        ThrowSmoke:
            TNT1 A 0 A_SetInventory("PlayerIsThrowingAGrenade",1);
		    STGR MLKJIH 1 PB_SetRoll(roll+0.5);
            TNT1 A 0 A_StartSound("OPNGRN",CHAN_AUTO,CHANF_OVERLAP);
            STGR GFE 1 PB_SetRoll(roll+0.5);
            STGR DCB 1;
            TNT1 A 1 PB_SetRoll(roll-18.0);
			HND1 I 1 A_StartSound("THRGRN",CHAN_AUTO,CHANF_OVERLAP);
			HND1 J 1;
            TNT1 A 0 {
				A_FireProjectile("PBX_ThrownSmokeGrenade",0,0,0,0,0,0);
				A_TakeInventory("MP5Smoke", 1, TIF_NOTAKEINFINITE);
				A_FireProjectile("Alerter",0,0,0,0,0,0);
			}
			HND1 KLMNOPQ 1 PB_SetRoll(roll-5.0);
            goto Ready3;            

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        MuzzleFlash:
            A1FM F 1 Bright {
                A_SetWeaponFrame(randompick[sfx](5,8,9,10,11));
                A_GunFlash();
            }
            Stop;

        FlashPunching:
            // 14 frames
            MAPP BCDE 1;
			MAPP F 6;
			MAPP EDCB 1;    
            goto Ready3;

        FlashKicking:
            // 15 frames
            MAPP BCDE 1;
			MAPP F 7;
			MAPP EDCB 1;
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            MAPP BCDE 1;
			MAPP F 8;
			MAPP EDCB 1;
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            MAPP BCDE 1;
			MAPP F 19;
			MAPP EDCB 1;
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            MAPP F 3;
			MAPP EDCB 1;  
            goto Ready3;
    }
}