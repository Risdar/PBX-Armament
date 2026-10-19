Class CrossbowBallistaWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + 4 Bolt Types (4)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.7, 0.7));
		mDisabled = PBX_BackPack_filter & DisablePBX_CrossbowBallistaUpgrade;

		// Standard and Explosive Bolt
		PBX_AddWheel(spw, img:"ProsurvBallista/StandardBallista",	alias:"$PBX_Crossbow_Standard",		token:"CB_Select_NormalMode");
		PBX_AddWheel(spw, img:"ProsurvBallista/ExplosiveBallista",	alias:"$PBX_Crossbow_Explosive",	token:"CB_Select_ExplosiveMode");

		// Demonic and Shock Bolt
		if(PBX_CheckInv("Crossbow_Upgraded"))
        {
			PBX_AddWheel(spw, img:"ProsurvBallista/DemonicBallista", alias:"$PBX_Crossbow_Demonic",	token:"CB_Select_DemonicMode");
			PBX_AddWheel(spw, img:"ProsurvBallista/ShockBallista",	 alias:"$PBX_Crossbow_Shock",	token:"CB_Select_ShockMode");
        } 
		else
        {
			PBX_AddWheel(spw, img:"ProsurvBallista/DemonicBallistaNo",	alias:"$PBX_AmmoNotAvailable",	token:"CB_Select_NO");
			PBX_AddWheel(spw, img:"ProsurvBallista/DemonicBallistaNo",	alias:"$PBX_AmmoNotAvailable",	token:"CB_Select_NO");
        }
		
	}
}