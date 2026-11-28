//////////////////////////// ELECTRIC AURA ///////////////////////////////////////////////////////////////////////////////
class PBX_ElectricAuraSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "VELAA0";
		Inventory.PickupMessage "$ELECTAURA_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$ELECTAURA_PICKUP";
	}

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_ElectAura_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,PBX_POWERUP_HELP_FLAG,PBX_Powerups_Tip_ElectricAura);
		}
		owner.GiveBody(AURASPHERE_HP,AURASPHERE_MAX);
		owner.A_SetBlend("RoyalBlue1",0.75,16);
		owner.A_GiveInventory("PBX_ElectricAuraGiver");
		return true;
	}

	States
	{
        Spawn:
            VELA ABCDEFGHDEF 3 bright;
            Loop;
	}
}

class PBX_ElectricAuraGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerElectAura"; } }
class PBX_PowerElectAura : Powerup
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;
	actor AL;
	double arad;
	const AURA_RADIUS = 384;
	const ELECTRIC_DAMAGE = 15;

	Default
	{
		Powerup.Color "RoyalBlue1", 0.075;
	}

	override void InitEffect()
	{
		super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("ElectAuraLight","ElectAuraLight");
//==============================================================================
		arad = AURA_RADIUS;	//Aura Radius
//==============================================================================
		owner.A_Startsound("ElectricAura/aura",22243,CHANF_LOOPING|ATTN_NONE);
		owner.A_AttachLight(
			"ELAL1",
			DynamicLight.PulseLight,
			"FFFFFF",
			arad*0.1,
			arad*0.2,
			flags:DYNAMICLIGHT.LF_NOSHADOWMAP,
			ofs:(0,0,owner.height),
			param:2.5
		);
		owner.A_AttachLight(
			"ELAL2",
			DynamicLight.PointLight,
			"A0A0FF",
			arad,
			arad,
			flags:DYNAMICLIGHT.LF_NOSHADOWMAP,
			ofs:(0,0,owner.height)
		);

		for (int i = 0; i < 360; i += 15)
		{
			AL = spawn("PBX_ElectricAuraWarp",owner.pos);
			if (AL)
			{
				AL.target = owner;
				AL.scale.x = (arad / 360) *0.375;
				AL.scale.y = AL.scale.x/1.5;
				AL.A_SetSize(-1,owner.height/3);
				AL.reactiontime = arad;
				AL.warp(owner, arad, 0, AL.height, i, WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
				AL.A_AttachLight(
					"ELAL3",
					DynamicLight.FlickerLight,
					"FFFFFF",
					arad*0.1,
					arad*0.2,
					flags:DYNAMICLIGHT.LF_NOSHADOWMAP,
					ofs:(0,0,0),
					param:2.5
				);
			}
		}
	}

	override void Tick()
	{	
		super.Tick();
		if(!Owner) return;
//-------------------------------- shock monsters -------------------------------
		if(GetAge() % 5 != 0) return;
		array<actor> monsters;
		actor mon;
		let it = BlockThingsIterator.Create(owner, arad);
		while (it.Next())
		{
			actor mon = it.thing;
			mon.A_RemoveLight("ELATL");
			if (mon && mon is "PB_Monster" && mon.bISMONSTER && !mon.bKILLED && monsters.Find(mon) == monsters.Size() && owner.Distance3D(mon) <= arad  && owner.CheckSight(mon))
			{
				monsters.push(mon);
			}
		}

		if (monsters.Size()> 0)
		{
			int index = random(0,monsters.Size()-1);
			actor mon = monsters[index];
			if (mon && !mon.bKILLED && owner.Distance3D(mon) <= arad && owner.CheckSight(mon))
			{
				actor Electricdmg = spawn("PBX_ElectricAuraBeam",owner.pos+(0,0,owner.height/2));
				if (Electricdmg)
				{
					Electricdmg.angle = owner.AngleTo(mon);
					Electricdmg.pitch = owner.PitchTo(mon,owner.height/2,mon.height/2);
					double dist = owner.distance3D(mon);
					Electricdmg.scale.y = dist/355;
					Electricdmg.scale.x = 0.5;
					Electricdmg.DoMissileDamage(mon);
					if (mon.tics > 0) mon.tics += 4; //stun monster
//---------------------------------- Aura FX -----------------------------------
					int ht = mon.height/2;
					SparkParticle("FFFFFF", mon.pos, ht);
					SparkParticle("FFFFFF", mon.pos, ht);
					SparkParticle("FFFFFF", mon.pos, ht);
					SparkParticle("FFFFFF", mon.pos, ht);
					SparkParticle("FFFF00", mon.pos, ht);
					SparkParticle("FFFF00", mon.pos, ht);
					SparkParticle("FFFF00", mon.pos, ht);
					SparkParticle("FFFF00", mon.pos, ht);
					SparkParticle("C080FF", mon.pos, ht);
					SparkParticle("C080FF", mon.pos, ht);
					SparkParticle("C080FF", mon.pos, ht);
					SparkParticle("C080FF", mon.pos, ht);
					mon.A_AttachLight("ELATL",DynamicLight.PointLight,"E0E0FF",mon.radius,mon.radius,
						flags:DYNAMICLIGHT.LF_NOSHADOWMAP|DYNAMICLIGHT.LF_ATTENUATE,
						ofs:(0,0,mon.height/2));
					mon.A_Startsound("ElectricAura/electric");
				}
			}
		}
		ElectricAuraParticle();
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("RoyalBlue1");
	}

	override void EndEffect()
	{
		super.EndEffect();
		if(!Owner) return;
		EndBlend("RoyalBlue1");
		owner.A_RemoveLight("ElectAuraLight");
		owner.A_RemoveLight("ELAL1");
		owner.A_RemoveLight("ELAL2");
		owner.A_Stopsound(22243);
	}

	void SparkParticle(color col, vector3 mpos, double mz)
	{
		A_SpawnParticle(col,
		flags: SPF_FULLBRIGHT,
		lifetime:15,
		size:random(3,5),
		xoff:mpos.x+random(-5,5),
		yoff:mpos.y+random(-5,5),
		zoff:mz,
		velx:random(-5,5),
		vely:random(-5,5),
		velz:random(-5,5),
		startalphaf:1.0,fadestepf:-1);
	}

	void ElectricAuraParticle()
	{
		int rnd = random(1,4);
		TextureID ptx;
		if (rnd == 1) ptx = TexMan.CheckForTexture ("VSPRA0");
		else if (rnd == 2) ptx = TexMan.CheckForTexture ("VSPRB0");
		else if (rnd == 3) ptx = TexMan.CheckForTexture ("VSPRC0");
		else if (rnd == 4) ptx = TexMan.CheckForTexture ("VSPRD0");
		owner.A_SpawnParticleEx("FFFFFF",ptx,
		style: STYLE_Add,
		flags: SPF_FULLBRIGHT,
		lifetime:4,
		size:random(5,30),
		xoff:random(-arad,arad),
		yoff:random(-arad,arad),
		zoff:0,
		startalphaf:0.8,fadestepf:0);
	}
}

class PBX_ElectricAuraWarp : Actor
{
	int dist;
	Default
	{
		+WALLSPRITE;
		+NOBLOCKMAP;
		+NOINTERACTION;
		RenderStyle "Add";
		Alpha 0.8;
	}
	States
	{
	Spawn:
		TNT1 A 0 Nodelay
		{
			dist = reactiontime;
		}
		TNT1 A 0 A_Jump (256, 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33);
	Warp:
		VLGB AABBCCDDEEFFGGHHIIJJHHGGFFEEDDCCBB 2 bright 
		{
			angle += 2;
			if (!random(0,1)) bXFLIP = !bXFLIP;
			if (target) warp(target, dist, 0, height, angle, WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
			if (!target || !target.FindInventory("PBX_PowerElectAura")) destroy();
		}
		Loop;
	}
}

class PBX_ElectricAuraBeam : Actor
{
	Default
	{
		+FLATSPRITE;
		+NOBLOCKMAP;
		+NOGRAVITY;
		+BLOODLESSIMPACT;
		+FORCEPAIN;
//==============================================================================
		DamageFunction PBX_PowerElectAura.ELECTRIC_DAMAGE; //Aura Damage
//==============================================================================
		DamageType "Stun";
		RenderStyle "Add";
		Alpha 0.8;
	}
	States
	{
	Spawn:
		TNT1 A 0 Nodelay
		{
			if (!random(0,1)) bXFLIP = !bXFLIP;
			if (!random(0,1)) bYFLIP = !bYFLIP;
		}
		TNT1 A 0 A_Jump (256, 1,2,3,4,5,6,7,8,9,10);
		VLGA A 5 bright;
		Stop;
		VLGA B 5 bright;
		Stop;
		VLGA C 5 bright;
		Stop;
		VLGA D 5 bright;
		Stop;
		VLGA E 5 bright;
		Stop;
		VLGA F 5 bright;
		Stop;
		VLGA G 5 bright;
		Stop;
		VLGA H 5 bright;
		Stop;
		VLGA I 5 bright;
		Stop;
		VLGA J 5 bright;
		Stop;
	}
}

//////////////////////////// FROST AURA ///////////////////////////////////////////////////////////////////////////////
class PBX_FrostAuraSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "VFRAA0";
		Inventory.PickupMessage "$FROSTAURA_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$FROSTAURA_PICKUP";
	}

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_FrostAura_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,PBX_POWERUP_HELP_FLAG,PBX_Powerups_Tip_FrostAura);
		}
		owner.GiveBody(AURASPHERE_HP,AURASPHERE_MAX);
		owner.A_SetBlend("LightCyan",0.75,16);
		owner.A_GiveInventory("PBX_FrostAuraGiver");
		return true;
	}

	States
	{
        Spawn:
            VFRA ABCDEFGHGFEDCB 3 bright;
            Loop;
	}
}

class PBX_FrostAuraGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerFrostAura"; } }
class PBX_PowerFrostAura : Powerup
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;
	int arad;
	const FROST_DAMAGE = 15;
	const AURA_RADIUS = 448;

	Default
	{
		Powerup.Color "LightCyan", 0.075;
	}

	override void InitEffect()
	{
		super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("FrostAuraLight","FrostAuraLight");
//==============================================================================
		arad = AURA_RADIUS;	//Aura Radius
//==============================================================================
		owner.A_StartSound("FrostAura/aura", 3, CHANF_LOOPING | ATTN_NONE);
		owner.A_AttachLight(
			"FRAL1", 
			DynamicLight.PulseLight, 
			"C0C0FF", 
			arad * 1.0, 
			arad * 1.1,
			flags: DYNAMICLIGHT.LF_NOSHADOWMAP | DYNAMICLIGHT.LF_ATTENUATE,
			ofs: (0, 0, owner.height), 
			param: 1.0
		);
		owner.A_AttachLight(
			"FRAL2", 
			DynamicLight.PulseLight, 
			"4040FF", 
			arad * 0.15, 
			arad * 0.3,
			flags: DYNAMICLIGHT.LF_NOSHADOWMAP | DYNAMICLIGHT.LF_ATTENUATE,
			ofs: (0, 0, owner.height), 
			param: 2.5
		);
	}

	override void Tick()
	{
		super.Tick();

		if (!owner) return;
		if (GetAge() % 10 != 0) return;
		
		let it = BlockThingsIterator.Create(owner, arad + 128);
		while (it.Next())
		{
			actor mon = it.thing;
			if (mon && mon.bIsMonster && mon is "PB_Monster") 
				mon.speed = mon.default.speed;
			if (mon && mon.bIsMonster 
				&& mon is "PB_Monster" 
				&& owner.Distance3D(mon) <= arad 
				&& owner.CheckSight(mon)
			)
			{
				if (!mon.bKilled)
				{
					if (mon.tics > 0)
					{
						double shp = mon.spawnhealth();
						double hpcur = mon.health;
						if (hpcur < 1)
							hpcur = 1;
						int hpfactor = int(shp / hpcur * 3);
						hpfactor = clamp(hpfactor, 2, 5);
						mon.tics  += hpfactor;
						mon.speed -= hpfactor;
					}
					actor frostdmg = Spawn("FrostAuraFreeze", mon.pos);
					if (frostdmg)
					{
						int stxW = 0, stxH = 0;
						TextureID stx;
						if (mon.CurState != null)
						{
							stx = mon.CurState.GetSpriteTexture(0);
							if (stx.IsValid()) [stxW, stxH] = TexMan.GetSize(stx);
						}
						frostdmg.target = owner;
						if (stxW > 0 && stxH > 0)
						{
							frostdmg.A_SetSize(stxW / 3 * mon.scale.x, stxH / 1.2 * mon.scale.y);
						}
						frostdmg.DoMissileDamage(mon);
					}
				}
				if (mon.bKilled && !mon.bICECORPSE && !mon.bNOICEDEATH && GetAge() % 20 == 0)
					mon.SetStateLabel("GenericFreezeDeath");
				if (mon.bICECORPSE)
				{
					actor frozen = Spawn("FrostAuraFrozen", mon.pos);
					if (frozen) frozen.A_SetSize(mon.radius, mon.height);
				}
			}
		}

		static const String smokeColors[] = {"FFFFFF", "F0F0EF", "E0E0DF", "D0D0CF", "C0C0BF"};
		for (int i = 0; i < smokeColors.Size(); i++)
		{
			owner.A_SpawnParticle(
				smokeColors[i], 
				lifetime: 280, 
				size: random(1, 3),
				xoff: random(-arad, arad), 
				yoff: random(-arad, arad), 
				zoff: 128,
				velx: frandom(-0.3, 0.3), 
				vely: frandom(-0.3, 0.3), 
				velz: frandom(-4.0, -2.0),
				startalphaf: 0.5
			);
		}
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("LightCyan");
	}

	override void EndEffect()
	{
		super.EndEffect();
		if(!Owner) return;
		EndBlend("LightCyan");
		owner.A_RemoveLight("FrostAuraLight");
		owner.A_RemoveLight("FRAL1");
		owner.A_RemoveLight("FRAL2");
		owner.A_StopSound(3);
		let it = BlockThingsIterator.Create(owner, arad);
		while (it.Next())
		{
			actor mon = it.thing;
			if (mon && mon.bIsMonster && mon is "PB_Monster") 
				mon.speed = mon.default.speed;
		}
	}
}

class FrostAuraFreeze : Actor
{
	Default
	{
		+NOBLOCKMAP;
		+NOGRAVITY;
		+PAINLESS;
		+BLOODLESSIMPACT;
		DamageFunction PBX_PowerFrostAura.FROST_DAMAGE;
		DamageType "Ice";
	}

	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 AAAAAAAAAA 1
			{
				A_SpawnParticle("BFBFFF",
					lifetime: 70,
					size: random(3, 6),
					xoff: random(int(-radius), int(radius)),
					yoff: random(int(-radius), int(radius)),
					zoff: random(int(height / 4), int(height)),
					velx: frandom(-1.0, 1.0),
					vely: frandom(-1.0, 1.0),
					velz: frandom(-1.0, 1.0),
					startalphaf: 0.3, fadestepf: -1, sizestep: 0.4
				);
			}
			Stop;
	}
}

class FrostAuraFrozen : Actor
{
	Default
	{
		+NOBLOCKMAP;
		+NOINTERACTION;
	}

	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 AAAAAAAAAAA 1{
				A_SpawnParticle("BFBFFF",
					lifetime: 70,
					size: random(6, 12),
					xoff: random(int(-radius), int(radius)),
					yoff: random(int(-radius), int(radius)),
					zoff: random(int(height / 4), int(height)),
					velx: frandom(-1.1, 1.1),
					vely: frandom(-1.1, 1.1),
					velz: frandom(-1.1, 1.1),
					startalphaf: 0.3, fadestepf: -1, sizestep: 0.5
				);
			}
			Stop;
	}
}

//////////////////////////// FIRE AURA ///////////////////////////////////////////////////////////////////////////////
class PBX_FireAuraSphere : PB_Inventory
{
	Default
	{
		Inventory.AltHudIcon "VFIAA0";
		Inventory.PickupMessage "$FIREAURA_PICKUP";
		Inventory.PickupSound "MEGASPH";
		+FLOATBOB
		floatbobstrength .4;
		Tag "$FIREAURA_PICKUP";
	}

	override bool Use(bool pickup)
	{
		if(PBX_SEND_TIP)
		{
			Array<String> tips;
			tips.Push("$PBX_FireAura_Tip1");
			PBX_Handler.SendTipArrayIfNeeded(tips,PBX_POWERUP_HELP_FLAG,PBX_Powerups_Tip_FireAura);
		}
		owner.GiveBody(AURASPHERE_HP,AURASPHERE_MAX);
		owner.A_SetBlend("firebrick4",0.75,16);
		owner.A_GiveInventory("PBX_FireAuraGiver");
		return true;
	}

	States
	{
        Spawn:
            VFIA ABCDEFGH 5 bright;
            Loop;
	}
}

class PBX_FireAuraGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerFireAura"; } }
class PBX_PowerFireAura : Powerup
{
	mixin PBX_PowerupTimer;
	mixin PBX_Duration_Powerups;
	int arad;
	const FIRE_DAMAGE = 15;
	const AURA_RADIUS = 160;

	Default
	{
		Powerup.Color "firebrick4", 0.075;
	}

	override void InitEffect()
	{
		super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("FireAuraLight","FireAuraLight");
//==============================================================================
		arad = AURA_RADIUS; //Aura Radius
//==============================================================================
		owner.A_StartSound("FireAura/aura", 2, CHANF_LOOPING | ATTN_NONE);
		owner.A_AttachLight(
			"FIAL1", 
			DynamicLight.FlickerLight, 
			"FF8000", 
			arad * 1.0, 
			arad * 1.05,
			flags: DYNAMICLIGHT.LF_NOSHADOWMAP,
			ofs: (0, 0, owner.height / 2), 
			param: 0.5
		);
		owner.A_AttachLight(
			"FIAL2", 
			DynamicLight.PulseLight, 
			"FFE000", 
			arad * 1.0, 
			arad * 1.05,
			flags: DYNAMICLIGHT.LF_NOSHADOWMAP | DYNAMICLIGHT.LF_ATTENUATE,
			ofs: (0, 0, owner.height / 2), 
			param: 0.5
		);
		owner.A_AttachLight(
			"FIAL3", 
			DynamicLight.PulseLight, 
			"FFFFFF", 
			arad * 0.1, 
			arad * 0.4,
			flags: DYNAMICLIGHT.LF_NOSHADOWMAP | DYNAMICLIGHT.LF_ATTENUATE,
			ofs: (0, 0, owner.height / 2), 
			param: 2.5
		);
	}

	override void Tick()
	{
		super.Tick();

		if (!owner) return;
		if (GetAge() % 5 != 0) return;

		array<actor> monsters;
		let it = BlockThingsIterator.Create(owner, arad);
		while (it.Next())
		{
			actor mon = it.thing;
			if (mon) 
				mon.A_RemoveLight("FIATL");
			if (mon && mon.bIsMonster && mon is "PB_Monster" 
				&& !mon.bKilled && monsters.Find(mon) == monsters.Size()
				&& owner.Distance3D(mon) <= arad 
				&& owner.CheckSight(mon)
			)
			{
				monsters.Push(mon);
			}
		}

		if (monsters.Size() > 0)
		{
			int index = random(0, monsters.Size() - 1);
			actor mon = monsters[index];
			if (mon && !mon.bKilled && owner.Distance3D(mon) <= arad && owner.CheckSight(mon))
			{
				int ht = int(mon.height / 2);
				for (int i = 0; i < 4; i++) SparkParticle("FFFFFF", mon.pos, ht);
				for (int i = 0; i < 4; i++) SparkParticle("FFE060", mon.pos, ht);
				for (int i = 0; i < 4; i++) SparkParticle("FF8040", mon.pos, ht);

				mon.A_AttachLight(
					"FIATL", 
					DynamicLight.PointLight, 
					"FFB060", 
					mon.radius, 
					mon.radius,
					flags: DYNAMICLIGHT.LF_NOSHADOWMAP | DYNAMICLIGHT.LF_ATTENUATE,
					ofs: (0, 0, mon.height / 2)
				);

				mon.A_StartSound("FireAura/fire");

				if (mon.tics > 0) mon.tics += 4;

				if (mon.health > 6)
				{
					actor firedmg = Spawn("FlamethrowerMissileNew", mon.pos);
					if (firedmg)
					{
						firedmg.target = owner;
						firedmg.scale.x = 0.8 + (mon.radius * 0.005 * mon.scale.x);
						firedmg.scale.y = 0.4 + (mon.height * 0.0075 * mon.scale.y);
						firedmg.DoMissileDamage(mon);
					}
				}
			}
		}
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("firebrick4");
	}

	override void EndEffect()
	{
		super.EndEffect();
		if (!owner) return;
		EndBlend("firebrick4");
		owner.A_RemoveLight("FireAuraLight");
		owner.A_RemoveLight("FIAL1");
		owner.A_RemoveLight("FIAL2");
		owner.A_RemoveLight("FIAL3");
		owner.A_StopSound(2);
	}

	void SparkParticle(color col, vector3 mpos, double mz)
	{
		A_SpawnParticle(col,
			flags: SPF_FULLBRIGHT,
			lifetime: 15,
			size: random(3, 5),
			xoff: mpos.x + random(-5, 5),
			yoff: mpos.y + random(-5, 5),
			zoff: mz,
			velx: random(-5, 5),
			vely: random(-5, 5),
			velz: random(-5, 5),
			startalphaf: 1.0, fadestepf: -1
		);
	}
}

