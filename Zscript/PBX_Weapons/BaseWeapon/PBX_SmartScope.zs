//////////////////////////// WEAPON CODE ////////////////////////////////////////////////////////////////////////////////////
extend class PBX_WeaponBase
{
    private bool mScopeLockedOn;
    private int mSmartScopeMode;

    enum PBX_SmartScopeMode
    {
        SMARTSCOPE_DISABLED,
        SMARTSCOPE_PARTIAL,
        SMARTSCOPE_FULL
    }

    // Call in wherever the function to handle the weapon special is located
    action void PBX_ToggleSmartScope()
    {
        invoker.mSmartScopeMode = (invoker.mSmartScopeMode + 1) % 3;
        A_StartSound("MS/Button", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
        A_SetBlend(0x00a100, 0.2, 3);
        switch(PBX_GetSmartScopeMode())
        {
            case SMARTSCOPE_DISABLED:   A_Print("$PBX_Scope1"); break;
            case SMARTSCOPE_PARTIAL:    A_Print("$PBX_Scope2"); break;
            case SMARTSCOPE_FULL:       A_Print("$PBX_Scope3"); break;
        }
    }

    action PBX_SmartScopeMode PBX_GetSmartScopeMode()
    {
        return invoker.mSmartScopeMode;
    }

    // Call in Ready States
    action void PBX_ReadySmartScope(string fontColor = "Green")
    {
        // Check if the scope is disabled
        if(PBX_GetSmartScopeMode() == SMARTSCOPE_DISABLED) 
        {
            return;
        }

        // Check whats in front of the player
        FLineTraceData HitData;
        bool hit = LineTrace(Angle, 6000, Pitch, 0, player.ViewHeight, 0, 0, HitData);

        // If it doesnt hit anything, dont draw
        if(!hit) 
        {
            EventHandler.SendInterfaceEvent(PlayerNumber(), "NoHitSmartScope");
            return;
        }

        // If it hits something, is a monster, and is not friendly
        if(HitData.HitActor && HitData.HitActor.bISMONSTER && HitData.HitActor.bFRIENDLY == false)
        {	
            // Play a sound
            if(!invoker.mScopeLockedOn)
            {
                // A_SetBlend(0x00a100, 0.2, 3);
                invoker.mScopeLockedOn = true;
                A_StartSound("IronSights", CHAN_WEAPON, CHANF_OVERLAP, 1.0, pitch:1.4);
            }

            // Show the actor's wireframe
            let Wireframe = PBX_CubeRadius(Spawn("PBX_CubeRadius", HitData.HitActor.pos));
            if(Wireframe)
            {
                Wireframe.scale.x = double(HitData.HitActor.Radius) * 2;
                Wireframe.scale.Y = double(HitData.HitActor.Height) * Level.pixelstretch;
                Wireframe.vel = HitData.HitActor.vel;
                Wireframe.mColor = fontColor == "Blue" ? PBX_CubeRadius.BLUE : PBX_CubeRadius.GREEN;
            }

            // Show the Monsters Information
            if(PBX_GetSmartScopeMode() == SMARTSCOPE_FULL)
            {
                // Get the Name, Max HP, and Painchance
                PBX_SmartScopeHandler.SendInterfaceEvent(
                    self.PlayerNumber(), 
                    "PrintScopeData_"..fontColor..":"..
                    HitData.HitActor.GetTag(), 
                    HitData.HitActor.health, 
                    HitData.HitActor.GetSpawnHealth(), 
                    HitData.HitActor.PainChance
                );
                // Get the Distance
                PBX_SmartScopeHandler.SendInterfaceEvent(
                    self.PlayerNumber(), 
                    "PrintScopeData2:", 
                    Distance3D(HitData.HitActor), 
                    PBX_GetZoomLevel()
                );
            }
        }
        // If it hits something but is not a monser and the scopedlockon is on, turn it off
        else if(invoker.mScopeLockedOn)
        {
            // A_SetBlend(0xa19900, 0.2, 3);
            invoker.mScopeLockedOn = false;
            A_StartSound("IronSights", CHAN_WEAPON, CHANF_OVERLAP, 1.0, pitch:1.3);
            EventHandler.SendInterfaceEvent(PlayerNumber(), "NoHitSmartScope");
            return;
        }

        // If it hits something but is not a monser, also dont draw
        else
        {
            EventHandler.SendInterfaceEvent(PlayerNumber(), "NoHitSmartScope");
            return;
        }
    }
}

//////////////////////////// HANDLER CODE ////////////////////////////////////////////////////////////////////////////////////
// This is modified from Doom Deluxe, all credits goes to Dox778 and the Doom Deluxe team
class PBX_SmartScopeHandler : EventHandler
{
    // Smart Scope System
	ui bool 	mCanDraw;
	ui int 		mMaxHealth, mCurrentHealth, mZoomScale, mPainChance;
	ui string 	mActorName;
	ui double 	mDistance;
	ui bool 	mUseBlueFont;
    
    override void InterfaceProcess(ConsoleEvent e)
    {
		bool blue = e.name.IndexOf("PrintScopeData_Blue:") >= 0;
    	bool green = e.name.IndexOf("PrintScopeData_Green:") >= 0;
    	bool noHit = e.name.IndexOf("NoHitSmartScope") >= 0;

		if(e.IsManual || noHit)
		{
			mCanDraw = false;
			return;
		}

		if((blue || green))
        {
			mUseBlueFont 	= blue;
            mCurrentHealth  = e.args[0];
			mMaxHealth 		= e.args[1];
			double painC 	= e.args[2];
			mPainChance 	= painC / 256 * 100;
			Array<string> command;
			e.Name.Split (command, ":");
			
			if(command.Size() == 2)
				mActorName = command[1];
				
			mCanDraw = true;
        }

		if(e.name.IndexOf("PrintScopeData2:") >= 0)
        {
            double ok = e.args[0];
			mDistance = ok / 32; //32 units should rougly be a meter i hope
			mZoomScale = e.args[1];
        }
    }

	override void UITick()
	{
        let plr = players[consoleplayer].mo;
		if(!plr || !plr.FindInventory("Zoomed"))
		{
			mCanDraw = false;
		}
	}

	override void RenderUnderlay(RenderEvent e)
	{	
		let phud = PB_Hud_ZS(StatusBar);
        if (!phud || !mCanDraw) return;

		vector2 hud_origin;
		vector2 hud_size;
		[hud_origin.x, hud_origin.y, hud_size.x, hud_size.y] = Screen.GetViewWindow();

		int color = mUseBlueFont ? Font.CR_CYAN : Font.CR_GREEN;
		int flags = BaseStatusBar.DI_SCREEN_CENTER | BaseStatusBar.DI_TEXT_ALIGN_LEFT;

		int hudX = 15;
		int hudY = 30;
		int steps = 15;

		phud.PBHud_DrawString(phud.mBoldFont, mActorName, (hudX, 10), flags, color, scale: (1.3, 1.3));

		Array<string> lines;
		lines.Push(string.format(StringTable.Localize("$PBXWeapons_SmartScope_MaxHP"), mMaxHealth));
		lines.Push(string.format(StringTable.Localize("$PBXWeapons_SmartScope_CurrHP"), mCurrentHealth));
		lines.Push(string.format(StringTable.Localize("$PBXWeapons_SmartScope_PainChance"), mPainChance));
		lines.Push(string.format(StringTable.Localize("$PBXWeapons_SmartScope_Distance"), mDistance));

		for (int i = 0; i < lines.Size(); i++)
		{
			phud.PBHud_DrawString(phud.mDefaultFont, lines[i], (hudX, hudY + i * steps), flags, color);
		}

		// Old version
		// Screen.DrawText(BigFont, color, 190, 86, mActorName, DTA_Clean, true);
		// Screen.DrawText(SmallFont, color, 190, 104, mPainChance, DTA_Clean, true);
		// Screen.DrawText(SmallFont, color, 190, 74, mDistance, DTA_Clean, true);
	}
}