#include "./PBX_Spawners_Weapons.zs"
#include "./PBX_Spawners_Equipments.zs"

//////////////////////////// INJECTOR ////////////////////////////////////////////////////////////////////////////////////
class PBX_Injector : PBInjector
{
	override void Init(PB_EventHandler handler)
	{
		injectWeapons(handler);
		injectUpgrades(handler);
		injectEquipments(handler);
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
		PBX_SpawnSecretWeapons();
	}

	// Replace actors
	override void CheckReplacement(ReplaceEvent e) 
	{
		PBX_ReplaceWeapons(e);
    }

	// When something is spawned, for example
	// when a zombie drop an smg and you want to replace that
    override void WorldThingSpawned(WorldEvent e)
    {
        PBX_ReplaceSpawnedWeapons(e);
    }

	// Same as above but when something dies
	override void WorldThingDied(WorldEvent e)
    {
        PBX_MonsterDropWeapons(e);
    }
	
}
