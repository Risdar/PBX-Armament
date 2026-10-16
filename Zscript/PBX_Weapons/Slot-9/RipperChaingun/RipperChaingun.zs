// Includes
// #include "./PlasmaBlaster_Functions.zs"
// #include "./PlasmaBlaster_Wheel.zs"

// class Plasma_Select_Auto : inventory {default{inventory.maxamount 1;}}

// Actual Weapon
class PBX_RipperChaingun : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        // PB_WeaponBase.UsesWheel true;
        // PB_WeaponBase.WheelInfo "PlasmaBlasterWheel";
	    Inventory.AltHUDIcon "RIPRA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_HighCalMag";
        Weapon.AmmoGive1 30;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_RipperChaingun_Pickup";
        Inventory.PickupSound "RipprSel";
        Obituary "$OB_WEAP_RIPPERCHAINGUN";
        AttackSound "None";
        Tag "$PBX_RipperChaingun_Tag";
        Scale 0.7;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    bool mDNFFireMode;
    int mFiringAnimation;

    enum FiringAnimation
    {
        FIRE_RESET
        ,FIRE_SECOND
        ,FIRE_THIRD
    }

//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    
//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void handleSpecial()
    {
        A_TakeInventory("GoWeaponSpecialAbility", 1);
        invoker.mDNFFireMode = !invoker.mDNFFireMode;
        A_Print(invoker.mDNFFireMode ? "$PBX_RipperChaingun_DNF" : "$PBX_RipperChaingun_Classic");
        A_StartSound("weapons/empty", CHAN_AUTO, CHANF_OVERLAP);
    }

    action void fireWeapon(bool classicFire = false)
    {
        PB_FireBullets("PB_792x57mm",1,1,0,0,1);
        PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
        PB_FireOffset();
        A_ZoomFactor(1.0);
        PB_WeaponRecoil(-0.5,0);
        A_TakeInventory(invoker.ammo1.getClassName(), 1, TIF_NOTAKEINFINITE);
        invoker.mFiringAnimation = (invoker.mFiringAnimation + 1) % 3;

        // Since it technically fires two of the barrels
        if(classicFire)
        {
            PB_FireBullets("PB_792x57mm",1,1,0,0,1);
            PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
            A_TakeInventory(invoker.ammo1.getClassName(), 1, TIF_NOTAKEINFINITE);
        }
    }

    action void setAnimationFrame(int frm1, int frm2, int frm3)
    {
        int frm;
        switch(invoker.mFiringAnimation)
        {
            case FIRE_RESET:  frm = frm1; break; 
            case FIRE_SECOND: frm = frm2; break; 
            case FIRE_THIRD:  frm = frm3; break;
        }
        A_SetWeaponFrame(frm);
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            RIPR A -1;
            Stop;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            RIPR IJKLM 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
			    PB_HandleCrosshair(75);
                PBX_WeaponRaise("RipprSel");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            RIPR MLKJI 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
			RIPR B 1 {
                invoker.mFiringAnimation = FIRE_RESET;
                PB_CoolDownBarrel();
                return A_DoPBWeaponAction();
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 PB_JumpIfNoAmmo(secondary:false);
            TNT1 A 0 {
                A_StartSound("RipprPew",CHAN_AUTO,CHANF_OVERLAP);
                A_StartSound("FARRIF",CHAN_5,CHANF_OVERLAP);
                A_ZoomFactor(0.98);
            }
			TNT1 A 0 A_JumpIf(invoker.mDNFFireMode,"FireDNF");
			TNT1 A 0 A_JumpIf(invoker.mFiringAnimation == FIRE_SECOND,"Fire2");
			RIPR D 1 BRIGHT fireWeapon();
			RIPR W 1 BRIGHT;
        EndFire:
			RIPR H 1;
			TNT1 A 0 PB_Refire();
            goto Ready3;
            
		Fire2:
            TNT1 A 0 PB_JumpIfNoAmmo(min:2,secondary:false);
			RIPR F 1 BRIGHT fireWeapon(classicFire:true);
			RIPR Y 1 BRIGHT;
            goto EndFire;
			
		FireDNF:
            TNT1 A 0 PB_JumpIfNoAmmo(secondary:false);
			RIPR C 1 BRIGHT {
                fireWeapon();
                setAnimationFrame(2,3,4);
            }
			RIPR V 1 BRIGHT setAnimationFrame(21,22,23);
            goto EndFire;
			
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            goto Ready3;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
		Reload:
            goto Ready3;
        
//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
            goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 handleSpecial();
        SwitchAnimation:
            RIPR TUUUTS 1;
            goto Ready3;            
                
//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        FlashPunching:
            // 14 frames
            RIPR NOPQ 1;
            RIPR R 6;
            RIPR QPON 1;      
            goto Ready3;

        FlashKicking:
            // 15 frames
            RIPR NOPQ 1;
            RIPR R 7;
            RIPR QPON 1;  
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            RIPR NOPQ 1;
            RIPR R 8;
            RIPR QPON 1;  
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            RIPR NOPQ 1;
            RIPR R 19;
            RIPR QPON 1;  
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            RIPR RRRQPON 1;               
            goto Ready3;
    }
}