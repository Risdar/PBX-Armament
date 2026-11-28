// Nov 9, 2025: Yes this has notes everywhere now
// 				and also shortened greatly because I forgot common sense exists

// class ClassName : EventHandler
// uses WorldThingDied so it fires every time an actor dies, yes even projectiles

class PBX_HelmetDropHandler : EventHandler
{
	static const String specialActors[] = { 
		"pb_pyrosergeant",
		"pb_qsgzombie",
		"pb_pistolzombieman2",
		"pb_riotshieldguy",
		
		//GK Compat
		"pb_pyrosergeantgk",
		"pb_qsgzombiegk",
		"pb_pistolzombieman2gk",
		"pb_riotshieldguygk"
	};
	
	// This is the function that finds a pattern in a string with no case sensitivity
	bool hasString( String s, String pattern )
    {
		if ( s.Length() < pattern.Length() )
		{ // if the string is shorter than the pattern, false
			return false;
		}
		else
		{
			// tries to find the index of the lowered pattern in the lowered string
			// if not -1 (no matches) then true, false otherwise
			return s.IndexOf(pattern) != -1;
		}
		
		return false; // Placeholder
	}
	
	bool stringStartsWith(String s, String pattern)
    {
		// Counting from the left of the string, if it matches the pattern then true
		return s.Left(pattern.Length()) == pattern;
	}
	
	override void WorldThingDied(WorldEvent e)
	{
		if (!e || !e.thing) return;
		// in this case "thing" is the actor that died
		let actor = e.thing;
		
		// if the actor isn't a monster, stop
		if (!actor.bISMONSTER) return;
		
        // if helmet drops is disabled, stop
        if(!PBX_CVAR_HELMETDROPS) return;

		// Specifies the pattern
		String targetStr	= "helmet";
		
		// Specifies the alias/prefix
		String actorAlias	= "pb_";
		
		// Gets actor's class name
		String thingClass	= actor.GetClassName();
		thingClass			= thingClass.MakeLower();
		// then lowers it for non case sensitive checks
		
		bool isSpecial = false;
		for ( int i = 0; i < specialActors.Size(); i++ )
		{
			if(specialActors[i] == thingClass){
				isSpecial = true;
				break;
			}
		}
		
		// If it's not a special case [and] their name didn't start with the specified alias, stop
		if (!isSpecial && !stringStartsWith( thingClass, actorAlias )) return;
		
		bool hasHelmet = isSpecial; // Special case
		hasHelmet = hasHelmet || hasString( thingClass, targetStr );
		// [or] if it has the pattern string in its name
		
		// If none of the conditions above were met, stop
		if ( !hasHelmet ) return;
		
		// Gets actor's position
		vector3 pos = actor.pos;
		
		// Left - Right velocity
		double xvel = random(-8, 8); 
		
		// Back - Forth velocity
		double yvel = random(-8, 8);
		
		// Up - Down velocity
		double zvel = random(5, 10); 
		
		// Spawn a PBX_DroppedHelmet at the actor's position and get a pointer to it
		let helm = Actor.Spawn ( 
			"PBX_DroppedHelmet", // actor name
			(pos.X, pos.Y, pos.Z + actor.Default.Height * 0.9) // vector3
			// ( x, y, z + 90% of actor;s height )
		);
		
		// If it failed to spawn, stop
		if ( !helm ) return;
		
		// randomize the helmet's angle
		helm.angle = random(0, 359);
		
		// sets velocity
		helm.vel = (xvel, yvel, zvel); // again, a vector3
		
		// (Optional) Addition, colors the helmet RED if it was a Commando that died
		if ( hasString(thingClass, "commando") || hasString(thingClass, "chaingun") )
		{
			helm.A_SetTranslation("CommandoHelm");
		}

	}
}

Class PBX_DroppedHelmet : Actor
{
    int mRollLeft;

    Default
    {
        Projectile;
        +FRIENDLY
        +ROLLSPRITE
        +ROLLCENTER
        +THRUACTORS
        +BOUNCEONWALLS
        +BOUNCEONCEILINGS
        +BOUNCEONACTORS
        +BOUNCEONFLOORS
        +FORCEXYBILLBOARD
        +USEBOUNCESTATE
        -NOGRAVITY
        +CANBOUNCEWATER
        Speed 1;
        Radius 19;
        Height 15;
        BounceType "Doom";
        BounceCount 4;
        BounceFactor 0.5;
        Gravity 1.0;
        Scale 0.415;
    }

    States
    {
        Spawn:
            3BON A 0 NoDelay { A_SetRoll(frandom(0, 360)); }
            3BON A 0 { mRollLeft = random(0, 1) == 0 ? 1 : 0; }
            3BON A 0 A_JumpIf(random(0, 1) == 0, "Idle");
            3BON A 0 { A_SetScale(-scale.x, scale.y); }
        Idle:
            3BON A 0 { bTHRUACTORS = false; }
        Bounce:
            3BON A 0 A_StartSound("misc/abonus_PickUp", CHAN_AUTO, 0, 1, ATTN_NORM, 1.35);
            3BON AAAAAAAAAAAAAAAAAAAAAAA 2 {
                if(abs(vel.y) > 0.05 || abs(vel.x) > 0.05 || vel.z != 0)
                {
                    if(mRollLeft) { A_SetRoll(roll - 5); }
                    else          { A_SetRoll(roll + 5); }
                }
            }
        Death:
            3BON A 0 {
                A_SpawnItemEx("PBX_DroppedHelmetItem", 0, 0, 0,
                    vel.x, vel.y, vel.z, angle,
                    SXF_TRANSFERTRANSLATION | SXF_ABSOLUTEANGLE | SXF_TRANSFERROLL | SXF_TRANSFERSCALE);
            }
            3BON A 0;
            Stop;
    }
}

Class PBX_DroppedHelmetItem : PB_ArmorBonusDropped
{
    Default
    {
        +ROLLSPRITE
        +ROLLCENTER
        +FORCEXYBILLBOARD
        Radius 19;
        Height 15;
        Scale 0.415;
    }

    States
    {
        Spawn:
            3BON AABBCCD 2;
            3BON D 2 A_SpawnItem("RedFlareSmall");
            3BON EE 2 A_SpawnItem("RedFlare");
            3BON D 2 A_SpawnItem("RedFlareSmall");
            3BON DCCBB 2;
            Loop;
    }
}