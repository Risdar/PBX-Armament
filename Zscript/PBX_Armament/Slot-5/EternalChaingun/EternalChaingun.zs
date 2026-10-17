// Eternal Chaingun 
// From a BD Addon by D_Boi
// TypicalSF (Base Sprite)
// Sergeant_Mark_IV (BD code used as a Base)

// Includes
// #include "./EternalChaingun_Functions.zs"

// Actual Weapon
class PBX_EternalMinigun : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
	    Inventory.AltHUDIcon "MGUNA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_HighCalMag";
        Weapon.AmmoGive1 50;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_EternalChaingun_Pickup";
        Inventory.PickupSound "CBOXPKUP";
        Obituary "$OB_WEAP_ETERNALCHAINGUN";
        AttackSound "None";
        Tag "$PBX_EternalChaingun_Tag";
        Scale 0.9;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    const MUZZLE_FLASH_LAYER2 = -4;
    const MUZZLE_FLASH_LAYER3 = -5;

//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void EChaingun_Fire(bool isAlt = false)
    {
        if(isAlt)
        {
            PB_FireBullets("EChaingunFreeze", 1, 5, 0, 0, 5);
            PB_FireBullets("EChaingunLightning", 1, 5, 0, 0, 5);
            PB_IncrementHeat();
            A_TakeInventory(invoker.ammo1.getClassName(), 1, TIF_NOTAKEINFINITE);
            PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
            PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
            A_StartSound("weapon/EternalChaingun/Shoot", CHAN_AUTO, CHANF_OVERLAP);
            A_FlashOverlay(MUZZLE_FLASH_LAYER2);A_OverlayOffset(MUZZLE_FLASH_LAYER2,-40,-5);
            A_FlashOverlay(MUZZLE_FLASH_LAYER3);A_OverlayOffset(MUZZLE_FLASH_LAYER3,40,-5);
        }
        
        PB_FireBullets("EternalChaingunTracer", 1, 3, 0, 0, 3);
        A_TakeInventory(invoker.ammo1.getClassName(), 1, TIF_NOTAKEINFINITE);
        PB_IncrementHeat();
        PB_GunSmoke_Basic(0,0,2);
        A_StartSound("weapon/EternalChaingun/Shoot", CHAN_AUTO);
        PB_FireOffset();
        PB_DynamicTail("lmg", "lmg");
        A_AlertMonsters();
        PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
        PB_WeaponRecoil(-0.6,frandom[sfx](1.6, -1.6));
        // A_Firecustommissile("50CaseSpawn",0,0,-12,-18)
        A_FlashOverlay();
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            MGUN A -1;
            Stop;

        WeaponRespect:
            CHGS ABCD 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("DTHDLRST",CHAN_6);
            CHAN AABBCCDDEEFFGG 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("8HAINSW2", CHAN_AUTO);
            CHAN H 10 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("8HAINSW3", CHAN_AUTO);
            CHAN GFEDCBA 1 A_DoPBWeaponAction();
            CHAX ABCD 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("CHAINSTA", CHAN_5);
            TNT1 A 0 A_StartSound("weapon/EternalChaingun/Stop", CHAN_5);
            Goto Ready3;

        WeaponInspect:
            TNT1 A 0 A_StartSound("DTHDLRST",CHAN_6);
            CHAN AABBCCDDEEFFGG 1;
            TNT1 A 0 A_StartSound("8HAINSW2", CHAN_AUTO);
        HoldInspect:
            CHAN H 1;
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            TNT1 A 0 A_StartSound("8HAINSW3", CHAN_AUTO);
            CHAN GFEDCBA 1 A_DoPBWeaponAction();
            CHAX ABCD 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("CHAINSTA", CHAN_5);
            TNT1 A 0 A_StartSound("weapon/EternalChaingun/Stop", CHAN_5);
            Goto Ready3;

        Deselect:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(39);
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_WEAPON);
                PBX_WeaponLower();
			}
			CHGS DCBA 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("weapons/minigun/respect1");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            CHGS ABCD 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
        ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
			CHAX A 1 {
				PB_CoolDownBarrel();
                PB_HandleCrosshair(39);
                return A_DoPBWeaponAction();
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
            }
			TNT1 A 0 {
                A_StartSound("CHAINSTA", CHAN_5);
                A_AlertMonsters();
            }
			CHAX BC 1;
			CHAX D 1;
			CHAX AB 1;
			CHAX CDABCD 1;
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
            TNT1 A 0 {
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StartSound("CHAINSPI", CHAN_5, CHANF_LOOPING);
            }
			CHGG ABCDABCD 1;
		Hold:
			TNT1 A 0 A_StartSound("weapon/EternalChaingun/Shoot",CHAN_WEAPON);
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
			CHF_ A 1 BRIGHT EChaingun_Fire();
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
			CHF_ B 1 BRIGHT EChaingun_Fire();
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
			CHF_ C 1 BRIGHT EChaingun_Fire();
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
			CHF_ D 1 BRIGHT EChaingun_Fire();
		    TNT1 A 0 PB_ReFire("Hold");
        SpinDown:
            TNT1 A 0 {
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_WEAPON);
                A_StartSound("weapon/EternalChaingun/Stop");
            }
            CHAX A 1 A_DoPBWeaponAction();
            CHAX B 1 A_DoPBWeaponAction();
            CHAX A 0 A_FireCustomMissile("SmokeSpawner11",0,0,0,0);
            CHAX C 2 A_DoPBWeaponAction();
            CHAX D 1 A_DoPBWeaponAction();
            CHAX A 0 A_FireCustomMissile("SmokeSpawner11",0,0,0,0);
            CHAX A 1 A_DoPBWeaponAction();
            CHAX B 1 A_DoPBWeaponAction();
            CHAX A 0 A_FireCustomMissile("SmokeSpawner11",0,0,0,0);
            CHAX C 1 A_DoPBWeaponAction();
            CHAX D 1 A_DoPBWeaponAction();
            CHAX A 0 A_FireCustomMissile("SmokeSpawner11",0,0,0,0);
            CHAX A 1 A_DoPBWeaponAction();
            goto Ready;

        EmptySpin:
            TNT1 A 0 {
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_WEAPON);
                A_StartSound("weapon/EternalChaingun/Stop");
            }
            CHAX ABCD 1;
            TNT1 A 0 A_StartSound("weapons/empty",0);
            TNT1 A 0 PB_Refire("Hold");
            Goto SpinDown;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
            }
            TNT1 A 0 A_StartSound("DTHDLRST",CHAN_6);
            CHAN AABBCCDDEEFFGG 1;
            TNT1 A 0 A_StartSound("8HAINSW2", CHAN_AUTO);
            CHAN H 2;
            CHNG ABCD 1;
            TNT1 A 0 {
                A_StartSound("DTHDRSN", CHAN_5, CHANF_LOOPING);
                A_StartSound("8HAINFIR", CHAN_WEAPON, CHANF_LOOPING);
            }
        AltHold:
            TNT1 A 0 PB_jumpIfNoAmmo("SpinDownAlt",2,false,false);
            CHNG A 1 BRIGHT EChaingun_Fire(true);
            TNT1 A 0 PB_jumpIfNoAmmo("SpinDownAlt",2,false,false);
            CHNG B 1 BRIGHT EChaingun_Fire(true);
            TNT1 A 0 PB_jumpIfNoAmmo("SpinDownAlt",2,false,false);
            CHNG C 1 BRIGHT EChaingun_Fire(true);
            TNT1 A 0 PB_jumpIfNoAmmo("SpinDownAlt",2,false,false);
            CHNG D 1 BRIGHT EChaingun_Fire(true);
            TNT1 A 0 PB_ReFire("AltHold");
        SpinDownAlt:
            TNT1 A 0 {
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_WEAPON);
                A_StartSound("DTHDLRSP", CHAN_5,CHANF_OVERLAP);
                A_StartSound("weapon/EternalChaingun/Stop");
            }
            CHNG ABCDABCD 1;
            CHNG D 2;
        SwitchBack:
            CHAN HH 1;
            TNT1 A 0 A_StartSound("8HAINSW3", CHAN_AUTO);
            CHAN GFEDCBA 1;
            CHAX AAA 3;
            GoTo Ready;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 {
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_WEAPON);
                A_StartSound("weapon/EternalChaingun/Stop");
            }
            TNT1 A 0 {
				A_Takeinventory("GoWeaponSpecialAbility",1);
                A_Print("$PBX_NoSpecial");
			}
            Goto Ready3;
            
//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        MuzzleFlash:
            P1SF D 1 BRIGHT {A_SetWeaponFrame(3 + random[sfx](0, 2)); A_GunFlash();}
			P1SF G 1 BRIGHT {A_SetWeaponFrame(6 + random[sfx](0, 2)); A_GunFlash();}
            stop;

        FlashPunching:
            CHGS DCBA 1;      // 14 frames
            CHGS A 6;
            CHGS ABCD 1;
            goto Ready3;

        FlashKicking:
            CHGS DCBA 1;      
            CHGS A 7;
            CHGS ABCD 1;    // 15 frames
            goto Ready3;

        FlashAirKicking:
            CHGS DCBA 1;      
            CHGS A 8;
            CHGS ABCD 1;    // 16 frames
            goto Ready3;

        FlashSlideKicking:
            CHGS DCBA 1;      
            CHGS A 19;
            CHGS ABCD 1; // 27 frames
            goto Ready3;

        FlashSlideKickingStop:
            CHGS AAAABCD 1;  // 7 frames
            goto Ready3;
    }
}