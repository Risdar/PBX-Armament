// Laser Charge, Swarm Charge, Acid Charge sprites are from LitDoom by Skadi and the LitDoom team modified by ThePopeOfDope

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

	action void detonate(bool det = true)
	{
		if(det) A_startsound("bepbep",CHAN_AUTO,CHANF_OVERLAP);
		A_SetInventory("RemoteChargeDetonator",det);
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
