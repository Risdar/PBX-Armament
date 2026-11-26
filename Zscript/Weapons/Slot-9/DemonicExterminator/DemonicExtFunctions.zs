extend class PBX_DemonExt{

	override void ondrop(actor dropper)
	{
		dropper.A_StopSound(chan_unmkidle);
		super.ondrop(dropper);
	}
	
	Action Void UNM_ChangePSFrame(int frm = 0,int layer = PSP_WEAPON)
	{
		let PS = player.findPSprite(layer);
		if(PS)
			PS.frame = frm;
	}

	Action state WeaponSpecialCheck()
	{
		if(!FindInventory("GoWeaponSpecialAbility"))
			return resolvestate(null);

		bool closeWheel = countinv("PBX_CloseWheel") > 0;
		bool noIncinerator = countinv("UMDE_Select_NoIncinerationMode") > 0;
		bool noLightning = countinv("UMDE_Select_NoLightningMode") > 0;

		bool goLaser = countinv("UMDE_Select_LaserMode") > 0;
		bool goIncinerator = countinv("UMDE_Select_IncinerationMode") > 0;
		bool goLightning = countinv("UMDE_Select_LightningMode") > 0;

		int prevMode = invoker.ExterminatorMode;
		A_TakeInventory("GoWeaponSpecialAbility",1);
		
		if(closeWheel)
		{
			cleanmodetokens();
			return resolvestate(null);
		}

		if(noIncinerator || noLightning)
		{
			A_Print(noIncinerator ? "$PBX_DemonExt_NoIncin" : "$PBX_DemonExt_NoLightning");
			cleanmodetokens();
			return resolvestate(null);
		}

		if((goLaser      && invoker.ExterminatorMode == LaserMode) 
		|| (goIncinerator && invoker.ExterminatorMode == IncinerationMode) 
		|| (goLightning  && invoker.ExterminatorMode == LightningMode))
		{
			A_print("$PBX_AlreadySelected");
			cleanmodetokens();
			return resolvestate(null);
		}
		
		if(goLaser)
		{
			DEUM_SetMode(LaserMode);
			A_print("$PBX_DemonExt_Laser");
		}
		
		if(goIncinerator)
		{
			DEUM_SetMode(IncinerationMode);
			A_print("$PBX_DemonExt_Incin");
		}
		
		if(goLightning)
		{
			DEUM_SetMode(LightningMode);
			A_print("$PBX_DemonExt_Lightning");
		}

		A_StartSound("unmaker/switch",CHAN_WEAPON);
		cleanmodetokens();

		// Switch from Lightning
		if(prevMode == LightningMode && (invoker.ExterminatorMode == IncinerationMode || invoker.ExterminatorMode == LaserMode))
		{
			A_Overlay(specialOverlay,"SwitchFromSoulLayer");
			return resolvestate("Ready3");
		}

		// Switch to Lightning
		if(invoker.ExterminatorMode == LightningMode)
		{
			A_Overlay(specialOverlay,"SwitchToSoulLayer");
			return resolvestate("SwitchToSoul");
		}

		// Everything else
		if(invoker.ExterminatorMode != LightningMode)
			A_Overlay(specialOverlay,"WeaponSpecialLayer");

		return resolvestate(null);
	}

	const LaserMode = 0;
	const IncinerationMode = 1;
	const LightningMode = 2;

	action void DEUM_SetMode(int set = 0)
	{
		invoker.ExterminatorMode = set;
	}

	action void cleanmodetokens()
	{
		A_TakeInventory("PBX_CloseWheel",1);
		A_TakeInventory("UMDE_Select_LaserMode",1);
		A_TakeInventory("UMDE_Select_IncinerationMode",1);
		A_TakeInventory("UMDE_Select_LightningMode",1);
		A_TakeInventory("UMDE_Select_NoIncinerationMode",1);
		A_TakeInventory("UMDE_Select_NoLightningMode",1);
	}

	action void DemonExtCrosshair()
	{
		switch(invoker.ExterminatorMode)
		{
			case LaserMode: 		PB_HandleCrosshair(26); break;
			case IncinerationMode: 	PB_HandleCrosshair(14); break;
			case LightningMode: 	PB_HandleCrosshair(90); break;
			default : PB_HandleCrosshair(0); break;
		}
	}
	
	action state UNM_WeaponReady()
	{
		// WeaponSpecialCheck();
		DemonExtCrosshair();
		A_TakeInventory("CantDoAction",0);
		if(!invoker.ExterminatorWeaponSpecial)
			return A_DoPBWeaponAction(0);

		// return ResolveState(NULL);
		return WeaponSpecialCheck();
	}

	action void UNM_Add_level()
	{
		invoker.U_level++;
		if(invoker.U_level > 2)
			invoker.U_level = 0;
		
	}
	
	static const int UN_LevelOfs[] = {
		5,10,15
	};
	
	
	action void UNM_FireBeams(int ofs = 0)
	{
		int lv = Player.ReFire%3*5+5;
		for(int i = -lv; i <= lv; i += lv) A_FireProjectile("UNMK_Projectile",i,0);
	}

	action void UNM_FireLasers()
	{
		int lv = Player.ReFire%3*5+5;
		for(int i = -lv; i <= lv; i += lv) 
		{
			A_RailAttack(
				LASER_DAMAGE, 0, 0, 
				"", "red", 
				RGF_SILENT | RGF_FULLBRIGHT | RGF_EXPLICITANGLE | RGF_NORANDOMPUFFZ, 
				0, "Unmaker64Puff", i, 0, 0, 0, 5, 2, "UnmakerLaser64Spark", -1,270,1
			);
		}
	}
	
	action void UNM_FireStorm(int stormLayers = 2, int distanceIntervals = 40)
	{
		for(int i = 0; i < stormLayers; i++)
		{
			actor a = A_FireProjectile("UNMK_StormSpray",0,0);
			if(a)
			{
				if(i == 0)
					a.bFALLING = true;

				a.Warp(a,distanceIntervals * i);
			}
		}
	}
	
}