extend class PBX_DeagleEdited
{
	override void DoEffect() 
	{
		super.DoEffect();
		If(owner.player && owner.player.readyweapon)
		{
			if(mCoinCooldown > 0 && level.time % TICRATE == 0)
			{
				mCoinCooldown--;
				if(mCoinCooldown == 0)
				{
					PBXCore_Debug.Print("Coin Cooldown finished");
					owner.a_startsound("revolver/coin",PBX_COOLDOWN_CHAN,CHANF_DEFAULT,1,ATTN_NONE);
				}
			}
		}
	}

	mixin PBX_LaserSight;
    static const StateLabel blockedLaserStates[] = {
        "Deselect",

        "SelectAnimationDualWield", "SelectAnimation",

        "SwitchToDualWield", "StopDualWield", "WeaponInspect", "HoldInspect",

        "Reload","ContinueReload", "CoinTossAnimation",

		"EmptyReload", "ContinueReloadEmpty",
        "Rechamber","ReloadDualFromUnload","ReloadDualWield","StartReloadLeft_Overlay",
        "ReloadLeftFromUnload_Overlay","ReloadLeftDown_Overlay", "StartReloadRight_Overlay",
		"ReloadRightFromUnload_Overlay","ReloadLeftUp_Overlay","ReloadLeftDown2_Overlay",
		"ReloadRightDown2_Overlay","ReloadRightUp_Overlay","SelectLeft_Overlay",
		"SelectRight_Overlay","DeselectLeft_Overlay","DeselectRight_Overlay",
		"ReloadRightFromLeft","StartReloadRight","ReloadRightFromUnload",
		"ReloadLeftFromRight","StartReloadLeft","ReloadLeftFromUnload",
		"ReloadLeft","FinishDualReload","StartRechamberRight","RechamberRight",
		"RechamberLeft",

        "Unload","EndUnloadLeft_Overlay","EndUnloadRight_Overlay","NoUnloadRight_Overlay", "NoUnloadLeft_Overlay",
		"DualUnload",

        "FlashPunchingDual","FlashKickingDual","FlashAirKickingDual","FlashSlideKickingDual",
		"FlashSlideKickingStopDual",

		"SwitchFromDualWield",
        "WeaponRespect", "SwitchAnimation",
        "FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
    };
	
    override void PBX_DoEffectWeaponReady()
    {
		PBX_SpawnLaserSight(RED_DOT);
    }

	private
    action state handleWheel()
    {
		A_WeaponOffset(0,32);
        A_Setinventory("GoWeaponSpecialAbility",0);
		PB_HandleCrosshair(32);
		PB_SetZoom(false);
		PB_ClearDualWield();
		A_StartSound("Ironsights", 10);

        switch(getTokens())
        {
            case CLOSE_WHEEL:
                cleanTokens();
        		return resolvestate("Ready3");

            case TOGGLE_SECONDARY:
                cleanTokens();
                invoker.mCoinSecondary = !invoker.mCoinSecondary;
				if(invoker.mCoinSecondary)
				{
					A_StartSound("revolver/coin",CHAN_AUTO,CHANF_OVERLAP);
                	A_Print("$PBX_Coin_Select");
					if(A_CheckAkimbo()) return resolvestate("Ready3");
        			return resolvestate("CoinSwitchAnimation");
				}
				else
				{
                	A_Print("$PBX_SECONDARY_ZOOM");
				}
				return resolvestate("Ready3");

            case TOGGLE_DUAL_WIELD:
                cleanTokens();
                return PBX_SetupDualWield("$PB_DEAGLE_NOAKIMBO");

            case TOGGLE_LASER_SIGHT:
				PBX_ToggleLaserSight();
                break;
        }

		A_StartSound("Ironsights",CHAN_AUTO,CHANF_OVERLAP);
        cleanTokens();
		if(A_CheckAkimbo()) return resolvestate("Ready3");
        return resolvestate(null);
    }

	private
    action Deag_WW_Mode getTokens()
	{
		// Prioritize checking the tokens
		if(FindInventory("Deagle_Toggle_Secondary"))
			return TOGGLE_SECONDARY;
		else if (FindInventory("Deagle_Toggle_DualWield"))
			return TOGGLE_DUAL_WIELD;
		else if(FindInventory("PBX_Toggle_Laser"))
			return TOGGLE_LASER_SIGHT;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
	}

    private
    action void cleanTokens()
    {
        A_SetInventory("Deagle_Toggle_Secondary",0);
        A_SetInventory("Deagle_Toggle_DualWield",0);
        A_SetInventory("PBX_Toggle_Laser",0);
        A_SetInventory("PBX_CloseWheel",0);
    }

    action void PB_SetSpriteIfUnload(string sp,bool dual = false)
	{
		if(PB_GetChamberEmpty(dual))
			A_setoverlaysprite(overlayID(),sp);
	}
	
	Action void PB_SetDualSpriteIfUnload(string leftuUnl,string rightUnl,string unloaded)
	{
		bool rightunloaded = (PB_GetChamberEmpty());
		bool leftunloaded = (PB_GetChamberEmpty(true));
		if(rightunloaded && leftunloaded)
		{
			A_setoverlaysprite(overlayID(),unloaded);
			return;
		}
		else if(rightunloaded)
		{
			A_setoverlaysprite(overlayID(),rightUnl);
			return;
		}
		
		else if(leftunloaded)
		{
			A_setoverlaysprite(overlayID(),leftuUnl);
			return;
		}
		//A_setoverlaysprite(overlayID(),normal);
	}
}