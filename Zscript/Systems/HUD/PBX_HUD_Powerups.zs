extend class PBX_HUD_Handler
{
    // Powerup Position
    const POWERUP_POSITION_X = 16;
    const POWERUP_POSITION_Y = -76;

    // Custom powerups in PBX
    private 
    ui bool IsPBXPowerup(name powerName)
    {
        static const name PBXPowerups[] =
        {
            // Special Powerups
            'PBX_PowerInvisTainted',
            'PBX_PowerDeflect',
            'PBX_PowerElectAura',
            'PBX_PowerInvulTainted',
            // Vanilla Powerups
            'PBX_PowerBuddha',
            'PBX_PowerDrain',
            'PBX_PowerFlight',
            'PBX_PowerFrightener',
            'PBX_PowerHighJump',
            'PBX_PowerInfiniteAmmo',
            'PBX_PowerProtection',
            'PBX_PowerReflection',
            'PBX_PowerRegeneration',
            'PBX_PowerTimeFreezer',
            'PBX_PowerTaintedRegen',
            // New Powerups
            'PBX_PowerFrostAura',
            'PBX_PowerFireAura'
        };

        for (int i = 0; i < PBXPowerups.Size(); i++)
        {
            if (PBXPowerups[i] == powerName) return true;
        }

        return false;
    }

    // Set what icon to use here
    // Make sure to update it everytime pb added new powerups
    private 
    ui string GetPowerupImage(name powerName)
    {
        switch (powerName)
        {
            // PB Powerups
            case 'PB_PowerInvul':           return "PWRINVUL";
            case 'PB_PowerIronFeet':        return "PWRRADSU";
            case 'PB_PowerInvis':           return "PWRINVIS";
            case 'PB_PowerLightAmp':        return "PWRINFRA";
            case 'PB_PowerDoomDamage':      return "PWRQUADD";
            case 'PB_PowerSpeed':           return "PWRHASTE";
            // PBX Powerups
            // Special Powerups
            case 'PBX_PowerInvisTainted':   return "PWRVISTN";
            case 'PBX_PowerDeflect':        return "PWRDEFLE";
            case 'PBX_PowerElectAura':      return "PWRELECT";
            case 'PBX_PowerInvulTainted':   return "PWRVULTN";
            // Vanilla Powerups
            case 'PBX_PowerBuddha':         return "PWRBUDHA";
            case 'PBX_PowerDrain':          return "PWRDRAIN";
            case 'PBX_PowerFlight':         return "PWRFLIGH";
            case 'PBX_PowerFrightener':     return "PWRFRGHT";
            case 'PBX_PowerHighJump':       return "PWRHIJMP";
            case 'PBX_PowerInfiniteAmmo':   return "PWRINFAM";
            case 'PBX_PowerProtection':     return "PWRPRTCK";
            case 'PBX_PowerReflection':     return "PWRRFLCT";
            case 'PBX_PowerRegeneration':   return "PWRREGEN";
            case 'PBX_PowerTimeFreezer':    return "PWRTMFRZ";
            case 'PBX_PowerTaintedRegen':   return "PWRRGNTN";
            // New Powerups
            case 'PBX_PowerFrostAura':      return "PWRFRZAU";
            case 'PBX_PowerFireAura':       return "PWRFRAUR";
            default:                        return "";
        }
    }

    // Draw Function
    private 
    ui void DrawPowerups()
    {
        vector2 initialpos = powerupPosition;
        string image;
		string powerTime;
		name powerName;
		int fontCol;
        int step = 22;

        // Count PB powerups first so we can start above them
        int baseCount = 0;
        for (let i = mo.inv; i != null; i = i.inv)
        {
            powerName = i.GetClassName();
            let power = Powerup(i);
            
            if (!power || IsPBXPowerup(powerName)) continue;
            if (GetPowerupImage(powerName) != "") baseCount++;
        }

        initialpos.y -= baseCount * step;

        // Draw PBX Powerups
        for (let i = mo.inv; i != null; i = i.inv)
        {
            powerName = i.GetClassName();
            let power = Powerup(i);

            if (!power || !IsPBXPowerup(powerName)) continue;

            image = GetPowerupImage(powerName);
            if (image == "") continue;

            powerTime = phud.FormatPowerupTime(power);
            fontCol = Font.FindFontColor(powerName);

            phud.PBHud_DrawImage(image, initialpos, flagsleft, phud.playerBoxAlpha);
            phud.PBHud_DrawString(phud.mBoldFont, powerTime, (initialpos.x + 28, initialpos.y - 20), flagsleft, fontCol);
            initialpos.y -= step;
        }
    }
}