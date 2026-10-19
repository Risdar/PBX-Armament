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

    action void Tesla_FireBeam()
	{
		vector3 fw = (cos(angle),sin(angle),0);
		int playerz = height * 0.5 - floorclip + player.mo.AttackZOffset * player.crouchFactor;
		playerz -= 6;
		
		//get the pitch and adjust the forward offset if looking up/down
		//cos(pitch) < 1.0, and get closer to 0 when looking up/down, ig sin(pitch) ** 2 could also work (yes,this time the calculator wasnt in radians :D)
		double pt = cos(pitch);
		if(pt < 1.0)
		{
			if(pt < 0.1) //if pt is lower than 0.1, set it as 0.1, so it doesnt spawn at player feets
				pt = 0.1;
			fw *= (pt*pt);
		}
		
		double pit = pitch;
		for(int i = 0; i < LIGHTSHOCK_TARGET; i++)
		{
			flinetracedata t;
			//randomize the beam direction
			double actpitch = pit + frandom(-10,10);
			double actangle = angle + frandom(-10,10);
			
			bool shouldEnd;	//indicates this beam should stop, since it either hit geometry or hit an actor or went too far
			int maxdistTravel = 450; //9 segments if it goes the full path
			bool isFirst = true;
			vector3 cursp = (pos.xy + fw.xy,pos.z + playerz);
			
			vector2 prevangles = (actangle,actpitch);
			vector3 hitloc;
			actor from;		//pointer to the last dummy puff, used to fire linetraces
			int safety = 0;	//just in case, we dont want infinite loops
			bool landed;	
			
			//fire the linetraces
			while(!shouldEnd)
			{
				bool avoid = false;
				if(safety > 12)	//normally no iteration should go this far, but just in case
				{
					shouldend = true;
					break;
				}
				
				if(isFirst)	//fire the trace from the player
				{
					linetrace(actangle,LIGHTSHOCK_RANGE,actpitch,0,playerz,1,0,t);
					isFirst = false;
					avoid = true;
				}
				else		//fire the trace from the dummy puff
				{
					if(!from)
					{
						shouldend = true;
						break;
						return;
					}
					from.linetrace(prevangles.x,LIGHTSHOCK_RANGE,prevangles.y,0,1,-1,0,t);
					
				}
				
				//substract the traveled distance
				maxdistTravel -= t.distance;
				
				//indicates the beam hit geometry
				if(t.hittype == TRACE_HitFloor ||
				t.hittype == TRACE_HitCeiling  ||
				t.hittype == TRACE_HitWall )
				{
					shouldEnd = true;
					landed = true;
				}
				
				//hit an actor
				if(t.hitactor != null)
				{
					t.hitactor.TriggerPainChance("Stun", true);
					if(from)
						t.hitactor.damagemobj(from,self,LIGHTSHOCK_DAMAGE,'plasma');
					else
						t.hitactor.damagemobj(self,self,LIGHTSHOCK_DAMAGE,'plasma');
					shouldEnd = true;
				}
				
				//check the distance left to travel
				if(maxdistTravel <= 0)
					shouldEnd = true;
				
				if(!avoid)	//skip the first beam
					Tesla_DrawBeam(cursp,t.hitlocation - t.hitdir,prevangles);
					
				safety++;
				//update variables
				cursp = t.hitlocation - t.hitdir;
				prevangles += (frandom(-15,15),frandom(15,-15));	//randomize the next beam direction
				hitloc = t.hitlocation - t.hitdir;
				from = spawn("PBX_TeslaPosPuff",cursp);		//spawn a dummy puff
				
			}
			//vector3 ds = levellocals.vec3diff(pos + (0,0,playerz),hitloc);
			//double di = ds.length();
			//console.printf("");
			//console.printf("hit %d took %d interations (maxdist: %d, traveled: %f)",i,ite,maxdisttravel,di);
			if(landed)
			{
				actor spk = spawn("PBX_EndFx",hitloc);
				if(spk)
					spk.A_Startsound("Tesla/Sparks");
					spk.A_startsound("Tesla/FireAdd",CHAN_AUTO, CHANF_OVERLAP, 1);
			}
			
		}
		
		PB_QuakeCamera(4, 1);
		PB_WeaponRecoil(-0.1, frandom(-0.2,0.2));
	}
	
	action void Tesla_FireShock()
	{
		blockthingsiterator bti = blockthingsiterator.create(self,500);
		array<PBX_LightningTarget> vic;
		int maxbeams = LIGHTSHOCK_TARGET;
		
		while(bti.next())
		{
			actor mo = bti.thing;
			double an = deltaangle(angle,angleto(mo));
			
			if(mo && mo.bismonster && mo.health > 0 && maxbeams > 0
			&& abs(an) < 45 && distance3d(mo) <= 450 && checksight(mo))
			{
				vic.push(
				PBX_LightningTarget.addnew(mo,mo.pos + (0,0,mo.height * 0.5),angleto(mo),pitchto(mo),distance3d(mo))
				);
				maxbeams--;
			}
		}
		
		Tesla_FireBeam();
		
		if(vic.size() <= 0)
			return;
		
		vector3 fw = (cos(angle),sin(angle),0);
		int playerz = height * 0.5 - floorclip + player.mo.AttackZOffset * player.crouchFactor;
		playerz -= 6;
	
		//get the pitch and adjust the forward offset if looking up/down
		//cos(pitch) < 1.0, and get closer to 0 when looking up/down, ig sin(pitch) ** 2 could also work (yes,this time the calculator wasnt in radians :D)
		double pt = cos(pitch);
		if(pt < 1.0)
		{
			if(pt < 0.1) //if pt is lower than 0.1, set it as 0.1, so it doesnt spawn at player feets
				pt = 0.1;
			fw *= (pt*pt);
		}
		
		for(int i = 0; i < vic.size(); i++)
		{
			if(!vic[i])
				continue;
			flinetracedata t;
			//randomize the initial beam direction
			double actpitch = pitch + frandom(-7,12);
			double actangle = angle + frandom(-12,12);
			bool isFirst = true;
			int safety = 0;
			vector3 cursp = (pos.xy + fw.xy,pos.z + playerz);
			double disttravel = vic[i].dist;
			int its = vic[i].dist / LIGHTSHOCK_RANGE;
			its = max(1,its);
			vector2 prevangles = (actangle,actpitch);
			vector3 hitloc;
			bool landed;	
			bool shouldend;
			actor from;

			bool setted;
			
			while(!shouldend)
			{
				bool avoid = false;
				if(safety > 14)	//normally no iteration should go this far, but just in case
				{
					shouldend = true;
					break;
				}
				
				if(isFirst)	//fire the trace from the player
				{
					linetrace(actangle,LIGHTSHOCK_RANGE,actpitch,0,playerz,1,0,t);
					isFirst = false;
					avoid = true;
				}
				else		//fire the trace from the dummy puff
				{
					if(!from)
					{
						shouldend = true;
						break;
						return;
					}
					from.linetrace(prevangles.x,
					max(disttravel < LIGHTSHOCK_RANGE ? disttravel : LIGHTSHOCK_RANGE,0)
					,prevangles.y,0,1,-1,0,t);
					
				}
				
				disttravel -= t.distance;
				
				if(disttravel <= 0)
				{
					shouldend = true;
					break;
				}
				safety++;
				if(!avoid)
					Tesla_DrawBeam(cursp,t.hitlocation - t.hitdir,prevangles);
				//update variables
				cursp = t.hitlocation - t.hitdir;
				//prevangles += (frandom(-7,7),frandom(5,-3));	//randomize the next beam direction
				if(safety < 2)
					prevangles += (frandom(-7,7),frandom(5,-3));
				else
				{
					if(!setted && vic[i] && vic[i].targ)
					{
						if(!from)
							from = spawn("PBX_TeslaPosPuff",cursp);
						//idk why i overcomplicated too much with this
						/*vector3 diffr = levellocals.vec3diff(from.pos,vic[i].tpos);
						vector3 dir = diffr.unit();
						double angh = atan2(dir.y,dir.x);
						double angv = atan(-dir.z/dir.x);*/
						double angh = from.angleto(vic[i].targ);
						double angv = from.pitchto(vic[i].targ);
						prevangles = (angh,angv);
						setted = true;
					}
					else
						prevangles += (frandom(-1.0,1.0),frandom(1.0,-1.0));
					
				}
				
				hitloc = t.hitlocation - t.hitdir;
				from = spawn("PBX_TeslaPosPuff",cursp);		//spawn a dummy puff
				from.angle = prevangles.x;
				from.pitch = prevangles.y;
			}
			
			if(landed)
			{
				actor spk = spawn("PBX_EndFx",hitloc);
				if(spk)
					spk.A_Startsound("Tesla/Sparks");
			}
			
			if(vic[i] && vic[i].targ)
			{
				vic[i].targ.TriggerPainChance("Stun", true);
				if(from)
					vic[i].targ.damagemobj(from,self,LIGHTSHOCK_DAMAGE,'plasma',DMG_USEANGLE,from.angleto(vic[i].targ));
				else
					vic[i].targ.damagemobj(self,self,LIGHTSHOCK_DAMAGE,'plasma',DMG_USEANGLE,self.angleto(vic[i].targ));
			}
		}
		PB_QuakeCamera(4, 1);
		PB_WeaponRecoil(-0.1, frandom(-0.2,0.2));
	}

	action void Tesla_DrawBeam(vector3 cur, vector3 next,vector2 angles, bool islong = false)
	{
		actor beam;
		cur.z -= 5;
		
		vector3 diff = levellocals.vec3diff(cur,next);
		double dist = diff.length();
		
		beam = spawn("PBX_Tesla_Beam",cur);
		if(beam)
		{
			beam.angle = angles.x;
			beam.pitch = (angles.y - 90);
			beam.scale.y = (dist + 5);
			if(islong)
				beam.setstatelabel("LongSpawn");
		}
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
            Tesla_FireShock();
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