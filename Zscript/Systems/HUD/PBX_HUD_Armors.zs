extend class PBX_HUD_Handler
{
    // Ammo Bar Position
    const AMMO2BG_POSITION_X    = -73;
    const AMMO2BG_POSITION_Y    = -49;
    const AMMO2BAR_POSITION_X   = -111;
    const AMMO2BAR_POSITION_Y   = -52;
    const AMMO2STR_POSITION_X   = -205;
    const AMMO2STR_POSITION_Y   = -68.75;

    const AMMO3BG_POSITION_X    = -90;
    const AMMO3BG_POSITION_Y    = -71;
    const AMMO3BAR_POSITION_X   = -100;
    const AMMO3BAR_POSITION_Y   = -72;
    const AMMO3STR_POSITION_X   = -207;
    const AMMO3STR_POSITION_Y   = -90;

    private
    ui void GetArmorCVARs()
    {
        // Armor
        pbx_armor_PosX          = CVar.GetCVar("PBX_CVAR_HUD_ARMOR_X", plr).GetInt();
        pbx_armor_PosY          = CVar.GetCVar("PBX_CVAR_HUD_ARMOR_Y", plr).GetInt();
        pbx_armor_hudscale      = CVar.GetCVar("PBX_CVAR_HUD_ARMOR_SCALE", plr).GetFloat();
        pbx_armor_alpha         = CVar.GetCVar("PBX_CVAR_HUD_ARMOR_ALPHA", plr).GetFloat();
        pbx_armor_boxW          = CVar.GetCVar("PBX_CVAR_HUD_ARMOR_BOX_W", plr).GetInt();
        pbx_armor_boxH          = CVar.GetCVar("PBX_CVAR_HUD_ARMOR_BOX_H", plr).GetInt();

        pbx_armor_pos           = (pbx_armor_PosX, pbx_armor_PosY);
        pbx_armor_truescale     = (pbx_armor_hudscale, pbx_armor_hudscale);
        pbx_armor_box           = (pbx_armor_boxW, pbx_armor_boxH);
    }

    // Get Armor Icon and Draw Function 
    private
    ui void DrawArmors()
    {
        // Dont draw if its disabled
        if(CheckFlag(DisablePBX_ArmorHud)) return;

        // Draw the Armor Box if Enabled
        if(!CheckFlag(DisablePBX_ArmorHudBG))
            PBX_DrawImage(DRAW_ARMOR_BG);

        // Get the data for the armors
        let barmor = BasicArmor(mo.FindInventory("BasicArmor", true));
        if(!barmor) return;

        if (barmor.Amount > 0)
        {
            TextureID iconID = barmor.Icon;
            class<Inventory> armorClass = (class<Inventory>)(barmor.ArmorType);
            if (armorClass)
            {
                // Look for the Default Icons
                name armorType = armorClass.GetClassName();
                let def = GetDefaultByType(armorClass);
                iconID = def.AltHUDIcon.IsValid() ? def.AltHUDIcon : def.Icon;

                // Do exceptions
                switch(armorType)
                {
                    case 'PBX_SuperArmor': case 'PBX_HyperArmor': case 'PBX_MiniArmor':
                    case 'PB_GreenArmor':  case 'PB_BlueArmor':   case 'PB_ArmorBonus':
                        pbx_armor_truescale *= 5.0;
                        break;
                    
                }
            }
            pbx_image4 = TexMan.GetName(iconID);
        }
        else
        {
            // Draw a No Armor Text if the player didnt have any
            pbx_image4 = "ARMRNO";
            pbx_armor_truescale *= 6;

        }

        // Draw
        PBX_DrawImage(DRAW_ARMOR_ICON);
    }
}