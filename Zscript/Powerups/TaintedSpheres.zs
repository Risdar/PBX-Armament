//////////////////////////// BLACK BLURSPHERE ///////////////////////////////////////////////////////////////////////////////
Class PBX_BlackBlur : PB_Inventory
{
	Default
	{
        //$Category Powerups/Tainted
        //%Tag Tainted Invisibility Sphere
        RenderStyle "Translucent";
		Inventory.AltHudIcon "TVISA0";
        Inventory.PickupMessage "$BLACKBLUR_PICKUP";
		Inventory.PickupSound "INVISIBL";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$BLACKBLUR_TAG";
	}
	
    override bool Use(bool pickup)
	{
		owner.A_SetBlend("DarkSlateBlue",0.75,16);
		owner.A_GiveInventory("PBX_InvisTaintedGiver");
		return true;
	}

	action void VisCheck()
    {
		BlockThingsIterator it = BlockThingsIterator.Create(self, 512);
		while(it.Next())
		{
			let obj = it.thing;
						
			if(obj && obj.bISMONSTER && obj.health > 0 && Distance3D(obj) <= 256 && !obj.bSTEALTH)
			{
				obj.bSTEALTH = TRUE;
				if(PBX_SEND_TIP)
				{
					Array<String> tips;
					tips.Push("$PBX_BlackBlur_Tip1");
					PBX_Handler.SendTipArrayIfNeeded(tips,POWERUPS_HELPTEXT,PBX_Powerups_Tip_BlackBlur);
				}
			}
			else if(obj && obj.bISMONSTER && obj.health > 0 && Distance3D(obj) > 256 && obj.bSTEALTH)
			{
				obj.bSTEALTH = FALSE;
				obj.Alpha = 1.0;
			}
		}
    }
	
	override void Tick()
	{
		super.Tick();
		
		double a = frandom[sfx](1, 360);
		double b = (frandom[sfx](-40, 40) + frandom[sfx](-40, 40));
		
		A_SpawnParticleEx(
			"0000AA",
			TexMan.CheckForTexture("FLAKA0"),
			style: STYLE_Add,
			flags: SPF_FULLBRIGHT,
			lifetime: 35,
			size: 8.0,
			angle: a,
			xoff: cos(a) * cos(b) * 40,
			yoff: sin(a) * cos(b) * 40,
			zoff: sin(b) * 40 + 26,
			velx: -cos(a) * cos(b) * 0.6,
			vely: -sin(a) * cos(b) * 0.6,
			velz: -sin(b) * 0.6,
			startalphaf: 1.0,
			fadestepf: -0.05,
			sizestep: -0.2,
			startroll: 0
		);
	}
	
	override bool CanPickup(Actor toucher)
	{
		if(toucher)
		{
			BlockThingsIterator it = BlockThingsIterator.Create(self, 512);
			while(it.Next())
			{
				let obj = it.thing;
						
				if(obj && obj.bISMONSTER && obj.bSTEALTH)
				{
					obj.bSTEALTH = FALSE;
					obj.Alpha = 1.0;
				}
			}
		}
		
		super.CanPickup(toucher);
		return TRUE;
	}

    States
	{
		Spawn:
			TVIS ABCD 6 Bright VisCheck();
			Loop;
	}
}

class PBX_InvisTaintedGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerInvisTainted"; } }
Class PBX_PowerInvisTainted : PB_PowerInvis
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;
	Default
	{
		+SHADOW;
		+REFLECTIVE;
		Powerup.Strength 100;
		Powerup.Mode "Translucent";
	}
	
	override void InitEffect()
	{
		super.InitEffect();
		if(!Owner) return;
		owner.bCANTSEEK = TRUE;	
		owner.A_AttachLightDef("InvisTaintedLight","InvisTaintedLight");
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("DarkSlateBlue");
	}
	
	override void EndEffect()
	{
		super.EndEffect();
		if(!Owner) return;
		owner.bCANTSEEK = FALSE;
		EndBlend("DarkSlateBlue");
		owner.A_RemoveLight("InvisTaintedLight");
	}
}

//////////////////////////// GOLD INVULNERABILITY ///////////////////////////////////////////////////////////////////////////////
class PBX_GoldInvul : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "TINVA0";
		Inventory.PickupMessage "$GOLDINV_PICKUP";
		Inventory.PickupSound "INVUL";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$GOLDINV_TAG";
	}
	
	double n;

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_GoldInvul_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,POWERUPS_HELPTEXT,PBX_Powerups_Tip_GoldInvul);
		}
		owner.A_SetBlend("PaleGoldenrod",0.75,16);
		owner.A_GiveInventory("PBX_InvulTaintedGiver");
		if(pb_newmugshot) owner.A_SetMugshotState("Grin");
		return true;
	}

    action void InvCheck()
    {
		BlockThingsIterator it = BlockThingsIterator.Create(self, 512);	
		while(it.Next())
		{
			let obj = it.thing;
						
			if(obj && obj.bISMONSTER && obj.health > 0 && Distance3D(obj) <= 256 && !obj.bINVULNERABLE)
			{
				obj.bINVULNERABLE = TRUE;
			}
			else if(obj && obj.bISMONSTER && obj.health > 0 && Distance3D(obj) > 256 && obj.bINVULNERABLE)
			{
				obj.bINVULNERABLE = FALSE;
			}
		}
    }
	
	override bool CanPickup(Actor toucher)
	{
		if(toucher)
		{
			BlockThingsIterator it = BlockThingsIterator.Create(self, 512);
			while(it.Next())
			{
				let obj = it.thing;
						
				if(obj && obj.bISMONSTER && obj.bINVULNERABLE)
				{
					obj.bINVULNERABLE = FALSE;
				}
			}
		}
		
		super.CanPickup(toucher);
		return TRUE;
	}
		
	override void Tick()
	{
		super.Tick();
		if(n > 359)
			n = 0;
			
		double a = n;
		double b = (frandom[sfx](-20, 20) + frandom[sfx](-20, 20));
	
		A_SpawnParticleEx(
			"00AA00",
			TexMan.CheckForTexture ("BFE1E0"),
			style: STYLE_Add,
			flags: SPF_FULLBRIGHT,
			lifetime: 105,
			size: 2.0,
			angle: n,
			xoff: cos(a) * cos(b) * 20,
			yoff: sin(a) * cos(b) * 20,
			zoff: 26,
			startalphaf: 1.0,
			fadestepf: -0.03,
			sizestep: -0.05,
			startroll: 0
		);
			
		n = n + 4;
		
		BlockThingsIterator it = BlockThingsIterator.Create(self, 256);
		
		while(it.Next())
		{
			let obj = it.thing;
			if(obj && obj.bISMONSTER && Distance3D(obj) <= 256 && !obj.bCORPSE)
			{
				obj.A_SpawnParticleEx(
                    "00AA00",
                    TexMan.CheckForTexture ("BFE1E0"),
                    style: STYLE_Add,
                    flags: SPF_FULLBRIGHT,
                    lifetime: 105,
                    size: 3.0,
                    angle: n,
                    xoff: cos(a) * cos(frandom[sfx](-obj.radius, obj.radius) + frandom[sfx](-obj.radius, obj.radius)) * obj.radius,
                    yoff: sin(a) * cos(frandom[sfx](-obj.radius, obj.radius) + frandom[sfx](-obj.radius, obj.radius)) * obj.radius,
                    zoff: obj.height / 2,
                    startalphaf: 1.0,
                    fadestepf: -0.03,
                    sizestep: -0.05,
                    startroll: 0
				);
			}
		}
	}

	States
	{
        Spawn:
            TINV ABCD 6 Bright InvCheck();
		    Loop;
	}
}

class PBX_InvulTaintedGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerInvulTainted"; } }
Class PBX_PowerInvulTainted : PowerInvulnerable
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;
	
	Default
	{
		Powerup.Color "GoldMap";
	}

	override void InitEffect()
	{
		super.InitEffect();
		if(!Owner) return;
		owner.bREFLECTIVE = TRUE;
		owner.bAIMREFLECT = TRUE;
		owner.bNOBLOOD = true;
		owner.A_AttachLightDef("InvulTaintedLight","InvulTaintedLight");
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
		PowerupTimer("PaleGoldenrod");
	}
	
	override void EndEffect()
	{
		super.EndEffect();
		if(!Owner) return;
		owner.bREFLECTIVE = FALSE;
		owner.bAIMREFLECT = FALSE;
		owner.bNOBLOOD = false;
		Shader.SetEnabled(Owner.Player,"Invulnerability",false);
		EndBlend("PaleGoldenrod");	
		owner.A_RemoveLight("InvulTaintedLight");
	}
}

//////////////////////////// RED SOULSPHERE ///////////////////////////////////////////////////////////////////////////////
Class CorpseDrained : Inventory {Default{Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE;}}
class PBX_RedSoulSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "TSOUA0";
		Inventory.PickupMessage "$REDSOUL_PICKUP";
		Inventory.PickupSound "SSPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$REDSOUL_TAG";
	}

	int damageTimer, corpseTimer;
	int ownHP;

	override bool Use(bool pickup)
	{
		owner.A_SetBlend("Red",0.75,16);
		ownHP = clamp(200 - owner.health, 0, 200);
		owner.GiveBody(REDSOUL_HP,REDSOUL_MAX);
		if(pb_newmugshot) owner.A_SetMugshotState("SoulsphereGrin");
		return true;
	}
	
	override string PickupMessage()
	{
		string msg = string.format(StringTable.Localize(Super.PickupMessage()), ownHP);
		return msg;
	}

    override void Tick()
    {
		super.Tick();

		if(level.isFrozen()) return;

		damageTimer++;
        corpseTimer++;

        if(GetAge() % Random(17, 28) == 0)
            SpawnParticle();

        if(damageTimer >= 35)
        {
            damageTimer = 0;
            DamageNearbyPlayers();
        }

        if(corpseTimer >= 175)
        {
            corpseTimer = 0;
            SpawnSoulsFromCorpses();
        }
		
    }

	void SpawnParticle()
	{
		A_SpawnParticleEx(
            "FF0000",
            TexMan.CheckForTexture("DROPA0"),
            style: STYLE_Add,
            flags: SPF_FULLBRIGHT|SPF_RELATIVE,
            lifetime: 15,
            size: 2.0,
            angle: 0,
            xoff: frandom[sfx](-3, 3),
            yoff: frandom[sfx](-3, 3),
            zoff: 15,
            velz: -0.01,
            accelz: -0.4,
            startalphaf: 1.0,
            fadestepf: -0.2,
            sizestep: 0,
            startroll: 0
        );
	}

	void DamageNearbyPlayers()
    {
        BlockThingsIterator it = BlockThingsIterator.Create(self, 256);
        while(it.Next())
        {
            let obj = it.thing;
            if(obj.player && obj.health > 0 && Distance3D(obj) <= 256)
			{
				if(PBX_SEND_TIP)
				{
					Array<String> tips;
					tips.Push("$PBX_RedSoul_Tip1");
					tips.Push("$PBX_RedSoul_Tip2");
					PBX_Handler.SendTipArrayIfNeeded(tips,POWERUPS_HELPTEXT,PBX_Powerups_Tip_RedSoul);
				}
                obj.DamageMobj(self, self, 1, "");
			}
        }
    }

	void SpawnSoulsFromCorpses()
    {
        BlockThingsIterator it = BlockThingsIterator.Create(self, 256);
        while(it.Next())
        {
            let obj = it.thing;
            if((obj is "PB_CurbstompedMarine")
                // && obj.bISMONSTER
                // && obj.health <= 0
                && obj.GetClassName() != "PB_LostSoul"
                && obj.GetClassName() != "PB_PainElemental"
                && Distance3D(obj) <= 256
                && !obj.CheckInventory("CorpseDrained", 1))
            {
                obj.Spawn("PB_LostSoul", obj.Vec3Offset(0, 0, 20), NO_REPLACE);
                obj.Spawn("TeleportFog", obj.Vec3Offset(0, 0, 20), NO_REPLACE);
                obj.GiveInventory("CorpseDrained", 1);
                obj.A_SetRenderStyle(0.4, STYLE_Translucent);
            }
        }
	}

	States
	{
		Spawn:
			TSOU ABCDCB 6 bright;
			loop;
	}
}

//////////////////////////// DARK MEGASPHERE ///////////////////////////////////////////////////////////////////////////////
class PBX_DarkMegaSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "TMEGA0";
		Inventory.PickupMessage "$DARKMEGA_PICKUP";
		Inventory.PickupSound "MEGASPH";
	    +VISIBILITYPULSE;
		+FLOATBOB
		floatbobstrength .4;
		Tag "$DARKMEGA_TAG";
	}

	int ownHP, ownAP;

	override bool Use(bool pickup)
	{
		owner.A_SetBlend("DarkOrange",0.75,16);
		ownHP = clamp(200 - owner.health, 0, 200);
		ownAP = clamp(200 - owner.CountInv("BasicArmor"), 0, 200);
		owner.GiveBody(DARKMEGA_HP,DARKMEGA_MAX);
		owner.A_GiveInventory("PBX_UltraArmor");
		owner.A_GiveInventory("PBX_TaintedRegenGiver");
		if(pb_newmugshot) owner.A_SetMugshotState("MegasphereGrin");
		return true;
	}
	
	override string PickupMessage()
	{
		string msg = string.format(StringTable.Localize(Super.PickupMessage()), ownHP, ownAP);
		return msg;
	}

    override void Tick()
	{
		super.Tick();
		
		double a = frandom[sfx](1, 360);
		double b = (frandom[sfx](-20, 20) + frandom[sfx](-20, 20));

		A_SpawnParticleEx(
			"BB0055",
			TexMan.CheckForTexture ("STARA0"),
			style: STYLE_Add,
			flags: SPF_FULLBRIGHT,
			lifetime: 35,
			size: 3.0,
			angle: a,
			xoff: cos(a) * cos(b) * 20,
			yoff: sin(a) * cos(b) * 20,
			zoff: sin(b) * 20 + 26,
			velx: cos(a) * cos(b) * 0.2,
			vely: sin(a) * cos(b) * 0.2,
			velz: sin(b) * 0.2,
			startalphaf: 1.0,
			fadestepf: -0.1,
			sizestep: -0.1,
			startroll: 0
		);
		
		BlockThingsIterator it = BlockThingsIterator.Create(self, 256);
		
		while(it.Next())
		{
			let obj = it.thing;
			if(obj && obj.bISMONSTER && Distance3D(obj) <= 256 && !obj.bCORPSE && obj.health < obj.SpawnHealth())
			{
				obj.A_SpawnParticleEx(
					"BB0055",
					TexMan.CheckForTexture ("STARA0"),
					style: STYLE_Add,
					flags: SPF_FULLBRIGHT|SPF_RELATIVE|SPF_ROLL,
					lifetime: 50,
					size: 0.5,
					angle: 0,
					xoff: frandom[sfx](obj.radius,-obj.radius),
					yoff: frandom[sfx](obj.radius,-obj.radius),
					zoff: 0,
					velx: frandom[sfx](0.5,-0.5),
					vely: frandom[sfx](0.5,-0.5),
					velz: frandom[sfx](0.4,3.0),
					accelz: -0.001,
					startalphaf: 1.25,
					fadestepf: -0.002,
					sizestep: 0.15,
					startroll: 180/2,
					rollvel: 0,
					rollacc: 0
				);
				obj.health++;
				if(PBX_SEND_TIP)
				{
					Array<String> tips;
					tips.Push("$PBX_DarkMega_Tip1");
					PBX_Handler.SendTipArrayIfNeeded(tips,POWERUPS_HELPTEXT,PBX_Powerups_Tip_DarkMega);
				}
			}
		}
	}

	States
	{
		Spawn:
			TMEG ABCDCB 6 bright;
			loop;
	}
}

class PBX_TaintedRegenGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerTaintedRegen"; } }
class PBX_PowerTaintedRegen : Powerup
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;
	// Default { Powerup.Color "Cyan";}

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("RegenTnLight","RegenTnLight");
	}
	
	override void DoEffect()
	{
		Super.DoEffect();
		if(owner && owner.health < 200 && GetAge() % 3 == 0)
			owner.GiveBody(1,200);
		PowerupTimer("MediumPurple");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("MediumPurple");
		owner.A_RemoveLight("RegenTnLight");
	}
}