Class CryoASGWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;

	override int GetSPCount(actor requester)
	{
		return 7; // Close Wheel (1) + Modes (6)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;

		PBX_InitializeWheel(spw,requester,scale:(0.65,0.65));

		// Modes
		// Primary
		PBX_AddWheel(spw, img:"CryoASG/PlasmaBlast",	alias:"$PBX_CryoASG_PlasmaBlast",	token:"CryoASG_Select_PlasmaBlast");
		PBX_AddWheel(spw, img:"CryoASG/FreezeBlast",	alias:"$PBX_CryoASG_FreezeBlast",	token:"CryoASG_Select_FreezeBlast");
		PBX_AddWheel(spw, img:"CryoASG/LightningArc",	alias:"$PBX_CryoASG_Lightning",		token:"CryoASG_Select_Lightning");
		// Secondary
		PBX_AddWheel(spw, img:"CryoASG/StunBomb",		alias:"$PBX_CryoASG_StunBomb",		token:"CryoASG_Select_StunBomb");
		PBX_AddWheel(spw, img:"CryoASG/IceSpear",		alias:"$PBX_CryoASG_IceSpear",		token:"CryoASG_Select_IceSpear");
		PBX_AddWheel(spw, img:"CryoASG/PlasmaBreath",	alias:"$PBX_CryoASG_PlasmaBreath",	token:"CryoASG_Select_PlasmaBreath");

	}
}