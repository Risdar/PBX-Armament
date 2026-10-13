enum PBXWeapons_eWeaponSpecialSpawns
{
////// Backpacks / Upgrades /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	DisablePBX_CSSGUpgrades			        = 1 << 0 // Actually spawns on the ShellBox spawner
	,DisablePBX_MetalSniperUpgrade			= 1 << 1
	,DisablePBX_LeverActionUpgrade			= 1 << 2
	,DisablePBX_CrossbowBallistaUpgrade		= 1 << 3
	,DisablePBX_UACBackpack					= 1 << 4
	,DisablePBX_ExcavatorUpgrade			= 1 << 5
	,DisablePBX_DemonExtArtifacts			= 1 << 6
////// Monster Drops /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// SLOT 6
	,DisablePBX_CyberdemonRL			    = 1 << 0
	,DisablePBX_MastermindCG			    = 1 << 1
////// Secret Weapons /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	,DisablePBX_EternalChaingun			    = 1 << 0
	,DisablePBX_NukeLauncher		        = 1 << 1
	,DisablePBX_HexaShotgun					= 1 << 2 
	,DisablePBX_MiniShotgun					= 1 << 3  
////// Weapon Edits /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	,DisablePBX_SGLEdit					    = 1 << 0
	,DisablePBX_LMGEdit					    = 1 << 1  
	,DisablePBX_ChainsawEdit				= 1 << 2  
}

enum PBXWeapons_eShotgunSpawns
{
////// SLOT 2  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	DisablePBX_LeverActionRifle				= 1 << 0
	,DisablePBX_PlasmaBlaster				= 1 << 1
////// SLOT 3  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	,DisablePBX_SPAS12						= 1 << 2
////// SLOT 4  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	,DisablePBX_CrossbowBallista			= 1 << 3
}

enum PBXWeapons_eSSGSpawns
{
////// SLOT 3 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	DisablePBX_CSSG			                = 1 << 0
}

enum PBXWeapons_eChaingunSpawns
{
	DisablePBX_BattleRifle					= 1 << 0 // Slot 4
	,DisablePBX_MetalSniper			        = 1 << 1 // Slot 4
	,DisablePBX_NeoHMG			        	= 1 << 2 // Slot 5
	,DisablePBX_SuperNailgun			    = 1 << 3 // Slot 5
	,DisablePBX_XM21			        	= 1 << 4 // Slot 4
}

enum PBXWeapons_eRocketLauncherSpawns
{
////// SLOT 6 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	DisablePBX_Excavator			        = 1 << 0
	,DisablePBX_Paingiver			        = 1 << 1
}

enum PBXWeapons_ePlasmaRifleSpawns
{
////// SLOT 3 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	DisablePBX_CryoSG						= 1 << 2
	,DisablePBX_CryoASG						= 1 << 3
////// SLOT 7 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	,DisablePBX_BDPRailgun					= 1 << 0
////// SLOT 8 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	,DisablePBX_TeslaGun					= 1 << 1
	,DisablePBX_FreezeRifle					= 1 << 4
}

enum PBXWeapons_eBFGSpawns
{
////// SLOT 9 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	DisablePBX_DemonExt			            = 1 << 0
}
//////////////////////////// CHAINSAW ////////////////////////////////////////////////////////////////////////////////////


//////////////////////////// PISTOL ////////////////////////////////////////////////////////////////////////////////////


//////////////////////////// SHOTGUN ////////////////////////////////////////////////////////////////////////////////////
class PBXShotgun_Injector : PBInjector
{
	override void Init(PB_EventHandler handler)
	{
		// Plasma Blaster
		if(!(pbxweapons_shotgun_filter & DisablePBX_PlasmaBlaster))
		{
			handler.InjectSpawn('PB_ShotSpawnerT2', 'PBX_PlasmaBlaster', 255, 1);
		}
		// Lever Action
		if(!(pbxweapons_shotgun_filter & DisablePBX_LeverActionRifle))
		{
			handler.InjectSpawn('PB_ShotSpawnerT1', 'PBX_Prosurv_LeverAction', 255, 1);
			handler.InjectSpawn('PB_ShotSpawnerT2', 'PBX_Prosurv_LeverAction', 255, 1);
			handler.InjectSpawn('PB_ShotSpawnerT3', 'PBX_Prosurv_LeverAction', 255, 1);
		}
		// SPAS12
		if(!(pbxweapons_shotgun_filter & DisablePBX_SPAS12))
		{
			handler.InjectSpawn('PB_ShotSpawnerT2', 'PBX_SPAS12', 255, 1);
		}
		// Crossbow Ballista
		if(!(pbxweapons_shotgun_filter & DisablePBX_CrossbowBallista))
		{
			handler.InjectSpawn('PB_ShotSpawnerT1', 'PBX_Prosurv_Ballista', 255, 1);
			handler.InjectSpawn('PB_ShotSpawnerT2', 'PBX_Prosurv_Ballista', 255, 1);
		}
	}
}

//////////////////////////// SSG ////////////////////////////////////////////////////////////////////////////////////
class PBXSSG_Injector : PBInjector
{
	override void Init(PB_EventHandler handler)
	{
		// CSSG
		if(!(pbxweapons_ssg_filter & DisablePBX_CSSG))
		{
			handler.InjectSpawn('PB_SSGSpawnerT3', 'PBX_CSSG', 255, 1);
			handler.InjectSpawn('PB_SSGSpawnerT4', 'PBX_CSSG', 255, 1);
		}
	}
}

//////////////////////////// CHAINGUN ////////////////////////////////////////////////////////////////////////////////////
class PBXChaingun_Injector : PBInjector
{
	override void Init(PB_EventHandler handler)
	{
		// Battle Rifle
		if(!(pbxweapons_chaingun_filter & DisablePBX_BattleRifle))
		{
			handler.InjectSpawn('PB_MGSpawnerT1', 'PBX_BDPBattleRifle', 255, 1);
			handler.InjectSpawn('PB_MGSpawnerT2', 'PBX_BDPBattleRifle', 255, 1);
		}
		// Metal Sniper
		if(!(pbxweapons_chaingun_filter & DisablePBX_MetalSniper))
		{
			handler.InjectSpawn('PB_MGSpawnerT3', 'PBX_MetalSniper', 255, 1);
		}
		// XM21 
		if(!(pbxweapons_chaingun_filter & DisablePBX_XM21))
		{
			handler.InjectSpawn('PB_MGSpawnerT4', 'PBX_XM21', 255, 1);
		}
		// Neo HMG
		if(!(pbxweapons_chaingun_filter & DisablePBX_NeoHMG))
		{
			handler.InjectSpawn('PB_MGSpawnerT3', 'PBX_NeoHMG', 255, 1);
			handler.InjectSpawn('PB_MGSpawnerT4', 'PBX_NeoHMG', 255, 1);
		}
		// Super Nailgun
		if(!(pbxweapons_chaingun_filter & DisablePBX_SuperNailgun))
		{
			handler.InjectSpawn('PB_MGSpawnerT4', 'PBX_SuperNailgun', 255, 1);
		}
		
	}
}

//////////////////////////// ROCKETLAUNCHER ////////////////////////////////////////////////////////////////////////////////////
class PBXRocketLauncher_Injector : PBInjector
{
	override void Init(PB_EventHandler handler)
	{
		// Excavator
		if(!(pbxweapons_rocketlauncher_filter & DisablePBX_Excavator))
		{
			handler.InjectSpawn('PB_RLSpawnerT3', 'PBX_Excavator', 255, 1);
			handler.InjectSpawn('PB_RLSpawnerT4', 'PBX_Excavator', 255, 1);
		}
		// Paingiver
		if(!(pbxweapons_rocketlauncher_filter & DisablePBX_Paingiver))
		{
			handler.InjectSpawn('PB_RLSpawnerT4', 'PBX_Paingiver', 255, 1);
		}
	}
}
//////////////////////////// PLASMARIFLE ////////////////////////////////////////////////////////////////////////////////////
class PBXPlasma_Injector : PBInjector
{
    override void Init(PB_EventHandler handler)
    {
		// BDP Railgun
		if(!(pbxweapons_plasmarifle_filter & DisablePBX_BDPRailgun))
		{
		   handler.InjectSpawn("PB_PlasSpawnerT2","PBX_BDPRailgun",255,1);
		}
		// Tesla Gun
		if(!(pbxweapons_plasmarifle_filter & DisablePBX_TeslaGun))
		{
		   handler.InjectSpawn("PB_PlasSpawnerT3","PBX_TeslaGun",255,1);
		}
		// Cryo SG
		if(!(pbxweapons_plasmarifle_filter & DisablePBX_CryoSG))
		{
		   handler.InjectSpawn("PB_PlasSpawnerT2","PBX_CryoSG",255,1);
		}
		// Cryo ASG
		if(!(pbxweapons_plasmarifle_filter & DisablePBX_CryoASG))
		{
		   handler.InjectSpawn("PB_PlasSpawnerT4","PBX_CryoASG",255,1);
		}
		// Freze Rifle 
		if(!(pbxweapons_plasmarifle_filter & DisablePBX_FreezeRifle))
		{
		   handler.InjectSpawn("PB_PlasSpawnerT2","PBX_FreezeRifle",255,1);
		}
    }
}
//////////////////////////// BFG ////////////////////////////////////////////////////////////////////////////////////
class PBXBFG_Injector : PBInjector
{
    override void Init(PB_EventHandler handler)
    {
		// Demon Ext
		if(!(pbxweapons_bfg_filter & DisablePBX_DemonExt))
		{
		   handler.InjectSpawn("PB_BFGSpawnerT1","PBX_DemonExt",255,1);
		}

		// Secret Weapons
		if(pbxweapons_secretweapon_bfgspawn)
		{
			handler.InjectSpawn("PB_BFGSpawnerT1","PBX_NukeLauncher",255,1);
			handler.InjectSpawn("PB_BFGSpawnerT1","PBX_HexaShotgun",255,1);
			handler.InjectSpawn("PB_BFGSpawnerT1","PBX_MiniShotgun",255,1);
			handler.InjectSpawn("PB_BFGSpawnerT1","PBX_EternalMinigun",255,1);
		}
    }
}
//////////////////////////// BACKPACKS ////////////////////////////////////////////////////////////////////////////////////
class PBXUpgrades_Injector : PBInjector
{
    override void Init(PB_EventHandler handler)
    {
		// UAC Backpack
		if(!(pbxweapons_backpack_filter & DisablePBX_UACBackpack))
		{
			handler.InjectSpawn('PB_PackSpawnerT1', 'PBX_CommandPack', 255, 1);
		}

		// CSSG Upgrades
		if(!(pbxweapons_backpack_filter & DisablePBX_CSSGUpgrades))
		{
			handler.InjectSpawn('PB_ShellboxSpawnerT3', 'WPShellsUpgrade', 255, 1);
			handler.InjectSpawn('PB_ShellboxSpawnerT3', 'SubZeroShellsUpgrade', 255, 1);
			handler.InjectSpawn('PB_ShellboxSpawnerT3', 'DanmakuShellsUpgrade', 255, 1);
			handler.InjectSpawn('PB_ShellboxSpawnerT3', 'ExplosiveShellsUpgrade', 255, 1);
			handler.InjectSpawn('PB_ShellboxSpawnerT4', 'AcidShellsUpgradePickup', 255, 1);
			handler.InjectSpawn('PB_ShellboxSpawnerT4', 'DoomShellsUpgrade', 255, 1);
			handler.InjectSpawn('PB_ShellboxSpawnerT4', 'HellFireShellsUpgrade', 255, 1);
		}
		
		// Metal Sniper Upgrade
		if(!(pbxweapons_backpack_filter & DisablePBX_MetalSniperUpgrade))
		{
			handler.InjectSpawn('PB_UpgradeSpawnerT4', 'MetalSniper_Upgrade', 255, 1);
			handler.InjectSpawn('PB_MGSpawnerT4', 'MetalSniper_Upgrade', 255, 1);
		}

		// Lever Action Upgrade
		if(!(pbxweapons_backpack_filter & DisablePBX_LeverActionUpgrade))
		{
			handler.InjectSpawn('PB_ShotSpawnerT3', 'LeverAction_Upgrade', 255, 1);
			handler.InjectSpawn('PB_UpgradeSpawnerT3', 'LeverAction_Upgrade', 255, 1);
		}

		// Crossbow Ballista Upgrades
		if(!(pbxweapons_backpack_filter & DisablePBX_CrossbowBallistaUpgrade))
		{
			handler.InjectSpawn('PB_ShotSpawnerT2', 'PBX_DemonicBallistaUpgrade', 255, 1);
			handler.InjectSpawn('PB_UpgradeSpawnerT2', 'PBX_DemonicBallistaUpgrade', 255, 1);
		}

		// Crossbow Ballista Upgrades
		if(!(pbxweapons_backpack_filter & DisablePBX_ExcavatorUpgrade))
		{
			handler.InjectSpawn('PB_RLSpawnerT3', 'PBX_ExcavatorUpgrade', 255, 1);
			handler.InjectSpawn('PB_UpgradeSpawnerT3', 'PBX_ExcavatorUpgrade', 255, 1);
		}
    }
}

//////////////////////////// OTHER TYPES ////////////////////////////////////////////////////////////////////////////////////
class PBXWeapons_SecretWeaponHandler : EventHandler
{
	bool mSecretWeaponSpawned;

	override void WorldLoaded(WorldEvent e)
	{
		PBX_SpawnSecretWeapons();
	}

	private
	void PBX_SpawnSecretWeapons()
	{
		// Only do it once
		if(mSecretWeaponSpawned || !pbxweapons_enablesecretweapon) return;

		int mSpawnChance = random(1,100);
		if(mSpawnChance > pbxweapons_secretweapon_spawnchance) //5% chance of spawning by default
		{
			PBXCore_Debug.PrintInt("PBXWeapons_SecretWeaponSpawner not Spawned!, got %d",mSpawnChance);
			return;
		}

		for (int i = 0; i < level.Sectors.Size(); ++i)
		{
			if(mSecretWeaponSpawned) return;
			
			Sector CurrSec = level.Sectors[i];
			vector3 SpawnPos = (CurrSec.centerspot.x, CurrSec.centerspot.y, CurrSec.floorplane.ZAtPoint(CurrSec.centerspot));
			
			if (CurrSec.IsSecret() && !mSecretWeaponSpawned)
			{
				Actor.Spawn("PBXWeapons_SecretWeaponSpawner", SpawnPos);
                PBXCore_Debug.Print("PBXWeapons_SecretWeaponSpawner Spawned!");
				mSecretWeaponSpawned = true;
			}			
		}
	}

	override void WorldThingDied (WorldEvent e)
    {
        if (!e || !e.thing) return;
        let mActor = e.Thing;
		name mMonsterName = mActor.getClassName();

        // Check and Spawn
        switch(mMonsterName)
        {
            case 'PB_Cyberdemon1': case 'PB_Cyberdemon1GK': case 'PB_Cyberdemon':
			case 'PB_Annihilator': case 'PB_AnnihilatorGK':
                if(!(PBXWeapons_monsterdrop_filter & DisablePBX_CyberdemonRL))
                { 
					PBXCore_Debug.PrintString("Spawning CyberdemonRL from %s", mMonsterName);
                   	actor.spawn("PBX_CyberdemonRL", mActor.pos);
                } 
                break;

			case 'PB_Mastermind': case 'PB_MastermindGK': 
			case 'PB_Demolisher': case 'PB_DemolisherGK':
                if(!(PBXWeapons_monsterdrop_filter & DisablePBX_MastermindCG))
                { 
					PBXCore_Debug.PrintString("Spawning MastermindCG from %s", mMonsterName);
                   	actor.spawn("PBX_MastermindChaingun", mActor.pos);
					// Since the demolisher has two chainguns
					if(mMonsterName == 'PB_Demolisher' || mMonsterName== 'PB_DemolisherGK')
                   		actor.spawn("PBX_MastermindChaingun", mActor.pos);
                } 
                break;

        }
    }

	
}

class PBXWeapons_SecretWeaponSpawner : PB_WeaponSpawner
{
	Default
	{
		DropItem 'PBX_NukeLauncher', 255, 1;
		DropItem 'PBX_HexaShotgun', 255, 1;
		DropItem 'PBX_MiniShotgun', 255, 1;
		DropItem 'PBX_EternalMinigun', 255, 1;
	}

	override bool HandleSpawnExceptions(name toSpawn)
	{
		if(toSpawn == "PBX_NukeLauncher" && (PBXWeapons_specialdrop_filter & DisablePBX_NukeLauncher))
			return false;
		if(toSpawn == "PBX_HexaShotgun" && (PBXWeapons_specialdrop_filter & DisablePBX_HexaShotgun))
			return false;
		if(toSpawn == "PBX_MiniShotgun" && (PBXWeapons_specialdrop_filter & DisablePBX_MiniShotgun))
			return false;
		if(toSpawn == "PBX_EternalMinigun" && (PBXWeapons_specialdrop_filter & DisablePBX_EternalChaingun))
			return false;
		return true;
	}

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		console.printf(StringTable.Localize("$PBX_SecretWeaponSpawned"));
	}
}

class PBX_CommandPack : CustomInventory
{
    Default
    {
        Inventory.Amount 1;
        Inventory.PickupMessage "$PBX_CommandPack_Pickup";
		Inventory.PickupSound "CLIPIN";
		Tag "$PBX_CommandPack_Tag";
        +Inventory.AlwaysPickUp;
        +FLOORCLIP;
        +DONTGIB;
    }

    States
    {
        Spawn:
            XPCK A -1;
            Stop; 

        Pickup:
            TNT1 A 0 {
				A_GiveInventory("PB_Backpack",1);
				A_GiveInventory("PBX_NormalRifle",1);
				A_GiveInventory("PBX_ProSurvPSG",1);
				A_GiveInventory("PB_RocketAmmo",20);
			}
            Stop;
    }
}

class PBXWeapons_WeaponEditHandler : EventHandler
{
    override void CheckReplacement(ReplaceEvent e) 
	{
		// Always replace since the exception code is in the weapon itself
        switch(e.Replacee.GetClassName())
        {
            case 'PB_SuperGL':      
                e.Replacement  = "PBX_SGLEdited";  
                break;

            case 'PB_LMG':          
                e.Replacement  = "PBX_LMGEdited";  
                break;

			case 'PB_Chainsaw':          
                e.Replacement  = "PBX_ChainsawEdited";  
                break;
        }
    }

    // Because scientists also drop chainsaws
    override void WorldThingSpawned (WorldEvent e)
    {
        if (!e || !e.thing) return;
        let act = e.Thing;

        if(act && act.getClassName() == "PB_Chainsaw") 
        {
            act.Spawn("PBX_ChainsawEdited",act.pos);
            act.Destroy();
        }
    }

}

class PBXWeapons_WeaponEditSpawner : PBInjector
{
	override void Init(PB_EventHandler handler)
	{
        if(!PBXWeapons_EnableWeaponEdits)
        {
            return;
        }
        
        if(!(PBXWeapons_WeaponEditsFlags & DisablePBX_SGLEdit))
        {
            handler.InjectSpawn('PB_UpgradeSpawnerT3', 'SGL_Upgrade', 255, 1);
            handler.InjectSpawn('PB_RLSpawnerT3', 'SGL_Upgrade', 255, 1);
        }

        if(!(PBXWeapons_WeaponEditsFlags & DisablePBX_LMGEdit))
        {
            handler.InjectSpawn('PB_UpgradeSpawnerT3', 'LMG_Upgrade', 255, 1);
		    handler.InjectSpawn('PB_MGSpawnerT3', 'LMG_Upgrade', 255, 1);
        }
		
	}
}