Class ChainsawEditWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + Toggle Lifesteal (1) + Secondary Modes (3)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.8,0.8));

        // Toggle Lifesteal
        if(PBX_CheckInv("ChainsawResourceGather",checkDisabled:false))
        {
            PBX_AddWheel(spw, img:"ChainsawEdit/DisableHeal",	alias:"$PB_SAW_GATHEROFF",	    token:"Saw_Toggle_Lifesteal");
        }
        else
        {
            PBX_AddWheel(spw, img:"ChainsawEdit/EnableHeal",	alias:"$PB_SAW_GATHERON",	    token:"Saw_Toggle_Lifesteal");
        }

        // Slash and Throw
        PBX_AddWheel(spw, img:"ChainsawEdit/Slash",	alias:"$PBX_ChainsawEdit_Slash",	    token:"Saw_Select_Slash", scale:(0.5,0.5));
        PBX_AddWheel(spw, img:"ChainsawEdit/Throw",	alias:"$PBX_ChainsawEdit_Throw",	    token:"Saw_Select_Throw");

        // Quick SSG
        if(PBX_CheckInv("PB_SSG",checkDisabled:false))
        {
            PBX_AddWheel(spw, img:"ChainsawEdit/QuickSSG",	alias:"$PBX_ChainsawEdit_SSG",	    token:"Saw_Select_SSG");
        }
        else
        {
            PBX_AddWheel(spw, img:"ChainsawEdit/NoSSG",	alias:"$PBX_ChainsawEdit_NoSSG",	token:"Saw_No_SSG");
        }
	}

}