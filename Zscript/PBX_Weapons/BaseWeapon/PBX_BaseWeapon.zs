#include "./PBX_LaserSight.zs"
#include "./PBX_SmartScope.zs"
#include "./PBX_ScrollZoom.zs"
#include "./PBX_WeaponWheel.zs"

// Generic Weapon Wheel Tokens
class PBX_Toggle_Laser : inventory {default{inventory.maxamount 1;}}
class PBX_Toggle_Scope : inventory {default{inventory.maxamount 1;}}
class PBX_Toggle_NVG   : inventory {default{inventory.maxamount 1;}}
class PBX_CloseWheel   : inventory {default{inventory.maxamount 1;}}

// What gives the player Nightvision, its basically a powerup
class PBX_Infrared : PB_PowerLightAmp  {default{Powerup.Duration -1800;}}

class PBX_WeaponBase : PB_WeaponBase abstract
{
//////////////////////////// WEAPON SETUP ////////////////////////////////////////////////////////////////////////////////////
    Default
    {
        PBX_WeaponBase.ScopeConfiguration false, 1.0, 1.0; 
        PBX_WeaponBase.SelectWeaponUpgrade "";
        PBX_WeaponBase.TakeWeaponDowngrade "";
    }

    override void PostBeginPlay()
    {
        mZoomLevel = mMinZoom;
        super.PostBeginPlay();
    }

    override void DoEffect() 
	{
		super.DoEffect();

        if (level.isFrozen()) return;
        
		If(owner.player && owner.player.readyweapon && owner.player.readyweapon.GetClass() is self.GetClass())
        {
		    PBX_HandleNightVision();
            PBX_DoEffectWeaponReady();
		}
    }

    protected virtual void PBX_DoEffectWeaponReady() {}

    // A wrapper for PB_WeaponRaise so we can do some default behaviours
    action void PBX_WeaponRaise(string upSnd = "")
    {
        PB_WeaponRaise(upSnd);
        if(pbxweapons_sendTip) PBX_WeaponHelpText(); // This function is in PBXWeapons_Tips.zs
        PBX_UpgradeWeapon();
    }

    // Same as above
    action void PBX_WeaponLower()
    {
        PB_SetZoom(false);
        A_SetInventory("PBX_Infrared", 0);
        A_WeaponOffset(0,32);
        PB_SetRoll(0);
        A_StopSound(CHAN_WEAPON);
        PB_ClearDualWield();
        // Clears the Laser Sight Puff
        invoker.ClearPuff(); 
        if(invoker.mLaserPuff) invoker.mLaserPuff.bInvisible = true;
    }

    private name mUpgradeWeapon, mDowngradeWeapon;
    property SelectWeaponUpgrade: mUpgradeWeapon;
    property TakeWeaponDowngrade: mDowngradeWeapon;
    action void PBX_UpgradeWeapon()
    {
        if(pbxweapons_keepweapons) return;

        if(invoker.mUpgradeWeapon != "") PB_SelectIfUpgrade(invoker.mUpgradeWeapon);
        if(invoker.mDowngradeWeapon != "") PB_TakeIfUpgrade(invoker.mDowngradeWeapon);
    }

    action state PBX_SetupDualWield(string noAkimboMsg)
    {
        // Dual Wield Toggle
        if (A_CheckAkimbo()) 
            return ResolveState("StopDualWield");
        if (invoker.amount >= 2) 
        {
            if(PB_GetZoom()) return ResolveState("ZoomOut"); // After zoomout it goes to "SwitchToDualWield"
            return ResolveState("SwitchToDualWield");
        }

        // If you dont have 2 weapon
        A_Print(noAkimboMsg);
        return ResolveState("Ready3");
    }

    action state PBX_HandleDurability(name toCheck, int ammoTake)
    {
        if (CountInv(toCheck) < 1) 		        return ResolveState("WeaponBreak");
		if (invoker.ammo1.amount < ammoTake) 	return ResolveState("NoAmmo");
		return ResolveState(null);
    }

//////////////////////////// NVG ////////////////////////////////////////////////////////////////////////////////////
    private bool mNightVisionActivated;
    action void PBX_ToggleNightVision()
    {
        invoker.mNightVisionActivated = !invoker.mNightVisionActivated;
        A_Print(invoker.mNightVisionActivated ? "$PBX_nvgOn" : "$PBX_nvgOff");
        A_SetInventory("PBX_Infrared", invoker.mNightVisionActivated);

        if(invoker.mNightVisionActivated) 
            A_StartSound("RA1IF1", CHAN_WEAPON, CHANF_OVERLAP, 1.0);

        A_SetBlend("Black",0.75,16);
    }

    clearscope bool IsNVGActive()
    {
        return mNightVisionActivated;
    }

    // Call in DoEffect()
    private bool mShouldPlayNVGSound;
    void PBX_HandleNightVision()
    {
        bool isZoomed = owner.FindInventory("Zoomed");

        if(IsNVGActive() && isZoomed)
        {
            owner.A_SetInventory("PBX_Infrared",1);
            if(mShouldPlayNVGSound)
            {
                owner.A_StartSound("RA1IF1", CHAN_AUTO, CHANF_OVERLAP);
                mShouldPlayNVGSound = false;
            }
        }
        else
        {
            owner.A_SetInventory("PBX_Infrared",0);
            mShouldPlayNVGSound = true;
        }
    }

//////////////////////////// FIRING ////////////////////////////////////////////////////////////////////////////////////
    // PB's firebullets modified to shoot non pb_projectile projectiles
    // Taken from one of CSSG's function
    action void PBX_FireBullets(string type, int amount, double angle, double offs, double height, double pitch)
	{
		vector2 spread;
		for(int i = amount; i > 0; i--)
		{
			spread.x = frandom(-angle, angle);
			spread.y = frandom(-pitch, pitch);

			if(i == amount) 
			{
				spread.x *= PB_Math.LinearMap(pb_weapon_recoil_mod_horizontal, 0.0, 1.0, 1.0, 0.2);
				spread.y *= PB_Math.LinearMap(pb_weapon_recoil_mod_vertical, 0.0, 1.0, 1.0, 0.2);
				// spread *= clamp((invoker.sustainedFire / 5), 0, 1);
				spread *= GetCrouchFactor();
			}

			Actor p1, p2 = A_FireProjectile(type, spread.x, 0, offs, height, FPF_NOAUTOAIM, spread.y);

            if(p2)
            {
                PB_Projectile pbProj = PB_Projectile(p2);
				if(pbProj)
					pbProj.isBloodExplosionGenerator = amount > 4 && i == amount;
            }
		}
	}

    // Fire Lighting
    action void PBX_FireLightningGun(
        int     damage, 
        double  horOfs      = 0, 
        double  spawnheight = 0, 
        double  range       = 512, 
        int     duration    = 1, 
        int     delay       = 0, 
        int     maxChains   = 1, 
        int     maxlinks    = 5,
        name    damageType  = 'plasma'
    )
	{
		// beamstart is where the lightning appears from:
		Vector3 beamstart = PBX_LightningController.L_GetBeamAttachPos(self, horOfs, spawnheight);
		Vector3 beamEnd;

		// hit victim:
		FLineTraceData tr;
		LineTrace(angle, range, pitch, offsetz: PBX_LightningController.L_GetAttackHeight(PlayerPawn(self)), data: tr);
		if (tr.HitType == TRACE_HitActor && tr.hitActor && PBX_LightningController.L_IsValidVictim(tr.hitActor, self))
		{
			beamEnd = PBX_LightningController.L_GetBeamAttachPos(tr.HitActor);
			PBX_LightningController.L_StartChain(self, tr.HitActor, damage, range, duration, delay, maxChains, maxlinks, damageType:damageType);
			tr.hitactor.TriggerPainChance("Stun", true);
		}
		// hit nothing:
		else
		{
			beamEnd = tr.HitLocation;
		}
		PBX_LightningController.L_DrawLightning(beamstart, beamend, spawnSpark: (tr.HitType != TRACE_HitNone), playersource: player);
	}

    // Ricochet function from BDP
    Action void PBX_FireRicochet(
        name projectileName, 
        name casingName = "",
        int projectileAmount = 1, 
        double angle = 1.0,
        double offsets = 0, 
        double height = 0, 
        double pitch = 0,
        name damageType = "Pistol",
        name puffType = "PB_BulletPuff"
    )
	{
		FLineTraceData ricochetdata;
		invoker.owner.LineTrace(invoker.owner.angle, 4096, invoker.owner.pitch, TRF_SOLIDACTORS, offsetz: invoker.owner.player.viewz - invoker.owner.pos.z, data: ricochetdata);
		vector3 hitNormal;

		if(ricochetdata.HitType == TRACE_HitWall )
		{
			if(!ricochetdata.LineSide)
            {
                hitnormal = (ricochetdata.Hitline.delta.y, -ricochetdata.Hitline.delta.x, 0).unit();
            }
			else
            {
                hitnormal = (-ricochetdata.Hitline.delta.y, ricochetdata.Hitline.delta.x, 0).unit();
            }
		}
        
		else if (ricochetdata.HitType == TRACE_HitFloor)
        {
            hitnormal = ricochetdata.HitSector.FloorPlane.normal;
        }
			
		else if (ricochetdata.HitType == TRACE_HitCeiling)
        {
            hitnormal = ricochetdata.HitSector.CeilingPlane.normal;
        }

		Vector3 PlayerAngle = BDPMATH.AngletoVector3(1.0,invoker.owner.angle,invoker.owner.pitch);
		Vector3 BounceAngle = BDPMATH.BounceNormal(PlayerAngle,hitNormal);
		
		Double NextShotAngle,NextShotPitch;
		[NextShotAngle, NextShotPitch] = BDPMATH.Vector3toangles(BounceAngle);

		double anglediff = BDPMath.AngleDiff(invoker.owner.angle % 360.0,nextshotangle % 360.0);
		double pitchdiff = BDPMath.AngleDiff(invoker.owner.pitch % 360.0,nextshotpitch % 360.0);
		
		Vector3 NextShotPosition = level.Vec3Offset(ricochetData.hitlocation, hitnormal * 2.0);
		
        // Actually fire
        PBXCore_Debug.Print("Projectile Fired");
		PB_FireBullets(projectileName, projectileAmount, angle, offsets, height, pitch);
        if(casingName != "")
        {
            PB_SpawnCasing(casingName,22,2,28,frandom[sfx](-2, -1),frandom[sfx](5,8),frandom[sfx](3,4));
        }

		If(pitchdiff > 45 || anglediff > 45 || pitchdiff < -45 || anglediff < -45)
        {
            return;
        }
		
		If(ricochetdata.HitType == TRACE_HitWall || ricochetdata.HitType == TRACE_HitFloor || ricochetdata.HitType == TRACE_HitCeiling)
		{
            PBXCore_Debug.Print("Ricochet");
			Invoker.Owner.LineAttack(NextShotAngle,8192,NextShotPitch,35,damageType,puffType,LAF_ABSPOSITION | LAF_ABSOFFSET,null,NextShotPosition.Z,NextShotPosition.x,NextShotPosition.y);
			let ricochettracer = Invoker.owner.spawn("decorativetracer",nextshotposition);
			If(ricochettracer)
			{
                PBXCore_Debug.Print("Ricochet Tracer");
				ricochettracer.angle = nextshotangle;
				ricochettracer.pitch = nextshotpitch;
				ricochettracer.vel3dfromangle(140,nextshotangle,nextshotpitch);
			}
		}
	}

    action void A_Recoil3D(double amt)
	{
		vel += BDPMath.VecFromAngles(angle, pitch, -amt);
	}

//////////////////////////// OTHERS ////////////////////////////////////////////////////////////////////////////////////
    action state PBX_CheckInspect()
    {
		int ammoToCheck = invoker.ammotype2 ? invoker.ammo2.amount : 0;
        int maxAmmoToCheck = invoker.ammotype2 ? invoker.ammo2.maxamount : 0;
        bool pressingReload = PressingReload() || (player.oldbuttons & BT_RELOAD);

        if (pressingReload && ammoToCheck >= maxAmmoToCheck) 
        {
            return resolvestate("WeaponInspect");
        }
        return resolvestate(null);
    }

    action bool PlayerPressedOnce(int button)
	{
		int bt = player.cmd.buttons;
		int oldbt = player.oldbuttons;
		if((bt & button) && !(oldbt & button))
        {
            return true;
        }
		return false;
	}

    action state A_PressingReload(StateLabel st = "Reload")
	{
		if ((player.cmd.buttons & BT_RELOAD) || (player.oldbuttons & BT_RELOAD)) 
        {
            return resolvestate(st);
        }
        return resolvestate(null);
	}

    // Return to a ready state based on zoom
    action state PBX_ReturnReady(StateLabel zoomed = "Ready2", StateLabel normal = "Ready3")
    {
        if(PB_GetZoom()) return resolvestate(zoomed);
        return resolvestate(normal);
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
        // Used by monster weapons since they have durability
        WeaponBreak:
			TNT1 A 0 {
				for(int i = 0; i < 5; i++)
				{
					A_CustomMissile("MetalShard1", 5, 0, random[sfx](-10, -20), 2, random[sfx](0, 30));
					A_CustomMissile("MetalShard2", 5, 0, random[sfx](-10, -20), 2, random[sfx](0, 30));
					A_CustomMissile("MetalShard3", 5, 0, random[sfx](-10, -20), 2, random[sfx](0, 30));
				}
				A_ALertMonsters();
				A_Startsound("meleeweapon/break");
            }
        // So any weapon can go to this state if they want to be safely removed
        SafelyRemoveWeapon:
            TNT1 A 0 {
                player.pendingweapon = player.mo.BestWeapon(null);
                self.RemoveInventory(invoker);
            }
			Stop;

        // Fail safe
        WeaponInspect:
            TNT1 A 0;
            goto Ready;
    }

}

//////////////////////////// CUBES ////////////////////////////////////////////////////////////////////////////////////
// Cubes
Class PBX_CubeRadius : actor
{
	DEFAULT
	{
		Radius 20;
		Height 20;
		Scale 32.0;
		//RenderStyle "STYLE_Translucent";
		//Alpha 0.8;
		+NOINTERACTION
		+NOBLOCKMAP
		+THRUACTORS
		-RANDOMIZE
	}

	int mColor;

	enum PBX_CubeColor
	{
		RED,
		GREEN,
		BLUE
	}

	States
	{
		Spawn:
			0001 A 0;
			0000 A 1 {
				if(mColor == BLUE)
					sprite = GetSpriteIndex("0001");
			}
			stop;
	}
}

Class PBX_CubeRadiusLoop : PBX_CubeRadius
{
	States
	{
		Spawn:
			0000 A 0;
			0000 A 1;
			wait;
	}
}

class PBX_RadiusVisualizer : Inventory
{
    Actor currentCube;

    Default
    {
        +INVENTORY.UNDROPPABLE;
    }

    override void DoEffect()
    {
        Super.DoEffect();

        if (!owner) return;

        if (currentCube && currentCube.bDestroyed)
        {
            currentCube = null;
        }

        // Spawn and size — runs once when cube is null
        if (!currentCube)
        {
            currentCube = Spawn("PBX_CubeRadiusLoop", owner.pos);
            if (!currentCube) return;

            // Set size once on spawn
            currentCube.scale.x = double(owner.radius) * 2;
            currentCube.scale.y = double(owner.height);
        }

        // Every tic change position only
        currentCube.SetOrigin(owner.pos, true);
        currentCube.vel = owner.vel;
        currentCube.angle = owner.angle;
    }

    override void OnDestroy()
    {
        if (currentCube && !currentCube.bDestroyed)
        {
            currentCube.Destroy();
            currentCube = null;
        }

        Super.OnDestroy();
    }
}