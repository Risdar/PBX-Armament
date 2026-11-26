#include "./PBX_Player.zs"
#include "./PBX_Lightning.zs" //Lightning Library by jekyllgrim
#include "./PBX_BeamZ.zs" // BEAMZ by Lewis3k

#include "./Spawners/PBX_Spawners.zs"
#include "./HUD/PBX_HUD.zs"

// Big thanks to EmeraldCoastt and the BDP team for this
#include "./MathsNMixins/Includes.zsc"

#include "./Gameplay/PBX_BackpackReload.zs"
#include "./Gameplay/PBX_PrevWeapon.zs"
#include "./Gameplay/PBX_DamageIndicators.zs"
#include "./Gameplay/PBX_DamageFlashes.zs"
#include "./Gameplay/PBX_HitFeedback.zs"

class PBX_Handler : EventHandler
{
    Override void PlayerEntered(PlayerEvent e)
    {
		GivePlayerItems(e);
    }

	private
	play void GivePlayerItems(PlayerEvent e)
	{
		// Get player pointer
        let pm = players[e.PlayerNumber].mo; 
		if(!pm) return;

		// Dont continue if its the titlemap
        if (level.MapName == "TITLEMAP") 
        {
            return;
        }

        if(PBX_CVAR_ASSAULT_RIFLE_START) 
        {
            pm.giveinventory("PBX_NormalRifle",1);
        }

		if(PBX_CVAR_CROSSBOW_START) 
        {
            pm.giveinventory("PBX_Prosurv_Ballista",1);
        }

        // Always give the backpack reload behavior
        // since the toggle code is in the behavior itself
        if (!pm.FindBehavior("PBX_BackpackReloadBehavior"))
        {
            pm.AddBehavior("PBX_BackpackReloadBehavior");
        }
	}

}

class PBX_PrintVersion : StaticEventHandler
{
    bool hasPrintedVersion;

    // These three Arrays are paired
    // Contains the name of classes to check
    static const string CHECKED_CLASSES[] =
    {
        "PB_BaronGK"
        ,"BehemothGasTankTargetBase"
        ,"UV_HudVisorDraw"
    };
    // Contains the name of the CVar that should be set
    static const name LOADED_CVARS[] =
    {
        'PBX_COMPAT_GLORYKILL'
        ,"PBX_COMPAT_MONSTERPACK"
        ,'PBX_COMPAT_ULTIMATEVISOR'
    };
    // What will be printed
    static const string COMPAT_STRINGS[] =
    {
        "$PBX_COMPAT_GLORYKILL"
        ,"$PBX_COMPAT_MONSTERPACK"
        ,"$PBX_COMPAT_ULTIMATEVISOR"
    };

    // When the world has been loaded (basically on the titlemap)
    // Check the existing classes and if they exist and set the CVars accordingly
    override void WorldLoaded(WorldEvent e)
    {
        if(hasPrintedVersion || e.IsSaveGame || e.IsReopen) return;
        for (int i = 0; i < CHECKED_CLASSES.Size(); i++)
        {
            bool loaded = FindClass(CHECKED_CLASSES[i]) != null;
            CVar.FindCVar(LOADED_CVARS[i]).SetBool(loaded);
        }
    }

    Override void PlayerEntered(PlayerEvent e)
    {
		PrintVersion();
    }

    private
	void PrintVersion()
	{
		if(hasPrintedVersion) return;
        if (level.MapName == "TITLEMAP") return;

        let plr = players[consoleplayer];
        if (!plr) return;

        // Dont print the versions if the option is disabled
        if (!CVar.GetCVar('PBX_SHOW_VERSION', plr).GetBool()) return;

        // Print the Core version
        PB_HelpNotificationsHandler.PB_SendTip("$PBX_VERSION", "PBX_EMPTY_FLAG", 0);

        // Print the other PBX Modules
        for (int i = 0; i < LOADED_CVARS.Size(); i++)
        {
            if (CVar.FindCVar(LOADED_CVARS[i]).GetBool())
                PB_HelpNotificationsHandler.PB_SendTip(COMPAT_STRINGS[i], "PBX_EMPTY_FLAG", 0);
        }

        hasPrintedVersion = true;
	}
}

// For easier testing, though you can also disable the upgrades in the backpack spawners
// and it will bypass the upgrade requirements
// to use these cheats just type "netevent <insert cheat name here>" in the console
Class PBX_Cheats_Handler : Eventhandler
{	
	override void NetworkProcess(ConsoleEvent e)
	{
		let pm = players[e.player].mo;
		if(!pm) return;
			
		if (e.Name ~== "CM_AllShells")
		{
			pm.giveinventory("ExplosiveShellsUpgrade",1);
			pm.giveinventory("WPShellsUpgrade",1);
			pm.giveinventory("DoomShellsUpgrade",1);
			pm.giveinventory("DragonBreathUpgrade",1);
			pm.giveinventory("DanmakuUpgrade",1);
			pm.giveinventory("SubZeroUpgrade",1);
			console.printf("[PBX] Gave all CSSG shells");
			let minisg = PBX_MiniShotgun(pm.FindInventory("PBX_MiniShotgun"));
			if(minisg)
			{
				minisg.buildShellArray(); // So it updates
			}
		}

		if (e.Name ~== "PBX_AllUpgrades")
		{
			// Lever Action
			pm.giveinventory("LeverAction_Upgrade",1);

			// CSSG
			pm.giveinventory("ExplosiveShellsUpgrade",1);
			pm.giveinventory("WPShellsUpgrade",1);
			pm.giveinventory("DoomShellsUpgrade",1);
			pm.giveinventory("DragonBreathUpgrade",1);
			pm.giveinventory("DanmakuUpgrade",1);
			pm.giveinventory("SubZeroUpgrade",1);
			pm.giveinventory("HellFireShellsUpgrade",1);
			pm.giveinventory("AcidShellsUpgradePickup",1);

			// Metal Sniper
			pm.giveinventory("MetalSniper_Upgrade",1);

			// Crossbow Ballista
			pm.giveinventory("PBX_DemonicBallistaUpgrade",1);

			// Excavator Upgrade
			pm.giveinventory("PBX_ExcavatorUpgrade",1);
			
			// Extermination Unmaker
			pm.giveinventory("ArtifactIncinerator",1);
			pm.giveinventory("ArtifactLightning",1);

            // Weapon Edits
			pm.giveinventory("SGL_Upgrade",1);
			pm.giveinventory("LMG_Upgrade",1);
			pm.giveinventory("PBX_ChainsawEdited",1);

			console.printf("[PBX] Gave all weapon upgrades");
		}
		
        // if (e.Name ~== "PBX_AllPowerups")
		// {
		// 	pm.giveinventory("PB_PowerInvul",1);
		// 	pm.giveinventory("PB_PowerIronFeet",1);
		// 	pm.giveinventory("PB_PowerInvis",1);
		// 	pm.giveinventory("PB_PowerLightAmp",1);
		// 	pm.giveinventory("PB_PowerDoomDamage",1);
		// 	pm.giveinventory("PB_PowerSpeed",1);

		// 	pm.giveinventory("PBX_PowerInvisTainted",1);
		// 	pm.giveinventory("PBX_PowerInvulTainted",1);
		// 	pm.giveinventory("PBX_PowerTaintedRegen",1);

		// 	pm.giveinventory("PBX_PowerDeflect",1);
		// 	pm.giveinventory("PBX_PowerBuddha",1);
		// 	pm.giveinventory("PBX_PowerDrain",1);
		// 	pm.giveinventory("PBX_PowerFlight",1);
		// 	pm.giveinventory("PBX_PowerFrightener",1);
		// 	pm.giveinventory("PBX_PowerHighJump",1);
		// 	pm.giveinventory("PBX_PowerInfiniteAmmo",1);
		// 	pm.giveinventory("PBX_PowerProtection",1);
		// 	pm.giveinventory("PBX_PowerReflection",1);
		// 	pm.giveinventory("PBX_PowerRegeneration",1);
		// 	pm.giveinventory("PBX_PowerTimeFreezer",1);

		// 	pm.giveinventory("PBX_PowerElectAura",1);
		// 	pm.giveinventory("PBX_PowerFrostAura",1);
		// 	pm.giveinventory("PBX_PowerFireAura",1);
		// }
	}
}

// Holds all the powerup duration, you can also check any cvar
// Call in BeginPlay()
struct PBXCore_Duration
{
	// Just in case
	static int GetByCVar(name cvr)
    {
        let c = CVar.FindCVar(cvr);
        int mResult = c ? c.GetInt() * Object.TICRATE : 1;  // So its always in seconds
        PBXCore_Debug.PrintInt("Getting CVar %d",mResult);
        return mResult;
    }

    static int GetByCVarInSeconds(name cvr)
    {
        let c = CVar.FindCVar(cvr);
        int mResult = c ? c.GetInt() : 1; // If the cvar is already in seconds
        PBXCore_Debug.PrintInt("Getting CVar in seconds %d",mResult);
        return mResult; 
    }

}

// Debuging
struct PBXCore_Debug
{
    static void Print(string st)
    {
        if(!PBX_DEBUG) return;
        console.printf(st);
    }

    static void PrintInt(string st, int mArg)
    {
        if(!PBX_DEBUG) return;
        console.printf(st,mArg);
    }

    static void PrintString(string st, string mArg)
    {
        if(!PBX_DEBUG) return;
        console.printf(st,mArg);
    }
}

// Inventory item given to the player that handles every Tooltips
class PBXCore_TipsManager : inventory abstract
{
    Default
	{
		// These are just some useful values for an inventory token
		// that make sure it can't be taken away or dropped:
		inventory.maxamount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.PERSISTENTPOWER
	}

    static clearscope void SendTipArrayIfNeeded(Array<String> tipStrings, string cvarName, int tipFlag)
	{
        CVAR shouldSend = CVar.GetCVar("PBX_SEND_TIP");
        if(!shouldSend) return;
        bool send = shouldSend.GetBool();
        if(!send) return;

        CVar name = CVar.GetCvar(cvarName);
        if(!name) return;

		if(!PB_HelpNotificationsHandler.CheckTipEvent(tipFlag, name))
		{
			PB_HelpNotificationsHandler.PB_SendTipArray(tipStrings, cvarName, tipFlag);
		}
	}
}



