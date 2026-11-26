// MIT License
// Copyright (c) 2026 generic name guy
// This file is part of "PB Damage Feedback" (addon)
//////////////////////////// HANDLER ////////////////////////////////////////////////////////////////////////////////////
class PBX_HitFeedback_Handler : EventHandler
{
    override void PlayerEntered( PlayerEvent e )
	{
		PlayerPawn player = PlayerPawn( players[e.PlayerNumber].mo );

        bool disabled;
		let disableDmgFeedback = Cvar.GetCvar('PBX_CVAR_HF', player.player);
		if(disableDmgFeedback) disabled = disableDmgFeedback.getBool();

        if(!player || disabled || PBX_COMPAT_ULTIMATEVISOR) 
        {
            return;
        }
            
        player.GiveInventoryType("PBX_HitFeedback_Inventory");

        cachedOverlays[0] = TexMan.CheckForTexture( "Graphics/visorcrack1.png" );
        cachedOverlays[1] = TexMan.CheckForTexture( "Graphics/crackflash1.png" );
        cachedOverlays[2] = TexMan.CheckForTexture( "Graphics/fuckasscircle.png" );
        S_StartSound("hud/shieldbreak", 0, volume: 0);
	}

    ui float shakeMagnitude;
    ui double animationProgress[2];
    ui int animationTime;
    const ANIM_DURATION = double( floor( 0.43 * TICRATE ) );
    ui vector2 overlayPos[2];
    TextureID cachedOverlays[3];

    override void InterfaceProcess( ConsoleEvent e )
    {
        if( e.name == "PB_hf_ShieldBroken" )
        {
            shakeMagnitude = 1;
            animationProgress[0] = 0.f;
            animationProgress[1] = 0.f;
            animationTime = ANIM_DURATION;
        }
    }

    override void UiTick()
    {
        animationProgress[1] = animationProgress[0];
        animationProgress[0] = 1.f - ( animationTime / ANIM_DURATION );

        overlayPos[1] = overlayPos[0];
        overlayPos[0] = ( cfrandom( -50, 50 ), cfrandom( -50, 50 ) ) * shakeMagnitude;

        shakeMagnitude *= 0.7;

        if( animationTime > 0 ) animationTime--;

        //console.printf("%i, %f, %f", animationTime, animationProgress[1], animationProgress[0]);
    }

    override void RenderUnderlay( RenderEvent e )
    {
        double i_animationProgress = GetTicFracInterpolation( animationProgress[1], animationProgress[0], e.FracTic );
        // console.printf("%f", i_animationProgress);
        vector2 i_shake = overlayPos[0];
        //( GetTicFracInterpolation( overlayPos[1].x, overlayPos[0].x, e.FracTic ), GetTicFracInterpolation( overlayPos[1].y, overlayPos[0].y, 1 ) );

        double overlayScale, overlay2Scale, overlay3Scale;
        /*if( i_animationProgress < 0.26 )
            overlayScale = PB_HitFeedback_Math.LinearMapClamped( i_animationProgress, 0.0, 0.1, 1.1, 1.f, 1.f, 1.1 );
        else*/
            overlayScale = PB_HitFeedback_Math.LinearMapClamped( i_animationProgress, 0.26, 1.f, 1.f, 3, 1.f, 3 );

        double overlayAlpha, overlay2Alpha, overlay3Alpha;

        //if( i_animationProgress < 0.5 )
        //    overlayAlpha = PB_HitFeedback_Math.LinearMapClamped( i_animationProgress, 0.0, 0.1, 0.f, 1.f, 0.f, 1.f );
        //if( i_animationProgress > 0.5 )
            overlayAlpha = PB_HitFeedback_Math.LinearMapClamped( i_animationProgress, 0.26, 1.f, 1.f, 0.f, 0.f, 1.f );

        /*if(i_animationProgress <= 0.07 || ( i_animationProgress >= 0.2 && i_animationProgress <= 0.26 ) || i_animationProgress > 0.3 )
            
        else
            overlay2Alpha = 0;*/

        overlay2Alpha = PB_HitFeedback_Math.LinearMapClamped( i_animationProgress, 0.f, 0.57, 1.f, 0.f, 0.f, 1.f );
        overlay2Scale = PB_HitFeedback_Math.LinearMapClamped( i_animationProgress, 0.f, 0.57, 1.f, 3, 1.f, 3 );

        overlay3Alpha = PB_HitFeedback_Math.LinearMapClamped( i_animationProgress, 0.f, 1, 1.f, 0.f, 0.f, 1.f );
        overlay3Scale = PB_HitFeedback_Math.LinearMapClamped( i_animationProgress, 0.f, 1, 1.f, 4.f, 1.f, 4.f );

        if( animationTime > 0 ) {
            Screen.DrawTexture(
                cachedOverlays[2], false, 
                Screen.GetWidth() / 2.f, Screen.GetHeight() / 2.f,
                DTA_DestWidth, Screen.GetWidth(), DTA_DestHeight, Screen.GetWidth(), 
                DTA_Alpha, overlay3Alpha * 0.1,
                DTA_CenterOffset, true, 
                DTA_ScaleX, overlay3Scale, DTA_ScaleY, overlay3Scale,
                DTA_LegacyRenderStyle, STYLE_Add
            );

            Screen.DrawTexture(
                cachedOverlays[0], false, 
                Screen.GetWidth() / 2.f + i_shake.x, Screen.GetHeight() / 2.f + i_shake.y,
                DTA_DestWidth, Screen.GetWidth(), DTA_DestHeight, Screen.GetHeight(), 
                DTA_Alpha, overlayAlpha * 0.5,
                DTA_CenterOffset, true, 
                DTA_ScaleX, overlayScale + 0.1, DTA_ScaleY, overlayScale + 0.1
            );

            Screen.DrawTexture(
                cachedOverlays[1], false, 
                Screen.GetWidth() / 2.f, Screen.GetHeight() / 2.f,
                DTA_DestWidth, Screen.GetWidth(), DTA_DestHeight, Screen.GetHeight(), 
                DTA_Alpha, (overlayAlpha * overlay2Alpha) * 0.5,
                DTA_CenterOffset, true, 
                DTA_ScaleX, overlay2Scale + 0.1, DTA_ScaleY, overlay2Scale + 0.1,
                DTA_LegacyRenderStyle, STYLE_Add
            );
        }
    }

    ui double GetTicFracInterpolation( double poll1, double poll2, double ticFrac )
    {
        return poll1 * ( 1.f - ticFrac ) + poll2 * ticFrac;
    }
}

//////////////////////////// INVENTORY ////////////////////////////////////////////////////////////////////////////////////
class PBX_HitFeedback_Inventory : Inventory 
{
    /*override void AbsorbDamage(int damage, Name damageType, out int newdamage, Actor inflictor, Actor source, int flags)
    {
        
    }*/

    enum EHPCounters {
        P_CURRENT,
        P_OLD
    };

    int playerArmor[2], playerHealth[2];

    override void DoEffect()
    {
        Super.DoEffect();

        playerArmor[P_CURRENT] = owner.CountInv( "BasicArmor" );
        playerHealth[P_CURRENT] = owner.Health;

        int armorDelta = min( 0, playerArmor[P_OLD] - playerArmor[P_CURRENT] );
        int healthDelta = min( 0, playerHealth[P_OLD] - playerHealth[P_CURRENT] );

        if( playerArmor[P_OLD] > playerArmor[P_CURRENT] && playerArmor[P_CURRENT] <= 0 && playerHealth[P_CURRENT] > 0 )
        {
            EventHandler.SendInterfaceEvent( owner.PlayerNumber(), "PB_hf_ShieldBroken", armorDelta + healthDelta );
            owner.A_StartSound( "hud/shieldbreak", flags: CHANF_UI );
        }

        playerArmor[P_OLD] = playerArmor[P_CURRENT];
        playerHealth[P_OLD] = playerHealth[P_CURRENT];
    }
}


//////////////////////////// SHAREDMATH ////////////////////////////////////////////////////////////////////////////////////
class PB_HitFeedback_Math abstract 
{
    clearscope static double LinearMapClamped( double val, double o_Min, double o_Max, double n_Min, double n_Max, double ret_Min, double ret_Max ) 
    {
        return clamp( PB_HitFeedback_Math.LinearMap( val, o_Min, o_Max, n_Min, n_Max ), ret_Min, ret_Max );
    }

    //[inkoalawetrust] Written by Agent_Ash, makes the Val ranging from O_Min to O_Man be crushed down to the range of N_Min and N_Max.
	//Useful for example for compressing distances to a range of 0 to 1.0.
	ClearScope Static Double LinearMap (Double Val, Double O_Min, Double O_Max, Double N_Min, Double N_Max) 
	{
		Return (Val - O_Min) * (N_Max - N_Min) / (O_Max - O_Min) + N_Min;
	}

    static double Lerp(double a, double b, double lerpFactor)
	{
		double result = ((1.f - lerpFactor) * a) + (lerpFactor * b);
		return result;
	}
}