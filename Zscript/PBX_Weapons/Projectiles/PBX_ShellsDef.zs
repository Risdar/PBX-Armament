//////////////////////////// COMMANDER SUPER SHOTGUN ////////////////////////////////////////////////////////////////////////////////////
class ExplosiveProjectile : PB_Projectile
{
	Default
	{
		radius 3;
		height 3;
		Speed 400;
		DamageType "Explosive";
		Gravity 1;
		Scale 0.1;
		Decal "Scorch";
		SeeSound "weapons/RLL";
		Obituary "$PBX_OB_MPROCKET";
		+nogravity;
		damage 12;
		damagetype "ExplosiveImpact";
		PB_Projectile.BaseDamage 20;
		PB_Projectile.RipperCount 0;
	}
	
	States
	{
		Spawn:
			TNT1 A 1;
		Fly:
			DBAC A 1 bright Light("ROCKET") {
				if(waterlevel < 1)
					spawnFirespark(pos);
			}
			loop;
		Crash:
		XDeath:
		Death:
			TNT1 A 0;
			TNT1 A 0 {
				A_Explode(60,128,XF_HURTSOURCE|RTF_THRUSTZ, 0, 64);
				A_StopSound(105);
				A_StartSound("FAREXPL", CHAN_AUTO,CHANF_OVERLAP,0.5,0,1.1);
				A_QuakeEx (2,2,2,4,0,100,"");
				A_SpawnItemEx ("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_SpawnItemEx ("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_SpawnItemEx ("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_SpawnItemEx ("LiquidExplosionEffectSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
				A_SpawnProjectile ("ExplosionSmokeFast22", 0, 0, random (0, 360), 2, random (0, 360));
				A_Spawnprojectile ("FireworkSFXType2", 0, 0, random (0, 360), 2, random (-60, -30));
				A_SpawnProjectile ("MediumExplosionFlames", 0, 0, random (0, 360), 2, random (0, 360));
				A_SpawnProjectile ("PBExplosionparticles", 0, 0, random (0, 360), 2, random (40, 90));
				A_SpawnProjectile ("PBExplosionparticles2", 0, 0, random (0, 360), 2, random (40, 90));
				A_SpawnProjectile ("PBExplosionparticles3", 10, 0, random (0, 360), 2, random (40, 90));
			}
			TNT1 A 0 A_Jump(256, "Spawn1", "Spawn2", "Spawn3");
		Spawn1:
			X004 ABCDE 1 bright Light("EXPLOSIONFLASH");
			X004 FGHIJKLMNOPQ 1 bright;
			stop;
		Spawn2:
			X003 ABCDE 1 bright Light("EXPLOSIONFLASH");
			X003 FGHIJKLMNOPQRSTUVWXYZ 1 bright;
			stop;
		Spawn3:
			X125 ABCDE 1 bright Light("EXPLOSIONFLASH");
			X125 FGHIJKLMNOPQR 1 bright;
			Stop;
	}
	
	void spawnFirespark(vector3 position)
	{
		if(position.x == 0 || position.y == 0 || position.z == 0)
			return;
			
		FSpawnParticleParams DBSPK;
		DBSPK.Texture = TexMan.CheckForTexture("REXPA0");
		DBSPK.Color1 = "FFFFFF";//"FF8400";
		DBSPK.Style = STYLE_ADD;
		DBSPK.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		DBSPK.Vel = (frandom(-5,5),frandom(-5,5),frandom(-5,5)); 
		DBSPK.Startroll = random(0,360);
		DBSPK.RollVel = frandom(-15,15);
		DBSPK.StartAlpha = 0.85;
		//DBSPK.FadeStep = 0.1;
		DBSPK.Size = random(12,26);
		DBSPK.SizeStep = -2;
		DBSPK.Lifetime = random(4,8); 
		DBSPK.Pos = position;
		// console.printf("Projectile spawned");
		Level.SpawnParticle(DBSPK);
	}
}

Class WPhosphorusProjectile : PB_Projectile
{
	default
	{
		+FORCEXYBILLBOARD;
		+DONTSPLASH;
		damagefunction (15*frandom(2.0,3.0));
		PB_Projectile.BaseDamage 32;
		PB_Projectile.RipperCount 0;
		Decal "SmallerScorch";
		PROJECTILE;
		gravity 0.6;
		DamageType "Fire";
		PoisonDamageType "Fire";
		PoisonDamage 7;
		+ADDITIVEPOISONDURATION;
		renderstyle "add";
		radius 2;
		height 2;
		speed 200;
		alpha 0.95;
		scale 0.45;
	}
	states
	{
		Spawn:
			DBAC A 1 BRIGHT spawnflameFlare(pos);
			//TNT1 A 0 A_SpawnItemEx("ShotgunParticles", random(8,-8), random(8,-8), random(8,-8), 0, 0, 0, 0, 128, 0);
			//TNT1 A 0 A_SpawnItemEx("ExplosionParticleVerySlow", random(8,-8), random(8,-8), random(19,-19), 0, 0, 0, 0, 128, 0);
			Loop;
		/*XDeath:
		Crash:
		Death:
			TNT1 A 0 A_Explode(10,36);
			TNT1 A 1;
			TNT1 A 0 A_SpawnWPSmoke(pos);//A_spawnitem("WhitePSmokeFx");
			TNT1 A 0 A_spawnitem("WPShockWave");
			TNT1 AAAAAA 0 A_spawnitemEx("BigFlamesIG",random(-15,15),random(-15,15),random(-5,5),0,0,0,0,SXF_NOCHECKPOSITION);
			TNT1 A 0 A_SpawnItemEx ("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_startSound("FAREXPL",3);
			stop;*/
	}
	
	bool ticked;
	override void Tick()
	{
		super.tick();
		if(isfrozen())
			return;
		if(!ticked)
			ticked = true;
		else
			SpawnFlameTrail(pos);
	}
	
	override void effect()
	{
		if(ticked)
			SpawnFlameTrail(pos);
	}
	
	override void OnHitActor(Actor target, Name dmgType)
	{
		if(pos.z < floorz)
			SetZ(floorz);
		A_Explode(10,36);
		A_SpawnWPSmoke(pos);
		for(int i = 0; i < random(3,6); i++)
			A_spawnitemEx("BigFlamesIG",random(-15,15),random(-15,15),random(-5,5),0,0,0,0,SXF_NOCHECKPOSITION);
		spawnflameFlare(pos,true);
		A_SpawnItemEx ("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
		A_startSound("FAREXPL",3);
	}
	override void OnExplode(int type)
	{
		if(pos.z < floorz)
			SetZ(floorz);
		A_Explode(10,36);
		A_SpawnWPSmoke(pos);
		for(int i = 0; i < random(3,6); i++)
			A_spawnitemEx("BigFlamesIG",random(-15,15),random(-15,15),random(-5,5),0,0,0,0,SXF_NOCHECKPOSITION);
		spawnflameFlare(pos,true);
		A_SpawnItemEx ("ExplosionFlareSpawner",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
		A_startSound("FAREXPL",3);
	}
	
	void A_SpawnWPSmoke(vector3 position)
	{
		FSpawnParticleParams PFSMK;
		PFSMK.Texture = TexMan.CheckForTexture ("X103E0");
		PFSMK.Color1 = "FFFFFF";
		PFSMK.Style = STYLE_Add;
		PFSMK.Flags = SPF_ROLL;
		PFSMK.Vel = (frandom(-2.5,2.5),frandom(-2.5,2.5),frandom(-2.3,2.3)); 
		PFSMK.Startroll = random(0,360);
		PFSMK.RollVel = frandom(-10,10);
		PFSMK.StartAlpha = 0.75;
		PFSMK.FadeStep = 0.1;
		PFSMK.Size = frandom(45,60);
		PFSMK.SizeStep = 6;
		PFSMK.Lifetime = FRandom(10,12); 
		PFSMK.Pos = position;
		Level.SpawnParticle(PFSMK);
	}
	
	void spawnflameFlare(vector3 position, bool bigger = false)
	{
		FSpawnParticleParams FFLAR;
		FFLAR.Texture = TexMan.CheckForTexture("FSO1A0");
		FFLAR.Color1 = "FFFFFF";
		FFLAR.Style = STYLE_ADD;
		FFLAR.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		FFLAR.Vel = (0,0,0);
		FFLAR.Startroll = random(0,360);
		FFLAR.RollVel = frandom(-3,3);
		FFLAR.StartAlpha = 0.85;
		FFLAR.FadeStep = bigger ? 0.15 : 0.25;
		FFLAR.Size = random(100,120);
		FFLAR.SizeStep = 10;
		FFLAR.Lifetime = bigger ? random(3,6): 1; 
		FFLAR.Pos = position;
		Level.SpawnParticle(FFLAR);
	}
	
	void SpawnFlameTrail(vector3 position, bool small = false)
	{
		FSpawnParticleParams FTrail;
		string txt = "EXP7D0";
		int f = random(1,6);
		switch(f)
		{
			case 1:		txt = "EXP7D0";			break;
			case 2:		txt = "EXP8D0";			break;
			case 3:		txt = "EXP2A0";			break;
			case 4:		txt = "EXP0D0";			break;
			case 5:		txt = "EXP9C0";			break;
			case 6:		txt = "EXP6D0";			break;
		}
		FTrail.Texture = TexMan.CheckForTexture(txt);//("DB54K0");
		FTrail.Color1 = "FFFFFF";
		FTrail.Style = STYLE_ADD;
		FTrail.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		FTrail.Vel = (frandom(-1.5,1.5),frandom(-1.5,1.5),frandom(-1.5,1.5)); 
		FTrail.Startroll = random(0,360);
		FTrail.RollVel = frandom(-5,5);
		FTrail.StartAlpha = 1.0;
		FTrail.FadeStep = 0.30;
		FTrail.Size = random(55,72);
		FTrail.SizeStep = -random(4,7);
		FTrail.Lifetime = random(2,3); 
		FTrail.Pos = position;
		Level.SpawnParticle(FTrail);
	}
}

//
//	well, in real life white phosphorous reacts a lot with oxygen and produces a lot of smoke
//
Class BigFlamesIG : FT_GroundFireSpawner
{
	int lifetime;
	Default
	{
		damagetype "Fire";
		renderstyle "add";
		damage 1;
		+nodamagethrust;
		+floorclip;
		scale 0.8;
		+bright;
	}
	
	states
	{
		spawn:
			TNT1 A 0 SpawnWPSmoke(pos + (0,0,random(28,36)));
			TNT1 A 0 spawnphosphorusFlare(pos + (0,0,6));
			FLME ABCDEFG 1 {
				if(random(0,1) == 1)
					A_explode(3,180,XF_NOSPLASH|XF_HURTSOURCE);
			}
			TNT1 A 0 SpawnWPSmoke(pos + (0,0,random(28,36)));
			TNT1 A 0 spawnphosphorusFlare(pos + (0,0,6));
			TNT1 A 0 SpawnParticleFast();
			FLME HIJKLM 1 {
				if(random(0,1) == 1)
					A_explode(3,180,XF_NOSPLASH|XF_HURTSOURCE);
			}
			TNT1 A 0 SpawnWPSmoke(pos + (0,0,random(28,36)));
			FLME N 1 {
				SpawnParticleFast();
				lifetime--;
			}
			TNT1 A 0 A_jumpif(lifetime <= 0 || waterlevel > 0,"Fadening");
			loop;
		Fadening:
			TNT1 A 0 spawnphosphorusFlare(pos + (0,0,6),true);
			FLME ABCDEFGHIJKLMN 1 {
				A_Fadeout(0.1);
				A_setscale(self.scale.x - frandom(0.02,0.07));
			}
			loop;
	}
	
	string flarcol;
	
	override void beginplay()
	{
		lifetime = random(7,35);
		bXFLIP = random(0,1);
		A_Setscale(self.scale.x + frandom(-0.2,0.2));
		flarcol = "LENYA0";
		switch(random(1,6))
		{
			case 1: flarcol = "LENYA0";	break;
			case 2: flarcol = "LENRA0";	break;
			case 3: flarcol = "LEYSO0";	break;
			case 4: flarcol = "L2NYA0";	break;	
			case 5: flarcol = "FLARA0";	break;
			case 6: flarcol = "DBFLA0";	break;
		}
		super.beginplay();
	}
	
	void SpawnWPSmoke(vector3 position)
	{
		if(pb_performance_fire)
			return;
		FSpawnParticleParams PFSMK;
		PFSMK.Texture = TexMan.CheckForTexture("X103E0");
		PFSMK.Color1 = "FFFFFF";
		PFSMK.Style = STYLE_ADD;
		PFSMK.Flags = SPF_ROLL;
		PFSMK.Vel = (frandom(-1.0,1.0),frandom(-1.0,1.0),frandom(2.75,10.5)); 
		PFSMK.Startroll = random(0,360);
		PFSMK.RollVel = frandom(-10,10);
		PFSMK.StartAlpha = 0.25;
		PFSMK.Size = frandom(60,70);
		PFSMK.SizeStep = 6;
		PFSMK.Lifetime = FRandom(9,15);
		PFSMK.FadeStep = PFSMK.StartAlpha / PFSMK.Lifetime;
		PFSMK.Pos = position;
		Level.SpawnParticle(PFSMK);
	}
	
	void spawnphosphorusFlare(vector3 position, bool dying = false)
	{
		FSpawnParticleParams FFLAR;
		FFLAR.Texture = TexMan.CheckForTexture(flarcol);
		FFLAR.Color1 = "FFFFFF";
		FFLAR.Style = STYLE_ADD;
		FFLAR.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		FFLAR.Vel = (0,0,0);
		FFLAR.Startroll = random(0,360);
		FFLAR.RollVel = frandom(-3,3);
		FFLAR.StartAlpha = 0.25;
		FFLAR.FadeStep = dying ? 0.03 : 0;
		FFLAR.Size = random(140,150);
		FFLAR.SizeStep = dying ? -0.25 : 0;
		FFLAR.Lifetime = 7; 
		FFLAR.Pos = position;
		Level.SpawnParticle(FFLAR);
	}
	
}

Class WPShockWave : Actor
{
	default
	{
		Translation "0:255=%[0,0,0]:[1.0,1.0,1.0]";
		renderstyle "add";
		//+bright;
		Scale 0.44;
		+nointeraction;
	}
	states
	{
		Spawn:
			X060 A 1 {
				A_fadeout(0.1);
				A_setscale(self.scale.x + frandom(0.06,0.1));
			}
			loop;
	}
}


Class DanmakuProjectile : Actor
{
	default
	{
		projectile;
		speed 80;
		BounceType "Doom";
		bouncecount 3;
		radius 5;
		height 5;
		projectilekickback 900;
		damage (10);
		renderstyle "add";
		+CANBOUNCEWATER;
		+BOUNCEAUTOOFF;
		+USEBOUNCESTATE;
		+bright;
		+forcexybillboard;
		+rollsprite;
		+FORCERADIUSDMG;
		damagetype "plasma";
	}
	
	color tracercolor;
	
	states
	{
		Spawn:
			TPEL A 1 nodelay A_Spawnparticle(tracercolor,SPF_FULLBRIGHT|SPF_NOTIMEFREEZE|SPF_RELATIVE,3,18,0,0,0,0,0,0,0,0,0,0,1,-1,-1);
		Fly:
			TPEL A 1 {
				spawnDnmkFlare(pos);
				A_Spawnparticle(tracercolor,SPF_FULLBRIGHT|SPF_RELATIVE,3,random(13,15),0,0,0,0,0,0,0,0,0,0,1,-1,-1);
			}
			loop;
			
		Bounce:
			TNT1 A 0 SpawnSparkFx(pos);
			TPEL A 1 SpawnSparkFx(pos);
			goto Fly;
			
		Death:
			TNT1 A 0 A_setscale(0.1);
			TNT1 A 0 A_explode(1,60,0);
			TNT1 A 0 A_Startsound("lildead",32);
			TNT1 A 0 SpawnBounceFx(pos);
			TNT1 A 0 spawnDnmkFlare(pos,true);
			TNT1 A 0 SpawnSparkFx(pos);
			5PRK AAAA 1 { A_setscale(self.scale.x + frandom(0.025,0.075)); A_Fadeout(0.15); }
			stop;
			
	}
	
	static const color DanmkTracerCol[] = {
		"83FFF9","D083FF","83AEFF","BAEFFF","E0BAFF",
		"E9BAFF","FFBAD0","7FC9FF","C27FFF","FFFFFF"
	};
	
	void SpawnBounceFx(vector3 where)
	{
		FSpawnParticleParams DnmkBnc;
		DnmkBnc.Texture = TexMan.CheckForTexture("SHWKK0");
		DnmkBnc.Color1 = tracercolor;//"FFFFFF";
		DnmkBnc.Style = STYLE_AddStencil;
		DnmkBnc.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		DnmkBnc.Vel = (0,0,0); 
		DnmkBnc.Startroll = 0;//random(0,360);
		DnmkBnc.RollVel = frandom(-3,3);
		DnmkBnc.StartAlpha = 0.80;
		DnmkBnc.Lifetime = random(7,10); 
		DnmkBnc.FadeStep = DnmkBnc.StartAlpha / DnmkBnc.Lifetime;
		DnmkBnc.Size = 32;
		DnmkBnc.SizeStep = 15;
		DnmkBnc.Pos = where;
		Level.SpawnParticle(DnmkBnc);
	}
	
	void SpawnSparkFx(vector3 where)
	{
		FSpawnParticleParams DnmkSprk;
		DnmkSprk.Texture = TexMan.CheckForTexture("5PRKA0");
		DnmkSprk.Color1 = tracercolor;//"FFFFFF";
		DnmkSprk.Style = STYLE_Add;
		DnmkSprk.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		DnmkSprk.Vel = (random(-5,5),random(-5,5),random(-2,9));
		DnmkSprk.accel = (0,0,frandom(-1.75,-0.75));
		DnmkSprk.Startroll = randompick(0,90,180,270,360);
		DnmkSprk.RollVel = 0;
		DnmkSprk.StartAlpha = 1.0;
		DnmkSprk.FadeStep = 0.075;
		DnmkSprk.Size = random(8,14);
		DnmkSprk.SizeStep = -0.5;
		DnmkSprk.Lifetime = random(12,18); 
		DnmkSprk.Pos = where;
		Level.SpawnParticle(DnmkSprk);
	}
	
	void spawnDnmkFlare(vector3 position, bool bigger = false)
	{
		FSpawnParticleParams FFLAR;
		FFLAR.Texture = TexMan.CheckForTexture("5PRKA0");//("LENSA0");//("L2NBA0");
		FFLAR.Color1 = tracercolor;//"FFFFFF";
		FFLAR.Style = STYLE_ADDSTENCIL;
		FFLAR.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		FFLAR.Vel = (0,0,0);
		FFLAR.Startroll = random(0,360);
		FFLAR.RollVel = frandom(-5,5);
		FFLAR.StartAlpha = 0.85;
		FFLAR.FadeStep = 0.15;
		FFLAR.Size = bigger ? random(50,69) : random(20,30);
		FFLAR.SizeStep = -5;
		FFLAR.Lifetime = bigger ? random(4,6): 1; 
		FFLAR.Pos = position;
		Level.SpawnParticle(FFLAR);
	}
	
	override void beginplay()
	{
		self.bxflip = random(0,1);
		self.byflip = random(0,1);
		A_Setroll(random(0,360));
		int c = random(0,self.DanmkTracerCol.Size()-1);
		tracercolor = self.DanmkTracerCol[c];
		super.beginplay();
	}
}

// Sub Zero
class SubZ_Puff : FastProjectile
{
    Default
    {
        Projectile;
        +BLOODLESSIMPACT
        Radius 1;
        Height 1;
        Speed 75;
        Damage 0;
        Scale 0.50;
        DamageType "Ice";
        Decal "FreezerBurn";
    }

    States
    {
    Spawn:
        FRPJ ABC 1 Bright
        {
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0);
            A_SpawnProjectile("Icetracer", 0, 0, random(0, 360), 2, random(0, 360));
            A_SpawnItemEx("FreezerTrailSparksSmall", random(-5, 5), random(-5, 5), random(-5, 5), 0, 0, 0, 0, 128, 0);
			A_FadeOut(0.1);
        }
        Loop;

    Death:
        TNT1 A 0 A_SpawnItemEx("DetectFloorIce", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        TNT1 A 0 A_SpawnItemEx("DetectCeilIce", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        TNT1 AAAAA 0 Bright A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30) * 0.04, 0, random(0, 10) * 0.04, random(1, 360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION, 64);
        TNT1 AAAAAAA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(-5, 5), random(-5, 5), random(-5, 5), random(10, 30) * 0.04, 0, random(0, 10) * 0.04, random(1, 360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION, 64);
        TNT1 AAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30) * 0.04, 0, random(0, 10) * 0.04, random(1, 360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION, 64);
        BXPL ABCDEFGH 1 Bright;
        BXPL IJKLLM 1 Bright A_FadeOut(0.1);
        Stop;
    }
}

class SubZeroProjectile : PB_10GAPellet
{
    Default
    {
        PB_Projectile.BaseDamage 35;
        DamageType "Ice";
    }
}

class CSSG_FrozenTracer : FastProjectile
{
    Default
    {
		Projectile;
        RenderStyle "Add";
        Alpha 0.9;
        Scale 0.5;
        DamageType "Ice";
        -DONTSPLASH;
		+RANDOMIZE;
		+FORCEXYBILLBOARD;
		//+BLOODSPLATTER 
		+NOEXTREMEDEATH;
		damage 0;
		radius 2;
		height 2;
		speed 140;
		alpha 0.9;
		scale .15;
    }

    States
    {
    Spawn:
        TRFR A 1 Bright;
        Loop;
    Death:
        FRPF ABCDEF 1;
        Stop;
    XDeath:
        FRPF ABCDEF 1;
        Stop;
    }
}

class HellFireProjectile : PB_10GAPellet
{ 
    Default
    {
        PB_Projectile.BaseDamage 35;
		+PB_PROJECTILE.NOCRITICALS
        RenderStyle "Add";
		Height 6;
		Radius 6;
		Scale 0.3;
		Alpha 0.80;
		Speed 100;
		Decal "Scorch";
		// Deathsound "Weapons/Demontech/Crash";
		Species "Player";
		DamageType "Disintegrate";
        +NOINTERACTION;
        +NOGRAVITY;
        +CLIENTSIDEONLY;
		+NOBLOCKMAP;
		+ACTIVATEIMPACT;
		+ACTIVATEPCROSS;
		+NOTELEPORT;
		+EXTREMEDEATH;
		+PUFFONACTORS ;
		+BLOODLESSIMPACT;
		+FORCERADIUSDMG;
		+ALWAYSPUFF;
		+DONTHARMSPECIES;
		+PUFFGETSOWNER;
    }

    States
    {
		Spawn:
			TRA3 A 1 Bright;
			Loop;
	
		Xdeath:
			TNT1 A 0 A_SpawnItem("HellRifle_Puff",0);
			TNT1 A 0 A_SpawnItem("DTechBurningPiece",0);
			TNT1 A 0 BRIGHT A_SpawnItem("RedFlare",0);
			TNT1 AAA 0 A_SpawnItemEx("ObeliskTrailSpark", random(-8, 8), random(-8, 8), random(-2,2), 0, 0, 0, 0, 128, 0);
			TNT1 A 4;
			Stop;

		Death:
			TNT1 A 0 A_SpawnItem("HellRifle_Puff2",0);
			TNT1 A 0 A_SpawnItem("DTechBurningPiece2",0);
			TNT1 A 0 BRIGHT A_SpawnItem("RedFlare",0);
			TNT1 AAA 0 A_SpawnItemEx("ExplosionParticleVerySlow", random(-8, 8), random(-8, 8), random(-2,2), 0, 0, 0, 0, 128, 0);
			TNT1 AAA 0 A_SpawnItemEx("ObeliskTrailSpark", random(-8, 8), random(-8, 8), random(-2,2), 0, 0, 0, 0, 128, 0);
			TNT1 A 4;
			Stop;
    }
}

class AcidShellsProjectile : PB_10GAPellet
{
    Default
    {
        PB_Projectile.BaseDamage 35;
        DamageType "Disintegrate";
    }

	States
	{
		Death:
		XDeath:
			TNT1 A 0 {
				for(int i = 0; i < 20; i++)
				{
					A_SpawnProjectile("PB_Shrapnel", 0, 0, random (0, 360), 2, random (-90, 90));
				}
			}
			TNT1 A 0 A_SpawnItem("BFGAltShockWave",0,0);
			TNT1 A 0 A_SpawnItemEx("ACIDFOG",flags:SXF_TRANSFERPOINTERS);
			TNT1 A 1;
			Stop;
	}
}