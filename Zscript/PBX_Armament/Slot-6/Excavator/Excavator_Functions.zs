extend class PBX_Excavator
{
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    
	override void PBX_DoEffectWeaponReady()
    {
		bool pressingAlt = owner.player.cmd.buttons & BT_ALTATTACK;
		bool hasDetonator = owner.countinv("GrenadeDetonator") > 0;
		bool isInDropDrillMode = (excavatorMode == eDrillChargeMode) || (excavatorMode == eDropShotMode);

		if(isInDropDrillMode)
		{
			if(pressingAlt && !hasDetonator )
			{
				owner.A_SetInventory("GrenadeDetonator",1);
				owner.A_PlaySound("excavator/detonate");
			}
			if(!pressingAlt && hasDetonator )
			{
				owner.A_SetInventory("GrenadeDetonator",0);
			}
		}
    }

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////

	action void changeModeSprite(name bolamode, name sawmode)
    {
        ExcMode mode = getExcavatorMode();
        if(mode == eSawMode)
		{
			A_SetWeaponSpriteEx(sawmode);
		}
        else
		{
			A_SetWeaponSpriteEx(bolamode);
		}
    }

	action void checkUnloadedSprites(name unloadedBola,name unloadedSaw,name modeBola,name modeSaw)
	{
		if(PB_GetMagUnloaded())
			changeModeSprite(unloadedBola,unloadedSaw);
		else
			changeModeSprite(modeBola,modeSaw);
	}

	action void EX_HandleCrosshair()
	{
		ExcMode mode = getExcavatorMode();
		int crosshair = 75;
		switch(mode)
		{
			case eDrillChargeMode: 	crosshair = 78; break;
			case eDropShotMode: 	crosshair = 79; break;
			case eBolaMode: 		crosshair = 77; break;
			case eSawMode: 			crosshair = 75; break;
		}
		PB_HandleCrosshair(crosshair);
	}

	action int isExcavatorUpgraded()
	{
		bool hasUpgraded = countinv("Excavator_Upgraded") > 0;
		bool isDisabled = (PBX_BackPack_filter & DisablePBX_ExcavatorUpgrade);
		return hasUpgraded || isDisabled || invoker.isUpgraded;
	}

	action ExcMode getTokens() 
	{
		if(FindInventory("EX_Select_DrillMode")) 
			return eDrillChargeMode;
		else if(FindInventory("EX_Select_DropMode")) 
			return eDropShotMode;
		else if(FindInventory("EX_Select_BolaMode")) 
			return eBolaMode;
		else if(FindInventory("EX_Select_SawMode")) 
			return eSawMode;
		else if(FindInventory("EX_Select_No")) 
			return eNoUpgrade;
		else 
			return eCloseWheel;
	}

    action ExcMode getExcavatorMode()
	{
		return invoker.excavatorMode;
	}
	
	action void setExcavatorMode(int mode = eDrillChargeMode)
	{
		invoker.excavatorMode = mode;
	}

    action void cleanmodetokens()
	{
		A_Takeinventory("EX_Select_DrillMode",1);
		A_takeinventory("EX_Select_DropMode",1);
		A_takeinventory("EX_Select_BolaMode",1);
		A_takeinventory("EX_Select_SawMode",1);
		A_takeinventory("PBX_CloseWheel",1);
		A_takeinventory("EX_Select_No",1);
	}

	// Tokens is cleared here
	action void actualModeChange()
	{
		ExcMode tokens = getTokens();
		cleanmodetokens(); // Clear tokens

		if(tokens != eSawMode)
		{
			invoker.ReserveToMagAmmoFactor = AMMO_TAKE_NORMAL;
			invoker.ammo1 = Ammo(FindInventory("PB_RocketAmmo"));
		}
		else
		{
			invoker.ReserveToMagAmmoFactor = AMMO_TAKE_SAW;
			invoker.ammo1 = Ammo(FindInventory("PB_Fuel"));
		}
		setExcavatorMode(tokens);
	}

	// This is called in Unload, note that at this point the weapon special token
	// still exists in the player's inventory
	action state handleModeChange()
	{
		ExcMode tokens	= getTokens();

		if(tokens <= 0)
		{
			cleanmodetokens();
			return resolvestate(null);
		}

		if(PB_GetMagUnloaded() && (tokens != eSawMode))
		{
			return resolvestate("SwitchToBola");
		}

		else if(PB_GetMagUnloaded())
		{
			return resolvestate("SwitchToSaw");
		}

		return resolvestate(null);
	}

	action state handleSpecial()
	{
		A_Takeinventory("GoWeaponSpecialAbility",1);
		A_ZoomFactor(1.0);

		// Setup Variables
		ExcMode mode	= getExcavatorMode();
		ExcMode tokens	= getTokens();

		// Handlle Close Wheel
		if(tokens == eCloseWheel)
		{
			cleanmodetokens();
			if(isExcavatorUpgraded())
				return resolvestate("ready2");
			return resolvestate("Ready3");
		}

		// Handle Not Upgraded
		if(tokens == eNoUpgrade)
		{
			A_TakeInventory("EX_Select_No",1);
			A_Print("$PBX_ModeNotAvailable");
			return resolvestate("Ready3");
		}

		// Handle Already Selected
		if(tokens == mode)
		{
			A_print("$PBX_AlreadySelected");
			cleanmodetokens();
			if(isExcavatorUpgraded())
				return resolvestate("ready2");
			return resolvestate("ready3");
		}

		// If its from drop/drill and going to bola, just play a sound and go to Switch Animation
		if(tokens == eBolaMode && (mode == eDropShotMode || mode == eDrillChargeMode))
		{
			setExcavatorMode(tokens);
			A_Print("$PBX_Excavator_BolaMode");
			cleanmodetokens();
			return resolvestate("SwitchAnimation.Upgraded");
		}

		// If it goes to Bola or Saw mode, go to unload
		// the actual mode change is handled there
		if(tokens == eBolaMode || tokens == eSawMode)
		{
			A_Print(tokens == eBolaMode ? "$PBX_Excavator_BolaMode" : "$PBX_Excavator_SawMode");
			return resolvestate("Unload.Upgraded");
		}
		
		// If its in saw mode and going to drop/drill
		// go to unload so it plays the saw to bola animation
		if(mode == eSawMode && (tokens == eDropShotMode || tokens == eDrillChargeMode))
		{
			return resolvestate("Unload.Upgraded");
		}

		// Handle drop/drill mode
		if(tokens == eDropShotMode || tokens == eDrillChargeMode)
		{
			setExcavatorMode(tokens);
			A_Print(tokens == eDropShotMode ? "$PBX_Excavator_DropMode" : "$PBX_Excavator_DrillMode");
			cleanmodetokens();

			// Play a sound and early return to the upgraded switch animation if its upgraded
			if(isExcavatorUpgraded())
			{
				return resolvestate("SwitchAnimation.Upgraded");
			}
			return resolvestate(null);
		}

		// If its not upgraded and going drop/drill, fallthrough
		// this will go to the standard mode switch animation
		return resolvestate(null);
	}

	action state checkAltfire()
	{
		ExcMode mode = getExcavatorMode();

		if(!isExcavatorUpgraded())
			return resolvestate("ready3");

		if(mode == eDrillChargeMode || mode == eDropShotMode)
			return resolvestate("ready2");
	
		return resolvestate(null);
	}
	
	action void FireWeapon(bool altfire = false)
	{
		A_AlertMonsters();
		A_WeaponOffset(0,32);
		PB_SetRoll(0);

		A_FireCustomMissile("ShotgunParticles", random(-16,16), 0, -1, random(-9,9));
		A_FireBullets(0, 0, 1, 50, "shotpuff", 0, 130);
		PB_IncrementHeat(4);
		A_FireCustomMissile("RedFlareSpawn",-5,0,0,0);
		A_ZoomFactor(0.96);
		EX_HandleCrosshair();
		
		// ACTUAL FIRING
		EX_FireWeapon(altfire);
		PB_FireOffset();
		
		PB_WeaponRecoil(-3.2,frandom[sfx](-1.61,1.61));//same as the SuperGL - sarge945
		PB_SpawnCasing("EmptyGrenadeBrass", 30, 0, 34, -frandom(1, 3), -frandom(2, 4), 5);
		// TAKE AMMO
		PB_LowAmmoSoundWarning();
		pb_takeammo(invoker.ammo2.getclassname(),emptyMag:0);
	}

	action void EX_FireWeapon(bool altfire = false)
	{
		ExcMode mode = getExcavatorMode();
		string snd = "excavator/firedigger";
        string projectile = "ExcavatorDrill";

		switch(mode)
		{
			case eDrillChargeMode: 	
				projectile = "ExcavatorDrill"; 		
				snd = "excavator/firedigger"; 	
				break;
			case eDropShotMode: 	
				projectile = "ExcavatorDropShot"; 	
				snd = "excavator/firedropshot"; 	
				break;
			case eBolaMode: 		
				projectile = altfire ? "ExcavatorGrenade" : "ExcavatorBola"; 		
				snd = altfire ? "excavator_grenadelaunch" : "excavator_bolalaunch"; 	
				break;
			case eSawMode: 			
				projectile = altfire ? "HeatedRazorblade" : "Razorblade";	 		
				snd = "excavator_fire_razor"; 	
				break;
		}

		PB_FireBullets(projectile, 1, 0, 0, 0, 3);
		A_StartSound(snd, CHAN_WEAPON, CHANF_OVERLAP);
	}
		
}