// ============================================================
// PBX Powerups - From PB's More Items mod by HyperExia
// ============================================================
//////////////////////////// MEGA BERSERK ///////////////////////////////////////////////////////////////////////////////
class PBX_MegaBerserk : PB_Berserk
{
	Default
	{
		Inventory.AltHudIcon "PSTRC0";
		Tag "$MEGABERSERK_TAG";
	}

	override bool Use(bool pickup)
	{
        if(!PB_HelpNotificationsHandler.CheckTipEvent(1 << 6, CVar.GetCvar("pb_helpflags", owner.Player)))
		{
			Array<String> pbTipsBuf;
			pbTipsBuf.Push("$PB_BERSERK_TIP_1");
			pbTipsBuf.Push(string.format(StringTable.Localize("$PB_BERSERK_TIP_2"), PB_HelpNotificationsHandler.PB_FormatKeybinds("+pb_specialwheel")));
			PB_HelpNotificationsHandler.PB_SendTipArray(pbTipsBuf, "pb_helpflags", 1 << 6);
		}
		owner.A_GiveInventory("PB_PowerStrength");
		owner.GiveBody(MEGABERSERK_HP,MEGABERSERK_MAX);
		owner.A_SetBlend("Red",0.75,16);
		if(pb_newmugshot) owner.A_SetMugshotState("BerserkGrin");
		return true;
	}

	override string PickupMessage() 
	{
		string msg = StringTable.Localize("$MEGABERSERK_PICKUP");
		if(ownHP < 25) msg = StringTable.Localize("$MEGABERSERK_PICKUP_LOW");
		return string.format(msg, max(0, 100 - ownHP));
	}

	States
	{
		Spawn:
			PSTR C -1;
			stop;
	}
}

//////////////////////////// SUPER SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_SuperSphere : PB_Soulsphere
{
	Default
	{
		Inventory.AltHudIcon "SPRSA0";
		Inventory.Amount SUPERSPHERE_HP;
		Inventory.MaxAmount SUPERSPHERE_MAX;
		Inventory.PickupMessage "$SUPERSPHERE_PICKUP";
		Health.LowMessage 25, "$SUPERSPHERE_PICKUP_LOW";
		Tag "$SUPERSPHERE_TAG";
	}

	override bool TryPickup (in out Actor other) 
	{
		other.A_SetBlend("Blue",0.75,16);
		if(other.player && CVar.GetCVar("pb_newmugshot", other.player).GetBool())
			other.A_SetMugshotState("SoulsphereGrin");
		return super.TryPickup(other);
	}
	
	States
	{
		Spawn:
			SPRS ABCDEFGHIJ 3;
			loop;
	}
}

//////////////////////////// ULTRA SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_UltraSphere : PB_Inventory
{	
	Default
	{
		Inventory.AltHudIcon "ULTSA0";
		Inventory.PickupMessage "$ULTRASPHERE_PICKUP";
		Tag "$ULTRASPHERE_TAG";
	}

	int ownHP, ownAP;

	override bool Use(bool pickup)
	{
		owner.A_SetBlend("White",0.75,16);
		ownHP = clamp(200 - owner.health, 0, 200);
		ownAP = clamp(200 - owner.CountInv("BasicArmor"), 0, 200);
		owner.A_GiveInventory(GetReplacement("PB_Soulsphere").getClassName());
		owner.A_GiveInventory("PBX_UltraArmor");
		if(pb_newmugshot) owner.A_SetMugshotState("MegasphereGrin");
		return true;
	}
	
	override string PickupMessage()
	{
		string msg = string.format(StringTable.Localize(Super.PickupMessage()), ownHP, ownAP);
		return msg;
	}
	
	States
	{
		Spawn:
			ULTS ABCDEFGHIJ 3;
			loop;
	}
}
class PBX_UltraArmor : PBX_ArmorBase
{
	Default
    {
		Armor.SavePercent ULTRAARMOR_SV;
		Armor.SaveAmount ULTRAARMOR_AMT;
		Inventory.PickupMessage "$ULTRAARMOR_PICKUP";
        Inventory.AltHudIcon "ULTSA0";
		Tag "$ULTRAARMOR_TAG";
	}
}

//////////////////////////// HYPER SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_HyperSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "HYPSA0";
		Inventory.PickupMessage "$HYPERSPHERE_PICKUP";
		Tag "$HYPERSPHERE_TAG";
	}

	int ownHP, ownAP;

	override bool Use(bool pickup)
	{
		owner.A_SetBlend("White",0.75,16);
		ownHP = clamp(200 - owner.health, 0, 200);
		ownAP = clamp(200 - owner.CountInv("BasicArmor"), 0, 200);
		owner.GiveBody(HYPERSPHERE_HP,HYPERSPHERE_MAX);
		owner.A_GiveInventory("PBX_HyperArmor");
		if(pb_newmugshot) owner.A_SetMugshotState("MegasphereGrin");
		return true;
	}
	
	override string PickupMessage()
	{
		string msg = string.format(StringTable.Localize(Super.PickupMessage()), ownHP, ownAP);
		return msg;
	}
	
	States
	{
		Spawn:
			HYPS ABCDEFGHIJ 3;
			loop;
	}
}
class PBX_HyperArmor : PBX_ArmorBase
{
	Default
    {
		Armor.SavePercent HYPERARMOR_SV;
		Armor.SaveAmount HYPERARMOR_AMT;
		Inventory.PickupMessage "$HYPERARMOR_PICKUP";
        Inventory.AltHudIcon "HYPSA0";
		Tag "$HYPERARMOR_TAG";
	}
}

//////////////////////////// MINI SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_MiniSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "MINIA0";
		Inventory.PickupMessage "$MINISPHERE_PICKUP";
		Inventory.PickupSound "SSPH";
		Tag "$MINISPHERE_TAG";
	}

	int ownHP, ownAP;

	override bool Use(bool pickup)
	{
		owner.A_SetBlend("White",0.75,16);
		ownHP = clamp(200 - owner.health, 0, 200);
		ownAP = clamp(200 - owner.CountInv("BasicArmor"), 0, 200);
		owner.GiveBody(MINISPHERE_HP,MINISPHERE_MAX);
		owner.A_GiveInventory("PBX_MiniArmor");
		if(pb_newmugshot) owner.A_SetMugshotState("MegasphereGrin");
		return true;
	}
	
	override string PickupMessage()
	{
		string msg = string.format(StringTable.Localize(Super.PickupMessage()), ownHP, ownAP);
		return msg;
	}
	
	States
	{
		Spawn:
			MINI ABCDEFGHIJ 3;
			loop;
	}
}
class PBX_MiniArmor : PBX_ArmorBase
{
	Default
    {
		Armor.SavePercent MINIARMOR_SV;
		Armor.SaveAmount MINIARMOR_AMT;
		Inventory.PickupMessage "$MINIARMOR_PICKUP";
        Inventory.AltHudIcon "MINIA0";
		Tag "$MINIARMOR_TAG";
	}
}

// ============================================================
// PBX Powerups - From Unless You Got Powah
// ============================================================
//////////////////////////// DEFLECT SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_DeflectSphere : PB_Inventory
{
	Default
	{
		RenderStyle "Translucent";
		Inventory.AltHudIcon "PDFSA0";
		Inventory.PickupMessage "$DEFLECTSPHERE_PICKUP";
		Inventory.PickupSound "INVISIBL";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$DEFLECTSPHERE_PICKUP";
	}

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_Deflect_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,PBX_POWERUP_HELP_FLAG,PBX_Powerups_Tip_DeflectSphere);
		}
		owner.A_SetBlend("LightGreen",0.75,16);
		owner.A_GiveInventory("PBX_DeflectGiver");
		return true;
	}

	States
	{
		Spawn:
			PDFS ABCD 6 bright;
			loop;
	}
}

class PBX_DeflectGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerDeflect"; } }
class PBX_PowerDeflect : Powerup 
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;
	bool zeroTurn;	// "random" deflection direction when projectile aims directly at player
	
	Default
	{
		Powerup.Color "LightGreen", 0.2;
	}
	
	override void InitEffect ()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("DeflectLight","DeflectLight");
		zeroTurn = random(0,1);
	}

	override void DoEffect ()
	{
		Super.DoEffect();
		PowerupTimer("LightGreen");
		Actor ob;
		ThinkerIterator iter = ThinkerIterator.Create();

		while (ob = Actor(iter.Next()))
		{
			bool shouldTrack = (!ob 
				|| !ob.bMissile 
				|| ob.bSeekermissile 
				|| ob.target == Owner 
				|| !(ob is "PB_Monster_Projectile")
			);

			if (shouldTrack) continue;
			
			// console.printf("projectile tracked");
			double v = ob.vel.Length();	// speed of projectile
			double ang = VectorAngle(ob.vel.x, ob.vel.y);	// direction of projectile
			double dist = ob.Distance3D(Owner);	// distance from player

			if (dist > 35*v) continue;	// too far away, no need to deflect
			
			zeroTurn = !zeroTurn;
			
			vector2 vecToPlayer = ob.Vec2To(Owner);	
			double angleToPlayer = VectorAngle(vecToPlayer.x, vecToPlayer.y); // direction from projectile to player
			double angleDelta = deltaangle(ang, angleToPlayer);	// how much the projectile is off
			
			if (abs(angleDelta) > 60) continue;	// not going to player (too much off)
			
			double newDiff;		// new direction difference
			if (angleDelta < 0) newDiff = 3.0;
			else if (angleDelta > 0 || zeroTurn) newDiff = -3.0;
			else newDiff = 3.0;
			
			ang += newDiff;
			double flatVel = sqrt(ob.vel.x*ob.vel.x + ob.vel.y*ob.vel.y);
			ob.vel.x = flatVel * cos(ang);
			ob.vel.y = flatVel * sin(ang);
			ob.angle += newDiff;
			
		}
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("LightGreen");
		owner.A_RemoveLight("DeflectLight");
	}
}

// ============================================================
// PBX Powerups - Based on Vanilla Doom's Powerups
// ============================================================
//////////////////////////// LEGEND SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_LegendSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "LESPA0";
		Inventory.PickupMessage "$LEGENDSPHERE_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Scale .73;
		Tag "$LEGENDSPHERE_PICKUP";
	}

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_Legend_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,PBX_POWERUP_HELP_FLAG,PBX_Powerups_Tip_LegendSphere);
		}
		owner.A_SetBlend("DarkOrange",0.75,16);
		owner.A_GiveInventory("PBX_BuddhaGiver");
		if(pb_newmugshot) owner.A_SetMugshotState("Grin");
		return true;
	}

	States
	{
		Spawn:
			LESP ABCD 6 bright;
			loop;
	}
}

class PBX_BuddhaGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerBuddha"; } }
class PBX_PowerBuddha : PowerBuddha
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;

	Default
	{
		Powerup.Color "00 00 128", 0.3;
	}

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("BuddhaLight","BuddhaLight");
		owner.bNOBLOOD = true;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		if(CVar.GetCVar("pb_powerup_shaders",Owner.Player).GetBool())
		{
			Shader.SetEnabled(Owner.Player,"Invulnerability",true);
			PPShader.SetUniform1f("Invulnerability","intensity",1.0);
		}
		else
		{
			Shader.SetEnabled(Owner.Player,"Invulnerability",false);
		}
		PowerupTimer("DarkOrange");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		Shader.SetEnabled(Owner.Player,"Invulnerability",false);
		EndBlend("DarkOrange");
		owner.A_RemoveLight("BuddhaLight");
		owner.bNOBLOOD = false;
	}
}

//////////////////////////// LIFESTEAL ORB ///////////////////////////////////////////////////////////////////////////////
class PBX_LifestealOrb : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "RAGEA0";
		Inventory.PickupMessage "$LFSTEALORB_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$LFSTEALORB_PICKUP";
	}

	override bool Use(bool pickup)
	{
		owner.A_SetBlend("firebrick",0.75,16);
		owner.A_GiveInventory("PBX_DrainGiver");
		return true;
	}

	States
	{
		Spawn:
			RAGE ABCDCB 6 bright;
			loop;
	}
}

class PBX_DrainGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerDrain"; } }
class PBX_PowerDrain : PowerDrain
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("DrainLight","DrainLight");
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("firebrick");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("firebrick");
		owner.A_RemoveLight("DrainLight");
	}
}

//////////////////////////// TERROR SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_TerrorSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "TERRA0";
		Inventory.PickupMessage "$TERRORSPHERE_PICKUP";
		Inventory.PickupSound "BERSPKUP";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$TERRORSPHERE_PICKUP";
	}

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_Terror_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,PBX_POWERUP_HELP_FLAG,PBX_Powerups_Tip_TerrorSphere);
		}
		owner.A_SetBlend("DarkRed",0.75,16);
		owner.A_GiveInventory("PBX_FrightenerGiver");
		if(pb_newmugshot) owner.A_SetMugshotState("BerserkGrin");
		return true;
	}

	States
	{
		Spawn:
			TERR ABCD 6 bright;
			loop;
	}
}

class PBX_FrightenerGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerFrightener"; } }
class PBX_PowerFrightener : PowerFrightener
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;

	Default
	{
		Powerup.Color "RedMap";
	}

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("FrightenerLight","FrightenerLight");
	}
	
	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("DarkRed");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("DarkRed");
		owner.A_RemoveLight("FrightenerLight");
	}
}

//////////////////////////// AMMO SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_AmmoSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "AMSPA0";
		Inventory.PickupMessage "$AMMOSPHERE_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$AMMOSPHERE_PICKUP";
	}

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_Ammo_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,PBX_POWERUP_HELP_FLAG,PBX_Powerups_Tip_AmmoSphere);
		}
		owner.A_SetBlend("yellow",0.75,16);
		owner.A_GiveInventory("PBX_InfiniteAmmoGiver");
		if(pb_newmugshot) owner.A_SetMugshotState("Grin");
		return true;
	}

	States
	{
		Spawn:
			AMSP ABCD 6 bright;
			loop;
	}
}

class PBX_InfiniteAmmoGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerInfiniteAmmo"; } }
class PBX_PowerInfiniteAmmo : PowerInfiniteAmmo
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;

	Default
	{
		Powerup.Color "255 0 0", 0.4;
	}
	
	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("InfAmmoLight","InfAmmoLight");
	}
	
	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("yellow");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("yellow");
		owner.A_RemoveLight("InfAmmoLight");
	}
}

//////////////////////////// GUARD SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_GuardSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "GARDA0";
		Inventory.PickupMessage "$GUARDSPHERE_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$GUARDSPHERE_PICKUP";
	}

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_Guard_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,PBX_POWERUP_HELP_FLAG,PBX_Powerups_Tip_GuardSphere);
		}
		owner.A_SetBlend("PaleTurquoise1",0.75,16);
		owner.A_GiveInventory("PBX_ProtectionGiver");
		return true;
	}

	States
	{
		Spawn:
			GARD ABCD 6 bright;
			loop;
	}
}

class PBX_ProtectionGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerProtection"; } }
class PBX_PowerProtection : PowerProtection
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;

	Default
	{
		Powerup.Color "GreenMap"; 
		Damagefactor "Normal", 0.25;
	}

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("ProtectLight","ProtectLight");
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("PaleTurquoise1");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("PaleTurquoise1");
		owner.A_RemoveLight("ProtectLight");
	}
}

//////////////////////////// REFLECT SPHERE (UNUSED) ///////////////////////////////////////////////////////////////////////////////
class PBX_ReflectionGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerReflection"; } }
class PBX_PowerReflection : PowerReflection
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("ReflectLight","ReflectLight");
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("DarkOrchid1");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("DarkOrchid1");
		owner.A_RemoveLight("ReflectLight");
	}
}

//////////////////////////// REGEN SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_RegenSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "REGNA0";
		Inventory.PickupMessage "$REGENSPHERE_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$REGENSPHERE_PICKUP";
	}

	override bool Use(bool pickup)
	{
		owner.A_SetBlend("Cyan",0.75,16);
		owner.A_GiveInventory("PBX_RegenerationGiver");
		return true;
	}

	States
	{
		Spawn:
			REGN ABCD 6 bright;
			loop;
	}
}

class PBX_RegenerationGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerRegeneration"; } }
class PBX_PowerRegeneration : PowerRegeneration
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("RegenLight","RegenLight");
	}
	
	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("Cyan");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("Cyan");
		owner.A_RemoveLight("RegenLight");
	}
}

//////////////////////////// TIME SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_TimeSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "TIMEA0";
		Inventory.PickupMessage "$TIMEFREEZE_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$TIMEFREEZE_TAG";
	}

	override bool Use(bool pickup)
	{
		owner.A_SetBlend("DarkOrange",0.75,16);
		owner.A_GiveInventory("PBX_TimeFreezeGiver");
		return true;
	}

	States
	{
		Spawn:
			TIME ABCD 6 bright;
			loop;
	}
}

class PBX_TimeFreezeGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerTimeFreezer"; } }
class PBX_PowerTimeFreezer : PowerTimeFreezer
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;
	Default
	{
		Powerup.Color "Goldmap";
	}

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("TimeFreezeLight","TimeFreezeLight");
	}
	
	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("Orange");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("Orange");
		owner.A_RemoveLight("TimeFreezeLight");
	}
}

//////////////////////////// FLIGHT SPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_FlightSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "FLYTA0";
		Inventory.PickupMessage "$FLIGHTSPHERE_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$FLIGHTSPHERE_PICKUP";
	}

	override bool Use(bool pickup)
	{
		owner.A_SetBlend("SteelBlue1",0.75,16);
		owner.A_GiveInventory("PBX_FlightGiver");
		return true;
	}

	States
	{
		Spawn:
			FLYT ABCD 6 bright;
			loop;
	}
}

class PBX_FlightGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerFlight"; } }
class PBX_PowerFlight : PowerFlight
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("FlightLight","FlightLight");
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("SteelBlue1");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("SteelBlue1");
		owner.A_RemoveLight("FlightLight");
	}
}

//////////////////////////// HIGH JUMP SPHERE (UNUSED) ///////////////////////////////////////////////////////////////////////////////
class PBX_HighJumpGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerHighJump"; } }
class PBX_PowerHighJump : PowerHighJump
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("HighJumpLight","HighJumpLight");
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("DeepSkyBlue1");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("DeepSkyBlue1");
		owner.A_RemoveLight("HighJumpLight");
	}
}

//////////////////////////// ADRENALINE ///////////////////////////////////////////////////////////////////////////////
class PBX_Adrenaline : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "ADRNA0";
		Inventory.PickupMessage "$ADRENAL_PICKUP";
		Inventory.PickupSound "misc/p_pkup";
		Tag "$ADRENAL_TAG";
	}

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_Adrenaline_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,PBX_POWERUP_HELP_FLAG,PBX_Powerups_Tip_Adrenaline);
		}
		owner.A_SetBlend("Red",0.75,16);
		owner.A_GiveInventory("PBX_Adrenaline_Speed");
		owner.A_GiveInventory("PBX_Adrenaline_QuadGiver");
		return true;
	}

	States
	{
		Spawn:
			ADRN A -1;
			stop;
	}
}
class PBX_Adrenaline_Speed : PB_HasteGiver {mixin PBX_Duration_Powerups;}
class PBX_Adrenaline_QuadGiver : PB_DoomGiver  {mixin PBX_Duration_Powerups;}
