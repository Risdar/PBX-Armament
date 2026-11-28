enum PBX_Armory_PowerupSpawns
{
	DisableMegaBerserk			 = 1 << 0
	,DisableSuperSphere			 = 1 << 1
	,DisableUltraSphere			 = 1 << 2
	,DisableHyperSphere			 = 1 << 3
	,DisableMiniSphere			 = 1 << 4

	,DisableBlackBlur			 = 1 << 5
	,DisableDeflectSphere        = 1 << 6
	,DisableElectricAura         = 1 << 7
	,DisableGoldInvul            = 1 << 8
	,DisableLegendSPhere         = 1 << 9
	,DisableLifestealOrb         = 1 << 10
	,DisableTerrorSphere         = 1 << 11
	,DisableAmmoSphere           = 1 << 12
	,DisableGuardSphere          = 1 << 13
	,DisableRegenSphere          = 1 << 14
	,DisableTimeSphere           = 1 << 15

	,DisableRedSoul              = 1 << 16
	,DisableDarkMega             = 1 << 17

	,DisableHaste                = 1 << 18
	,DisableQuadDamage           = 1 << 19

	,DisableFrostAura            = 1 << 20
	,DisableFireAura             = 1 << 21

	,DisableFlightSphere         = 1 << 22

	,DisableAdrenaline           = 1 << 23
}

extend class PBX_Injector
{
//////////////////////////// POWERUPS ///////////////////////////////////////////////////////////////////////////////
    private
    void injectPowerups(PB_EventHandler handler)
    {
        name powerupsFlag = "PBX_SPAWN_FLAGS_POWERUPS";

        if(!CheckFlag(powerupsFlag,DisableMegaBerserk))
        {
            handler.InjectSpawn('PB_BerserkSpawnerT2', 'PBX_MegaBerserk', 255, 1);
            handler.InjectSpawn('PB_BerserkSpawnerT3', 'PBX_MegaBerserk', 255, 1);
            handler.InjectSpawn('PB_BerserkSpawnerT4', 'PBX_MegaBerserk', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableSuperSphere))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT2', 'PBX_SuperSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_SuperSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_SuperSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableUltraSphere))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_UltraSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_UltraSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableHyperSphere))
        {
            handler.InjectSpawn('PB_MegaSpawnerT2', 'PBX_HyperSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT3', 'PBX_HyperSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT4', 'PBX_HyperSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableMiniSphere))
        {
		    handler.InjectSpawn('PB_GreenSpawnerT3', 'PBX_MiniSphere', 255, 1);
		    handler.InjectSpawn('PB_GreenSpawnerT4', 'PBX_MiniSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableBlackBlur))
        {
            handler.InjectSpawn('PB_BlurSpawnerT1', 'PBX_BlackBlur', 255, 1);
            handler.InjectSpawn('PB_BlurSpawnerT2', 'PBX_BlackBlur', 255, 1);
            handler.InjectSpawn('PB_BlurSpawnerT3', 'PBX_BlackBlur', 255, 1);
            handler.InjectSpawn('PB_BlurSpawnerT4', 'PBX_BlackBlur', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableDeflectSphere))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT1', 'PBX_DeflectSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT2', 'PBX_DeflectSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableElectricAura))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_ElectricAuraSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_ElectricAuraSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT2', 'PBX_ElectricAuraSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT3', 'PBX_ElectricAuraSphere', 255, 1);
        }
        
        if(!CheckFlag(powerupsFlag,DisableGoldInvul))
        {
            handler.InjectSpawn('PB_InvulSpawnerT1', 'PBX_GoldInvul', 255, 1);
            handler.InjectSpawn('PB_InvulSpawnerT2', 'PBX_GoldInvul', 255, 1);
            handler.InjectSpawn('PB_InvulSpawnerT3', 'PBX_GoldInvul', 255, 1);
            handler.InjectSpawn('PB_InvulSpawnerT4', 'PBX_GoldInvul', 255, 1);
        }
        
        if(!CheckFlag(powerupsFlag,DisableLegendSPhere))
        {
            handler.InjectSpawn('PB_InvulSpawnerT1', 'PBX_LegendSphere', 255, 1);
            handler.InjectSpawn('PB_InvulSpawnerT2', 'PBX_LegendSphere', 255, 1);
            handler.InjectSpawn('PB_InvulSpawnerT3', 'PBX_LegendSphere', 255, 1);
            handler.InjectSpawn('PB_InvulSpawnerT4', 'PBX_LegendSphere', 255, 1);
        }
        
        if(!CheckFlag(powerupsFlag,DisableLifestealOrb))
        {
            handler.InjectSpawn('PB_BerserkSpawnerT1', 'PBX_MegaBerserk', 255, 1);
            handler.InjectSpawn('PB_BerserkSpawnerT2', 'PBX_MegaBerserk', 255, 1);
            handler.InjectSpawn('PB_BerserkSpawnerT3', 'PBX_MegaBerserk', 255, 1);
            handler.InjectSpawn('PB_BerserkSpawnerT4', 'PBX_MegaBerserk', 255, 1);
        }
        
        if(!CheckFlag(powerupsFlag,DisableTerrorSphere))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT1', 'PBX_TerrorSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT2', 'PBX_TerrorSphere', 255, 1);

        }
        
        if(!CheckFlag(powerupsFlag,DisableAmmoSphere))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT1', 'PBX_AmmoSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT2', 'PBX_AmmoSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_AmmoSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_AmmoSphere', 255, 1);
        }
        
        if(!CheckFlag(powerupsFlag,DisableGuardSphere))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT1', 'PBX_GuardSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT2', 'PBX_GuardSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_GuardSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_GuardSphere', 255, 1);
        }
        
        if(!CheckFlag(powerupsFlag,DisableRegenSphere))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT1', 'PBX_RegenSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT2', 'PBX_RegenSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_RegenSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_RegenSphere', 255, 1);

            handler.InjectSpawn('PB_MediSpawnerT4', 'PBX_RegenSphere', 255, 1);
        }
        
        if(!CheckFlag(powerupsFlag,DisableTimeSphere))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_TimeSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT4', 'PBX_TimeSphere', 255, 1);
            handler.InjectSpawn('PB_InvulSpawnerT4', 'PBX_TimeSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableRedSoul))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT1', 'PBX_RedSoulSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT2', 'PBX_RedSoulSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_RedSoulSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_RedSoulSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableDarkMega))
        {
            handler.InjectSpawn('PB_MegaSpawnerT1', 'PBX_DarkMegaSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT2', 'PBX_DarkMegaSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT3', 'PBX_DarkMegaSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT4', 'PBX_DarkMegaSphere', 255, 1);

        }

        if(!CheckFlag(powerupsFlag,DisableHaste))
        {
            handler.InjectSpawn('PB_BlurSpawnerT1', 'PB_Haste', 255, 1);
            handler.InjectSpawn('PB_BlurSpawnerT2', 'PB_Haste', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableQuadDamage))
        {
            handler.InjectSpawn('PB_BlurSpawnerT3', 'PB_Doomsphere', 255, 1);
            handler.InjectSpawn('PB_BlurSpawnerT4', 'PB_Doomsphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableFrostAura))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_FrostAuraSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_FrostAuraSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT2', 'PBX_FrostAuraSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT3', 'PBX_FrostAuraSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableFireAura))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_FireAuraSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_FireAuraSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT2', 'PBX_FireAuraSphere', 255, 1);
            handler.InjectSpawn('PB_MegaSpawnerT3', 'PBX_FireAuraSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableFlightSphere))
        {
            handler.InjectSpawn('PB_SoulSphereSpawnerT3', 'PBX_FlightSphere', 255, 1);
            handler.InjectSpawn('PB_SoulSphereSpawnerT4', 'PBX_FlightSphere', 255, 1);
        }

        if(!CheckFlag(powerupsFlag,DisableAdrenaline))
        {
            handler.InjectSpawn('PB_BerserkSpawnerT1', 'PBX_Adrenaline', 255, 1);
            handler.InjectSpawn('PB_BerserkSpawnerT2', 'PBX_Adrenaline', 255, 1);
            handler.InjectSpawn('PB_BerserkSpawnerT3', 'PBX_Adrenaline', 255, 1);
            handler.InjectSpawn('PB_BerserkSpawnerT4', 'PBX_Adrenaline', 255, 1);
        }
    }
}