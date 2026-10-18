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

    action int getMinAmmo()
    {
        if(!invoker.mDNFFireMode && invoker.mFiringAnimation == FIRE_SECOND)
        {
            return 2;
        }
        return 1;
    }

    action void fireWeapon(int tic)
    {
        switch(tic)
        {
            case 1:
                A_StartSound("RipprPew", CHAN_AUTO, CHANF_OVERLAP);
                A_StartSound("FARRIF", CHAN_5, CHANF_OVERLAP);
                A_ZoomFactor(0.98);
                break;

            case 2:
                PB_FireBullets("PB_792x57mm",1,1,0,0,1);
                PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
                PB_FireOffset();
                A_ZoomFactor(1.0);
                PB_WeaponRecoil(-0.5,0);
                A_TakeInventory(invoker.ammo1.getClassName(), 1, TIF_NOTAKEINFINITE);

                // Since it technically fires two of the barrels
                if(invoker.mFiringAnimation == FIRE_SECOND)
                {
                    PB_FireBullets("PB_792x57mm",1,1,0,0,1);
                    PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
                    A_TakeInventory(invoker.ammo1.getClassName(), 1, TIF_NOTAKEINFINITE);
                }

                if(invoker.mDNFFireMode)
                {
                    setAnimationFrame(2, 3, 4);
                }
                else
                {
                    setAnimationFrame(3, 5, 3);
                }
                break;

            case 3:
                if (invoker.mDNFFireMode)
                {
                    setAnimationFrame(21, 22, 23);
                }
                else
                {
                    setAnimationFrame(22, 24, 22);
                }
                invoker.mFiringAnimation = (invoker.mFiringAnimation + 1) % 3;
                break;  
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
            TNT1 A 0 PB_JumpIfNoAmmo(min: getMinAmmo(), secondary: false);
            TNT1 A 0 fireWeapon(1);
            RIPR D 1 BRIGHT fireWeapon(2);
            RIPR W 1 BRIGHT fireWeapon(3);
            RIPR H 1;
            TNT1 A 0 PB_Refire();
            Goto Ready3;
			
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
		Reload:
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