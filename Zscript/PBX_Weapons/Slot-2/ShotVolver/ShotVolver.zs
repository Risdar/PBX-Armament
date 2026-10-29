// Actual Weapon
class PBX_Shotvolver : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
	    Inventory.AltHUDIcon "REVPA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_Shell";
        Weapon.AmmoType2 "ShotvolverAmmo";
        Weapon.AmmoGive1 12;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_Shotvolver_Pickup";
        Inventory.PickupSound "Revolver/Hammer";
        Obituary "$OB_WEAP_SHOTVOLVER";
        AttackSound "None";
        Tag "$PBX_Shotvolver_Tag";
        Scale 1.0;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////

    const CHAMBER_AMOUNT = 6;
    
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    
//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    private
    action void fireWeapon(int tic)
    {
        switch(tic)
        {
            case 1:
                A_ZoomFactor(0.9);
                A_AlertMonsters();
                A_StartSound("Revolver/Fire",CHAN_WEAPON,CHANF_OVERLAP);
				PB_FireBullets("ExplosiveProjectile",5,6,0,0,6); 
                PB_TakeAmmo(invoker.ammo2.getClassName(),1,0);
				A_SetInventory("CantDoAction", 1);
                break;

            case 2:
                PB_WeaponRecoil(-3,frandom[sfx](-1.5,1.5));
                A_ZoomFactor(1.00);
                break;
        }
    }

    private
    action void spawnRevolverCasing()
	{
		int casingCount = CHAMBER_AMOUNT - invoker.ammo2.amount;
		for(casingCount > 0; casingCount--;)
		{
            PB_SpawnCasing("ExplosiveShellCasing",random(10,14),random(-1,3),random(26,28),random(1,3),random(-5,-2),random(4,7));
		}
	}

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            REVP A -1;
            Stop;

        WeaponRespect:
            REVO A 1 Offset(15, 50);
            REVO A 1 Offset(10, 45);
            REVO A 1 Offset(5, 35);
            REVO A 1 Offset(2, 33);
            REVO A 1 Offset(0, 32) A_DoPBWeaponAction();
            REVR ABCDEFF 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Revolver/Open",CHAN_WEAPON,CHANF_OVERLAP);
            REVU ABCDEEFGHIJKKKKKKKK 1 A_DoPBWeaponAction();
            REVU LMN 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("insertshell",CHAN_WEAPON,CHANF_OVERLAP);
            REVU OOPPPPPPPQQR 1 A_DoPBWeaponAction();
            REVR QPONMLKJIH 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Revolver/Close",CHAN_WEAPON,CHANF_OVERLAP);
            REVR GFEEDCBA 1 A_DoPBWeaponAction();
            REVO LMNOP 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Revolver/Hammer",CHAN_WEAPON,CHANF_OVERLAP);
            REVO QRSTUVW 1 A_DoPBWeaponAction();
            goto Ready3;

        WeaponInspect:
            REVR ABCDEF 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Revolver/Open",CHAN_WEAPON,CHANF_OVERLAP);
            REVR GHIJ 1 A_DoPBWeaponAction();
            REVR K 3 A_DoPBWeaponAction();
        HoldInspect:
            REVR KK 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            REVR JIH 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Revolver/Close",CHAN_WEAPON,CHANF_OVERLAP);
            REVR GFEDCBA 1 A_DoPBWeaponAction();
            goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            REVS EFGH 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select.Hammering:
            2EVO STUV 1;
            TNT1 A 0 PB_SetChamberEmpty(false);
            goto Ready3;

        Select:
            TNT1 A 0 {
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("Revolver/Hammer");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"Select.Hammering");
            REVS ABCD 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
			TNT1 A 0 {
                PB_SetRoll(0);
                A_ZoomFactor(1.0);
                PB_HandleCrosshair(39);
				A_SetInventory("CantDoAction",0);
                PB_SetReloading(false);
            }
        ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
			REVO A 1 {
                if(PB_GetChamberEmpty())
                {
                    A_SetWeaponFrame(11);
                }
                PB_CoolDownBarrel();
                return A_DoPBWeaponAction();
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 PB_JumpIfNoAmmo();
            REVO A 0 fireWeapon(1);
            "####" B 1 BRIGHT;
            "####" C 1 BRIGHT;
            "####" A 0 fireWeapon(2);
            "####" DEFG 1;
            "####" HIJ 1;
            "####" K 1 PB_SetChamberEmpty(true);
		    "####" K 2 A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE|WRF_ALLOWZOOM|WRF_ALLOWRELOAD);
        Hammering:
            REVO LMNOP 1;
            "####" A 0 A_StartSound("Revolver/Hammer",CHAN_WEAPON,CHANF_OVERLAP);
            "####" QRSTUVW 1 A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE|WRF_ALLOWZOOM);
            "####" A 0 {
				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
				A_SetInventory("CantDoAction",0);
            }
            "####" A 0 PB_ReFire();
            goto Ready3;
  
//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
        Reload:
            TNT1 A 0 PB_CheckReload(null,"ReloadEmpty","Hammering","Ready3","Ready3",CHAMBER_AMOUNT);
			TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            // Raise Weapon
            REVR ABCDEFF 1;
            "####" A 0 A_StartSound("Revolver/Open",CHAN_WEAPON,CHANF_OVERLAP);
            "####" GHIJKKK 1;
            "####" LMNOP 1;
            "####" Q 2;
        ShellChecker:
            // Main reload loop
			REVR A 0 A_JumpIf(invoker.ammo1.amount < 1 || invoker.ammo2.amount >= CHAMBER_AMOUNT,"FinishReload");
			"####" A 0 PB_SetReloading(true);
            "####" Z 2;
            "####" RS 1;
            "####" A 0 A_StartSound("insertshell",CHAN_WEAPON,CHANF_OVERLAP);
            "####" TT 1;
            "####" A 0 {
		        PB_SpawnCasing("ExplosiveShellCasing",random(10,14),random(-1,3),random(26,28),random(1,3),random(-5,-2),random(4,7));
				A_Giveinventory(invoker.ammo2.getClassName(),1);
				A_Takeinventory(invoker.ammo1.getClassName(),1,TIF_NOTAKEINFINITE);
            }
            "####" UVWXY 1;
			Loop;

        FinishReload:
            REVR QPONMLKJIH 1;
            TNT1 A 0 A_StartSound("Revolver/Close",CHAN_WEAPON,CHANF_OVERLAP);
            REVR GFEEDCBA 1;
			TNT1 A 0 PB_SetReloading(false);
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"Hammering");
            TNT1 A 0 PB_ReFire();
            goto Ready3;

        ReloadEmpty:
            REVR ABCDEFF 1;
            TNT1 A 0 A_StartSound("Revolver/Open",CHAN_WEAPON,CHANF_OVERLAP);
            REVU ABCDEEFGHIJKKKKKKKK 1;
            REVU LMN 1;
            TNT1 A 0 {
                spawnRevolverCasing();
                PB_AmmoIntoMag(
                    invoker.ammo2.getclassname(), 
                    invoker.ammo1.getclassname(), 
                    CHAMBER_AMOUNT
                );
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
                A_StartSound("insertshell",CHAN_WEAPON,CHANF_OVERLAP);
            }
        FinishUnloadedReload:
            REVU OOPPPPPPPQQR 1;
            goto FinishReload;
        
//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				A_StartSound("Ironsights",CHAN_AUTO,CHANF_OVERLAP);
			}
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty(),"Ready3");
			// Raise Weapon
            REVR ABCDEFF 1;
            TNT1 A 0 A_StartSound("Revolver/Open",CHAN_WEAPON,CHANF_OVERLAP);
            TNT1 A 0 {
                PB_UnloadMag(
                    invoker.ammo2.getclassname(),
                    invoker.ammo1.getclassname(),
                    goal:0
                );
                PB_SetMagEmpty(true);
                PB_SetChamberEmpty(true);
            }
            TNT1 A 0 A_StartSound("Revolver/Unload",CHAN_WEAPON,CHANF_OVERLAP);
            REVU ABCDEEFG 1;
		FinishUnload:
		    REVU GFEDCB 1;
            REVU A 1 A_StartSound("Revolver/Close",CHAN_WEAPON,CHANF_OVERLAP);
            REVR GFEEDCBA 1;
			TNT1 A 0 PB_SetReloading(false);
            goto Ready3;            

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 {
                A_TakeInventory("GoWeaponSpecialAbility", 1);
                A_Print("$PBX_NoSpecial");
            }
        AltFire:
            goto Ready3;            

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        FlashPunching:
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"FlashPunching.Hammering");
            // 14 frames
            REVO XYZ 1;
            REVO "[" 1;
            TNT1 A 6;
            REVO "[" 1;
            REVO ZYX 1;   
            goto Ready3;

        FlashPunching.Hammering:
            R3VO ABCD 1;
            R3VO E 6;
            R3VO DCBA 1;
            goto Ready3;

        FlashKicking:
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"FlashKicking.Hammering");
            // 15 frames
            REVO XYZ 1;
            REVO "[" 1;
            TNT1 A 7;
            REVO "[" 1;
            REVO ZYX 1;   
            goto Ready3;

        FlashKicking.Hammering:
            R3VO ABCD 1;
            R3VO E 7;
            R3VO DCBA 1;
            goto Ready3;

        FlashAirKicking:
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"FlashAirKicking.Hammering");
            // 16 frames
            REVO XYZ 1;
            REVO "[" 1;
            TNT1 A 8;
            REVO "[" 1;
            REVO ZYX 1;   
            goto Ready3;

        FlashAirKicking.Hammering:
            R3VO ABCD 1;
            R3VO E 8;
            R3VO DCBA 1;
            goto Ready3;

        FlashSlideKicking:
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"FlashSlideKicking.Hammering");
            // 27 frames
            REVO XYZ 1;
            REVO "[" 1;
            TNT1 A 19;
            REVO "[" 1;
            REVO ZYX 1;   
            goto Ready3;

        FlashSlideKicking.Hammering:
            R3VO ABCD 1;
            R3VO E 19;
            R3VO DCBA 1;
            goto Ready3;

        FlashSlideKickingStop:
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"FlashSlideKickingStop.Hammering");
            // 7 frames
            TNT1 A 3;
            REVO "[" 1;
            REVO ZYX 1;    
            goto Ready3;

        FlashSlideKickingStop.Hammering:
            R3VO E 3;
            R3VO DCBA 1;
            goto Ready3;
    }
}