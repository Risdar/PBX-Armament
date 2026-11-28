// Shoulder Cannon
// From GloryKill addon for Project Brutality
// GloryKillMechanics - BrutalDoom Black Edition's Team
// Pinata pickup sound - BrutalDoom Black Edition's Team
// Glory Kill Shader - D4D Teams
// Crucible sprite , Sound, FlameBelch sound - D4D Teams, EOA Teams
// Crucible trail - Embers Of Armageddon
// Pinata, Ammo Sprites - D4D Teams, LJG2023
// BloodPunch Effect - EOA Teams
// Low Health Sound - D4D Teams
// Item Collecting Mechanics - D4D Teams
// CYBERDEMON FATALITY - SgtMarkIV (BrutalDoom)
// MATSTERMIND FATALITY - SgtMarkIV (BrutalDoom)
// Flamethrower Crucible Mod - a90doomguy , Tunasz & Officer_D
// Hud Graphic Soucce - EOA Teams
// Old PB Addon Maintainer - Headshot_Ev
// New PB Addon Maintainer - thedoctorofdoom,RENEGADE_ANDROiD,beefrice

class PBX_ShoulderCannon : CustomInventory
{
	Default
	{
		Inventory.AltHudIcon "SCFMA0";
		Inventory.PickupMessage "$SHOULDCANNON_PICKUP";
		Inventory.PickupSound "7LSPICK";
		Tag "$SHOULDCANNON_TAG";
		+INVENTORY.AUTOACTIVATE;
	}

	// Overlay Layers
	const FLAMEBELCH_LAYER = 51;
	const ICEBOMB_LAYER    = 69;
	const OVERLAY_LAYER    = 871;

	// Default Cooldowns (in seconds)
	const FLAME_DEFAULT_COOLDOWN = 12;
	const ICE_DEFAULT_COOLDOWN   = 35;

	// Ammo Takes
	const FUEL_AMMO       	= "PB_Fuel";
	const ROCKET_AMMO     	= "PB_RocketAmmo";

	// How much ammo given upon pick up
	const FUEL_AMMO_GIVE 	= 100;
	const ROCKET_AMMO_GIVE 	= 15;

	enum EEquipType
	{
		EQUIP_NONE = -1,
		EQUIP_FLAMEBELCH,
		EQUIP_ICEBOMB,
		EQUIP_COUNT // How many equipments are there
	}

	static const String EquipReadySound[]  = {"Equip_flameready",   "Equip_Iceready"};
	static const int    EquipDefaultCool[] = {FLAME_DEFAULT_COOLDOWN, ICE_DEFAULT_COOLDOWN};

	bool isReady[EQUIP_COUNT];
	int  coolTic[EQUIP_COUNT];
	int  pendingSlot;

	override void AttachToOwner(Actor other)
	{
		if (other == null || other.player == null) 
        {
            return;
        }

		for (int i = 0; i < EQUIP_COUNT; i++)
        {
            isReady[i] = true; // Sets Every Type to Ready
        }

		pendingSlot = EQUIP_NONE;
		other.A_GiveInventory(FUEL_AMMO, FUEL_AMMO_GIVE);
		other.A_GiveInventory(ROCKET_AMMO, ROCKET_AMMO_GIVE);
		super.AttachToOwner(other);
	}

	override void DoEffect()
	{
		super.DoEffect();

		if (owner == null || owner.player == null) 
        {
            return;
        }

		// Update every seconds (35 tics)
		if (level.time % TICRATE == 0)
        {
            UpdateEquipCooldowns();
        }
	}

	override bool TryPickup(in out Actor toucher)
    {
        bool pickup = Super.TryPickup(toucher);
        if (pickup)
        {
			if(PBX_SEND_TIP)
			{
				Array<String> tips;
				tips.Push(string.format(
						StringTable.Localize("$PBX_ShouldCan_Tip1"),
						PB_HelpNotificationsHandler.PB_FormatKeybinds("pbx_doflame"), 
						PB_HelpNotificationsHandler.PB_FormatKeybinds("pbx_doice")
					)
				);
				PBX_Handler.SendTipArrayIfNeeded(tips,ITEMS_HELPTEXT,PBX_Armory_Tip_ShoulderCannon);
			}
        }
        return pickup;
    }

	// Called externally to queue a fire request.
	void RequestFire(int slot)
	{
		if (slot < 0 || slot >= EQUIP_COUNT) return;
		pendingSlot = slot;
	}

	private 
	void UpdateEquipCooldowns()
	{
		// For every equipment
		for (int i = 0; i < EQUIP_COUNT; i++)
		{
			// Skip if its ready to use
			if (isReady[i]) continue;

			// Get the cooldown
			int coolMax = GetEquipCooldown(i);
			coolTic[i]++; // count towards it

			// If it has reached the max cooldown, play a sound and set it to ready
			if (coolTic[i] >= coolMax)
			{
				coolTic[i] = 0;
				isReady[i] = true;
				owner.A_StartSound(EquipReadySound[i], CHAN_AUTO, CHANF_LOCAL, 1.0, ATTN_NONE);
			}
		}
	}

	// Action Functions
	private
	action state initShoulderCannon()
	{
		// console.printf("use state called");
		let ownr = PB_PlayerPrawn(invoker.owner);
		let revLauncherActive = ownr.player.FindPSprite(-90);
		if (ownr && !revLauncherActive)
		{
			// console.printf("player found, starting overlay");
			return ResolveState("Startoverlay");
		}
		return ResolveState(null);
	}

	private
	action state checkShoulderCannon()
	{
		// console.printf("checking");
		let revLauncherActive = invoker.owner.player.FindPSprite(-90);
		if (invoker.pendingSlot != EQUIP_NONE && !revLauncherActive)
			return handleFireLogic();
		return ResolveState(null);
	}

	private 
	action state handleFireLogic()
	{
		int slot = invoker.pendingSlot;
		invoker.pendingSlot = EQUIP_NONE;

		bool useELAmmo = PBX_SC_UseAmmo;
		int mFlameBelchAmmoUse = PBX_SC_FlameBelchAmmoUse;
		int mIceBombAmmoUse = PBX_SC_IceBombAmmoUse;

		if (slot == EQUIP_FLAMEBELCH)
		{
			bool notEnoughAmmo = CountInv(FUEL_AMMO) < mFlameBelchAmmoUse;
			if ((useELAmmo && notEnoughAmmo) || !invoker.isReady[EQUIP_FLAMEBELCH])
			{
				A_Print(notEnoughAmmo ? "$SHOULDCANNON_NOFUEL" : "$SHOULDCAN_FLAMNOTREADY");
				A_StartSound("Equip_notready",CHAN_AUTO,CHANF_OVERLAP);
				return ResolveState("CheckForAction");
			}

			invoker.isReady[EQUIP_FLAMEBELCH] = false;
			if (useELAmmo) TakeInventory(FUEL_AMMO, mFlameBelchAmmoUse);
			A_Overlay(FLAMEBELCH_LAYER, "FireFlameBelch");
			return ResolveState("CheckForAction");
		}
		if (slot == EQUIP_ICEBOMB)
		{
			bool notEnoughAmmo = CountInv(ROCKET_AMMO) < mIceBombAmmoUse;
			if ((useELAmmo && notEnoughAmmo) || !invoker.isReady[EQUIP_ICEBOMB])
			{
				A_Print(notEnoughAmmo ? "$SHOULDCANNON_NOROCKET" : "$SHOULDCAN_ICENOTREADY");
				A_StartSound("Equip_notready",CHAN_AUTO,CHANF_OVERLAP);
				return ResolveState("CheckForAction");
			}

			invoker.isReady[EQUIP_ICEBOMB] = false;
			if (useELAmmo) TakeInventory(ROCKET_AMMO, mIceBombAmmoUse);
			A_Overlay(ICEBOMB_LAYER, "FireIceBomb");
			A_OverlayFlags(ICEBOMB_LAYER, PSPF_FLIP|PSPF_MIRROR, true); // flip the layer so its on the right side
			return ResolveState("CheckForAction");
		}
		return ResolveState(null);
	}

	clearscope int GetEquipCooldown(int slot) const
	{
		if (slot < 0 || slot >= EQUIP_COUNT) return 0;
		return EquipDefaultCool[slot];
	}

	clearscope bool IsEquipReady(int slot) const
	{
		if (slot < 0 || slot >= EQUIP_COUNT) return false;
		return isReady[slot];
	}

	clearscope double GetCooldownFraction(int slot) const
	{
		if (slot < 0 || slot >= EQUIP_COUNT || isReady[slot]) return 1.0;
		int coolMax = GetEquipCooldown(slot);
		return coolMax > 0 ? double(coolTic[slot]) / coolMax : 1.0;
	}

	States
	{
		Spawn:
			SCFM A -1;
			loop;

		Use:
			TNT1 A 0 initShoulderCannon();
		Remove:
			stop;

		Startoverlay:
			TNT1 A 0 A_Overlay(OVERLAY_LAYER, "CheckForAction");
			wait;

		// This layer should never be destroyed
		CheckForAction:
			TNT1 A 1 checkShoulderCannon();
			Loop;

		FireFlameBelch:
			SCL0 ABCD 1 A_StartSound("Equip_Activate", CHAN_ITEM);
			SCL0 EFGHIJ 1;
			SCL0 K 1 A_Quake(8, 8, 0, 32);
			TNT1 A 0 A_Recoil(4);
			SCF0 A 3 bright A_GunFlash();
			TNT1 A 0 A_AlertMonsters();
		ActualFireFlameBelch:
			TNT1 A 0 A_StartSound("Flamebelch", CHAN_ITEM);
			SCF0 BCDBCDBCD 1 bright {
				if(pb_performance_fire)
					A_FireProjectile("PBX_FireMissile", -3, 0, Random(-25, -20), 12, FPF_NOAUTOAIM, 0);
				else
					A_FireProjectile("PBX_FireMissileSimple", -3, 0, Random(-25, -20), 12, FPF_NOAUTOAIM, 0);
			}
			SCF0 EF 1;
			SCL0 KJIHGFEDCBA 1;
			Stop;

		FireIceBomb:
			SCL0 ABCD 1 A_StartSound("Equip_Activate", CHAN_ITEM);
			SCL0 EFGHIJ 1;
			SCL0 K 1 A_Quake(8, 8, 0, 32);
			TNT1 A 0 A_Recoil(4);
			SCF0 A 3 bright A_GunFlash();
			TNT1 A 0 A_AlertMonsters();
		ActualFireIceBomb:
			SCF0 BC 1 bright;
			SCF0 D 1 bright {
				A_StartSound("weapons/firegrenade", CHAN_ITEM);
				A_FireProjectile("PBX_CryoGrenade", 1, 0, Random(22, 18), 12, FPF_NOAUTOAIM, 0);
			}
			SCF0 EF 1;
			SCL0 KJIHGFEDCBA 1;
			Stop;
	}
}

class PBX_CryoGrenade : PB_FragGrenade
{
    Default
    {
        +NODAMAGETHRUST
        +FORCEXYBILLBOARD
        +FORCERADIUSDMG
        +BLOODLESSIMPACT
        Damage 0;
        DamageType "Freeze";
        RenderStyle "Add";
        Alpha 0.95;
        BounceFactor 0.15;
        DeathSound "weapons/CryoRifle/freezeobject";
        Decal "FreezerBurn";
    }
    
	States
	{
        Spawn:
            TNT1 A 0 {
                If(WaterLevel > 1) 
                    A_SpawnItem ("CryoRifleTrailSparksSmall");
                A_SpawnItem("BlueFlareSmall",0,0);
            }
            GRNP A 1 Bright Light("SGL_CRYO");
            Loop;

        Bounce:
            TNT1 A 0;
            TNT1 A 0 {
                If(GetCvar("pb_sglgrenadeimpact") == 1)
                { 
                    Return ResolveState("Death");
                }
                Else If(GetCvar("pb_sglgrenadeimpact") >=2)
                {
                    A_Stop();
                    Return ResolveState("Rest");
                }
                Return ResolveState(null);
            }
            Goto Spawn;
        Rest:
            GRNP A 35 Bright Light("SGL_CRYO");
        DetonateGKCryoGrenade:
            TNT1 A 0;
            TNT1 A 0 A_Scream();
        Death:
        XDeath:
            TNT1 A 0;
            TNT1 A 0 Bright A_StopSound(CHAN_BODY);
            TNT1 A 0 Bright A_ChangeFlag("ICEDAMAGE", 1);
            TNT1 A 0 Bright A_ChangeFlag("NODAMAGETHRUST", 0);
            TNT1 A 0 Bright A_Explode(150,200, 0)  ;
            TNT1 A 0 Bright A_Explode(120, 300, 0);
            TNT1 A 0 A_CheckFloor("GKCryoGrenadeDeathFloor");
            TNT1 A 0 A_CheckCeiling("GKCryoGrenadeDeathCeiling");
            Goto GKCryoGrenadeDeathEffects;
        GKCryoGrenadeDeathFloor:
            TNT1 AAAAAAAAAAAAA 0 A_SpawnItemEx("PBX_GKDetectFloorIce",Random(-150,150), Random(-150,150),1,0,0,0,0,SXF_NOCHECKPOSITION,0);
            Goto GKCryoGrenadeDeathEffects;
        GKCryoGrenadeDeathCeiling:
            TNT1 AAAA 0 A_SpawnItemEx("PBX_GKDetectCeilIce",Random(-30,30), Random(-30,30),1,0,0,0,0,SXF_NOCHECKPOSITION,0);
            // Fallthrough
        GKCryoGrenadeDeathEffects:
            TNT1 AAAAAAAAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke", 0, 0, 0, Random(10, 30)*0.2, 0, Random(0, 10)*0.2, Random(1,360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            TNT1 AAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke3", 0, 0, 0, Random(10, 30)*0.08, 0, Random(0, 10)*0.08, Random(1,360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION,64);
            TNT1 AAAAAAAAAAAA 0 Bright A_SpawnItemEx("CryoRifleTrailSparksSmall", Random(5,-5), Random(5,-5), Random(5,-5), Random(10, 30)*0.04, 0, Random(0, 10)*0.04, Random(1,360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION,64);
            TNT1 AAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, Random(10, 30)*0.08, 0, Random(0, 10)*0.08, Random(1,360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION,64);
            TNT1 AAAAAAAAAAA 0 Bright A_SpawnItemEx("IceExplosionImpact", Random(-4,4), Random(-4,4), Random(-4,4), 0, 0, 0, Random(1,360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            TNT1 A 0 A_PlaySound("weapons/CryoRifle/missiledeath");
            TNT1 AAA 0 Bright A_SpawnItemEx("PBX_GKDetectFloorCraterIce",0,0,1,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 AAA 0 Bright A_SpawnItemEx("PBX_GKDetectCeilCraterIce",0,0,1,0,0,0,0,SXF_NOCHECKPOSITION,0);
            Stop;
	}
}

class PBX_FireMissile : FlamethrowerMissileNew
{
    Default
    {
        Radius 2;
        Height 2;
        Speed 25;
        Damage 1;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +MISSILE;
        +FORCEXYBILLBOARD;
        -RIPPER;
        +NOBLOOD;
        +NOBLOODDECALS;
        +BLOODLESSIMPACT;
        -BLOODSPLATTER;
        +FORCEPAIN;
        RenderStyle "Add";
        // DamageType GloryFire;
        Scale 0.65;
        DeathSound "FlameBelch/FlameCrackle";
    }
	States
	{
        Spawn:
            TNT1 A 0;
            FIR5 ABC 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            FIR3 A 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 10));
            DB54 D 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 20));
            TNT1 A 0 A_Explode(3, 100, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 30));
            DB54 E 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 40));
            DB54 F 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 50));
            DB54 G 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            TNT1 A 0 A_Explode(3, 100, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (-10, 60));
            DB54 H 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (-50, 70));
            DB54 I 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (-60, 80));
            DB54 J 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            TNT1 A 0 A_Explode(3, 100, 0);
            DB54 KL 1 Bright A_SpawnItem("RedFlare", 0, 0);
            TNT1 A 0 A_Explode(3, 150, 0);
            TNT1 A 0 A_PlaySound("FlameBelch/FlameCrackle");
            stop;
	}
}

class PBX_FireMissileSimple : Actor
{
    Default
    {
        Radius 2;
        Height 2;
        Speed 25;
        Damage 1;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +MISSILE;
        +FORCEXYBILLBOARD;
        -RIPPER;
        +NOBLOOD;
        +NOBLOODDECALS;
        +BLOODLESSIMPACT;
        -BLOODSPLATTER;
        +FORCEPAIN;
        RenderStyle "Add";
        // DamageType "GloryFire";
        Scale 0.65;
        Alpha 1.0;
        Gravity 0;
        DeathSound "FlameBelch/FlameCrackle";
    }
	States
	{
        Spawn:
            TNT1 A 0;
            FIR5 ABC 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            FIR3 A 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 10));
            DB54 D 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 20));
            TNT1 A 0 A_Explode(3, 100, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 30));
            DB54 E 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 40));
            DB54 F 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (0, 50));
            DB54 G 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            TNT1 A 0 A_Explode(3, 100, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (-10, 60));
            DB54 H 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (-50, 70));
            DB54 I 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            EXPL A 0 A_CustomMissile ("SmallFireTrail", 6, 0, 0, 2, Random (-60, 80));
            DB54 J 1 Bright A_SpawnItem("RedFlareSmall", 0, 0);
            TNT1 A 0 A_Explode(3, 100, 0);
            EXPL A 0 A_CustomMissile ("PBX_FBFireParticles", 6, 0, 0, 2, Random (10, 20));
            DB54 KL 1 Bright A_SpawnItem("RedFlare", 0, 0);
            TNT1 A 0 A_Explode(3, 150, 0);
            EXPL A 0 A_CustomMissile ("PBX_FBFireParticles", 6, 0, Random (0, 360), 2, Random (10, 90));
            Stop;
        Death:
            TNT1 A 0 A_Explode(35, 150, 0);
            TNT1 A 0 A_Explode(3, 50);
            TNT1 A 0 {
                A_SpawnItemEx("TinyBurningPiece2", Random (-25, 25), Random (-15, 15));
                A_SpawnItemEx("TinyBurningPiece", Random (-15, 15), Random (-15, 15));
                A_CustomMissile ("PBX_FBFireParticles", 6, 0, Random (0, 360), 2, Random (10, 90));
                A_PlaySound("FlameBelch/FlameCrackle");
            }
            TNT1 A 0;
            Stop;
   }
}

class PBX_FBFireParticles : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Speed 2;
        Damage 0 ;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOINTERACTION;
        +NOCLIP;
        +FORCEXYBILLBOARD;
        DamageType "Fire";
        Renderstyle "Add";
        Scale 1.25;
        Alpha 1.0;
        Gravity 0;
    }

	States
	{
        Spawn:
            TNT1 A 0;
            DB54 ABCD 2 Bright A_SpawnItem("RedFlare", 0, 10);
            TNT1 A 0 A_CustomMissile ("BigBlackSmoke", 40, 0, Random (0, 360), 2, Random (40, 160));
            DB54 EFGHIJKLMNO 2 Bright A_SpawnItem("RedFlare", 0, 10);
            TNT1 A 0 A_SpawnItemEx("BurningEmberParticlesFloating_Bigger_Faster", Random(16,-16), Random(16,-16), Random(16,-16), 0, 0, 0, 0, 128, 0);
            DB54 PQR 2 Bright;
            Stop;
	}
}

class PBX_GKDetectFloorIce : Actor
{
    Default
    {
        Scale 5.0;
        Speed 0;
        Health 1;
        Radius 8;
        Height 2;
        Gravity 0.9;
        Renderstyle "Add";
        Alpha 0.9;
        Damage 0;
        DamageType "Blood";
        BounceType "Doom";
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        +MOVEWITHSECTOR;
        -DONTSPLASH;
        BounceFactor 0.01;
    }

	States
    {
        Spawn:
            TNT1 A 0;
            TNT1 A 5;
            Stop;
        Death:
            TNT1 A 0 Bright A_SpawnItemEx("IcicleGround", Random(-140,140), Random(-140,140), 0, 0, 0, 0, 0, SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            TNT1 A 0 Bright A_SpawnItemEx("IcicleGround", Random(-140,140), Random(-140,140), 0, 0, 0, 0, 0, SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            XXX1 A 530;
            XXX1 AAAAAAAAAAAAAAAAAAAA 1 A_FadeOut(0.05);
            Stop;
    }
}

class PBX_GKDetectCeilIce : Actor
{
    Default
    {
        Scale 5.0;
        Speed 0;
        Health 1;
        Radius 1;
        Height 2;
        Gravity 0.0;
        Damage 0;
        Renderstyle "Add";
        Alpha 0.9;
        DamageType "Blood";
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        -DONTSPLASH;
        +NOGRAVITY;
    }

    States
    {
        Spawn:
            TNT1 A 0;
            TNT1 A 0 ThrustThingZ(0,35,0,1);
            TNT1 A 1;
            Stop;
        Death:
            TNT1 AAA 0 Bright A_SpawnItemEx("IcicleCeiling",Random(-10,10), Random(-10,10), 0, 0, 0, 0, 0, SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            TNT1 A 0 A_SpawnItemEx("CeilingCrystal1", Random(-60,60), Random(-60,60), -1, 0, 0, 0, 0, SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            TNT1 A 0 A_SpawnItemEx("CeilingCrystal2", Random(-60,60), Random(-60,60), -1, 0, 0, 0, 0, SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            TNT1 A 0 A_SpawnItemEx("CeilingCrystal3", Random(-60,60), Random(-60,60), -1, 0, 0, 0, 0, SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            TNT1 A 0 A_SpawnItemEx("CeilingCrystal4", Random(-60,20), Random(-60,20), -1, 0, 0, 0, 0, SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            XXX1 A 530 Bright;
            XXX1 AAAAA 1 A_FadeOut(0.05);
            Stop;
    }
}

class PBX_GKDetectFloorCraterIce : Actor
{
    Default
    {
        Scale 3.4;
        Speed 0;
        Health 1;
        Radius 8;
        Height 4;
        Gravity 0.9;
        Damage 0;
        Renderstyle "Shaded";
        StencilColor "Black";
        Alpha 0.9;
        DamageType "Blood";
        BounceType "Doom";
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        +MOVEWITHSECTOR;
        -DONTSPLASH;
        BounceFactor 0.01;
    }
    
    States
    {
        Spawn:
            TNT1 A 0;
            TNT1 A 2;
        Spawn2:
            TNT1 A 0 ThrustThingZ(0,-10,0,1);
            TNT1 A 4;
            Stop;
        Death:
            TNT1 A 1;
            XXX1 A 2000;
            Stop;
    }
}

class PBX_GKDetectCeilCraterIce : Actor
{
    Default
    {
        Scale 3.4;
        Speed 0;
        Health 1;
        Radius 1;
        Height 1;
        Gravity 0.0;
        Damage 0;
        Renderstyle "Shaded";
        StencilColor "Black";
        Alpha 0.9;
        DamageType "Blood";
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        -FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        -DONTSPLASH;
        +NOGRAVITY;
    }

    States
    {
        Spawn:
            TNT1 A 0;
            TNT1 A 0 ThrustThingZ(0,35,0,1);
            TNT1 A 2;
            Stop;
        Death:
            XXX1 A 2000;
            XXX1 AAAAA 1 A_FadeOut(0.05);
            Stop;
    }
}

// class FireArmorPinata : ArmorPinata
// {
// 	scale 0.4
// 	Armor.Saveamount 1
// }

// class FireArmorPinataL1 : ArmorPinataL1
// {
// 	Armor.Saveamount 2
// }

// class FlamePinataSpawn
// {
// 	States
// 	{
// 		Spawn:
// 			TNT1 AA 0 A_SpawnItemEx("FireArmorPinata",0,0,16,Random(0,8),0,Random(0,8),Random(0,360))
// 			Stop
// 	}
// }

// class FlamePinataSpawnHigh
// {
// 	States
// 	{
// 		Spawn:
// 			TNT1 A 0 A_Jump(127, "SpawnHigh")
// 			TNT1 AA 0 A_SpawnItemEx("FireArmorPinata",0,0,16,Random(0,8),0,Random(0,8),Random(0,360))
// 			Stop
			
// 		SpawnHigh:
// 			TNT1 AA 0 A_SpawnItemEx("FireArmorPinataL1",0,0,16,Random(0,8),0,Random(0,8),Random(0,360))
// 			Stop	
// 	}
// }