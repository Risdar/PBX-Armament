class DecorativeTracer : FastProjectile
{
	default
	{
		-DONTSPLASH;
		Projectile;
		+RANDOMIZE;
		+FORCEXYBILLBOARD;
		+DONTSPLASH;
		//+BLOODSPLATTER 
		+NOEXTREMEDEATH;
		damage 0;
		radius 2;
		height 2;
		speed 140;
		renderstyle "ADD";
		alpha 0.9;
		scale .15;
	}

	states
	{
		Spawn:
			TNT1 A 0 A_JumpIf(GetCvar("PB_TracerLight") >=1,"Spawn2");
		Spawn1:
			TRAC A 1 BRIGHT;
			Loop;
		Spawn2:
			TRAC A 1 BRIGHT Light("TracerLight");
			Loop;
		Death:
			TNT1 A 0;
			Stop;
		XDeath:
			TNT1 A 0;
			Stop;
	}
}

class BR45BulletPuff: PB_BulletPuff
{
	default
	{
		DamageType "Pistol";
		renderstyle "Translucent";
		alpha 0.4;
		Scale 1.5;
		radius 0;
		height 0;
		+NOBLOCKMAP;
		+NOGRAVITY;
		Gravity 0.01;
		+NOEXTREMEDEATH;
		+FORCEXYBILLBOARD;
		+THRUACTORS;
		+NOCLIP;
		Decal "BulletDecalNew1";
		+DONTSPLASH;
		-EXPLODEONWATER;
	}
}

class RifleClipSpawn : actor
{
	Default
	{
		Speed 18;
		PROJECTILE;
		+NOCLIP;
		+CLIENTSIDEONLY;
	}
	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 A 1 A_CustomMissile("EmptyRifleClip",6,-3,random(-80,-100),2,random(20,45));
			Stop;
	}
}

class EmptyRifleClip: BaseMagActor
{
	Default
	{
		BounceFactor 0.6;
		Scale 0.2;
		SeeSound "null";
		DeathSound "BR45BOUNCE";
		BounceSound "BR45BOUNCE";
		WallBounceSound "BR45BOUNCE";
		bouncetype "doom";
		+thruactors;
	}

   	States
   	{
		Spawn:
			//TNT1 A 7 A_PlaySound("NULL")
			TNT1 A 0;
			TNT1 A 0 A_playsound("BR45PING");
			ECLI I 4 ;
			ECLI IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 4 A_SetRoll(roll+45,SPF_INTERPOLATE);
			Stop;
		Death:
			TNT1 A 0;
			TNT1 A 0 A_Jump(128,2);
			TNT1 A 0 A_ChangeFlag("XFLIP",1);
			TNT1 A 0;
			TNT1 A 0;
			TNT1 A 0 A_SetRoll(0);
			C4S3 I 0
			{
					bnointeraction = true;
					A_changelinkflags(true);
			}
			
			stay1:
			ECLI J 400;
			Goto Fadeout;
	}
}

class BaseMagActor : actor
{
	Default
	{
		bouncetype "Doom";
		- NOGRAVITY;
		+WINDTHRUST;
		+CLIENTSIDEONLY;
		+MOVEWITHSECTOR;
		+MISSILE;
		+NOBLOCKMAP;
		-DROPOFF;
		+NOTELEPORT;
		+FORCEXYBILLBOARD;
		+NOTDMATCH;
		+GHOST;
		+ROLLSPRITE;
		+ROLLCENTER;
		Height 2;
		Radius 2;
		Speed 4;
		Mass 1;
		SeeSound "weapons/largemagdrop";
		DeathSound "weapons/largemagdrop";
		BounceSound "weapons/largemagdrop";
	}

	States
	{
		Spawn:
			TNT1 A 0;
			stop;
		Death:
			"####" "#" 0;
			"####" "#" 0 A_SetRoll(0);
			"####" "#" 350;
		Fadeout:
		"####" "#" 1 A_fadeout(0.02);
		LOOP;
	}
}
