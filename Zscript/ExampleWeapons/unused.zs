// Code that I think could be useful but unused
// and I dont know where else to put them lol

    vector3 targetpos = lasersight.HitLocation;
    switch (lasersight.HitType)
    {
    	case TRACE_HitWall:
    	{
    		vector2 wallnormal = (-lasersight.HitLine.delta.y, lasersight.HitLine.delta.x).unit();
    		if (!lasersight.LineSide) wallnormal *= -1;
    		targetpos += (wallnormal.x, wallnormal.y, 0) * 2;
    		break;
    	}
    	case TRACE_HitFloor:
    		targetpos.z += 2;
    		break;
    	case TRACE_HitCeiling:
    		targetpos.z -= 2;
    		break;
    	case TRACE_HitActor:
    		// push back along trace direction so it sits on the actor surface
    		vector3 traceDir = (cos(pitch) * cos(angle), cos(pitch) * sin(angle), -sin(pitch));
    		targetpos -= traceDir * 2;
    		break;
    }

    // Replace the DMR if the replace cvar is enabled
    override void AttachToOwner(Actor other)
    {
        Super.AttachToOwner(other);
        if (level.MapName ~== "TITLEMAP") return;       // If its the titlemap, return
        if(!PBX_Weapons_startwithnormalrifle) return;      // If the CVAR is disabled, return
        if(owner.findinventory("DMRUpgraded")) return;  // If the player has the HDMR, return (though this is probably not needed since this function is only called once)

        // Force switch
        owner.TakeInventory("PB_DMR",1);
        if (Owner.player != null) Owner.player.PendingWeapon = self;
    }
    // Give the player ammo instead of picking up the weapon if the replace cvar is enabled
    override bool HandlePickup(Inventory item)
    {
        bool hasUpgrade = owner.findinventory("DMRUpgraded");
        bool isTitlemap = level.MapName ~== "TITLEMAP";

        // This is so you dont need to pick up the upgrade twice
        if (item is "PB_HDMRUpgrade")
        {
            console.printf("success");
            owner.GiveInventory("PB_DMR",1);
            owner.GiveInventory("DMRUpgraded",1);
            return super.HandlePickup(item);
        }

    	if (item.GetClassName() == "PB_DMR" 
            && !isTitlemap                              // If its the titlemap, return
            && PBX_Weapons_startwithnormalrifle            // If the CVAR is disabled, return
            && !hasUpgrade)                             // If the player has the HDMR, return
    	{
    		item.bPickupgood = true;
    		owner.GiveInventory("PB_HighCalMag", 15); // Give the replacement
    		return true; // Do not process Fist further
    	}
    	return super.HandlePickup(item);
    }

    //shells:
	// 0-buckshot 1-slug 2-flechette
	// 3-flak 4-dragon breath
	// 5-explosive 6-white phosphorous 7-Doom shells
	// 8-danmaku 9-subzero
	
	//to cycle shells ->
	Action Void CycleShellFw()
	{
		//cycle to the right
		int actmod = invoker.shellsmode;
		invoker.oldshells = actmod;
		A_startsound("menu/change",CHAN_AUTO);
		actmod++;
		
	// 	//dont need extra checks there
		if(actmod < 4)
		{
			invoker.shellsmode = actmod;
			//PrintCurrentShell();
			return;
		}
		
	// 	//this is kinda weird, the idea is, if you DONT have the upgrade, add another, so it jumps to the next shell type
	// 	//if you dont have any upgrade, just go back to 0, wich means buckshot
	// 	//if got dragon breat upgrade
		if(countinv("DragonBreathUpgrade")<1 && actmod == 4)
			actmod++;
		//if got Explosive upgrade
		if(countinv("ExplosiveUpgrade")<1 && actmod == 5)
			actmod++;
		//if got White phosphoruos upgrade (dragon breath 2: this time its personal)
		if(countinv("WhitePhosphorusUpgrade")<1 && actmod == 6)
			actmod++;
		if(countinv("TripleDoomUpgrade")<1 && actmod == 7)
			actmod++;
		if(countinv("DanmakuUpgrade")<1 && actmod == 8)
			actmod++;
			
		if(actmod > 8)
			actmod = 0;
		
		//clamps, so it never goes out from the types allowed
		actmod = clamp(actmod,0,8);
		invoker.shellsmode = actmod;
		//PrintCurrentShell();
		return;
	// }
	
	// //to cycle shells <-
	Action Void CycleShellBack()
	{
		//idk why it was harder to do the back cycling than the forward one
		//console.printf("cicling back.");
		int actmod = invoker.shellsmode;
		invoker.oldshells = actmod;
		A_startsound("menu/change",CHAN_AUTO);
		
		actmod--;
		
		if(actmod < 0)
			actmod = 8;
			
		if(actmod < 4)
		{
			invoker.shellsmode = actmod;
			//PrintCurrentShell();
			return;
		}
		
	// 	//the same as the other functions but the other way around, decrements if you dont have that specific upgrade
		if(countinv("DanmakuUpgrade")<1 && actmod == 8)
			actmod--;
		if(countinv("TripleDoomUpgrade")<1 && actmod == 7)
			actmod--;
		if(countinv("WhitePhosphorusUpgrade")<1 && actmod == 6)
			actmod--;
		if(countinv("ExplosiveUpgrade")<1 && actmod == 5)
			actmod--;
		if(countinv("DragonBreathUpgrade")<1 && actmod == 4)
			actmod--;
		
		actmod = clamp(actmod,0,8);
		invoker.shellsmode = actmod;
		//PrintCurrentShell();
		
	}

    // This is from Return to Brutal Wolfenstein (https://github.com/jaih1r0/Return_to_Brutal_Wolfenstein)
	action void M2_FireBeam(int dmg = 45, int max = 5)
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
		
		//double pit = clamp(pitch,-4,30); //clamp the pitch, so the beams always go forward, like the rtcw tesla gun
		
		double pit = pitch;
		//we'll fire 5 beams
		for(int i = 0; i < max; i++)
		{
			flinetracedata t;
			//randomize the beam direction
			double actpitch = pit + frandom(-4,10);
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
					linetrace(actangle,LIGHTNING_BEAM_DISTANCE,actpitch,0,playerz,1,0,t);
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
					from.linetrace(prevangles.x,LIGHTNING_BEAM_DISTANCE,prevangles.y,0,1,-1,0,t);
					
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
					if(from)
					{
						t.hitactor.damagemobj(from,self,35,'Electric');
					}
					else
					{
						t.hitactor.damagemobj(self,self,35,'Electric');
					}
					t.hitactor.TriggerPainChance("Stun", true);
					shouldEnd = true;
				}
				
				//check the distance left to travel
				if(maxdistTravel <= 0)
					shouldEnd = true;
				
				if(!avoid)	//skip the first beam
					M2_DrawBeam(cursp,t.hitlocation - t.hitdir,prevangles);
					
				safety++;
				//update variables
				cursp = t.hitlocation - t.hitdir;
				prevangles += (frandom(-15,15),frandom(15,-3));	//randomize the next beam direction
				hitloc = t.hitlocation - t.hitdir;
				from = spawn("TeslaPosPuff",cursp);		//spawn a dummy puff
				
			}
			//vector3 ds = levellocals.vec3diff(pos + (0,0,playerz),hitloc);
			//double di = ds.length();
			//console.printf("");
			//console.printf("hit %d took %d interations (maxdist: %d, traveled: %f)",i,ite,maxdisttravel,di);
			if(landed)
			{
				actor spk = spawn("EndFx",hitloc);
				if(spk)
					spk.A_Startsound("Tesla/Sparks");
					spk.A_startsound("Tesla/FireAdd",CHAN_AUTO, CHANF_OVERLAP, 1);
			}
			
		}
		
		PB_QuakeCamera(4, 1);
		PB_WeaponRecoilBasic(-0.1, frandom(-0.2,0.2));
		A_startsound("Tesla/Fire",32);
		A_startsound("Tesla/FireAdd",CHAN_AUTO, CHANF_OVERLAP, 1);
		A_SpawnItemEx("PlayerMuzzleFlash_Blue",30,0,45);
		// if(invoker.ammo2.amount)
		// 	invoker.ammo2.amount--;
	}
	
	action void M2_FireRail()
	{
		double rad = radius;
		vector3 fw = (cos(angle) * rad,sin(angle) * rad,0);	//offset the spawn pos forward by radius of the player, so it doesnt spawn inside the player
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
		
		//quats works fine for the first beam, but the next ones will be misplaced for some reason
		/*quat base = quat.fromangles(angle,pitch,roll);
		vector3 ofs = base * (10,0,-5);
		vector3 spawnpos = levellocals.vec3offset((pos.xy,player.viewz),ofs);
		int playerz = spawnpos.z;*/
		
		//double pit = clamp(pitch,-4,30); //clamp the pitch, so the beams always go forward, like the rtcw tesla gun
		
		double pit = pitch;
		
		flinetracedata t;
		//randomize the beam direction
		double actpitch = pit;
		double actangle = angle;
		
		bool shouldEnd;	//indicates this beam should stop, since it either hit geometry or hit an actor or went too far
		int maxdistTravel = 2000; //9 segments if it goes the full path
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
				linetrace(actangle,radius*2,actpitch,0,playerz,1,0,t);
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
				from.linetrace(prevangles.x,max(maxdistTravel < LIGHTNING_RAIL_DISTANCE ? maxdistTravel : LIGHTNING_RAIL_DISTANCE,0),prevangles.y,0,1,-1,0,t);
				
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
			if(t.hitactor != null && t.hitactor != self)
			{
				if(from)
				{
					t.hitactor.damagemobj(from,self,100,'Electric');
				}
				else
				{
					t.hitactor.damagemobj(self,self,100,'Electric');
				}
				t.hitactor.TriggerPainChance("Stun", true);
				shouldEnd = true;
				landed = true;
			}
			
			//check the distance left to travel
			if(maxdistTravel <= 0)
				shouldEnd = true;
			vector3 zofs = (0,0,7 * sin(-prevangles.y));
			/*if(avoid)	//first beam
				M2_DrawBeam(cursp + zofs,t.hitlocation - t.hitdir,prevangles,true);
			else	//the next beams needs this little offset to look correct
			{
				M2_DrawBeam(cursp + zofs,t.hitlocation - t.hitdir,prevangles,true);
			}*/
			
			if(!avoid)
				M2_DrawBeam(cursp + zofs,t.hitlocation - t.hitdir,prevangles,true);
			
			safety++;
			//update variables
			cursp = t.hitlocation - t.hitdir;
			//prevangles += (frandom(-7,7),frandom(5,-3));	//randomize the next beam direction
			prevangles += (frandom(-7,7),frandom(5,-3));
			hitloc = t.hitlocation - t.hitdir;
			from = spawn("TeslaPosPuff",cursp);		//spawn a dummy puff
			
		}

		if(landed)
		{
			actor spk = spawn("EndFx",hitloc);
			if(spk)
				spk.A_Startsound("Tesla/Sparks");
			spawn("TeslaSparkbig",hitloc);
		}
			
		if(from)
		{
			blockthingsiterator bti = blockthingsiterator.create(from,300);
			actor mo;
			while(bti.next())
			{
				mo = bti.thing;
				if(mo && (mo.bismonster || mo.bshootable) && 
				mo != self && from.checksight(mo))
				{
					mo.damagemobj(from,self,50,'electric',DMG_USEANGLE,from.angleto(mo));
					mo.TriggerPainChance("Stun", true);
				}
			}
		}
			
		A_SpawnItemEx("PlayerMuzzleFlash_Blue",30,0,45);
		PB_QuakeCamera(6, 2);
		PB_WeaponRecoilBasic(-3, frandom(-0.75,0.75));
		A_startsound("Tesla/Fire",32);
		// if(invoker.ammo2.amount)
		// 	invoker.ammo2.amount -= 5;
	}
	
	action void M2_FireSeekerLight()
	{
		blockthingsiterator bti = blockthingsiterator.create(self,500);
		array<PBX_LightningTarget> vic;
		int maxbeams = random(2,4);
		
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
		
		int maxranbeams = 6 - maxbeams;
		M2_FireBeam(maxranbeams);
		
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
			int its = vic[i].dist / LIGHTNING_BEAM_DISTANCE;
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
					linetrace(actangle,LIGHTNING_BEAM_DISTANCE,actpitch,0,playerz,1,0,t);
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
					max(disttravel < LIGHTNING_BEAM_DISTANCE ? disttravel : LIGHTNING_BEAM_DISTANCE,0)
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
					M2_DrawBeam(cursp,t.hitlocation - t.hitdir,prevangles);
				//update variables
				cursp = t.hitlocation - t.hitdir;
				//prevangles += (frandom(-7,7),frandom(5,-3));	//randomize the next beam direction
				if(safety < 2)
					prevangles += (frandom(-7,7),frandom(5,-3));
				else
				{
					if(!setted)
					{
						if(!from)
							from = spawn("TeslaPosPuff",cursp);
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
				from = spawn("TeslaPosPuff",cursp);		//spawn a dummy puff
				from.angle = prevangles.x;
				from.pitch = prevangles.y;
			}
			
			if(landed)
			{
				actor spk = spawn("EndFx",hitloc);
				if(spk)
					spk.A_Startsound("Tesla/Sparks");
			}
			
			if(vic[i] && vic[i].targ)
			{
				if(from)
				{
					vic[i].targ.damagemobj(from,self,35,'electric',DMG_USEANGLE,from.angleto(vic[i].targ));
				}
				else
				{
					vic[i].targ.damagemobj(self,self,35,'electric',DMG_USEANGLE,self.angleto(vic[i].targ));
				}
				vic[i].targ.TriggerPainChance("Stun", true);
			}
		}
		
		
		A_SpawnItemEx("PlayerMuzzleFlash_Blue",30,0,45);
		PB_QuakeCamera(4, 1);
		PB_WeaponRecoilBasic(-0.1, frandom(-0.2,0.2));
		A_startsound("Tesla/Fire",32);
		A_startsound("Tesla/AltAdd",CHAN_AUTO, CHANF_OVERLAP, 1);
		// if(invoker.ammo2.amount)
		// 	invoker.ammo2.amount--;
	}

	action void M2_DrawBeam(vector3 cur, vector3 next,vector2 angles, bool islong = false)
	{
		actor beam;
		cur.z -= 5;
		
		vector3 diff = levellocals.vec3diff(cur,next);
		double dist = diff.length();
		
		beam = spawn("Tesla_Beam",cur);
		if(beam)
		{
			beam.angle = angles.x;
			beam.pitch = (angles.y - 90);
			beam.scale.y = (dist + 5);
			if(islong)
				beam.setstatelabel("LongSpawn");
		}
	}