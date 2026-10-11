//////////////////////////// WEAPON WHEEL ////////////////////////////////////////////////////////////////////////////////////
mixin class PBX_GenericSpecialWheel
{
    private PBX_WeaponBase mWeap; // Weapon pointer (Needs to be casted again for specific weapon vars)
    private actor mRequester;     // Player pointer
    private bool mDisabled;       // For upgrades if they're disabled
    private vector2 mIconScale;   // Icon scale

    // Bundles the close wheel, laser, scope mode, and nvg
    void PBX_GenericWheel(in out array <PB_SpecialWheel_Mode> spw, string wheelFolder, vector2 laserWheelScale = (1.0,1.0))
    {
		PBX_LaserWheel(spw,wheelFolder,laserWheelScale);
		PBX_ScopeWheel(spw);
        PBX_NVGWheel(spw);
    }

    // Set up class fields
    void PBX_InitializeWheel(in out array <PB_SpecialWheel_Mode> spw, actor requester, vector2 scale = (1.0,1.0))
    {
		super.GetSpecials(spw,requester);
        mRequester = requester;
        mWeap = PBX_WeaponBase(requester.player.readyweapon);
        mIconScale = scale;
        PBX_CloseWheel(spw);
    }

    void PBX_AddWheel(in out array <PB_SpecialWheel_Mode> spw, string img, string alias, string token, vector2 scale = (0,0))
    {
        vector2 scl = scale == (0,0) ? mIconScale : scale;
        PB_SpecialWheel_Mode newWheel = new ("PB_SpecialWheel_Mode");
		newWheel.img = IMAGE_DIRECTORY..img..".png";
		newWheel.Alias = alias;
		newWheel.tokentogive = token;
		newWheel.scalex = scl.x;
		newWheel.scaley = scl.y;
		spw.push(newWheel);
    }

    bool PBX_CheckInv(name inv, bool checkDisabled = true)
    {
        bool hasInv = mRequester && mRequester.CountInv(inv) > 0;
        return hasInv || (checkDisabled && mDisabled);
    }

    void PBX_CloseWheel(in out array <PB_SpecialWheel_Mode> spw)
    {
        PB_SpecialWheel_Mode PBX_CloseWheel = new ("PB_SpecialWheel_Mode");
		PBX_CloseWheel.img = "graphics/WeaponWheel/CloseMenu.png";
		PBX_CloseWheel.Alias = "$PBX_CloseMenu";
		PBX_CloseWheel.tokentogive = "PBX_CloseWheel";
		PBX_CloseWheel.scalex = WHEEL_CLOSEMENU_SCALE;
		PBX_CloseWheel.scaley = WHEEL_CLOSEMENU_SCALE;
		spw.push(PBX_CloseWheel);
    }

    void PBX_LaserWheel(in out array <PB_SpecialWheel_Mode> spw, string wheelFolder, vector2 laserWheelScale = (1.0,1.0))
    {
        if(!mWeap) return;

        PB_SpecialWheel_Mode PBX_ToggleLaser = new("PB_SpecialWheel_Mode");
		if(!mWeap.GetLaserActive()) 
        {
            PBX_ToggleLaser.Alias = "$PBX_LaserON";
            PBX_ToggleLaser.img = IMAGE_DIRECTORY..wheelFolder.."/LaserOn.png";
		}
		else 
        {
            PBX_ToggleLaser.Alias = "$PBX_LaserOff";
            PBX_ToggleLaser.img = IMAGE_DIRECTORY..wheelFolder.."/LaserOff.png";
		}
		PBX_ToggleLaser.tokentogive = "PBX_Toggle_Laser";
		PBX_ToggleLaser.scalex = laserWheelScale.x;
		PBX_ToggleLaser.scaley = laserWheelScale.y;
		spw.push(PBX_ToggleLaser);
    }

    void PBX_ScopeWheel(in out array <PB_SpecialWheel_Mode> spw)
    {
        PB_SpecialWheel_Mode PBX_ToggleScope = new ("PB_SpecialWheel_Mode");
		PBX_ToggleScope.img = "graphics/WeaponWheel/ScopeMode.png";
		PBX_ToggleScope.Alias = "$PBX_GoScope";
		PBX_ToggleScope.tokentogive = "PBX_Toggle_Scope";
		PBX_ToggleScope.scalex = WHEEL_SCOPE_SCALE;
		PBX_ToggleScope.scaley = WHEEL_SCOPE_SCALE;
		spw.push(PBX_ToggleScope);
    }

    void PBX_NVGWheel(in out array <PB_SpecialWheel_Mode> spw)
    {
        if(!mWeap) return;

        PB_SpecialWheel_Mode PBX_ToggleNVG = new ("PB_SpecialWheel_Mode");
		PBX_ToggleNVG.img = "GRAPHICS/HiResPickups/Powerups/VISR1.png";
		if(mWeap.IsNVGActive()) 
			PBX_ToggleNVG.Alias = "$PBX_nvgOffWW";
		else 
			PBX_ToggleNVG.Alias = "$PBX_nvgOnWW";
		PBX_ToggleNVG.tokentogive = "PBX_Toggle_NVG";
		PBX_ToggleNVG.scalex = WHEEL_NVG_SCALE;
		PBX_ToggleNVG.scaley = WHEEL_NVG_SCALE;
		spw.push(PBX_ToggleNVG);
    }
}