enum PBX_Armory_ItemSpawns
{
	DisableRepairKit			= 1 << 0
	,DisableShoulderCannon      = 1 << 1
	,DisableJetPack             = 1 << 2
	,DisableUpgradeBot          = 1 << 3
	,DisableSmartScav           = 1 << 4

}

extend class PBX_Injector
{
    private
    void injectItems(PB_EventHandler handler)
    {
        name itemsFlag = "PBX_SPAWN_FLAGS_ITEMS";

        if(!CheckFlag(itemsFlag,DisableRepairKit))
        {
            handler.InjectSpawn('PB_PackSpawnerT1', 'PBX_RepairKit', 255, 1);
            handler.InjectSpawn('PB_PackSpawnerT2', 'PBX_RepairKit', 255, 1);
            handler.InjectSpawn('PB_PackSpawnerT3', 'PBX_RepairKit', 255, 1);
            handler.InjectSpawn('PB_PackSpawnerT4', 'PBX_RepairKit', 255, 1);
        }

        if(!CheckFlag(itemsFlag,DisableShoulderCannon) && !PBX_COMPAT_GLORYKILL)
        {
            handler.InjectSpawn('PB_PackSpawnerT2', 'PBX_ShoulderCannon', 255, 1);
            handler.InjectSpawn('PB_PackSpawnerT3', 'PBX_ShoulderCannon', 255, 1);
            handler.InjectSpawn('PB_PackSpawnerT4', 'PBX_ShoulderCannon', 255, 1);
        }

        if(!CheckFlag(itemsFlag,DisableJetPack))
        {
            handler.InjectSpawn('PB_RocketBoxSpawnerT2', 'PBX_Jetpack', 255, 1);
            handler.InjectSpawn('PB_RocketBoxSpawnerT3', 'PBX_Jetpack', 255, 1);
        }

        if(!CheckFlag(itemsFlag,DisableUpgradeBot))
        {
            // handler.InjectSpawn('PB_UpgradeSpawnerT1', 'PBX_UpgradeBot', 255, 1);
            handler.InjectSpawn('PB_UpgradeSpawnerT2', 'PBX_UpgradeBot', 255, 1);
            handler.InjectSpawn('PB_UpgradeSpawnerT3', 'PBX_UpgradeBot', 255, 1);
            // handler.InjectSpawn('PB_UpgradeSpawnerT4', 'PBX_UpgradeBot', 255, 1);
        }
    }
}