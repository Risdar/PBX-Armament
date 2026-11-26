// Excavator Upgrade 
// From Project Survival made by ThePopeOfDope
// New Original Sprites made by ThePopeOfDope

extend class PBX_Excavator
{
    States
    {
        CacheSprites:
            EX_A A 0; EX_B A 0; EX_C A 0; EX_D A 0; EX_E A 0; 
            EX_F A 0; EX_G A 0; EX_H A 0; EX_I A 0;

		WeaponRespect.UpgradedStart:
		    5DKF EFGHI 1 A_DoPBWeaponAction();
        WeaponRespect.Upgraded:
			TNT1 A 0 A_PlaySound("RLANDRAW");
			TNT1 A 5 A_DoPBWeaponAction();
		RespectBola:
			TNT1 A 0 A_JumpIf(getExcavatorMode() == eSawMode,"RespectSaw");
			EX_L QRSTUVW 1 {
				PB_SetRoll(roll-0.6);
				return A_DoPBWeaponAction();
			}
			EX_G NNN 1 A_DoPBWeaponAction();
			EX_I HHHHGFE 1 {
				PB_SetRoll(roll+0.6);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_PlaySound("RLCYCLE2", 13);
			EX_I DDDDDCBA 1 A_DoPBWeaponAction();
			EX_E NNN 1 A_DoPBWeaponAction ();
			TNT1 A 0 A_PlaySound("weapons/minigun/respect1", 13);
			EX_E OPQRST 1 {
				PB_SetRoll(roll-0.6);
				return A_DoPBWeaponAction();
			}
			EX_E UVWX 1 A_DoPBWeaponAction();
			EX_E YZ 1 {
				PB_SetRoll(roll+0.6);
				return A_DoPBWeaponAction();
			}
			EX_F ABCC 1 {
				PB_SetRoll(roll+0.6);
				return A_DoPBWeaponAction();
			}
			EX_F CCC 1 A_DoPBWeaponAction();
			TNT1 A 0 A_PlaySound("excavator_magslap", 13);
			EX_F EFGHIJ 1 {
				PB_SetRoll(roll+0.6);
				return A_DoPBWeaponAction();
			}
			EX_F JIHGFL 1 {
				PB_SetRoll(roll-0.6);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_PlaySound("weapons/nailgun/up", 10);
			EX_F MNO 1 A_DoPBWeaponAction();
			TNT1 A 0 A_PlaySound("excavator/detonate");
			EX_A EEEEE 1 A_DoPBWeaponAction();
			goto Ready2;
			
		RespectSaw:
			EX_K QRSTUVW 1 {
				PB_SetRoll(roll-0.6);
				return A_DoPBWeaponAction();
			}
			EX_E NNN 1 A_DoPBWeaponAction();
			EX_I ABCDDDD 1 {
				PB_SetRoll(roll+0.6);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_PlaySound("RLCYCLE2", 13);
			EX_I EFGHHHHH 1 A_DoPBWeaponAction();
			EX_G NNN 1 A_DoPBWeaponAction();
			TNT1 A 0 A_PlaySound("weapons/minigun/respect1", 13);
			EX_G OPQRST 1 {
				PB_SetRoll(roll-0.6);
				return A_DoPBWeaponAction();
			}
			EX_G UVWX 1 A_DoPBWeaponAction();
			EX_G YZ 1 {
				PB_SetRoll(roll+0.6);
				return A_DoPBWeaponAction();
			}
			EX_H ABCC 1 {
				PB_SetRoll(roll+0.6);
				return A_DoPBWeaponAction();
			}
			EX_H CCC 1 A_DoPBWeaponAction();
			TNT1 A 0 A_PlaySound("excavator_magslap", 13);
			EX_H EFGHIJ 1 {
				PB_SetRoll(roll+0.6);
				return A_DoPBWeaponAction();
			}
			EX_H JIHGFL 1 {
				PB_SetRoll(roll-0.6);
				return A_DoPBWeaponAction();
			}
			TNT1 A 0 A_PlaySound("weapons/nailgun/up", 10);
			EX_H MNO 1 A_DoPBWeaponAction();
			TNT1 A 0 A_PlaySound("excavator/detonate");
			EX_C EEEEE 1 A_DoPBWeaponAction();
			goto Ready2;
			
        Deselect.Upgraded:
            EX_A EDCBA 1 checkUnloadedSprites("EX_B","EX_D","EX_A","EX_C");
			goto ActualDeselect;

        Select.Upgraded:
			TNT1 A 0 PBX_WeaponRaise("RLANDRAW");
			TNT1 A 0 PB_RespectIfNeeded();
        SelectAnimation.Upgraded:
            EX_A ABCDE 1 checkUnloadedSprites("EX_B","EX_D","EX_A","EX_C");
        // Fall through to Ready2
        Ready2:
            EX_A E 1 {
				checkUnloadedSprites("EX_B","EX_D","EX_A","EX_C");
                PB_CoolDownBarrel();
                EX_HandleCrosshair();
                return A_DoPBWeaponAction();
            }
            Loop;

        Fire.Upgraded:
			TNT1 A 0 PB_JumpIfNoAmmo("Reload.Upgraded",1,false);
			EX_A JK 1 BRIGHT changeModeSprite("EX_A","EX_C");
			"####" A 0 FireWeapon();
            "####" L 1 BRIGHT A_ZoomFactor(0.97);
			"####" M 1 BRIGHT A_ZoomFactor(0.98);
			"####" N 1 A_ZoomFactor(0.99);
			"####" OPQR 1 {
				A_ZoomFactor(1.0);
				return A_DoPBWeaponAction(WRF_NOPRIMARY);
			}
			"####" A 0 A_PlaySound("RLCYCLE2", 5);
			"####" EEEEEEEEEE 1 A_DoPBWeaponAction(WRF_NOPRIMARY|WRF_NOSECONDARY);
			goto Ready2;

        Altfire:
            TNT1 A 0 checkAltfire();
            TNT1 A 0 A_JumpIf(getExcavatorMode() == eSawMode, "AltFire.UpgradedSaw");
            TNT1 A 0 {invoker.burstcount = 0;}
        AltFire.UpgradedBola:
			TNT1 A 0 PB_JumpIfNoAmmo("Reload.Upgraded",1,false);
			EX_A JK 1 BRIGHT ;
			TNT1 A 0 {
                FireWeapon(true);
                invoker.burstcount++;
            }
			EX_A L 1 BRIGHT A_ZoomFactor(0.97);
			EX_A M 1 BRIGHT A_ZoomFactor(0.98);
            TNT1 A 0 A_JumpIf(invoker.burstcount < 6, "AltFire.UpgradedBola");
		FinishBurst:
			EX_A N 1 A_ZoomFactor(0.99);
			TNT1 A 0 A_ZoomFactor(1.0);
			EX_A OPQR 1 A_WeaponReady(WRF_NOPRIMARY);
			TNT1 A 0 A_PlaySound("RLCYCLE2", 5);
			EX_A EEEEEEEEEE 1 A_WeaponReady(WRF_NOPRIMARY|WRF_NOSECONDARY);
			goto Ready2;

        AltFire.UpgradedSaw:
			TNT1 A 0 PB_JumpIfNoAmmo("Reload.Upgraded",1,false);
			TNT1 A 0 A_PlaySound ("excavator_sawcharge");
			EX_C STU 3;
			TNT1 A 0 A_Startsound("excavator_sawcharge_loop",2,CHANF_LOOP);
		SawBladeCharged:
			EX_C U 1;
			TNT1 A 0 A_Jumpif(PressingAltFire(),"SawBladeCharged");
		FireSawBladeCharged:
			TNT1 A 0 A_Stopsound(2);
			EX_C K 1 BRIGHT;
            TNT1 A 0 FireWeapon(true);
			EX_C L 1 BRIGHT A_ZoomFactor(0.97);
			EX_C M 1 A_ZoomFactor(0.98);
			EX_C N 1 A_ZoomFactor(0.99);
			TNT1 A 0 A_ZoomFactor(1.0);
			EX_C OPQR 1 A_WeaponReady(WRF_NOPRIMARY);
			TNT1 A 0 A_PlaySound("RLCYCLE2", 5);
			EX_C EEEEEEEEEE 1 A_WeaponReady(WRF_NOPRIMARY);
			Goto Ready2;

        RaiseFromEmpty.Upgraded:
            EX_K CBA 1 changeModeSprite("EX_K","EX_L");
            goto ContinueReload.Upgraded;

        Reload.Upgraded:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			}
            TNT1 A 0 A_JumpIf(invoker.ammo1.amount < invoker.ReserveToMagAmmoFactor, "Ready2");
            TNT1 A 0 PB_CheckReload(
				"RaiseFromEmpty.Upgraded", 
				null, 
				null, 
				"Ready2", 
				"Ready2", 
				MAGAZINE_SIZE, 
				invoker.ReserveToMagAmmoFactor
			);
			TNT1 A 0 A_PlaySound("Ironsights", 15);
			EX_E ABCD 1 {
                changeModeSprite("EX_E","EX_G");
                PB_SetRoll(roll-0.6);
            }
			"####" EEE 1;
			"####" FGHI 1 PB_SetRoll(roll+1.2);
			"####" A 0 A_PlaySound("weapons/sgl/cycle", 14);
			"####" JKL 1 PB_SetRoll(roll-0.6);
			"####" M 1 {
                PB_SpawnCasing("SGL_Drum",25,0,20,Frandom(3,4),Frandom(3,4),1);
				PB_SetMagUnloaded(true);
                PB_SetChamberEmpty(true);
                PB_SetMagEmpty(true);
			}
        ContinueReload.Upgraded:
			EX_E NNNNN 1 changeModeSprite("EX_E","EX_G");
			"####" A 0 A_PlaySound("weapons/minigun/respect1", 13);
			"####" OPQRST 1 PB_SetRoll(roll-0.6);
			"####" UVW 1;
            "####" X 1 {
                PB_AmmoIntoMag(
					invoker.ammo2.getclassname(), 
					invoker.ammo1.getclassname(), 
					MAGAZINE_SIZE, 
					invoker.ReserveToMagAmmoFactor
				);
                PB_SetMagUnloaded(false);
                PB_SetChamberEmpty(false);
                PB_SetMagEmpty(false);
            }
			"####" YZ 1 PB_SetRoll(roll+0.6);
			EX_F ABCC 1 {
				changeModeSprite("EX_F","EX_H");
				PB_SetRoll(roll+0.6);
			}
			"####" CCC 1;
			"####" A 0 A_PlaySound("excavator_magslap", 13);
			"####" EFG 1 PB_SetRoll(roll+0.6);
        FinishReload.Upgraded:
            EX_F HIJ 1 {
                changeModeSprite("EX_F","EX_H");
                PB_SetRoll(roll+0.6);
            }
			"####" JIHGFL 1 PB_SetRoll(roll-0.6);
			"####" A 0 A_PlaySound("weapons/nailgun/up", 10);
			"####" MNO 1;
			"####" A 0 A_PlaySound("excavator/detonate");
			EX_A EEEEE 1 changeModeSprite("EX_A","EX_C");
            TNT1 A 0 PB_SetReloading(false);
			Goto Ready2;

        Unload.Upgraded:
			TNT1 A 0 handleModeChange();
			TNT1 A 0 A_JumpIf(PB_GetMagUnloaded(),"Ready2");
			TNT1 A 0 A_PlaySound("Ironsights", 15);
            EX_E ABCD 1 {
                changeModeSprite("EX_E","EX_G");
                PB_SetRoll(roll-0.6);
            }
			"####" EEE 1;
			"####" FGHI 1 PB_SetRoll(roll+1.2);
			"####" A 0 A_PlaySound("weapons/sgl/cycle", 14);
			"####" JKLM 1 PB_SetRoll(roll-0.6);
            "####" A 0 {
				PB_UnloadMag(
					invoker.ammo2.getclassname(),
					invoker.ammo1.getclassname(), 
					invoker.ReserveToMagAmmoFactor, 
					1, 0, 0);
				PB_SetMagUnloaded(true);
				PB_SetMagEmpty(true);
                PB_SetChamberEmpty(true);
			}
            "####" NNN 1 handleModeChange();
            "####" NN 1;
			EX_K ABC 1 changeModeSprite("EX_K","EX_L");
			goto Ready2;

        SwitchToSaw:
            EX_I ABCDDDDD 1 ;
			TNT1 A 0 {
				A_PlaySound("RLCYCLE2", 13);
				actualModeChange();
			}
			EX_I EFGHHHHH 1;
			goto ContinueReload.Upgraded;

        SwitchToBola:
            EX_I HHHHHGFE 1 ;
			TNT1 A 0 {
				A_PlaySound("RLCYCLE2", 13);
				actualModeChange();
			}
			EX_I DDDDDCBA 1;
			goto ContinueReload.Upgraded;

		SwitchAnimation.Upgraded:
			EX_A FGHI 1 checkUnloadedSprites("EX_B","EX_D","EX_A","EX_C");
			"####" A 0 A_PlaySound("excavator/switch");
			"####" I 10;
			"####" IHGF 1;
            goto Ready2;

        FlashPunching.Upgraded:
            EX_A FGHI 1 checkUnloadedSprites("EX_B","EX_D","EX_A","EX_C");
			"####" I 6;
			"####" IHGF 1;
            goto Ready2;

        FlashKicking.Upgraded:
            EX_A FGHI 1 checkUnloadedSprites("EX_B","EX_D","EX_A","EX_C");
			"####" I 6;
			"####" IHGF 1;
            goto Ready2;

        FlashAirKicking.Upgraded:
            EX_A FGHI 1 checkUnloadedSprites("EX_B","EX_D","EX_A","EX_C");
			"####" I 8;
			"####" IHGF 1;
            goto Ready2;

        FlashSlideKicking.Upgraded:
            EX_A FGHI 1 checkUnloadedSprites("EX_B","EX_D","EX_A","EX_C");
			"####" I 21;
            goto Ready2;

        FlashSlideKickingStop.Upgraded:
            EX_A IIIIHGF 1 checkUnloadedSprites("EX_B","EX_D","EX_A","EX_C");
            goto Ready2;

    }
}