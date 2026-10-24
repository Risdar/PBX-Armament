Class PBX_BackpackReloadBehavior : Behavior
{
	// Exception list, for weapons that use AmmoType2 but is not a mag
	// Or edited weapon
	static const string PB_noreloadweapons[] = {
		"PB_Unmaker"
		,"PBX_DemonExt"
		,"PB_Revolver"
		,"PB_Deagle"
	};

	override void Tick()
	{
		if (!Owner || !Owner.player)
			return;

		// Check if disabled
		if (!PBX_BackpackReload_Enable)
		{
			return;
		}

		// Reload every PBBCKPR_Time
		if(owner.getage() % PBBCKPR_Time == 0)
		{
			refillweapons();
		}
	}

	void refillweapons()
	{
		let held = Owner.player.readyweapon; if(!held) return;

		for (Inventory item = Owner.inv; item != null; item = item.inv)
		{
			let wep = PB_WeaponBase(item);
			if (!wep)
				continue;

			// Skip the weapon currently being held
			if (wep == held)
				continue;

			// Can it be reloaded (using ammotype2)
			if (!isReloadable(wep))
				continue;

			// Does the weapon actually have ammo
			if (!wep.ammo1 || !wep.ammo2)
				continue;

			// Does the weapon still have reserve ammo
			if (wep.ammo1.amount < 1 && !hasInfiniteAmmo(Owner))
				continue;

			ReloadWeapon(wep, wep.ammo1, wep.ammo2, false);

			// Dual wield
			if (wep.akimboMode && wep.amount > 1)
			{
				if (!wep.ammoLeft)
					continue;
				ReloadWeapon(wep, wep.ammo1, wep.ammoLeft, true);
			}
		}
	}

	void ReloadWeapon(PB_WeaponBase wep, Ammo am1, Ammo am2, bool isLeft = false)
	{
		int cur   = am2.amount;                 // Current ammo in the magazine
		int maxm  = am2.maxamount;              // Max ammo in the magazine
		int res   = am1.amount;                 // Reserve ammo
		int eq    = wep.ReserveToMagAmmoFactor; // Reserve needed per one mag ammo

		if (res < eq)
			return;

		if (cur < maxm && res >= eq)
		{
			int pendin = maxm - cur;               // Ammo needed to fill the mag
			pendin = min(pendin, PBBCKPR_Ref);     // Capped by the CVar amount

			int releq  = pendin * eq;              // Reserve needed for that
			int amt    = min(releq, res);          // Limited by what's in reserve
			int giveam = amt / eq;                 // Mag ammo to actually give

			Owner.A_GiveInventory(am2.GetClassName(), giveam);
			Owner.A_TakeInventory(am1.GetClassName(), int(giveam * eq), TIF_NOTAKEINFINITE);

			ResetStagedReload(wep, isLeft);

			if (PBBCKPR_Tell && am2.amount >= maxm)
				printreloadedmsg(wep.GetTag(), isLeft);
		}
	}

	void ResetStagedReload(PB_WeaponBase wep, bool isLeft = false)
	{
		if (isLeft)
		{
			wep.leftChamberEmpty = false;
			wep.leftMagEmpty     = false;
			wep.leftMagUnloaded  = false;
		}
		else
		{
			wep.chamberEmpty = false;
			wep.magEmpty     = false;
			wep.magUnloaded  = false;
		}
	}

	bool hasInfiniteAmmo(Actor who)
	{
		return (sv_infiniteammo || who.FindInventory("PowerInfiniteAmmo", true) != null);
	}

	void printreloadedmsg(name w, bool lefts)
	{
		Console.Printf("%s\cv%s\c- reloaded.", lefts ? "Left " : "", w);
	}

	bool isReloadable(PB_WeaponBase wep)
	{
		if (wep.ammo1 != null && wep.ammo2 != null)
		{
			for (int i = 0; i < PB_noreloadweapons.Size(); i++)
			{
				if (wep.GetClassName() == PB_noreloadweapons[i])
					return false;
			}
			return true;
		}
		return false;
	}
}