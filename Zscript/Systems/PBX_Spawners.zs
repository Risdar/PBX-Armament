//////////////////////////// INJECTOR ////////////////////////////////////////////////////////////////////////////////////
class PBX_Injector : PBInjector
{
	override void Init(PB_EventHandler handler)
	{
		if(PBX_MODULE_WEAPONS)
		{
			injectWeapons(handler);
			injectUpgrades(handler);
		}

		if(PBX_MODULE_EQUIPMENTS)
		{
			injectEquipments(handler);
		}

		if(PBX_MODULE_ARMORS)
		{
			injectArmors(handler);
		}

		if(PBX_MODULE_POWERUPS)
		{
			injectPowerups(handler);
		}

		if(PBX_MODULE_ITEMS)
		{
			injectItems(handler);
		}
	}

//////////////////////////// HELPERS ////////////////////////////////////////////////////////////////////////////////////
	private
	bool CheckFlag(string name, int tipFlag)
	{
		let check = CVar.FindCVar(name);
		return (check.GetInt() & tipflag) == tipflag;
	}
}

//////////////////////////// HANDLER ////////////////////////////////////////////////////////////////////////////////////
extend class PBX_Handler
{
	// When player spawns/world is loaded
	override void WorldLoaded(WorldEvent e)
	{
		if(PBX_MODULE_EQUIPMENTS && PBX_CVAR_SECRET_WEAPONS)
		{
			PBX_SpawnSecretWeapons();
		}
	}

	// Replace actors
	override void CheckReplacement(ReplaceEvent e) 
	{
		if(PBX_MODULE_WEAPONS) 
		{
			PBX_ReplaceWeapons(e);
		}

		if(PBX_CVAR_SMARTSCAV)
		{
			spawnSmartScav(e);
		}
    }

	// When something is spawned, for example
	// when a zombie drop an smg and you want to replace that
    override void WorldThingSpawned(WorldEvent e)
    {
		if(PBX_MODULE_WEAPONS) 
		{
			PBX_ReplaceSpawnedWeapons(e);
		}
    }

	// Same as above but when something dies
	override void WorldThingDied(WorldEvent e)
    {
		if(PBX_MODULE_WEAPONS) 
		{
			PBX_MonsterDropWeapons(e);
		}
    }
	
}
