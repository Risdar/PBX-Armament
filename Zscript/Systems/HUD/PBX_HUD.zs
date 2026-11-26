#include "./PBX_HUD_Weapons.zs"
#include "./PBX_HUD_Armors.zs"
#include "./PBX_HUD_Powerups.zs"

enum PBX_eHudSettingFlags
{
    DisablePBX_WeaponHud            = 1 << 0
    ,DisablePBX_WeaponModeHud       = 1 << 1
    ,DisablePBX_ArmorHud		    = 1 << 2
    ,DisablePBX_ArmorHudBG		    = 1 << 3
}

class PBXHUDData : Object
{
    bool Handled;

    bool SkipAutoDraw;

    String Image1;
    String Image2;
    String Image3;

    Vector2 Offset1;
    Vector2 Offset2;
    Vector2 Offset3;

    double Scale1;
    double Scale2;
    double Scale3;
}

// HUD System
class PBX_HUD_Handler : StaticEventHandler
{
//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    // Position
    ui int pbx_weapon_PosX, pbx_weapon_PosY, pbx_weaponmode_PosX, pbx_weaponmode_PosY, pbx_armor_PosX, pbx_armor_PosY;

    // Scale
    ui double pbx_weapon_hudscale, pbx_weaponmode_hudscale, pbx_armor_hudscale;

    // Transparency
    ui double pbx_weapon_alpha, pbx_weaponmode_alpha, pbx_armor_alpha;

    // Cut Off Range (Box)
    ui int pbx_weapon_boxW, pbx_weapon_boxH;
    ui int pbx_weaponmode_boxW, pbx_weaponmode_boxH;
    ui int pbx_armor_boxW, pbx_armor_boxH;

    // Combine all individual values into one vector2
    ui Vector2 pbx_weapon_pos, pbx_weapon_truescale, pbx_weapon_box1;
    ui Vector2 pbx_weapon_pos2, pbx_weapon_truescale2, pbx_weapon_box2;
    ui Vector2 pbx_weapon_pos3, pbx_weapon_truescale3, pbx_weapon_box3;
    ui Vector2 pbx_armor_pos, pbx_armor_truescale, pbx_armor_box;

    // Flags
    ui int flagsleft, flagsright, flagsLeftCenter;

    // Icons
    ui string pbx_image, pbx_image2, pbx_image3, pbx_image4;

    // Services
    ui Array<Service> PBX_HUDServices;
    ui bool ServicesLoaded;

    // Others
    ui PlayerInfo plr;
    ui PlayerPawn mo;
    ui PB_Hud_ZS phud;
    ui PB_WeaponBase pbWeap;
    ui bool isAkimbo;
    ui vector2 akimboPosition;
    ui vector2 powerupPosition;
    bool isGearboxOpened;

    enum PBXHud_DrawImageSettings
    {
        DRAW_WEAPON_ICON,
        DRAW_MODE_ICON,
        DRAW_MODE2_ICON,
        DRAW_ARMOR_ICON,
        DRAW_ARMOR_BG
    }

    enum PBXHud_DrawBarSettings
    {
        DRAW_SECOND_BAR,
        DRAW_THIRD_BAR
    }

//////////////////////////// MAIN FUNCTION ////////////////////////////////////////////////////////////////////////////////////
    override void RenderOverlay(RenderEvent e)
    {
        // Dont bother drawing if both the Weapon and Armor HUD is off
        if(CheckFlag(DisablePBX_WeaponHud) && CheckFlag(DisablePBX_ArmorHud))
            return;

        // let handler = GB_EventHandler(EventHandler.Find("GB_EventHandler"));
        // if(handler && isGearboxOpened)
        // {
        //     let alpha = clamp(0.0 + 0.2, 0.0, 1.0);
        //     let gbColor = CVar.GetCVar('gb_dim_color',plr).GetInt();
        //     Screen.Dim(gbColor, alpha * 0.4, 0, 0, Screen.getWidth(), Screen.getHeight());
        // }

        bool success = Hud_Init();
        if(!success) return;

        // If the menu is active or the console is up
        // Gather the CVARs
        if (!menuactive || consolestate == c_up)
        {
            GetWeaponCVARs();
            GetArmorCVARs();
        }

        // Begin drawing the HUD
        phud.BeginHUD();       // Initialize
        DrawEveryWeapon();
        DrawArmors();
        DrawPowerups();
        
    }

    override void RenderUnderlay(RenderEvent e)
    {
        bool success = Hud_Init();
        if(!success) return;

        // Begin drawing the HUD
        phud.BeginHUD();          // Initialize
        DrawWeaponOverlays();     // Some Weapons have overlays
    }

    override void WorldTick()
    {
        isGearboxOpened = false;

        let handler = GB_EventHandler(EventHandler.Find("GB_EventHandler"));
        if (handler && handler.isOpened())
            isGearboxOpened = true;
    }

//////////////////////////// GATHER DATA ////////////////////////////////////////////////////////////////////////////////////
    // Initialize Members
    private
    ui bool Hud_Init()
    {
        // Dont draw if the player is not in a level
        if (gamestate != GS_LEVEL)
            return false;

        // Get a pointer to the PB Hud so we can access it
        phud = PB_Hud_ZS(StatusBar); if(!phud) return false;

        // Dont draw if the player is dead
        if (phud.hudState == BaseStatusBar.HUD_None || phud.PlayerWasDead) 
            return false;

        // Get a pointer to the player
        plr = players[consoleplayer]; 
        mo = plr.mo;
        if (!plr || !mo) 
            return false;

        pbWeap = PB_WeaponBase(plr.ReadyWeapon); 
        if (!pbWeap) 
            return false;

        return true;
    }

    // Find the Services function
    private
    ui void FindHUDServices()
    {
        if (ServicesLoaded)
            return;

        let it = ServiceIterator.Find("PBXHUDService");

        Service svc;

        while ((svc = it.Next()))
        {
            PBX_HUDServices.Push(svc);
        }

        ServicesLoaded = true;
    }

    // Function to get the Data from those Services
    private
    ui PBXHUDData GetExternalHUD(PB_WeaponBase weapon)
    {
        for (int i = 0; i < PBX_HUDServices.Size(); i++)
        {
            if(!weapon) 
                return null;

            let svc = PBX_HUDServices[i];
            if (!svc) 
                continue;

            let data = PBXHUDData(svc.GetObjectUI("PBX_HUD", objectArg: weapon));
            if (data && data.Handled){
                return data;
            }
        }
        return null;
    }

    // Get data from any PBXHUDData
    private
    ui void GetWeaponDataService()
    {
        let ext = GetExternalHUD(pbWeap);
        if (ext)
        {
             // This way it will only draw if theres actually something there
            if(ext.Image1 != "") pbx_image = ext.Image1;
            if(ext.Image2 != "") pbx_image = ext.Image2;
            if(ext.Image3 != "") pbx_image = ext.Image3;

            pbx_weapon_pos += ext.Offset1;
            pbx_weapon_pos2 += ext.Offset2;
            pbx_weapon_pos3 += ext.Offset3;

            pbx_weapon_truescale *= ext.Scale1;
            pbx_weapon_truescale2 *= ext.Scale2;
            pbx_weapon_truescale3 *= ext.Scale3;

        }
    }

//////////////////////////// HELPER FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    private
    ui void PBX_DrawImage(PBXHud_DrawImageSettings whatimage, bool drawAkimbo = false)
    {
        int flags;
        string image; 
        Vector2 pos, scale, box; 
        double transparency;

        vector2 armorBGScale = pbx_armor_truescale*4;

        switch (whatimage)
        {
            default:
            case DRAW_WEAPON_ICON: 
                image           = pbx_image;  
                pos             = pbx_weapon_pos;  
                scale           = pbx_weapon_truescale;  
                transparency    = pbx_weapon_alpha;     
                box             = pbx_weapon_box1;   
                flags           = flagsright;     
                break;

            case DRAW_MODE_ICON: 
                image           = pbx_image2; 
                pos             = pbx_weapon_pos2; 
                scale           = pbx_weapon_truescale2; 
                transparency    = pbx_weaponmode_alpha; 
                box             = pbx_weapon_box2;   
                flags           = flagsright;     
                break;

            case DRAW_MODE2_ICON: 
                image           = pbx_image3; 
                pos             = pbx_weapon_pos3; 
                scale           = pbx_weapon_truescale3; 
                transparency    = pbx_weaponmode_alpha; 
                box             = pbx_weapon_box3;   
                flags           = flagsright;     
                break;

            case DRAW_ARMOR_ICON: 
                image           = pbx_image4; 
                pos             = pbx_armor_pos;   
                scale           = pbx_armor_truescale;   
                transparency    = pbx_armor_alpha;      
                box             = pbx_armor_box;     
                flags           = flagsLeftCenter;
                break;

            case DRAW_ARMOR_BG: 
                image           = "ARMRBO";   
                pos             = pbx_armor_pos;   
                scale           = armorBGScale; 
                transparency    = phud.playerBoxAlpha;      
                box             = pbx_armor_box;     
                flags           = flagsLeftCenter;
                break;

        }

        // Dim stuff if any gearbox wheel is open
        if(isGearboxOpened) transparency *= 0.4;

        phud.PBHud_DrawImage(
            image, 
            drawAkimbo ? pos + akimboPosition : pos,
            flags, 
            transparency, 
            scale:scale 
            // box:box
        );
    }

    // Just a non verbose way to check flags
    // will always check PBXCore_HudFlags
    private 
    ui bool CheckFlag(int tipFlag)
    {
        let check = CVar.FindCVar("PBXCore_HudFlags");
        return (check.GetInt() & tipflag) == tipflag;
    }

    private
    ui void PBX_DrawAmmoBar(
        bool whatBar,       // What Bar to Draw
        String bgimg,       // Background Image
        String ongfx,       // Ammo Bar
        String ammoName,    // What Ammo to Count
        int fontTranslation // Font Color
    )
    {
        if(!phud) return;

        let transparency = phud.playerBoxAlpha;
        let barAlpha = 1.0;
        if(isGearboxOpened)
        {
            transparency *= 0.4;
            barAlpha *= 0.4;
        }

        vector2 bgpos       = whatBar ? (-90,-71)   : (-73,-49);
        vector2 barpos      = whatBar ? (-100,-72)  : (-111,-52);
        vector2 stringpos   = whatBar ? (-207,-90)  : (-205,-68.75);

        phud.PBHud_DrawImage(bgimg, bgpos,  BaseStatusBar.DI_SCREEN_RIGHT_BOTTOM | BaseStatusBar.DI_ITEM_RIGHT_BOTTOM, transparency);
        phud.PBHud_DrawBar(ongfx, "BGBARL", phud.GetAmount(ammoName), phud.GetMaxAmount(ammoName), barpos, 0, 1,  BaseStatusBar.DI_SCREEN_RIGHT_BOTTOM | BaseStatusBar.DI_ITEM_RIGHT_BOTTOM,barAlpha);
        phud.PBHud_DrawString(phud.mDefaultFont, phud.Formatnumber(phud.GetAmount(ammoName)), stringpos, BaseStatusBar.DI_TEXT_ALIGN_RIGHT, fontTranslation);
    }

    static ui void PBX_DrawAmmoBarStatic(
        PB_Hud_ZS phud,     // Pointer to the PB Hud
        bool whatBar,       // What Bar to Draw
        String bgimg,       // Background Image
        String ongfx,       // Ammo Bar
        String ammoName,    // What Ammo to Count
        int fontTranslation // Font Color
    )
    {
        if(!phud) return;

        let transparency = phud.playerBoxAlpha;
        let barAlpha = 1.0;
        let handler = PBX_HUD_Handler(EventHandler.Find("PBX_HUD_Handler"));
        if(handler && handler.isGearboxOpened)
        {
            transparency *= 0.4;
            barAlpha *= 0.4;
        }

        vector2 bgpos       = whatBar ? (-90,-71)   : (-73,-49);
        vector2 barpos      = whatBar ? (-100,-72)  : (-111,-52);
        vector2 stringpos   = whatBar ? (-207,-90)  : (-205,-68.75);

        phud.PBHud_DrawImage(bgimg, bgpos,  BaseStatusBar.DI_SCREEN_RIGHT_BOTTOM | BaseStatusBar.DI_ITEM_RIGHT_BOTTOM, transparency);
        phud.PBHud_DrawBar(ongfx, "BGBARL", phud.GetAmount(ammoName), phud.GetMaxAmount(ammoName), barpos, 0, 1,  BaseStatusBar.DI_SCREEN_RIGHT_BOTTOM | BaseStatusBar.DI_ITEM_RIGHT_BOTTOM,barAlpha);
        phud.PBHud_DrawString(phud.mDefaultFont, phud.Formatnumber(phud.GetAmount(ammoName)), stringpos, BaseStatusBar.DI_TEXT_ALIGN_RIGHT, fontTranslation);
    }

    // Im not sure if this can be called from the play scope lol
    static clearscope bool PBX_PlayerHasInventory(name inv)
    {
        return PlayerPawn(players[consoleplayer].mo).CountInv(inv) > 0;
    }

}

