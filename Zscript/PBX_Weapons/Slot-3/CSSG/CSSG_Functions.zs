extend class PBX_CSSG
{
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
	override void postbeginplay()
	{
		meathookMode = false;
		shellsmode = 0;
		super.postbeginplay();
	}
	
    override void DoEffect() 
	{
		super.DoEffect();
		If(owner.player && owner.player.readyweapon)
		{
			if(hookCooldown > 0 && level.time % TICRATE == 0)
			{
				hookCooldown--;
				if(hookCooldown == 0)
				{
					PBXCore_Debug.Print("Hook Cooldown finished");
					owner.a_startsound("MHKSTRT",193,CHANF_DEFAULT,1,ATTN_NONE);
				}
			}
		}
	}

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
	action void A_trymeathook(int meathookrange = 256)
	{
		let pbxplr = PBXCore_Player(invoker.owner);
		if(!pbxplr)
		{
			A_Print("$PBX_CSSG_NOPLAYER");
			return;
		}
		if(pbxplr.aimActor2 && invoker.hookCooldown <= 0)
		{
			target = pbxplr.aimActor2;
			A_spawnprojectile("hook",32);
			A_takeinventory("meathook",1);
			a_startsound("MHKSTRT",193,CHANF_DEFAULT,1,ATTN_NONE);
			invoker.hookCooldown = PBX_CSSGMeathook_Cooldown;
        	PBXCore_Debug.PrintInt("Meathook Cooldown is %d",invoker.hookCooldown);
			return;
		}
		else
		{
			if(invoker.hookCooldown > 0)
				A_Print("$PBX_CSSG_NOHOOK");
			A_StartSound("weapons/empty",190,CHANF_DEFAULT,1,ATTN_NONE);
		}
	}

	action void CSSG_CutMeathook()
	{
		let pbxplr = PBXCore_Player(invoker.owner);
		if(pbxplr) pbxplr.StopHook(true);
	}

	action state CSSG_Ready()
	{
		let pbxplr = PBXCore_Player(invoker.owner);
		if(pbxplr && pbxplr.Grappled && PBX_Weapons_cssghooklockswitch)
			return A_DoPBWeaponAction(WRF_NOSWITCH|WRF_DISABLESWITCH);	

		return A_DoPBWeaponAction();
	}

	static const string CSSG_ShellsType[] = {
		"$PBX_CM_BUCKLD2",	"$PBX_CM_SLUGLD2",	"$PBX_CM_FLCHLD2",
		"$PBX_CM_FLAKLD2",	"$PBX_CM_DGBTLD2",	"$PBX_CM_EXPLLD2",
		"$PBX_CM_WPLOAD2",	"$PBX_CM_DOOMLD2",	"$PBX_CM_DNMKULD2",
		"$PBX_CM_SUBZRLD2",	"$PBX_CM_HELFRLD2", "$PBX_CM_ACIDLD2"
	};
	
	static const string CSSG_ShellsToken1[] = {
		"SelectCSG_Buckshot",		"SelectCSG_Slugshot",		"SelectCSG_Flechette",
		"SelectCSG_Flak",			"SelectCSG_Dragonsbreath",	"SelectCSG_Explosive",	
		"SelectCSG_WPhosphorus",	"SelectCSG_Doom",			"SelectCSG_Danmaku",
		"SelectCSG_SubZero", 		"SelectCSG_HellFire", 		"SelectCSG_Acid"
	};
	
	static const string CSSG_ConfirmShell[] = {
		"$PBX_CM_BUCKLD",	"$PBX_CM_SLUGLD",	"$PBX_CM_FLCHLD",
		"$PBX_CM_FLAKLD",	"$PBX_CM_DGBTLD",	"$PBX_CM_EXPLLD",
		"$PBX_CM_WPLOAD",	"$PBX_CM_DOOMLD",	"$PBX_CM_DNMKULD",
		"$PBX_CM_SUBZRLD", 	"$PBX_CM_HELFRLD", 	"$PBX_CM_ACIDLD"
	};
	
	//bascially, check wich shells is actually used, and change the sprite based on that
	Action Void ChangeCSSGShellsLook(
		name buck = '',
		name slug = '',
		name flech = '',
		name flak = '',
		name dragons = '',
		name explo = '',
		name wp = '',
		name tds = '',
		name dnm = '',
		name subz = '',
		name helf = '',
		name acid = '',
		bool old = false)
	{
		int wich = old ? invoker.oldshells : invoker.shellsmode;
		wich++;
		switch(wich)
		{
			case Shell_Buck: 	A_SetWeaponSpriteEx(buck); 		break;
			case Shell_Slug: 	A_SetWeaponSpriteEx(slug); 		break;
			case Shell_Flech: 	A_SetWeaponSpriteEx(flech); 	break;
			case Shell_Flak: 	A_SetWeaponSpriteEx(flak); 		break;
			case Shell_Drgn: 	A_SetWeaponSpriteEx(dragons); 	break;
			case Shell_EXPL: 	A_SetWeaponSpriteEx(explo); 	break;
			case Shell_WPSP: 	A_SetWeaponSpriteEx(wp); 		break; 
			case Shell_Doom: 	A_SetWeaponSpriteEx(tds); 		break;
			case Shell_Damn: 	A_SetWeaponSpriteEx(dnm); 		break;
			case Shell_SubZ: 	A_SetWeaponSpriteEx(subz); 		break;
			case Shell_HellF: 	A_SetWeaponSpriteEx(helf); 		break;
			case Shell_Acid: 	A_SetWeaponSpriteEx(acid); 		break;
		}
		
	}
	
	//this just prints the selected shell message
	Action Void PrintSelectedShell()
	{
		int wich = invoker.shellsmode + 1;
		switch(wich)
		{
			case Shell_Buck:  A_Print("$PBX_CM_BUCKLD");  break;
			case Shell_Slug:  A_Print("$PBX_CM_SLUGLD");  break;
			case Shell_Flech: A_Print("$PBX_CM_FLCHLD");  break;
			case Shell_Flak:  A_Print("$PBX_CM_FLAKLD");  break;
			case Shell_Drgn:  A_Print("$PBX_CM_DGBTLD");  break;
			case Shell_EXPL:  A_Print("$PBX_CM_EXPLLD");  break;
			case Shell_WPSP:  A_Print("$PBX_CM_WPLOAD");  break;
			case Shell_Doom:  A_Print("$PBX_CM_DOOMLD");  break;
			case Shell_Damn:  A_Print("$PBX_CM_DNMKULD"); break;
			case Shell_SubZ:  A_Print("$PBX_CM_SUBZRLD"); break;
			case Shell_HellF: A_Print("$PBX_CM_HELFRLD"); break;
			case Shell_Acid:  A_Print("$PBX_CM_ACIDLD");  break;
		}
	}
	
	//this function spawns the casing based on the current shell
	Action Void A_spawnCSSGCasing(bool useprev = false)
	{
		string shelltype = "BuckShellCasing";
		int wich = invoker.shellsmode + 1;
		if(useprev)
			wich = invoker.oldshells + 1;
		switch(wich)
		{
			case Shell_Buck: 	shelltype = "BuckShellCasing"; 			break;
			case Shell_Slug: 	shelltype = "SlugShellCasing"; 			break;
			case Shell_Flech: 	shelltype = "FlechetShellCasing"; 		break;
			case Shell_Flak: 	shelltype = "FlakShellCasing"; 			break;
			case Shell_Drgn: 	shelltype = "DragonShellCasing"; 		break;
			case Shell_EXPL: 	shelltype = "ExplosiveShellCasing"; 	break;
			case Shell_WPSP: 	shelltype = "WhitePShellCasing"; 		break;
			case Shell_Doom: 	shelltype = "TDoomCasing"; 				break;
			case Shell_Damn: 	shelltype = "DanmakuCasing"; 			break;
			case Shell_SubZ: 	shelltype = "SubZeroCasing"; 			break;
			case Shell_HellF: 	shelltype = "HellFireCasing"; 			break;
			case Shell_Acid: 	shelltype = "AcidShellsCasing"; 		break;
		}
		PB_SpawnCasing(shelltype,random(10,14),random(-1,3),random(26,28),random(1,3),random(-5,-2),random(4,7));
	}
	
	//the nexts funcions exist only to not bloat the code and dont make a lot of different fire states
	//so all is handled here, so if something goes wrong, i can fix it here once, and not in every state
	Action Void FireCSSGFirst()
	{
		int mode = invoker.shellsmode + 1;
		switch(mode)
		{
			case Shell_Buck: 
				PB_FireBullets("PB_10GAPellet",20,8,0,0,6);
				break;
			case Shell_Slug:
				PB_FireBullets("PB_12GASlug",1,0.1,2,0,0); 
				PB_FireBullets("PB_12GASlug",1,0.1,-2,0,0); 
				break;
			case Shell_Flech: 
				PB_FireBullets("PB_MGNail",12,3,0,0,3); 
				break;
			case Shell_Flak: 
				PBX_FireBullets("chunk1",3,5,0,0,3); 
				PBX_FireBullets("chunk2",3,3,0,0,4);
				PBX_FireBullets("chunk4",2,4,0,0,3);
				break;
			case Shell_Drgn: 
				PB_FireBullets("PB_DragonsBreathTracer",10,6,0,0,6); 
				break; 
			case Shell_EXPL:
				PB_FireBullets("ExplosiveProjectile",5,6,0,0,6); 
				break; 
			case Shell_WPSP: 
				PB_FireBullets("WPhosphorusProjectile",7,6,0,0,6);
				break;
			case Shell_Doom:
				PB_FireBullets("PB_12GASlug",1,0.1,2,0,0); 
				PB_FireBullets("PB_12GASlug",1,0.1,-2,0,0);
				PB_FireBullets("PB_10GAPellet",10,6,0,0,6);
				PB_FireBullets("PB_10GAPellet_LP",1,6,0,0,6);
				PB_FireBullets("PB_8GAPellet",10,16,0,0,12);
				break;
			case Shell_Damn:
				PBX_FireBullets("DanmakuProjectile",16,4.0,0,0,2.5);
				break;
			case Shell_SubZ:
				A_SpawnItemEx("BlueFlareSpawn", 0, 0, -3);
				A_SpawnItemEx("BlueFlareSpawn", 0, 0, 3);
				PB_FireBullets("SubZeroProjectile",6,3,0,0,3);
         		A_FireBullets(8, 6, 10, 18, "SubZ_Puff",FBF_NORANDOM,8192,"CSSG_FrozenTracer",-12);
				break;
			case Shell_HellF:
				PB_FireBullets("HellFireProjectile",16,6,0,0,6);
				break;
			case Shell_Acid:
				PB_FireBullets("AcidShellsProjectile",3,6,0,0,6);
				break;
		}
		// Always shoot the shield breaking projectile
		PB_FireBullets("PB_10GAPellet_LP",1,0,0,0,0);
	}

	Action Void FireHalfCSSGRight()
	{
		
		int mode = invoker.shellsmode + 1;
		switch(mode)
		{
			case Shell_Buck: 
				PB_FireBullets("PB_10GAPellet",10,8,0,0,6);
				break;
			case Shell_Slug: 
				PB_FireBullets("PB_12GASlug",1,0.1,2,0,0); 
				break;
			case Shell_Flech: 
				PB_FireBullets("PB_MGNail",6,3,0,0,3); 
				break;
			case Shell_Flak: 
				PBX_FireBullets("chunk1",2,3,0,0,3); 
				PBX_FireBullets("chunk4",2,3,0,0,3);
				break;
			case Shell_Drgn: 
				PB_FireBullets("PB_DragonsBreathTracer",5,6,0,0,6); 
				break; 
			case Shell_EXPL:
				PB_FireBullets("ExplosiveProjectile",2,6,0,0,6); 
				break; 
			case Shell_WPSP: 
				PB_FireBullets("WPhosphorusProjectile",4,6,0,0,6);
				break;
			case Shell_Doom:
				PB_FireBullets("PB_12GASlug",1,0.1,2,0,0); 
				PB_FireBullets("PB_10GAPellet",4,6,0,0,6);
				PB_FireBullets("PB_10GAPellet_LP",2,6,0,0,6);
				PB_FireBullets("PB_8GAPellet",5,13,0,0,8);
				break;
			case Shell_Damn:
				PBX_FireBullets("DanmakuProjectile",8,1.5,2,0,1.2);
				break;
			case Shell_SubZ:
				A_SpawnItemEx("BlueFlareSpawn", 0, 0, -3);
				A_SpawnItemEx("BlueFlareSpawn", 0, 0, 3);
				PB_FireBullets("SubZeroProjectile",3,3,0,0,3);
         		A_FireBullets(8, 6, 5, 18, "SubZ_Puff",FBF_NORANDOM,8192,"CSSG_FrozenTracer",-12);
				break;
			case Shell_HellF:
				PB_FireBullets("HellFireProjectile",8,6,0,0,6);
				break;
			case Shell_Acid:
				PB_FireBullets("AcidShellsProjectile",1,6,0,0,6);
				break;
		}
		PB_IncrementHeat(4);
	}
	
	Action Void FireHalfCSSGLeft()
	{
		
		int mode = invoker.shellsmode + 1;
		switch(mode)
		{
			case Shell_Buck: 
				PB_FireBullets("PB_10GAPellet",10,6,0,0,6);
				break;
			case Shell_Slug: 
				PB_FireBullets("PB_12GASlug",1,0.1,-2,0,0); 
				break;
			case Shell_Flech: 
				PB_FireBullets("PB_MGNail",6,3,0,0,3); 
				break;
			case Shell_Flak: 
				PBX_FireBullets("chunk2",4,3,0,0,3); 
				break;
			case Shell_Drgn: 
				PB_FireBullets("PB_DragonsBreathTracer",5,6,0,0,6); 
				break; 
			case Shell_EXPL:
				PB_FireBullets("ExplosiveProjectile",2,6,0,0,6); 
				break; 
			case Shell_WPSP: 
				PB_FireBullets("WPhosphorusProjectile",3,6,0,0,6);
				break;
			case Shell_Doom:
				PB_FireBullets("PB_12GASlug",1,0.1,-2,0,0); 
				PB_FireBullets("PB_10GAPellet",4,6,0,0,6);
				PB_FireBullets("PB_10GAPellet_LP",2,6,0,0,6);
				PB_FireBullets("PB_8GAPellet",5,12,0,0,8);
				break;
			case Shell_Damn:
				PBX_FireBullets("DanmakuProjectile",8,1.6,-2,0,1.2);
				break;
			case Shell_SubZ:
				A_SpawnItemEx("BlueFlareSpawn", 0, 0, -3);
				A_SpawnItemEx("BlueFlareSpawn", 0, 0, 3);
				PB_FireBullets("SubZeroProjectile",3,3,0,0,3);
         		A_FireBullets (8, 6, 5, 18, "SubZ_Puff",FBF_NORANDOM,8192,"CSSG_FrozenTracer",-12);
				break;
			case Shell_HellF:
				PB_FireBullets("HellFireProjectile",8,6,0,0,6);
				break;
			case Shell_Acid:
				PB_FireBullets("AcidShellsProjectile",1,6,0,0,6);
				break;
		}
		PB_IncrementHeat(4);
	}
	
	action void FireCSSG()
	{
		FireCSSGFirst();
		A_ZoomFactor(0.92);
		PB_FireOffset();
		A_takeinventory(invoker.ammotype2,BARREL_CAPACITY);
		PB_WeaponRecoil(-7,frandom[sfx](-1.5,1.5));
		PB_GunSmoke(2,0,-1);
		PB_GunSmoke(-2,0,-1);
		A_FireProjectile("ShotgunWad",random(-2,2),0,3,-4,FPF_NOAUTOAIM,random(-2,2));
		A_FireProjectile("ShotgunWad",random(-2,2),0,-3,-4,FPF_NOAUTOAIM,random(-2,2));	
	}
	
	Action Void CM_HandleCrosshair()
	{
		int mode = invoker.shellsmode + 1;
		int mCrosshair;
		switch(mode)
		{
			case Shell_Buck: 	mCrosshair = 69;	break;
			case Shell_Slug:	mCrosshair = 69;	break;
			case Shell_Flech: 	mCrosshair = 70;	break;
			case Shell_Flak: 	mCrosshair = 72;	break;
			case Shell_Drgn: 	mCrosshair = 69;	break; 
			case Shell_EXPL:	mCrosshair = 73;	break; 
			case Shell_WPSP: 	mCrosshair = 74;	break;
			case Shell_Doom:	mCrosshair = 11;	break;
			case Shell_Damn:	mCrosshair = 45;	break;
			case Shell_SubZ:	mCrosshair = 71;	break;
			case Shell_HellF:	mCrosshair = 70;	break;
			case Shell_Acid:	mCrosshair = 70;	break;
		}
		PB_HandleCrosshair(mCrosshair);
	}
	
	Action Void CM_PlayFireSound()
	{
		int mode = invoker.shellsmode + 1;
		A_AlertMonsters();
		switch(mode)
		{
			case Shell_Buck: 
				A_Startsound("SSHFIRE",21);
				A_Startsound("CSSGFULL",22);
				break;
			case Shell_Slug:
				A_Startsound("CSSGSLGF",22);
				break;
			case Shell_Flech: 
				A_Startsound("CSSGFULL",21);
				A_Startsound("CSSGFLKF",22);
				break;
			case Shell_Flak: 
				A_Startsound("CSSGFULL",21);
				A_Startsound("CSSGFLKF",22);
				break;
			case Shell_Drgn: 
				A_Startsound("SSHFIRE",21);
				A_Startsound("CSSGDBF",22);
				break; 
			case Shell_EXPL:
				A_Startsound("CSSGEXPF",22);
				break; 
			case Shell_WPSP: 
				A_Startsound("CSSGPHOF",22);
				break;
			case Shell_Doom:
				A_Startsound("CSSGEXPF",21);
				A_Startsound("CSSGSLGF",23);
				A_Startsound("CSSGFULL",22);
				break;
			case Shell_Damn:	
				A_Startsound("CSSGDANF",22);
				break;
			case Shell_SubZ:	
				A_Startsound("CSSGFULL",21);
				A_Startsound("weapons/CryoRifle/missile",21);
				break;
			case Shell_HellF:
				A_Startsound("DTechShotty/Fire",21);
				A_Startsound("DTechShotty/PrimaryAmb",22);
				break;
			case Shell_Acid:
				A_Startsound("SSHFIRE",21);
				A_Startsound("CSSGFULL",21);
				break;
		}
	}
	
	Action void CM_PlayAltFireSound()
	{
		int mode = invoker.shellsmode + 1;
		A_AlertMonsters();
		switch(mode)
		{
			case Shell_Buck: 
				A_Startsound("weapons/shh2",21);
				A_Startsound("CSSGSNGL",22);
				break;
			case Shell_Slug:
				A_Startsound("CSSGSLGS",22);
				break;
			case Shell_Flech: 
				A_Startsound("CSSGSNGL",21);
				A_Startsound("CSSGFLKS",22);
				break;
			case Shell_Flak: 
				A_Startsound("CSSGSNGL",21);
				A_Startsound("CSSGFLKS",22);
				break;
			case Shell_Drgn: 
				A_Startsound("weapons/shh2",21);
				A_Startsound("CSSGDBS",22);
				break; 
			case Shell_EXPL:
				A_Startsound("CSSGEXPS",22);
				break; 
			case Shell_WPSP: 
				A_Startsound("CSSGPHOS",22);
				break;
			case Shell_Doom:
				A_Startsound("CSSGEXPF",21);
				A_Startsound("CSSGSLGS",22);
				break; 
			case Shell_Damn:	
				A_Startsound("CSSGDANS",22);
				break;
			case Shell_SubZ:	
				A_Startsound("weapons/CryoRifle/missile",21);
				break;
			case Shell_HellF:
				A_Startsound("DTechShotty/Fire",21);
				break;
			case Shell_Acid:
				A_Startsound("weapons/shh2",21);
				A_Startsound("CSSGSNGL",22);
				break;
		}

	}
	
	Action Void CM_HandleUnload()
	{
		int mode = invoker.shellsmode + 1;
		name tounload;
		switch(mode)
		{
			case Shell_Buck: 	tounload = 'PBX_CSSG_BuckShell';			break;
			case Shell_Slug:	tounload = 'PBX_CSSG_SlugShell';			break;
			case Shell_Flech: 	tounload = 'PBX_CSSG_FlechetteShell';		break;
			case Shell_Flak: 	tounload = 'PBX_CSSG_FlakShell';			break;
			case Shell_Drgn: 	tounload = 'PBX_CSSG_DragonsBreathShell';	break; 
			case Shell_EXPL:	tounload = 'PBX_CSSG_ExplosiveShell';		break; 
			case Shell_WPSP: 	tounload = 'PBX_CSSG_WPShell';				break;
			case Shell_Doom:	tounload = 'PBX_CSSG_TDoomShell';			break;
			case Shell_Damn:	tounload = 'PBX_CSSG_DanmakuShell';			break;
			case Shell_SubZ:	tounload = 'PBX_CSSG_SubZeroShell';			break;
			case Shell_HellF:	tounload = 'PBX_CSSG_HellFireShell';		break;
			case Shell_Acid:	tounload = 'PBX_CSSG_AcidShell';			break;
		}

		PB_UnloadMag(
			invoker.ammo2.getClassName(),
			invoker.ammo1.getClassName(),
			1,1,0,0,tounload
		);
		
	}

	action state CSSG_HandleWheel()
	{
		A_Takeinventory("GoWeaponSpecialAbility",1);
		int wheelmode = getTokens();

		if(wheelmode == HOOK_ALTFIRE && invoker.meathookMode || wheelmode == SINGLE_ALTFIRE && !invoker.meathookMode)
		{
			A_Print("$PB_ALREADYSELECTED"); 
            cleanModeTokens(); 
            return ResolveState("Ready3");
		}

		switch(wheelmode)
		{
			case NO_UPGRADE: 
				A_Print("$PBX_AmmoNotAvailable");
			case CLOSE_WHEEL: case SKIP_FUNCTION:
				break;
				
			case SINGLE_ALTFIRE:
				invoker.meathookMode = false;
				A_print("$PBX_CSSG_SINGLE");
				a_startsound("weapons/cssg/in",193,CHANF_DEFAULT,1,ATTN_NONE);
				break;

			case HOOK_ALTFIRE:
				invoker.meathookMode = true;
				A_print("$PBX_CSSG_HOOK");
				a_startsound("MHKSTRT",193,CHANF_DEFAULT,1,ATTN_NONE);
				break;

			case SWITCH_MENU:
				invoker.mWheelPage2 = !invoker.mWheelPage2;
				invoker.wheelinfo = invoker.mWheelPage2 ? "CSSGWeaponWheelPage2" : "CSSGWeaponWheelPage1";
				A_print(invoker.mWheelPage2 ? "$PBX_CSSG_PAGE2" : "$PBX_CSSG_PAGE1");
				// EventHandler.SendInterfaceEvent(PlayerNumber(),"pb_special_wheel");
				break;
		}

		if(wheelmode == SINGLE_ALTFIRE || wheelmode == HOOK_ALTFIRE)
		{
			cleanmodetokens();
			return ResolveState("SwitchAnimation");
		}
		if(wheelmode == NO_UPGRADE || wheelmode == CLOSE_WHEEL || wheelmode == SWITCH_MENU)
		{
			cleanmodetokens();
			return ResolveState("Ready3");
		}

		cleanmodetokens();
		return resolvestate(null);
	}

	Action state CSSG_HandleShells()
	{
		int mode = invoker.shellsmode + 1;
		int actmode = invoker.shellsmode; // actual mode
		
		// Handle Shell Change
		// If you've already selected the same shell type, cancel wheel
		if(countinv(PBX_CSSG.CSSG_ShellsToken1[actmode]) > 0)
		{
			A_Print(
				String.format(
					StringTable.Localize("$PBX_CSSG_ALR"),
					StringTable.Localize(PBX_CSSG.CSSG_ShellsType[actmode]
					)
				)
			);
			ClearCssgTokens();
			return resolvestate("Ready3");
		}
		
		// Actual shell change
		for(int i = 0; i < PBX_CSSG.CSSG_ShellsToken1.size(); i++)
		{
			if(countinv(PBX_CSSG.CSSG_ShellsToken1[i]) > 0)
			{
				invoker.oldshells = invoker.shellsmode;
				invoker.shellsmode = i;
				A_print(PBX_CSSG.CSSG_ConfirmShell[i]);
				ClearCssgTokens();
				return resolvestate("ChangeShellAnimation");
			}
		}
		 
		// Fallthrough to handle shells
		ClearCssgTokens();
		return resolvestate(null);
	}

	action int getTokens()
	{
		if(FindInventory("SelectCSG_SwitchMenu"))
			return SWITCH_MENU;
		else if (FindInventory("SelectCSG_SwitchHook"))
			return HOOK_ALTFIRE;
		else if (FindInventory("SelectCSG_SwitchSingle"))
			return SINGLE_ALTFIRE;
		else if (FindInventory("SelectCSG_No"))
			return NO_UPGRADE;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return SKIP_FUNCTION;
	}

	action void cleanmodetokens()
	{
		A_TakeInventory("PBX_CloseWheel",1);
		A_TakeInventory("SelectCSG_No",1);
		A_TakeInventory("SelectCSG_SwitchSingle",1);
		A_TakeInventory("SelectCSG_SwitchHook",1);
		A_TakeInventory("SelectCSG_SwitchMenu",1);
	}
	
	action void clearcssgtokens()
	{
		for(int j = 0; j < PBX_CSSG.CSSG_ShellsToken1.size(); j++)
			A_takeinventory(PBX_CSSG.CSSG_ShellsToken1[j],10);
	}
}