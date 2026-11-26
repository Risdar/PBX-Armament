// This id the data for PB Weapons

extend class PBX_HUD_Handler
{
    // How many steps the whole icon should move
    const AKIMBO_POSITION_WHOLE = -15;

    // Where should the position of the second icon be
    // if dual wield is active
    const AKIMBO_POSITION_X = -10;
    const AKIMBO_POSITION_Y = -10;

    // Visor overlays
    ui int flagsManualVisor1, flagsManualVisor2;
    ui int8 pbx_m32to0;
    ui float pbx_visorOffsets;
    ui vector2 topOffsets1, topOffsets2;

    // The constants used for the overlays (the graphics you see at the side)
    const HUD_SIDE_OVERLAY = 24;
    
    // Main Draw Function
    private
    ui void DrawEveryWeapon()
    {
        // Dont draw if its disabled
        if(CheckFlag(DisablePBX_WeaponHud) || !pbWeap) return;

        FindHUDServices();        // Find other mods that uses PBX HUD
        GetWeaponData();          // Get Data on this file
        GetWeaponDataService();   // Get Data outside of this file
        GetWeaponDataAuto();      // Automatically get the weapon Icons
        DrawWeaponScope();        // Draw Scroll Zoom Text

        // Draw Function
        if(pbweap.akimboMode) 
            PBX_DrawImage(DRAW_WEAPON_ICON,true); // Draw an extra icon behind the weapon if in dual wield
        PBX_DrawImage(DRAW_WEAPON_ICON);

        // Dont draw the Weapon Mode if its disabled
        if(CheckFlag(DisablePBX_WeaponModeHud)) return;
        if(pbx_image2 != "") 
            PBX_DrawImage(DRAW_MODE_ICON);
        if(pbx_image3 != "") 
            PBX_DrawImage(DRAW_MODE2_ICON);
    }

    private
    ui void DrawWeaponScope()
    {
        let weap = PBX_WeaponBase(pbWeap);
        if(!weap || !weap.IsScopedWeapon() || !mo || !mo.FindInventory("Zoomed")) return;

        int hudX = 150;
        
        phud.PBHud_DrawString(phud.mDefaultFont,"Zoom In:",(hudX, -100), BaseStatusBar.DI_SCREEN_LEFT_CENTER | BaseStatusBar.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
        phud.PBHud_DrawString(
            phud.mDefaultFont, 
            (string.format(StringTable.Localize("$PBX_Weapons_ZoomScroll_Up"), PB_HelpNotificationsHandler.PB_FormatKeybinds("pbx_zoomin"))), 
            (hudX, -85), 
            BaseStatusBar.DI_SCREEN_LEFT_CENTER | BaseStatusBar.DI_TEXT_ALIGN_LEFT, 
            Font.CR_WHITE
        );

        phud.PBHud_DrawString(phud.mDefaultFont,"Zoom Out:",(hudX, 85), BaseStatusBar.DI_SCREEN_LEFT_CENTER | BaseStatusBar.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
        phud.PBHud_DrawString(
            phud.mDefaultFont, 
            (string.format(StringTable.Localize("$PBX_Weapons_ZoomScroll_Down"), PB_HelpNotificationsHandler.PB_FormatKeybinds("pbx_zoomout"))), 
            (hudX, 100), 
            BaseStatusBar.DI_SCREEN_LEFT_CENTER | BaseStatusBar.DI_TEXT_ALIGN_LEFT, 
            Font.CR_WHITE
        );
    }

    private
    ui void DrawWeaponOverlays()
    {
        pbx_visorOffsets = phud.visorOffsets;
        pbx_m32to0 = phud.m32to0;
        topOffsets1 = ((-HUD_SIDE_OVERLAY - pbx_visorOffsets) + (-pbx_m32to0), -HUD_SIDE_OVERLAY - pbx_visorOffsets - pbx_m32to0);
        topOffsets2 = ((HUD_SIDE_OVERLAY + pbx_visorOffsets) + (pbx_m32to0), -HUD_SIDE_OVERLAY - pbx_visorOffsets - pbx_m32to0);
        flagsManualVisor1 = BaseStatusBar.DI_ITEM_LEFT | BaseStatusBar.DI_SCREEN_LEFT | BaseStatusBar.DI_ITEM_VCENTER | BaseStatusBar.DI_SCREEN_VCENTER;
        flagsManualVisor2 = BaseStatusBar.DI_ITEM_RIGHT | BaseStatusBar.DI_SCREEN_RIGHT | BaseStatusBar.DI_MIRROR | BaseStatusBar.DI_ITEM_VCENTER | BaseStatusBar.DI_SCREEN_VCENTER;

        switch(pbWeap.GetClassName())
        {
            // Draw bars and effects for specific modes
            case 'PBX_MetalSniper':
                let sniper = PBX_MetalSniper(pbWeap); if(!sniper) return;
                // This draws the overlay when the smart scope is enabled
                if (sniper.enableScopeHUD)
                {
                    // Draw
					phud.PBHud_DrawImageManualAlpha("NIGHTVIS", (topOffsets1.x, 0), flagsManualVisor1, 0.5 + 0.5 * abs(sin(level.MapTime)), scale: (0.3, 0.3), parallax: 1.5, parallax2: 1.5);
					phud.PBHud_DrawImageManualAlpha("NIGHTVIS", (topOffsets2.x, 0), flagsManualVisor2, 0.5 + 0.5 * abs(sin(level.MapTime)), scale: (0.3, 0.3), parallax: 1.5, parallax2: 1.5);
                }
                break;

        }

        // So the overlay is always there even if you switch weapon
        let snip = PBX_XM21(mo.FindInventory("PBX_XM21")); if(!snip) return;
        if (snip.mCloakEngaged)
        {
            // Draw
            phud.PBHud_DrawImageManualAlpha("RADSUIT", (topOffsets1.x, 0), flagsManualVisor1, 0.5 + 0.5 * abs(sin(level.MapTime)), scale: (0.3, 0.3), parallax: 1.5, parallax2: 1.5);
            phud.PBHud_DrawImageManualAlpha("RADSUIT", (topOffsets2.x, 0), flagsManualVisor2, 0.5 + 0.5 * abs(sin(level.MapTime)), scale: (0.3, 0.3), parallax: 1.5, parallax2: 1.5);
        }
    }

    // Automatically get weapon icons
    private
    ui void GetWeaponDataAuto()
    {
        // Dont draw if SkipAutoDraw is true
        let ext = GetExternalHUD(pbWeap);
        if (ext && ext.SkipAutoDraw) return;

        // Add exceptions here
        static const string exceptionWeapons[] = {
            // Slot 2
            "PB_Pistol"
            ,"PB_SMG"
            ,"PBX_Prosurv_LeverAction"
            ,"PBX_Shotvolver"
            ,"PBX_MP5"
            ,"PBX_RevolverEdited"
            ,"PBX_DeagleEdited"
            ,"PBX_44PDW"

            // Slot 3
            ,"PB_Shotgun"
            ,"PB_Autoshotgun"
            ,"PB_QuadSG"
            ,"PBX_ProSurvPSG"

            // Slot 4
            ,"PB_DMR"
            ,"PB_ChexRifle"
            ,"PBX_BDPBattleRifle"
            ,"PBX_MetalSniper"
            ,"PBX_NormalRifle"
            ,"PBX_XM21"
            ,"PBX_LMGEdited"

            // Slot 5
            ,"PB_Minigun"

            // Slot 6
            ,"PBX_MastermindChaingun"
            ,"PBX_SGLEdited"

            // Slot 7
            ,"PB_M2Plasma"
            ,"PBX_BDPRailgun"

            // Slot 8
            ,"PB_Flamethrower"
            ,"PB_CryoRifle"

            // Slot 9
            ,"PB_BFG9000"
            ,"PB_Unmaker"
        };

        // Handle exceptions
        string weaponClass = pbWeap.GetClassName();
        for (int i = 0; i < exceptionWeapons.Size(); i++)
        {
            if (weaponClass == exceptionWeapons[i]) return; // do not draw HUD for these weapons
        }

        // Use default Icons
        TextureID iconID = pbWeap.AltHudIcon.IsValid() ? pbWeap.AltHudIcon : pbWeap.Icon;
        pbx_image = TexMan.GetName(iconID);

    }

    private
    ui void GetWeaponCVARs()
    {
        // Weapon Pickup Sprites
        pbx_weapon_PosX         = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_X", plr).GetInt();
        pbx_weapon_PosY         = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_Y", plr).GetInt();
        pbx_weapon_hudscale     = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_SCALE", plr).GetFloat();
        pbx_weapon_alpha        = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_ALPHA", plr).GetFloat();
        pbx_weapon_boxW         = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_BOX_W", plr).GetInt();
        pbx_weapon_boxH         = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_BOX_H", plr).GetInt();

        pbx_weapon_pos          = (pbx_weapon_PosX, pbx_weapon_PosY);
        pbx_weapon_truescale    = (pbx_weapon_hudscale, pbx_weapon_hudscale);
        pbx_weapon_box1         = (pbx_weapon_boxW, pbx_weapon_boxH);

        // Weapon Modes
        pbx_weaponmode_PosX     = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_MODE_HUD_X", plr).GetInt();
        pbx_weaponmode_PosY     = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_MODE_HUD_Y", plr).GetInt();
        pbx_weaponmode_hudscale = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_MODE_HUD_SCALE", plr).GetFloat();
        pbx_weaponmode_alpha    = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_MODE_HUD_ALPHA", plr).GetFloat();
        pbx_weaponmode_boxW     = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_MODE_HUD_BOX_W", plr).GetInt();
        pbx_weaponmode_boxH     = CVar.GetCVar("PBX_CVAR_HUD_WEAPON_MODE_HUD_BOX_H", plr).GetInt();

        pbx_weapon_pos2         = (pbx_weaponmode_PosX, pbx_weaponmode_PosY);
        pbx_weapon_truescale2   = (pbx_weaponmode_hudscale, pbx_weaponmode_hudscale);
        pbx_weapon_box2         = (pbx_weaponmode_boxW, pbx_weaponmode_boxH);

        // Special cases where weapons uses two modes at the same time
        pbx_weapon_pos3         = pbx_weapon_pos2 + (0,-10);
        pbx_weapon_truescale3   = pbx_weapon_truescale2;
        pbx_weapon_box3         = (pbx_weaponmode_boxW, pbx_weaponmode_boxH);

        // Flags
        flagsright              = BaseStatusBar.DI_SCREEN_RIGHT_BOTTOM | BaseStatusBar.DI_ITEM_RIGHT_BOTTOM;
        flagsleft               = BaseStatusBar.DI_SCREEN_LEFT_BOTTOM | BaseStatusBar.DI_ITEM_LEFT_BOTTOM;
        flagsLeftCenter         = BaseStatusBar.DI_SCREEN_LEFT_BOTTOM | BaseStatusBar.DI_ITEM_CENTER;

        // Others
        akimboPosition          = (AKIMBO_POSITION_X,AKIMBO_POSITION_Y);
        powerupPosition         = (POWERUP_POSITION_X,POWERUP_POSITION_Y);
    }

    private
    ui void GetWeaponData()
    {
        // Set Defaults & Variables
        TextureID iconID = pbWeap.AltHudIcon.IsValid() ? pbWeap.AltHudIcon : pbWeap.Icon;
        string icon = TexMan.GetName(iconID);
        vector2 adjustPos,adjustPos2, adjustPos3 = (0,0);
        double adjustScale  = 1.0;
        double adjustScale2 = 1.0;
        double adjustScale3 = 1.0;
        isAkimbo            = pbWeap.akimboMode;

        switch(pbWeap.GetClassName())
        {
//////////////// SLOT 1 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PB_Fists':
                adjustPos = (-15, 20);
                adjustScale = 0.6;
                break;

            case 'PB_Chainsaw':
                adjustPos = (-20, 32);
                break;

            case 'PB_Axe':
                adjustPos = (-30, 40);
                break;

            case 'PBX_ChainsawEdited':
            {
                let saw = PBX_ChainsawEditedBase(pbWeap);
                if(!saw) return;

                // Draw the resouce gather icon
                if(saw.mChainsawLifesteal)
                {
                    phud.PBHud_DrawImage("CHAINHL", (-90, -44), BaseStatusBar.DI_SCREEN_RIGHT_BOTTOM, 1, (32, 32));
                }

                if(saw.mChainsawAlt == PBX_ChainsawEditedBase.SELECT_QUICKSSG && saw.ptrSSG && !mo.FindInventory("PB_QuadSG"))
                {
                    PBX_DrawAmmoBar(
                        DRAW_SECOND_BAR,
                        "BARBACO2",
                        "ABAR3",
                        "PB_SSGMag",
                        Font.FindFontColor("Orange")
                    );
                }

                adjustPos   = (-20, 32);
                adjustScale = 0.8;

                if(saw.mChainsawAlt == PBX_ChainsawEditedBase.SELECT_QUICKSSG && saw.ptrSSG && !PBX_PlayerHasInventory("PB_QuadSG"))
                    adjustPos.y -= 20;

                switch(saw.mChainsawAlt)
                {
                    case PBX_ChainsawEditedBase.SELECT_SLASH:    pbx_image2 = "chnslsh"; break;
                    case PBX_ChainsawEditedBase.SELECT_THROW:    pbx_image2 = "chnthrw"; break;
                    case PBX_ChainsawEditedBase.SELECT_QUICKSSG: pbx_image2 = "chnssg";  break;
                }
                break;
            }

//////////////// SLOT 2 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PB_MP40':
                adjustPos = isAkimbo ? (-5, -10) : (-8,10);
                adjustScale = 0.7;
                break;

            case 'PB_SMG':
                let smg = PB_SMG(pbWeap);
                if(!smg) return;

                pbx_image = "ATFLB0";

                adjustPos = (10,14); // Single ? Silenced : Not Silenced
                adjustScale = 0.9;

                if(smg.hasSilencer)
                {
                    pbx_image = "ATFLA0";
                    adjustPos.x -= 23;
                }
                break;

            case 'PB_Pistol':
                let pistol = PB_Pistol(pbWeap);
                if(!pistol) return;

                pbx_image = "graphics/pywheel/PISTOL_0.png";

                adjustPos = (18,18);
                adjustScale = 1.1;

                if(pistol.hasSilencer)
                {
                    pbx_image = "graphics/pywheel/PISTOL_1.png";
                    adjustPos.x -= 20;
                }
                break;

            case 'PB_Revolver':
                adjustPos = (-20, 12);
                if(isAkimbo)
                    adjustPos.y -= 6;
                break;

            case 'PB_Deagle':
                adjustPos = (-30, 13);
                adjustScale = 1.1;
                break;

            case 'PBX_PlasmaBlaster':
                adjustPos   = (-22, 12);
                adjustScale = 2.0;
                break;

            case 'PBX_ProsurvBlaster':
                adjustPos   = (-30, 30);
                break;

            case 'PBX_Prosurv_LeverAction':
            {
                let lar = PBX_Prosurv_LeverAction(pbWeap);
                if(!lar) return;

                bool laserOn = lar.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."LeverAction/LaserOn.png" : IMAGE_DIRECTORY.."LeverAction/LaserOff.png";
                adjustPos   = laserOn ? (0, 18) : (-10, 18);
                adjustScale = laserOn ? 0.6 : 0.7;
                break;
            }

            case 'PBX_Shotvolver':
                pbx_image   = "REVPB0";
                adjustPos   = (-15, 15);
                adjustScale = 1.5;
                break;

            case 'PBX_MP5':
            {
                let mp5 = PBX_MP5(pbWeap);
                if(!mp5) return;

                bool laserOn = mp5.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."MP5/LaserOn.png" : IMAGE_DIRECTORY.."MP5/LaserOff.png";
                adjustPos   = laserOn ? (0, 10) : (-20, 10);
                adjustScale = laserOn ? 0.7 : 1.2;
                break;
            }

            case 'PBX_RevolverEdited':
            {
                let rev = PBX_RevolverEdited(pbWeap);
                if(!rev) return;

                bool laserOn = rev.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."RevolverEdit/laseron.png" : IMAGE_DIRECTORY.."RevolverEdit/laseroff.png";
                adjustPos   = laserOn ? (0, 12) : (-20, 12);

                if(rev.akimboMode)
                    adjustPos.y -= 6;

                // Coin
                if(rev.mCoinSecondary)
                    pbx_image2 = rev.mCoinCooldown > 0 ? "nocoinhd" : "coinhud";
                adjustPos2 = (0, -10);
                break;
            }

            case 'PBX_DeagleEdited':
            {
                let deag = PBX_DeagleEdited(pbWeap);
                if(!deag) return;

                bool laserOn = deag.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."DeagleEdit/laseron.png" : IMAGE_DIRECTORY.."DeagleEdit/laseroff.png";
                adjustPos   = laserOn ? (-15, 13) : (-30, 13);

                if(deag.akimboMode)
                    adjustPos.y -= 6;

                // Coin
                if(deag.mCoinSecondary)
                    pbx_image2 = deag.mCoinCooldown > 0 ? "nocoinhd" : "coinhud";
                adjustPos2 = (0, -10);
                break;
            }

            case 'PBX_44PDW':
            {
                let pdw = PBX_44PDW(pbWeap);
                if(!pdw) return;

                bool laserOn = pdw.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."44PDW/LaserOn.png" : IMAGE_DIRECTORY.."44PDW/LaserOff.png";
                adjustPos   = laserOn ? (0, 10) : (-20, 10);
                adjustScale = laserOn ? 1.0 : 2.0;
                break;
            }

//////////////// SLOT 3 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PB_Shotgun':
                let shotgun = PB_Shotgun(pbWeap);
                if(!shotgun) return;

                bool shotgunUpgraded = PBX_PlayerHasInventory("PumpshotgunMagazine");

                switch(shotgun.shellsmode)
                {
                    case PB_Shotgun.Shell_Buck:
                        pbx_image2 = "buckhud";
                        break;
                    case PB_Shotgun.Shell_Slug:
                        pbx_image2 = "slughud";
                        break;
                    case PB_Shotgun.Shell_Drag:
                        pbx_image2 = "drgnhud";
                        break;
                }

                pbx_image = shotgunUpgraded ? "9SMUA0" : icon;

                adjustPos = (-5, 10);
                break;

            case 'PB_Autoshotgun':
                bool asgUpgraded = PBX_PlayerHasInventory("AutoshotgunDrumMag");

                pbx_image = icon;

                adjustPos = (-9,15);

                // If upgraded then use the upgraded icon
                // and move up a bit
                if(asgUpgraded)
                {
                    pbx_image = "A9SCA0";
                    adjustPos.y -= isAkimbo ? 6 : 1;
                }
                break;

            case 'PB_SSG':
                adjustPos = (-20,13);
                break;

            case 'PB_QuadSG':
                bool quadFullBlast = PBX_PlayerHasInventory("FullBlastMode");
                bool demonBreath = PBX_PlayerHasInventory("BreathMode");

                pbx_image = "QSPGA0";
                pbx_image2 = quadFullBlast ? "graphics/WeaponIcons/QUAD_FULL.png" : "graphics/WeaponIcons/QUAD_HALF.png";

                adjustPos = (0,10);
                // MODE
                adjustPos2 = (0,-20);
                adjustScale2 = 0.2;

                if(demonBreath)
                {
                    pbx_image = "graphics/pywheel/Quad_Demonic.png";
                    adjustPos = (1,12);
                }
                break;

            case 'PBX_CSSG':
            {
                let cssg = PBX_CSSG(pbWeap);
                if(!cssg) return;

                static const string cssgIcons[] = {
                    "buckhud", "slughud", "flcthud",
                    "flakhud", "drgnhud", "explhud",
                    "phoshud", "doomhud", "dnmkhud",
                    "subzhud", "helfhud", "acshhud"
                };

                pbx_image2  = cssgIcons[clamp(cssg.shellsmode, 0, cssgIcons.Size() - 1)];
                adjustPos   = (-5, 12);
                adjustScale = 0.9;
                break;
            }

            case 'PBX_ProSurvPSG':
            {
                let psg = PBX_ProSurvPSG(pbWeap);
                if(!psg) return;

                // Draw rocket ammo
                PBX_DrawAmmoBar(
                    DRAW_THIRD_BAR,
                    "BARBACR3",
                    "ABAR4",
                    "PB_RocketAmmo",
                    Font.CR_RED
                );

                bool laserOn = psg.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."ProsurvPSG/LaserOn.png" : IMAGE_DIRECTORY.."ProsurvPSG/LaserOff.png";
                adjustPos   = laserOn ? (13, -9) : (-5, -7);
                adjustScale = laserOn ? 0.8 : 1.1;
                break;
            }

            case 'PBX_SPAS12':
            {
                let spas12 = PBX_SPAS12(pbWeap);
                if(!spas12) return;

                pbx_image2  = spas12.mSemiAuto ? "buckhud" : "slughud";
                adjustPos   = (-10, 10);
                adjustScale = 0.65;
                break;
            }

            case 'PBX_CryoSG':
                adjustPos   = (-15, 15);
                adjustScale = 1.35;
                break;

            case 'PBX_CryoASG':
                adjustPos   = (-15, 12);
                adjustScale = 1.5;
                break;

//////////////// SLOT 4 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PB_DMR':
                bool dmrUpgraded    = PBX_PlayerHasInventory("DMRUpgraded");
                bool hdmrSniperMode = PBX_PlayerHasInventory("HDMRSniperMode");
                bool hdmrGrenMode   = PBX_PlayerHasInventory("HDMRGrenadeMode");

                pbx_image  = icon; // Because its in the exception list we need to set the default icon

                adjustPos   = (-5,12);
                adjustScale = dmrUpgraded ? 0.8 : 0.9;

                if(dmrUpgraded)
                {
                    pbx_image = hdmrSniperMode  ? "Graphics/WeaponIcons/HDMR_SNIPER.png" : "HIFLA0";
                    adjustPos = hdmrSniperMode  ? (-6,10) : (-4,10);
                }
                break;

            case 'PB_Carbine':
                adjustPos = (-10,15);
                adjustScale = 1.2;
                break;

            case 'PB_LMG':
                pbx_image = "LMPIA0";
                adjustPos = (3, 23);
                adjustScale = 0.8;
                break;

            case 'PB_ChexRifle':
                pbx_image = "CRRSA0";
                adjustPos = (-10, 13);
                adjustScale = 0.9;
                break;

            case 'PBX_BDPBattleRifle':
            {
                let br = PBX_BDPBattleRifle(pbWeap);
                if(!br) return;

                bool laserOn = br.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."BattleRifle/LaserOn.png" : IMAGE_DIRECTORY.."BattleRifle/LaserOff.png";
                adjustPos   = laserOn ? (0, 12) : (-7, 12);
                adjustScale = laserOn ? 0.7 : 1.3;
                break;
            }

            case 'PBX_MetalSniper':
            {
                let sniper = PBX_MetalSniper(pbWeap);
                if(!sniper) return;

                // Show Rocket Ammo if Grenade Secondary Mode is Selected
                if (sniper.AltMode) 
                {
                    PBX_DrawAmmoBar(
                        DRAW_THIRD_BAR,
                        "BARBACR3",
                        "ABAR4",
                        "PB_RocketAmmo",
                        Font.CR_RED
                    );
                }

                bool sniperLaser = sniper.GetLaserActive();
                pbx_image  = sniperLaser ? IMAGE_DIRECTORY.."MetalSniper/LaserOn.png" : IMAGE_DIRECTORY.."MetalSniper/LaserOff.png";
                pbx_image2 = sniper.resonanceAmmoLoaded ? IMAGE_DIRECTORY.."metalsniper/ResonanceAlt.png" : IMAGE_DIRECTORY.."metalsniper/StandardAlt.png";

                adjustPos    = sniperLaser ? (0, 10) : (0, 14);
                adjustScale2 = 0.7;
                if(sniper.AltMode)
                    adjustPos.y -= 19;
                break;
            }

            case 'PBX_Prosurv_Ballista':
                adjustPos   = (-10, 10);
                break;

            case 'PBX_NormalRifle':
            {
                let nr = PBX_NormalRifle(pbWeap);
                if(!nr) return;

                bool laserOn = nr.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."NormalRifle/laseron.png" : IMAGE_DIRECTORY.."NormalRifle/laseroff.png";
                adjustPos   = laserOn ? (0, 8) : (-5, 8);
                adjustScale = laserOn ? 0.8 : 0.9;
                break;
            }

            case 'PBX_XM21':
            {
                let xm21 = PBX_XM21(pbWeap);
                if(!xm21) return;

                // Show Cloak Energy
                PBX_DrawAmmoBar(
                    DRAW_THIRD_BAR,
                    "BARBACC3",
                    "ABAR8",
                    "CloakEnergy",
                    Font.CR_CYAN
                );

                bool laserOn = xm21.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."XM21/LaserOn.png" : IMAGE_DIRECTORY.."XM21/LaserOff.png";
                adjustPos   = laserOn ? (0, -12) : (-7, -12);
                adjustScale = laserOn ? 0.7 : 1.3;
                break;
            }

            case 'PBX_LMGEdited':
                pbx_image   = PBX_PlayerHasInventory("LMGUpgraded") ? "LMPUA0" : "LMPIA0";
                adjustPos   = (3, 23);
                adjustScale = 0.8;
                break;

//////////////// SLOT 5 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PB_MG42':
                adjustPos = (-10, 32);
                adjustScale = 0.5;
                break;

            case 'PB_Minigun':
                let minigun = PB_Minigun(pbWeap);
                if(!minigun) return;

                switch(minigun.mode)
                {
                    case PB_Minigun.CHAINGUN_MODE:
                    case PB_Minigun.GATLING_MODE:
                        pbx_image       = icon;
                        pbx_image2      = minigun.mode == PB_Minigun.CHAINGUN_MODE ? "graphics/WeaponIcons/NORMALSPEED.png" : "graphics/WeaponIcons/HIGHSPEED.png";
                        adjustPos       = (-15,32);
                        adjustPos2      = (0, 0);
                        adjustScale2    = 0.9;
                        break;
                    case PB_Minigun.TRIPLE_MODE:
                        pbx_image       = "8GUNA0";
                        pbx_image2      = "graphics/WeaponIcons/EXTREMELYHIHGSPID.png";
                        adjustPos       = (-20,32);
                        adjustPos2      = (-3, 0);
                        adjustScale2    = 0.5;
                        break;
                }
                break;

            case 'PB_Nailgun':
                adjustPos = (-9,12);
                break;

            case 'PBX_NeoHMG':
            {
                let hmg = PBX_NeoHMG(pbWeap);
                if(!hmg) return;

                // Draw bar for the shield durability
                PBX_DrawAmmoBar(
                    DRAW_THIRD_BAR,
                    "BARBASH3",
                    "ABAR9",
                    "HMGShield",
                    Font.CR_GREEN
                );

                bool shld        = hmg.mShieldIsReady && mo && mo.CountInv("HMGShield") > 0;
                bool hmgOverheat = hmg.overheat >= PBX_NeoHMG.OVERHEAT_THRESHOLD;

                pbx_image2  = shld ? "shldhud" : "shldhudn";
                pbx_image3  = hmgOverheat ? "ovrheatd" : "noovrhtd";
                adjustPos   = (-3, -3);
                adjustPos3  = (0, -50);
                adjustScale = 1.6;
                break;
            }

            case 'PBX_EternalMinigun':
                adjustPos   = (-20, 35);
                adjustScale = 1.5;
                break;

            case 'PBX_SuperNailgun':
            {
                let sng = PBX_SuperNailgun(pbWeap);
                if(!sng) return;

                bool sngOverheat = sng.overheat >= PBX_SuperNailgun.OVERHEAT_THRESHOLD;

                pbx_image2  = sng.mChargedNailsMode ? "sngchrg" : "sngheat";
                pbx_image3  = sngOverheat ? "ovrheatd" : "noovrhtd";
                adjustPos   = (-2, 16);
                adjustPos3  = (0, -50);
                adjustScale = 0.7;
                break;
            }

//////////////// SLOT 6 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PB_RocketLauncher':
                name rocketmode;
                // WHY IS THE ROCKETLAUNCHER MODE SWITCH SO JANK
                // WHAT DO YOU MEAN ITS A STRING
                if(pbweap)
                {
                    if(pbweap.rocketLauncherMode == "Standard")
                        rocketmode = "graphics/pywheel/rocket_standard.png";
                    else if (pbweap.rocketLauncherMode == "Homing")
                        rocketmode = "graphics/pywheel/rocket_homing.png";
                    else if (pbweap.rocketLauncherMode == "Laser")
                        rocketmode = "graphics/pywheel/rocket_laser.png";
                }

                pbx_image2 = rocketmode;

                adjustPos = (-8 , 15);
                adjustScale = 0.9;

                adjustPos2 = (0,-20);
                adjustScale2 = 0.3;
                break;

            case 'PBX_SGLEdited':
            {
                let sgl = PB_SuperGL(pbWeap);
                if(!sgl) return;

                static const string sglIcons[] = {
                    "graphics/pywheel/grenade_impact.png", "graphics/pywheel/grenade_sticky.png",
                    "graphics/pywheel/grenade_acid.png", "graphics/pywheel/grenade_incendiary.png",
                    "graphics/pywheel/grenade_cryo.png"
                };

                pbx_image2 = sglIcons[clamp(sgl.GrenadeMode, 0, sglIcons.Size() - 1)];

                adjustPos = (-5, 13);
                adjustScale = 0.9;

                adjustPos2 = (3,-18);
                adjustScale2 = 0.3;

                pbx_image = PBX_PlayerHasInventory("SGLUpgraded") ? "BSGLA0" : "SGL0Z0";
                break;
            }

            case 'PBX_CyberdemonRL':
            {
                let crl = PBX_CyberdemonRL(pbWeap);
                if(!crl) return;

                // Draw the durability bar
                PBX_DrawAmmoBar(
                    DRAW_SECOND_BAR,
                    "BARBADD2",
                    "ABAR10",
                    "CyberRLDurability",
                    Font.CR_DARKGRAY
                );

                pbx_image2  = crl.mLaserMode ? "cybrllas" : "trplhud";
                adjustPos   = (-12, 12);
                adjustScale = 1.6;
                break;
            }

            case 'PBX_MastermindChaingun':
                // Draw the durability bar
                PBX_DrawAmmoBar(
                    DRAW_SECOND_BAR,
                    "BARBADD2",
                    "ABAR10",
                    "MastermindCGDurability",
                    Font.CR_DARKGRAY
                );

                pbx_image   = "RMN1H0";
                adjustPos   = (-10, 40);
                adjustScale = 1.6;
                break;

            case 'PBX_Excavator':
                adjustPos   = (-10, 15);
                adjustScale = 1.1;
                break;

            case 'PBX_Paingiver':
                let pngv = PBX_Paingiver(pbWeap); 
                if(!pngv) return;

                // Show Fuel if Demonic Mode, Show Rocket if Standard Mode
                bool enraged = pngv.enragedState;
                
                PBX_DrawAmmoBar(
                    DRAW_SECOND_BAR,
                    enraged ? "BARBACZ2" : "BARBASC2",
                    enraged ? "ABAR7"    : "ABAR11",
                    "SoulCharge",
                    enraged ? Font.FindFontColor("PB_DTech")  : Font.CR_DARKRED
                );
                
                adjustPos   = (-10, 15);
                adjustScale = 1.3;
                break;

//////////////// SLOT 7 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PB_M1Plasma':
                adjustPos = (-10,12);
                break;

            case 'PB_M2Plasma':
                bool m2Upgraded = PBX_PlayerHasInventory("HasLightningGunUpgrade");

                pbx_image = m2Upgraded ? "M2PRB0" : icon;

                adjustPos = (-10,15);
                adjustScale = 0.9;
                break;

            case 'PB_DTechRifle':
                adjustPos = (-5, 15);
                adjustScale = 0.9;
                break;

            case 'PBX_BDPRailgun':
            {
                let railgun = PBX_BDPRailgun(pbWeap);
                if(!railgun) return;

                bool laserOn = railgun.GetLaserActive();
                pbx_image   = laserOn ? IMAGE_DIRECTORY.."PlatRailgun/LaserOn.png" : IMAGE_DIRECTORY.."PlatRailgun/LaserOff.png";
                adjustPos   = laserOn ? (0, 12) : (-5, 12);
                adjustScale = laserOn ? 0.7 : 1.4;
                break;
            }

//////////////// SLOT 8 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PB_Flamethrower':
                bool flamerUpgraded = PBX_PlayerHasInventory("FlamerUpgraded");

                pbx_image = "FSPWA0";

                adjustPos = (-10,15);

                if(flamerUpgraded)
                {
                    pbx_image = "FSPWB0";
                    adjustPos = (-15, 40);
                }
                break;

            case 'PB_CryoRifle':
                let cryorifle = PB_CryoRifle(pbWeap);
                if(!cryorifle) return;

                bool cryoMissile = cryorifle.cryoPrimary   == cryorifle.PRIM_MISSILE;
                bool cryoSpear   = cryorifle.cryoSecondary == cryorifle.SEC_SPEAR;

                pbx_image  = "FRPKA0";
                pbx_image2 = cryoSpear   ? "graphics/pywheel/CryoRifle_Spear.png"   : "graphics/pywheel/CryoRifle_Flak.png";
                pbx_image3 = cryoMissile ? "graphics/pywheel/CryoRifle_Missile.png" : "graphics/pywheel/CryoRifle_Beam.png";

                adjustPos = (-5, 15);

                adjustPos2   = (0,-60);
                adjustScale2 = 0.3;

                adjustPos3   = (0,-10);
                adjustScale3 = 0.3;
                break;

            case 'PBX_TeslaGun':
                adjustPos   = (-10, 15);
                adjustScale = 2.0;
                break;

            case 'PBX_FreezeRifle':
                adjustPos   = (-15, 13);
                adjustScale = 1.2;
                break;

//////////////// SLOT 9 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PB_BFG9000':
                pbx_image = "097GA0";

                adjustPos = (-10,32);
                adjustScale = 0.8;
                break;

            case 'PB_Railgun':
                adjustPos = (-5,15);
                adjustScale = 0.8;
                break;

            case 'PB_Unmaker':
                pbx_image = "UNHDA0";

                adjustPos = (-5,15);
                adjustScale = 0.9;
                break;

            case 'PBX_DemonExt':
                adjustPos   = (-10, 10);
                adjustScale = 1.3;
                break;

            case 'PBX_NukeLauncher':
                adjustPos   = (25, 35);
                adjustScale = 1.5;
                break;

            case 'PBX_HexaShotgun':
                adjustPos   = (-25, 10);
                adjustScale = 1.7;
                break;

            case 'PBX_MiniShotgun':
                adjustPos   = (-25, 30);
                adjustScale = 1.7;
                break;

            case 'PBX_RipperChaingun':
                adjustPos   = (-25, 30);
                adjustScale = 1.2;
                break;

//////////////// OTHERS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            case 'PBX_RideableCaco':
                PBX_DrawAmmoBar(
                    DRAW_SECOND_BAR,
                    "BARBACC2",
                    "ABAR8",
                    "CacoHP",
                    Font.FindFontColor("HUDBLUEBAR")
                );

                adjustPos   = (-30, 20);
                adjustScale = 0.7;
                break;

            default:
                pbx_image       = "";
                pbx_image2      = "";
                pbx_image3      = "";
                adjustPos       = (0,0);
                adjustPos2      = (0,0);
                adjustPos3      = (0,0);
                adjustScale     = 1.0;
                adjustScale2    = 1.0;
                adjustScale3    = 1.0;
                break;
        }
        // Send the Values
        pbx_weapon_pos          += adjustPos;
        pbx_weapon_pos2         += adjustPos2;
        pbx_weapon_pos3         += adjustPos3;
        pbx_weapon_truescale    *= adjustScale;
        pbx_weapon_truescale2   *= adjustScale2;
        pbx_weapon_truescale3   *= adjustScale3;

        // If akimbo then put the icon higher regardless
        if(isAkimbo || hdmrGrenMode) // Edge case for the HDMR Grenade Mode
            pbx_weapon_pos.y += AKIMBO_POSITION_WHOLE;
    }

}