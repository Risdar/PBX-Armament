//////////////////////////// DEMONIC EXTERMINATOR ////////////////////////////////////////////////////////////////////////////////////
Class UNMK_Projectile : UNMK_DExtFastProjectile
{
	default
	{
		speed 350;
		//damage 72;
		//damagefunction (324);
		//damagefunction (247.5);
		Species "Marines";
		damagefunction (108);
		radius 5;
		height 5;
		//damagetype "incinerate";
		damagetype "saw";
		DeathSound "weapons/StachanovHit";
		renderstyle "add";
		scale 0.1;
		decal "PlasmaScorchLower";
	}
	
	states
	{
		Spawn:
			UAE3 C 1 bright;
			loop;
		Death:
			TNT1 A 0 A_setscale(frandom(0.25,0.50));
			TNT1 A 0 SpawnFlareImpact(pos);
			TNT1 A 0 A_Explode(random(64,128),8,0,0);
			DB26 IJKLMNOPQRSTUV 1 bright;
			stop;
	}
	
	override void postbeginplay()
	{
		//inflict different damage types
		int dtp = random(1,4);
		switch(dtp)
		{
			case 1:		damagetype = "Saw";				break;
			case 2:		damagetype = "Incinerate";		break;
			case 3:		damagetype = "ExplosiveImpact";	break;
			case 4:		damagetype = "Fire";			break;
		}
		super.postbeginplay();
	}
	
	//this spawns the trail, replaces the actors trail for a particles one
	override void effect()
	{
		spawnTrailPx(pos);
	}
	
	void spawnTrailPx(vector3 where)
	{
		FSpawnParticleParams UNMKPX;
		UNMKPX.Texture = TexMan.CheckForTexture("YHE5A0");
		UNMKPX.Color1 = "FFFFFF";
		UNMKPX.Style = STYLE_Add;
		UNMKPX.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		UNMKPX.Vel = (frandom(-0.5,0.5),frandom(-0.5,0.5),frandom(-0.5,0.5));
		UNMKPX.accel = (frandom(-0.25,0.25),frandom(-0.25,0.25),frandom(-0.25,0.25));
		UNMKPX.Startroll = random(0,360);
		UNMKPX.RollVel = random(-15,15);
		UNMKPX.StartAlpha = 0.75;
		UNMKPX.FadeStep = 0.031;
		UNMKPX.Size = 28;
		UNMKPX.SizeStep = -2;
		UNMKPX.Lifetime = 7; 
		UNMKPX.Pos = where;
		Level.SpawnParticle(UNMKPX);
	}
	
	void SpawnFlareImpact(vector3 where)
	{
		FSpawnParticleParams UNMFLAR;
		UNMFLAR.Texture = TexMan.CheckForTexture("UAE3C0");
		UNMFLAR.Color1 = "FFFFFF";
		UNMFLAR.Style = STYLE_TRANSLUCENT;
		UNMFLAR.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		UNMFLAR.Vel = (0,0,0);//(frandom(-0.5,0.5),frandom(-0.5,0.5),frandom(-0.5,0.5));
		UNMFLAR.Startroll = randompick(0,180);
		//UNMFLAR.RollVel = random(-5,5);
		UNMFLAR.StartAlpha = 0.85;
		UNMFLAR.FadeStep = 0.12;
		UNMFLAR.Size = random(150,160);
		//UNMFLAR.SizeStep = -7;
		UNMFLAR.Lifetime = 10; 
		UNMFLAR.Pos = where;
		Level.SpawnParticle(UNMFLAR);
	}
}

//unused	- too generic tbh
Class UNMK_AltPj : UNMK_DExtActor
{
	default
	{
		damagetype "incinerate";
		Translation "0:255=%[0,0,0]:[2.0,0.0,0.0]";
		renderstyle "translucent";
		+bright;
		Scale 0.18;
		+missile;
		projectile;
		speed 20;
		damage 100;
		Species "Marines";
		+rollsprite;
		+rollcenter;
	}
	
	states
	{
		spawn:
			TNT1 A 0 nodelay A_Startsound("UNMFLY1",18,CHANF_LOOPING);
			029G ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 Bright;
			loop;
		Death:
			TNT1 A 0 { 
				A_StopSound(18);
				bedead = true; 
				A_setroll(random(0,360));
				alpha = frandom(0.75,0.80);
				A_setscale(0.45,0.60);
				A_Startsound("unmbal",CHAN_AUTO);
			}
			TNT1 A 0 DoUnmakerAttack(1200,100);
			TNT1 A 0 A_QuakeEx(2,2,2,8,0,300,"",QF_SCALEDOWN);
			DB26 IJKLMNOPQRSTUV 1 bright;
			//HRX2 ABCDEFGH 1 bright;
			stop;
	}
	bool beDead;
	override void tick()
	{
		super.tick();
		
		if(isfrozen() || beDead)
			return;
			
		if(getage() % 3 == 0)
		{
			PB_SpawnUNMShockWave(pos);
			SPawnUnmkCal(self.vec3offset(2 * random(-radius,radius),2 * random(-radius,radius),1.25 * random(0,height) ));
		}
		if(getage() % 35 == 0)
			DoUnmakerAttack();
			
		spawnTrailPx(self.vec3offset(random(-radius,radius),random(-radius,radius), random(0,height) ));
		
	}
	
	void DoUnmakerAttack(int dist = 800, int dmg = -1)
	{
		let bt = blockthingsiterator.create(self,dist);
		actor v;
		if(dmg < 0)
			dmg = random(45,60);
		while(bt.next())
		{
			v = bt.thing;
			int sd = random(1,4);
			name damagetype = "Incinerate";
			switch(sd)
			{
				case 1:	damagetype = "Incinerate";	break;
				case 2:	damagetype = "Fire";	break;
				case 3:	damagetype = "Saw";	break;
				case 4:	damagetype = "Incinerate";	break;
			}
			if(v && v.health > 0 && v.checksight(self) && v != target)
				v.damagemobj(self,target,dmg,damagetype,DMG_THRUSTLESS);
		}
	}
	
	void spawnTrailPx(vector3 where)
	{
		FSpawnParticleParams UNMKPX;
		UNMKPX.Texture = TexMan.CheckForTexture("YHE5A0");
		UNMKPX.Color1 = "FFFFFF";
		UNMKPX.Style = STYLE_Add;
		UNMKPX.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		UNMKPX.Vel = (frandom(-2.5,2.5),frandom(-2.5,2.5),frandom(-2.5,2.5));
		UNMKPX.accel = (frandom(-0.15,0.15),frandom(-0.15,0.15),frandom(-0.15,0.15));
		UNMKPX.Startroll = random(0,360);
		UNMKPX.RollVel = random(-15,15);
		UNMKPX.StartAlpha = 0.75;
		UNMKPX.FadeStep = 0.031;
		UNMKPX.Size = 28;
		UNMKPX.SizeStep = -2;
		UNMKPX.Lifetime = 18; 
		UNMKPX.Pos = where;
		Level.SpawnParticle(UNMKPX);
	}
	
	Void PB_SpawnUNMShockWave(vector3 where)
	{
		FSpawnParticleParams ShockWv;
		ShockWv.Texture = TexMan.CheckForTexture("PBSWV1");
		ShockWv.Style = STYLE_ADD;
		ShockWv.Color1 = "FFFFFF";
		ShockWv.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		ShockWv.Startroll = randompick(0,180);
		//ShockWv.RollVel = random(-45,45);
		ShockWv.StartAlpha = 1.0;
		ShockWv.Lifetime = 20;
		ShockWv.FadeStep = 0.05;
		ShockWv.Size = 120;
		ShockWv.SizeStep = -5;
		ShockWv.Pos = where;
		Level.SpawnParticle(ShockWv);
	}
	
	void SPawnUnmkCal(vector3 where)
	{
		FSpawnParticleParams redcr;
		string f = String.Format("%c", int("A") + random(1,5));
		redcr.Texture = TexMan.CheckForTexture("HRX2"..f..0);
		redcr.Style = STYLE_TRANSLUCENT;
		redcr.Color1 = "FFFFFF";
		redcr.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		redcr.Startroll = random(0,360);
		//redcr.RollVel = random(-45,45);
		redcr.vel = (frandom(-0.25,0.25),frandom(-0.25,0.25),frandom(-0.25,0.25));
		redcr.StartAlpha = 0.85;
		redcr.Lifetime = 15;
		redcr.FadeStep = 0.075;
		redcr.Size = random(55,80);
		redcr.SizeStep = random(2,6);
		redcr.Pos = where;
		Level.SpawnParticle(redcr);
	}
}

Class ExplosievUNmk : PB_lightactor
{
	default
	{
		scale 0.5;
		alpha 0.85;
		renderstyle "Add";
		damagetype "Fire";
		+nointeraction;
		+rollsprite;
		+rollcenter;
	}
	States
	{
		spawn:
			HRX2 ABCDEFGH 1 bright;
			stop;
	}
	
	override void beginplay()
	{
		A_Setscale(self.scale.x + frandom(-0.1,0.1));
		A_Setroll(random(0,360));
		super.beginplay();
	}
}

//
//	ground fire attack, spawns dtech fire as its trail, and explodes dealing big damage
//	couldnt come up with something better, sorry 
//

Class UNMK_Grounder : UNMK_DExtActor
{
	default
	{
		+missile;
		projectile;
		+floorhugger;
		speed 45;
		damage 5;
		radius 7;
		height 5;
		damagetype "Incinerate";
		Species "Marines";
		+ripper;
		-bloodsplatter;
		decal "Scorch";
	}
	states
	{
		Spawn:
			TNT1 A 1;
			TNT1 A 0 A_startsound("UNOCBLL",16,CHANF_LOOPING);
			TNT1 A 1;
		Run:
			TNT1 A 1 Unmk_SpawnDtechFire((random(-25,25),random(-25,25),random(0,5)));
			TNT1 A 0 SpawnUNMKFlare(pos,true);
			TNT1 A 0 spawnTrailPx(pos);
			TNT1 A 0 A_jump(64,"DamageSpecial");	// 1/4 chance to do the area attack before exploding,so it isnt just a useless ground attack
			loop;
		DamageSpecial:
			TNT1 A 1 Unmk_SpawnDtechFire((random(-30,30),random(-25,25),random(0,5)));
			TNT1 A 0 SpawnUNMKFlare(pos,true);
			TNT1 A 0 DoUnmakerAttack(600,-1);
			TNT1 A 0 A_SPawnitem("ExplosievUNmk",0,10);
			TNT1 A 1 Unmk_SpawnDtechFire((random(-30,30),random(-25,25),random(0,5)));
			TNT1 A 0 SpawnUNMKFlare(pos,true);
			goto Run;
		Death:
			TNT1 A 0 A_StopSound(16);
			TNT1 A 0 SpawnUNMKFlare(self.vec3offset(0,0,5));
			TNT1 A 0 A_Startsound("weapons/demontech/respect2",CHAN_AUTO);
			TNT1 A 0 A_StartSound("FAREXPL",CHAN_AUTO,CHANF_OVERLAP);
			TNT1 A 0 PB_SpawnUNMShockWave(pos);
			TNT1 A 0 DoUnmakerAttack(1200,150);
			TNT1 A 0 A_QuakeEx(3,3,3,8,0,120,"",QF_SCALEDOWN);
			TNT1 AAA 0 A_SpawnProjectile("FireworkSFXUnmaker", 2, 0, random (0, 360), 2, -random(10, 80));
			TNT1 A 8;
			stop;
	}
	
	void SpawnUNMKFlare(vector3 where, bool fast = false)
	{
		FSpawnParticleParams UNMFLAR;
		UNMFLAR.Texture = TexMan.CheckForTexture("UAE3C0");
		UNMFLAR.Color1 = "FFFFFF";
		UNMFLAR.Style = STYLE_TRANSLUCENT;
		UNMFLAR.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		UNMFLAR.Vel = (0,0,0);
		UNMFLAR.Startroll = randompick(0,180);
		UNMFLAR.StartAlpha = 0.85;
		UNMFLAR.FadeStep = 0.05;
		UNMFLAR.Size = fast ? 300 : random(400,500);
		UNMFLAR.SizeStep = -10;
		UNMFLAR.Lifetime = fast ? 1 : 18; 
		UNMFLAR.Pos = where;
		Level.SpawnParticle(UNMFLAR);
	}
	
	void Unmk_SpawnDtechFire(vector3 offs)
	{
		actor dtc = Spawn("U64BurningPiece",self.vec3offset(offs.x,offs.y,offs.z));
		if(dtc)
		{
			dtc.target = self;
			//dtc.A_setscale(dtc.scale.x + frandom(-0.1,0.45));
		}
	}
	
	void DoUnmakerAttack(int dist = 1200, int dmg = -1)
	{
		let bt = blockthingsiterator.create(self,dist);
		actor v;
		if(dmg < 0)
			dmg = random(45,60);
		while(bt.next())
		{
			v = bt.thing;
			int sd = random(1,4);
			name damagetype = "Incinerate";
			switch(sd)
			{
				case 1:	damagetype = "Incinerate";	break;
				case 2:	damagetype = "Fire";	break;
				case 3:	damagetype = "Saw";	break;
				case 4:	damagetype = "Incinerate";	break;
			}
			if(v && v.health > 0 && v.checksight(self) && v != target)
				v.damagemobj(self,target,dmg,damagetype,DMG_THRUSTLESS);
		}
	}
	
	void spawnTrailPx(vector3 where)
	{
		FSpawnParticleParams UNMKPX;
		UNMKPX.Texture = TexMan.CheckForTexture("YHE5A0");
		UNMKPX.Color1 = "FFFFFF";
		UNMKPX.Style = STYLE_Add;
		UNMKPX.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		UNMKPX.Vel = (frandom(-2.5,2.5),frandom(-2.5,2.5),frandom(1.75,4.5));
		UNMKPX.accel = (frandom(-0.75,0.75),frandom(-0.75,0.75),frandom(-0.25,0.25));
		UNMKPX.Startroll = random(0,360);
		UNMKPX.RollVel = random(-15,15);
		UNMKPX.StartAlpha = 0.75;
		UNMKPX.FadeStep = 0.031;
		UNMKPX.Size = 28;
		UNMKPX.SizeStep = -2;
		UNMKPX.Lifetime = 18; 
		UNMKPX.Pos = where;
		Level.SpawnParticle(UNMKPX);
	}
	
	Void PB_SpawnUNMShockWave(vector3 where)
	{
		FSpawnParticleParams ShockWv;
		ShockWv.Texture = TexMan.CheckForTexture("PBSWV1");
		ShockWv.Style = STYLE_ADD;
		ShockWv.Color1 = "FFFFFF";
		ShockWv.Flags = SPF_ROLL|SPF_FULLBRIGHT;
		ShockWv.Startroll = randompick(0,180);
		//ShockWv.RollVel = random(-45,45);
		ShockWv.StartAlpha = 1.0;
		ShockWv.Lifetime = 8;
		ShockWv.FadeStep = 0.15;
		ShockWv.Size = 125;
		ShockWv.SizeStep = 65;
		ShockWv.Pos = where;
		Level.SpawnParticle(ShockWv);
	}
	
}

Class U64BurningPiece : DTechBurningPiece
{
	default
	{
		scale 0.6;
		radius 10;
		height 10;
	}
	states
	{
		Spawn:
			TNT1 A 0 A_JumpIf(waterlevel > 1, "StopBurning");
			TNT1 A 0 A_Explode(15, 50);
			TNT1 A 0 SpawnParticleSlow("YAE4A0");
			DFIR ABCDEFGHIJKLMNOP 2 BRIGHT;
			TNT1 A 0 A_Jump(50, "StopBurning");
			Loop;
		StopBurning:
			DFIR A 2 BRIGHT A_SetScale(0.06);
			DFIR B 2 BRIGHT A_SetScale(0.04);
			DFIR C 2 BRIGHT A_SetScale(0.02);
			Stop;
	}
	
	override void beginplay()
	{
		self.bxflip = random(0,1);
		A_setscale(self.scale.x + frandom(-0.1,0.25));
		super.beginplay();
	}
}
Class UnmakerLaser64 : UNMK_DExtActor
{
	Default
	{
		Radius 18;
		Height 18;
		Speed 40;
		Damage 20;
		Projectile;
		+NOGRAVITY
		MissileType "UnmakerLaser64Trail";
		DamageType "Fire";
		DeathSound "";
		Scale 0.1;
	}

	States
	{
		Spawn:
			TNT1 A 1;
			Loop;
		Death:
			TNT1 A 0 A_SetScale(1);
			LENR C 1 A_FadeOut(0.02);
			Stop;
	}
}
Class DExtShoque : UNMK_DExtActor
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 2;
		Damage 0;
		RenderStyle "Add";
		Scale 0.7;
		Gravity 0;
		Alpha 0.5;
		+NOBLOCKMAP
		+NOTELEPORT
		+DONTSPLASH
		+MISSILE
		+FORCEXYBILLBOARD
		+ROLLSPRITE
		+ROLLCENTER
	}

	States
	{
		Spawn:
			TNT1 A 1;
			SHOQ ABCDEFG 1 BRIGHT;
			Stop;
	}
}

Class DemonExterminatorEnergyBlast : PlasmaBall
{
	Default
	{
		Scale 0.8;
		Speed 85;
		Damagefunction 216;
		//Damage 25;
		//54*4
		Height 7;
		Radius 7;
		Alpha 0.9;
		RenderStyle "Add";
		Decal "MedScorch";
		DamageType "Plasma";
		ReactionTime 60;
		+DONTSPLASH
		+BLOODSPLATTER
		+FORCERADIUSDMG
		+NOGRAVITY
		+BOUNCEONWALLS
		+EXPLODEONWATER
		+PAINLESS
		Obituary "$OB_PROJ_DEMONEXT_ENERGYBLAST";
		SeeSound "";
		BounceFactor 0.95;
		ReactionTime 45;
	}
	int flipRoll;
	override void BeginPlay(){
		flipRoll = randompick(-1,1);
		if(random(0,1)){bXFLIP = true;}
		if(random(0,1)){bYFLIP = true;}
		super.BeginPlay();
	}
	override void tick(){
		super.tick();
		if(GetAge() >= 1){
			A_SetRoll(roll+(15 * flipRoll ) );
		}
	}
	States{
	Spawn:
		TNT1 A 0 NoDelay A_JumpIf(waterlevel > 1,"Death");
		TNT1 A 0 A_CountDown;
		TNT1 A 0 A_SpawnItemEx("RocketFlare");
		LEYS R 1 Bright Light("BIGREDLASER") A_SpawnItemEx("DemonExterminatorLaserTrail",0,0,0,0,0,0,0,SXF_TRANSFERROLL);
		TNT1 A 0 A_CustomMissile("ObeliskTrailSpark",0,0,random(0,360));
		TNT1 A 0 A_SpawnItemEx("DExtShoque",0,0,0,0,0,0,0,SXF_TRANSFERROLL);
		Loop;
	Death:
		TNT1 A 0 A_Stop;
		TNT1 A 0 {A_PlaySound("DSFIRXPL",CHAN_ITEM); A_Explode(50,75,0);}//100
		L2NR AB 3 Bright Light("BIGREDLASER") A_SpawnItemEx("RocketFlare");
		LENR AB 1 Bright Light("BIGREDLASER") A_SpawnItemEx("RocketFlare");
		TNT1 AAAAAAAAAA 0 {A_CustomMissile("ExplosionParticleHeavy",2,0,random(0,360),2,random(0,180));A_CustomMissile("ExplosionParticleLaser",0,0,random(0,360),2,random(0,360));}
		LPUF A 1 Light("REDLASER") A_Explode(50,75,0);
		TNT1 A 0 A_SpawnItemEx("DExtShoque");
		TNT1 A 0 A_SpawnItemEx("LiquidExplosionEffectSpawner");
		TNT1 A 0 A_SetScale(1.2);
		LPUF ABC 7 Bright Light("REDLASER") A_CustomMissile("PlasmaSmoke",1,0,random(0,360),2,random(0,160));
		Stop;
	}
}
Class ExplosionParticleLaser : UNMK_DExtActor{
	Default{
	Scale 0.02;
	Speed 6;
	Radius 1;
	Height 1;
	Gravity 0.9;
	RenderStyle "Add";
	BounceType "Doom";
	BounceFactor 0.01;
	BounceCount 1;
	+MISSILE
	+NOTELEPORT
	+NOBLOCKMAP
	+BLOODLESSIMPACT
	+FORCEXYBILLBOARD
	+CLIENTSIDEONLY
	+DONTSPLASH
	+THRUACTORS
	+THRUGHOST
	+GHOST
	+ROLLSPRITE
	+ROLLCENTER
	}
	States{
	Spawn:
		SPRK O 8 Bright NoDelay A_JumpIf(waterlevel > 1,"Splash");
	Death:
		TNT1 A 0 A_JumpIf(waterlevel > 1,"Splash");
		SPRK O 1 Bright A_FadeOut(0.03);
		Loop;
	Splash:
		TNT1 A 1;
		Stop;
	}
}
Class DemonExterminatorLaserTrail : UNMK_DExtActor{
	Default{
		Scale 2.75;
		Height 7;
		Radius 7;
		Speed 80;
		Damage 0;
		Alpha 1;
		RenderStyle "Add";
		+ROLLSPRITE
		+ROLLCENTER
	}
	states{
	Spawn:
		LAZR AB 1 Bright A_SpawnItemEx("RocketFlare");
		Stop;
	Death:
		LPUF A 1 Bright;
		Stop;
	}
}

Class UNMK_StormShot1 : Actor
{
	Default
	{
		Radius 12;
		Height 6;
		Speed 30;
		Damagefunction 50;
		PROJECTILE;
		RENDERSTYLE "ADD";
		Alpha 0.80;
		Damagetype "Incinerate";//wepsoul//"Lightning"
		DeathSound "weapons/devexp";
		+THRUGHOST
		+PIERCEARMOR
		+NODAMAGETHRUST
		+FORCEPAIN
		+DONTREFLECT
		+FORCERADIUSDMG
	}

	int user_ang1;

	States
	{
		Spawn:
			TNT1 A 2 NODELAY A_SetUserVar("user_ang1",0);
		Spawn2:
			LFX1 STUVW 1 Bright{
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+90,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+180,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+270,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+0,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+135,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+225,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+315,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+45,6);
				A_SetUserVar("user_ang1",user_ang1+17);
			}
			loop;
		Death:
			LFX1 STUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVW 1 Bright {
				A_Explode(32,64,0);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+90,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+180,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+270,6);
				A_CustomMissile("UNMK_StormLite1",0,0,user_ang1+0,6);
				A_SetUserVar("user_ang1",user_ang1+17);
			}
			stop;
	}
}

Class UNMK_StormShot2 : UNMK_StormShot1
{
	Default
	{
		Damagefunction 150;
	}

	States
	{
		Spawn:
			TNT1 A 2 NODELAY A_SetUserVar("user_ang1",0);
		Spawn2:
			LFX1 KLMNO 1 Bright{
				A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+90,6);
				A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+180,6);
				A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+270,6);
				A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+0,6);
				A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+135,6);
				A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+225,6);
				A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+315,6);
				A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+45,6);
				A_SetUserVar("user_ang1",user_ang1+17);
			}
			loop;
		Death:
		LFX2 KLMNOKLMNOKLMNOKLMNOKLMNOKLMNOKLMNOKLMNOKLMNOKLMNOKLMNOKLMNO 1 Bright {
			A_Explode(64,128,0);
			A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+90,6);
			A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+180,6);
			A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+270,6);
			A_CustomMissile("UNMK_StormLite2",0,0,user_ang1+0,6);
			A_SetUserVar("user_ang1",user_ang1+17);
		}
		stop;
	}
}

Class UNMK_StormLite1 : Actor
{
	Default
	{
		Radius 6;
		Height 12;
		Speed 32;
		Damagefunction 5;
		PROJECTILE;
		Renderstyle "Add";
		Alpha 0.80;
		Damagetype "Incinerate";//wepsoul//"Lightning"
		DeathSound "weapons/devzap";
		+PIERCEARMOR
		+FORCEPAIN
		+THRUGHOST
		+DONTREFLECT
		+RIPPER
		+FORCERADIUSDMG
	}

	States
	{
		Spawn:
			DLIT ABC 1 Bright;
			Loop;
		Death:
			DLIT DEFGHIJKLMNO 1 Bright;
			Stop;
	}
}

Class UNMK_StormLite2 : UNMK_StormLite1
{
	Default
	{
		Speed 64;
		Damagefunction 10;
	}

	States
	{
		Spawn:
			LFX1 XYZ 1 Bright;
			Loop;
		Death:
			LFX1 STUVW 3 Bright;
			Stop;
	}
}
Class HolyMissile2 : HolyMissile replaces HolyMissile
{
	Default
	{
		Speed 15;
		Damage 0;
		RenderStyle "None";
		Alpha 0.50;
		Damagetype "wepsoul";
		Obituary "$OB_GENERIC_REAPED_BY";
		+Bright
		+EXTREMEDEATH
		+FORCEXYBILLBOARD
		+PIERCEARMOR
		-FOILINVUL
	}

	States
	{
		Spawn:
			TNT1 A 0 ;
			TNT1 A 1 A_CHolyAttack2;
			Stop;
	}
}

Class ReaperBall : Cacodemonball //Thanks to Xaser for spiraling projectile code :)
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 25;
		Damage 100;
		Damagetype "wepsoul";
		Obituary "$OB_GENERIC_REAPED_BY";
		SeeSound "none";
		DeathSound "weapons/solexp";
		RENDERSTYLE "ADD";
		+SEEKERMISSILE
		+EXTREMEDEATH
		+FORCEXYBILLBOARD
		+DONTREFLECT
		+SCREENSEEKER
		+FORCERADIUSDMG
		+PIERCEARMOR
		+NODAMAGETHRUST
	}
	
	int user_ang1;
	int user_radius1;

	States
	{
		Spawn:
			REAX J 0;
			REAX J 0 {A_SetUserVar("user_ang1",0);A_SetUserVar("user_radius1",24);}
			REAX JK 1 Bright {
				A_SpawnItemEx("SoulPuff",0,(user_radius1*sin(user_ang1*(7.5)+30)),(user_radius1*cos(user_ang1*(7.5)+30)),0,0,0,0,0,0);
				A_SpawnItemEx("SoulPuff",0,(user_radius1*sin(user_ang1*(7.5)+150)),(user_radius1*cos(user_ang1*(7.5)+150)),0,0,0,0,0,0);
				A_SpawnItemEx("SoulPuff",0,(user_radius1*sin(user_ang1*(7.5)+270)),(user_radius1*cos(user_ang1*(7.5)+270)),0,0,0,0,0,0);
				A_SetUserVar("user_ang1",user_ang1+1);
			}
		Spawn2:
			REAX JK 1 Bright {
				A_SpawnItemEx("SoulPuff",0,(user_radius1*sin(user_ang1*(7.5)+30)),(user_radius1*cos(user_ang1*(7.5)+30)),0,0,0,0,0,0);
				A_SpawnItemEx("SoulPuff",0,(user_radius1*sin(user_ang1*(7.5)+150)),(user_radius1*cos(user_ang1*(7.5)+150)),0,0,0,0,0,0);
				A_SpawnItemEx("SoulPuff",0,(user_radius1*sin(user_ang1*(7.5)+270)),(user_radius1*cos(user_ang1*(7.5)+270)),0,0,0,0,0,0);
				A_SetUserVar("user_ang1",user_ang1+1);
				A_SeekerMissile(1,3,SMF_LOOK|SMF_PRECISE);
				A_Explode(16,64,0,0,64,0,0);
			}
			REAX K 0 A_JumpIf(user_ang1==15,"ResetVar");
			loop;
		ResetVar:
			REAX J 0 A_SetUserVar("user_ang1",0);
			goto Spawn2;
		Death:
			REAX A 3 Bright;
			REAX B 3 Bright A_Explode(320,256,0);
			REAX CD 3 Bright ;
			REAX E 3 Bright A_SpawnItemEx("HolyMissile2",0,0,0,0,0,0,0,0,0);
			REAX FGHI 3 Bright;
			stop;
	}
}

Class ReaperBall2 : Cacodemonball
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 25;
		Damage 150;
		Damagetype "wepsoul";
		SeeSound "none";
		DeathSound "weapons/solexp";
		RENDERSTYLE "ADD";
		+SEEKERMISSILE
		+EXTREMEDEATH
		+FORCEXYBILLBOARD
		+DONTREFLECT
		+SCREENSEEKER
		+FORCERADIUSDMG
		+PIERCEARMOR
		+NODAMAGETHRUST
	}

	States
	{
		Spawn:
			REA2 A 0 Bright;
			REA2 ABCDE 2 Bright;
			REA2 F 0 Bright A_SpawnItemEx("ReaperShot",0,0,0,18,0,0,45,0,0);
			REA2 F 0 Bright A_SpawnItemEx("ReaperShot",0,0,0,18,0,0,135,0,0);
			REA2 F 0 Bright A_SpawnItemEx("ReaperShot",0,0,0,18,0,0,225,0,0);
			REA2 F 0 Bright A_SpawnItemEx("ReaperShot",0,0,0,18,0,0,315,0,0);
			REA2 FA 2 Bright {A_Explode(128,128,0);A_SeekerMissile(1,3,SMF_LOOK|SMF_PRECISE);}
			REA2 B 2 Bright {A_Explode(128,128,0);A_SeekerMissile(1,2,SMF_LOOK|SMF_PRECISE);}
			REA2 CDE 2 Bright {A_Explode(128,128,0);A_SeekerMissile(1,3,SMF_LOOK|SMF_PRECISE);}
			goto Spawn+6;
		Death:
			TNT1 A 9 Bright A_Explode(400,256,0);
			TNT1 AA 0 Bright A_SpawnItemEx("HolyMissile2",0,0,0,0,0,0,0,0,0);
			TNT1 A 4 Bright {A_SpawnItemEx("SoulPuff2",frandom(-60,60),frandom(-60,60),frandom(-60,60),0,0,0,0,0,0);A_SpawnItemEx("SoulPuff2",frandom(-60,60),frandom(-60,60),frandom(-60,60),0,0,0,0,0,0);A_SpawnItemEx("SoulPuff2",frandom(-60,60),frandom(-60,60),frandom(-60,60),0,0,0,0,0,0);}
			TNT1 A 4 Bright A_SpawnItemEx("SoulPuff2",frandom(-60,60),frandom(-60,60),frandom(-60,60),0,0,0,0,0,0);
			TNT1 AAAAAAAAA 4 Bright {A_SpawnItemEx("SoulPuff2",frandom(-60,60),frandom(-60,60),frandom(-60,60),0,0,0,0,0,0);A_SpawnItemEx("SoulPuff2",frandom(-60,60),frandom(-60,60),frandom(-60,60),0,0,0,0,0,0);A_SpawnItemEx("SoulPuff2",frandom(-60,60),frandom(-60,60),frandom(-60,60),0,0,0,0,0,0);}
			stop;
	}
}

Class ReaperShot : CacodemonBall
{
	Default
	{
		Damage 10;
		Speed 20;
		Renderstyle "Add";
		Alpha 0.85 ;
		Damagetype "wepsoul";
		Obituary "$OB_PROJ_DEMONEXT_REAPERSHOT";
		SeeSound "weapons/ghomis";
		DeathSound "weapons/ghohit";
		+SEEKERMISSILE
		+FORCEXYBILLBOARD
		+PIERCEARMOR
		-SCREENSEEKER
	}

	States
	{
		Spawn: 
			REAX L 2 Bright A_SpawnItemEx("SoulPuff3",0,0,0,0,0,0,0,8);
		Spawn2:
			REAX L 2 Bright A_SpawnItemEx("SoulPuff3",0,0,0,0,0,0,0,8);
			REAX L 2 Bright A_SeekerMissile(7,12,SMF_LOOK,128);
			loop;
		Death:
			SPIR KLMNO 3 Bright;
			stop;
		XDeath:
			SPIR V 3 Bright;
			SPIR W 0 Bright A_GiveToTarget("Health",1);
			SPIR WXYZ 3 Bright;
			stop;
	}
}

Class SoulPuff : actor
{
	Default
	{
		Radius 0;
		Height 1;
		+NOGRAVITY
		+NOBLOCKMAP
		+FORCEXYBILLBOARD
		Renderstyle "Normal";
		Alpha 1;
	}

	States
	{
		Spawn:
			REAX L 2 Bright;
			SPIR QRSTU 2 Bright A_FadeOut(0.2);
			Stop;
	}
}

Class SoulPuff2 : SoulPuff
{
	Default
	{
		Damagetype "wepsoul";
		Renderstyle "Add";
		Alpha 0.67;
		+NODAMAGETHRUST
	}

	States
	{
		Spawn:
			REAX A 3 Bright;
			REAX BCD 3 Bright;
			REAX E 3 Bright A_Explode(8,144,0);
			REAX FGH 3 Bright ;
			REAX IIIII 3 Bright A_FadeOut(0.10);
			Stop;
	}
}

Class SoulPuff3 : SoulPuff
{
	States
	{
		Spawn:
			TNT1 A 3;
			SPIR QRSTU 3 Bright A_FadeOut(0.1);
			Stop;
	}
}

Class UNMK_DExtActor : Actor
{
	Default
	{
		Species "Marines";
		+THRUSPECIES
		+MTHRUSPECIES
		+DOHARMSPECIES
		+DONTHARMSPECIES
		+FORCERADIUSDMG
	}
}

Class UNMK_DExtFastProjectile : FastProjectile
{
	Default
	{
		Species "Marines";
		+THRUSPECIES
		+MTHRUSPECIES
		+DOHARMSPECIES
		+DONTHARMSPECIES
		+FORCERADIUSDMG
	}
}

Class UnmakerLaser64Trail : UNMK_DExtActor{
	Default{
	Scale 0.1;
	+NOCLIP
	+NOGRAVITY
	+THRUGHOST
	}
	States{
	Spawn:
	LENR A 1 A_FadeOut(0.02);
	Loop;
	}
}
Class Unmaker64Puff: BulletPuff{
	Default{
	alpha 1;
	Scale 0.5;
	RenderStyle "Add";
	+NOBLOCKMAP
	+NOGRAVITY
	+NOEXTREMEDEATH
	+FORCEXYBILLBOARD
	+NOBLOOD
	+PUFFONACTORS
	+EXTREMEDEATH
	+ALWAYSPUFF
	-NOEXTREMEDEATH
	+ROLLSPRITE
	+ROLLCENTER
	+BRIGHT
	//+NOINTERACTION
	Decal "UnmakerBeamScorch";
	}
	int flipRoll;
	override void BeginPlay(){
		flipRoll = randompick(-1,1);
		if(random(0,1)){bXFLIP = true;}
		if(random(0,1)){bYFLIP = true;}
		A_Stop();
		super.BeginPlay();
	}
	override void tick(){
		super.tick();
		if(GetAge() >= 1){
			A_SetRoll(roll+(15 * flipRoll ) );
			if(scale.x - 0.08 > 0 && scale.y - 0.08 > 0){
				scale.x -= 0.08;scale.y -= 0.08;
			}
		}
	}
	States{
	Spawn:
	TNT1 A 0 NODELAY {
	}
	TNT1 A 0 A_Jump(256, "Decal1", "Decal2");
	
	Melee:
	TNT1 A 0 A_Jump(256, "Decal1", "Decal2");
	
	Decal1:
	UNPF AB 3 ;
	Stop;
	
	Decal2:
	UNPF CDE 2 ;
	Stop;
	}
}
Class UnmakerLaser64Spark : Actor{
	Default{
	RenderStyle "Add";
	Scale 0.0125;
	Alpha 0.95;
	+NOINTERACTION
	+NOGRAVITY
	+FORCERADIUSDMG
	}
	States{
	Spawn:
	YHE5 A 0 NoDelay A_JumpIf(Scale.X <= 0, "NULL");
	YHE5 A 0 A_SetScale(Scale.X-0.00075);
	YHE5 A 0 A_ChangeVelocity (frandom(-0.03, 0.03), frandom(-0.03, 0.03), frandom(-0.03, 0.03), 0);
	YHE5 A 1 A_FadeOut(0.05);
	Loop;
	}
}
/*
Class UNMK_StormSpray1 : Actor{
	Default{
	Radius 1;
	Height 1;
	Speed 200;
	PROJECTILE;
	Renderstyle "Add";
	Alpha 0.80;
	Damagetype "Incinerate";//"Lightning"
	DeathSound "weapons/devexp";
	+THRUGHOST
	+PIERCEARMOR
	+MTHRUSPECIES
	+THRUSPECIES
	Species "Marines";
	}
	States{
	Spawn:
		TNT1 A 1 A_BFGSpray("UNMK_StormZapper1",180,1,180,268435456,180,0);
		Goto Death;
	Death:
		TNT1 A 1 A_BFGSpray("UNMK_StormZapper1",180,1,180,268435456,180,0,BFGF_MISSILEORIGIN);
		stop;
	}
}
Class UNMK_StormSpray2 : UNMK_StormSpray1{
	States{
	Spawn:
		TNT1 A 1 A_BFGSpray("UNMK_StormZapper2",360,2,180,268435456);
		Goto Death;
	Death:
		TNT1 A 1 A_BFGSpray("UNMK_StormZapper2",360,2,180,268435456);
		stop;
	}
}
*/
Class UNMK_StormSpray : Actor
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 0;
		PROJECTILE;
		Renderstyle "Add";
		Alpha 0.80;
		Damagetype "Incinerate";//"Lightning"
		+THRUGHOST
		+PIERCEARMOR
		DeathSound "weapons/devexp";
		+MTHRUSPECIES
		+THRUSPECIES
		+FORCERADIUSDMG
		Species "Marines";
	}

	void A_UNMKSpray(class<Actor> spraytype = "BFGExtra", int numrays = 40, int damagecnt = 15, double ang = 90, double distance = 16*64, double vrange = 32, int defdamage = 0, int flags = 0)
	{
		int damage;
		FTranslatedLineTarget t;
		array < Actor > bfgtargets;
		// validate parameters
		if (spraytype == null) spraytype = "BFGExtra";
		if (numrays <= 0) numrays = 40;
		if (damagecnt <= 0) damagecnt = 15;
		if (ang == 0) ang = 90.;
		if (distance <= 0) distance = 16 * 64;
		if (vrange == 0) vrange = 32.;

		// [RH] Don't crash if no target
		if (!target) return;

		// [XA] Set the originator of the rays to the projectile (self) if
		//      the new flag is set, else set it to the player (target)
		Actor originator = (flags & BFGF_MISSILEORIGIN) ? Actor(self) : target;
		// offset angles from its attack ang
		for (int i = 0; i < numrays; i++){
			double an = angle - ang / 2 + ang / numrays*i;

			originator.AimLineAttack(an, distance, t, vrange);
			if (t.linetarget != null){//if (t.linetarget != null && bfgtargets.Find(t.linetarget) == bfgtargets.Size()) 
				//bfgtargets.Push(t.linetarget);
				Actor spray = Spawn(spraytype, t.linetarget.pos + (0, 0, t.linetarget.Height / 4), ALLOW_REPLACE);

				int dmgFlags = 0;
				Name dmgType = 'BFGSplash';

				if (spray != null)
				{
					if ((spray.bMThruSpecies && target.GetSpecies() == t.linetarget.GetSpecies()) || 
						(!(flags & BFGF_HURTSOURCE) && target == t.linetarget) ) // [XA] Don't hit oneself unless we say so.|| !t.linetarget.bSHOOTABLE 
					{
						spray.Destroy(); // [MC] Remove it because technically, the spray isn't trying to "hit" them.
						continue;
					}
					if (spray.bPuffGetsOwner) spray.target = target;
					if (spray.bFoilInvul) dmgFlags |= DMG_FOILINVUL;
					if (spray.bFoilBuddha) dmgFlags |= DMG_FOILBUDDHA;
					dmgType = spray.DamageType;
				}

				if (defdamage == 0)
				{
					damage = 0;
					for (int j = 0; j < damagecnt; ++j)
						damage += Random[BFGSpray](1, 8);
				}
				else
				{
					// if this is used, damagecnt will be ignored
					damage = defdamage;
				}

				int newdam = t.linetarget.DamageMobj(originator, target, damage, dmgType, dmgFlags|DMG_USEANGLE, t.angleFromSource);
				t.TraceBleed(newdam > 0 ? newdam : damage, self);
			}
		}
	}
	///

	States
	{
		Spawn:
			TNT1 A 1 NODELAY {
				//invoker.target.player.fov
				if(bFALLING){
					A_UNMKSpray("UNMK_StormZapper1",180,0,self.target.player.fov,PLAYERMISSILERANGE,self.target.player.fov,0);
				}
				else{
					A_UNMKSpray("UNMK_StormZapper1",180,0,self.target.player.fov,PLAYERMISSILERANGE,self.target.player.fov,0,BFGF_MISSILEORIGIN);
				}
				//BFGF_MISSILEORIGIN
				Destroy();
			}
			Goto Death;
		Death:
			TNT1 A 1 ;//A_BFGSpray("UNMK_StormZapper1",180,1,180,PLAYERMISSILERANGE,180,0,BFGF_MISSILEORIGIN);
			stop;
	}
}

Class UNMK_LightningEffect : Actor{
	Default{
		Renderstyle "Add";
		Alpha 0.75;
		Projectile;
		+FLOORHUGGER
		+NOGRAVITY
	}
	bool deathActive;
	Override Void Tick(){
		if(tracer){
			A_Warp(AAPTR_TRACER,0,0,0,0,WARPF_TOFLOOR|WARPF_NOCHECKPOSITION|WARPF_STOP|WARPF_INTERPOLATE);
		}
		SetZ(floorz);
		if(!deathActive){
			scale.y = (self.ceilingz - self.floorz)/255;
			if(random(0,1) > 0){bSPRITEFLIP = !bSPRITEFLIP;}
		}else{
			if(scale.y != GetDefaultByType(GetClass()).scale.y){
				scale.y = GetDefaultByType(GetClass()).scale.y;
			}
		}
		if(scale.x != GetDefaultByType(GetClass()).scale.x){
			scale.x = GetDefaultByType(GetClass()).scale.x;
		}
		Super.Tick();
	}
	States{
	Spawn:
		LFX4 IJKLM 1 Bright ;// A_JumpIf(!master,"Death");
		stop;
		//loop;
	Death:
		TNT1 A 0 {deathActive = true;}
		LFX1 NOPQR 2 Bright;
		stop;
	}
}
Class UNMK_StormZapper1 : Actor{
	Default{
	Radius 1;
	Height 1;
	Renderstyle "Add";
	Alpha 0.80;
	Projectile;
	DamageType "Incinerate";
	Species "Marines";
	+PIERCEARMOR
	+THRUSPECIES
	+MTHRUSPECIES
	+DONTHARMSPECIES
	-DOHARMSPECIES
	+DONTREFLECT
	+NODAMAGETHRUST
	+PUFFGETSOWNER
	+HITTRACER
	+FOILBUDDHA
	+FOILINVUL
	+FORCERADIUSDMG
	}
	
	Override Void Tick(){
		if(tracer){A_Warp(AAPTR_TRACER);}
		A_Explode(16,32,XF_NOALLIES);
		Super.Tick();
	}
	//floorz
	//ceilingz
	void A_SoulLightningStrike(class<Actor> MissileUp = "UNMK_StormStrike1", class<Actor> MissileDown = "UNMK_StormStrike4"){
		Actor MisUp;Actor MisDown;
		MisUp = A_SpawnProjectile(MissileUp,0,0,0,CMF_TRACKOWNER,90);
		MisDown = A_SpawnProjectile(MissileDown,0,0,0,CMF_TRACKOWNER,-90);
		//if(MisUp){int properheight = MisUp.ceilingz - MisUp.pos.z;}
		//if(MisDown){int properheight = MisDown.pos.z - MisDown.floorz;}
		bool a; actor b;
		[a,b] = A_SpawnItemEx("UNMK_LightningEffect",0,0,floorz,0,0,0);
		if(b){b.tracer = self.tracer;b.master = self;}
	}
	States{
	Spawn:
		LFX1 S 0 NODELAY A_SoulLightningStrike();
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike();
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike();
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike();
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike();
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike();
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike();
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike("UNMK_StormStrike2","UNMK_StormStrike5");
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike("UNMK_StormStrike2","UNMK_StormStrike5");
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike("UNMK_StormStrike2","UNMK_StormStrike5");
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike("UNMK_StormStrike2","UNMK_StormStrike5");
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike("UNMK_StormStrike2","UNMK_StormStrike5");
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike("UNMK_StormStrike2","UNMK_StormStrike5");
		LFX1 STUVW 1 Bright ;//A_Explode(16,32,XF_NOALLIES);
		LFX1 S 0 A_SoulLightningStrike("UNMK_StormStrike2","UNMK_StormStrike5");
		LFX1 STUVW 1 Bright A_Explode(16,32,XF_NOALLIES);//A_Explode(32,32,XF_NOALLIES);
		stop;
	}
}
Class UNMK_StormZapper2 : UNMK_StormZapper1{
	Override Void Tick(){
		if(tracer){A_Warp(AAPTR_TRACER);}
		A_Explode(32,64,XF_NOALLIES);
		Super.Tick();
	}
	States{
	Spawn:
		LFX2 K 0 NODELAY A_SoulLightningStrike("UNMK_StormStrike3","UNMK_StormStrike6");
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike("UNMK_StormStrike3","UNMK_StormStrike6");
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike("UNMK_StormStrike3","UNMK_StormStrike6");
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike("UNMK_StormStrike3","UNMK_StormStrike6");
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike("UNMK_StormStrike3","UNMK_StormStrike6");
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike("UNMK_StormStrike3","UNMK_StormStrike6");
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike();
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike();
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike();
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike();
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike();
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		LFX2 K 0 A_SoulLightningStrike();
		LFX2 KLMNO 1 Bright ;//A_Explode(32,64,XF_NOALLIES);
		stop;
	}
}

Class UNMK_StormStrike1 : Actor{
	Default{
	Radius 16;
	Height 1;
	Speed 90;
	Damage 2;
	PROJECTILE;
	Damagetype "Incinerate";//"Lightning"
	Renderstyle "None";//Add
	Alpha 0.75;
	Species "Marines";
	DeathSound "weapons/devzap";
	+PIERCEARMOR
	+THRUGHOST
	+RIPPER
	+NODAMAGETHRUST
	+DONTREFLECT
	+STRIFEDAMAGE
	+THRUSPECIES
	+MTHRUSPECIES
	+DONTHARMSPECIES
	-DOHARMSPECIES
	+FORCERADIUSDMG
	}
	States{
	Spawn:
		LFX1 IJKLM 1 Bright A_Explode(32,64,XF_NOALLIES);
		loop;
	Death:
		LFX1 NOPQR 2 Bright;
		stop;
	}
}

Class UNMK_StormStrike2 : UNMK_StormStrike1{
	Default{
	Speed 35;
	Damage 0;
	DeathSound "weapons/gnthit";
	}
	States{
	Spawn:
		LFX1 ABC 1 Bright A_Explode(16,64,XF_NOALLIES);
		loop;
	Death:
		LFX1 DEFGH 2 Bright;
		stop;
	}
}

Class UNMK_StormStrike3 : UNMK_StormStrike1{
	Default{
	Speed 120;
	Damage 4;
	DeathSound "weapons/shock";
	}
	States{
	Spawn:
		LFX2 FGHIJ 1 Bright A_Explode(64,64,XF_NOALLIES);
		loop;
	Death:
		LFX2 A 2 Bright A_Explode(32,128,XF_NOALLIES);
		LFX2 BCDE 2 Bright;
		stop;
	}
}

Class UNMK_StormStrike4 : UNMK_StormStrike1{
	States{
	Spawn:
		LFX3 DEFGH 1 Bright A_Explode(16,32,XF_NOALLIES);
		loop;
	Death:
		LFX1 NOPQR 2 Bright;
		stop;
	}
}

Class UNMK_StormStrike5 : UNMK_StormStrike2{
	States{
	Spawn:
		LFX3 ABC 1 Bright A_Explode(8,16,XF_NOALLIES);
		loop;
	Death:
		LFX1 DEFGH 2 Bright;
		stop;
	}
}

Class UNMK_StormStrike6 : UNMK_StormStrike3{
	States{
	Spawn:
		LFX3 IJKLM 1 Bright A_Explode(32,64,XF_NOALLIES);
		loop;
	Death:
		LFX2 A 2 Bright A_Explode(32,128,XF_NOALLIES);
		LFX2 BCDE 2 Bright;
		stop;
	}
}
