// Jetpack
// Modified code from Brutal Doom Platinum by EmeraldCoasttt

class PBX_Jetpack : Inventory
{
	bool mActive;

	Default 
	{
		Inventory.AltHudIcon "JETPA0";
		Inventory.PickupMessage "$JETPACK_PICKUP";
		Inventory.PickupSound "7LSPICK";
		inventory.maxamount 1;
		Tag "$JETPACK_TAG";
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

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
			owner.A_TakeInventory("PB_Fuel",mJetpackFuelTake);
		else
		{
			owner.A_Print("$JETPACK_NOFUEL");
			owner.A_StartSound("BEPBEP", CHAN_ITEM);
			toggleJetpack(true);
		}
	}

	override bool TryPickup(in out Actor toucher)
    {
        bool pickup = Super.TryPickup(toucher);
        if (pickup)
        {
			if(PBX_SEND_TIP)
			{
				Array<String> tips;
				tips.Push(string.format(
						StringTable.Localize("$PBX_JetPack_Tip1"),
						PB_HelpNotificationsHandler.PB_FormatKeybinds("pbx_togglejetpack"),
						PBX_JetPack_FuelUse
					)
				);
				PBX_Handler.SendTipArrayIfNeeded(tips,ITEMS_HELPTEXT,PBX_Armory_Tip_JetPack);
			}
			toucher.A_GiveInventory("PB_Fuel",mJetpackFuelTake*15); // So you atleast have 15 seconds of flight
        }
        return pickup;
    }

	void toggleJetpack(bool bypassCheck = false)
	{
		if(owner.CountInv("PB_Fuel") < mJetpackFuelTake && !bypassCheck)
		{
			owner.A_Print("$SHOULDCANNON_NOFUEL");
			owner.A_startsound("weapons/carbine/respectbeep",4);
			return;
		}

		// Toggle
		mActive 			= !mActive;
		// Change player flags
		owner.bfloatbob 	= mActive;
		owner.bfloat 		= mActive;
		owner.bnogravity 	= mActive;
		owner.bfly 			= mActive;

		// Start Effects
		if(!bypassCheck)
			owner.A_Print(mActive ? "$JETPACK_ACTIVE" : "$JETPACK_DEACTIVE");

		owner.a_startsound("Equip_Activate",CHAN_ITEM);

		if(mActive)
			owner.a_startsound("JETLOOP",6,CHANF_LOOPING);
		else
		{
			owner.A_startsound("weapons/carbine/respectbeep",4);
			owner.a_stopsound(6);
			owner.a_startsound("JETEND",6);
		}
	}

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
		Spawn:
			JETP A -1;
			Stop;
	}
}

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