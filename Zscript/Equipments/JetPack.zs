// Jetpack
// Modified code from Brutal Doom Platinum by EmeraldCoasttt
////// DATA /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class JetPackCard : equipmentCard
{
	override void InfoFiller(out array<string> tags,out array<string> tokens,out array<string> ammotypes,out array<string>img,out array<double>sx,out array<double>sy)
	{
		tags.push("$PBX_JETPACK_TAG");
		tokens.push("PBX_JetPackToken");
		ammotypes.push("PB_Fuel");
		img.push("graphics/Equipments/JetPack/JetpackIcon.png");
		sx.push(1.0);
		sy.push(1.0);
	}
}

class PBX_JetPackToken : PBX_Equipment 
{
	Default 
    {
		Inventory.Icon "JTFLICON";
		PB_Equipment.AmmoType "PB_Fuel";
		PB_Equipment.SelectString "$PBX_JETPACK_WHEEL";
		PB_Equipment.SelectSound "7LSPICK";
		PB_Equipment.FailString "$PBX_JETPACK_OUT";
		PB_Equipment.FontColor "Orange";
	}

	bool mActive;
	int mJetpackFuelTake;

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		mJetpackFuelTake = PBX_JetPack_FuelUse;
	}

	//This function is executed every tic by items while they're in an actor's inventory:
	Override void DoEffect() 
	{
		super.DoEffect();
		if(!owner || !owner.player || owner.health <= 0 || owner.isFrozen() || !mActive)
			return;

		spawnTrail();		

		// Everything below here will be run every second
		if (level.time % TICRATE != 0)  
			return;

		if(owner.CountInv("PB_Fuel") > mJetpackFuelTake-1)
		{
			owner.A_TakeInventory("PB_Fuel",mJetpackFuelTake);
		}
		else
		{
			owner.A_Print("$PBX_JETPACK_NOFUEL");
			owner.A_StartSound("BEPBEP", CHAN_ITEM);
			toggleJetpack(true);
		}
	}

	private
	action void toggleJetpack(bool bypassCheck = false)
	{
		if(CountInv("PB_Fuel") < invoker.mJetpackFuelTake && !bypassCheck)
		{
			A_Print("$SHOULDCANNON_NOFUEL");
			A_startsound("weapons/carbine/respectbeep",CHAN_BODY);
			return;
		}

		// Toggle
		invoker.mActive = !invoker.mActive;
		// Change player flags
		bool act = invoker.mActive;
		bfloatbob = bfloat = bnogravity = bfly = act;

		// Start Effects
		if(!bypassCheck)
		{
			A_Print(act ? "$PBX_JETPACK_ACTIVE" : "$PBX_JETPACK_DEACTIVE");
		}

		a_startsound("Equip_Activate",CHAN_ITEM);

		if(act)
		{
			a_startsound("JETLOOP",CHAN_6,CHANF_LOOPING);
		}
		else
		{
			A_startsound("weapons/carbine/respectbeep",CHAN_BODY);
			a_stopsound(CHAN_6);
			a_startsound("JETEND",CHAN_6);
		}
	}

	private
	void spawnTrail()
	{
		//every tick a stream of fire is spawned at either shoulder
		owner.A_SpawnItemEx(
			"PB_JetpackFlameTrails",
			xofs:-5,
			yofs:-12,
			zofs:12

		);
			owner.A_SpawnItemEx(
			"PB_JetpackFlameTrails",
			xofs:-5,
			yofs:12,
			zofs:12
		);
	}
	
	States 
    {
        UseEquipment:
            TNT1 A 1 toggleJetpack();
            TNT1 A 10; // Placeholder
            TNT1 A 0 PB_ReThrow();
            Stop;
	}
}

////// PICKUP /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class PBX_Jetpack : PB_Ammo
{
    Default
    {
        Inventory.Amount 1;
        Inventory.PickupMessage "$PBX_SMOKEGRENADE_PICKUP";
		Inventory.PickupSound "7LSPICK";
		Ammo.BackpackAmount 0;
		Tag "$PBX_JETPACK_TAG";
    }

	override string PickupMessage()
	{
		return "$PBX_JETPACK_PICKUP";
	}

	override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("JETP");
		frame = 0;
    }
	
	override void AttachToOwner(actor other)
	{
		if(amount > 0)
		{
			showHelpText();
			other.GiveInventory("PBX_JetPackToken",1);
			other.GiveInventory("PB_Fuel",PBX_JetPack_FuelUse*15); // At least 15 seconds of flight
			Super.AttachToOwner(other);
		}
		else
		{
			Destroy();
		}
	}

	private
	void showHelpText()
	{
		Array<String> tips;
		tips.Push(string.format(StringTable.Localize("$PBX_JetPack_Tip1"), PBX_JetPack_FuelUse));
		PBX_Handler.SendTipArrayIfNeeded(tips,EQUIPMENTS_HELPTEXT,PBX_TIP_JETPACK);
	}

	States
	{
		CacheSprites:
			JETP A 0;
			Stop;
	}

}

////// ACTORS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Class PB_JetpackFlameTrails : Actor 
{
	Default 
	{
		+NOINTERACTION
		+BRIGHT
		renderstyle 'Add';
		//Alpha 0.9;
		//turns it upside down
		+yflip;	
	}

	Override void PostBeginPlay() 
	{
		Super.PostBeginPlay();
		scale.x *= frandom[sfx](0.01,0.2); //randomize horizontal scale a bit
		scale.y *= frandom[sfx](0.6,0.7); //randomize vertical scale a bit
		bSPRITEFLIP = random[sfx](0,1); //randomly set or not set SPRITEFLIP flag
	}

	States 
	{
		Spawn:
		//flamethrower particle sprite, if it's too short for your tastes add "B" to the frame
			TNT1 A 0;
			NF4R A 1 BRIGHT;
			stop;
	}
}