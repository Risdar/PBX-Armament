// Includes
// #include "./PlasmaBlaster_Functions.zs"
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
        Weapon.AmmoType1 "PB_Cell";
        Weapon.AmmoType2 "HellPistolerAmmo";
        Weapon.AmmoGive1 30;
        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "PlasmaBlasterWheel";
        PBX_WeaponBase.TakeWeaponDowngrade "PBX_ProsurvBlaster";
        Inventory.PickupSound "CHGNPKUP";
        Inventory.Pickupmessage  "$PBX_PlasmaBlaster_Pickup";
	    Inventory.AltHUDIcon "ARMZA0";
        Obituary "$OB_WEAP_PLASMABLASTER";
        AttackSound "None";
        Scale 0.8;
        Tag "$PBX_PlasmaBlaster_Tag";
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
		+WEAPON.CHEATNOTWEAPON;
    }

    bool blasterPrimary;
    bool blasterSecondary;
    int burstcount;
    const CELL_SIZE = 16;
    enum blasterEnum {
        PRIM_SEMI       = 0,
        PRIM_AUTO       = 1,
        SEC_BURST       = 0,
        SEC_CHARGE      = 1,
        TAKE_CHARGE     = 2   // Ammo take charge
    }

    override void postbeginplay()
	{
        blasterPrimary   = PRIM_SEMI;
        blasterSecondary = SEC_BURST;
		super.postbeginplay();
	}

    action state handleWeaponSpecial()
    {
        A_StopSound(2);
        A_SetInventory("GoWeaponSpecialAbility", 0);
        PB_HandleCrosshair(79);
        A_ZoomFactor(1.0);

        // Get tokens
        bool goSemi     = CountInv("Plasma_Select_Semi")   > 0;
        bool goAuto     = CountInv("Plasma_Select_Auto")   > 0;
        bool goBurst    = CountInv("Plasma_Select_Burst")  > 0;
        bool goCharge   = CountInv("Plasma_Select_Charge") > 0;

        if(countinv("PBX_CloseWheel") > 0)
		{
			A_TakeInventory("PBX_CloseWheel",1);
			return resolvestate("Ready3");
		}

        // Check if already selected, if yes go to ready3
        if( goAuto && getPrimary() == PRIM_AUTO || goBurst  && getSecondary() == SEC_BURST ||
            goSemi && getPrimary() == PRIM_SEMI || goCharge && getSecondary() == SEC_CHARGE) 
        {
            A_Print("$PB_ALREADYSELECTED"); 
            cleanModeTokens(); 
            return ResolveState("Ready3");
        }

        A_StartSound("BEP", CHAN_AUTO, CHANF_OVERLAP);

        // Change Mode and then fallthrough to the switch animation
        if(goAuto)    { A_Print("$PBX_PlasmaBlaster_Auto");    setPrimary(PRIM_AUTO);} 
        if(goSemi)    { A_Print("$PBX_PlasmaBlaster_Semi");    setPrimary(PRIM_SEMI);}
        if(goBurst)   { A_Print("$PBX_PlasmaBlaster_Burst");   setSecondary(SEC_BURST);}
        if(goCharge)  { A_Print("$PBX_PlasmaBlaster_Charge");  setSecondary(SEC_CHARGE);}     

        cleanModeTokens();
        return ResolveState(null);
    }

    action state fireWeapon(int tic)
    {
        int mode            = getPrimary();
        string projectile   = mode == PRIM_SEMI ? "HellPistolNormal" : "HellPistolAuto";

        switch(tic)
        {
            case 0:
                A_WeaponOffset(0,32);
                A_SetRoll(0);
                A_SetCrosshair(39);
                return PB_JumpIfNoAmmo(chamber:false);
                break;

            case 1:
                A_PlaySound("HRFire", CHAN_WEAPON);
		        PB_FireBullets(projectile, 1, 0, 0, 0, 0);
                PB_TakeAmmo(invoker.ammo2.getClassName());
                break;

            case 2:
                if(mode == PRIM_SEMI)
                {
                    if(JustPressed(BT_ATTACK)) return ResolveState("Fire");
                    return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOPRIMARY);
                }
                else return resolvestate(null);
                break;

            case 3:
                if(mode == PRIM_AUTO)
                {
                    if(invoker.ammo2.amount > 0 && PressingFire()) return ResolveState("AutoFire");
                    else return PB_JumpIfNoAmmo(chamber:false);
                }
                else return resolvestate(null);
                break;
        }
        return resolvestate(null);
    }

    action void cleanModeTokens()
    {
        A_SetInventory("Plasma_Select_Auto",0);
        A_SetInventory("Plasma_Select_Semi",0);
        A_SetInventory("Plasma_Select_Burst",0);
        A_SetInventory("Plasma_Select_Charge",0);
    }

    action bool getPrimary()
    {
        return invoker.blasterPrimary;
    }

    action void setPrimary(bool set)
    {
        invoker.blasterPrimary = set;
    }

    action bool getSecondary()
    {
        return invoker.blasterSecondary;
    }

    action void setSecondary(bool set)
    {
        invoker.blasterSecondary = set;
    }

    States
    {
        Spawn:
            ARMZ A -1;
            Stop;

        WeaponRespect:
            TNT1 A 0 A_StartSound("weapons/blasterpistol/ready",CHAN_WEAPON,CHANF_OVERLAP);
            AMGR ABCD 1 A_DoPBWeaponAction();
            AMGZ ABC 1 A_DoPBWeaponAction();
            AMGR QRSTUV 1 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaySound("CELLIN2", 6);
            AMGR WXY 1 A_DoPBWeaponAction();
            Goto Ready3;

		WeaponInspect:
            TNT1 A 0 A_StartSound("weapons/blasterpistol/ready",CHAN_WEAPON,CHANF_OVERLAP);
            AMGR ABCDE 1 A_DoPBWeaponAction();
            AMGR FFFFFFFFFFFFFF 1 A_DoPBWeaponAction();
        InspectHold:
            AMGR F 1 A_DoPBWeaponAction();
			TNT1 A 0 A_PressingReload("InspectHold");
            TNT1 A 0 A_StartSound("BEPBEP",CHAN_WEAPON,CHANF_OVERLAP);
            AMGR EDCBA 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            Goto Ready3;

        Deselect:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(39);
			}
			TNT1 A 0 A_StopSound(1);
			AMGR ABCDEF 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("weapons/smg_magfly1");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            AMGR FEDCBA 1;
        Ready3:
			TNT1 A 0 PBX_CheckInspect();
			AMGL A 1 {
                PB_HandleCrosshair(39);
                return A_DoPBWeaponAction();
            }
            loop;

        Fire:
            TNT1 A 0    fireWeapon(0);
            AMGF A 1;
            AMGF B 1 A_PlaySound("BEP",3);
            AMGF CD 1;
        AutoFire:
            AMGF E 1    fireWeapon(1);
            AMGF FG 1   fireWeapon(2);
            TNT1 A 0    fireWeapon(3);
            Goto Ready3;
  
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
            Goto Ready3;
            
        ChargeFire:
            TNT1 A 0 PB_JumpIfNoAmmo(min:TAKE_CHARGE,chamber:false);
            AMGF A 1 A_PlaySound("BEP",7);
            AMGF B 1 A_PlaySound("BEP",8);
            AMGF C 1 A_PlaySound("BEP",9);
            AMGF CD 5;
        ChargeHold:
            AMGF D 1 A_FireCustomMissile("RedFlareSpawn", 0, 0, 0, 0);
            TNT1 A 0 PB_ReFire("ChargeHold");
        FireCharge:
            TNT1 E 0 A_PlaySound("HRFire");
            AMGF E 1 {
		        PB_FireBullets("HellPistolCharge", 1, 0, 0, 0, 0);
                PB_TakeAmmo(invoker.ammo2.getClassName(),TAKE_CHARGE);
            }
            AMGF F 1;
            AMGF G 1;
            AMGL A 10;
            Goto Ready3;

        Reload:
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null,null,"Ready3","Ready3",CELL_SIZE);
            TNT1 A 0 A_ZoomFactor(1.0);
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
                    CELL_SIZE);
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
                PB_SetChamberEmpty(false);
            }
            AMGR WXY 1;
        FinishReload:
            AMGR FEDCBA 1;
            TNT1 A 0 {
                PB_SetReloading(false);
                A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            }
            Goto Ready3;

        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
            TNT1 A 0 A_ZoomFactor(1.0);
            TNT1 A 0 A_PlaySound("weapons/smg_magfly1");
            AMGR ABCDEF 1;
            TNT1 A 0 A_PlaySound("weapons/smg_magfly2");
            AMGR GHIJK 1;
            TNT1 A 0 {
                A_PlaySound("CELLOUT2", 5);
                PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname());
                PB_SetMagEmpty(true);
                PB_SetMagUnloaded(true);
                PB_SetChamberEmpty(true);
            }
            AMGR LMNOPQ 1;
            AMGZ CBA 1;
            AMGR DCBA 1;
            Goto Ready3;
        
        RaiseFromEmpty:
            AMGR ABCD 1;
            AMGZ ABC 1;
            Goto ContinueReload;

        WeaponSpecial:
            TNT1 A 0 handleWeaponSpecial();
            Goto Ready3;
            
        // No flash punching lol
        FlashPunching:
            TNT1 A 14;
            Goto Ready3;

        FlashKicking:
            AMGR BCDEFGHIIIIIIIII 1;
            Goto Ready3;
            
        FlashAirKicking:
            AMGR BCDEFGHIIIIIIIIIII 1;
            Goto Ready3;
            
        FlashSlideKicking:
            AMGR BCDEFGHIIIII 1;
            Goto Ready3;

        FlashSlideKickingStop:
            AMGR IIIIIHGFEDCB 1;
            Goto Ready3;
    }
}