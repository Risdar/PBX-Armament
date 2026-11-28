mixin class PBX_SmartScav
{
	bool shouldSpawnPartial(Actor toucher)
	{
		// Get the parent ammo
		class<Ammo> type = GetParentAmmo();
		let ammoDefault = GetDefaultByType(type);

		if (!toucher || !type || !ammoDefault) 
		{
			return false;
		}

		// Get the current and maximum values
		int current, maxCap;
		let inv = toucher.FindInventory(type);
		if(inv)
		{
			// Check if the player has a backpack
			bool backpack = toucher.FindInventory("PB_Backpack");
			current = inv.Amount;
			maxCap = backpack ? ammoDefault.BackpackMaxAmount : inv.MaxAmount;
		}
		else
		{
			current = 0;
			maxCap = ammoDefault.MaxAmount;
		}

		// console.printf("Current = %d, maxCap = %d, Given Amount = %d",current,maxCap,self.amount); 
		
		// Check if the current ammo is less than the cap
		// AND if the current + the amount that will be given by this item
		// is more than the cap
		return (current < maxCap) && (current + self.amount > maxCap);
	}

	int getHowManySpawn()
	{
		let type = GetParentAmmo();
		let ammoDefault = GetDefaultByType(type);
		if(!type || !ammoDefault) return 1;

		return self.amount / ammoDefault.amount;
	}

	void setSprite()
	{
		name s;
		switch(self.GetClassName())
		{
			case 'Smartscav_Cells': s = "YELP"; break;
			case 'Smartscav_Shells': s = "SB0X"; break;
			case 'Smartscav_Rockets': s = "BR0K"; break;
			case 'Smartscav_HighCal': s = "AMM0"; break;
			case 'Smartscav_LowCal': s = "AMOK"; break;
		}
		// console.printf("Sprite Changed to %s",s); 
		sprite = GetSpriteIndex(s);
	}

	int amt,rand,am1,am2;
	void spawnPartial()
	{
		amt = getHowManySpawn();
		rand = random(1,amt-1);
		am1 = amt - rand;
		am2 = amt - am1;
	}

	override bool TryPickup(in out actor toucher)
    {
		if(!toucher || !toucher.Player) 
			return Super.TryPickup(toucher);

		if(shouldSpawnPartial(toucher))
		{
			bNoInteraction = true;
			SetStateLabel("SpawnPartial");
			return false;
		}
        return Super.TryPickup(toucher);
    }

	States
	{
		SpawnPartial:
			"####" "#" 5 setSprite();
			"####" "#" 5 {
				spawnPartial();
				// console.printf("Spawned Partial with %d many times",am1); 
				for(int i = 0; i < am1; i++)
					A_SpawnItemEx(GetParentAmmo(),0,0,0,frandom(2,4),0,frandom(2,4),random(1,360));
			}
			"####" "#" 15;
			"####" "#" 5 {
				// console.printf("Spawned Partial with %d many times",am2); 
				for(int i = 0; i < am2; i++)
					A_SpawnItemEx(GetParentAmmo(),0,0,0,frandom(2,4),0,frandom(2,4),random(1,360));
			}
			"####" "#" 5 A_FadeOut();
			Wait;
	}

}

class Smartscav_Cells  : PB_CellPack   {mixin PBX_SmartScav;}
class Smartscav_Shells : PB_ShellBox   {mixin PBX_SmartScav;}
class Smartscav_Rockets: PB_RocketBox  {mixin PBX_SmartScav;}
class Smartscav_HighCal: PB_HighCalBox {mixin PBX_SmartScav;}
class Smartscav_LowCal : PB_LowCalBox  {mixin PBX_SmartScav;}


// SMART MEDIKIT ==========================================================================================
class Smartscav_Medikit : PB_Medikit
{
	bool SC_checkHealth(actor toucher)
	{
		if(!toucher.player)
		{
			return false;
		}

		int maxHP = toucher.GetMaxHealth(true);
		int currentHP = toucher.health;
		return currentHP < maxHP && currentHP > 75;
	}

	override bool TryPickup(in out actor toucher)
	{
		if (!toucher || !toucher.player) 
			return Super.TryPickup(toucher);

		if(SC_checkHealth(toucher))
		{
			bNoInteraction = true;
			SetStateLabel("SpawnStims");
			return false;
		}

		return Super.TryPickup(toucher);
	}
	
	States
	{
		SpawnStims:
			MED1 A 5;
			"####" "#" 5 A_SpawnItemEx("PB_Stimpack",0,0,0,frandom(2,4),0,frandom(2,4),random(1,360));
			"####" "#" 5 A_SpawnItemEx("PB_Stimpack",0,0,0,frandom(2,4),0,frandom(2,4),random(1,360));
			"####" "#" 5 A_SpawnItemEx("PB_Stimpack",0,0,0,frandom(2,4),0,frandom(2,4),random(1,360));
			"####" "#" 5 A_FadeOut();
			Wait;
	}
}

// SPAWNER ==========================================================================================
extend class PBX_Handler
{
	private
	void spawnSmartScav(ReplaceEvent e)
	{
		switch(e.Replacee.GetClassName())
        {
            case 'PB_CellPack':   e.Replacement  = "Smartscav_Cells";    break;
            case 'PB_ShellBox':   e.Replacement  = "Smartscav_Shells";   break;
            case 'PB_RocketBox':  e.Replacement  = "Smartscav_Rockets";  break;
            case 'PB_HighCalBox': e.Replacement  = "Smartscav_HighCal";  break;
            case 'PB_LowCalBox':  e.Replacement  = "Smartscav_LowCal";   break;
            case 'PB_Medikit':    e.Replacement  = "Smartscav_Medikit";  break;
        }
	}
}