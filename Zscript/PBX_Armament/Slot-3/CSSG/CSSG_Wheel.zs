Class CSSGWeaponWheelPage1 : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 4; // Close Wheel (1) + Switch Page (1) + Secondary Modes (2)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester);

		// Switch to Page 2 and Secondary Modes
		PBX_AddWheel(spw, img:"CSSG/SG_Buck",		alias:"$PBX_CSSG_PAGE2_WW",	token:"SelectCSG_SwitchMenu",	scale:mIconScale/2);
		PBX_AddWheel(spw, img:"CSSG/SG_SingleFire",	alias:"$PBX_CSSG_SINGLE",	token:"SelectCSG_SwitchSingle");
		PBX_AddWheel(spw, img:"CSSG/SG_Meathook",	alias:"$PBX_CSSG_HOOK",		token:"SelectCSG_SwitchHook");
	}
}

Class CSSGWeaponWheelPage2 : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 14; // Close Wheel (1) + Base Shells (4) + Upgraded Shells (8)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;

		PBX_InitializeWheel(spw,requester,scale:(0.5,0.5));
		mDisabled = PBX_BackPack_filter & DisablePBX_CSSGUpgrades;

		// Switch to Page 1
		PBX_AddWheel(spw, img:"CSSG/SG_Page",	   alias:"$PBX_CSSG_PAGE1_WW",	token:"SelectCSG_SwitchMenu");

		// Base shell types, 4
		PBX_AddWheel(spw, img:"CSSG/SG_Buck",      alias:"$PBX_CM_BUCKLD", 		token:"SelectCSG_Buckshot");
		PBX_AddWheel(spw, img:"CSSG/SG_Slug",      alias:"$PBX_CM_SLUGLD", 		token:"SelectCSG_Slugshot");
		PBX_AddWheel(spw, img:"CSSG/SG_Flechette", alias:"$PBX_CM_FLCHLD", 		token:"SelectCSG_Flechette");
		PBX_AddWheel(spw, img:"CSSG/SG_Flak",      alias:"$PBX_CM_FLAKLD", 		token:"SelectCSG_Flak");

		// Upgraded shell types, 8
		AddUpgradeSlot(spw, toCheck:"DragonBreathUpgrade",    img:"CSSG/SG_DB",          alias:"$PBX_CM_DGBTLD",  token:"SelectCSG_Dragonsbreath");
		AddUpgradeSlot(spw, toCheck:"ExplosiveUpgrade",       img:"CSSG/SG_Explosive",   alias:"$PBX_CM_EXPLLD",  token:"SelectCSG_Explosive");
		AddUpgradeSlot(spw, toCheck:"WhitePhosphorusUpgrade", img:"CSSG/SG_WPhosphorus", alias:"$PBX_CM_WPLOAD",  token:"SelectCSG_WPhosphorus");
		AddUpgradeSlot(spw, toCheck:"TripleDoomUpgrade",      img:"CSSG/SG_Doom",        alias:"$PBX_CM_DOOMLD",  token:"SelectCSG_Doom");
		AddUpgradeSlot(spw, toCheck:"DanmakuUpgrade",         img:"CSSG/SG_Danmaku",     alias:"$PBX_CM_DNMKULD", token:"SelectCSG_Danmaku");
		AddUpgradeSlot(spw, toCheck:"SubZeroUpgrade",         img:"CSSG/SG_SubZ",        alias:"$PBX_CM_SUBZRLD", token:"SelectCSG_SubZero");
		AddUpgradeSlot(spw, toCheck:"HellFireUpgrade",        img:"CSSG/SG_HellFire",    alias:"$PBX_CM_HELFRLD", token:"SelectCSG_HellFire");
		AddUpgradeSlot(spw, toCheck:"AcidShellsUpgrade",      img:"CSSG/SG_Acid",        alias:"$PBX_CM_ACIDLD",  token:"SelectCSG_Acid");
		
	}

	void AddUpgradeSlot(in out array <PB_SpecialWheel_Mode> spw, string toCheck, string img, string alias, string token)
	{
		if (PBX_CheckInv(toCheck))
		{
			PBX_AddWheel(spw, img: img, alias: alias, token: token);
		}
		else
		{
			PB_SpecialWheel_Mode CSSG_No_Upgrade = new("PB_SpecialWheel_Mode");
			CSSG_No_Upgrade.img = "graphics/pywheel/SG_NO.png";
			CSSG_No_Upgrade.Alias = "$PBX_AmmoNotAvailable";
			CSSG_No_Upgrade.tokentogive = "SelectCSG_No";
			CSSG_No_Upgrade.scalex = mIconScale.x;
			CSSG_No_Upgrade.scaley = mIconScale.y;
			spw.Push(CSSG_No_Upgrade);
		}
	}
}
