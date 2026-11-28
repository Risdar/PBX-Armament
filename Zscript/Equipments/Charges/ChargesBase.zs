// Laser Charge, Swarm Charge, Acid Charge sprites are from LitDoom by Skadi and the LitDoom team 
// Modified by ThePopeOfDope for Project Survival which the one here is based of off

#include "./SwarmCharge.zs"
#include "./AcidCharge.zs"
#include "./LaserCharge.zs"

class RemoteChargeDetonator : inventory {default{inventory.maxamount 1;}}

class PBX_ChargesBase : PBX_Equipment
{
	Default
	{
		PB_Equipment.SelectSound "GRNPIN";
	}

	override bool UseEquipment()
	{
		// Always activate since empty means trigger detonator
		Use(false);
		return true;
	}

	action void detonate(bool det = true)
	{
		if(det) A_startsound("bepbep",CHAN_AUTO,CHANF_OVERLAP);
		A_SetInventory("RemoteChargeDetonator",det);
	}

	action state checkDetonate()
	{
		if(HasDoubleTapped() || EQ_GetAmount() < 1)
		{
			return resolvestate("Detonate");
		}
		return resolvestate(null);
	}

	States
	{
		// DetonateUnused:
		// 	// TNT1 A 0 EQ_SetWeaponState("FlashPunching");
        //     DETO ABCDE 1;
		// 	TNT1 A 0 detonate();
		// 	DETO FG 3;
		// 	TNT1 A 0 detonate(false);
		// 	DETO EDCBA 1;
        //     TNT1 A 0 PB_ReThrow();
        //     Stop;

		Detonate:
            "####" A 0 detonate();
			"####" GFE 1;
            "####" A 0 detonate(false);
            "####" DCBA 1;
            "####" A 0 PB_ReThrow();
            Stop;
	}
}

////// PICKUPS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class PBX_ChargesPack : CustomInventory
{
    Default
    {
		Scale 0.45;
        Inventory.Amount 1;
        Inventory.PickupMessage "$PBX_EXPRCHRG_PICKUP";
		Inventory.PickupSound "GRNPIN";
		Tag "$PBX_EXPRCHRG_TAG";
        +Inventory.AlwaysPickUp;
        +FLOORCLIP;
        +DONTGIB;
    }

    States
    {
        Spawn:
            6CHP A -1;
            Stop; 

        Pickup:
			TNT1 A 0 {
				Array<String> tips;
                tips.Push(string.format(StringTable.Localize("$PBX_EXPRCHRG_TIP"),PB_HelpNotificationsHandler.PB_FormatKeybinds("+USER1")));
				PBX_Handler.SendTipArrayIfNeeded(tips,EQUIPMENTS_HELPTEXT,PBX_TIP_CHARGES);
			}
            TNT1 A 0 {
				A_GiveInventory("PBX_AcidChargeAmmo",1);
				A_GiveInventory("PBX_LaserChargeAmmo",1);
				A_GiveInventory("PBX_SwarmChargeAmmo",1);
			}
            Stop;
    }
}

