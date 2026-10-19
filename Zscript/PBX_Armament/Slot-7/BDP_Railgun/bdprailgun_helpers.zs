class BDP_GunLight : DynamicLight 
{
	default 
	{
		DynamicLight.Type "Point";
		+DYNAMICLIGHT.ATTENUATE;
		+DYNAMICLIGHT.SPOT
		self.alivetime 2;
	}

	int alivetime; 
	property alivetime : alivetime;

	override void Tick() 
	{
		super.Tick();
		alivetime--;
		If(alivetime <= 0) Destroy();
	}
}

class BluePlasmaParticleWeapon : actor
{
	Default
	{
		Height 0;
		Radius 0;
		Mass 0;
		+Missile;
		+NoBlockMap;
		-NoGravity;
		+DontSplash;
		BounceType "Doom";
		+FORCEXYBILLBOARD;
		RenderStyle "Add";
		BounceFactor 0.2;
		Gravity 0.8;
		Scale 0.02;
		Speed 9;
	}

	States
	{
		Spawn:
		Death:
			SPKB A 2 Bright A_FadeOut(0.04);
			Loop;
	}
}

class SpentRailgunShell : BaseMagActor
{
	Default
	{
		Scale 0.2;
		+STRETCHPIXELS
		BounceFactor 0.7;
	}
	
	States
	{
		Spawn:
			RCLI A 0;
			Goto Fly;
		Fly:
			#### # 1 A_SetRoll(roll+11.25);
			Loop;
		Death:
			RCLI A 350
			{
				if(random(0, 1) == 1)
				{
					A_ChangeFlag("XFLIP",1);
					A_SetRoll(90);
				}
				else
				{
					A_SetRoll(-90);
				}
			}
			Goto FadeOut;
	}
}

class PBX_Hologram : PB_Monster
{
	Default
	{
		+SHOOTABLE
		+NOBLOODDECALS
		+BRIGHT
		+FRIENDLY
		+DONTTHRUST
		Renderstyle "Translucent";
		Alpha 0.75;
		Radius 16;
		Height 56;
		Health 100;
		MaxStepHeight 666;
		BloodType "HoloBlood";
	}

	int mLifetime;
	
	Vector3 targetPos;

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		mLifetime = PBX_RailgunHologram_Lifetime;
	}
	
	override void Tick()
	{
		if (!tracer || findinventory("KillHologram") || mLifetime <= 0)
			A_FadeOut(0.05);

		if(mLifeTime > 0 && level.time % TICRATE == 0)
			mLifeTime--;
			
		Super.Tick();
	}
	
	action void A_HologramAlert()
	{
		BlockThingsIterator checkForTracers = BlockThingsIterator.Create(self, 1000); //256 can be whatever range around the actor.
		Actor currentActor;
		while(checkForTracers.Next())
		{
			currentActor = checkForTracers.Thing;
			
			//If the actor is a monster, has none of the specified item, the caller has a line of sight to the actor, and the actor is within 512 MU, then jump to the see state.
			//Itemname obviously has to be whatever item you want the actor to check that the possible target has none of, and the 512 map unit sight range can be changed to anything else.
			if(currentActor &&
			currentActor.bISMONSTER &&
			!currentActor.bFRIENDLY &&
			currentActor.health > 0 &&
			currentActor.target &&
			currentActor.target is "PlayerPawn" &&
			CheckSight(currentActor, SF_IGNOREWATERBOUNDARY))
			{
				currentActor.target = self;
			}
		}
		A_AlertMonsters(0, AMF_TARGETEMITTER);
	}
	
	States
	{
		Spawn:
			MARN AAABBBCCCBBB 1 {
				FCheckPosition movecheck;
				bool couldMove = CheckMove(Vec2Angle(6, angle), PCM_NOACTORS, movecheck);
				vector3 movepos = Vec3Angle(6, angle, 0);
				if(couldMove)
				{
					SetOrigin(movepos, TRUE);
				}
				else
				{
					Vector3 oldpos = pos;
					SetOrigin((pos.xy, movecheck.floorz), false);
					couldMove = CheckMove(Vec2Angle(6, angle), PCM_NOACTORS, movecheck);
					if(couldMove)
					{
						SetOrigin(oldpos, false);
						SetOrigin(movepos, TRUE);
					}
				}
				A_HologramAlert();
				double distance = (targetPos.xy - pos.xy).Length();
				if(distance <= 32 || !couldMove)
				{
					return findstate("Spawn2");
				}
				return findstate(null);
			}
			Loop;
		Spawn2:
			TNT1 A 0 A_Jump(30, "Twerk","TeaBag", "Moves1", "Moves2", "Moves3", "TPose");
			TNT1 A 0 A_Jump(255, "Wave1", "Wave2", "Observe", "Medkit");
		Wave1:
			MWAV IJK 1;
		Wave1Continue:
			MWAV LMNNML 3 A_HologramAlert();
			Loop;
		Wave2:
			MWAV ABCD 3;
		Wave2Continue:
			MWAV EEEEEEEFFFFFFF 1 A_HologramAlert();
			Loop;
		Observe:
			MR7S AAAAABBBBBACCCCCABBBBBAA 4 A_HologramAlert();
			Loop;
		MedKit:
			MR8S AAAAAAABBBBBBB 2 A_HologramAlert();
			Loop;
		TeaBag:
			MARN AA 2 A_HologramAlert();
			PLYC AA 2 A_HologramAlert();
			Loop;
		Twerk:
			TWRK CBA 2 A_HologramAlert();
			Loop;
		Moves1:
			2AKE ABCDEFGHIJKLMOPQR 4 A_HologramAlert();
			Loop;
		Moves2:
			3AKE ABCDEFGHIJKLMNO 4 A_HologramAlert();
			Loop;
		Moves3:
			JAKE ABCDEFGHIJKLMNOP 4 A_HologramAlert();
			Loop;
		TPose:
			TWRK D 4 A_HologramAlert();
			Loop;
		Death:
			PLAY O 5;
			PLAY P 5 A_XScream();
			PLAY Q 5;
			PLAY RSTUV 5;
			PLAY W 1 A_fadeout(0.05);
			Wait;
	}
}

class HoloBlood : Actor
{
	Default
	{
		+nogravity;
		+noblockmap;
	}
	States
	{
		Spawn:
			TNT1 AAA 0 NODELAY {
				A_spawnitemex("blueplasmaparticle",0,0,0,frandom(-5,5),frandom(-5,5),frandom(1,5));
				A_startsound("StickyGrenade/hit");
			}
			STOP;
	}
}

