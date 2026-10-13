enum PBX_Weapons_eWeaponTipFlags
{
    // SLOT 2
    
    // SLOT 3
    PBX_TIP_CSSG                 = 1 << 0
    ,PBX_TIP_PSG                 = 1 << 1
    // SLOT 4
    ,PBX_TIP_METALSNIPER         = 1 << 2
    // SLOT 5 
    ,PBX_TIP_NEOHMG              = 1 << 3
    ,PBX_TIP_SUPERNAILGUN        = 1 << 4
    // SLOT 6
    ,PBX_TIP_EXCAVATOR           = 1 << 5
    ,PBX_TIP_PAINGIVER           = 1 << 6
    // SLOT 7
    ,PBX_TIP_BDPRAILGUN          = 1 << 7
    // SLOT 8
    ,PBX_TIP_TESLAGUN            = 1 << 8
    // SLOT 9
    ,PBX_TIP_DEMONEXT            = 1 << 9
    // OTHERS
    ,PBX_TIP_SCROLLZOOM          = 1 << 28
    ,PBX_TIP_COMMANDERWEAPON     = 1 << 29
    ,PBX_TIP_MONSTERWEAPON       = 1 << 30
    ,PBX_TIP_DEMONICWEAPON       = 1 << 31
}

const WEAPON_HELPTEXT = "PBX_Weapons_weaponTipFlags";
const WEAPON_UPGRADE_HELPTEXT = "PBX_Weapons_upgradeTipFlags";
extend class PBX_WeaponBase
{

    action void PBX_WeaponHelpText()
	{
        // PBXCore_Debug.Print("Help Text Called");
        if(invoker.mScopedWeapon)
        {
            Array<String> tips;
            tips.Push("$PBX_ScrollZoom_Tip1");
            tips.Push(string.format(StringTable.Localize("$PBX_ScrollZoom_Tip2"),PB_HelpNotificationsHandler.PB_FormatKeybinds("pbx_zoomin"),PB_HelpNotificationsHandler.PB_FormatKeybinds("pbx_zoomout")));
            PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_SCROLLZOOM);
        }

        switch(invoker.getClassName())
        {
            default:
                break;

            // SLOT 2
            
            // SLOT 3
            case 'PBX_CSSG':
            {
                Array<String> tips;
                tips.Push(string.format(StringTable.Localize("$PBX_CSSG_Tip1"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+pb_specialwheel")));
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_CSSG);
                TryGiveSpecialTip(DISABLE_UPGRADE);
            }
            break;

            case 'PBX_ProSurvPSG':
            {
                Array<String> tips;
                tips.Push(string.format(StringTable.Localize("$PBX_PSG_Tip1"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+pb_specialwheel")));
                tips.Push("$PBX_PSG_Tip2");
                tips.Push(string.format(StringTable.Localize("$PBX_PSG_Tip3"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+USE")));
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_PSG);
            }
            break;

            // SLOT 4
            case 'PBX_MetalSniper':
            {
                Array<String> tips;
                tips.Push(string.format(StringTable.Localize("$PBX_MetalSniper_Tip1"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+pb_specialwheel")));
                tips.Push(string.format(StringTable.Localize("$PBX_MetalSniper_Tip2"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+ALTATTACK"), PB_HelpNotificationsHandler.PB_FormatKeybinds("+ATTACK")));
                tips.Push("$PBX_MetalSniper_Tip3");
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_METALSNIPER);
                TryGiveSpecialTip(DISABLE_UPGRADE);
            }
            break;

            // SLOT 5
            case 'PBX_NeoHMG':
            {
                Array<String> tips;
                tips.Push(string.format(StringTable.Localize("$PBX_NeoHMG_Tip1"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+ALTATTACK")));
                tips.Push(string.format(StringTable.Localize("$PBX_NeoHMG_Tip2"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+pb_specialwheel")));
                tips.Push(string.format(StringTable.Localize("$PBX_NeoHMG_Tip3"),PBX_NeoHMG.OVERHEAT_THRESHOLD));
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_NEOHMG);
            }
            break;
            case 'PBX_SuperNailgun':
            {
                Array<String> tips;
                tips.Push(string.format(StringTable.Localize("$PBX_SuperNailgun_Tip1"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+ALTATTACK"),PBX_SuperNailgun.OVERHEAT_THRESHOLD));
                tips.Push("$PBX_SuperNailgun_Tip2");
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_SUPERNAILGUN);
            }
            break;

            // SLOT 6
            case 'PBX_Excavator':
            {
                Array<String> tips;
                tips.Push(string.format(StringTable.Localize("$PBX_Excavator_Tip1"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+ALTATTACK")));
                tips.Push("$PBX_Excavator_Tip2");
                tips.Push("$PBX_Excavator_Tip3");
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_EXCAVATOR);
            }
            break;
            case 'PBX_CyberdemonRL':  case 'PBX_MastermindChaingun':
            {
                TryGiveSpecialTip(MONSTER_WEAPON);
            }
            break;
            case 'PBX_Paingiver':
            {
                Array<String> tips;
                tips.Push("$PBX_Paingiver_Tip1");
                tips.Push("$PBX_Paingiver_Tip2");
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_PAINGIVER);
            }
            break;

            // SLOT 7
            case 'PBX_BDPRailgun':
            {
                Array<String> tips;
                tips.Push(string.format(StringTable.Localize("$PBX_BDPRailgun_Tip1"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+pb_specialwheel")));
                tips.Push(string.format(StringTable.Localize("$PBX_BDPRailgun_Tip2"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+pb_specialwheel")));
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_BDPRAILGUN);
            }
            break;

            // SLOT 8
            case 'PBX_TeslaGun':
            {
                Array<String> tips;
                tips.Push("$PBX_Teslagun_Tip1");
                tips.Push("$PBX_Teslagun_Tip2");
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_TESLAGUN);
            }
            break;
            

            // SLOT 9
            case 'PBX_DemonExt':
            {
                Array<String> tips;
                tips.Push("$PBX_DemonExt_Tip1");
                tips.Push("$PBX_DemonExt_Tip2");
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_DEMONEXT);
            }
            break;
        }
    }

    enum PBX_Weapons_SpecialTip
    {
        MONSTER_WEAPON,
        DISABLE_UPGRADE
    }

    action void TryGiveSpecialTip(PBX_Weapons_SpecialTip whatToSend)
    {
        switch(whatToSend)
        {
            case MONSTER_WEAPON:
            {
                Array<String> tips;
                tips.Push("$PBX_MonsterWeapon1");
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_HELPTEXT, PBX_TIP_MONSTERWEAPON);
            }
            break;

            case DISABLE_UPGRADE:
            {
                Array<String> tips;
                tips.Push("$PBX_DisableUpgrade");
                PBXCore_TipsManager.SendTipArrayIfNeeded(tips, WEAPON_UPGRADE_HELPTEXT, PBX_TIP_DISABLE_UPGRADE);
            }
            break;
        }
    }
}