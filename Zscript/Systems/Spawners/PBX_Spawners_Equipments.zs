enum PBX_Equipment_SpawnFlags
{
////// Equipments /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	DisableEQ_IncendiaryGrenade		= 1 << 0
	,DisableEQ_SmokeGrenade			= 1 << 1
	,DisableEQ_MedPack				= 1 << 2
	,DisableEQ_Charges				= 1 << 3
}

extend class PBX_Injector
{
//////////////////////////// EQUIPMENTS ////////////////////////////////////////////////////////////////////////////////////
	private
	void injectEquipments(PB_EventHandler handler)
	{
		name equipmentFlag = "PBX_SPAWN_FLAGS_EQUIPMENTS";

		// Incendiary Grenade
		if(!CheckFlag(equipmentFlag, DisableEQ_IncendiaryGrenade))
		{
			handler.InjectSpawn('PB_RocketSpawnerT1', 'PB_IncendiaryGrenadeAmmo', 255, 1);
			handler.InjectSpawn('PB_RocketSpawnerT2', 'PB_IncendiaryGrenadeAmmo', 255, 1);
		}

		// Smoke Grenade
		if(!CheckFlag(equipmentFlag, DisableEQ_SmokeGrenade))
		{
			handler.InjectSpawn('PB_RocketBoxSpawnerT3', 'PBX_SmokeGrenadePack', 255, 1);
		}

		// Med Pack
		if(!CheckFlag(equipmentFlag, DisableEQ_MedPack))
		{
			handler.InjectSpawn('PB_PackSpawnerT2', 'PBX_MedPackAmmo', 255, 1);
			handler.InjectSpawn('PB_PackSpawnerT3', 'PBX_MedPackAmmo', 255, 1);
		}

        // Charges
		if(!CheckFlag(equipmentFlag, DisableEQ_Charges))
		{
			handler.InjectSpawn('PB_RocketSpawnerT1', 'PBX_AcidChargeAmmo', 255, 1);
			handler.InjectSpawn('PB_RocketSpawnerT2', 'PBX_LaserChargeAmmo', 255, 1);
			handler.InjectSpawn('PB_RocketSpawnerT3', 'PBX_SwarmChargeAmmo', 255, 1);
			handler.InjectSpawn('PB_RocketBoxSpawnerT3', 'PBX_ChargesPack', 255, 1);
		}
	}
}