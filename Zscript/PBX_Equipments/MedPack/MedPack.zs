class MedPackCard : equipmentCard
{
	override void InfoFiller(out array<string> tags,out array<string> tokens,out array<string> ammotypes,out array<string>img,out array<double>sx,out array<double>sy)
	{
		tags.push("$PB_MEDPACK_TAG");
		tokens.push("PBX_MedPackToken");
		ammotypes.push("PBX_MedPackAmmo");
		img.push("graphics/Equipments/MedPack/MedPack.png");
		sx.push(1.0);
		sy.push(1.0);
	}
}

class PBX_MedPackToken : PBX_Equipment 
{
	Default 
    {
		Inventory.Icon "MEDPAICO";
		PB_Equipment.AmmoType "PBX_MedPackAmmo";
		PB_Equipment.SelectString "$PB_MEDPACK_WHEEL";
		PB_Equipment.SelectSound "GRNPIN";
		PB_Equipment.FailString "$PB_MEDPACK_OUT";
		PB_Equipment.FontColor "White";
	}

	override bool UseEquipment() 
	{
		if(owner.CountInv(AmmoType) >= ammoUse && owner.player.health < 100) 
		{
			Use(false);
			return true;
		}
		else 
		{
			owner.A_Print(owner.player.health >= 100 ? "$PB_MEDPACK_FULL" : failString);
			return false;
		}
	}

    action state syringeLoop()
    {
        if(EQ_GetAmount() >= 1 && PressingUser1() && player.health < 100)
        {
            GiveBody(1,100);
			EQ_TakeAmmo();
            return resolvestate("HoldSyringe");
        }
        return resolvestate(null);
    }

	States 
    {
        UseEquipment:
            SYRI ABCDEFGHIJ 1;
            SYRI A 0 A_StartSound("blodr1",CHAN_AUTO);
            SYRI KLL 1;
            SYRI A 0 A_StartSound("misc/N_HP_pickup",CHAN_AUTO);
        HoldSyringe:
            SYRI MMM 1;
            SYRI M 1 syringeLoop();
            SYRI LK 1;
            SYRI JIHGFEDCBA 1;
        FinishHeal:
		    TNT1 A 0 PB_ReThrow();
            Stop;
	}
}

class PBX_MedPackAmmo : PB_Ammo
{
	Default
	{
		Scale 1.0;
		Tag "$PB_MEDPACK_TAG";
		Inventory.Amount 100;
		Inventory.MaxAmount 100;
		Inventory.PickupSound "BACKPCK";
        Inventory.PickupMessage "$PB_MEDPACK_PICKUP";
		Inventory.Icon "SYRIN0";
		Ammo.BackpackAmount 100;
		Ammo.BackpackMaxAmount 100;
	}
	
	override void PB_SetAmmoSprite()
	{
		sprite = GetSpriteIndex("SYRI");
        frame = 13;
	}
	
	override void AttachToOwner(actor other) //we have to do this here so that cheats will give the tokens
	{
		other.GiveInventory("PBX_MedPackToken",1);
		Super.AttachToOwner(other);
	}
}

