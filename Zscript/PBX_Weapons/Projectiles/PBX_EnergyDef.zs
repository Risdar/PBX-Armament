//////////////////////////// PLASMA BLASTER ////////////////////////////////////////////////////////////////////////////////////
class HellPistolNormal : PB_ProjectileAlt
{
    Default
    {
        PB_Projectile.BaseDamage 35;
		+PB_PROJECTILE.NOCRITICALS
        DamageType "Plasma";
        Speed 350;
    }
}

class HellPistolAuto : HellPistolNormal
{
    Default
    {
        PB_Projectile.BaseDamage 20;
        Speed 100;
    }
}

class HellPistolCharge : HellPistolNormal
{
    Default
    {
        PB_Projectile.BaseDamage 150;
        Speed 350;
        Scale 1.5;
        Height 2.0;
    }
}

//////////////////////////// PROSURV BLASTER ////////////////////////////////////////////////////////////////////////////////////
class ProsurvBlasterProjectile : PB_ProjectileAlt
{
    Default
    {
        
        +BLOODSPLATTER ;
        -DONTSPLASH;
        speed 200;
        PB_Projectile.BaseDamage 10;
		+PB_PROJECTILE.NOCRITICALS
        // damage 3;
        scale 0.3;
        RenderStyle "Add";
        Alpha 0.2;
        radius 2;
        height 2;
        damagetype "Plasma";
        Decal "BulletPuff";
    }
    
    void SpawnTrail()
    {    
        static const double ALPHAS[] =
        {
            0.85, 0.80, 0.75, 0.70, 0.65, 0.60,
            0.55, 0.50, 0.45, 0.40, 0.35, 0.30
        };

        for (int i = 0; i < ALPHAS.Size(); i++)
        {
            double t = (i + 1) * 2.0;
            double ox = (t * Vel.X) / -35.0;
            double oy = -(t * Vel.Y) / -35.0;
            double oz = 2.0 + (t * Vel.Z) / -35.0;

            let [success, trail] = A_SpawnItemEx("ProsurvBlasterTracerTrail", ox, oy, oz, 0, 0, 0, 0, SXF_ABSOLUTEANGLE, 0);
            if (success && trail) 
                trail.A_SetRenderStyle(ALPHAS[i], STYLE_Add);
        }
    }

    States
    {
         Spawn:
            TNT1 A 1 NoDelay BRIGHT { 
                A_SpawnItemEx("ProsurvBlasterTracerTrail", 0, 0, 2); 
                SpawnTrail(); 
            }
            Loop;

        Death:
            TNT1 AAAAA 0 A_SpawnItem("BlueFlareSmall");
            TNT1 AAAAA 0 A_CustomMissile ("BluePlasmaParticle", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 B 1 A_Explode(2,50,1);
            BL1I ABCD 1 BRIGHT A_SpawnItem("BlueFlareSmall");
            TNT2 AA 3 A_CustomMissile ("PlasmaSmoke", 1, 0, random (0, 360), 2, random (0, 160));
            Stop;
    }
}

class ProsurvBlasterTracerTrail : actor
{
    Default
    {
        Scale 0.04;
        RenderStyle "Add";
        Alpha 0.9;
        +NOINTERACTION;
        +CLIENTSIDEONLY;
    }

    States
    {
        Spawn:
            SPKB A 2 BRIGHT;
            stop;
    }
}