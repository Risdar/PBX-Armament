/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2019
 *
 * This file is a part of m_gizmos.
 *
 * m_gizmos is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * m_gizmos is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * m_gizmos.  If not, see <https://www.gnu.org/licenses/>.
 */

// Modified Previous Weapon Handler from m_gizmos

class PBX_PreviousWeaponHandler : EventHandler
{
// public: // EventHandler /////////////////////////////////////////////////////
	override void NetworkProcess(ConsoleEvent e)
	{
		PlayerInfo player = players[e.player];
		if (e.name ~== "PBX_Prev_Weapon") 
		{
			selectPreviousWeapon(player); 
		}
	}

	override void WorldTick()
	{
		PlayerInfo player = players[consolePlayer];
		updatePreviousWeapon(player);
	}

// private: ////////////////////////////////////////////////////////////////////
	private
	void updatePreviousWeapon(PlayerInfo player)
	{
		let ready = player.ReadyWeapon;

		if (!ready)
		{
			return;
		}

		if (currentWeapon != ready)
		{
			previousWeapon = currentWeapon;
		}

		currentWeapon = ready;
	}

	private
	void selectPreviousWeapon(PlayerInfo player)
	{
		if (previousWeapon != NULL && player.ReadyWeapon != previousWeapon)
		{
			player.PendingWeapon = previousWeapon;
		}
	}

// private: ////////////////////////////////////////////////////////////////////

	private Weapon currentWeapon;
	private Weapon previousWeapon;

} // class mg_PreivousWeaponEventHandler

class PBX_Weapons_Handler : EventHandler
{
    Override void PlayerEntered(PlayerEvent e)
    {
		// Get player pointer
        let pm = players[e.PlayerNumber].mo; if(!pm) return;

		// Dont continue if its the titlemap
        if (level.MapName == "TITLEMAP") 
        {
            return;
        }

        if(PBX_Weapons_startwithnormalrifle) 
        {
            pm.giveinventory("PBX_NormalRifle",1);
        }

		if(PBX_Weapons_startwithcrossbow) 
        {
            pm.giveinventory("PBX_Prosurv_Ballista",1);
        }

		if(PBX_BackpackReload_Enable) 
        {
			if (!pm.FindBehavior("PBX_BackpackReloadBehavior"))
			{
				pm.AddBehavior("PBX_BackpackReloadBehavior");
			}
        }

    }
}

// For easier testing, though you can also disable the upgrades in the backpack spawners
// and it will bypass the upgrade requirements
// to use these cheats just type "netevent <insert cheat name here>" in the console
Class PBX_Weapons_CheatsHandler : Eventhandler
{	
	override void NetworkProcess(ConsoleEvent e)
	{
		let pm = players[e.player].mo;
		if(!pm)
			return;
			
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
		
	}
}



