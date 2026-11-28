enum PBX_Armory_ArmorSpawns
{
	DisableRed			= 1 << 0
	,DisablePurple		= 1 << 1
	,DisableWhite		= 1 << 2
	,DisableOrange		= 1 << 3
	,DisableYellow		= 1 << 4
	,DisableBlack		= 1 << 5
	,DisableDemon		= 1 << 6
	,DisableCyan		= 1 << 7
	,DisableDarkPurple	= 1 << 8
	,DisableDarkRed		= 1 << 9
	,DisableGold		= 1 << 10
	,DisableGray		= 1 << 11
	,DisableLightBlue	= 1 << 12
	,DisableLightGreen	= 1 << 13
	,DisablePink		= 1 << 14
	,DisableHelmetDrop	= 1 << 15
}

extend class PBX_Injector
{
    private
    void injectArmors(PB_EventHandler handler)
    {
        name armorsFlag = "PBX_SPAWN_FLAGS_ARMORS";

        // Red 0
        if(!CheckFlag(armorsFlag,DisableRed))
		{
			handler.InjectSpawn('PB_BlueSpawnerT2', 'PBX_RedArmor', 255, 1);
			handler.InjectSpawn('PB_BlueSpawnerT3', 'PBX_RedArmor', 255, 1);
		}

		// Purple 1
        if(!CheckFlag(armorsFlag,DisablePurple))
		{
			handler.InjectSpawn('PB_GreenSpawnerT3', 'PBX_PurpleArmor', 255, 1);
			handler.InjectSpawn('PB_GreenSpawnerT4', 'PBX_PurpleArmor', 255, 1);
		}

		// White 2
        if(!CheckFlag(armorsFlag,DisableWhite))
		{
			handler.InjectSpawn('PB_BlueSpawnerT1', 'PBX_WhiteArmor', 255, 1);
		}

		// Orange 3
        if(!CheckFlag(armorsFlag,DisableOrange))
		{
			handler.InjectSpawn('PB_BlueSpawnerT1', 'PBX_OrangeArmor', 255, 1);
		}

		// Yellow 4
        if(!CheckFlag(armorsFlag,DisableYellow))
		{
			handler.InjectSpawn('PB_GreenSpawnerT2', 'PBX_YellowArmor', 255, 1);
			handler.InjectSpawn('PB_GreenSpawnerT3', 'PBX_YellowArmor', 255, 1);
		}

		// Black 5
        if(!CheckFlag(armorsFlag,DisableBlack))
		{
			handler.InjectSpawn('PB_BlueSpawnerT1', 'PBX_BlackArmor', 255, 1);
			handler.InjectSpawn('PB_BlueSpawnerT2', 'PBX_BlackArmor', 255, 1);
		}
		
		// Demon 6
        if(!CheckFlag(armorsFlag,DisableDemon))
		{
			handler.InjectSpawn('PB_BlueSpawnerT3', 'PBX_DemonArmor', 255, 1);
			handler.InjectSpawn('PB_BlueSpawnerT4', 'PBX_DemonArmor', 255, 1);
		}

		// Cyan 7
        if(!CheckFlag(armorsFlag,DisableCyan))
		{
			handler.InjectSpawn('PB_BlueSpawnerT3', 'PBX_CyanArmor', 255, 1);
			handler.InjectSpawn('PB_BlueSpawnerT4', 'PBX_CyanArmor', 255, 1);
		}

		// Dark Purple 8
        if(!CheckFlag(armorsFlag,DisableDarkPurple))
		{
			handler.InjectSpawn('PB_GreenSpawnerT4', 'PBX_DarkPurpleArmor', 255, 1);
		}

		// Dark Red 9
        if(!CheckFlag(armorsFlag,DisableDarkRed))
		{
			handler.InjectSpawn('PB_BlueSpawnerT4', 'PBX_DarkRedArmor', 255, 1);
		}
		
		// Gold 10
        if(!CheckFlag(armorsFlag,DisableGold))
		{
			handler.InjectSpawn('PB_GreenSpawnerT4', 'PBX_GoldArmor', 255, 1);
		}

		// Gray 11
        if(!CheckFlag(armorsFlag,DisableGray))
		{
			handler.InjectSpawn('PB_GreenSpawnerT1', 'PBX_GrayArmor', 255, 1);
			handler.InjectSpawn('PB_GreenSpawnerT2', 'PBX_GrayArmor', 255, 1);
			handler.InjectSpawn('PB_GreenSpawnerT3', 'PBX_GrayArmor', 255, 1);
			handler.InjectSpawn('PB_GreenSpawnerT4', 'PBX_GrayArmor', 255, 1);
		}

		// Light Blue 12
        if(!CheckFlag(armorsFlag,DisableLightBlue))
		{
			handler.InjectSpawn('PB_GreenSpawnerT2', 'PBX_LightBlueArmor', 255, 1);
			handler.InjectSpawn('PB_GreenSpawnerT3', 'PBX_LightBlueArmor', 255, 1);
		}

		// Light Green 13
        if(!CheckFlag(armorsFlag,DisableLightGreen))
		{
			handler.InjectSpawn('PB_BlueSpawnerT4', 'PBX_LightGreenArmor', 255, 1);
		}

		// Pink 14
        if(!CheckFlag(armorsFlag,DisablePink))
		{
			handler.InjectSpawn('PB_BlueSpawnerT2', 'PBX_PinkArmor', 255, 1);
		}
    }
}