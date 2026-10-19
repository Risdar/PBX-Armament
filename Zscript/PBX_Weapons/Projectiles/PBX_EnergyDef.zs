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

//////////////////////////// FUNNY CACO ////////////////////////////////////////////////////////////////////////////////////
class CacoBallPlayer : PB_ProjectileAlt
{
    const ORB_DURATION = 35;
    const ORB_RANGE = 800.0;       // How far the orbiters look for enemies
    const ORB_LAUNCH_SPEED = 16.0;
    const ORB_AMOUNT = 3;

    bool isAlive;
    int startTime;

    double orbInitX[ORB_AMOUNT];
    double orbInitY[ORB_AMOUNT];

    Actor lastKnownTarget;
    Actor orbiters[ORB_AMOUNT];
    double initialVelocity;
    int CascadeTimer;
    int OrbTimer;
    double dist;
    int checkDistanceTimer;
    int distanceTimerInterval;
    int launchStartTime;

    Default
    {
        DamageType "Plasma";
        SeeSound "pb/monsters/caco/spit";
        DeathSound "CacoBallImpact";
        Radius 8;
        Height 8;
        Speed 12;
        FastSpeed 20;
        PB_Projectile.BaseDamage PBX_RideableCaco.CACOBALL_DIRECT_DAMAGE;
		+PB_PROJECTILE.NOCRITICALS
        RenderStyle "Add";
        Alpha 0.99;
        +THRUGHOST;
        +RANDOMIZE;
        Projectile;
        Scale 0.58;
    }

    Actor FindNearestEnemy(Actor from, double range)
    {
        Actor victim = null;
        double bestDist = range;

        BlockThingsIterator it = BlockThingsIterator.Create(from, range);
        while (it.Next())
        {
            Actor mo = it.thing;
            if (!mo || mo == from || mo == self.target) continue;
            if (mo.health <= 0) continue;
            if (!mo.bIsMonster || !mo.bShootable) continue;
            if (mo.bFriendly) continue;
            if (self.target && mo.IsFriend(self.target)) continue;

            double d = from.Distance3D(mo);
            if (d >= bestDist) continue;
            if (!from.CheckSight(mo)) continue;

            bestDist = d;
            victim = mo;
        }
        return victim;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        isAlive = true;
        startTime = level.time;
        initialVelocity = vel.Length() > 0 ? vel.Length() : 12;
        CascadeTimer = 35;
        OrbTimer = 22;
        checkDistanceTimer = 5;
        launchStartTime = -1;
        dist = 4096;

        double centerX = self.pos.x;
        double centerY = self.pos.y;

        for (int i = 0; i < ORB_AMOUNT; i++)
        {
            double angleDeg = i * 120.0;
            orbInitX[i] = 30.0 * Cos(angleDeg);
            orbInitY[i] = 30.0 * Sin(angleDeg);

            Actor orb = Spawn("Plasma_Ball", (centerX + orbInitX[i], centerY + orbInitY[i], self.pos.z), ALLOW_REPLACE);
            if (orb)
            {
                orb.master = self;
                orb.target = self.target;   // so it won't hurt the player
                orbiters[i] = orb;
            }
        }
    }

    override void Tick()
    {
        Super.Tick();
        if (!isAlive) return;

        int ticDiff = level.time - startTime;

        if (level.time - distanceTimerInterval >= checkDistanceTimer)
        {
            distanceTimerInterval = level.time;

            // Check for targets
            lastKnownTarget = FindNearestEnemy(self, ORB_RANGE);
            dist = lastKnownTarget ? distance3d(lastKnownTarget) : 4096;

            // Avoid walls/floors
            FLineTraceData traceData;
            bool traceResult = self.LineTrace(angle, 75, 25, TRF_THRUACTORS, 0, 0, 0, data: traceData);
            if (traceResult && (traceData.HitType == TRACE_HitFloor || traceData.HitType == TRACE_HitWall))
            {
                if (vel.z != 0) vel.z += 0.3;
            }
        }

        // Start seeking when an enemy is in range
        if (launchStartTime == -1 && dist <= ORB_RANGE)
            launchStartTime = level.time;

        // Decelerate when close
        if (dist <= 700)
        {
            double timePassed = double(ticDiff - CascadeTimer);
            double decelerationRate = (initialVelocity * 0.5) / 40.0;
            double velocityFactor = Max(initialVelocity * 0.5, initialVelocity - (timePassed * decelerationRate));
            if (vel.Length() > 0) vel = vel.Unit() * velocityFactor;
        }

        // Orbit
        double rotationAngleDeg = ticDiff * (360.0 / double(ORB_DURATION));

        for (int i = 0; i < ORB_AMOUNT; i++)
        {
            if (!orbiters[i]) continue;

            if (launchStartTime != -1 && level.time >= launchStartTime + (i * OrbTimer))
            {
                LaunchOrbiter(i);
                continue;
            }

            double rx = orbInitX[i] * Cos(rotationAngleDeg) - orbInitY[i] * Sin(rotationAngleDeg);
            double ry = orbInitX[i] * Sin(rotationAngleDeg) + orbInitY[i] * Cos(rotationAngleDeg);
            orbiters[i].SetOrigin((self.pos.x + rx, self.pos.y + ry, self.pos.z), true);
        }
    }

    void LaunchOrbiter(int i)
    {
        Actor orb = orbiters[i];
        if (!orb) return;

        // Each orb picks its own nearest enemy at launch time
        Actor tgt = FindNearestEnemy(orb, ORB_RANGE * 1.5);

        Vector3 dir;
        if (tgt)
        {
            Vector3 aim = (tgt.pos.x, tgt.pos.y, tgt.pos.z + tgt.height * 0.5);
            dir = (aim - orb.pos);
        }
        else
        {
            // If no enemy then just follow the main projectile
            dir = vel;
        }

        if (dir.Length() > 0) dir = dir.Unit();
        else dir = (Cos(angle), Sin(angle), 0);

        orb.vel = dir * ORB_LAUNCH_SPEED;
        orb.angle = VectorAngle(dir.x, dir.y);
        orb.pitch = -ASin(dir.z);
        orb.master = null;

        orbiters[i] = null;
    }

    override void OnDestroy()
    {
        Super.OnDestroy();
        isAlive = false;

        for (int i = 0; i < ORB_AMOUNT; i++)
        {
            if (orbiters[i])
            {
                orbiters[i].Destroy();
                orbiters[i] = null;
            }
        }
    }

    States
    {
        Spawn:
            0DB0 A 1 BRIGHT A_StartSound("CacoBallLoop", CHAN_BODY, CHANF_LOOP, 1);
        Fly:
            0DB0 BCDEFA 2 BRIGHT A_SpawnProjectile("RailGunTrailSpark", 0, 0, random(0, 360), CMF_AIMDIRECTION|CMF_ABSOLUTEPITCH|CMF_OFFSETPITCH|CMF_BADPITCH|CMF_SAVEPITCH, random(0, 360));
            Loop;

        Death:
            TNT1 A 0 {
                A_StopSound(CHAN_BODY);
                A_StartSound("CacoBallImpact", CHAN_AUTO);
                A_SpawnItem("Plasma_Puff", 0);
                isAlive = false;
            }
            TNT1 A 4;
            Stop;
    }
}