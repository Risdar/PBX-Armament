//////////////////////////// LEVER ACTION RIFLE ////////////////////////////////////////////////////////////////////////////////////
class PB_357Magnum : PB_500SW
{
	Default
	{
		PB_Projectile.BaseDamage 120;
		PB_Projectile.RipperCount 4;
		PB_Projectile.PenetrationCount 5;
		PB_Projectile.SpeedFPS 1670;
		+PB_Projectile.WHIZCRACK;
		Obituary "$OB_PROJ_357MAGNUM";
	}
}

class PB_444Marlin : PB_500SW
{
	Default
	{
		PB_Projectile.BaseDamage 210;
		PB_Projectile.RipperCount 5;
		PB_Projectile.PenetrationCount 5;
		PB_Projectile.SpeedFPS 2450;
		+PB_Projectile.WHIZCRACK;
		DamageType "SSG";
		Obituary "$OB_PROJ_444MARLIN";
	}
}

//////////////////////////// METAL SNIPER ////////////////////////////////////////////////////////////////////////////////////
class MS_ResonanceRounds : PB_762x51mmAP
{
	Default
	{
		PB_Projectile.BaseDamage 300;
		PB_Projectile.RipperCount 8;
		PB_Projectile.PenetrationCount 5;
        DamageType "Stun";
		+PB_Projectile.WHIZCRACK;
		Obituary "$OB_PROJ_RESOROUND";
	}
	
	override int SpecialMissileHit(Actor victim)
	{
		pbxcore_debug.print("Resonance Projectile Shot");
		if(!(victim is "Shield"))
			return super.SpecialMissileHit(victim);

		pbxcore_debug.print("Target is shield");

		let mActor = PB_StunGrenadeExplosion(Spawn("PB_StunGrenadeExplosion",self.pos));
		if(mActor)
		{
			pbxcore_debug.print("spawned stun explosion");
			mActor.target = target.player.mo;
			mActor.expDmg  = 250;
			mActor.expRad  = 1024;
			mActor.expType = "Stun";
		}
		A_StopSound(CHAN_BODY);
		A_StartSound("Explosion", CHAN_AUTO,CHANF_OVERLAP);
		A_StartSound("FAREXPL", CHAN_AUTO,CHANF_OVERLAP);
		Radius_Quake (3, 8, 0, 15, 0);
		return super.SpecialMissileHit(victim);
	}

}

//////////////////////////// NEO HMG ////////////////////////////////////////////////////////////////////////////////////
class PB_792x57mm_Heated : PB_792x57mm
{
	Default
	{
		PB_Projectile.BaseDamage 45;
		PB_Projectile.RipperCount 8;
		PB_Projectile.PenetrationCount 3;
		+PB_Projectile.WHIZCRACK;
		+PB_Projectile.SMALLIMPACT;
		DamageType "Fire";
		Obituary "$OB_PROJ_792x57MM_HEATED";
	}
}

class ShieldParticle : VisualThinker
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		texture = TexMan.CheckForTexture('SPKGA0');
		scale = (0.01,0.01);
		alpha = 1;
		flags = SPF_FULLBRIGHT;
		SetRenderStyle(STYLE_Add);
	}
	
	override void Tick()
	{
		if(alpha <= 0)
		{
			Destroy();
		}
		vel.z -= 0.2;
		alpha -= 0.04;
		Super.Tick();
	}
}

//////////////////////////// ETERNAL CHAINGUN ////////////////////////////////////////////////////////////////////////////////////
class EternalChaingunTracer : PB_556x45mmAP
{

    Default
    {
        Scale .9;
		+PB_PROJECTILE.NOCRITICALS
    }

    States
    {
        Spawn:
            PRTL A 1 BRIGHT;
            Loop;

        Death:
            TNT1 A 0;
            TNT1 A 1;
            TNT1 a 2;
        XDeath:
            TNT1 A 0 A_Explode(8, 50);
            Stop;
    }
}

class EChaingunFreeze : EternalChaingunTracer
{
	Default
	{
        DamageType "Ice";
	}
}



class EChaingunLightning : EternalChaingunTracer
{
	mixin PBX_LightningProjectile;

	Default
	{
        PB_Projectile.BaseDamage 25;
        EChaingunLightning.DetectRange 256;
        EChaingunLightning.MaxVictims 3;
		EChaingunLightning.SplitRange 256;
		EChaingunLightning.Damage 1;
		EChaingunLightning.Duration 1;
		EChaingunLightning.Delay 2;
		EChaingunLightning.maxChains 1;
		EChaingunLightning.MaxLinks 1;
		EChaingunLightning.DamageType 'plasma';
        Translation "112:127=192:207", "224:231=80:87";
		+PB_PROJECTILE.NOCRITICALS
	}

	override void Tick()
	{
		Super.Tick();
		if (isFrozen()) return;

		L_ProjTick();
	}
}

