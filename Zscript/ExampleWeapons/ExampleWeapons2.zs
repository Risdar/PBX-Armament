// Includes
#include "./PlasmaBlaster_Functions.zs"
#include "./PlasmaBlaster_Wheel.zs"

class Plasma_Select_Auto : inventory {default{inventory.maxamount 1;}}
class Plasma_Select_Semi : inventory {default{inventory.maxamount 1;}}
class Plasma_Select_Burst : inventory {default{inventory.maxamount 1;}}
class Plasma_Select_Charge : inventory {default{inventory.maxamount 1;}}

// Actual Weapon
class PBX_PlasmaBlaster : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        Weapon.SelectionOrder 1;
        Weapon.SlotNumber 2;
        Weapon.SlotPriority 1;
        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "PlasmaBlasterWheel";
	    Inventory.AltHUDIcon "ARMZA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_Cell";
        Weapon.AmmoType2 "HellPistolerAmmo";
        Weapon.AmmoGive1 30;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_PlasmaBlaster_Pickup";
        Inventory.PickupSound "CHGNPKUP";
        Obituary "$OB_WEAP_HEXASG";
        AttackSound "None";
        Tag "$PBX_PlasmaBlaster_Tag";
        Scale 0.8;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    bool blasterPrimary;
    bool blasterSecondary;
    int burstcount;
    const MAXCHARGE = 16;

    enum CrossbowMode
	{
        ERROR_WHEEL = -2
        ,CLOSE_WHEEL
        ,NO_UPGRADE
		,NORMAL_BOLT
		,EXPLOSIVE_BOLT
		,DEMONIC_BOLT
        ,SHOCK_BOLT
	}
    
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    override void attachtoowner(actor other)
	{
		if(other && other.player)
		{
			if(other.countinv(ammotype2) < 1 && !respected)
            {
                other.A_giveinventory(ammotype2,GetAmmoCapacity(ammotype2));
            }
		}
		super.attachtoowner(other);
	}
    
	override void postbeginplay()
	{
		excavatorMode = eDrillChargeMode;
		super.postbeginplay();
	}
    
//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    private
    action void setCrossbowSprite(name unloaded = '', name bolt = '', name explosive = '', name demonic = '', name shock = '')
	{
		int mode = getCrossbowMode();
		name spriteToUse = '';
		
		if(PB_GetChamberEmpty())
			spriteToUse = unloaded;

		switch(mode)
		{
			case NORMAL_BOLT: 	  spriteToUse = bolt;		break;
			case EXPLOSIVE_BOLT:  spriteToUse = explosive;	break;
			case DEMONIC_BOLT: 	  spriteToUse = demonic;	break;
			case SHOCK_BOLT: 	  spriteToUse = shock;		break;
			default: break;
		}

		if(spriteToUse != '')
			A_SetWeaponSpriteEx(spriteToUse);
	}
    
    action int getCrossbowMode() const
	{
		return invoker.currentMode;
	}

	action void setCrossbowMode(int mode)
	{
		invoker.currentMode = mode;
	}
    
    private
    action int getTokens()
	{
		// Prioritize checking the tokens
		if(FindInventory("CB_Select_ShockMode"))
			return SHOCK_BOLT;
		else if(FindInventory("CB_Select_DemonicMode"))
			return DEMONIC_BOLT;
		else if (FindInventory("CB_Select_ExplosiveMode"))
			return EXPLOSIVE_BOLT;
		else if (FindInventory("CB_Select_NormalMode"))
			return NORMAL_BOLT;
		else if (FindInventory("CB_Select_NO"))
			return NO_UPGRADE;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
	}

    private
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
            ARMZ A -1;
            Stop;

        WeaponRespect:
            AMGR ABCD 1 A_DoPBWeaponAction();
            AMGZ ABC 1 A_DoPBWeaponAction();
            AMGR QRSTUV 1 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaySound("CELLIN2", 6);
            AMGR WXY 1 A_DoPBWeaponAction();
            goto Ready3;

        WeaponInspect:
        HoldInspect:
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            stop;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            AMGR ABCDEF 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("weapons/smg_magfly1");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            AMGR FEDCBA 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 PBX_CheckInspect();
			AMGL A 1 {
                PB_CoolDownBarrel();
                PB_HandleCrosshair(39);
                return A_DoPBWeaponAction();
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 PB_JumpIfNoAmmo();
            AMGF A 1;
            AMGF B 1 A_PlaySound("BEP",3);
            AMGF CD 1;
        AutoFire:
            AMGF E 1    fireWeapon(1);
            AMGF FG 1   fireWeapon(2);
            TNT1 A 0    fireWeapon(3);
            goto Ready3;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
            }
            TNT1 A 0 A_JumpIf(getSecondary() == SEC_CHARGE, "ChargeFire");
            TNT1 A 0 PB_JumpIfNoAmmo(chamber:false);
            AMGF A 1 A_PlaySound("BEP",7);
            AMGF B 1 A_PlaySound("BEP",8);
            AMGF CD 1 A_PlaySound("BEP",9);
            TNT1 A 0 {invoker.burstcount = 0;}
        AltFireBurst:
            TNT1 A 0 PB_JumpIfNoAmmo(chamber:false);
            AMGF E 0 A_PlaySound("HRFire");
            AMGF E 1 {
		        PB_FireBullets("HellPistolNormal", 1, 0, 0, 0, 0);
                PB_TakeAmmo(invoker.ammo2.getClassName());
                invoker.burstcount++;
            }
            AMGF FG 1;
            TNT1 A 0 A_JumpIf(invoker.burstcount < 3, "AltFireBurst");
        EndBurst:
            TNT1 A 0 {invoker.burstcount = 0;}
            AMGL A 10{
                if(JustPressed(BT_ATTACK)) return ResolveState("Fire");
                return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOPRIMARY);
            }
            TNT1 A 0 PB_ReFire("AltFireBurst");
            goto Ready3;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
        ReloadFromADS:
			TNT1 A 0 PB_HandleCrosshair(42);
			TNT1 A 0 A_startsound("IronSights",29);
            TNT1 A 0 A_ZoomFactor(1.5);
			BR4Z CB 1;
			TNT1 A 0 PB_SetZoom(false);
			BR4Z A 1;
		Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null,null,"Ready3","Ready3",MAXCHARGE);
            TNT1 A 0 A_PlaySound("weapons/smg_magfly1");
            AMGR ABCDEF 1;
            TNT1 A 0 A_PlaySound("weapons/smg_magfly2");
            AMGR GHIJK 1;
            TNT1 A 0 {
                A_PlaySound("CELLOUT2", 5);
                PB_SetMagEmpty(true);
                PB_SetMagUnloaded(true);
                PB_SetChamberEmpty(true);
            }
            AMGR LMNOP 1;
        ContinueReload:
            AMGR QRS 1;
            AMGR TUV 1;
            TNT1 A 0 {
                A_PlaySound("CELLIN2", 6);
                PB_AmmoIntoMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    MAXCHARGE);
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
                PB_SetChamberEmpty(false);
            }
            AMGR WXY 1;
            goto Ready3;
        
        RaiseFromEmpty:
            AMGR ABCD 1;
            AMGZ ABC 1;
            goto ContinueReload;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
            TNT1 A 0 {
				PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname());
				PB_SetMagUnloaded(true);
				PB_SetChamberEmpty(true);
                PB_SetMagEmpty(true);
			}
            goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 A_TakeInventory("GoWeaponSpecialAbility", 1);
            goto Ready3;            

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        FlashPunching:
            // 14 frames
            MSNQ ABCDE 1;
            MSNQ FGHF 1;
            MSNQ EDCBA 1;      
            goto Ready3;

        FlashKicking:
            // 15 frames
            MSNQ ABCDE 1;
            MSNQ FGHF 1;
            MSNQ EDCBA 1;  
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            MSNQ ABCDE 1;
            MSNQ FGHF 1;
            MSNQ EDCBA 1;
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            MSNK ABCDEFGHHHHHHHHHHHHHGFEDCBA 1; MSNQ ABCDE 1;
            MSNQ FGHF 1;
            MSNQ EDCBA 1;
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            MSNQ FGHF 1;
            MSNQ EDCBA 1;       
            goto Ready3;
    }
}