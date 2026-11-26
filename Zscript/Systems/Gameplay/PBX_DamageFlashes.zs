class OuchFlashAdjuster : CustomIntCVar
{
    override int ModifyValue(Name CVarName, int val)
    {
		if(val < OuchFlashDuration) 
			return OuchFlashDuration + 1;
		else 
			return val;
    }
}

class PBX_DamageFlash_Handler : EventHandler
{
	override void WorldThingDamaged(WorldEvent e)
	{
		if(OuchFlashOnlyMonsters && e.thing.bISMONSTER == false) 
		return;
		if(e.damage < OuchFlashMinDamage) 
		return;
		
		If(OuchFlashDuration > 0 && !(e.thing.FindBehavior("OuchieFlash")))
		{
			OuchieFlash ReceivedFlash = OuchieFlash(e.thing.AddBehavior("OuchieFlash"));
			If(ReceivedFlash)
			{
				CVAR ColorToUse = CVAR.FindCVar("OuchFlash_"..e.DamageType);
				if(!ColorToUse) ColorToUse = CVAR.FindCVar("OuchFlash_");
				
				e.thing.SetShade(ColorToUse.GetString());
			}
		}
	}
	override void WorldThingDied(WorldEvent e)
	{
		if(OuchFlashOnlyMonsters && e.thing.bISMONSTER == false) 
		return;

		If(OuchFlashDuration > 0 && !(e.thing.FindBehavior("OuchieFlash")))
		{
			OuchieFlash ReceivedFlash = OuchieFlash(e.thing.AddBehavior("OuchieFlash"));
			If(ReceivedFlash)
			{
				CVAR ColorToUse = CVAR.FindCVar("OuchFlash_"..e.DamageType);
				if(!ColorToUse) ColorToUse = CVAR.FindCVar("OuchFlash_");
				
				e.thing.SetShade(ColorToUse.GetString());
			}
		}
	}
}

class OuchieFlash : Behavior
{
	uint8 OGRenderStyle, FlashDuration, StayInInventory, timer;
	float OGalpha;
	color FlashColor;
	bool DontChange;

	void RestoreRendering()
	{
		owner.A_SetRenderStyle(OGalpha, OGRenderStyle);
		owner.LightLevel = owner.default.LightLevel;
		owner.bADDLIGHTLEVEL = owner.default.bADDLIGHTLEVEL;
	}
	
	override void Initialize()
	{
        StayInInventory = OuchFlashCooldown;
        FlashDuration = OuchFlashDuration;
        OGRenderStyle = owner.GetRenderStyle();
        OGalpha = owner.alpha;
        If(OGRenderStyle == STYLE_None || OGalpha < 0.1 || owner.bINVISIBLE)
        {
            Destroy();
        }
        owner.A_SetRenderStyle(1.0, OuchFlashSolidColor? STYLE_Stencil : STYLE_Shaded);
        
        if(OuchFlashBrightness)
        {
            owner.bADDLIGHTLEVEL = true;
            owner.LightLevel += OuchFlashBrightness;
        }
	}
	
	override void Tick()
	{
		if(owner)
		{
			if(++timer >= FlashDuration)
			{
				RestoreRendering();
			}
			if(timer >= StayInInventory)
			{
				owner.ClearBehaviors();
			}
		}
	}
}