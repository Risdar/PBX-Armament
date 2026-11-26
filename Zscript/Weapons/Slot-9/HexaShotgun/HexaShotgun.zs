// Hexa Shotgun 
// From a Brutal Doom Addon by Dox778
// Complex Doom LCA - Firing sound effect, reload/idle frames
// ȽʘɌƉ ȽʘŦḢɅɌ - New Hexa Shotgun idle frame
// Iamcarrotmaster - Polishing the idle sprite
// leonelc - Firing frames
// IDDQD_1337 - help with sprinting/firing frames, firing sound effect
// Doom 3/ID Software - Reload sound effects

// Actual Weapon
class PBX_HexaShotgun : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        Weapon.Kickback 76;
	    Inventory.AltHUDIcon "HSGPA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_Shell";
        Weapon.AmmoType2 "HexaShotgunAmmo";
        Weapon.AmmoGive1 6;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_HexaShotgun_Pickup";
        Inventory.PickupSound "CLIPINSS";
        Obituary "$OB_WEAP_HEXASG";
        Tag "$PBX_HexaShotgun_Tag";
        Scale 0.9;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    bool mHellBlast;
    const HELLBLAST_SELFDAMAGE = 10; // Take this amount of hp every hellblast shot

    const BARREL_CAPACITY = 6;

//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void fireHexa()
    {
        bool hblast = invoker.mHellBlast;

        A_StartSound("QSGFIRE1", CHAN_WEAPON, CHANF_DEFAULT, 1.0);
        A_AlertMonsters();
        
        if(hblast)
        {
            PB_FireBullets("HellFireProjectile", 72,7, 0, 0, 5);
            A_Startsound("DTechShotty/Fire",CHAN_WEAPON,CHANF_OVERLAP);
            A_Startsound("DTechShotty/PrimaryAmb",CHAN_AUTO,CHANF_OVERLAP);
            PB_FireOffset();
            PB_IncrementHeat(30);
            A_Recoil3D(30);
            A_DamageSelf(HELLBLAST_SELFDAMAGE);
        }
        else
        {
            PB_FireBullets("PB_8GAPellet", 72,7, 0, 0, 5);
            PB_FireBullets("PB_8GAPellet_LP", 6, 0, 0, 0, 0);				
            PB_IncrementHeat(20);
            A_Recoil3D(20);
        }

        A_TakeInventory(invoker.ammo2.getclassname(),BARREL_CAPACITY);
        A_FireCustomMissile("YellowFlareSpawn", 15, 0, 0, 0);
        A_FireCustomMissile("YellowFlareSpawn", -15, 0, 0, 0);
        A_FlashOverlay();
        A_ZoomFactor(0.7);
        PB_FireOffset();
    }

    action state handleSpecial()
    {
        A_TakeInventory("GoWeaponSpecialAbility", 1);
        invoker.mHellBlast = !invoker.mHellBlast;
        if(invoker.mHellBlast)
        {
            A_Print("$PBX_HexaShotgun_HellBlast");
            return resolvestate("NormalToHellBlast");
        }
        else
        {
            A_Print("$PBX_HexaShotgun_Normal");
            return resolvestate("HellBlastToNormal");
        }
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            HSGP A -1;
            Stop;

        WeaponRespect:
            // Raise
            HSGF T 1 {
                A_WeaponOffset(-2,33);
                return A_DoPBWeaponAction();
            }
            HSGF T 1 {
                A_WeaponOffset(-4,34);
                return A_DoPBWeaponAction();
            }
            HSGF T 1 {
                A_WeaponOffset(-7,36);
                return A_DoPBWeaponAction();
            }
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                return A_DoPBWeaponAction();
            }
        WeaponInspect:
            // Open Chamber
            HSGR ABCDEFG 1 A_DoPBWeaponAction();
            HSGR H 4 A_DoPBWeaponAction();
            HSGR IJKMOR 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("QSGOPN",CHAN_WEAPON,CHANF_OVERLAP);
            HSR3 G 2 {
                A_WeaponOffset(9,38);
                return A_DoPBWeaponAction();
            }
            HSR3 G 1 {
                A_WeaponOffset(5,35);
                return A_DoPBWeaponAction();
            }
            HSR3 G 1 {
                A_WeaponOffset(2,33);
                return A_DoPBWeaponAction();
            }
            HSR3 G 1 {
                A_WeaponOffset(0,32);
                return A_DoPBWeaponAction();
            }
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            HSR3 G 14 A_DoPBWeaponAction();
        ContinueRespect:
            HSR3 HIJ 1 A_DoPBWeaponAction();
            HSR2 OPQRSTUV 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("QSGCLSE",CHAN_WEAPON,CHANF_OVERLAP);
            HSR2 WXYYYZ 1 A_DoPBWeaponAction();
            HSR3 A 1 A_DoPBWeaponAction();
            // Blink
            TNT1 A 0 A_StartSound("QSGCHRG",CHAN_WEAPON,CHANF_OVERLAP);
            HSGF U 10 A_DoPBWeaponAction();
            HSGF VW 1 A_DoPBWeaponAction();
            HSF2 A 15 A_DoPBWeaponAction(); 
            HSGF WVV 1 A_DoPBWeaponAction();
            Goto Ready3;

        HoldInspect:
            HSR3 G 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            Goto ContinueRespect;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            HSGS ABCDEF 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    // PB_HandleCrosshair(41);
                A_SetCrosshair(-1);
                PBX_WeaponRaise("CLIPINSS");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            TNT1 A 0 A_GunFlash();
            HSGS FEDCBA 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 A_JumpIf(invoker.mHellBlast,"Ready2");
        ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
		    TNT1 A 0 A_JumpIfTargetInLOS("BlinkBegin", 0, 0, JLOSF_COMBATANTONLY, 12000); //checks if an enemy/player is in sight
			HSGF T 1 {
                PB_CoolDownBarrel();
                return A_DoPBWeaponAction();
            }
            loop;

        Ready2:
            TNT1 A 0 PBX_CheckInspect();
			HSF2 A 1 {
                PB_CoolDownBarrel();
                return A_DoPBWeaponAction();
            }
            loop;

        BlinkBegin:
            // TNT1 A 0 A_StartSound("QSGCHRG",CHAN_WEAPON,CHANF_OVERLAP);
            HSGF UVW 1 A_DoPBWeaponAction();
        Blink:
            HSF2 A 1 A_DoPBWeaponAction(); //Blinking frame
            TNT1 A 0 A_JumpIfTargetInLOS("Blink", 0, 0, JLOSF_COMBATANTONLY, 12000); //Still in sight? Then repeat!
            HSGF WVU 1 A_DoPBWeaponAction();
		    Goto Ready3;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 PB_JumpIfNoAmmo(min:BARREL_CAPACITY);
            HSGF A 1 BRIGHT fireHexa();
            HSGF B 1 BRIGHT {
				A_ZoomFactor(0.8);
                PB_WeaponRecoil(-10,-5);
			}
            TNT1 A 0 A_ZoomFactor(1.3);
            HSGF C 1 BRIGHT {
				A_ZoomFactor(0.9);
                PB_WeaponRecoil(-8,-4);
			}
            TNT1 A 0 A_ZoomFactor(1.0);
            HSGF DE 1 PB_WeaponRecoil(-4,-2);
            HSGF EEEFGH 1;
            HSGF IJKLMNOPQR 1;
            HSGF S 1;
            HSGF T 1 A_WeaponOffset(0,34);
            HSGF TT 1 A_WeaponOffset(0,33);
            HSGF T 1 A_WeaponOffset(0,32);
            HSGF T 5 A_DoPBWeaponAction(WRF_NOFIRE|WRF_NOBOB);
		    Goto Reload;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 handleSpecial();
        NormalToHellBlast:
            TNT1 A 0 A_StartSound("QSGCHRG",CHAN_WEAPON,CHANF_OVERLAP);
            HSGF UVW 1;
            Goto Ready3;

        HellBlastToNormal:
            HSGF WVU 1;
            Goto Ready3;

        AltFire:
            Goto Ready3;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
		Reload:
            TNT1 A 0 PB_CheckReload(null,null,null,"Ready3","Ready3",BARREL_CAPACITY);
            //Reload 6 barrels
            TNT1 A 0 A_WeaponOffset(20,48);
            TNT1 A 0 A_WeaponOffset(0,32);
            HSGF T 1 A_WeaponOffset(-2,33);
            HSGF T 1 A_WeaponOffset(-4,34);
            HSGF T 1 A_WeaponOffset(-7,36);
            // Raise
            HSGR ABCDEFG 1 A_WeaponOffset(0,32);
            HSGR H 4;
            // Open
            HSGR HIJKLMN 1;
            TNT1 A 0 A_StartSound("QSGOPN",CHAN_WEAPON,CHANF_OVERLAP);
            TNT1 A 0 {
                if(invoker.ammo2.amount == 4)
                    return resolvestate("Insert6");
                if(invoker.ammo2.amount == 2)
                    return resolvestate("Insert4");
                else
                    return resolvestate(null);
            }
        Insert2:
            TNT1 A 0 {
                if(!PB_GetMagUnloaded())
                {
                    PB_SpawnCasing("ShotgunCasing",14,-3,28,-1,-4,4);
                    PB_SpawnCasing("ShotgunCasing",14,-3,32,-1,-4,4);
                    PB_SpawnCasing("ShotgunCasing",15,3,28,-1,-4,4);
                    PB_SpawnCasing("ShotgunCasing",15,3,32,-1,-4,4);
                    PB_SpawnCasing("ShotgunCasing",16,3,28,-1,-4,4);
                    PB_SpawnCasing("ShotgunCasing",16,3,32,-1,-4,4);
                }
            }
            HSGR S 2 A_WeaponOffset(9,38);
            HSGR S 1 A_WeaponOffset(5,35);
            HSGR S 1 A_WeaponOffset(2,33);
            HSGR S 2 A_WeaponOffset(0,32);
            HSGR TUVWW 1;
            TNT1 A 0 {
                A_StartSound("QSGIN",CHAN_WEAPON,CHANF_OVERLAP);
                A_TakeInventory(invoker.ammo1.getclassname(),2);
                A_GiveInventory(invoker.ammo2.getclassname(),2);
            }
            HSGR XXYZ 1;
        Insert4:
            HSR2 A 1;
            HSR2 A 1 A_WeaponOffset(-2,31);
            HSR2 A 1 A_WeaponOffset(-3,31);
            HSR2 A 2 A_WeaponOffset(-4,33);
            HSR2 A 1 A_WeaponOffset(-2,33);
            HSR2 A 2 A_WeaponOffset(0,32);
            HSR2 BCDEE 1;
            TNT1 A 0 {
                A_StartSound("QSGIN",CHAN_WEAPON,CHANF_OVERLAP);
                A_TakeInventory(invoker.ammo1.getclassname(),2);
                A_GiveInventory(invoker.ammo2.getclassname(),2);
            }
            HSR2 FFGH 1;
            HSR2 I 1 A_WeaponOffset(-1,30);
            HSR2 I 1 A_WeaponOffset(-2,29);
            HSR2 I 3 A_WeaponOffset(-4,27);
            HSR2 I 1 A_WeaponOffset(-3,28);
            HSR2 I 2 A_WeaponOffset(-1,31);
        Insert6:
            HSR2 JKLMM 1 A_WeaponOffset(0,32);
            TNT1 A 0 {
                A_StartSound("QSGIN",CHAN_WEAPON,CHANF_OVERLAP);
                A_TakeInventory(invoker.ammo1.getclassname(),2);
                A_GiveInventory(invoker.ammo2.getclassname(),2);
            }
            HSR2 NN 1;
        FinishReload:
            HSR2 OPQRSTUV 1;
            TNT1 A 0 A_StartSound("QSGCLSE",CHAN_WEAPON,CHANF_OVERLAP);
            HSR2 WXYYYZ 1;
            HSR3 A 1;
            Goto Ready3;
        
//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(PB_GetMagEmpty(),"Ready3");
            HSGF T 1 A_DoPBWeaponAction();
            QSGF P 0 A_ZoomFactor(1.0);
            HSGS ABCDEF 1;
            TNT1 A 0 A_StartSound("QSGOPN",CHAN_WEAPON,CHANF_OVERLAP);
            TNT1 A 0 PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname(),1,1,1,0,"PB_SingleShell");
        FinishUnload:
            TNT1 A 19;
            HSR2 QRSTUV 1;
            TNT1 A 0 A_StartSound("QSGCLSE",CHAN_WEAPON,CHANF_OVERLAP);
            HSR2 WXYYYZ 1;
            HSR3 A 1;
            goto Ready3;

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        MuzzleFlash:
			QSFM AB 1 Bright A_GunFlash();
			Stop;

        FlashPunching:
            // 14 frames
            HSGR BDEGHHHHHHGEDB 1;      
            goto Ready3;

        FlashKicking:
            // 15 frames
            HSR3 BCDEFFFFFFFEDCB 1;     
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            HSR3 BCDEFFFFFFFFEDCB 1;    
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            HSR3 BCDEF 1;
            HSR3 F 17;
            HSR3 FEDCB 1; 
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            HSR3 FFFEDCB 1;             
            goto Ready3;
    }
}