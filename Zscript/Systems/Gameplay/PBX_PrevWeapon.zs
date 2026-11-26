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

class PBX_PreviousWeapon_Handler : EventHandler
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

	static PBX_PreviousWeapon_Handler Get()
    {
        return PBX_PreviousWeapon_Handler(EventHandler.Find('PBX_PreviousWeapon_Handler'));
    }

	Weapon getPreviousWeapon()
	{
		return previousWeapon;
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
		if (previousWeapon != NULL && player.ReadyWeapon != previousWeapon && (previousWeapon == player.mo.FindInventory(previousWeapon.getClass())))
		{
			player.PendingWeapon = previousWeapon;
		}
	}

// private: ////////////////////////////////////////////////////////////////////

	private Weapon currentWeapon;
	private Weapon previousWeapon;

} // class mg_PreivousWeaponEventHandler