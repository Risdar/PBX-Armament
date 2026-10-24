extend class PBX_RevolverEdited
{
    override void AttachToOwner(Actor Other)
	{
		Super.AttachToOwner(other);
		if(!PB_HelpNotificationsHandler.CheckTipEvent(1 << 9, CVar.GetCvar("pb_helpflags", Other.Player))) {
			Array<String> pbTipsBuf;
			pbTipsBuf.Push("$PB_REVOLVER_TIP");
			PB_HelpNotificationsHandler.PB_SendTipArray(pbTipsBuf, "pb_helpflags", 1 << 9);
		}
	}

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

		"ReloadUnloaded", "ReloadDualWield",
        "ReloadUnloadedRight","ContinueReloadRight","ReloadLeftOnly","ReloadLeft",
        "ReloadUnloadedLeft","ContinueReloadLeft", "FinishDualReload",

        "Unload","DualUnload","StartUnloadLeft","UnloadLeft", "FinishDualUnload",

		"SwitchFromDualWield",
		"DualFlashKicking","DualFlashPunching","DualFlashSlideKicking","DualFlashSlideKickingStop",
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
        A_Setinventory("GoWeaponSpecialAbility",0);
		A_WeaponOffset(0,32);
		PB_HandleCrosshair(42);
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
                return PBX_SetupDualWield("$PB_REVOLVER_NOAKIMBO");

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
    action Rev_WW_Mode getTokens()
	{
		// Prioritize checking the tokens
		if(FindInventory("Revolver_Toggle_Secondary"))
			return TOGGLE_SECONDARY;
		else if (FindInventory("Revolver_Toggle_DualWield"))
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
        A_SetInventory("Revolver_Toggle_Secondary",0);
        A_SetInventory("Revolver_Toggle_DualWield",0);
        A_SetInventory("PBX_Toggle_Laser",0);
        A_SetInventory("PBX_CloseWheel",0);
    }
}