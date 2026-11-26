extend class PBX_TeslaGun
{
//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void Tesla_ChargeLightningBall()
    {
        FLineTraceData traceData;
        double pz = height * 0.5 - floorclip + player.mo.AttackZOffset * player.crouchFactor;
        bool hit = LineTrace(Angle, LIGHTNING_RANGE, Pitch, 0, offsetz: pz, data: traceData);
        
        if(hit && traceData.HitActor && traceData.HitActor is "Tesla_LightningBall")
        {
            let lightball = Tesla_LightningBall(traceData.HitActor);
            if(lightball)
            {
                lightball.increaseCharge();
            }
        }
    }

    action int Tesla_GetAnimDuration()
    {
        if(invoker.mLightShockMode)
        {
            return DECHARGE_LOOP_SHOCK;
        }
        return DECHARGE_LOOP;
    }

    action state Tesla_AltFireAnim()
    {
        A_SetWeaponFrame(random[sfx](0,7));
        A_StartSound("PLSC_1",CHAN_AUTO,CHANF_OVERLAP);
        A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-2,2), -15, 0, random(-2,2));
        PB_TakeAmmo(invoker.ammotype2,takeNum:DECHARGE_GIVE,emptyMag:0);
        invoker.mTeslaAnimCounter++;

        if(invoker.mTeslaAnimCounter < Tesla_GetAnimDuration())
        {
            return resolvestate("AltFireAnimation");
        }
        return resolvestate(null);
    }

    action state Tesla_DechargeAnim()
    {
        A_SetWeaponFrame(random[sfx](0,3));
        A_GiveInventory(invoker.ammotype2,DECHARGE_GIVE);
        invoker.mTeslaAnimCounter++;
        
        if (invoker.mTeslaAnimCounter == Int(DECHARGE_LOOP/2))
        {
            A_StartSound("PLSCOOL",CHAN_VOICE);
        }
        if (invoker.mTeslaAnimCounter < Tesla_GetAnimDuration()) // Loop this until all the taken ammo is given
        {
            return ResolveState("DechargeLoop");
        }
        return ResolveState(null);
    }

    action int Tesla_GetMinAmmo(bool isAlt = false)
    {
        if(invoker.mLightShockMode)
        {
            return isAlt ? LIGHTSTORM_AMMO_TAKE : LIGHTSHOCK_AMMO_TAKE;
        }
        return isAlt ? LIGHTBALL_AMMO_TAKE : 1;
    }

    action void Tesla_FireLightningBall()
    {
        A_ZoomFactor(1.0);
        A_FireCustomMissile("ElectroBlastTrail2", 0, 0, 0, 0);
        // A_StartSound("TESLAH", CHAN_WEAPON, CHANF_LOOPING, starttime: frandom[sfx](0, 0.5));
        A_StartSound("PLSULT", CHAN_WEAPON);
        A_FireCustomMissile("Tesla_LightningBall",0,0,0,0);
        A_FlashOverlay();
        // Effects
        A_SetBlend("Blue", 0.6, 12);
        EventHandler.SendInterfaceEvent(PlayerNumber(), "PB_HUDInterference", 20);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
    }

	action Void Tesla_VisualLaser()
	{
		double vz = (height * 0.5 - floorclip + player.mo.AttackZOffset*player.crouchFactor) - 8; //little offset
		Vector3 dir = (AngleToVector(angle, cos(pitch)), -sin(pitch));
		vector3 spos = (pos.xy,pos.z + vz);

		let laser = new("PB_Laser"); if(!laser) return;

		laser.Trace(spos,cursector,dir,8192,TRACE_NoSky,Line.ML_BLOCKEVERYTHING|Line.ML_BLOCKHITSCAN,false,invoker.owner);
		let res = laser.results;
		vector3 fpos = res.HitPos;
		fpos -= res.HitVector; //step back 1 map unit, not necessary now, but for spawning something at hitlocation is useful
		
		vector3 dif = levellocals.Vec3diff(spos,fpos);
		vector3 dr = dif.unit();
		double dis = dif.length();
		
		int q = int(dis / railpartstepaim + 1); //+ 1 to ensure its always more than 0, since distance cant be negative but can be 0
		
		for(int i = 0; i < q; i++)
		{
			spos += (dr * railpartstepaim);
			if(i > 3) //skip some iteration, so it doesnt spawn a particle blocking the view
            {
                PBX_DrawBlueRail(spos,size:8);
            }
		}
	}

    action void Tesla_FireLightningStorm(
        int damage = 100, 
        int numrays = 32, 
        double coneAngle = 90, 
        double distance = 1024, 
        double vrange = 0, 
        int duration = 5, 
        int delay = 0, 
        int maxChains = 1, 
        int maxlinks = 5,
        name damageType = 'plasma'
    )
    {
        Vector3 beamstart = PBX_LightningController.L_GetBeamAttachPos(self);
        Array<Actor> alreadyChained;

        for (int i = 0; i < numrays; i++)
        {
            double an = angle - coneAngle * 0.5 + (numrays > 1 ? coneAngle / (numrays - 1) * i : 0);

            FTranslatedLineTarget t;
            AimLineAttack(an, distance, t, vrange);

            Vector3 beamEnd;
            if (t.linetarget && PBX_LightningController.L_IsValidVictim(t.linetarget, self))
            {
                beamEnd = PBX_LightningController.L_GetBeamAttachPos(t.linetarget);

                if (alreadyChained.Find(t.linetarget) == alreadyChained.Size())
                {
                    PBX_LightningController.L_StartChain(self, t.linetarget, damage, distance, duration, delay, maxChains, maxlinks, damageType:damageType);
                    Spawn("LightningBolt", t.linetarget.pos);
                    S_StartSound("Thunder",0);
                    alreadyChained.Push(t.linetarget);
                }
            }
            else
            {
                beamEnd = beamstart + (cos(an), sin(an), 0) * distance;
            }

            PBX_LightningController.L_DrawLightning(beamstart, beamEnd, spawnSpark: (t.linetarget != null), playersource: player);
        }
        // Effects
        A_SetBlend("Blue", 0.6, 12);
        EventHandler.SendInterfaceEvent(PlayerNumber(), "PB_HUDInterference", 20);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
    }

    action void Tesla_FirePrimary()
    {
        A_SetWeaponFrame(random[sfx](4,7));
        A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
        A_FireProjectile("BlueFlareSpawn",0,0,0,0);
        A_FireCustomMissile("PlasmaFlareSpawner", 0, 0, 0,spawnheight:-5);
        A_StartSound("TESLAH2", CHAN_WEAPON, CHANF_LOOPING);
        A_WeaponOffset(frandom[sfx](-0.5, 0.5), WEAPONTOP + frandom(0, 0.75), WOF_INTERPOLATE);
        A_FlashOverlay();

        PB_TakeAmmo(invoker.ammotype2,Tesla_GetMinAmmo(),emptyMag:0);
        if(invoker.mLightShockMode)
        {
            PBX_FireShock(LIGHTSHOCK_DAMAGE,LIGHTSHOCK_TARGET,LIGHTSHOCK_RANGE);
        }
        else
        {
            PBX_FireLightningGun(ARCFIRE_DAMAGE, spawnheight:-10, range:LIGHTNING_RANGE, duration:1, delay:0, maxChains:1, maxlinks:5);
        }
        Tesla_ChargeLightningBall();
    }
 
    action state Tesla_CheckDecharge()
    {        
        if(!invoker.mLightShockMode)
        {
            A_FireCustomMissile("PlasmaFlareSpawner",0,0,0,0);
            A_FireProjectile("BlueFlareSpawn",0,0,0,0);
            A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-2,2), -15, 0, random(-2,2));
            A_FlashOverlay();
        }

        Tesla_VisualLaser();

        if(JustPressed(BT_RELOAD))
            return resolvestate("DeCharge");
        return resolvestate(null);
    }
}