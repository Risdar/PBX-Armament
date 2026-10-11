extend class PBX_MetalSniper
{
    mixin PBX_LaserSight;

    static const StateLabel blockedLaserStates[] = {
        "Reload", "Reload_Grenade", "StandardReload", "WeaponRespect", "ReloadFromADS", "WeaponInspect",
        "TakeMagStandard", "TakeMagResonance", "InsertMag", "ReloadFromSpecial", "Deselect",
        "FinishReload", "RaiseFromEmpty", "Start_Rechamber", "Rechamber", "ChangeAnim",
        "UnloadFromSpecial","Unload","UnloadRaise","UnloadMagStandard", "UnloadMagEmpty",
        "UnloadMagResonance", "UnloadChamber", "FinishUnload", "StartUnloadChamber", "SelectAnimation",
        "FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
    };

    // ── Overrides ──────────────────────────────────────────────────────────────────
    override void PostBeginPlay()
    {
        grenadeloaded  = true;
        currentMaxAmmo = MAGAZINE_SIZE;
        Super.PostBeginPlay();
    }

    bool mShouldResetVariables;
    override void PBX_DoEffectWeaponReady()
	{
        PBX_SpawnLaserSight(GREEN_DOT);

        if(!owner.FindInventory("Zoomed") && mShouldResetVariables)
        {
            enableScopeHUD = false;
            owner.A_SetRenderstyle(1.0, STYLE_Normal);
            wheelinfo = "MetalSniperWheel";
            mShouldResetVariables = false;
        }
	}

    // ═════════════════════════════════════════════════════════════════════════
    // ACTION FUNCTIONS
    // ═════════════════════════════════════════════════════════════════════════
    action state MS_ReadyZoom()
    {
        A_SetRoll(0);
        A_SetCrosshair(-1);
        PB_CoolDownBarrel(-5, 0, 7, 0,  1);
        PB_CoolDownBarrel( 5, 0, 7, 0, -1);
        A_ZoomFactor(PBX_GetZoomLevel());
        MS_SetTransparency();
        invoker.mShouldResetVariables = true;
        return PB_ReadyFire(ads:true);
    }

    action void MS_SetTransparency()
    {
        switch(PBX_GetSmartScopeMode())
        {
            case SMARTSCOPE_DISABLED:
                // EndBlend("DarkGreen");
                invoker.enableScopeHUD = false;
                A_SetRenderstyle(1.0, STYLE_Normal);
                break;

            case SMARTSCOPE_PARTIAL: case SMARTSCOPE_FULL:
                // A_SetBlend(0x00a100, 0.2, 99999);
                A_SetCrosshair(52);
                PBX_ReadySmartScope();
                A_SetRenderstyle(0.1, Style_Translucent);
                invoker.enableScopeHUD = true;
                break;
        }
    }

    // ── Ammo / magazine helpers ───────────────────────────────────────────────
    action void MS_ReloadMag()
    {
        int amount = invoker.currentMaxAmmo;
        if (PB_GetChamberEmpty()) amount--;
        PB_AmmoIntoMag(
            invoker.ammo2.GetClassName(), 
            invoker.ammo1.GetClassName(), 
            amount, 
            invoker.ReserveToMagAmmoFactor
        );
    }

    action void MS_UnloadMag(bool UnloadChamber = false)
    {
        int goal = UnloadChamber ? 0 : 1;
		string rounds = invoker.resonanceAmmoLoaded ? "PBX_ResoRound" : "PB_HigherCalRound";
        PB_UnloadMag(
            invoker.ammotype2, 
            invoker.ammotype1, 
            invoker.ReserveToMagAmmoFactor, 
            1, 
            0, 
            goal, 
            rounds
        );
    }

    action void MS_HandleAmmoChange()
    {
        int capacity;
        int amount;
        invoker.resonanceAmmoLoaded = !invoker.resonanceAmmoLoaded;

        // these are 3 because the ammo couunter already counts 2 reserve as 1 in the ammo bar
        if(invoker.resonanceAmmoLoaded)
        {
            capacity = MAGAZINE_SIZE / 3;
            amount = invoker.ammo2.amount / 3;
            invoker.ReserveToMagAmmoFactor = AMMO_TAKE_RESONANCE;
            invoker.ammo2.backpackmaxamount = MAGAZINE_SIZE / 3;
        }
        else
        {
            capacity = MAGAZINE_SIZE;
            amount = invoker.ammo2.amount * 3;
            invoker.ReserveToMagAmmoFactor = AMMO_TAKE_NORMAL;
            invoker.ammo2.backpackmaxamount = MAGAZINE_SIZE;
        }

        A_SetInventory(invoker.ammotype2, amount);
        SetAmmoCapacity(invoker.ammotype2, capacity);
        invoker.currentMaxAmmo = capacity;
        cleanmodetokens();
    }

    // ── Mode switch handler ───────────────────────────────────────────────────

    action MS_WheelMode MS_GetTokens()
    {
        if(FindInventory("MS_Select_NO"))
            return NO_UPGRADE;
        else if(FindInventory("MS_Select_Resonance"))
            return TOGGLE_RESONANCE;

        else if(FindInventory("MS_Select_AimMode"))
            return ZOOM_ALTFIRE;
        else if(FindInventory("MS_Select_GrenMode"))
            return GRENADE_ALTFIRE;
        else if(FindInventory("PBX_Toggle_Laser"))
            return TOGGLE_LASER;

        else if(FindInventory("PBX_Toggle_Scope"))
            return TOGGLE_SCOPE;
        else if(FindInventory("PBX_Toggle_NVG"))
            return TOGGLE_NVG;
        else if(FindInventory("PBX_CloseWheel"))
            return CLOSE_WHEEL;
        else
            return ERROR_WHEEL;
    }

    action state MS_HandleSpecial()
    {
        // Get the tokens
        MS_WheelMode tokens = MS_GetTokens();

        // Check if the mode is already selected
        if (tokens == invoker.AltMode)
        {
            A_Print("$PBX_AlreadySelected");
            cleanmodetokens();
            return resolvestate("Ready3"); // Skip the change animation
        }

        // Handles everything else
        switch(tokens)
        {
            case CLOSE_WHEEL:
                cleanmodetokens();
                return PBX_ReturnReady();

            case NO_UPGRADE:
                cleanmodetokens();
                A_Print("$PBX_AmmoNotAvailable");
                return resolvestate("Ready3");

            case TOGGLE_RESONANCE:
			    // The actual weapon switch is at the end of the unload > reload > chamber sequence
                A_Print(!invoker.resonanceAmmoLoaded ? "$PBX_MetalSniper_Resonance" : "$PBX_MetalSniper_Standard"); // Reversed because technically the ammo hasnt been loaded yet
                return PB_GetChamberEmpty() ? resolvestate("ReloadFromSpecial") : resolvestate("UnloadFromSpecial");

            case ZOOM_ALTFIRE: case GRENADE_ALTFIRE:
                invoker.AltMode = tokens;
                A_Print(tokens == ZOOM_ALTFIRE ? "$PBX_MetalSniper_AimMode" : "$PBX_MetalSniper_GrenMode");
                break;

            case TOGGLE_LASER:
                PBX_ToggleLaserSight();
                // Basically only play the change animation if the player is not in ADS
                // Since the laser can be toggled from both the normal and ads wheel
                if(!PB_GetZoom()) 
                {
                    cleanmodetokens();
                    return ResolveState("ChangeAnim");
                }
                break;

            case TOGGLE_SCOPE:
                PBX_ToggleSmartScope();
                break;

            case TOGGLE_NVG:
                PBX_ToggleNightVision();
                break;
        }

        // Always clear the tokens
        cleanmodetokens();
        return resolvestate(null);
    }

    action void cleanmodetokens()
    {
        A_TakeInventory("MS_Select_AimMode",      1);
        A_TakeInventory("MS_Select_GrenMode",     1);
        A_TakeInventory("MS_Select_Resonance",    1);
        A_TakeInventory("MS_Select_NO",           1);
        A_TakeInventory("PBX_Toggle_Laser",       1);
        A_TakeInventory("PBX_Toggle_Scope",       1);
        A_TakeInventory("PBX_Toggle_NVG",         1);
        A_TakeInventory("PBX_CloseWheel",         1);
    }

    // ── Fire helpers ──────────────────────────────────────────────────────────
    action void MS_FireActual()
    {
        if (invoker.resonanceAmmoLoaded)
        {
            PB_FireBullets("MS_ResonanceRounds", 1, frandom(-0.1, 0.1), 0, 0, frandom(-0.1, 0.1));
            A_StartSound("MS/ResonanceFire",CHAN_WEAPON,CHANF_OVERLAP);
        }
        else
        {
            PB_FireBullets("PB_762x51mmAP", 1, frandom(-0.1, 0.1), 0, 0, frandom(-0.1, 0.1));
            A_StartSound("MS/Fire",CHAN_WEAPON, CHANF_OVERLAP);
        }
    }

    action void MetalSniperFireADS()
    {
        A_WeaponOffset(0, 32);
        A_AlertMonsters();
        PB_DynamicTail("lmg", "lmg");
        A_Overlay(muzzlelayer, "MuzzleFlash_ADS");
        MS_FireActual();
        PB_TakeAmmo(invoker.ammotype2, 1);
        // A_SetInventory("CantDoAction", 1);
        PB_IncrementHeat(4);
        PB_IncrementHeat(4, true);
        PB_FireOffset();
        PB_GunSmoke(0, 0, -2);
        PB_WeaponRecoil(-1, frandom[sfx](-1.0, 1.0));
        PB_SpawnCasing("LMGCasingStandard", 26, 2, 28, 0, frandom(5, 8), frandom(1, 4));
    }

    action void MetalSniperFire()
    {
        A_WeaponOffset(0, 32);
        A_AlertMonsters();
        PB_DynamicTail("lmg", "lmg");
        A_Overlay(muzzlelayer, "MuzzleFlash");
        MS_FireActual();
        // PB_LowAmmoSoundWarning("lmg");
        PB_TakeAmmo(invoker.ammotype2, 1);
        PB_IncrementHeat(4);
        PB_IncrementHeat(4, true);
        PB_FireOffset();
        PB_GunSmoke(0, 0, -1);
        PB_WeaponRecoil(-3, frandom[sfx](-0.5, 0.5));
        PB_SpawnCasing("LMGCasingStandard", 26, 2, 28, 0, frandom(5, 8), frandom(1, 4));
    }

    // ── Grenade helpers ───────────────────────────────────────────────────────
    action void MS_SetGrenadeQ(bool q) { invoker.grenadeloaded = q; }
    action int  getgrenqtty()          { return invoker.grenadeloaded; }

    // ── Input helpers ─────────────────────────────────────────────────────────
    action bool PlayerPressedOnce(int button)
    {
        return (player.cmd.buttons & button) && !(player.oldbuttons & button);
    }

}