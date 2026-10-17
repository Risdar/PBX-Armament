extend class PBX_NeoHMG
{
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////    
	override void ModifyDamage(int damage, Name damageType, out int newDamage, bool passive, Actor inflictor, Actor source, int flags)
    {
		if (passive && damage > 0)
		{
			mShieldDrain = clamp(int(damage * SHIELD_PROTECTION_MULTIPLIER), 1, SHIELD_MAXCHARGE);
			if (owner.player && owner.player.readyweapon is self.getClass() && mShieldWasActive)
			{
				owner.TakeInventory("HMGShield", mShieldDrain);
				owner.A_StartSound("StickyGrenade/Hit", 125);
				newDamage = 0;
			}
		}

    }

	override Vector2 ModifyBobLayer(Vector2 Bob, int layer, double ticfrac)
	{
		if(layer == HMG_SHIELDLAYER)
			return Bob * 0.4;
		else
			return Bob;
	}
    
	override void DoEffect() 
	{
		super.DoEffect();
		if(level.isFrozen() || !owner || !owner.player || !owner.player.readyweapon) 
		{
			return;
		}

		// Things to check
		bool isWeapon = owner.player.readyweapon is self.getClass();
		bool isPressingAlt = owner.player.cmd.buttons & BT_ALTATTACK;
		bool hasShieldCharge = countinv("HMGShield") != 0;
		bool isNotOverheating = overheat <= MAX_OVERHEAT-5;
		bool shouldEnable = isWeapon && isPressingAlt && mShieldIsReady && hasShieldCharge && isNotOverheating;

		// If the shield should be enabled
		If(shouldEnable)
		{
			// Activate the shield
			owner.Player.SetPSprite(HMG_SHIELDLAYER,resolvestate("HMGShield"));

			// If the shield was only now activated
			If(!mShieldWasActive)
			{
				// Do a shield bash
				owner.Player.SetPSprite(HMG_SHIELDLAYER,resolvestate("HMGShieldBash"));
				owner.A_startsound("HMGSHLD3",HMG_SHIELDSOUNDLAYER);
			}

			// Enable these variables regardless
			mShieldWasActive = true;
			mShieldActive = true;
			owner.bnoblood = true;	
		}
		// If the player is not activating the shield
		else if(owner.player)
		{
			// Reset some variables
			mShieldActive = false;
			owner.bnoblood = false;

			// If the shield was recently activated and the player is holding the NeoHMG
			If(mShieldWasActive && isWeapon)
			{
				// Play the shield break effects
				owner.Player.SetPSprite(HMG_SHIELDLAYER,resolvestate("HMGShieldBreak"));
				owner.A_startsound("HMGSHLD4",HMG_SHIELDSOUNDLAYER);
				owner.a_startsound("StickyGrenade/Hit",125,0,0.5);

				// Set the cooldown
				mShieldCooldown = SHIELD_COOLDOWN;
				mShieldIsReady = false;

				// If the shield doesnt have any charges
				If(countinv("HMGShield") < 1)
				{
					// Play the shield broken effects, "HMGShieldBroken" is where the stun bomb is spawned
					mShieldIsBroken = true;
					EventHandler.SendInterfaceEvent(PlayerNumber(), "PB_HUDInterference", 20);
					owner.A_startsound("HMGSHLD1",HMG_SHIELDSOUNDLAYER);
					owner.Player.SetPSprite(HMG_SHIELDLAYER,resolvestate("HMGShieldBroken"));
				}

				// Disable this variable
				mShieldWasActive = false;
			}

			// Decrease the cooldown
			If(mShieldCooldown > 0)
			{
				mShieldCooldown--;
			}

			// If the cooldown is finished, the shield is not broken, but the shield is not ready
			Else if(!mShieldIsBroken && !mShieldIsReady)
			{
				// Ready shield
				mShieldIsReady = true;
				
				// Play a sound if the player is still holding the NeoHMG
				If(isWeapon)
				{
					owner.A_startsound("HMGSHLD",HMG_SHIELDSOUNDLAYER2);
				}
				
			}

			// If the cooldown is finished
			If(mShieldCooldown < 1)
			{
				// Counts up to SHIELD_RECHARGE_CYCLE to finish one cycle
				// If the weapon is overheating then it will recharge faster
				If(mShieldRechargeTimer < ((overheat >= OVERHEAT_THRESHOLD) ? Int(SHIELD_RECHARGE_CYCLE/2) : SHIELD_RECHARGE_CYCLE))
				{
					mShieldRechargeTimer++;
				}
				// If the shield charge is less than the maximum amount and the weapon is overheating
				Else if(countinv("HMGShield") < SHIELD_MAXCHARGE && overheat > 0)
				{
					// Reset the recharge timer and give the charge
					mShieldRechargeTimer = 0;
					giveinventory("HMGShield",SHIELD_RECHARGE_AMOUNT);
				}
				// If the shield was broken
				Else if(mShieldIsBroken)
				{
					// Reset some variables
					mShieldIsBroken = false;
					mShieldIsReady = true;

					// Play a sound if the player is still holding the NeoHMG
					If(isWeapon)
					{
						owner.A_startsound("HMGSHLD",HMG_SHIELDSOUNDLAYER2);
					}
					
				}
			}
		}
	}

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
	action void HMGSpawnStunBomb()
	{
		let mActor = PB_StunGrenadeExplosion(Spawn("PB_StunGrenadeExplosion",self.pos));
		int mShieldLeft = max(10,CountInv("HMGShield")); // So it'll atleast deal 10 damage with 10 radius
		if(mActor)
		{
			pbxcore_debug.PrintInt("spawned stun explosion with shield left: %d",mShieldLeft);
			mActor.target = self.player.mo;
			mActor.expDmg  = mShieldLeft;
			mActor.expRad  = mShieldLeft; 
			mActor.expType = "Stun";
		}
	}

	action void HMG_DetonateShield()
	{
		invoker.mShieldCooldown = SHIELD_COOLDOWN;
		invoker.mShieldIsReady = false;
		invoker.mShieldIsBroken = true;
		invoker.mShieldWasActive = false;
		a_startsound("StickyGrenade/Hit",125,0,0.5);
		A_startsound("HMGSHLD1",HMG_SHIELDSOUNDLAYER);
		
		HMGSpawnStunBomb();
		
		A_SetInventory("HMGShield",0);
		EventHandler.SendInterfaceEvent(PlayerNumber(), "PB_HUDInterference", 20);
	}

	action void HMG_HandleSpecial()
    {
		A_Takeinventory("GoWeaponSpecialAbility",1);
		A_ZoomFactor(1.0);

		if(invoker.mShieldActive)
		{
			HMG_DetonateShield();
		}
    }

	action void HMG_CoolDownBarrel()
	{
		int heat = PB_GetOverheat();
		
		if (heat < OVERHEAT_THRESHOLD)
		{
			PB_CoolDownBarrel(0, 0, 2, 0, 0, 0, 1.0, 1.0, true);
			return;
		}
		
		double scale = PB_Math.LinearMap(double(heat), 175.0, 500.0, 0.8, 2.5);
		double alpha = PB_Math.LinearMap(double(heat), 175.0, 500.0, 0.5, 1.5);
		
		PB_CoolDownBarrel(0, 0, 2, 0, 0, 0, scale, alpha, true);
	}

	action void cooldownOverheat()
	{
		A_Overlay(OVERHEATCOOLING_LAYER,"Cooling",true);
	}

	action void HMG_fireBullet(bool overThreshold)
	{
		double spread;
        bool isOverheating = PB_GetOverheat() > 0;

		if(overThreshold)		spread = 7;
		else if(isOverheating) 	spread = 1.0 + (PB_GetOverheat() / 100.0);
		else					spread = 3;
		
		A_Startsound("MG42FIR",CHAN_WEAPON,CHANF_OVERLAP);
		if(overThreshold)
		{
			A_Startsound("weapon/HMG/Fire",CHAN_WEAPON,CHANF_OVERLAP);
		}
		PB_FireBullets(overThreshold ? "PB_792x57mm_Heated" : "PB_792x57mm", 1, spread, 0, 0, spread);
	}

	action void setMagSprite(
		name l5,
		name l4, 
		name l3, 
		name l2, 
		name l1
	)
	{
		if(PB_GetMagUnloaded()) return; // Dont change if its unloaded
		int ammo = invoker.ammo2.amount;
		if		(ammo >  4) A_SetWeaponSpriteEx(l5);
		else if (ammo == 4) A_SetWeaponSpriteEx(l3);
		else if (ammo == 3) A_SetWeaponSpriteEx(l3);
		else if (ammo == 2) A_SetWeaponSpriteEx(l2);
		else if (ammo <= 1)	A_SetWeaponSpriteEx(l1);
	}

	action void fireHMG(int ticCount)
	{
		bool overThreshold = PB_GetOverheat() > OVERHEAT_THRESHOLD;

		switch (ticCount)
		{
			case 1:
				// SETUP
				A_AlertMonsters();
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				// ACTUAL FIRING
				HMG_fireBullet(overThreshold);
				PB_DynamicTail("lmg", "lmg");
				A_FlashOverlay();
				PB_WeaponRecoil(-1.1,frandom[sfx](-0.82,0.82));
				PB_IncrementHeat(2);
				PB_GunSmoke(0, 0, 0);
				PB_LowAmmoSoundWarning("hdmr");
				PB_FireOffset();
				A_QuakeEx(0,1,0,12,0,10,"",QF_WAVE|QF_RELATIVE|QF_SCALEDOWN,0.6,0,0.2,0,0,0.3,0.40);
				A_Zoomfactor(0.98);
				// TAKE AMMO
				PB_LowAmmoSoundWarning();
				pb_takeammo(invoker.ammotype2,1,0);
				break;
				
			case 2:
				PB_ModifyOverheat(overThreshold ? OVERHEAT_GIVE_OVR : OVERHEAT_GIVE_NORM);
				break;
		}
	}
	
	action void A_FireVisualThinker(class<VisualThinker> thinker, int speed = 0, double offsetangle = 0, double offsetpitch = 0, double offsetx = 0, double offsety = 0, double offsetz = 0, bool rvel = true)	
	{
		let thonk = Level.SpawnVisualThinker(thinker);
		if(thonk)
		{
			BDPGMQuaternion base = BDPGMQuaternion.createFromAngles(angle,pitch,roll);
			BDPGMQuaternion angl = BDPGMQuaternion.createFromAngles(offsetangle,0,0);
			BDPGMQuaternion ptch = BDPGMQuaternion.createFromAngles(0,offsetpitch,0);
			BDPGMQuaternion rotated = base.multiplyQuat(angl).multiplyQuat(ptch);
			Vector3 dir;
			[dir.x, dir.y, dir.z] = rotated.toAngles();
			quat ofsbase = Quat.FromAngles(angle, pitch, roll);
			Vector3 offset = (offsety, -offsetx, offsetz);
			Vector3 ppos = ofsbase * offset;
			Vector3 ofs = level.Vec3Offset(pos, ppos);
			thonk.pos = ofs;
			thonk.pos.z += player.mo.height * 0.5 - player.mo.floorclip + player.mo.AttackZOffset*player.crouchFactor - 4 + offsetz; //i want to die
			invoker.Vel3DFromAngle(speed,dir.x,dir.y);
			thonk.vel = invoker.vel;
			invoker.Vel3DFromAngle(clamp(speed/2,0,player.mo.radius),dir.x,dir.y);
			thonk.pos += invoker.vel;
			if(rvel)
			{
				thonk.vel += player.mo.vel;
			}
		}
	}

	action void A_FireShieldParticles()
	{
		for(int i = 40; i > 0; i--)
		{
			A_FireVisualThinker("ShieldParticle", i > 40 / 2 ? 2 : 4,random(-4,4),random(-20,20),frandom(-20,20),10,frandom(0,6));
		}
	}

}