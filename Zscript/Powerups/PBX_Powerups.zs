#include "./PBX_Powerups_Spawners.zs"
#include "./PBX_Powerups_Tips.zs"

#include "./PowerupSpheres.zs" // Powerup Spheres
#include "./AuraSpheres.zs" // Aura Spheres
#include "./TaintedSpheres.zs" // Tainted Spheres

enum PBX_Powerups_Values
{
    MEGABERSERK_HP      = 200
    ,MEGABERSERK_MAX    = 200

    ,SUPERSPHERE_HP     = 100
    ,SUPERSPHERE_MAX    = 200

    ,ULTRAARMOR_SV      = 70
    ,ULTRAARMOR_AMT     = 100

    ,HYPERSPHERE_HP     = 200
    ,HYPERSPHERE_MAX    = 200
    ,HYPERARMOR_SV      = 100
    ,HYPERARMOR_AMT     = 200

    ,MINISPHERE_HP      = 50
    ,MINISPHERE_MAX     = 200
    ,MINIARMOR_SV       = 60
    ,MINIARMOR_AMT       = 50

    ,REDSOUL_HP   		= 150
    ,REDSOUL_MAX   		= 200

	,DARKMEGA_HP   		= 200
    ,DARKMEGA_MAX   	= 200

    ,AURASPHERE_HP   	= 100
    ,AURASPHERE_MAX   	= 200

}

mixin class PBX_Duration_Powerups
{
    override void BeginPlay()
	{
		super.BeginPlay();
		EffectTics = getDuration(self);
	}

    private
    int getDuration(actor mActor)
	{
        if(!mActor) return 1; 
        
		name tmp;
		switch(mActor.getClassName())
		{
            // Tainted Spheres
			case 'PBX_PowerInvisTainted': 	    tmp = 'pbx_invistaint_duration'; 	break;
			case 'PBX_PowerDeflect': 		    tmp = 'pbx_deflect_duration'; 		break;
			case 'PBX_PowerInvulTainted': 	    tmp = 'pbx_invultaint_duration'; 	break;
			case 'PBX_PowerTaintedRegen': 	    tmp = 'pbx_taintregen_duration'; 	break;
			// Vanilla Powerups
			case 'PBX_PowerBuddha': 		    tmp = 'pbx_buddha_duration'; 		break;
			case 'PBX_PowerDrain': 		 	    tmp = 'pbx_drain_duration'; 		break;
			case 'PBX_PowerFlight': 		    tmp = 'pbx_flight_duration'; 		break;
			case 'PBX_PowerFrightener': 	    tmp = 'pbx_frightener_duration'; 	break;
			case 'PBX_PowerHighJump': 		    tmp = 'pbx_highjump_duration'; 		break;
			case 'PBX_PowerInfiniteAmmo': 	    tmp = 'pbx_infammo_duration'; 		break;
			case 'PBX_PowerProtection': 	    tmp = 'pbx_protect_duration'; 		break;
			case 'PBX_PowerReflection': 	    tmp = 'pbx_reflect_duration'; 		break;
			case 'PBX_PowerRegeneration': 	    tmp = 'pbx_regen_duration'; 		break;
			case 'PBX_PowerTimeFreezer': 	    tmp = 'pbx_timefreeze_duration'; 	break;
			// Aura Spheres
			case 'PBX_PowerElectAura': 	 	    tmp = 'pbx_electaura_duration'; 	break;
			case 'PBX_PowerFrostAura': 	 	    tmp = 'pbx_frostaura_duration'; 	break;
			case 'PBX_PowerFireAura': 		    tmp = 'pbx_fireaura_duration'; 		break;
			// Others
            case 'PBX_Adrenaline_Speed': 
			case 'PBX_Adrenaline_QuadGiver':    tmp = 'pbx_adrenaline_duration'; 	break;
		}

        let c = CVar.FindCVar(tmp);
        int mResult = c ? c.GetInt() * Object.TICRATE : 1;  // So its always in seconds
        return mResult;
	}

}

mixin class PBX_PowerupTimer
{
	int time;
	bool lf;

	void PowerupTimer(color col, color col2 = 0)
	{
		time = EffectTics;
		switch(time)
		{
			case 105:
			case 70:
			case 35:
				lf = CVar.GetCVar("pb_lowflashesmode", owner.player).GetBool();
				owner.A_SetBlend(col, lf ? 0.08 : 0.25, lf ? 20 : 12, col2);
				owner.A_StartSound("powerup/countdown", CHAN_AUTO, CHANF_OVERLAP | CHANF_UI);
			default:
				break;
		}
	}
	
	void EndBlend(color col, color col2 = 0)
	{ 
		owner.A_SetBlend(col, lf ? 0.1 : 0.50, 35, col2);
		owner.A_StartSound("powerup/ranout", CHAN_AUTO, CHANF_OVERLAP | CHANF_UI); 
	}

	override void PlayPickupSound(actor toucher)
	{
		let hnd  = PB_EventHandler(EventHandler.Find("PB_EventHandler"));
		if(hnd)
		{
			if(hnd.pickuptic[toucher.PlayerNumber()]==gametic) return;
			hnd.pickuptic[toucher.PlayerNumber()] = gametic;
		}
		double atten;
		int flags = CHANF_OVERLAP|CHANF_MAYBE_LOCAL;
		if(bNoAttenPickupSound) atten = ATTN_NONE;
		else atten = ATTN_NORM;
		if(toucher && toucher.CheckLocalView()) flags |= CHANF_NOPAUSE;
		toucher.A_StartSound(PickupSound,1002,flags,1.0,atten);
	}
}