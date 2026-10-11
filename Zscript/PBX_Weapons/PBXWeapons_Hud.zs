// The Wheel for Scope Mode, Variable Zoom, and NVG Toggle uses these values for its scale
const WHEEL_ZOOM_SCALE       = 0.16;
const WHEEL_SCOPE_SCALE      = 0.16;
const WHEEL_NVG_SCALE        = 0.5;
const WHEEL_CLOSEMENU_SCALE  = 0.15;
// Used in this file and in PBXWeapons_BaseWeapons.zs
const IMAGE_DIRECTORY = "graphics/WeaponWheel/";

// Draw the ammo bar for some weapons
class PBXWeapons_HUDHandler : EventHandler
{
//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    ui int flagsManualVisor1, flagsManualVisor2;
    ui int8 pbx_m32to0;
    ui float pbx_visorOffsets;
    ui vector2 topOffsets1, topOffsets2;

    ui PlayerInfo plr;
    ui PlayerPawn mo;
    ui PB_Hud_ZS phud;
    ui PB_WeaponBase pbWeap;

    // The constants used for the overlays (the graphics you see at the side)
    const HUD_SIDE_OVERLAY = 24; 

//////////////////////////// MAIN FUNCTION ////////////////////////////////////////////////////////////////////////////////////
    override void RenderOverlay(RenderEvent e)
    {
        // Dont draw if the player is not in a leve or if the automap is active
        if (gamestate != GS_LEVEL || automapactive)
            return;

        // Get a pointer to the PB Hud so we can access it
        phud = PB_Hud_ZS(StatusBar);
        if (!phud) return;

        // Dont draw if the player is dead
        if (phud.hudState == BaseStatusBar.HUD_None || phud.PlayerWasDead) 
            return;

        // Get a pointer to the player and weapon
        plr = players[consoleplayer];
        mo = plr.mo;
        pbWeap = PB_WeaponBase(plr.ReadyWeapon);
        if (!plr || !mo || !pbWeap) return;

        // Begin drawing the HUD
        phud.BeginHUD();                    // Initialize
        PBXWeapons_DrawAmmoBar();
        PBXWeapons_DrawScope();

    }

    override void RenderUnderlay(RenderEvent e)
    {
        if (gamestate != GS_LEVEL || automapactive || !phud || !plr || !mo || !pbWeap || phud.hudState == BaseStatusBar.HUD_None || phud.PlayerWasDead)
            return;

        // These are used for the Overlays
        pbx_visorOffsets = phud.visorOffsets;
        pbx_m32to0 = phud.m32to0;
        topOffsets1 = ((-HUD_SIDE_OVERLAY - pbx_visorOffsets) + (-pbx_m32to0), -HUD_SIDE_OVERLAY - pbx_visorOffsets - pbx_m32to0);
        topOffsets2 = ((HUD_SIDE_OVERLAY + pbx_visorOffsets) + (pbx_m32to0), -HUD_SIDE_OVERLAY - pbx_visorOffsets - pbx_m32to0);
        flagsManualVisor1 = BaseStatusBar.DI_ITEM_LEFT | BaseStatusBar.DI_SCREEN_LEFT | BaseStatusBar.DI_ITEM_VCENTER | BaseStatusBar.DI_SCREEN_VCENTER;
        flagsManualVisor2 = BaseStatusBar.DI_ITEM_RIGHT | BaseStatusBar.DI_SCREEN_RIGHT | BaseStatusBar.DI_MIRROR | BaseStatusBar.DI_ITEM_VCENTER | BaseStatusBar.DI_SCREEN_VCENTER;

        phud.BeginHUD();                    // Initialize
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

            // Draw bars and effects
            // case 'PBX_XM21':
            //     let snp = PBX_XM21(pbWeap); if(!snp) return;
            //     // This draws the overlay when the cloak is active
            //     if (snp.mCloakEngaged)
            //     {
            //         // Draw
			// 		phud.PBHud_DrawImageManualAlpha("RADSUIT", (topOffsets1.x, 0), flagsManualVisor1, 0.5 + 0.5 * abs(sin(level.MapTime)), scale: (0.3, 0.3), parallax: 1.5, parallax2: 1.5);
			// 		phud.PBHud_DrawImageManualAlpha("RADSUIT", (topOffsets2.x, 0), flagsManualVisor2, 0.5 + 0.5 * abs(sin(level.MapTime)), scale: (0.3, 0.3), parallax: 1.5, parallax2: 1.5);
            //     }
            //     break;
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


    private
    ui void PBXWeapons_DrawScope()
    {
        let weap = PBX_WeaponBase(pbWeap);
        if(!weap || !weap.IsScopedWeapon() || !mo || !mo.FindInventory("Zoomed")) return;

        int hudX = 150;
        phud.PBHud_DrawString(phud.mDefaultFont,"Zoom In:",(hudX, -100), BaseStatusBar.DI_SCREEN_LEFT_CENTER | BaseStatusBar.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
        phud.PBHud_DrawString(
            phud.mDefaultFont, 
            (string.format(StringTable.Localize("$PBXWeapons_ZoomScroll_Up"), PB_HelpNotificationsHandler.PB_FormatKeybinds("pbx_zoomin"))), 
            (hudX, -85), 
            BaseStatusBar.DI_SCREEN_LEFT_CENTER | BaseStatusBar.DI_TEXT_ALIGN_LEFT, 
            Font.CR_WHITE
        );

        phud.PBHud_DrawString(phud.mDefaultFont,"Zoom Out:",(hudX, 85), BaseStatusBar.DI_SCREEN_LEFT_CENTER | BaseStatusBar.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
        phud.PBHud_DrawString(
            phud.mDefaultFont, 
            (string.format(StringTable.Localize("$PBXWeapons_ZoomScroll_Down"), PB_HelpNotificationsHandler.PB_FormatKeybinds("pbx_zoomout"))), 
            (hudX, 100), 
            BaseStatusBar.DI_SCREEN_LEFT_CENTER | BaseStatusBar.DI_TEXT_ALIGN_LEFT, 
            Font.CR_WHITE
        );
    }

    private
    ui void PBXWeapons_DrawAmmoBar()
    {
        if(!pbWeap || !phud || !plr || !mo) return;
        switch(pbWeap.GetClassName())
        {
            // Draw bars and effects for specific modes
            case 'PBX_MetalSniper':
            {
                let sniper = PBX_MetalSniper(pbWeap);
                if(!sniper) return;
                
                // Show Rocket Ammo if Grenade Secondary Mode is Selected
                if (sniper.AltMode) 
                PBXCore_HUDHandler.PBX_DrawAmmoBar(
                    phud,
                    PBXCore_HUDHandler.
                    DRAW_THIRD_BAR,
                    "BARBACR3",
                    "ABAR4",
                    "PB_RocketAmmo",
                    Font.CR_RED
                );
            }
            break;

            // Draw bars and effects
            case 'PBX_XM21':
            {

                let snp = PBX_XM21(pbWeap);
                if(!snp) return;
                
                // Show Cloak Energy
                PBXCore_HUDHandler.PBX_DrawAmmoBar(
                    phud,
                    PBXCore_HUDHandler.
                    DRAW_THIRD_BAR,
                    "BARBACC3",
                    "ABAR8",
                    "CloakEnergy",
                    Font.CR_CYAN
                );
            }
            break;
                
            // Draw bar for the shield durability
            case 'PBX_NeoHMG':
            {
                PBXCore_HUDHandler.PBX_DrawAmmoBar(
                    phud,
                    PBXCore_HUDHandler.DRAW_THIRD_BAR,
                    "BARBASH3",
                    "ABAR9",
                    "HMGShield",
                    Font.CR_GREEN
                );
            }
            break;

            // Draw rocket ammo
            case 'PBX_ProSurvPSG':
            {
                PBXCore_HUDHandler.PBX_DrawAmmoBar(
                    phud,
                    PBXCore_HUDHandler.DRAW_THIRD_BAR,
                    "BARBACR3",
                    "ABAR4",
                    "PB_RocketAmmo",
                    Font.CR_RED
                );
            }
            break;

            // Draw the durability bar
            case 'PBX_CyberdemonRL':
            {
                PBXCore_HUDHandler.PBX_DrawAmmoBar(
                    phud,
                    PBXCore_HUDHandler.DRAW_SECOND_BAR,
                    "BARBADD2",
                    "ABAR10",
                    "CyberRLDurability",
                    Font.CR_DARKGRAY
                );
                break;
            }

            case 'PBX_MastermindChaingun':
            {
                PBXCore_HUDHandler.PBX_DrawAmmoBar(
                    phud,
                    PBXCore_HUDHandler.DRAW_SECOND_BAR,
                    "BARBADD2",
                    "ABAR10",
                    "MastermindCGDurability",
                    Font.CR_DARKGRAY
                );
                break;
            }

            // Draw enraged bar
            case 'PBX_Paingiver':
            {
                let pngv = PBX_Paingiver(pbWeap); if(!pngv) return;
                
                // Show Fuel if Demonic Mode, Show Rocket if Standard Mode
                bool enraged = pngv.enragedState;
                
                PBXCore_HUDHandler.PBX_DrawAmmoBar(
                    phud,
                    PBXCore_HUDHandler.DRAW_SECOND_BAR,
                    enraged ? "BARBACZ2"                      : "BARBASC2",
                    enraged ? "ABAR7"                         : "ABAR11",
                    "SoulCharge",
                    enraged ? Font.FindFontColor("PB_DTech")  : Font.CR_DARKRED
                );
            }
            break;

            // Draw lightning charge bar
            case 'PBX_TeslaGun':
            {
                PBXCore_HUDHandler.PBX_DrawAmmoBar(
                    phud,
                    PBXCore_HUDHandler.DRAW_THIRD_BAR,
                    "BARBACC3",
                    "ABAR8",
                    "Tesla_LightningCharge",
                    Font.FindFontColor("HUDBLUEBAR")
                );
                break;
            }

            // Draw the resouce gather icon
            case 'PBX_ChainsawEdited':
            {
                if(mo.FindInventory("ChainsawResourceGather"))
                {
                    phud.PBHud_DrawImage("CHAINHL", (-90, -44), BaseStatusBar.DI_SCREEN_RIGHT_BOTTOM, 1, (32, 32));
                }
            }

            default:
                break;
        }
    }
}

//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
class PBXHUDService_PBX_AllWeapons : service
{
    override Object GetObjectUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg)
    {
        if (request != "PBX_HUD") return null;

        let weapon = PB_WeaponBase(objectArg);
        if (!weapon) return null;

        switch (weapon.GetClassName())
        {
//////////////////////////// SLOT 2 ////////////////////////////////////////////////////////////////////////////////////
        case 'PBX_PlasmaBlaster':
        {
            return MakeData(imgOffset1:(-22, 12), imgScale1:2.0);
        }

        case 'PBX_ProsurvBlaster':
        {
            return MakeData(imgOffset1:(-30, 30), imgScale1:1.0);
        }

        case 'PBX_Prosurv_LeverAction':
        {
            let lar = PBX_Prosurv_LeverAction(weapon); if (!lar) return null;

            return MakeLaserData(
                laserOn: lar.GetLaserActive(),
                onImage: IMAGE_DIRECTORY.."LeverAction/LaserOn.png",
                offImage: IMAGE_DIRECTORY.."LeverAction/LaserOff.png",
                onOffset: (0, 18), 
                offOffset: (-10, 18), 
                onScale: 0.6, 
                offScale: 0.7
            );
        }

//////////////////////////// SLOT 3 ////////////////////////////////////////////////////////////////////////////////////
        case 'PBX_CSSG':
        {
            let cssg = PBX_CSSG(weapon); if (!cssg) return null;

            static const string cssgIcons[] = {
                "buckhud", "slughud", "flcthud",
                "flakhud", "drgnhud", "explhud",
                "phoshud", "doomhud", "dnmkhud",
                "subzhud", "helfhud", "acshhud"
            };

            int cssgshell = clamp(cssg.shellsmode, 0, cssgIcons.Size() - 1);

            return MakeData(img2: cssgIcons[cssgshell], imgOffset1:(-5, 12), imgScale1:0.9);
        }

        case 'PBX_ProSurvPSG':
        {
            let psg = PBX_ProSurvPSG(weapon); if (!psg) return null;

            return MakeLaserData(
                laserOn: psg.GetLaserActive(),
                onImage: IMAGE_DIRECTORY.."ProsurvPSG/LaserOn.png",
                offImage: IMAGE_DIRECTORY.."ProsurvPSG/LaserOff.png",
                onOffset: (13, -9), 
                offOffset: (-5, -7), 
                onScale: 0.8, 
                offScale: 1.1
            );
        }

        case 'PBX_SPAS12':
        {
            let spas12 = PBX_SPAS12(weapon); if (!spas12) return null;
            string shellImg = spas12.mSemiAuto ? "buckhud" : "slughud";

            return MakeData(img2:shellImg,imgOffset1:(-10, 10),imgScale1:0.65);
        }

        case 'PBX_CryoSG':
        {
            return MakeData(imgOffset1:(-15, 15), imgScale1:1.35);
        }

        case 'PBX_CryoASG':
        {
            return MakeData(imgOffset1:(-15, 12), imgScale1:1.5);
        }

//////////////////////////// SLOT 4 ////////////////////////////////////////////////////////////////////////////////////
        case 'PBX_BDPBattleRifle':
        {
            let br = PBX_BDPBattleRifle(weapon); if (!br) return null;

            return MakeLaserData(
                laserOn: br.GetLaserActive(),
                onImage: IMAGE_DIRECTORY.."BattleRifle/LaserOn.png",
                offImage: IMAGE_DIRECTORY.."BattleRifle/LaserOff.png",
                onOffset: (0, 12), 
                offOffset: (-7, 12), 
                onScale: 0.7, 
                offScale: 1.3);
        }

        case 'PBX_MetalSniper':
        {
            let sniper = PBX_MetalSniper(weapon); if (!sniper) return null;

            Vector2 imgOffset1 = sniper.GetLaserActive() ? (0, 10) : (0, 14);
            if (sniper.AltMode) imgOffset1.y -= 19;

            string img1 = sniper.GetLaserActive() ? IMAGE_DIRECTORY.."MetalSniper/LaserOn.png" : IMAGE_DIRECTORY.."MetalSniper/LaserOff.png";
            string img2 = sniper.resonanceAmmoLoaded ? IMAGE_DIRECTORY.."metalsniper/ResonanceAlt.png" : IMAGE_DIRECTORY.."metalsniper/StandardAlt.png";

            return MakeData(
                skipAutoDraw:true, 
                img1: img1, 
                img2: img2, 
                imgOffset1: imgOffset1, 
                imgScale2:0.7
            );
        }

        case 'PBX_Prosurv_Ballista':
        {
            return MakeData(imgOffset1:(-10, 10), imgScale1:1.0);
        }

        case 'PBX_NormalRifle':
        {
            let nr = PBX_NormalRifle(weapon); if (!nr) return null;

            return MakeLaserData(
                laserOn: nr.GetLaserActive(),
                onImage: IMAGE_DIRECTORY.."NormalRifle/laseron.png",
                offImage: IMAGE_DIRECTORY.."NormalRifle/laseroff.png",
                onOffset: (0, 8), 
                offOffset: (-5, 8), 
                onScale: 1.0, 
                offScale: 1.1
            );
        }

        case 'PBX_XM21':
        {
            let snp = PBX_XM21(weapon); if (!snp) return null;

            return MakeLaserData(
                laserOn: snp.GetLaserActive(),
                onImage: IMAGE_DIRECTORY.."XM21/LaserOn.png",
                offImage: IMAGE_DIRECTORY.."XM21/LaserOff.png",
                onOffset: (0,-12), 
                offOffset: (-7,-12), 
                onScale: 0.7, 
                offScale: 1.3);
        }

//////////////////////////// SLOT 5 ////////////////////////////////////////////////////////////////////////////////////
        case 'PBX_NeoHMG':
        {
            return MakeData(imgOffset1:(-3, -3), imgScale1:1.6);
        }

        case 'PBX_EternalMinigun':
        {
            return MakeData(imgOffset1:(-20, 35), imgScale1:1.5);
        }

        case 'PBX_SuperNailgun':
        {
            return MakeData(imgOffset1:(-2, 16), imgScale1:0.7);
        }

//////////////////////////// SLOT 6 ////////////////////////////////////////////////////////////////////////////////////
        case 'PBX_CyberdemonRL':
        {
            return MakeData(imgOffset1:(-12, 12), imgScale1:1.6);
        }

        case 'PBX_MastermindChaingun':
        {
            return MakeData(skipAutoDraw:true, img1:"RMN1H0", imgOffset1:(-10, 40), imgScale1:1.6);
        }

        case 'PBX_Excavator':
        {
            return MakeData(imgOffset1:(-10, 15), imgScale1:1.1);
        }

        case 'PBX_Paingiver':
        {
            return MakeData(imgOffset1:(-10, 15), imgScale1:1.3);
        }

//////////////////////////// SLOT 7 ////////////////////////////////////////////////////////////////////////////////////
        case 'PBX_BDPRailgun':
        {
            let railgun = PBX_BDPRailgun(weapon); if (!railgun) return null;
            
            return MakeLaserData(
                laserOn: railgun.GetLaserActive(),
                onImage: IMAGE_DIRECTORY.."PlatRailgun/LaserOn.png",
                offImage: IMAGE_DIRECTORY.."PlatRailgun/LaserOff.png",
                onOffset: (0, 12), 
                offOffset: (-5, 12), 
                onScale: 0.7, 
                offScale: 1.4
            );
        }

//////////////////////////// SLOT 8 ////////////////////////////////////////////////////////////////////////////////////
        case 'PBX_TeslaGun':
        {
            return MakeData(imgOffset1:(-10, -10), imgScale1:1.4);
        }
        case 'PBX_FreezeRifle':
        {
            return MakeData(imgOffset1:(-15, 13), imgScale1:1.2);
        }

//////////////////////////// SLOT 9 ////////////////////////////////////////////////////////////////////////////////////
        case 'PBX_DemonExt':
        {
            return MakeData(imgOffset1:(-10, 10), imgScale1:1.3);
        }

        case 'PBX_NukeLauncher':
        {
            return MakeData(imgOffset1:(25, 35), imgScale1:1.5);
        }

        case 'PBX_HexaShotgun':
        {
            return MakeData(imgOffset1:(-25, 10), imgScale1:1.7);
        }

        case 'PBX_MiniShotgun':
        {
            return MakeData(imgOffset1:(-25, 30), imgScale1:1.7);
        }

//////////////////////////// WEAPON EDITS ////////////////////////////////////////////////////////////////////////////////////
        case 'PBX_SGLEdited':
        {
            let sgl = PB_SuperGL(weapon); if(!sgl) return null;
            bool upgraded = PBXCore_HUDHandler.PBX_PlayerHasInventory("SGLUpgraded");

            static const string sglIcons[] = {
                "graphics/pywheel/grenade_impact.png", "graphics/pywheel/grenade_sticky.png", 
                "graphics/pywheel/grenade_acid.png", "graphics/pywheel/grenade_incendiary.png", 
                "graphics/pywheel/grenade_cryo.png"
            };

            int sglgren = clamp(sgl.GrenadeMode, 0, sglIcons.Size() - 1);
            string img1 = upgraded ? "BSGLA0" : "SGL0Z0";

            return MakeData(skipAutoDraw:true,img1:img1,img2:sglIcons[sglgren],imgOffset1:(-5, 13),imgOffset2:(3,-18),imgScale1:0.9,imgScale2:0.3);
        }

        case 'PBX_LMGEdited':
        {
            bool upgraded = PBXCore_HUDHandler.PBX_PlayerHasInventory("LMGUpgraded");

            string img1 = upgraded ? "LMPUA0" : "LMPIA0";

            return MakeData(skipAutoDraw:true,img1:img1,imgOffset1:(3, 23),imgScale1:0.8);
        }

        case 'PBX_ChainsawEdited':
        {
            return MakeData(imgOffset1:(-20, 32),imgScale1:0.8);
        }

        default:
            return null;
        }
    }

//////////////////////////// HELPER FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    private 
    PBXHUDData MakeData(
        bool skipAutoDraw = false,
        String img1 = "", 
        String img2 = "", 
        String img3 = "",
        Vector2 imgOffset1 = (0, 0),
        Vector2 imgOffset2 = (0, 0),
        double imgScale1 = 1.0, 
        double imgScale2 = 1.0
    )
    {
        let data = PBXHUDData(new("PBXHUDData"));
        if (!data) return null;

        data.Handled = true;
        data.SkipAutoDraw = skipAutoDraw;

        data.Image1 = img1;
        data.Image2 = img2;
        data.Image3 = img3;

        data.Offset1 = imgOffset1;
        data.Offset2 = imgOffset2;

        data.Scale1 = imgScale1;
        data.Scale2 = imgScale2;

        return data;
    }

    private 
    PBXHUDData MakeLaserData(
        bool laserOn, 
        String onImage, 
        String offImage,
        Vector2 onOffset, 
        Vector2 offOffset,
        double onScale, 
        double offScale
    )
    {
        string img = laserOn ? onImage : offImage;
        Vector2 ofs = laserOn ? onOffset : offOffset;
        double scl = laserOn ? onScale : offScale;
        return MakeData(skipAutoDraw:true, img1:img, imgOffset1:ofs, imgScale1:scl);
    }
}