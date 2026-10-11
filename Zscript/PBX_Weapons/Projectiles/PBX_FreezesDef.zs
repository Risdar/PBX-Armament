// Freeze effects
// From Cat's Frozen Addon Pack
// by SchrödingCat, Eriance/Amuscaria, Realm667
// Bloax, ZZrionTheInsect, Xaser & Ethrill, Tomtefar, SchrödingCat
// You can find the full credits in Credits/credits_CatsFrozenAddon.txt

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        FLARES       ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class Flare_GeneralZS : Actor
{
    Default
    {
        +NOINTERACTION;
        +NOGRAVITY;
        +FORCEXYBILLBOARD;
        +SQUAREPIXELS;
        //;
        +CLIENTSIDEONLY;
        renderstyle "ADD";
        radius 1;
        height 1;
        alpha 0.4;
        scale 0.4;
    }
}

class CryoFlare : Flare_GeneralZS
{
    Default
    {
        alpha 0.4;
        scale 0.3;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay A_Jump(128, 2);
        L9NB A 1 bright;
        stop;
        TNT1 A 0;
        L9NB B 1 bright;
        stop;
    }
}
class CryoFlareSpawn : Actor
{
    Default
    {
        Speed 20;
        PROJECTILE;
        +NOCLIP;
    }
    States
    {
        Spawn:
        TNT1 A 1 NoDelay A_SpawnProjectile("CryoFlare", -5, 0, -85, 0, random(-10, 10), AAPTR_TARGET);
        stop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        FREEZERSTUFF         ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class FreezeExplSmall : Actor
{
    Default
    {
        +NOBLOCKMAP;
        +MISSILE;
        +DONTSPLASH;
        Damagetype "Freeze";
        DeathSound "FRZFIRE2";
        Height 32;
        RenderStyle "ADD";
        Alpha 0.8;
        Scale 1.5;
        +NODAMAGETHRUST;
        +FORCEXYBILLBOARD;
        +FORCERADIUSDMG;
        //;
        MissileHeight 8;
        Decal "IceScorch";
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            A_SpawnItemEx("BluePlasmaParticleSpawner", 0, 0, -20);
            A_SpawnItemEx("BlueFlareSpawn", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("BlueFlare3", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        TNT1 AAAA 0
        {
            A_SpawnProjectile("BluePlasmaFire", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
            A_SpawnProjectile("BluePlasmaParticle", 0, 0, random(0, 360), 2, random(0, 90), AAPTR_TARGET);
            A_SpawnProjectile("BluePlasmaParticle", 0, 0, random(0, 360), 2, random(0, 90), AAPTR_TARGET);
        }
        TNT1 AA 0
        {
            A_SpawnProjectile("RealisticFireSparks1Blue", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
            A_SpawnProjectile("RealisticFireSparks1Blue", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
            A_SpawnProjectile("BigPlasmaParticleX", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
            A_SpawnProjectile("BigPlasmaParticleX", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
        }
        TNT1 A 0
        {
            A_ALertMonsters();
            A_StartSound("FRZFIRE2", 3, CHANF_DEFAULT, 3);
            A_SpawnItem("CryoSmoke");
        }
        BXPL A 0 Bright
        {
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
            A_Explode(10*random(5, 6), 200);
        }
        //Freezerballs
        BXPL A 0
        {
            A_SpawnItemEx("SmallFreezerBall", -4, 0, -1, random(-50, 10), random(-20, 10), random(-20, 40));
            A_SpawnItemEx("SmallFreezerBall", -2, 0, -1, random(-20, 30), random(-20, 40), random(-20, 40));
            A_SpawnItemEx("SmallFreezerBall", 0, 0, -1, random(-20, 20), random(-20, 30), random(-20, 40));
            A_SpawnItemEx("SmallFreezerBall", 1, 0, -1, random(-10, 20), random(-20, 40), random(-20, 40));
            A_SpawnItemEx("SmallFreezerBall", 2, 0, -1, random(-20, 10), random(-20, 20), random(-20, 40));
            A_SpawnItemEx("SmallFreezerBall", 4, 0, -1, random(-20, 30), random(-20, 20), random(-20, 40));
        }
        BXPL AAAAAA 0 Bright
        {
            A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        }
        BXPL AAA 0 Bright A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAA 0 Bright A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL AAA 0 Bright
        {
            A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
            A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        }
        BXPL ABCDEFGH 1 Bright;
        BXPL IJKLLM 1 Bright A_FadeOut(0.1);
        stop;
    }
}
class FreezeDotDamage1 : Actor
{
    Default
    {
        Radius 6;
        Height 6;
        Speed 10;
        DamageFunction (5);
        DamageType "Freeze";
        PROJECTILE;
        +NODAMAGETHRUST;
        +BLOODLESSIMPACT;
        +PAINLESS;
    }
    States
    {
        Spawn:
        BUBL B 2;
        Death:
        BUBL B 4;
        stop;
    }
}
class FreezerTrailSparksWhite : Actor
{
    Default
    {
        RenderStyle "ADD";
        Scale 0.008;
        Alpha 0.70;
        +NOGRAVITY;
        +CLIENTSIDEONLY;
        +BLOODLESSIMPACT;
        +PAINLESS;
    }
    States
    {
        Spawn:
        YA66 B 3 NoDelay bright
        {
            A_JumpIf(scale.x<=0, "NULL");
            A_SetScale(scale.x-0.00075);
            A_ChangeVelocity(frandom(-0.8, 0.8), frandom(-0.8, 0.8), frandom(-0.8, 0.8), 0);
        }
        YA66 B 1 bright A_FadeOut(0.02);
        loop;
    }
}
// : FastProjectile
class FreezerTrailSparksSpeed : Actor
{
    Default
    {
        RenderStyle "ADD";
        Scale 0.5;
        Alpha 0.70;
        Speed 15;
        //;
        PROJECTILE;
        Radius 2;
        Height 2;
        BOUNCETYPE "DOOM";
        +NOGRAVITY;
        +CLIENTSIDEONLY;
        BounceType "Grenade";
        //;
        +DONTHARMCLASS;
        //;
        +THRUSPECIES;
        //;
        +MTHRUSPECIES;
        +RIPPER;
        +MISSILE;
        +CANNOTPUSH;
        +BLOODLESSIMPACT;
        +PAINLESS;
    }
    States
    {
        Spawn:
        TNT1 A 3;
        SpawnLoop:
        SNOW A 0; //NoDelay A_JumpIf(ScaleX <= 0 , "NULL")__TERMINATE__
        SNOW A 0; //A_SetScale(ScaleX-0.05)__TERMINATE__
        SNOW A 3 bright A_ChangeVelocity(frandom(-0.8, 0.8), frandom(-0.8, 0.8), frandom(-0.8, 0.8), 0);
        SNOW A 1 bright A_FadeOut(0.02);
        loop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        CLOUDS            ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class FreezeCloud3 : SlowingCloud
{
    Default
    {
        +BLOODLESSIMPACT;
        //;
        +FORCERADIUSDMG;
        +DONTBLAST;
        +FOILINVUL;
        +NODAMAGETHRUST;
        BOUNCETYPE "DOOM";
        +PAINLESS;
        -MISSILE;
        +DONTHARMCLASS;
        +THRUSPECIES;
        +MTHRUSPECIES;
        +RIPPER;
        +DONTSPLASH;
        //;
        +FRIENDLY;
        Species "Marines";
        BounceType "Grenade";
        damagetype "Freeze";
        Damage 0;
        gravity 0.005;
        Translation "0:255=%[0.0,0.0,0.0]:[0.5,0.8,1.0]";
        Alpha 0.40;
        Height 16;
        PROJECTILE;
        Radius 1;
        RenderStyle "SHADED";
        StencilColor "A0 FF FF";
        Scale 0.5;
        Speed 2;
        SeeSound "none";
        DeathSound "none";
        AttackSound "none";
    }
    States
    {
        Spawn:
        WPXS A 0 NoDelay A_Jump(230, 3, 7, 11, 15, 19, 23, 27);
        WPXS AB 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS CD 2 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(2, 64, 0, 0, 16);
        WPXS EF 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS GH 2 A_FadeOut(0.03);
        // TNT1 A 0 A_Explode(4 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS IJ 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS KL 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(4 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS MN 2 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(1, 32, 0, 0, 16);
        WPXS OP 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(4 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS QR 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(0.8);
        WPXS STUV 2 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(4, 64, 0, 0, 16);
        WPXS WXYZ 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(4 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXZ ABC 3 A_FadeOut(0.03);
        TNT1 A 0;
        stop;
    }
}
class FreezeCloud4 : FreezeCloud3
{
    Default
    {
        Speed 20;
        Alpha 0.50;
        Scale 1.7;
    }
    States
    {
        Spawn:
        TNT1 A 3;
        WPXS A 0 A_Jump(128, 3, 7, 11);
        WPXS AB 2 A_FadeOut(0.01);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        TNT1 A 0 A_SetScale(3.0);
        WPXS CD 2 A_FadeOut(0.01);
        TNT1 A 0
        {
            A_SetScale(3.2);
            A_Explode(4, 64, 0, 0, 16);
        }
        WPXS EF 2 A_FadeOut(0.01);
        TNT1 A 0 A_SetScale(3.5);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS GH 2 A_FadeOut(0.01);
        TNT1 A 0 A_SetScale(3.7);
        //TNT1 A 0 A_Explode(4 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS IJ 2 A_FadeOut(0.01);
        TNT1 A 0 A_SetScale(3.9);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS KL 2 A_FadeOut(0.01);
        TNT1 A 0
        {
            A_Explode(4, 64, 0, 0, 16);
            A_SetScale(4.2);
        }
        WPXS MN 2 A_FadeOut(0.02);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS OP 2 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(4.5);
        //TNT1 A 0 A_Explode(6 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS QR 2 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(4.8);
        WPXS ST 2 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(5.2);
        WPXS UV 2 A_FadeOut(0.02);
        TNT1 A 0 A_Explode(6, 64, 0, 0, 16);
        WPXS WX 2 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(5.8);
        WPXS YZ 2 A_FadeOut(0.02);
        //TNT1 A 0 A_Explode(6 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXZ ABC 3 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(6.4);
        stop;
    }
}
class FreezeCloud5 : FreezeCloud3
{
    Default
    {
        Speed 20;
        Alpha 0.50;
        Scale 1.7;
    }
    States
    {
        Spawn:
        WPXS A 0 NoDelay A_Jump(128, 3, 7, 11);
        WPXS AB 2 A_FadeOut(0.01);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        TNT1 A 0 A_SetScale(3.0);
        WPXS CD 2 A_FadeOut(0.01);
        TNT1 A 0 A_SetScale(3.2);
        //TNT1 A 0 A_Explode(10 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS EF 2 A_FadeOut(0.01);
        TNT1 A 0 A_SetScale(3.5);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS GH 2 A_FadeOut(0.01);
        TNT1 A 0
        {
            A_SetScale(3.7);
            A_Explode(6, 64, 0, 0, 16);
        }
        WPXS IJ 2 A_FadeOut(0.01);
        TNT1 A 0 A_SetScale(3.9);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS KL 2 A_FadeOut(0.01);
        TNT1 A 0
        {
            A_Explode(6, 64, 0, 0, 16);
            A_SetScale(4.2);
        }
        WPXS MN 2 A_FadeOut(0.02);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS OP 2 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(4.5);
        //TNT1 A 0 A_Explode(10 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS QR 2 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(4.8);
        WPXS ST 2 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(5.2);
        WPXS UV 2 A_FadeOut(0.02);
        //TNT1 A 0 A_Explode(10 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS WX 2 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(5.8);
        WPXS YZ 2 A_FadeOut(0.02);
        TNT1 A 0 A_Explode(6, 64, 0, 0, 16);
        WPXZ ABC 3 A_FadeOut(0.02);
        TNT1 A 0 A_SetScale(6.4);
        stop;
    }
}
class FreezeCloudSmall : FreezeCloud3
{
    Default
    {
        scale 0.4;
        Alpha 0.3;
    }
    States
    {
        Spawn:
        WPXS A 0 NoDelay A_Jump(230, 3, 7, 11, 15, 19, 23, 27);
        WPXS AB 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS CD 2 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(2, 64, 0, 0, 16);
        WPXS EF 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS GH 2 A_FadeOut(0.03);
        // TNT1 A 0 A_Explode(4 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS IJ 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 32 , 0 , 0 , 16)__TERMINATE__
        WPXS KL 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(4 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS MN 2 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(1, 32, 0, 0, 16);
        WPXS OP 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(4 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXS QR 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(0.2);
        WPXS STUV 2 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(8, 64, 0, 0, 16);
        WPXS WXYZ 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(4 , 64 , 0 , 0 , 16)__TERMINATE__
        WPXZ ABC 3 A_FadeOut(0.03);
        TNT1 A 0;
        stop;
    }
}
class FreezeCloudSpawnerLong : Actor
{
    Default
    {
        +NOGRAVITY;
        Height 0;
        Radius 0;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay A_JumpIfInventory("FreezeSpawnerCheck", 10, "cloudend");
        TNT1 AAAAAA 2 A_SpawnItemEx("FreezeCloud", frandom(-50, 50), frandom(-50, 50), frandom(0, 40), 0, 0, 0);
        TNT1 A 0 A_GiveInventory("FreezeSpawnerCheck", 1);
        loop;
        cloudend:
        TNT1 A 0;
        stop;
    }
}
class FreezeCloudSpawner : Actor
{
    Default
    {
        +NOGRAVITY;
        Height 0;
        Radius 0;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay A_JumpIfInventory("FreezeSpawnerCheck", 4, "cloudend");
        TNT1 AAAA 2 A_SpawnItemEx("FreezeCloud", frandom(-50, 50), frandom(-50, 50), frandom(0, 40), 0, 0, 0);
        TNT1 A 0 A_GiveInventory("FreezeSpawnerCheck", 1);
        loop;
        cloudend:
        TNT1 A 0;
        stop;
    }
}
class FreezeCloudSpawnerShort : Actor
{
    Default
    {
        +NOGRAVITY;
        Height 0;
        Radius 0;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay A_JumpIfInventory("FreezeSpawnerCheck", 2, "cloudend");
        TNT1 AAAA 2 A_SpawnItemEx("FreezeCloud", frandom(-50, 50), frandom(-50, 50), frandom(0, 40), 0, 0, 0);
        TNT1 A 0 A_GiveInventory("FreezeSpawnerCheck", 1);
        loop;
        cloudend:
        TNT1 A 0;
        stop;
    }
}
class BaronFreezeCloudSpawner : Actor
{
    Default
    {
        +NOGRAVITY;
        Height 0;
        Radius 0;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay A_JumpIfInventory("FreezeSpawnerCheck", 2, "cloudend");
        TNT1 AA 2 A_SpawnItemEx("BaronFreezeCloud", frandom(-50, 50), frandom(-50, 50), frandom(0, 40), 0, 0, -0.5);
        TNT1 A 0 A_GiveInventory("FreezeSpawnerCheck", 1);
        loop;
        cloudend:
        TNT1 A 0;
        stop;
    }
}
class FreezeCloud : SlowingCloud
{
    Default
    {
        +BLOODLESSIMPACT;
        +FORCERADIUSDMG;
        +DONTBLAST;
        +FOILINVUL;
        +NODAMAGETHRUST;
        BOUNCETYPE "DOOM";
        +DONTSPLASH;
        +PAINLESS;
        BounceType "Grenade";
        damagetype "Freeze";
        Damage 0;
        gravity 0.005;
        Translation "0:255=%[0.0,0.0,0.0]:[0.5,0.8,1.0]";
        Alpha 0.50;
        Height 16;
        PROJECTILE;
        Radius 1;
        RenderStyle "SHADED";
        StencilColor "A0 FF FF";
        Scale 1;
        Speed 2;
        SeeSound "none";
        DeathSound "none";
        AttackSound "none";
    }
    States
    {
        Spawn:
        WPXS A 0 NoDelay A_Jump(230, 3, 7, 11, 15, 19, 23, 27);
        WPXS AB 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS CD 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS EF 2 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(1, 4, 0);
        WPXS GH 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS IJKL 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS MN 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS OP 2 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(1, 4, 0);
        WPXS QR 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS ST 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS UV 2 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(1, 4, 0);
        WPXS WX 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS YZ 2 A_FadeOut(0.03);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXZ ABC 3 A_FadeOut(0.03);
        TNT1 A 0 A_Explode(1, 4, 0);
        stop;
    }
}
// : FreezeCloud
class BaronFreezeCloud : Actor
{
    Default
    {
        //Translation "0:255=%[0.0,0.0,0.0]:[0.5,0.8,1.0]";
        +BLOODLESSIMPACT;
        +FORCERADIUSDMG;
        +DONTBLAST;
        +NODAMAGETHRUST;
        BOUNCETYPE "DOOM";
        +DONTSPLASH;
        +PAINLESS;
        BounceType "Grenade";
        damagetype "Freeze";
        Damage 0;
        gravity 0.005;
        //Translation "0:255=%[0.0,0.0,0.0]:[0.5,0.8,1.0]";
        Alpha 0.3;
        Height 16;
        PROJECTILE;
        Radius 1;
        RenderStyle "SHADED";
        StencilColor "69 99 99";
        Scale 1.4;
        Speed 2;
        Species "HellNoble";
        +DONTHARMCLASS;
        +DONTHARMSPECIES;
        -FOILINVUL;
        SeeSound "none";
        DeathSound "none";
        AttackSound "none";
    }
    States
    {
        Spawn:
        WPXS A 0 NoDelay A_Jump(230, 3, 7, 11, 15, 19, 23, 27);
        WPXS AB 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(1.6);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS CD 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(1.7);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS EF 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(1.8);
        //TNT1 A 0 A_Explode(4 , 8 , 0)__TERMINATE__
        WPXS GH 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(2.0);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS IJ 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(2.2);
        WPXS KL 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(2.4);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS MN 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(2.6);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS OP 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(2.7);
        //TNT1 A 0 A_Explode(4 , 8 , 0)__TERMINATE__
        WPXS QR 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(2.8);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS ST 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(3.0);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS UV 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(3.2);
        //TNT1 A 0 A_Explode(4 , 8 , 0)__TERMINATE__
        WPXS WX 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(3.4);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXS YZ 2 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(3.8);
        //TNT1 A 0 A_Explode(1 , 16 , 0)__TERMINATE__
        WPXZ ABC 3 A_FadeOut(0.03);
        TNT1 A 0 A_SetScale(4.0);
        //TNT1 A 0 A_Explode(4 , 8 , 0)__TERMINATE__
        stop;
    }
}
class FreezeSpawnerCheck : Inventory
{
    Default
    {
        Inventory.amount 1;
        Inventory.maxamount 100;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        ICICLE           ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class BigIcicle : Actor
{
    Default
    {
        Radius 10;
        Height 8;
        Speed 10;
        DamageFunction (random(90, 120));
        PROJECTILE;
        DamageType "Freeze";
        Scale 0.75;
        RenderStyle "ADD";
        //Translation "0:255=%[0,0,0]:[0,1,1]";
        Alpha 0.95;
        DeathSound "cryodea3";
        //;
        MissileHeight 8;
        Decal "IceScorch";
        Species "Marines";
        +THRUSPECIES;
        +MTHRUSPECIES;
        +RIPPER;
        +EXTREMEDEATH;
        +BLOODLESSIMPACT;
    }
    States
    {
        Spawn:
        BREA A 3 NoDelay Bright A_SpawnItemEx("FreezeCloud", 0, 0, 2); //A_SpawnItemEx("FreezeCloudSpawner" , random(5 , -5) , random(5 , -5) , random(5 , -5) , 0 , 0 , 0 , 0 , 128 , 0)__TERMINATE__ 
        TNT1 A 0
        {
            A_StartSound("icespik", CHAN_7);
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
            A_SpawnProjectile("Icetracer", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
        }
        Spawnloop:
        BREA A 3 Bright A_SpawnItemEx("FreezeCloud", 0, 0, 2); //A_SpawnItemEx("FreezeCloudSpawner" , random(5 , -5) , random(5 , -5) , random(5 , -5) , 0 , 0 , 0 , 0 , 128 , 0)__TERMINATE__ 
        TNT1 A 0
        {
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
            A_SpawnProjectile("Icetracer", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
        }
        loop;
        Death:
        //BXPL A 0 Bright A_StopSound(CHAN_7)__TERMINATE__
        BXPL A 0 Bright
        {
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
        }
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        BXPL AAAAAAAAAAAA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        // TNT1 AAAAAAA 0 A_SpawnItemEx("XIceChunkAdd1", random(5, -5), random(5, -5), random(5, -5), random(-10, -20), random(-10, 10), random(-10, 10), random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAAAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL IJK 1 BRIGHT A_FadeOut(0.1);
        BXPL LLM 1 Bright A_FadeOut(0.1);
        stop;
        Crash:
        XDeath:
        //BXPL A 0 Bright A_StopSound(CHAN_7)__TERMINATE__
        BXPL A 0 Bright
        {
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
        }
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        BXPL AAAAAAAAAAAA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAAAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL IJK 1 BRIGHT A_FadeOut(0.1);
        BXPL LLM 1 Bright A_FadeOut(0.1);
        stop;
    }
}
class BigIcicle2 : BigIcicle
{
    Default
    {
        Speed 40;
        Scale 0.3;
        DamageFunction (random(70, 90));
        +PAINLESS;
        -RIPPER;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        SNOW           ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class SnowParticle2 : NewSnowParticle
{
    Default
    {
        Speed 5;
        Damage 6;
    }
}
class SnowParticle3 : NewSnowParticle
{
    Default
    {
        Damage 4;
    }
}
////The Cloud Stuff////
class SnowStart : Actor
{
    Default
    {
        Radius 2;
        Height 2;
        Speed 1;
        RenderStyle "TRANSLUCENT";
        Alpha 0;
        Scale 0.6;
        PROJECTILE;
        +SKYEXPLODE;
    }
    States
    {
        Spawn:
        SNOW A 1 NoDelay
        {
            A_ChangeVelocity(0, 0, 10, CVF_REPLACE);
            A_CheckCeiling("Death");
        }
        wait;
        Death:
        SNOW A 1;
        TNT1 A 0 A_SpawnItemEx("SnowSpawnerIcespike");
        TNT1 AAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("SnowSpawner");
        stop;
    }
}
class SnowSpawner : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        +NOBLOCKMAP;
        +NOGRAVITY;
        +NOSECTOR;
        +NOINTERACTION;
        +NOCLIP;
        -SOLID;
        +SPAWNCEILING;
    }
    States
    {
        Spawn:
        TNT1 AAAAAAAAAA 1 NoDelay A_SpawnItemEx("Snowcloud", Random(-400, 400), Random(-400, 400), -30, random(-1, 1), random(-1, 1), 0, 0, 0, 0);
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("NewSnowParticle", Random(-400, 400), Random(-400, 400), -60, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, SXF_TRANSFERPOINTERS, 0);
        TNT1 AAAAAAAAAA 1 A_SpawnItemEx("Snowcloud", Random(-400, 400), Random(-400, 400), -30, random(-1, 1), random(-1, 1), 0, 0, 0, 0);
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("NewSnowParticle", Random(-400, 400), Random(-400, 400), -60, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, SXF_TRANSFERPOINTERS, 0);
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("NewSnowParticle", Random(-400, 400), Random(-400, 400), -60, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, SXF_TRANSFERPOINTERS, 0);
        TNT1 AAAAAAAAAA 1 A_SpawnItemEx("Snowcloud", Random(-400, 400), Random(-400, 400), -30, random(-1, 1), random(-1, 1), 0, 0, 0, 0);
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("NewSnowParticle", Random(-400, 400), Random(-400, 400), -60, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, SXF_TRANSFERPOINTERS, 0);
        stop;
    }
}
class SnowSpawnerIcespike : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        +NOBLOCKMAP;
        +NOGRAVITY;
        +NOSECTOR;
        +NOINTERACTION;
        +NOCLIP;
        -SOLID;
        +SPAWNCEILING;
    }
    States
    {
        Spawn:
        TNT1 AAAAAAAAAA 1 NoDelay A_SpawnItemEx("Snowcloud", Random(-400, 400), Random(-400, 400), -30, random(-1, 1), random(-1, 1), 0, 0, 0, 0);
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("NewSnowParticle", Random(-400, 400), Random(-400, 400), -60, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, SXF_TRANSFERPOINTERS, 0);
        TNT1 A 2 A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), -30, random(-2, 2), random(-2, 2), random(-90, -30));
        TNT1 AAAAAAAAAA 1 A_SpawnItemEx("Snowcloud", Random(-400, 400), Random(-400, 400), -30, random(-1, 1), random(-1, 1), 0, 0, 0, 0);
        TNT1 A 2 A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), -30, random(-2, 2), random(-2, 2), random(-90, -30));
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("NewSnowParticle", Random(-400, 400), Random(-400, 400), -60, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, SXF_TRANSFERPOINTERS, 0);
        TNT1 AAA 3 A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), -30, random(-2, 2), random(-2, 2), random(-90, -30));
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("NewSnowParticle", Random(-400, 400), Random(-400, 400), -60, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, SXF_TRANSFERPOINTERS, 0);
        TNT1 A 2 A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), -30, random(-2, 2), random(-2, 2), random(-90, -30));
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("NewSnowParticle", Random(-400, 400), Random(-400, 400), -60, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, SXF_TRANSFERPOINTERS, 0);
        TNT1 AA 3 A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), -30, random(-2, 2), random(-2, 2), random(-90, -30));
        TNT1 AAAAAAAAAA 1 A_SpawnItemEx("Snowcloud", Random(-400, 400), Random(-400, 400), -30, random(-1, 1), random(-1, 1), 0, 0, 0, 0);
        TNT1 A 2 A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), -30, random(-2, 2), random(-2, 2), random(-90, -30));
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("NewSnowParticle", Random(-400, 400), Random(-400, 400), -60, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, SXF_TRANSFERPOINTERS, 0);
        stop;
    }
}
class Snowcloud : Actor
{
    Default
    {
        Radius 0;
        Height 0;
        RenderStyle "TRANSLUCENT";
        Alpha 0;
        Scale 2.5;
        Speed 1;
        +NOGRAVITY;
        +NOBLOCKMAP;
        +NOINTERACTION;
        -SOLID;
    }
    States
    {
        Spawn:
        SNCL ABCDEABCDE 7 NoDelay A_FadeIn(0.01); //fades from 0% to 100%
        SNCL ABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDEABCDE 7;
        SNCL ABCDEABCDE 7 A_FadeOut(0.01); //fades from 100% to 0%
        stop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        BLIZZARD          ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class BlizzTarget : Actor
{
    Default
    {
        Scale 1.3;
        Radius 16;
        Height 32;
        //;
        +FLATSPRITE;
        Gravity 0;
    }
    States
    {
        Spawn:
        BLZT A 159 Bright;
        Death:
        BLZT A 1 Bright A_FadeOut(0.1);
        loop;
    }
}
class BlizzardTimer : Inventory
{
    Default
    {
        Inventory.maxamount 53;
        +INVENTORY.UNDROPPABLE;
    }
}
class Blizzard : Actor
{
    Default
    {
        +MISSILE;
        -NOGRAVITY;
        +NOBLOCKMAP;
        +ACTIVATEIMPACT;
        +RIPPER;
        Speed 50;
        Gravity 3.5;
    }
    States
    {
        Spawn:
        TNT1 A 2;
        loop;
        Death:
        XDeath:
        FLMG A 0;
        FLMG A 0 A_Explode(20, 50);
        TNT1 A 0 A_StartSound("coldchr", 5);
        BXPL AAAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL AAAA 0 Bright A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL A 0 Bright A_SpawnItemEx("SnowStart");
        //BXPL A 0 Bright A_SpawnItemEx("CloudWhirl")__TERMINATE__
        BXPL AAAAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 30;
        //TNT1 A 0 A_SpawnItemEX("BlizzTarget")__TERMINATE__
        BlizzardTime:
        TNT1 A 4
        {
            A_JumpIfInventory("BlizzardTimer", 30, "TimesUp");
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-50, -20));
            A_SpawnItemEX("CryoSmoke3", random(-180, 180), random(-180, 180));
            A_Jump(random(128, 256), 3);
        }
        TNT1 A 6
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-90, -30));
        }
        TNT1 A 4
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-70, -30));
        }
        TNT1 A 2
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-70, -30));
        }
        TNT1 A 10
        {
            A_Jump(random(128, 256), 2);
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-50, -20));
        }
        TNT1 A 0 A_GiveInventory("BlizzardTimer", 1);
        loop;
        TimesUp:
        TNT1 A 0 A_StopSound(5);
        stop;
    }
}
class EverWinter : Actor
{
    Default
    {
        +MISSILE;
        -NOGRAVITY;
        +NOBLOCKMAP;
        +ACTIVATEIMPACT;
        +RIPPER;
        Speed 50;
        Gravity 3.5;
        //;
        ReactionTime 50;
    }
    States
    {
        Spawn:
        TNT1 A 2;
        loop;
        Death:
        XDeath:
        FLMG A 0;
        FLMG A 0 A_Explode(20, 50);
        TNT1 A 0 A_StartSound("coldchr", 5);
        BXPL AAAAAAAAA 0 A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL AAAA 0 A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAA 0 A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL A 0 A_SpawnItemEx("SnowStart");
        //BXPL A 0 A_SpawnItemEx("CloudWhirl")__TERMINATE__
        BXPL AAAAA 0 A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 30;
        //TNT1 A 0 A_SpawnItemEX("BlizzTarget")__TERMINATE__
        BlizzardTime:
        TNT1 A 2
        {
            A_JumpIfInventory("BlizzardTimer", 30, "TimesUp");
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-50, -20));
            A_SpawnItemEX("CryoSmoke3", random(-180, 180), random(-180, 180));
            A_Jump(random(128, 256), 3);
        }
        TNT1 A 2
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-90, -30));
        }
        TNT1 A 2
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-90, -30));
        }
        TNT1 A 2
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-90, -30));
        }
        TNT1 A 2
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-70, -30));
        }
        TNT1 A 2
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-70, -30));
        }
        TNT1 A 2
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-90, -30));
        }
        TNT1 A 2
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-90, -30));
        }
        TNT1 A 2
        {
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-90, -30));
        }
        TNT1 A 5
        {
            A_Jump(random(128, 256), 2);
            A_SpawnItemEX("IceSpikeb", random(-180, 180), random(-180, 180), (ceilingz-10)-floorz, random(-2, 2), random(-2, 2), random(-50, -20));
        }
        //TNT1 A 0 A_Countdown()
        TNT1 A 0 A_GiveInventory("BlizzardTimer", 1);
        loop;
        TimesUp:
        TNT1 A 0 A_StopSound(5);
        stop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        FREEZER BALLS         ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class FreezerBall : FastProjectile
{
    Default
    {
        Radius 4;
        Height 8;
        Speed 50;
        Damage 0;
        PROJECTILE;
        DamageType "Freeze";
        RenderStyle "ADD";
        //Translation "0:255=%[0,0,0]:[0,1,1]";
        Alpha 0.95;
        +NOEXTREMEDEATH;
        +NODAMAGETHRUST;
        +FORCEXYBILLBOARD;
        +FORCERADIUSDMG;
        +BOUNCEONFLOORS;
        +BOUNCEONWALLS;
        +BOUNCEONCEILINGS;
        BounceType "Grenade";
        BounceFactor 1;
        WallBounceFactor 1;
        BounceCount 2;
        DeathSound "weapons/cryobowhit";
        //;
        MissileHeight 8;
        Decal "IceScorch";
    }
    States
    {
        Spawn:
        FRPJ ABC 1 NoDelay Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
        TNT1 A 0
        {
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
            A_SpawnProjectile("FreezerTrailSparksSmall", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
        }
        loop;
        Death:
        //TNT1 A 0 A_Jump(192 , "Death2")__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        Death2:
        BXPL A 0 Bright
        {
            A_StopSound(CHAN_BODY);
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
            A_Explode(25*random(3, 4), 180, 0);
            A_Explode(random(20, 25), 315, 0);
        }
        BXPL AAAAAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL AAAAA 0 Bright A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAA 0 Bright
        {
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
            A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        }
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL ABCD 1 Bright;
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        EFGH EFGH 1 Bright;
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL IJKLLM 1 Bright A_FadeOut(0.1);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        stop;
    }
}
class SmallFreezerBall : FreezerBall
{
    Default
    {
        Scale 0.5;
    }
    States
    {
        Spawn:
        FRPJ ABC 1 NoDelay Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
        TNT1 A 0
        {
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
            A_SpawnProjectile("FreezerTrailSparksSmall", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
        }
        FRPJ ABC 1 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
        TNT1 A 0
        {
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
            A_SpawnProjectile("FreezerTrailSparksSmall", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
        }
        FRPJ ABC 1 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
        TNT1 A 0
        {
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
            A_SpawnProjectile("FreezerTrailSparksSmall", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
        }
        FRPJ ABC 1 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
        TNT1 A 0
        {
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
            A_SpawnProjectile("FreezerTrailSparksSmall", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
        }
        goto Death;
        Death:
        //TNT1 A 0 A_Jump(192 , "Death2")__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        Death2:
        BXPL A 0 Bright
        {
            A_StopSound(CHAN_BODY);
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
        }
        //BXPL A 0 Bright A_Explode(5*random(2 , 3) , 10 , 0)__TERMINATE__ 
        BXPL AAAAAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL AAAAA 0 Bright A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAA 0 Bright
        {
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
            A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        }
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL ABCD 1 Bright;
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        EFGH EFGH 1 Bright;
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL IJKLLM 1 Bright A_FadeOut(0.1);
        stop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        EFFECTS           ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class BigCryoSmoke : CryoSmoke
{
    Default
    {
        Scale 1.2;
    }
}
class CryoShot : FastProjectile
{
    Default
    {
        Radius 4;
        Height 8;
        Speed 60;
        DamageFunction (random(50, 75));
        Damagetype "Freeze";
        PROJECTILE;
        RenderStyle "ADD";
        Alpha 0.9;
        +FORCERADIUSDMG;
        +NODAMAGETHRUST;
        +NOEXTREMEDEATH;
        DeathSound "weapons/cryobowhit";
        MissileType "CryoTrail";
        MissileHeight 8;
        Decal "IceScorch";
    }
    States
    {
        Spawn:
        BSHT A 1 NoDelay Bright
        {
            A_SpawnItemEx("FreezerTrailSparksSmall", random(3, -3), 0, random(3, -3), 0, 0, 0, 0, 128, 0);
            A_SpawnItem("PlasmaFlare", 0, 0);
        }
        TNT1 A 0 A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
        loop;
        Death:
        //TNT1 A 0 A_Jump(192 , "Death2")__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        Death2:
        BXPL A 0 Bright
        {
            A_StopSound(CHAN_BODY);
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
            A_Explode(7, 8, 0);
            A_Explode(14, 16, 0);
        }
        BXPL AAA 0 Bright A_SpawnItemEx("MiniCryoSmoke1", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL AA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), 0, random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL A 0 Bright A_SpawnItemEx("MiniCryoSmoke1", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL ABCDEFGH 1 Bright;
        BXPL IJKLLM 1 Bright A_FadeOut(0.1);
        stop;
    }
}
class CryoShotBot : CryoShot
{
    Default
    {
        Damage 12;
    }
}

class FreezerTrailSparksSmall : Actor
{
    Default
    {
        RenderStyle "ADD";
        Scale 0.008;
        Alpha 0.95;
        +NOINTERACTION;
        +NOGRAVITY;
        +CLIENTSIDEONLY;
    }
    States
    {
        Spawn:
        YA36 B 3 NoDelay bright
        {
            A_JumpIf(scale.x<=0, "NULL");
            A_SetScale(scale.x-0.00075);
            A_ChangeVelocity(frandom(-0.8, 0.8), frandom(-0.8, 0.8), frandom(-0.8, 0.8), 0);
        }
        YA36 B 1 bright A_FadeOut(0.05);
        loop;
    }
}
class FreezerTrailSparksShort : Actor
{
    Default
    {
        RenderStyle "ADD";
        Scale 0.004;
        Alpha 0.3;
        +NOINTERACTION;
        +NOGRAVITY;
        +CLIENTSIDEONLY;
    }
    States
    {
        Spawn:
        YA36 B 3 NoDelay bright
        {
            A_JumpIf(scale.x<=0, "NULL");
            A_SetScale(scale.x-0.00075);
            A_ChangeVelocity(frandom(-0.8, 0.8), frandom(-0.8, 0.8), frandom(-0.8, 0.8), 0);
        }
        YA36 B 1 bright A_FadeOut(0.1);
        loop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////         ORBS          ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class IceOrb : Actor
{
    Default
    {
        Radius 13;
        Height 8;
        Speed 8;
        Fastspeed 8;
        Damage 50;
        PROJECTILE;
        RenderStyle "ADD";
        Alpha 0.7;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        +RIPPER;
        +NOBOSSRIP;
        +FRIENDLY;
        -THRUGHOST;
        Damagetype "Freeze";
        Scale 0.5;
        DeathSound "iceimpa";
        Decal "IceScorch";
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            A_SpawnItem("CryoSmoke2");
            A_StartSound("coldcst");
        }
        Fly:
        ICOR AA 1 Bright;
        TNT1 A 0
        {
            A_Explode(20, 90, 0);
            A_SpawnItemEx("IceShard0", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            A_SpawnItemEx("IceShard0", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
        }
        ICOR BB 1 Bright;
        TNT1 A 0
        {
            A_Explode(20, 90, 0);
            A_SpawnItemEx("IceShard0", 0, 0, 0, random(30, 50), 0, 0, 40, SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            A_SpawnItemEx("IceSpike", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("IceShard0", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
        }
        ICOR CC 1 Bright;
        TNT1 A 0
        {
            A_SpawnItemEx("IceShard0", 0, 0, 0, random(30, 50), 0, 0, 100, SXF_TRANSFERPOINTERS, 128);
            A_Explode(20, 90, 0);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            A_SpawnItemEx("IceSpike", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("IceShard0", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
        }
        ICOR DD 1 Bright;
        TNT1 A 0
        {
            A_SpawnItemEx("IceShard0", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
            A_Explode(20, 90, 0);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            A_SpawnItemEx("IceSpike", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("IceShard0", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
        }
        ICOR EE 1 Bright;
        TNT1 A 0
        {
            A_SpawnItemEx("IceSpike", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
            A_Explode(20, 90, 0);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            A_SpawnItemEx("IceSpike", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("IceSpike", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
        }
        loop;
        Death:
        ICOR FF 1 Bright;
        TNT1 A 0
        {
            A_SpawnItem("FreezeExplSmall", 0, 0, 0);
            A_SetScale(1.5);
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        TNT1 AAAA 0 A_SpawnItemEx("IceSpike", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
        BXPL AAAAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AABBCCDD 1 Bright A_Explode(25, 250, 0);
        TNT1 A 0
        {
            A_SetScale(2.0, 1.5);
            A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        BXPL EFGH 2 Bright A_FadeOut(0.1);
        BXPL AAAAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL IJKLLM 2 Bright A_FadeOut(0.1);
        BXPL AAAAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 12
        {
            A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        BXPL AAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        stop;
    }
}
class IceOrbBig : IceOrb
{
    int user_angle;
    Default
    {
        Radius 18;
        Height 8;
        Speed 6;
        Fastspeed 6;
        Damage 80;
        Alpha 1.0;
        Scale 0.9;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            A_SpawnItem("CryoSmoke2");
            A_Startsound("coldcst", CHAN_BODY , CHANF_OVERLAP, 1);
            // A_Startsound("CacoBallLoop", CHAN_BODY , CHANF_LOOP, 1);
            user_angle = 0;
        }
        Fly:
        ICOR A 1 Bright;
        TNT1 A 0
        {
            A_Explode(20, 90, 0);
            A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, user_angle, SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, user_angle+180, SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            user_angle = user_angle+8;
        }
        ICOR B 1 Bright;
        TNT1 A 0
        {
            A_Explode(20, 90, 0);
            A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, user_angle, SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            A_SpawnItemEx("IceOrbBigTrail", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
            user_angle = user_angle+8;
        }
        ICOR C 1 Bright;
        TNT1 A 0
        {
            A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, user_angle, SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, user_angle+180, SXF_TRANSFERPOINTERS, 128);
            A_Explode(20, 90, 0);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            user_angle = user_angle+8;
        }
        ICOR D 1 Bright;
        TNT1 A 0
        {
            A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, user_angle, SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, user_angle+180, SXF_TRANSFERPOINTERS, 128);
            A_Explode(20, 90, 0);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            A_SpawnItemEx("IceOrbBigTrail", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
            user_angle = user_angle+8;
        }
        ICOR E 1 Bright;
        TNT1 A 0
        {
            A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, user_angle, SXF_TRANSFERPOINTERS, 128);
            A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, user_angle+180, SXF_TRANSFERPOINTERS, 128);
            A_Explode(20, 90, 0);
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), 4, 0, 0, 0, 0, 128, 0);
            user_angle = user_angle+8;
        }
        loop;
        Death:
        ICOR FF 1 Bright;
        TNT1 A 0
        {
            A_SpawnItem("IceExplosionImpact", 0, 0, 0);
            A_SetScale(1.5);
        }
        TNT1 AAAA 0 A_SpawnItemEx("BigIcicle", 0, 0, 0, random(30, 50), 0, 0, random(-180, 180), SXF_TRANSFERPOINTERS, 128);
        BXPL AAAAAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AABBCCDD 1 Bright A_Explode(25, 250, 0);
        TNT1 A 0
        {
            A_SetScale(2.0, 1.5);
            A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        BXPL EFGH 2 Bright A_FadeOut(0.1);
        BXPL AAAAAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL IJKLLM 2 Bright A_FadeOut(0.1);
        BXPL AAAAAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 12
        {
            A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        TNT1 A 0
        {
            A_SpawnItemEX("SmallIceStalagmite1", 7, 8);
            A_SpawnItemEX("IceStalagmite2", 8, 0);
            A_SpawnItemEX("SmallIceStalagmite2", 7, -8);
        }
        BXPL AAAAAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        stop;
    }
}
class IceOrbBigTrail : Actor
{
    Default
    {
        RenderStyle "ADD";
        Scale 0.9;
        Alpha 0.3;
        +NOINTERACTION;
        +NOGRAVITY;
        +CLIENTSIDEONLY;
    }
    States
    {
        Spawn:
        ICOR B 0 NoDelay
        {
            A_JumpIf(scale.x<=0, "NULL");
            A_SetScale(scale.x-0.00075);
        }
        ICOR A 2 bright A_ChangeVelocity(frandom(-0.8, 0.8), frandom(-0.8, 0.8), frandom(-0.8, 0.8), 0);
        ICOR B 2 bright
        {
            A_JumpIf(scale.x<=0, "NULL");
            A_SetScale(scale.x-0.00075);
            A_ChangeVelocity(frandom(-0.8, 0.8), frandom(-0.8, 0.8), frandom(-0.8, 0.8), 0);
        }
        ICOR C 1 bright A_FadeOut(0.1);
        loop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////       SPIKES AND SPEARS         ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class IceSpike : FastProjectile
{
    Default
    {
        Radius 6;
        Height 8;
        Speed 45;
        DamageFunction (random(25, 50));
        PROJECTILE;
        DamageType "Freeze";
        RenderStyle "ADD";
        //Translation "0:255=%[0,0,0]:[0,1,1]";
        Alpha 0.95;
        DeathSound "iceimpa";
        //;
        MissileHeight 8;
        Decal "IceSmall";
        Species "Marines";
        +THRUSPECIES;
        +MTHRUSPECIES;
    }
    States
    {
        Spawn:
        ICPK A 3 Bright;
        TNT1 A 0
        {
            A_StartSound("icespik", CHAN_7);
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
        }
        //TNT1 A 0 A_CustomMissile("Icetracer" , 0 , 0 , random(0 , 360) , 2 , random(0 , 360))__TERMINATE__
        loop;
        Death:
        //TNT1 A 0 A_Jump(192 , "Death2")__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        Death2:
        BXPL A 0 Bright
        {
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
        }
        BXPL AAAAAAA 0 Bright
        {
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
            A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        }
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL IJK 1 BRIGHT A_FadeOut(0.1);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL LLM 1 Bright A_FadeOut(0.1);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        stop;
    }
}
class IceSpikeb : FastProjectile
{
    Default
    {
        Radius 4;
        Height 8;
        Speed 15;
        Fastspeed 20;
        DamageFunction (random(60, 90));
        PROJECTILE;
        DamageType "Freeze";
        RenderStyle "ADD";
        //Translation "0:255=%[0,0,0]:[0,1,1]";
        Alpha 0.95;
        Scale 0.8;
        DeathSound "iceimpa";
        //;
        MissileHeight 8;
        Decal "IceScorch";
        DAMAGETYPE "ICE";
    }
    States
    {
        Spawn:
        ICBL AAA 1 NoDelay Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
        TNT1 A 0
        {
            A_StartSound("icespik", CHAN_7);
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
        }
        //TNT1 A 0 A_CustomMissile("Icetracer" , 0 , 0 , random(0 , 360) , 2 , random(0 , 360))__TERMINATE__
        loop;
        Death:
        //TNT1 A 0 A_Jump(192 , "Death2")__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        Death2:
        BXPL A 0 Bright
        {
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
        }
        BXPL AAAAAAA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL A 0 A_explode(90, 90);
        BXPL AAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL IJKLLM 1 Bright A_FadeOut(0.1);
        stop;
    }
}

class IceSpearBrain : IceSpike
{
    Default
    {
        -RIPPER;
        Radius 20;
        Scale 0.5;
        Radius 6;
        Height 8;
        Speed 30;
        DamageFunction (random(25, 50));
        PROJECTILE;
        DamageType "Freeze";
        RenderStyle "ADD";
        //Translation "0:255=%[0,0,0]:[0,1,1]";
        Alpha 0.95;
        DeathSound "iceimpa";
        //;
        MissileHeight 8;
        Decal "IceSmall";
        Species "Arachnotron";
        +THRUSPECIES;
        +MTHRUSPECIES;
    }
    States
    {
        Spawn:
        BREA A 3 NoDelay Bright A_SpawnItemEx("FreezeCloud", 0, 0, 2); //A_SpawnItemEx("FreezeCloudSpawner" , random(5 , -5) , random(5 , -5) , random(5 , -5) , 0 , 0 , 0 , 0 , 128 , 0)__TERMINATE__ 
        TNT1 A 0
        {
            A_StartSound("icespik", CHAN_7);
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
        }
        //TNT1 A 0 A_CustomMissile("Icetracer" , 0 , 0 , random(0 , 360) , 2 , random(0 , 360))__TERMINATE__
        loop;
        Death:
        //TNT1 A 0 A_Jump(96 , "Death2")__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        Death2:
        BXPL A 0 Bright
        {
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
        }
        BXPL AAAAAAA 0 Bright
        {
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
            A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        }
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL IJK 1 BRIGHT A_FadeOut(0.1);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        BXPL LLM 1 Bright A_FadeOut(0.1);
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        stop;
    }
}
class IceSpearBaron : IceSpearBrain
{
    Default
    {
        Speed 35;
        Species "HellNoble";
        DamageFunction (random(40, 65));
    }
}
class IceSpearKnight : IceSpearBrain
{
    Default
    {
        Speed 25;
        Scale 0.4;
        Species "HellNoble";
        DamageFunction (random(30, 60));
    }
}
class BlizzardProjectile : IceSpear
{
    Default
    {
        Damage 0;
        +NOGRAVITY;
        +THRUACTORS;
        Speed 50;
        Damagetype "Freeze";
        scale 0.1;
    }
    States
    {
        Spawn:
        TNT1 AAA 2;
        Death:
        XDeath:
        FLMG A 0;
        FLMG A 0 A_Explode(20, 50);
        TNT1 A 0 A_SpawnItem("Blizzard");
        BXPL IJKLLM 1 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        //BXPL AAAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke" , 0 , 0 , 0 , random(10 , 30)*0.1 , 0 , random(0 , 10)*0.1 , random(1 , 360) , SXF_CLIENTSIDE|SXF_NOCHECKPOSITION)__TERMINATE__
        //BXPL AAAA 0 Bright A_SpawnItemEx("CryoSmoke3" , 0 , 0 , 0 , random(10 , 30)*0.04 , 0 , random(0 , 10)*0.04 , random(1 , 360) , SXF_CLIENTSIDE|SXF_NOCHECKPOSITION , 64)__TERMINATE__
        //BXPL AAAAAAA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall" , random(5 , -5) , random(5 , -5) , random(5 , -5) , random(10 , 30)*0.04 , 0 , random(0 , 10)*0.04 , random(1 , 360) , SXF_CLIENTSIDE|SXF_NOCHECKPOSITION , 64)__TERMINATE__
        //BXPL AAAAA 0 Bright A_SpawnItemEx("CryoSmoke2" , 0 , 0 , 0 , random(10 , 30)*0.04 , 0 , random(0 , 10)*0.04 , random(1 , 360) , SXF_CLIENTSIDE|SXF_NOCHECKPOSITION , 64)__TERMINATE__
        stop;
    }
}
class SmallIceSpike : IceSpike
{
    Default
    {
        DamageFunction (random(15, 20));
        Radius 3;
        Height 5;
        Scale 0.7;
        PROJECTILE;
        DamageType "Freeze";
        RenderStyle "ADD";
        //Translation "0:255=%[0,0,0]:[0,1,1]";
        Alpha 0.95;
        DeathSound "iceimpa";
        //;
        MissileHeight 8;
        Decal "IceSmall";
        Species "Marines";
        +THRUSPECIES;
        +MTHRUSPECIES;
    }
    States
    {
        Spawn:
        ICPK A 3 Bright;
        TNT1 A 0
        {
            A_StartSound("icespik", CHAN_7);
            A_SpawnProjectile("BlueFlareSpawn", 0, 0, 0, 0, 0, AAPTR_TARGET);
            A_SpawnProjectile("FreezerTrailSparksSmall", 0, 0, random(0, 360), 2, random(0, 360), AAPTR_TARGET);
        }
        loop;
        Death:
        //TNT1 A 0 A_Jump(192 , "Death2")__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        Death2:
        TNT1 A 0 Bright
        {
            A_ChangeFlag("ICEDAMAGE", 1);
            A_ChangeFlag("NODAMAGETHRUST", 0);
        }
        TNT1 AAAAAAA 0 Bright
        {
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
            A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        }
        TNT1 A 1 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        TNT1 A 0
        {
            A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        stop;
    }
}
class XSmallIceSpike : SmallIceSpike
{
    Default
    {
        DamageFunction (random(15, 20));
        Radius 3;
        Height 5;
        Scale 0.5;
    }
}
class Icebuckshot : Actor
{
    Default
    {
        PROJECTILE;
        +RANDOMIZE;
        +FORCEXYBILLBOARD;
        -NOGRAVITY;
        DamageFunction (random(40, 80));
        gravity 0.3;
        radius 4;
        height 5;
        speed 35;
        alpha 0.8;
        scale 0.2;
        Decal "IceSmall";
        DeathSound "cryodea4";
        RenderStyle "ADD";
        DamageType "Ice";
    }
    States
    {
        Spawn:
        ICBK ABAB 2 NoDelay BRIGHT A_SpawnItemEx("FreezerTrailSparksShort", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
        loop;
        Death:
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        BXPL A 0 Bright A_ChangeFlag("ICEDAMAGE", 1);
        BXPL AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 BRIGHT A_SpawnItemEx("IceShard0", 0, 0, 0, random(18, 24), random(-18, 18), random(-18, 18), random(-45, 45));
        BXPL A 0 Bright A_Explode(25*random(2, 3), 100, 0);
        BXPL AAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL AAAAA 0 Bright A_ChangeFlag("NODAMAGETHRUST", 0);
        BXPL AAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 AAAAAAA 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 0, random(18, 24), random(-18, 18), random(-18, 18), random(-45, 45), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL ABC 1 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 BRIGHT A_SpawnItemEx("IceShardSmallSG", 0, 0, 0, random(18, 24), random(-18, 18), random(-18, 18), random(-45, 45));
        BXPL DEFG 1 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAA 0 Bright
        {
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
            A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        }
        BXPL M 1 Bright A_FadeOut(0.1);
        stop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        SHARDS           ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class IceShard0 : Actor
{
    Default
    {
        PROJECTILE;
        +RANDOMIZE;
        +FORCEXYBILLBOARD;
        +BOUNCEONFLOORS;
        +BOUNCEONCEILINGS;
        -USEBOUNCESTATE;
        -NOGRAVITY;
        BounceType "Grenade";
        RenderStyle "ADD";
        bouncefactor 0.75;
        BounceSound "ricochet/hit";
        wallbouncefactor 0.75;
        DamageFunction (random(5, 10));
        gravity 0.3;
        radius 2;
        height 2;
        speed 48;
        alpha 0.9;
        scale 1.0;
        Decal "IceSmall";
        DamageType "Ice";
        deathsound "cryodea1";
    }
    States
    {
        Spawn:
        ICH3 A 0 NoDelay Bright A_ChangeFlag("ICEDAMAGE", 1);
        ICH3 ABCD 2 BRIGHT A_SpawnItemEx("FreezerTrailSparksShort", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
        ICH3 ABCD 2 BRIGHT A_SpawnItemEx("FreezerTrailSparksShort", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
        TNT1 A 1 A_SpawnProjectile("IceShResidue", -5, 0, 0, CMF_AIMDIRECTION, 0, AAPTR_TARGET);
        Death:
        TNT1 A 0
        {
            A_Stop();
        }
        //ICPR IJKLM 2 //BRIGHT
        stop;
        /*Bounce:
  TNT1 A 0 A_CustomMissile("IceShard3" , 0 , 0 , 0 , CMF_AIMDIRECTION)__TERMINATE__
  TNT1 A 0 A_Stop()
  ICH3 IJKLM 2 //BRIGHT
  Stop*/
        XDeath:
        TNT1 AA 0 BRIGHT A_SpawnItemEx("MiniCryoSmoke1", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        TNT1 AAA 0 BRIGHT
        {
            A_SpawnItemEx("FreezerTrailSparksShort", random(5, -5), random(5, -5), random(5, -5), 0, 0, 0, 0, 128, 0);
            A_SpawnItemEx("MiniCryoSmoke1", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        }
        stop;
    }
}

class IceShardSmall : IceShard0
{
    Default
    {
        DamageFunction (2*random(0, 8));
        gravity 0.15;
        radius 2;
        height 2;
        speed 80;
        alpha 0.6;
        scale 0.8;
        wallbouncefactor 0.80;
        bouncefactor 0.78;
    }
    States
    {
        Spawn:
        ICH3 A 0 NoDelay Bright A_ChangeFlag("ICEDAMAGE", 1);
        ICH3 ABCDABCDABCD 2 BRIGHT;
        TNT1 A 0 A_SpawnProjectile("IceShResidueSmall", -5, 0, 0, CMF_AIMDIRECTION, 0, AAPTR_TARGET);
        Death:
        TNT1 A 0
        {
            A_Stop();
        }
        stop;
    }
}
class RipIceShardSmall : IceShardSmall
{
    Default
    {
        +RIPPER;
    }
}
class IceShardSmallSG : IceShardSmall
{
    Default
    {
        DamageFunction (random(5, 10));
        gravity 0.15;
        radius 2;
        height 2;
        speed 80;
        alpha 0.6;
        scale 0.8;
        wallbouncefactor 0.80;
        bouncefactor 0.78;
        damagetype "Shotgun";
    }
    States
    {
        Spawn:
        ICH3 A 0 Bright;
        ICH3 ABCDABCDABCD 2 BRIGHT;
        TNT1 A 0 A_SpawnProjectile("IceShResidueSmall", -5, 0, 0, CMF_AIMDIRECTION, 0, AAPTR_TARGET);
        Death:
        TNT1 A 0
        {
            A_Stop();
        }
        stop;
    }
}
class RipIceShardSmallSG : IceShardSmallSG
{
    Default
    {
        +RIPPER;
    }
}
class IceShResidue : Actor
{
    Default
    {
        +FORCEXYBILLBOARD;
        +BOUNCEONFLOORS;
        +BOUNCEONCEILINGS;
        +THRUACTORS;
        +NOBLOOD;
        BloodType "Ice_Blood";
        BounceType "Grenade";
        bouncefactor 0.5;
        wallbouncefactor 0.5;
        BounceSound "ricochet/hit";
        RenderStyle "ADD";
        radius 2;
        gravity 0.3;
        height 2;
        speed 20;
        alpha 0.7;
        scale 0.8;
    }
    States
    {
        Spawn:
        TNT1 AAAA 0 NoDelay A_Jump(256, "Type1", "Type2", "Type3", "Type4");
        Type1:
        ICH3 A 20 BRIGHT;
        goto Death;
        Type2:
        ICH3 B 22 BRIGHT;
        goto Death;
        Type3:
        ICH3 C 15 BRIGHT;
        goto Death;
        Type4:
        ICH3 D 17 BRIGHT;
        goto Death;
        Death:
        ICPR IJKLM 2 BRIGHT;
        XDeath:
        ICPR IJKLM 2 BRIGHT;
        stop;
    }
}
class IceShResidueSmall : IceShResidue
{
    Default
    {
        radius 1;
        height 1;
        speed 40;
        alpha 0.7;
        scale 0.6;
    }
}
class FlakShake : Actor
{
    Default
    {
        height 8;
        radius 4;
        +NOBLOCKMAP;
        +NOGRAVITY;
        +NOSECTOR;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
        Spawn:
        TNT1 A 10 NoDelay
        {
            A_CallSpecial(Radius_Quake, 8, 6, 0, 1, 0);
        }
        stop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        STALAGMITES          ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class IceWall : IceSpear
{
    Default
    {
        Damage 0;
        +NOGRAVITY;
        +THRUACTORS;
        Speed 50;
        Damagetype "Freeze";
        scale 0.1;
    }
    States
    {
        Spawn:
        TNT1 AAA 2;
        Death:
        XDeath:
        FLMG A 0;
        FLMG A 0 A_Explode(20, 50);
        TNT1 A 0;
        BXPL AAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL AAAA 0 Bright A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 4 A_SpawnItemEX("IceStalagmite", 10, 15);
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite2", 15, 0);
        TNT1 A 4 A_SpawnItemEX("IceStalagmite2", 10, -15);
        TNT1 A 4
        {
            A_SpawnItemEX("SmallIceStalagmite2", 7, -30);
            A_SpawnItemEX("SmallIceStalagmite2", 7, 30);
            A_SpawnItemEX("IceStalagmite2", 2, 50);
        }
        TNT1 A 4
        {
            A_SpawnItemEX("IceStalagmite3", 2, -50);
            A_SpawnItemEX("SmallIceStalagmite1", -5, 75);
        }
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite2", -5, -75);
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite", -10, 90);
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite", -10, -90);
        TNT1 A 4
        {
            A_SpawnItemEX("IceStalagmite4", -15, -100);
            A_SpawnItemEX("IceStalagmite3", -15, 100);
        }
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite", -20, 120);
        TNT1 A 0 A_SpawnItemEX("SmallIceStalagmite2", -20, -120);
        stop;
    }
}
class IceWallSmall : IceWall
{
    States
    {
        Death:
        XDeath:
        FLMG A 0;
        FLMG A 0 A_Explode(20, 50);
        TNT1 A 0;
        BXPL AAA 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAAAA 0 Bright A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        BXPL AAAA 0 Bright A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAAAA 0 Bright A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AAAAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite1", 10, 15);
        TNT1 A 4 A_SpawnItemEX("IceStalagmite2", 15, 0);
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite2", 10, -15);
        TNT1 A 4
        {
            A_SpawnItemEX("SmallIceStalagmite2", 7, -30);
            A_SpawnItemEX("IceStalagmite3", 7, 30);
            A_SpawnItemEX("IceStalagmite2", 2, 50);
        }
        TNT1 A 4
        {
            A_SpawnItemEX("IceStalagmite3", 2, -50);
            A_SpawnItemEX("SmallIceStalagmite1", -5, 75);
        }
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite2", -5, -75);
        stop;
    }
}
class IceWallXS : IceWall
{
    States
    {
        Death:
        XDeath:
        FLMG A 0;
        FLMG A 0 A_Explode(20, 50);
        TNT1 A 0;
        BXPL A 0 Bright A_SpawnItemEx("BigCryoSmoke", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        BXPL AA 0 Bright
        {
            A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
            A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        }
        BXPL AAA 0 Bright
        {
            A_SpawnItemEx("FreezerTrailSparksSmall", random(5, -5), random(5, -5), random(5, -5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
            A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1, 360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION, 64);
        }
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite1", 10, 15);
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite2", 15, 0);
        TNT1 A 4 A_SpawnItemEX("SmallIceStalagmite1", 10, -15);
        stop;
    }
}

class GroundStalagmites : Actor
{
    Default
    {
        -SOLID;
        +FLOORHUGGER;
        +FORCEYBILLBOARD;
        +SHOOTABLE;
        +NOBLOOD;
        BloodType "Ice_Blood";
        Health 200;
        DamageFactor "freeze", 3.0;
        DamageFactor "ice", 3.0;
        Gravity 500.0;
        Mass 10000000000;
        Radius 1;
        Height 1;
        Scale 1.0;
        RenderStyle "Translucent";
        alpha 0.6;
    }
    States
    {
        Spawn:
        IC3X A 1 NoDelay A_SetScale(frandom(0.3, 0.6), frandom(0.3, 0.5));
        IC3X ABCDEF 6;
        IC3X F 100;
        IC3X EEDDCCBBAA 1 A_FadeOut(0.02);
        stop;
        Death.Ice:
        Death.freeze:
        TNT1 A 0 A_Jump(256, "Death.freeze1", "Death.freeze2", "Death.freeze3");
        Death.freeze1:
        TNT1 A 1 A_SpawnItemEX("SmallIceStalagmite1", 10, 15);
        stop;
        Death.freeze2:
        TNT1 A 1 A_SpawnItemEX("SmallIceStalagmite", 10, 15);
        stop;
        Death.freeze3:
        TNT1 A 1 A_SpawnItemEX("SmallIceStalagmite2", 10, 15);
        stop;
    }
}
class CeilingStalagmites : Actor
{
    Default
    {
        -SOLID;
        +NOGRAVITY;
        +CEILINGHUGGER;
        +FORCEYBILLBOARD;
        +NOBLOOD;
        BloodType "Ice_Blood";
        Radius 1;
        Height 1;
        RenderStyle "Translucent";
        alpha 0.6;
    }
    States
    {
        Spawn:
        IC3Y A 1 NoDelay A_SetScale(frandom(0.3, 0.6), frandom(0.3, 0.5));
        IC3Y ABCDEF 6;
        IC3Y F 100;
        IC3Y EEDDCCBBAA 1 A_FadeOut(0.02);
        stop;
    }
}

class DetectFloorIceZS : Actor
{
    Default
    {
        scale 5.0;
        speed 0;
        health 1;
        radius 8;
        height 2;
        Gravity 0.9;
        Damage 0;
        Renderstyle "ADD";
        Alpha 0.9;
        DamageType "Blood";
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        +MOVEWITHSECTOR;
        -DONTSPLASH;
        BOUNCETYPE "DOOM";
        +NOBLOOD;
        BloodType "Ice_Blood";
        BounceFactor 0.01;
    }
    States
    {
        Spawn:
        TNT1 A 5;
        stop;
        Death:
        TNT1 A 0 A_SpawnItemEx("GroundStalagmites", random(-20, 20), random(-20, 20), 0, 0, 0, 0, 0, SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        XXX1 A 530;
        XXX1 AAAAAAAAAAAAAAAAAAAA 1 A_FadeOut(0.02);
        stop;
    }
}

class DetectFloorIceZS2 : DetectFloorIceZS
{
    States
    {
        Death:
        TNT1 A 0 A_Jump(256, "Death1", "Death2", "Death3");
        Death1:
        TNT1 A 1 A_SpawnItemEX("SmallIceStalagmite1", 10, 15);
        stop;
        Death2:
        TNT1 A 1 A_SpawnItemEX("SmallIceStalagmite", 10, 15);
        stop;
        Death3:
        TNT1 A 1 A_SpawnItemEX("SmallIceStalagmite2", 10, 15);
        stop;
        stop;
    }
}
class DetectCeilIceZS : Actor
{
    Default
    {
        scale 5.0;
        speed 0;
        health 1;
        radius 1;
        height 2;
        Gravity 0;
        Damage 0;
        Renderstyle "ADD";
        Alpha 0.9;
        DamageType "Blood";
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        -DONTSPLASH;
        +NOGRAVITY;
        +NOBLOOD;
        BloodType "Ice_Blood";
    }
    States
    {
        Spawn:
        TNT1 A 1 NoDelay
        {
            A_CallSpecial(ThrustThingZ, 0, 35, 0, 1);
        }
        stop;
        Death:
        TNT1 A 0 A_SpawnItemEx("CeilingStalagmites", random(-20, 20), random(-20, 20), -1, 0, 0, 0, 0, SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
        XXX1 A 530;
        XXX1 AAAAAAAAAAAAAAAAAAAA 1 A_FadeOut(0.02);
        stop;
    }
}
class IceStalagmite : Actor
{
    Default
    {
        Mass 99999;
        RenderStyle "Translucent";
        alpha 0.8;
        Health 100;
        Radius 24;
        Height 128;
        DamageFactor "freeze", 0.5;
        DamageFactor "ice", 0.5;
        +SOLID;
        +SHOOTABLE;
        BloodType "Ice_Blood";
        +DONTDRAIN;
        +NOBLOODDECALS;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            A_StartSound("ICEBRK1");
            A_SetScale(frandom(0.8, 1.2), frandom(0.8, 1.2));
        }
        Stay:
        ICES A -1;
        stop;
        Death.Ice:
        Death.freeze:
        TNT1 A 1 A_SpawnItemEX("IceStalagmite", 0, 0);
        stop;
        Death:
        TNT1 A 0
        {
            A_NoBlocking();
            A_StartSound("DSBOTTLE");
            A_SpawnItemEX("IceStalagmite2", 0, 0);
        }
        // TNT1 AAAAAAAAAAAAAAAAAAA 0
        // {
        //     A_SpawnProjectile("XIceChunk1", random(10, 70), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        //     A_SpawnProjectile("XIceChunk2", random(10, 70), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        // }
        // TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnProjectile("XIceChunk3", random(10, 50), 0, random(0, 360), 2, random(40, 120), AAPTR_TARGET);
        ICES F 300;
        ICES FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 1 A_FadeOut(0.01);
        stop;
    }
}
class IceStalagmite2 : IceStalagmite
{
    Default
    {
        Scale 0.8;
        Health 75;
        Height 96;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            A_StartSound("ICEBRK1");
            A_SetScale(frandom(0.6, 0.8), frandom(0.6, 0.8));
        }
        ICES D -1;
        stop;
        Death.Ice:
        Death.freeze:
        TNT1 A 1 A_SpawnItemEX("IceStalagmite", 0, 0);
        stop;
        Death:
        TNT1 A 0
        {
            A_NoBlocking();
            A_StartSound("DSBOTTLE");
            A_SpawnItemEX("IceStalagmite3", 0, 0);
        }
        // TNT1 AAAAAAAAAAAAAAAAAAA 0
        // {
        //     A_SpawnProjectile("XIceChunk1", random(10, 60), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        //     A_SpawnProjectile("XIceChunk2", random(10, 60), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        // }
        // TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnProjectile("XIceChunk3", random(10, 50), 0, random(0, 360), 2, random(40, 120), AAPTR_TARGET);
        ICES F 300;
        ICES FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 1 A_FadeOut(0.01);
        stop;
    }
}
class IceStalagmite3 : IceStalagmite
{
    Default
    {
        Scale 0.5;
        Health 50;
        Height 64;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            A_StartSound("ICEBRK1");
            A_SetScale(frandom(0.4, 0.6), frandom(0.4, 0.6));
        }
        ICES D -1;
        stop;
        Death.Ice:
        Death.freeze:
        TNT1 A 1 A_SpawnItemEX("IceStalagmite2", 0, 0);
        stop;
        Death:
        TNT1 A 0
        {
            A_NoBlocking();
            A_StartSound("DSBOTTLE");
            A_SpawnItemEX("IceStalagmite4", 0, 0);
        }
        // TNT1 AAAAAAAAAAAAAAAAAAA 0
        // {
        //     A_SpawnProjectile("XIceChunk1", random(5, 40), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        //     A_SpawnProjectile("XIceChunk2", random(5, 40), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        // }
        // TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnProjectile("XIceChunk3", random(0, 50), 0, random(0, 360), 2, random(40, 120), AAPTR_TARGET);
        ICES F 300;
        ICES FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 1 A_FadeOut(0.01);
        stop;
    }
}
class IceStalagmite4 : IceStalagmite
{
    Default
    {
        Scale 0.4;
        Health 30;
        Height 54;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            A_StartSound("ICEBRK1");
            A_SetScale(frandom(0.3, 0.4), frandom(0.3, 0.4));
        }
        ICES A -1;
        stop;
        Death.Ice:
        Death.freeze:
        TNT1 A 1 A_SpawnItemEX("IceStalagmite3", 0, 0);
        stop;
        Death:
        TNT1 A 1
        {
            A_NoBlocking();
            A_StartSound("DSBOTTLE");
            A_SpawnItemEX("SmallIceStalagmite", 0, 0);
        }
        // TNT1 AAAAAAAAAAAAAAAAAAA 0
        // {
        //     A_SpawnProjectile("XIceChunk1", random(5, 20), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        //     A_SpawnProjectile("XIceChunk2", random(5, 20), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        // }
        // TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnProjectile("XIceChunk3", random(0, 15), 0, random(0, 360), 2, random(40, 120), AAPTR_TARGET);
        ICES F 300;
        ICES FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 1 A_FadeOut(0.01);
        stop;
    }
}
class SmallIceStalagmite : IceStalagmite
{
    Default
    {
        Health 20;
        Radius 16;
        Height 32;
        Scale 0.7;
        +SOLID;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay A_SetScale(frandom(0.8, 1.2), frandom(0.8, 1.2));
        ICES B -1;
        stop;
        Death.Ice:
        Death.freeze:
        TNT1 A 1 A_SpawnItemEX("IceStalagmite4", 0, 0);
        stop;
        Death:
        TNT1 A 0
        {
            A_NoBlocking();
            A_StartSound("DSBOTTLE");
        }
        // TNT1 AAAAAAAAAAA 0
        // {
        //     A_SpawnProjectile("XIceChunk1", random(0, 15), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        //     A_SpawnProjectile("XIceChunk2", random(0, 15), 0, random(0, 360), 2, random(0, 160), AAPTR_TARGET);
        // }
        // TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnProjectile("XIceChunk3", random(0, 10), 0, random(0, 360), 2, random(40, 120), AAPTR_TARGET);
        ICES G 300;
        ICES GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 1 A_FadeOut(0.01);
        stop;
    }
}
class SmallIceStalagmite1 : SmallIceStalagmite
{
    Default
    {
        Radius 16;
        Height 32;
        +SOLID;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay A_SetScale(frandom(0.8, 1.2), frandom(0.8, 1.2));
        ICES C -1;
        stop;
        Death.Ice:
        Death.freeze:
        TNT1 A 1 A_SpawnItemEX("IceStalagmite4", 0, 0);
        stop;
    }
}
class SmallIceStalagmite2 : SmallIceStalagmite
{
    Default
    {
        Scale 1.2;
        Radius 16;
        Height 32;
        +SOLID;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            A_StartSound("ICEBRK1");
            A_SetScale(frandom(0.8, 1.2), frandom(0.8, 1.2));
        }
        ICES E -1;
        stop;
        Death.Ice:
        Death.freeze:
        TNT1 A 1 A_SpawnItemEX("IceStalagmite3", 0, 0);
        stop;
    }
}
// : Projectile
class FrostShard : Actor
{
    Default
    {
        Radius 5;
        Height 5;
        Speed 25;
        DamageFunction (random(1, 5));
        damagetype "Freeze";
        Decal "IceScorch2";
        PROJECTILE;
        -THRUGHOST;
        +RANDOMIZE;
        +FORCEXYBILLBOARD;
        +BLOODSPLATTER;
        Renderstyle "NORMAL";
        Alpha 0.90;
        Scale 0.7;
        SeeSound "hail";
        deathsound "coldhit";
        //;
        DeathSound "GWANDHIT";
    }

    States
    {
        Spawn:
        ICPR ABC 2 NoDelay Bright A_SpawnItemEx("FreezeCloud", 0, 0, 2);
        loop;
        Death:
        //TNT1 A 0 A_Jump(192 , "Death2")__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("DetectFloorIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_SpawnItemEx("DetectCeilIceZS", 0, 0, 1, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        }
        Death2:
        TNT1 A 0 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        SPHW ABCDE 1 BRIGHT; //A_SetScale(scalex+(0.1) , scaley+(0.1))__TERMINATE__
        SPHW F 1 A_SpawnItemEx("FreezeCloudSpawner", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
        TNT1 A 0;
        stop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        BOLT and DAGGER         ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
//damaging icebolt
class Icebolt : Actor
{
    Default
    {
        Speed 10;
        Radius 8;
        Height 10;
        DamageFunction (random(2, 4));
        PROJECTILE;
        DamageType "Freeze";
        +PAINLESS;
        +NOTAUTOAIMED;
        +NODAMAGETHRUST;
        Scale 0.5;
        +RIPPER;
        RenderStyle "ADD";
        Alpha 0.1;
        //;
        SeeSound "IceGuyAttack";
        //;
        DeathSound "IceGuyMissileExplode";
    }
    States
    {
        Spawn:
        SHXW A 8 NoDelay Bright A_SetTranslucent(0.1, 0);
        SHXW BCDE 8 Bright;
        Death:
        TNT1 A 0;
        stop;
    }
}
//IceDagger is spawned in Powerup State
class IceDagger : Icebolt
{
    Default
    {
        DamageFunction (Random(8, 14));
        Speed 40;
        Scale 0.5;
    }
    States
    {
        Spawn:
        ICPR A 1 NoDelay Bright A_SetTranslucent(0.7, 0);
        ICPR BCABCABCABC 1 Bright;
        Death:
        ICPR DEFGH 2 Bright;
        stop;
    }
}
//Nondamaging IceDagger
class IceDagger1 : Icebolt
{
    Default
    {
        Speed 40;
        Damage 0;
        Scale 0.5;
    }
    States
    {
        Spawn:
        ICPR A 1 NoDelay Bright A_SetTranslucent(0.7, 0);
        ICPR BCABCABCABC 1 Bright;
        Death:
        ICPR DEFGH 2 Bright;
        stop;
    }
}
//nondamaging icebolt
class Icebolt1 : Actor
{
    Default
    {
        Speed 10;
        Radius 8;
        Height 10;
        PROJECTILE;
        DamageType "Freeze";
        +PAINLESS;
        +NOTAUTOAIMED;
        +NODAMAGETHRUST;
        Scale 0.5;
        +THRUACTORS;
        RenderStyle "ADD";
        Alpha 0.1;
        Translation "146:163=155:163";
        //;
        SeeSound "IceGuyAttack";
        //;
        DeathSound "IceGuyMissileExplode";
    }
    States
    {
        Spawn:
        SHXW A 5 NoDelay Bright A_SetTranslucent(0.1, 0);
        SHXW BCDE 5 Bright;
        Death:
        TNT1 A 0;
        stop;
    }
}
class IceShatteringExpl : Actor
{
    Default
    {
        //;
        +MISSILE;
        -BLOODSPLATTER;
        +THRUGHOST;
        +DONTSPLASH;
        +NOBLOCKMAP;
        Damagetype "IceShatter";
        Height 32;
        +NODAMAGETHRUST;
        //;
        +FORCEXYBILLBOARD;
        +FORCERADIUSDMG;
        +PAINLESS;
    }
    States
    {
        Spawn:
        TNT1 A 1;
        TNT1 A 0
        {
            A_AlertMonsters();
            A_Explode(2000, 2000);
        }
        stop;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/////////                     ////////
/////////        ICE WARPERS          ////////
/////////                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class WarpTimer : inventory {default{inventory.maxamount 60;}}
class IceWarperA : Actor
{
    int user_angle;
    int user_xoffset;
    int user_yoffset;
    int user_zoffset;
    Default
    {
        RenderStyle "Add";
        Scale 0.3;
        Alpha 0.5;
        species "Marines";
        PROJECTILE;
        +MISSILE;
        +DONTHARMCLASS;
        +THRUSPECIES;
        +MTHRUSPECIES;
        +NOINTERACTION;
        +FRIENDLY;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            user_xoffset = 32;
        }
        SetVars:
        TNT1 A 0
        {
            user_yoffset = 0;
            user_zoffset = 32;
            user_angle = 0;
        }
        AnimInit:
        TNT1 A 1 A_Warp(AAPTR_PLAYER1, user_xoffset, user_yoffset, user_zoffset, user_angle, WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_ABSOLUTEANGLE);
        AnimLoop:
        TNT1 A 0 A_JumpIfInventory("WarpTimer", 60, "Destroy");
        P0BL A 1 Bright A_Warp(AAPTR_PLAYER1, user_xoffset, user_yoffset, user_zoffset, user_angle, WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_ABSOLUTEANGLE);
        TNT1 A 0
        {
            user_angle = user_angle+5;
            A_SpawnItemEx("IceWarperTrail", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
        }
        //TNT1 A 0 A_SpawnItemEx("FreezerTrailSparksSmall" , 0 , 0 , 0 , random(10 , 30)*0.04 , 0 , random(0 , 10)*0.04 , random(1 , 360) , SXF_CLIENTSIDE|SXF_NOCHECKPOSITION , 64)__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("FreezeCloudSmall", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_Jump(240, 2);
            A_GiveInventory("WarpTimer", 1);
        }
        TNI1 A 0;
        loop;
        Destroy:
        // TNT1 A 0
        // {
        //     A_TakeFromTarget("IceCounter", 1, 0, AAPTR_PLAYER1|AAPTR_PLAYER2|AAPTR_PLAYER3|AAPTR_PLAYER4);
        //     A_TakeFromTarget("AllCounter", 1, 0, AAPTR_PLAYER1|AAPTR_PLAYER2|AAPTR_PLAYER3|AAPTR_PLAYER4);
        // }
        RealDestroy:
        P0BL A 1 Bright A_Warp(AAPTR_PLAYER1, user_xoffset, user_yoffset, user_zoffset, user_angle, WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_ABSOLUTEANGLE);
        TNT1 A 0
        {
            user_angle = user_angle+5;
            A_SpawnItemEx("IceWarperTrail", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
            A_FadeOut(0.02);
        }
        loop;
    }
}
class IceWarperC : Actor
{
    int user_angle;
    int user_xoffset;
    int user_yoffset;
    int user_zoffset;
    Default
    {
        RenderStyle "Add";
        Scale 0.3;
        Alpha 0.5;
        species "Marines";
        +DONTHARMCLASS;
        +THRUSPECIES;
        +MTHRUSPECIES;
        +NOINTERACTION;
        +FRIENDLY;
        +MISSILE;
        PROJECTILE;
    }
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            user_xoffset = 32;
        }
        SetVars:
        TNT1 A 0
        {
            user_yoffset = 0;
            user_zoffset = 42;
            user_angle = 0;
        }
        AnimInit:
        TNT1 A 1 A_Warp(AAPTR_PLAYER1, user_xoffset, user_yoffset, user_zoffset, user_angle, WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_ABSOLUTEANGLE);
        AnimLoop:
        TNT1 A 0 A_JumpIfInventory("WarpTimer", 60, "Destroy");
        P0BL A 1 Bright A_Warp(AAPTR_PLAYER1, user_xoffset, user_yoffset, user_zoffset, user_angle, WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_ABSOLUTEANGLE);
        TNT1 A 0
        {
            user_angle = user_angle-5;
            A_SpawnItemEx("IceWarperTrail", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
        }
        //TNT1 A 0 A_SpawnItemEx("FreezerTrailSparksSmall" , 0 , 0 , 0 , random(10 , 30)*0.04 , 0 , random(0 , 10)*0.04 , random(1 , 360) , SXF_CLIENTSIDE|SXF_NOCHECKPOSITION , 64)__TERMINATE__
        TNT1 A 0
        {
            A_SpawnItemEx("FreezeCloudSmall", 0, 0, 5, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0);
            A_Jump(240, 2);
            A_GiveInventory("WarpTimer", 1);
        }
        TNI1 AA 0;
        loop;
        Destroy:
        P0BL A 1 Bright A_Warp(AAPTR_PLAYER1, user_xoffset, user_yoffset, user_zoffset, user_angle, WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_ABSOLUTEANGLE);
        TNT1 A 0
        {
            user_angle = user_angle-5;
            A_SpawnItemEx("IceWarperTrail", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
            A_FadeOut(0.02);
        }
        loop;
    }
}
class IceWarperB : IceWarperA
{
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            user_xoffset = -32;
        }
        goto SetVars;
    }
}
class IceWarperD : IceWarperC
{
    States
    {
        Spawn:
        TNT1 A 0 NoDelay
        {
            user_xoffset = -32;
        }
        goto SetVars;
    }
}
class IceWarperTrail : Actor
{
    Default
    {
        RenderStyle "Add";
        Alpha 0.4;
        Scale 0.2;
        +NOINTERACTION;
    }
    States
    {
        Spawn:
        TNT1 A 1;
        P0BL B 1 Bright A_FadeOut(0.25);
        wait;
    }
}
class IceWarp : CustomInventory
{
    States
    {
        Pickup:
        TNT1 A 0
        {
            A_SpawnItemEx("IceWarperA", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER|SXF_NOCHECKPOSITION);
            A_SpawnItemEx("IceWarperB", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER|SXF_NOCHECKPOSITION);
            A_SpawnItemEx("IceWarperC", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER|SXF_NOCHECKPOSITION);
            A_SpawnItemEx("IceWarperD", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER|SXF_NOCHECKPOSITION);
            A_GiveInventory("FreezeImmunity", 1);
        }
        stop;
    }
}
class FreezeImmunity : PowerupGiver
{
    Default
    {
        Powerup.Type "PowerFreezeImmunity";
        Powerup.Duration -30;
        // ;
        Powerup.Colormap 0, 0, 0, 0.5, 0, 0.25;
        // ;
        +INVENTORY.AUTOACTIVATE;
        -INVENTORY.ADDITIVETIME;
    }
}
class PowerFreezeImmunity : PowerProtection
{
    Default
    {
        DamageFactor "Freeze", 0;
        DamageFactor "Ice", 0;
    }
}
//=========================================================================
//=========================================================================

Class SlowingCloud : Actor
{
	default
	{
	Projectile;
	}
	States
	{
	Spawn:
		TNT1 A 1 ;
		loop ;
	}
	override int SpecialMissileHit(Actor victim) // handle slowdown and pain effects on the victim
	{
		if (victim && (!target || victim != target) && victim.bSHOOTABLE && victim.health > 0)
		{
			int df = victim.ApplyDamageFactor("Freeze",1); // no slowdown if victim is resistant to Ice damage
			if (df)
			{
				victim.A_GiveInventory("PowerSlowdown"); // slow down victim
				if (victim.bISMONSTER && victim.tics > 0)
				{
					int rnd =  random(1,500);
					if (rnd > 290) victim.tics += 1; // chance to reduce anim speed
					else if (rnd == 1 && victim.bNOPAIN == false && victim.painchance > 0) // chance to force pain
					{
						state painstate = victim.Findstate("Pain.Freeze");
						if (painstate) victim.SetState(painstate); 
					}
				}
			}
		}
		return -1;
	}
}

Class NewSnowParticle : Actor
{
	default
	{
	Radius 2;
	Height 2;
	DamageFunction (8);
	+PAINLESS;
	DamageType "Ice";
	RenderStyle "Translucent";
	Alpha 0;
	Scale 0.6;
	Projectile;
	+THRUGHOST;
	+GHOST;
	+THRUSPECIES;
	+MTHRUSPECIES;
	Species "Marines";
	}
	States
	{
	Spawn:
		TNT1 A 0 ;
		Goto See ;
	See:
		TNT1 A 0 A_SetScale(frandom(0.2, 0.4)) ;
		SNOW AAAAAAA 2 A_FadeIn(0.1) ;
		SNOW A 3 ;
		loop ;
	XDeath:
	Death:
		SNOW A 20 A_FadeOut(0.05) ;
		Stop ;
	}
	override int SpecialMissileHit(Actor victim) // handle slowdown and pain effects on the victim
	{
		if (victim && (!target || victim != target) && victim.bSHOOTABLE && victim.health > 0)
		{
			int df = victim.ApplyDamageFactor("Ice",1); // no slowdown if victim is resistant to Ice damage
			if (df)
			{
				victim.A_GiveInventory("PowerSlowdown"); // slow down victim
				if (victim.bISMONSTER && victim.tics > 0)
				{
					int rnd =  random(1,500);
					if (rnd > 290) victim.tics += 1; // chance to reduce anim speed
					else if (rnd == 1 && victim.bNOPAIN == false && victim.painchance > 0) // chance to force pain
					{
						state painstate = victim.Findstate("Pain.Ice");
						if (painstate) victim.SetState(painstate); 
					}
				}
			}
		}
		return -1;
	}
}

Class PowerSlowdown : PowerSpeed
{
	Default
	{
		Powerup.Duration 15;
		Speed 0.3;
	}
	override void InitEffect()
	{
		super.InitEffect();
		if (owner && owner.bISMONSTER) owner.speed = owner.default.speed*0.3;
	}
	override void EndEffect()
	{
		super.EndEffect();
		if (owner && owner.bISMONSTER) owner.speed = owner.default.speed;
	}
	
}

// Cryo Wall
Class CryoWall : PB_CryoGrenade
{
    Default
    {
        DeathSound "weapons/CryoRifle/missiledeath";
    }

	States
	{
		Spawn:
			TNT1 A 0 {
				if(waterlevel > 1) A_SpawnItem ("CryoRifleTrailSparksSmall");
				spawnGrenadeFlare("LENBA0");
			}
			ICOR A 1 Bright Light("SGL_CRYO") A_Jumpif(CheckDetonation(),"Detonate");
			Loop;

		Bounce:
		Rest:
		Detonate:
		Death:
		XDeath:
			BXPL AAAA 0 A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30), 0, random(0, 10), random(1,360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
			BXPL AAAA 0 A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30), 0, random(0, 10), random(1,360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION,64);
			TNT1 AAAA 0 A_SpawnItemEx ("FreezeCloudSpawner",frandom(-100,100),frandom(-100,100),20,0,0,0,0,SXF_NOCHECKPOSITION,0);
		    TNT1 A 0 A_PlaySound("IceBreakMedium", 3);
			ICOR K 1 BRIGHT A_CustomMissile("CryoFlare",-5,0,-85,0,random(-10,10));
			TNT1 AAAAAA 0  A_SpawnItemEx("IceShardSmallSG",0,0,0,random(18,24),random(-18,18),random(-18,18),random(-45,45));
			TNT1 A 0 A_PlaySound("ICIMPA", 5);
			TNT1 A 0 A_PlaySound("IceBreakMedium",3 );
			TNT1 A 0 A_SpawnItemEx("IceWall");
			TNT1 A 0 A_SpawnItemEx("IceWall");
            TNT1 A 0 Bright A_Explode(200,120, 0, 0, 120);
			TNT1 AAA 0 Bright A_SpawnItemEx("CryoSmoke", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(1,360), SXF_NOCHECKPOSITION);
			TNT1 AAA 0 Bright A_SpawnItemEx("CryoSmoke3", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1,360), SXF_NOCHECKPOSITION,64);
			TNT1 AAA 0 Bright A_SpawnItemEx("CryoRifleTrailSparksSmall", random(5,-5), random(5,-5), random(5,-5), random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1,360), SXF_NOCHECKPOSITION,64);
			TNT1 AAA 0 Bright A_SpawnItemEx("CryoSmoke2", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(1,360), SXF_NOCHECKPOSITION,64);
			TNT1 AAA 0 Bright A_SpawnItemEx("IceExplosionImpact", random(-2,2), random(-2,2), random(-2,2), 0, 0, 0, random(1,360), SXF_NOCHECKPOSITION);
			TNT1 AAAAA 0 A_SpawnItemEx ("DetectFloorIce",random(-150,150), random(-150,150),1,0,0,0,0,SXF_NOCHECKPOSITION,0);
			TNT1 A 0 A_SpawnItemEx ("DetectFloorCraterIce",0,0,1,0,0,0,0,SXF_NOCHECKPOSITION,0);
            TNT1 A 0 {
				for(int i = 0; i < 20; i++)
				{
					A_SpawnProjectile("PB_Shrapnel", 0, 0, random (0, 360), 2, random (-90, 90));
				}
			}
			TNT1 A 5;
			TNT1 A 0 A_PlaySound("IceBreakMedium", 3);
			Stop;
	}
}