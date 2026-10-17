//////////////////////////// WEAPON CODE ////////////////////////////////////////////////////////////////////////////////////
extend class PBX_WeaponBase
{
    // This is set in PostBeginPlay()
    private double mZoomLevel;

    // This is set as a Property
    private double mMinZoom, mMaxZoom;
    private bool mScopedWeapon;
    property ScopeConfiguration: mScopedWeapon,mMinZoom,mMaxZoom;

    // This only changes the internal values
    // You'll need to actually set the zoomfactor by using A_ZoomFactor(PBX_GetZoomLevel());
    action void PBX_AdjustZoom(int dir, double step = 0.5)
    {
        invoker.mZoomLevel = clamp(invoker.mZoomLevel + dir * step, invoker.mMinZoom, invoker.mMaxZoom);
        PBXCore_Debug.PrintInt("Zoom Adjusted with %d",invoker.mZoomLevel);
        A_StartSound("IronSights", CHAN_WEAPON, CHANF_OVERLAP);
        A_StartSound("MS/Button", CHAN_AUTO);
        A_SetBlend("Black", 1, 35);
    }

    clearscope bool IsScopedWeapon()
    {
        return mScopedWeapon;
    }

    action double PBX_GetZoomLevel()
    {
        return invoker.mZoomLevel;
    }
}

//////////////////////////// HANDLER CODE ////////////////////////////////////////////////////////////////////////////////////
class PBX_ScrollZoomHandler : EventHandler
{	
	// Scroll Zoom Input
	override bool InputProcess(InputEvent e)
    {
        if (e.Type == InputEvent.Type_None)
		{
			return false;
		}

        let plr = players[consoleplayer].mo;
        if (!plr || !(plr.player.ReadyWeapon is "PBX_WeaponBase") || !plr.FindInventory("Zoomed"))
		{
			return false;
		}

		let weap = PBX_WeaponBase(plr.player.ReadyWeapon);
		if(!weap || !weap.IsScopedWeapon()) 
		{
			return false;
		}

        if (e.KeyScan == InputEvent.Key_MWheelUp)
        {
            SendNetworkEvent("PBX_Weapons_ZoomIn");
            return true;
        }

        if (e.KeyScan == InputEvent.Key_MWheelDown)
        {
            SendNetworkEvent("PBX_Weapons_ZoomOut");
            return true;
        }

        return false;
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        PlayerInfo player = players[e.Player];
        let wpn = PBX_WeaponBase(player.ReadyWeapon);
        if (!wpn || !wpn.IsScopedWeapon() || !player.mo || !player.mo.FindInventory("Zoomed")) 
		{
			return;
		}

        if (e.Name == "PBX_Weapons_ZoomIn")
		{
			wpn.PBX_AdjustZoom(1);
		}
        else if (e.Name == "PBX_Weapons_ZoomOut")
		{
			wpn.PBX_AdjustZoom(-1);
		}
    }
}