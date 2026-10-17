// THIS IS AN OLD VERSION KEPT FOR ARCHIVING PURPOSES

// The SPAS 12 
// From BD Plus made by yaelvolador
// sprite is made by Wocht11k
// Originally from BD Plus then ported to PB2022 by RENEGADE_ANDROiD
// the PB2022 version is the base for the PBX version
// some sounds are from Half-Life 2

// // Includes
// #include "./ProsurvPSG_Functions.zs"
// #include "./ProsurvPSG_Wheel.zs"
// #include "./ProsurvPSG_helpers.zs"

// Actual Weapon
class PBX_SPAS12 : PBX_WeaponBase
{
	Default
	{
		Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.5;
		Weapon.BobStyle "InverseSmooth";
		Weapon.BobSpeed 2.4;
		Weapon.SelectionOrder 1250;
		Weapon.AmmoType1 "PB_Shell";
		weapon.ammogive1 10;
		Weapon.AmmoType2 "PBX_SPAS12Mag";
		Inventory.PickupMessage "$PBX_SPAS12_PICKUP";
		Inventory.PickupSound "weapons/spas12/raise";
		Inventory.Icon "M4SHA0";
		Inventory.AltHUDIcon "M4SHA0";
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority 2.4;
		Obituary "$OB_WEAP_SPAS12";
		Scale 0.40;
		Tag "$PBX_SPAS12_TAG";
        +FLOORCLIP;
		+DONTGIB;
		+WEAPON.NOAUTOAIM;
		+WEAPON.NOAUTOFIRE;
		+WEAPON.NOALERT;
	}

    bool dualfiremode;
    const MAGAZINE_SIZE = 9;

    action void SPAS_Fire(int tic)
    {
        switch(tic)
        {
            case 1:
            
                A_AlertMonsters();
                PB_FireBullets("PB_12GAPellet", 12, 1.5, 0, 0, 1.5);
				A_FireProjectile("ShotgunWad", random(-2,2), 0, random(-2,2), -3, FPF_NOAUTOAIM, random(-2,2));

                A_Recoil(3);
                A_SetPitch(pitch - 4.0);
				PB_FireOffset();

				PB_LowAmmoSoundWarning("shotgun");
				PB_TakeAmmo(invoker.ammo2.getClassName(),1,0);

                A_StartSound("DRBTFIRE", CHAN_WEAPON, pitch:frandom(0.95, 1.05));
				PB_IncrementHeat();
				A_FireCustomMissile("YellowFlareSpawn", 0, 0, 0, 0);
				_SpawnMuzzleSparksSG(0, 0, -4);
				PB_MuzzleFlashEffects(0, 0, -4);
				PB_DynamicTail("shotgun", "shotgun");
				A_SetInventory("CantDoAction", 1);
				PB_SetChamberEmpty(true);
				A_GunFlash();
                break;

            case 2:
                Radius_Quake(3, 3, 0, 1, 0); 
                A_SetPitch(pitch + 1.0); 
                A_ZoomFactor(0.94); 
                break;

            case 3: case 4:
                A_SetPitch(pitch + (tic == 4 ? 1.0 : 2.0)); 
                A_ZoomFactor(tic == 4 ? 1.0 : 0.96);
                break;

            case 5:
				PB_SpawnCasing("ShotgunCasing",15,-5,26,0,3,3);
				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
                A_ZoomFactor(PB_GetZoom() ? 1.48 : 1.0);
                break;

        }
    }

    action state SPAS_HandleAlt()
    {
        PB_SetRoll(0);
        PB_HandleCrosshair(46);

        if(invoker.dualfiremode)
            return ResolveState("HL2Fire");

        A_StartSound("IronSights", 0);
        if(PB_GetZoom())
            return ResolveState("Zoomout");
            
        return ResolveState(null);
    }

	States
	{
        Spawn:
            M4SH A -1;
            Stop;

        WeaponRespect:
            TNT1 A 0 {
				A_SetCrosshair(-1);
                A_PlaySound("weapons/spas12/raise", CHAN_AUTO);
            }
            S12S EDCBA 1;
            Goto Ready3;

        Deselect:
            TNT1 A 0 {
                A_WeaponOffset(0, 32);
                PB_SetRoll(0);
                PB_SetZoom(false);
            }
            S12S ABCDE 1;
            TNT1 AAAAAAAAAAAAAAAAAA 0 A_Lower();
            TNT1 A 1 A_Lower();
            Wait;

        Select:
            TNT1 A 0 {
                A_WeaponOffset(0, 32);
                PB_SetRoll(0);
                PB_SetZoom(false);
                PBX_WeaponRaise("weapons/spas12/raise");
			    return PB_RespectIfNeeded();
            }
        SelectAnimation:
            S12S EDCBA 1;
        Ready3:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Ready2");
            TNT1 A 0 {
                PB_SetRoll(0);
                A_ZoomFactor(1.0);
                PB_HandleCrosshair(46);
				A_SetInventory("CantWeaponSpecial",0);
				A_SetInventory("CantDoAction",0);
            }
        ReadyToFire:
            S12G A 1 {
				PB_CoolDownBarrel(0,0,-4);
                return PB_ReadyFire();
            }
            Loop;

        Ready2:
            TNT1 A 0 {
				A_ZoomFactor(1.5);
                A_SetCrosshair(-1);
				A_SetInventory("CantDoAction",0);
            }
        ReadytoFire2:
            S12Z A 1 {
				PB_CoolDownBarrel(0,-2,6);
                return PB_ReadyFire(ads:true);
            }
            Loop;

        WeaponSpecial:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Zoomout");
            TNT1 A 0 {
				A_Takeinventory("GoWeaponSpecialAbility",1);
			}
            TNT1 A 0 {
                invoker.dualfiremode = !invoker.dualfiremode;
                A_StartSound("MS/Button", CHAN_AUTO, CHANF_OVERLAP);
                A_Print(invoker.dualfiremode ? "$PBX_SPAS12_DUALFIRE" : "$PBX_SPAS12_ADS");
            }
            Goto Ready3;


        AltFire:
			TNT1 A 0 SPAS_HandleAlt();
        ZoomIn:
            S12X ABCDEF 1;
            TNT1 A 0 {
                A_ZoomFactor(1.5);
                PB_SetZoom(true);
                A_SetCrosshair(-1);
			}
            Goto Ready2;

        Zoomout:
            TNT1 A 0 {	
				PB_HandleCrosshair(46);
				A_ZoomFactor(1.0);
                PB_SetZoom(false);
            }
            S12X FEDCBA 1;
            TNT1 A 0 A_JumpIfInventory("GoWeaponSpecialAbility",1,"WeaponSpecial");
            Goto Ready3;

        HL2Fire:
			TNT1 A 0 PB_jumpIfNoAmmo(min:2);
            S12G B 1 Bright {
                SPAS_Fire(1);
                PB_WeaponRecoil(-1.50, frandom[sfx](-1.0,1.0));
                PB_FireBullets("PB_DragonsBreathTracer", 9, 1.5, 0, 0, 1.5);
				A_FireProjectile("ShotgunWad", random(-2,2), 0, random(-2,2), -3, FPF_NOAUTOAIM, random(-2,2));
				PB_TakeAmmo(invoker.ammo2.getClassName(),1,0);
                A_StartSound("weapons/sg", CHAN_WEAPON, CHANF_OVERLAP, 1.0, pitch: 1.2);
            }
            S12G C 1 SPAS_Fire(2);
            S12G D 1 SPAS_Fire(3);
            S12G E 1 SPAS_Fire(4);
        PumpSlow:
            S12P ABCDEFGH 1;
            TNT1 A 0 A_PlaySound("weapons/spas12/pumpback", CHAN_AUTO); 
            S12P IJKLM 1;
            S12P N 1 A_ZoomFactor(0.98);
            S12P O 16 {
                SPAS_Fire(5);
				PB_SpawnCasing("ShotgunCasing",15,-5,26,0,3,3);
            }
            TNT1 A 0 A_PlaySound("weapons/spas12/pumpforward", CHAN_AUTO); 
            S12P NMLKJI 1;
            S12P HGFEDCBA 1;
            Goto Ready3;

        Fire:
            TNT1 A 0 {
                A_WeaponOffset(0, 32);
                A_SetRoll(0);
            }
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Fire2");
		Fire1Actual:
			TNT1 A 0 		PB_jumpIfNoAmmo();
            S12G B 1 Bright SPAS_Fire(1);
            S12G C 1        SPAS_Fire(2);
            S12G D 1        SPAS_Fire(3);
            S12G E 1        SPAS_Fire(4);
        Pump:
            S12P ABCDEFGH 1;
		PumpBegin:
            S12P IJKLM 1 PB_SetReloading(true); 
            S12P N 1 A_ZoomFactor(0.98);
            TNT1 A 0 A_PlaySound("weapons/spas12/pump", CHAN_AUTO);
            S12P O 1        SPAS_Fire(5);
            S12P NMLKJI 1;
		PumpEnd:
            S12P HGFEDCBA 1;
            TNT1 A 0 {
				A_SetInventory("CantDoAction",0);
				PB_SetReloading(false);
				PB_Refire();
			}
            Goto Ready3;

        Fire2:
            TNT1 A 0 {
				PB_SetRoll(0);
				A_SetCrosshair(-1);
			}
		Fire2Actual:
			TNT1 A 0 		PB_jumpIfNoAmmo();
            S12Z B 1 Bright SPAS_Fire(1);
            S12Z CDEF 1;
		Pump2:
            S1PZ ABCDEF 1;
            S1PZ G 2;
            TNT1 A 0 A_PlaySound("weapons/spas12/pump", CHAN_AUTO);
            S1PZ H 1        SPAS_Fire(5);
            S1PZ HHHHGFEDCBA 1 {
				if(JustPressed(BT_ATTACK) && invoker.ammo2.amount > 0) return ResolveState("Fire2");
                return ResolveState(null);
			}
            TNT1 A 0 {
                A_ZoomFactor(1.5);
				A_SetInventory("CantDoAction",0);
				return PB_ReadyFire(ads:true);
			}
            Goto Ready2;

        ReloadFromADS:
            TNT1 A 0 {	
				PB_HandleCrosshair(46);
                PB_SetZoom(false);
            }
            S12X FEDCBA 1;
        Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
            TNT1 A 0 {
                A_ZoomFactor(1.0);
			}
            TNT1 A 0 PB_CheckReload(null,null,"Pump","Ready3","Ready3",MAGAZINE_SIZE);
			TNT1 A 0 A_PlaySoundEx("Ironsights", "Auto");
            // Raise Weapon
            S12P ABCDEFGH 1;
            S12R AB 1;
        ShellChecker:
            // Main reload loop
			TNT1 A 0 A_JumpIf(invoker.ammo1.amount < 1 || invoker.ammo2.amount >= MAGAZINE_SIZE,"FinishReload");
            TNT1 A 0 A_PlaySound("weapons/spas12/insert", CHAN_AUTO);
            S12R CD 2 A_DoPBWeaponAction(WRF_NOBOB);
            S12R E 2 {
				A_Giveinventory(invoker.ammo2.getClassName(),1);
				A_Takeinventory(invoker.ammo1.getClassName(),1,TIF_NOTAKEINFINITE);
				PB_RotateCamera(addAngle:0.2,addPitch:-0.2,addRoll:-0.4);
                return A_DoPBWeaponAction(WRF_NOBOB);
            }
            S12R FGH 1 A_DoPBWeaponAction(WRF_NOBOB);
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(), "PumpReload");
            S12R A 1 A_DoPBWeaponAction(WRF_NOBOB);
			Loop;

        PumpReload:
            S12P IJKLM 1 A_DoPBWeaponAction(WRF_NOBOB);
            S12P N 1 A_ZoomFactor(0.98);
            S12P O 1 {
                A_PlaySound("weapons/spas12/pump", CHAN_AUTO);
                A_ZoomFactor(1.0);
                PB_SetChamberEmpty(false);
				PB_SetMagEmpty(false);
				return A_DoPBWeaponAction(WRF_NOBOB|WRF_NOFIRE);
            }
            S12P NMLKJI 1 A_DoPBWeaponAction(WRF_NOBOB);
            goto ShellChecker;

        FinishReload:
            TNT1 A 0 {
				A_PlaysoundEx("Ironsights", "Auto");
			}
            S12P HGFEDCBA 1;
			TNT1 A 0 PB_SetReloading(false);
            Goto Ready3;

        Unload:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				A_PlaysoundEx("Ironsights", "Auto");
			}
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty(),"Ready3");
			S12P ABCDEFGH 1 A_DoPBWeaponAction();
		RemoveBullets:
            TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"FinishUnload");
			TNT1 A 0 {
				A_Takeinventory(invoker.ammo2.getclassname(),1);
				A_Giveinventory(invoker.ammo1.getclassname(),1);
                A_PlaySound("weapons/spas12/pump", CHAN_AUTO);
			}
			S12P IJKLLL 1 A_DoPBWeaponAction();
			S12P MNO 1 A_DoPBWeaponAction();
			loop;

		FinishUnload:
            S12P ONMKJIH 1 A_DoPBWeaponAction();
			S12P GFEDCBA 1 A_DoPBWeaponAction();
			TNT1 A 0 {
                PB_SetMagEmpty(true);
                PB_SetChamberEmpty(true);
				PB_SetReloading(false);
            }
			Goto Ready3;

        FlashKicking:
            S12P ABCDEFGHGFEDCBA 1;
            Goto Ready3;

        FlashAirKicking:
            S12P ABCDEFGHHGFEDCBA 1;
            Goto Ready3;

        FlashPunching:
            S12P ABCDEFG 1;
            S12P GFEDCBA 1;
            Goto Ready3;

        FlashSlideKicking:
            S12P ABCDEFG 1;
            S12P H 12;
            S12P GFEDCBA 1;
            Goto Ready3;

        FlashSlideKickingStop:
            S12P GFEDCBA 1;
            Goto Ready3;

	}
}