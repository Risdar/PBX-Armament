extend class PBX_Prosurv_LeverAction
{
	mixin PBX_LaserSight;
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////  
	override void postbeginplay()
	{
		LAMode = LA_357Magnum;
		currentMaxAmmo = MAGAZINE_SIZE;
		super.postbeginplay();
	}

	static const StateLabel blockedLaserStates[] = {
		"Pump", "PumpBegin", "PumpEnd", "Reload","FinishUnload", "Deselect", "SelectAnimation", "ReloadFromADS",
		"ReloadLoop", "ReloadFinished","Unload","RemoveBullets", "WeaponRespect", "WeaponSwitch", "WeaponInspect","Inspect2",
		"FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
	};

	override void PBX_DoEffectWeaponReady()
    {
		PBX_SpawnLaserSight(RED_DOT);
    }

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////

	action void setLAMode(int mode = LA_444Marlin)
	{
		invoker.LAMode = mode;
	}

	action int getLAMode()
	{
		return invoker.LAMode;
	}

	action void clearLAModeTokens()
	{
		A_SetInventory("LA_Select_No", 0);
		A_SetInventory("LA_Select_Marlin", 0);
		A_SetInventory("LA_Select_Magnum", 0);
		A_SetInventory("PBX_Toggle_Laser" ,0);
		A_SetInventory("PBX_CloseWheel", 0);
	}
	
	action void LA_FireWeapon(int ticCount)
	{
		bool ads = PB_GetZoom();
		bool mode = getLAMode();
		double zoomA = ads ? 1.23 : 0.98;
		double zoomB = ads ? 1.24 : 0.99;
		double recoilX = ads ? frandom[sfx](-1.75,1.75) : frandom[sfx](-1.83,1.83);
		double recoilY = ads ? +0.50 : +0.75;
		string projectile = mode == LA_444Marlin ? "PB_444Marlin" : "PB_357Magnum";
		string sound = mode == LA_444Marlin ? "weapons/leveraction/magfire" : "weapons/leveraction/fire";

		switch (ticCount)
		{
			//Tic 1
			default:
			case 1:
				A_AlertMonsters();
				// Firing
				A_StartSound(sound, CHAN_WEAPON, CHANF_OVERLAP, 1.0);
				PB_FireBullets(projectile,1, 0, 0, 0, 0);
				if(mode == LA_357Magnum) {
					PB_DynamicTail("sniper", "sniper");
					PB_LowAmmoSoundWarning("revolver");
				}
				else {
					PB_DynamicTail("pistol", "pistol");
					PB_LowAmmoSoundWarning();
				}
				// Effects
				PB_GunSmoke(0,0,0);
				A_FireCustomMissile("YellowFlareSpawn",0,0,0,0);
				PB_IncrementHeat(4);
				A_GunFlash();
				A_ZoomFactor(zoomA);
				PB_WeaponRecoil(recoilX, recoilY);
				pb_takeammo(invoker.ammotype2,1,0);
				PB_SpawnCasing("EmptyBrassPistol");
				A_SetInventory("CantDoAction", 1);
				PB_SetReloading(true);
				PB_SetChamberEmpty(true);
				break;
			//Tic 2
			case 2:
				A_ZoomFactor(zoomB);
				PB_WeaponRecoil(recoilX, recoilY);
				break;
			//Tic 3
			case 3:
				A_ZoomFactor(1.0);
				// A_FireCustomMissile("EmptyBrassPistol",0,0,4,-8);
				break;
		}
	}
	
	action void LA_SetAmmo(int mode = LA_357Magnum)
	{
		switch(mode)
		{
			case LA_444Marlin:
				A_SetInventory(invoker.ammotype2,invoker.ammo2.amount/2);
				SetAmmoCapacity(invoker.ammotype2,MAGAZINE_SIZE/2);
				invoker.ammo2.backpackmaxamount = MAGAZINE_SIZE/2;
				break;
			case LA_357Magnum:
				SetAmmoCapacity(invoker.ammotype2,MAGAZINE_SIZE);
				A_SetInventory(invoker.ammotype2,invoker.ammo2.amount*2);
				invoker.ammo2.backpackmaxamount = MAGAZINE_SIZE;
				break;
		}
		PB_SetChamberEmpty(true);
		PB_SetMagEmpty(true);
	}

	action state PB_PreHandleLAWheel()
	{
		bool noUpgrade 	 = findinventory("LA_Select_No");
		bool goMarlin 	 = findinventory("LA_Select_Marlin");
		bool goMagnum 	 = findinventory("LA_Select_Magnum");
		bool toggleLaser = findinventory("PBX_Toggle_Laser");

		A_WeaponOffset(0,32);
		A_SetInventory("CantWeaponSpecial",0);
		A_SetInventory("GoWeaponSpecialAbility",0);

		if(noUpgrade)
		{
			clearLAModeTokens();
			A_Print("$PBX_AmmoNotAvailable");
			return PBX_ReturnReady();
		}
		
		if(goMarlin && getLAMode() == LA_444Marlin || goMagnum && getLAMode() == LA_357Magnum)
		{
			clearLAModeTokens();
			A_Print("$PB_ALREADYSELECTED");
			return PBX_ReturnReady();
		}

		if(toggleLaser)
		{
			clearLAModeTokens();
			PBX_ToggleLaserSight();
			// Plays the switch animation only when its not in ADS
			if(!PB_GetZoom())
				return resolvestate("WeaponSwitch");
		}

		if(goMarlin || goMagnum) 
		{
			A_Print(goMarlin ? "$PBX_LeverAction_Marlin" : "$PBX_LeverAction_Magnum", 2);

			if(invoker.ammo2.amount == 0)
				return resolvestate("finishunload");
			return resolvestate("Unload");
		}

		clearLAModeTokens();
		return resolvestate(null);
	}

	action state PB_HandleWheel()
	{
		if(findinventory("LA_Select_Marlin") || findinventory("LA_Select_Magnum"))
		{
			{
				if (CountInv("LA_Select_Marlin") > 0) 
				{
					LA_SetAmmo(LA_444Marlin);
					setLAMode(LA_444Marlin);
					invoker.ReserveToMagAmmoFactor = AMMO_TAKE_MARLIN;
					invoker.currentMaxAmmo = MAGAZINE_SIZE/2;
				}
				if (CountInv("LA_Select_Magnum") > 0) 
				{
					LA_SetAmmo(LA_357Magnum);
					setLAMode(LA_357Magnum);
					invoker.ReserveToMagAmmoFactor = AMMO_TAKE_MAGNUM;
					invoker.currentMaxAmmo = MAGAZINE_SIZE;
				}
			}
			clearLAModeTokens();
			return ResolveState("Reload");
		}
		return resolvestate(null);
	}    
}