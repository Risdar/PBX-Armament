class ExterminatorHandler : EventHandler
{
    override void WorldThingDamaged(WorldEvent e)
    {
        let src = e.DamageSource;
        let thing = e.Thing;
		let inflictor = e.inflictor;

        if (!src || !thing) return;

        if (inflictor && thing.bISMONSTER && thing.Health <= 0 && CheckForSoulsNoDemon2(thing))
        {
            if (src.CountInv("SoulCharge") < src.GetAmmoCapacity("SoulCharge"))
            {
                src.GiveInventory("SoulCharge", PBX_DemonExt.SOUL_GAIN);
                if (IsValidInflictor(inflictor))
                    src.GiveInventory("SoulCharge", PBX_DemonExt.SOUL_GAIN);
            }
        }
        else if (!inflictor && src is "PlayerPawn")
        {
            if (src.CountInv("SoulCharge") < src.GetAmmoCapacity("SoulCharge"))
                src.GiveInventory("SoulCharge", PBX_DemonExt.SOUL_GAIN/2);
        }
    }

	bool mArtifactSpawned;
    override void WorldLoaded(WorldEvent e)
	{
		if(mArtifactSpawned || (PBX_BackPack_filter & DisablePBX_DemonExtArtifacts) || !mShouldSpawnArtifact) 
        {
            PBXCore_Debug.Print("Artifact NOT Spawned!");
            return;
        }

		for (int i = 0; i < level.Sectors.Size(); ++i)
		{
			if(mArtifactSpawned) return;
			
			Sector CurrSec = level.Sectors[i];
			vector3 SpawnPos = (CurrSec.centerspot.x, CurrSec.centerspot.y, CurrSec.floorplane.ZAtPoint(CurrSec.centerspot));
			
			if (CurrSec.IsSecret() && !mArtifactSpawned)
			{
				Actor.Spawn("DemonExtArtifactSpawner", SpawnPos);
                PBXCore_Debug.Print("Artifact Spawned!");
				mArtifactSpawned = true;
                mShouldSpawnArtifact = false;
			}			
		}
	}

    bool mShouldSpawnArtifact;
    bool mPlayerAlreadyHaveOneArtifact;
    Override void PlayerEntered(PlayerEvent e)
    {
		// Get player pointer
        let pm = players[e.PlayerNumber].mo;
		if(!pm) return;

		// Dont continue if its the titlemap
        if (level.MapName == "TITLEMAP") return;

        // Check if any player has the demonic exterminator
        if(!pm.FindInventory("PBX_DemonExt")) 
        {
            PBXCore_Debug.Print("No DemonExt detected");
            return;
        }

        if(pm.FindInventory("ArtifactIncinerator"))
        {
            PBXCore_Debug.Print("Artifact A detected");
            mPlayerAlreadyHaveOneArtifact = true;
        }

        if(pm.FindInventory("ArtifactLightning"))
        {
            PBXCore_Debug.Print("Artifact B detected");
            mShouldSpawnArtifact = false;
            return;
        }

        mShouldSpawnArtifact = true;
    }

    private 
	bool IsValidInflictor(Actor inflictor)
    {
        return
            inflictor is "UNMK_DExtActor"               || inflictor is "UNMK_DExtFastProjectile"  ||
            inflictor is "Unmaker64Puff"                || inflictor is "DemonExterminatorEnergyBlast" ||
            inflictor is "Hellbullet"                   || inflictor is "Hellbullet2"              ||
            inflictor is "ShrinkBeam"                   || inflictor is "CausticGreenPlasmaBall"   ||
            inflictor is "ACIDFOGSHRINK"                || inflictor is "GreenCloudMediumShrink"   ||
            inflictor is "GreenCloudSmallShrink"        || inflictor is "UnmakerLaser"             || 
			inflictor is "UnmakerDoomSeeker"            || inflictor is "OverchargeLaser"          || 
			inflictor is "OverchargeGroundSpike"        || inflictor is "PlayerPawn";
    }

    private
	bool CheckForSoulsNoDemon2(Actor monster)
    {
        bool isDemonType =
            monster is "Arachnotron"       || monster is "Archvile"        ||
            monster is "BaronOfHell"       || monster is "Cacodemon"       ||
            monster is "Cyberdemon"        || monster is "Demon"           ||
            monster is "DoomImp"           || monster is "Fatso"           ||
            monster is "HellKnight"        || monster is "SpiderMastermind";

        bool isFormerHuman =
            monster is "PB_ZombieMan"      || monster is "PB_ShotgunGuy"   ||
            monster is "PB_Commando"       || monster is "PB_Nazi"         ||
            monster is "Revenant"          || monster is "PB_Revenant"     ||
            monster is "LostSoul"          || monster is "PainElemental"   ||
            monster.GetSpecies() == "Nazi" || monster.GetSpecies() == "Former_Human";

        bool isNotPBNative = !(monster is "PB_Monster");

        return (isFormerHuman || isNotPBNative) && !isDemonType;
    }
}

class DemonExtArtifactSpawner : PBRandomSpawner
{
	Default
	{
		DropItem 'ArtifactSpawner', 255, 1;
	}
}

class ArtifactSpawner : PB_WeaponSpawner
{
    Default
    {
        DropItem 'ArtifactIncinerator', 255, 1;
        DropItem 'ArtifactLightning', 255, 1;
    }

    override bool HandleSpawnExceptions(name toSpawn)
    {
        bool haveArtifact = PlayerAlreadyHasArtifact();

        // B can't spawn until A has been found.
        if (toSpawn == 'ArtifactLightning' && !haveArtifact)
            return false;

        // A stops spawning once the player already has one.
        if (toSpawn == 'ArtifactIncinerator' && haveArtifact)
            return false;

        return true;
    }

    bool PlayerAlreadyHasArtifact()
    {
        let handler = ExterminatorHandler(EventHandler.Find("ExterminatorHandler"));
        return (handler && handler.mPlayerAlreadyHaveOneArtifact);
    }
}

class ArtifactIncinerator : Inventory
{
    Default
    {
        Inventory.Pickupmessage "$PBX_DemonExt_IncinArtifact";
        Inventory.PickupSound "UNMPCK";
        inventory.maxamount 1;
        Tag "$PBX_DemonExt_IncinArtifact";
    }

    States
    {
        Spawn:
            PIEC A -1;
            Stop;
    }
}

class ArtifactLightning : Inventory
{
    Default
    {
        Inventory.Pickupmessage "$PBX_DemonExt_LightningArtifact";
        Inventory.PickupSound "UNMPCK";
        inventory.maxamount 1;
        Tag "$PBX_DemonExt_LightningArtifact";
    }

    States
    {
        Spawn:
            PIEC D -1;
            Stop;
    }
}