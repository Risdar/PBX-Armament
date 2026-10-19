extend class PBX_ProSurvPSG
{
    mixin PBX_LaserSight;

	static const StateLabel blockedLaserStates[] = {
		"Reload", "ShellChecker", "ChamberInsertShell", "ReloadFinished", "ReloadFromADS",
		"Unload", "RemoveBullets", "FinishUnload", "SelectAnimation", "WeaponInspect",
		"Pump", "PumpBegin", "PumpEnd", "WeaponRespect", "Deselect", "SwitchAnimation",
		"FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
	};

	override void PBX_DoEffectWeaponReady()
    {
		PBX_SpawnLaserSight(GREEN_DOT);
    }

	action void cleanmodetokens()
	{
		A_SetInventory("PBX_CloseWheel",0);
		A_SetInventory("PBX_Toggle_Laser",0);
		A_SetInventory("PSG_Select_Tripmine",0);
		A_SetInventory("PSG_Select_LaserCharge",0);
		A_SetInventory("PSG_Select_AcidCharge",0);
		A_SetInventory("PSG_Select_SwarmCharge",0);
		A_SetInventory("PSG_Select_Detonator",0);
	}

	action int getTokens() 
	{
		if(FindInventory("PBX_Toggle_Laser")) 
			return TOGGLE_LASER;
		else if(FindInventory("PSG_Select_Tripmine"))
			return TRY_TRIPMINE;
		else if(FindInventory("PSG_Select_LaserCharge"))
			return LASERCHARGE;
		else if(FindInventory("PSG_Select_AcidCharge"))
			return ACIDCHARGE;
		else if(FindInventory("PSG_Select_SwarmCharge"))
			return SWARMCHARGE;
		else if(FindInventory("PSG_Select_Detonator"))
			return DETONATOR;
		else
			return CLOSE_WHEEL;
	}

	action state handleSpecial()
	{
		int tokens = getTokens();

		switch(tokens)
		{
			case CLOSE_WHEEL:
				cleanmodetokens();
				return PBX_ReturnReady();
				break;

			case TOGGLE_LASER:
				cleanmodetokens();
				PBX_ToggleLaserSight();
				return PBX_ReturnReady(normal:"SwitchAnimation");
				break;

			case TRY_TRIPMINE:
				cleanmodetokens();
				if(!hasEnoughRockets(tokens))
				{
					return PBX_ReturnReady();
				}
				PB_SetZoom(false);
				A_ZoomFactor(1.0);
				A_overlay(SPECIAL_LAYER,"TripMineOverlay");
				return resolvestate("FlashPunching");
				break;

			case LASERCHARGE: case ACIDCHARGE: case SWARMCHARGE:
				if(!hasEnoughRockets(tokens))
				{
					cleanmodetokens();
					return PBX_ReturnReady();
				}
				PB_SetZoom(false);
				A_ZoomFactor(1.0);
				return resolvestate("ThrowCharges");
				break;

			case DETONATOR:
				cleanmodetokens();
				PB_SetZoom(false);
				A_ZoomFactor(1.0);
				A_overlay(SPECIAL_LAYER,"DetonatorOverlay");
				return resolvestate("FlashPunching");
				break;
		}
		return resolvestate(null);
	}

	action void throwCharges()
	{
		A_StartSound("charge/place/remote",CHAN_AUTO);
		
		string projectile;
		int amount;

		switch(getTokens())
		{
			case LASERCHARGE: 	projectile = "ThrownLaserCharge"; 	amount = LASERCHARGE_TAKE;	break;
			case ACIDCHARGE: 	projectile = "ThrownAcidCharge";	amount = ACIDCHARGE_TAKE; 	break;
			case SWARMCHARGE: 	projectile = "ThrownSwarmCharge"; 	amount = SWARMCHARGE_TAKE;	break;
		}
		A_TakeInventory(ROCKET_AMMO,amount);
		A_FireCustomMissile(projectile,0,0,0,-1);
		cleanmodetokens();
	}

	action bool hasEnoughRockets(int mode)
	{
		int toCheck;
		switch(mode)
		{
			case TRY_TRIPMINE: 	toCheck = TRIPMINE_TAKE; 		break;
			case LASERCHARGE: 	toCheck = LASERCHARGE_TAKE; 	break;
			case ACIDCHARGE: 	toCheck = ACIDCHARGE_TAKE; 		break;
			case SWARMCHARGE: 	toCheck = SWARMCHARGE_TAKE; 	break;
		}

		if(countinv(ROCKET_AMMO) < toCheck)
		{
			A_Print("$PBX_PSG_NOROCKETS");
			return false;
		}

		return true;
	}

	action void throwChargesSprite()
	{
		name sprite;
		switch(getTokens())
		{
			case LASERCHARGE:	sprite = "LSRC";	break;
			case ACIDCHARGE:	sprite = "REMT";	break;
			case SWARMCHARGE:	sprite = "SWRM";	break;
		}
		A_SetWeaponSpriteEx(sprite);
	}

	action void SG_Fire(int tic)
	{
		bool ads = PB_GetZoom();

		// Shared variables
		double recoilX      = ads ? frandom[sfx](-0.62,0.62) : frandom[sfx](-1.64,1.64);
		double recoilY      = ads ? +0.24 : +0.88;
		double zoomA        = ads ?  1.2  :  0.98;
		double zoomB        = ads ?  1.24 :  0.99;
		double zoomC        = ads ?  1.25 :  1.0 ;
		int    wadOfsY      = ads ?    -3 :    -4;

		switch(tic)
		{
			case 1:
				PB_SetRoll(0);
				if (ads) A_SetCrosshair(-1);

				PB_FireBullets("PB_12GAPellet", 12, 1.5, 0, 0, 1.5);

				A_FireProjectile("ShotgunWad", random(-2,2), 0, random(-2,2), wadOfsY, FPF_NOAUTOAIM, random(-2,2));
				PB_LowAmmoSoundWarning("shotgun");
				PB_TakeAmmo(invoker.ammo2.getClassName(),1,0);
				A_AlertMonsters();
				A_StartSound("weapons/sg", CHAN_WEAPON, pitch:frandom(0.95, 1.05));
				PB_IncrementHeat();
				PB_FireOffset();
				A_FireCustomMissile("YellowFlareSpawn", 0, 0, 0, 0);
				_SpawnMuzzleSparksSG(0, 0, -4);
				PB_MuzzleFlashEffects(0, 0, -4);
				PB_DynamicTail("shotgun", "shotgun");
				A_SetInventory("CantDoAction", 1);
				PB_SetChamberEmpty(true);
				A_GunFlash();
				A_ZoomFactor(zoomA);
				PB_WeaponRecoil(recoilX, recoilY);
				break;

			case 2:
				A_ZoomFactor(zoomB);
				PB_WeaponRecoil(recoilX, recoilY);
				break;

			case 3:
				A_ZoomFactor(zoomC);
				break;

			// Pump
			case 4:
				A_ZoomFactor(zoomC);
				if(ads) A_SetCrosshair(-1);
                A_StartSound("Ironsights",CHAN_AUTO);
				PB_SetReloading(true);
				break;

			case 5:
				PB_SpawnCasing("ShotgunCasing",15,-5,26,0,3,3);
				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
				break;
		}
	}
}