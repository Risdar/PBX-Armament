extend class PBX_NormalRifle
{
    mixin PBX_LaserSight;

    // Dont spawn the laser sight if the weapon is in one of these states
    static const StateLabel blockedLaserStates[] = {
        "Deselect", "NormalDeselect", "DualWieldDeselect", "FinishDeselect",

        "SelectAnimationDualWield", "SelectAnimation", "ReloadFromADS",

        "SwitchToDualWield", "StopDualWield", "WeaponInspect",

        "RaiseFromEmpty","Reload","ContinueReload","FinishReload","Rechamber",

        "ReloadUnloadRight","ReloadUnloadLeft","ReloadDualWield","ContinueReloadRight",
        "ReloadLeft","ContinueReloadLeft","ReloadFromADS","StartRechamberRight",
        "RechamberRight","CheckLeftRel","StartRechamberLeft","RechamberLeft",

        "Unload","UnloadChamber","UnloadDualWield","UnloadLeft",

        "FlashKickingAkimbo","FlashAirKickingAkimbo","FlashSlideKickingAkimbo","FlashSlideKickingStopAkimbo",

        "WeaponRespect", "SwitchAnimation",
        "FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
    };

    override void PBX_DoEffectWeaponReady()
    {
		PBX_SpawnLaserSight(RED_DOT);
    }

    action void setBurstCount(int set, bool isLeft = false)
    {
        if(!isLeft) invoker.burstcount  = set;
        else        invoker.burstcountLeft = set;
    }

    action int getBurstCount(bool isLeft = false)
    {
        if(!isLeft) return invoker.burstcount;
        else        return invoker.burstcountLeft;
    }

    action bool getBurst()
    {
        return invoker.doBurst;
    }

    action void setBurst(bool set)
    {
        invoker.doBurst = set;
    }
 
    action void NormalRifle_FireOverlay(int tic, bool isLeft = false)
    {
        bool burst          = getBurst();
        int heat            = burst ? 3 : 1;
        double recoilX      = burst ? frandom[sfx](-0.6,0.6)  : frandom[sfx](-0.24,0.24);
        double recoilY      = isLeft ? (burst ? +0.8 : +0.6) : (burst ? -0.8 : -0.6);
        double smokeOfs     = isLeft ?  6  : -6;
        double vertOfs      = isLeft ? -16 :  9;
        string ammoClass    = isLeft ? invoker.ammoleft.getClassName() : invoker.ammo2.getClassName();

        switch(tic)
        {
            case 1:
                // Shoot + Effects
                PB_IncrementHeat(heat, isLeft);
                PB_FireBullets("PB_556x45mm", 1, 0.1, 0, 0, 0.1);
                PB_SpawnCasing("PB_EmptyBrass", 26, vertOfs, 38, frandom(-2,2), -frandom(2,5), frandom(3,6), true, true);
                A_StartSound("weapons/rifle", CHAN_Weapon, CHANF_DEFAULT, 1.0);
			    PB_DynamicTail("lmg", "br");
                A_ZoomFactor(0.98);
                PB_WeaponRecoil(recoilX, recoilY);

                // Everything Else
                if(isLeft) {
                    PB_LowAmmoSoundWarning(ammoClass);
                    PB_TakeAmmo(ammoClass,dual:true);
                    A_SetFiringLeftWeapon(true);
                    A_FlashOverlay(LEFT_MUZZLE_LAYER,"LeftMuzzleFlash");
                    A_OverlayOffset(LEFT_MUZZLE_LAYER,-10,20);
                    invoker.burstcountLeft++;
                }
                else {
                    PB_LowAmmoSoundWarning();
                    PB_TakeAmmo(ammoClass);
                    A_SetFiringRightWeapon(true);
                    A_FlashOverlay(RIGHT_MUZZLE_LAYER,"RightMuzzleFlash");
                    A_OverlayOffset(RIGHT_MUZZLE_LAYER,10,20);
                    invoker.burstcount++;
                }
                A_AlertMonsters();
                PB_GunSmoke(smokeOfs, 0, 1.6);
                PB_MuzzleFlashEffects(smokeOfs, 0, 1.6);
                break;

            case 2:
                if(isLeft)
                {
                    A_SetFiringLeftWeapon(false);
                }
                else
                {
                    A_SetFiringRightWeapon(false);
                }
                break;

             case 3: 
                A_ZoomFactor(1.0);
                PB_WeaponRecoil(recoilX, recoilY);
                break;

            case 4:
                // Reset burst
                setBurstCount(0, isLeft ? true : false);
                break;
        }
    }

    action void fireweapon(int tic)
    {
        bool ads     = PB_GetZoom();
        double zoomA = ads ? 1.24 : 0.98;
        double zoomB = ads ? 1.25 : 1.0;

        switch(tic)
        {
            case 1:
                A_StartSound("weapons/rifle", CHAN_Weapon, CHANF_DEFAULT, 1.0);
                A_AlertMonsters();
                PB_IncrementHeat();
			    PB_DynamicTail("lmg", "br");
				PB_LowAmmoSoundWarning();
                PB_TakeAmmo(invoker.ammo2.getclassname());
				PB_GunSmoke(0,0,0); PB_MuzzleFlashEffects(0,0,0);
                A_FireCustomMissile("YellowFlareSpawn",0,0,0,0);
                A_GunFlash();
                PB_WeaponRecoil(-0.5,0);
                PB_FireOffset();
                if(ads) {
                    PB_SpawnCasing("PB_EmptyBrass",28,0,30,3,Frandom(5,8),Frandom(3,4));
                    PB_FireBullets("PB_556x45mm",1, 0.1, 0, 0, 0.1);
                }
                else {
				    PB_SpawnCasing("PB_EmptyBrass",22,2,28,Frandom(-2, -1),Frandom(5,8),Frandom(3,4));
                    PB_FireBullets("PB_556x45mm",1, 1, 0, 0, 1);
                }
                A_ZoomFactor(zoomA);
                break;

            case 2:
                PB_WeaponRecoil(-1.0,0);
                A_ZoomFactor(zoomB);
                invoker.burstCount++;
                break;

            // Everything below here is not called by ADS
            case 3:
                PB_WeaponRecoil(-0.5,0);
                break;
        }
    }

    action state checkSpecial()
	{
        A_Takeinventory("GoWeaponSpecialAbility",1);
        PB_ClearDualWield();

		bool toggleFireMode     = countinv("NR_Select_FireMode")    > 0;
		bool toggleDualWield  	= countinv("NR_Select_DualWield")   > 0;
		bool toggleLaser 	    = countinv("PBX_Toggle_Laser")       > 0;

        if(countinv("PBX_CloseWheel") > 0)
		{
            cleanmodetokens();
			return PBX_ReturnReady();
		}

		if(toggleFireMode)
		{
            invoker.doBurst = !invoker.doBurst;
            A_Print(invoker.doBurst ? "$PB_FIREMODE_BURST" : "$PB_FIREMODE_FULL");
		}

		if (toggleLaser) 
        {
            PBX_ToggleLaserSight(skipPlaySound:true);
        }

        if (toggleDualWield)
        {
            cleanmodetokens();
            return PBX_SetupDualWield("$PBX_NormalRifle_NoAkimbo");
        } 

		// Always remove the tokens regardless
		cleanmodetokens();

		// Play sound when opening the wheel in ADS
		if(PB_GetZoom())
		{
			A_StartSound("MS/Button", 26);
			return resolvestate("Ready2");
		}

		// Fallthrough to Switch Animation
		return resolvestate(null);
	}

    action void cleanmodetokens()
    {
        A_SetInventory("NR_Select_FireMode",0);
        A_SetInventory("NR_Select_DualWield",0);
        A_SetInventory("PBX_Toggle_Laser",0);
        A_SetInventory("PBX_CloseWheel",0);
    }
}