extend class PBX_Prosurv_Ballista
{
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
	override void postbeginplay()
	{
		currentMode = NORMAL_BOLT;
		unwindString = false;
		super.postbeginplay();
	}

	override void AttachToOwner(Actor other)
	{
		if (!other || !other.player) return;
		other.A_GiveInventory("PB_RocketAmmo", ROCKET_AMMO_GIVE);
		super.AttachToOwner(other);
	}

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
	// Automatically change sprites based on the mode
	action void setCrossbowSprite(
		name unloaded = '', 
		name bolt = '', 
		name explosive = '', 
		name demonic = '', 
		name shock = '',
		bool skipUnloadedCheck = false
	)
	{
		CrossbowMode mode = getCrossbowMode();
		name spriteToUse = '';
		
		// Set the sprite based on mode
		switch(mode)
		{
			case NORMAL_BOLT: 	  spriteToUse = bolt;		break;
			case EXPLOSIVE_BOLT:  spriteToUse = explosive;	break;
			case DEMONIC_BOLT: 	  spriteToUse = demonic;	break;
			case SHOCK_BOLT: 	  spriteToUse = shock;		break;
			default: break;
		}

		// If the chamber is empty, prioritize unloaded sprite
		if(PB_GetChamberEmpty() && !skipUnloadedCheck)
			spriteToUse = unloaded;
		
		// Double check if the sprite for it actually exists
		if(spriteToUse != '')
			A_SetWeaponSpriteEx(spriteToUse);
	}

	action state readyCrossbow()
	{
		if(getCrossbowMode() == NORMAL_BOLT)
		{
			setCrossbowSprite("CB0S","CB1S");
		}

		if(PressingReload() && invoker.ammo2.amount == ARROW_AMOUNT)
		{
			return resolveState("WeaponInspect");
		}
		else
		{
			return PB_ReadyFire(ads:false);
		}

	}

	action CrossbowMode getCrossbowMode()
	{
		return invoker.currentMode;
	}

	action void setCrossbowMode(CrossbowMode mode)
	{
		invoker.currentMode = mode;
	}

	// Convert tokens to Integers for easier use
	action CrossbowMode getTokens()
	{
		// Prioritize checking the tokens
		if(FindInventory("CB_Select_ShockMode"))
			return SHOCK_BOLT;
		else if(FindInventory("CB_Select_DemonicMode"))
			return DEMONIC_BOLT;
		else if (FindInventory("CB_Select_ExplosiveMode"))
			return EXPLOSIVE_BOLT;
		else if (FindInventory("CB_Select_NormalMode"))
			return NORMAL_BOLT;
		else if (FindInventory("CB_Select_NO"))
			return NO_UPGRADE;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
	}

	// Unload crossbow depending on mode
	action void unloadCrossbow()
	{
		name mToUnload;
		switch(getCrossbowMode())
		{
			case NORMAL_BOLT: 	 mToUnload = "PBX_BallistaBoltPickup"; 	break;
			case EXPLOSIVE_BOLT: mToUnload = "PBX_ExplosiveBoltPickup"; break;
			case DEMONIC_BOLT: 	 mToUnload = "PBX_DemonicBoltPickup"; 	break;
			case SHOCK_BOLT: 	 mToUnload = "PBX_ShockBoltPickup"; 	break;
		}
		PB_UnloadMag(
			invoker.ammo2.getclassname(),
			invoker.ammo1.getclassname(),
			invoker.ReserveToMagAmmoFactor,
			ARROW_AMOUNT,
			invoker.ReserveToMagAmmoFactor,
			0,
			mToUnload
		);
	}

	// Handle Weapon Special, if change mode then go to Unload
	// The actual mode change is handled there
    action state HandleWheel()
    {
		CrossbowMode tokens = getTokens();
		CrossbowMode mode = getCrossbowMode();
		bool alreadySelected = tokens == mode;
		bool notUpgraded = tokens == NO_UPGRADE;

		// Dont do anything, early returns
		if(countinv("PBX_CloseWheel") > 0 || alreadySelected || notUpgraded)
		{
			cleanmodetokens();
			if(alreadySelected || notUpgraded)
            	A_Print(alreadySelected ? "$PBX_AlreadySelected" : "$PBX_AmmoNotAvailable");

			return PBX_ReturnReady();
		}

		// Switch modes
		int ammoTake;
		name ammo;
		switch(tokens)
		{
			case NORMAL_BOLT: 	  ammoTake = ammoTakeNormal;  ammo = "PB_HighCalMag"; 	break;
			case EXPLOSIVE_BOLT:  ammoTake = ammoTakeNormal;  ammo = "PB_RocketAmmo";	break;
			case DEMONIC_BOLT: 	  ammoTake = ammoTakeDemonic; ammo = "PB_DTech";	 	break;
			case SHOCK_BOLT: 	  ammoTake = ammoTakeShock;   ammo = "PB_Cell";	 		break;
		}

		// Check if the player actually have enough ammo for a mode change
		if(CountInv(ammo) < ammoTake)
		{
			cleanmodetokens();
			A_Print("$PBX_NotEnoughAmmo");
			return PBX_ReturnReady();
		}

		printMode(tokens);

		// Very specific case where you've already unloaded and mode switch
		if(PB_GetChamberEmpty())
		{
			invoker.modechangeUnloaded = true;
        	return handleModeChange();
		}

		// Fallthrough to Unload Animation, the actual mode change is handled there
        return ResolveState(null);
    }

	action void printMode(int tokens)
	{
		string str;
		switch(tokens)
		{
			case NORMAL_BOLT: 		str = "$PBX_Crossbow_Standard"; 	break;
			case EXPLOSIVE_BOLT: 	str = "$PBX_Crossbow_Explosive"; 	break;
			case DEMONIC_BOLT: 		str = "$PBX_Crossbow_Demonic"; 		break;
			case SHOCK_BOLT: 		str = "$PBX_Crossbow_Shock"; 		break;
		}
		A_Print(StringTable.Localize(str).." \c-Loaded");
	}

	// Check if the player still has a token
	action bool checkTokens()
	{
		return getTokens() > 0;
	}

	action state handleModeChange()
	{
		// Setup Variables
		CrossbowMode mode = getTokens();
		int ammoTake;
		name ammo, icon;

		if(!checkTokens())
			return resolvestate(null);

		// Check what mode is selected
		switch(mode)
		{
			case NORMAL_BOLT: 	  ammoTake = ammoTakeNormal;  ammo = "PB_HighCalMag"; 	icon = "CB_ZA0"; 	break;
			case EXPLOSIVE_BOLT:  ammoTake = ammoTakeNormal;  ammo = "PB_RocketAmmo";	icon = "CB_ZB0";	break;
			case DEMONIC_BOLT: 	  ammoTake = ammoTakeDemonic; ammo = "PB_DTech";	 	icon = "CB_ZC0";	break;
			case SHOCK_BOLT: 	  ammoTake = ammoTakeShock;   ammo = "PB_Cell";	 		icon = "CB_ZD0";	break;
		}

		setCrossbowMode(mode);
		invoker.ReserveToMagAmmoFactor = ammoTake;
		invoker.ammo1 = Ammo(FindInventory(ammo));
		invoker.AltHudIcon = TexMan.CheckForTexture(icon);
		
		// always clear tokens and go to continue reload
		cleanmodetokens();
		if(invoker.modechangeUnloaded) 
		{
			invoker.modechangeUnloaded = false;
			return resolveState("StandardReload"); // Start reload animation if no arrow is loaded
		}
		return resolvestate("ContinueReload"); // Continue Reload also handles if the player does not have enough reserve when mode change
	}

	// Since some ready states have animations we made a simple "switch" so it goes to the right ready state
	action state readyCheck(StateLabel demonic, StateLabel explosive, StateLabel shock)
	{
		CrossbowMode mode = getCrossbowMode();

		if(PB_GetChamberEmpty())
			return resolvestate(null);

		switch(mode)
		{
			case SHOCK_BOLT:		return resolvestate(shock);
			case DEMONIC_BOLT:		return resolvestate(demonic);
			case EXPLOSIVE_BOLT:	return resolvestate(explosive);
		}
		
		return resolvestate(null);
	}

	// Fire Function, selects the correct projectile depending on mode
	action void FireWeapon()
	{
		string projectile;
		int ofs = PB_GetZoom() ? 1 : 3;
		switch (getCrossbowMode())
		{
			case NORMAL_BOLT: 		projectile = "PBX_BallistaBolt"; 	break;
			case EXPLOSIVE_BOLT: 	projectile = "PBX_ExplosiveBolt"; 	break;
			case DEMONIC_BOLT: 		projectile = "PBX_DemonicBolt"; 	break;
			case SHOCK_BOLT: 		projectile = "PBX_ShockBolt"; 		break;
		}
		if(PB_GetZoom()) invoker.firedFromADS = true;
		PB_FireBullets(projectile, 1, ofs, 0, 0, ofs);
		pb_takeammo(invoker.ammotype2,ARROW_AMOUNT,0,0);
	}	
	
	action void cleanmodetokens()
	{
        A_SetInventory("PBX_CloseWheel", 0);
        A_SetInventory("CB_Select_NormalMode", 0);
        A_SetInventory("CB_Select_ExplosiveMode", 0);
        A_SetInventory("CB_Select_DemonicMode", 0);
        A_SetInventory("CB_Select_ShockMode", 0);
        A_SetInventory("CB_Select_NO", 0);
	}

}