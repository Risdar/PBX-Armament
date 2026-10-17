// Nuke Launcher 
// From Brutal Doom by Sergeant_Mark_IV
// Sprites by Tesefy

// Actual Weapon
class PBX_NukeLauncher : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
	    Inventory.AltHUDIcon "NKLGF0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PBX_NukeAmmo";
        Weapon.AmmoGive1 1;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_NukeLauncher_Pickup";
        Inventory.PickupSound "8FGPICK";
	    // Obituary "$OBBD_NUKELAUNCHER"
        Tag "$PBX_NukeLauncher_Tag";

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
        +WEAPON.BFG
        -WEAPON.AMMO_CHECKBOTH
        -INVENTORY.UNDROPPABLE
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            NKLG F -1;
            Stop;

        Deselect:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(39);
                A_StopSound(1);
			}
			NKLS EFGH 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("8FGPICK");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
		    TNT1 A 1;
            NKLS ABCD 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
			NKLG A 1 {
                PB_HandleCrosshair(39);
                return A_DoPBWeaponAction();
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 A_AlertMonsters();
            NKLF A 1 BRIGHT {
                A_PlaySound ("Rocket/Fire", 1);
                A_PlaySound ("brain/spit", 5);
                A_ZoomFactor(0.9);
            }
            NKLF A 1 BRIGHT {
                A_ZoomFactor(1.0);
                PB_FireBullets("NuclearRocket", 1, 0.1, 0, 0, 0.1);
                A_TakeInventory(invoker.ammo1.GetClassName(),1,TIF_NOTAKEINFINITE);
            }
            NKLF B 2 BRIGHT;
            NKLF CDEFGHIJKL 1;
			NKLS EFGH 1 A_WeaponOffset(0, 8, WOF_ADD);
            Goto SafelyRemoveWeapon;
  
        WeaponSpecial:
            TNT1 A 0 A_TakeInventory("GoWeaponSpecialAbility", 1);
        AltFire:
        Reload:
            TNT1 A 0;
            Goto Ready3;
            
//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        FlashPunching:
            NKLG BCDE 1;
            NKLG E 6;
            NKLG EDCB 1;     // 14 frames
            goto Ready3;

        FlashKicking:
            NKLG BCDE 1;
            NKLG E 7;
            NKLG EDCB 1;     // 15 frames
            goto Ready3;

        FlashAirKicking:
            NKLG BCDE 1;
            NKLG E 8;
            NKLG EDCB 1;    // 16 frames
            goto Ready3;

        FlashSlideKicking:
            NKLG BCDE 1; // 27 frames
		    NKLG E 21;
            NKLG EDCB 1;     
            goto Ready3;

        FlashSlideKickingStop:
            NKLG EEEEDCB 1;             // 7 frames
            goto Ready3;
    }
}