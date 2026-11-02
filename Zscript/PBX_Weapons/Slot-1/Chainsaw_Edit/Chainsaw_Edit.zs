// Throwable Chainsaw from Brutal Doom Platinum
// Quick SSG Edit by Runner_OG

// Includes
#include "./Chainsaw_Edit_Wheel.zs"

class Saw_Select_Slash : inventory {default{inventory.maxamount 1;}}
class Saw_Select_Throw : inventory {default{inventory.maxamount 1;}}
class Saw_Select_SSG : inventory {default{inventory.maxamount 1;}}
class Saw_Toggle_Lifesteal : inventory {default{inventory.maxamount 1;}}
class Saw_No_SSG : inventory {default{inventory.maxamount 1;}}

// A very hacky way to add functions to decorate weapons
class PBX_ChainsawEditedBase : PBX_WeaponBase abstract
{
    PB_SSG ptrSSG;
    Saw_WW_Mode mChainsawAlt;
    bool mChainsawLifesteal;
    bool mThrowChainsawSecondary;

    enum Saw_WW_Mode
	{
        ERROR_WHEEL = -3
        ,NO_SSG
        ,CLOSE_WHEEL
		,SELECT_SLASH
		,SELECT_THROW
		,SELECT_QUICKSSG
		,TOGGLE_LIFESTEAL
	}

    const QUICKSSG_LAYER = 78;
    const SAWSSG_LAYER = 79;

    protected
    action void Saw_TakeSSGAmmo(int take)
    {
        Saw_GetSSG();
        if(Saw_GetSSGPtr())
        {
            Saw_GetSSGPtr().PB_TakeAmmo(Saw_GetSSGPtr().ammo2.getClassName(), take, 0);
        }
    }

    protected
    action PB_SSG Saw_GetSSGPtr()
    {
        return invoker.ptrSSG;
    }

    protected
    action int Saw_GetSSGAmmoCount()
    {
        Saw_GetSSG();
        if(Saw_GetSSGPtr())
        {
            return Saw_GetSSGPtr().ammo2.amount;
        }
        return 0;
    }

    protected
    action void Saw_GetSSG()
    {
        if(!invoker.ptrSSG)
        {
            invoker.ptrSSG = PB_SSG(FindInventory("PB_SSG"));
        }
    }

    protected
    action state Saw_HandleWheel()
    {
        A_WeaponOffset(0,32);
        A_SetInventory("GoWeaponSpecialAbility",0);

        Saw_WW_Mode tokens = Saw_GetTokens();
        Saw_WW_Mode mode = Saw_GetMode();

        if(tokens == mode)
        {
            Saw_CleanTokens();
			A_Print("$PB_ALREADYSELECTED");
			return resolvestate("OnLoop");
        }

        switch(tokens)
        {
            case CLOSE_WHEEL:
                Saw_CleanTokens();
                break;

            case NO_SSG:
                Saw_CleanTokens();
                A_Print("$PBX_ChainsawEdit_NoSSG");
                break;

            case SELECT_SLASH: case SELECT_THROW: 
                Saw_SetMode(tokens);
                A_Print(tokens == SELECT_SLASH ? "$PBX_ChainsawEdit_Slash" : "$PBX_ChainsawEdit_Throw");
                A_StartSound("weapons/chainsaw/draw",CHAN_WEAPON,CHANF_OVERLAP);
                break;

            case SELECT_QUICKSSG:
                Saw_GetSSG();
                Saw_SetMode(tokens);
			    A_Overlay(SAWSSG_LAYER,"SSGSelect",false);
                A_StartSound("weapons/ssg/inspect4",CHAN_WEAPON,CHANF_OVERLAP);
                A_Print("$PBX_ChainsawEdit_SSG");
                break;
                
            case TOGGLE_LIFESTEAL:
                Saw_CleanTokens();
                invoker.mChainsawLifesteal = !invoker.mChainsawLifesteal;
                A_Print(invoker.mChainsawLifesteal ? "$PB_SAW_GATHERON" : "$PB_SAW_GATHEROFF");
                A_SetInventory("ChainsawResourceGather",invoker.mChainsawLifesteal);
                return resolvestate("RevAnimation");
        }

        Saw_CleanTokens();
        return resolvestate(null); //Fallthrough to OnLoop
    }

    protected
    action state Saw_HandleAltFire()
    {
        Saw_GetSSG();
        Saw_WW_Mode mode = Saw_GetMode();
        switch(mode)
        {
            case SELECT_SLASH:
			    return resolvestate("SlashAltFire");

            case SELECT_THROW:
			    return resolvestate("ThrowChainsawStart");

            case SELECT_QUICKSSG:
                return resolvestate("QuickSSG");
        }
        return resolvestate(null);
    }

    protected
    action state Saw_HandleQuickSSG()
    {
        Saw_GetSSG();

        if(!Saw_GetSSGPtr() || Saw_GetSSGPtr().amount <= 0 || FindInventory("PB_QuadSG"))
        {
            Saw_SetMode(SELECT_SLASH);
            return resolvestate("SlashAltFire");
        }

        if(Saw_GetSSGPtr().ammo1.amount <= 0 && Saw_GetSSGPtr().ammo2.amount <= 0)
        {
            return resolvestate("OnLoop");
        }

        if(Saw_GetSSGPtr().ammo2.amount <= 0)
        {
            return resolvestate("ReloadChainsawSSG");
        }

        return resolvestate(null);
    }

    protected
    action Saw_WW_Mode Saw_GetMode()
    {
        return invoker.mChainsawAlt;
    }

    protected
    action void Saw_SetMode(Saw_WW_Mode set)
    {
        invoker.mChainsawAlt = set;
    }

    protected
    action Saw_WW_Mode Saw_GetTokens()
    {
        if(FindInventory("Saw_No_SSG"))
			return NO_SSG;
        else if(FindInventory("Saw_Toggle_Lifesteal"))
			return TOGGLE_LIFESTEAL;
        else if(FindInventory("Saw_Select_Slash"))
			return SELECT_SLASH;
		else if (FindInventory("Saw_Select_Throw"))
			return SELECT_THROW;
		else if(FindInventory("Saw_Select_SSG"))
			return SELECT_QUICKSSG;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
    }

    protected
    action void Saw_CleanTokens()
    {
        A_SetInventory("Saw_No_SSG",0);
        A_SetInventory("Saw_Toggle_Lifesteal",0);
        A_SetInventory("Saw_Select_Slash",0);
        A_SetInventory("Saw_Select_Throw",0);
        A_SetInventory("Saw_Select_SSG",0);
        A_SetInventory("PBX_CloseWheel",0);
    }

    protected
    action void Saw_SetSprite(name red, name blue, name green)
    {
        if(PB_IsVisorBlood())
        {
            name spr;
            switch(PB_GetVisorBlood())
            {
                case REDBLOODVISOR:     spr = red;   break;
                case BLUEBLOODVISOR:    spr = blue;  break;
                case GREENBLOODVISOR:   spr = green; break;
            }
            A_SetWeaponSpriteEx(spr);
        }
    }

    States
    {
        Spawnthrown:
            CSAW B 8 {
                A_StartSound("weapons/chainsaw/idle", 6); 
                A_SpawnProjectile("SmokeSpawner");
                Saw_SetMode(SELECT_THROW);
            }
            Loop;

        WeaponInspect:
            SAWS WXYZ 1 {
                A_SetRoll(roll+0.6,SPF_INTERPOLATE); 
                return A_DoPBWeaponAction();
            }
            TNT1 A 0 A_PlaySound("DSSAWZIP");
            SAWS A 1 {
                A_Zoomfactor(0.98); 
                return A_DoPBWeaponAction();
            }
            SAWS B 1 {
                A_Zoomfactor(0.96); 
                return A_DoPBWeaponAction();
            }
            SAWS C 1 {
                A_Zoomfactor(0.98); 
                return A_DoPBWeaponAction();
            }
            SAWS D 1 {
                A_Zoomfactor(1.0); 
                return A_DoPBWeaponAction();
            }
            SAWS EFGH 1 {
                A_SetRoll(roll-0.6,SPF_INTERPOLATE); 
                return A_DoPBWeaponAction();
            }
            RIFF A 0 A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
            SAWS I 1 A_DoPBWeaponAction();
            RIFF A 0 A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
            SAWS J 1 {
                A_playsound("weapons/chainsaw/draw", CHAN_AUTO); 
                return A_DoPBWeaponAction();
            }
            RIFF A 0 A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
            SAWS K 1 A_DoPBWeaponAction();
            RIFF A 0 A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
            TNT1 A 0 A_JumpIf(PressingReload(),"WeaponInspect");
            goto OnLoop;

        OnLoop:
            TNT1 A 0 { 
                A_StartSound("weapons/chainsaw/idle",CHAN_WEAPON,CHANF_LOOPING, 0.5);
                A_SetRoll(0);
                A_SetInventory("ComboSeq", 0);
                A_SetInventory("FiredGun", 0);
            }
        OnLoop1:
            TNT1 A 0 {
                if(PB_IsVisorBlood())
                {
                    A_Overlay(-2,"BloodDrop");
                }
            }
            S4WG ABABCDCD 1 {
                Saw_SetSprite('SAW2','SAW3','SAW4');
                return PBX_CheckInspectSimple();
            }
            Loop;

        WeaponSpecial:
            TNT1 A 0 Saw_HandleWheel();
            goto OnLoop;
            
        RevAnimation:
            TNT1 A 0 A_StartSound("DSSAWZIP", CHAN_AUTO);
            SAWS A 1 A_Zoomfactor(0.98);
            SAWS B 1 A_Zoomfactor(0.96);
            SAWS C 1 A_Zoomfactor(0.98);
            SAWS D 1 A_Zoomfactor(1.0);
            SAWS EFGH 1 A_SetRoll(roll-0.6,SPF_INTERPOLATE);
            SAWS I 1 A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
            SAWS J 1 {
                A_playsound("weapons/chainsaw/draw", CHAN_AUTO);
                A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
            }
            SAWS K 1 A_FireCustomMissile("GunFireSmoke", 0, 0, -5, -5, 0, 0);
            Goto OnLoop;

        AltFire:
            "####" A 0 Saw_HandleAltFire();
            Goto Onloop;

        QuickSSG:
            TNT1 A 0 Saw_HandleQuickSSG();
            TNT1 A 3 {
                A_Overlay(SAWSSG_LAYER,"SSGBang",false);
                A_Overlay(QUICKSSG_LAYER,"PutChainAside",false);
                A_SetRoll(0);
            }
            TNT1 A 0 A_SetInventory("CantDoAction",1);
            TNT1 A 1 BRIGHT {
                PB_IncrementHeat(10);
                A_GunFlash();

                if(Saw_GetSSGAmmoCount() == 1)
                {
                    A_AlertMonsters();
                    PB_FireBullets("PB_10GAPellet",10,8,0,0,6);
                    A_StartSound("weapons/shh2", CHAN_Weapon, CHANF_DEFAULT, 1.0);
                    PB_DynamicTail("shotgun", "shotgun");
                    PB_GunSmoke(-3,0,0); PB_MuzzleFlashEffects(-3,0,0);
                    PB_GunSmoke(-5,0,0); PB_MuzzleFlashEffects(-5,0,0);
                    A_ZoomFactor(0.95);
                    Saw_TakeSSGAmmo(1);
                    A_FireProjectile("ShotgunWad",random(-1,1),0,6,-2,FPF_NOAUTOAIM,random(-1,1));
                }
                else 
                {
                    A_AlertMonsters();
                    PB_FireBullets("PB_10GAPellet_LP",1,0,0,0,0);
                    PB_FireBullets("PB_10GAPellet",20,8,0,0,6);
                    PB_GunSmoke(-3,0,0); PB_MuzzleFlashEffects(-3,0,0);
                    PB_GunSmoke(-5,0,0); PB_MuzzleFlashEffects(-5,0,0);
                    A_StartSound("SSHFIRE", CHAN_Weapon, CHANF_DEFAULT, 1.0);
                    PB_DynamicTail("shotgun", "shotgun");
                    A_ZoomFactor(0.95);
                    Saw_TakeSSGAmmo(2);
                    A_FireProjectile("ShotgunWad",random(-1,1),0,10,-2,FPF_NOAUTOAIM,random(-1,1));
                    A_FireProjectile("ShotgunWad",random(-1,1),0,6,-2,FPF_NOAUTOAIM,random(-1,1));
                }
            }
            TNT1 A 1 BRIGHT {
                PB_GunSmoke(-3,0,0); PB_MuzzleFlashEffects(-3,0,0);
                PB_GunSmoke(-5,0,0); PB_MuzzleFlashEffects(-5,0,0);
            }
            TNT1 A 1 {
                A_ZoomFactor(0.975);
                PB_WeaponRecoil(-3.80,-2.40);
            }
            TNT1 A 1 {
                A_ZoomFactor(1.0);
                PB_WeaponRecoil(-3.80,-2.40);
            }
            TNT1 A 1 PB_WeaponRecoil(-3.80,-2.40);
            TNT1 AA 1;
            TNT1 A 0 A_PlaySoundEx("weapons/ssg/inspect4", "Auto");
            TNT1 A 12;
            TNT1 A 0 A_ClearOverlays(QUICKSSG_LAYER,SAWSSG_LAYER,true);
            TNT1 A 0 A_SetInventory("CantDoAction",0);
            Goto Onloop;

        PutChainAside:		
            CSK1 ABCDEEEDCBA 2 Saw_SetSprite('CSK2','CSK3','CSK4');
            SAWG GFEDC 2 Saw_SetSprite('SAW2','SAW3','SAW4');
            stop;

        SSGSelect:
            SSGQ ABC 1;
            SSGQ D 5;
            SSGQ CBA 1;
            stop;

        SSGBang:
            SSGQ ABCD 1;
            P6W1 ABCDEFGHIJK 1;
            SSGQ DCBA 1;
            stop;

        ReloadChainsawSSG:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                A_SetRoll(0);
                A_SetInventory("CantDoAction",1);
            }
            TNT1 A 0 A_Stopsound(CHAN_WEAPON);
            SAWS YXW 1 Saw_SetSprite('S1WS','S2WS','S3WS');
            "####" W 1 Offset(-15,46);
            "####" W 1 Offset(-25,58);
            "####" W 1 Offset(-35,70);
            TNT1 A 0 {
                Saw_GetSSG();
                if(!Saw_GetSSGPtr())
                {
                    return resolvestate("SelectAnimation");
                }
                return resolvestate(null);
            }
            SGAR ABCDEFGHI 1;
            TNT1 A 0 A_PlaySoundEx("weapons/ssg/open", "Auto");
            SGAR KJOP 1;
            TNT1 A 0 A_PlaySoundEx("weapons/ssg/open2", "Auto");
            TNT1 A 0 {
                if(Saw_GetSSGPtr().getSpentR() > 0) {
                    PB_SpawnCasing("ShotgunCasing",14,-3,30,-1,4,4);
                    if(Saw_GetSSGPtr().getSpentR() > 1) PB_SpawnCasing("ShotgunCasing",15,3,30,-1,5,4);
                }
                Saw_GetSSGPtr().setSpentR(0);
            }
            SG10 HI 1 PB_SetRoll(roll-1.0);
            SG10 JKLMNOPQ 1;
            SG10 RS 1 PB_SetRoll(roll+2.0);
            SG10 TUV 1 PB_SetRoll(roll-1.0);
            TNT1 A 0 {
                A_PlaySoundEx("weapons/ssg/inspect2", "Auto");
                PB_AmmoIntoMag(Saw_GetSSGPtr().ammo2.getClassName(), Saw_GetSSGPtr().ammo1.getClassName(), PB_SSG.MAGAZINE_SIZE);
                Saw_GetSSGPtr().PB_SetMagEmpty(false);
                Saw_GetSSGPtr().PB_SetChamberEmpty(false);
            }
            SG10 WXY 1 PB_SetRoll(roll-1.0);
            SG10 Z 1;
            SG11 ABCDE 1;
            TNT1 A 0 A_PlaySoundEx("weapons/ssg/inspect3", "Auto");
            SG11 FGHIJKLMNO 1;
            SGAR QR 1;
            TNT1 A 3;
		    TNT1 A 0 A_SetInventory("CantDoAction",0);
		    Goto SelectAnimation;

        ThrowChainsawStart:
            "####" A 0 {
                A_SetRoll(0);
                A_AlertMonsters();
                A_SetInventory("ComboSeq", 0);
                A_SetInventory("FiredGun", 0);
                A_PlaySound("sawswing", 7, 0.5);
                A_PlaySound("weapons/gswing", 0, 0.8);
                A_Recoil(-5);
                A_DoPBWeaponAction(WRF_NOFIRE|WRF_NOSWITCH);
            }
            C7S1 A 0 Saw_SetSprite('C7S2','C7S3','C7S4');
            "####" A 0 A_StartSound("weapons/chainsaw/idle",5,CHANF_LOOPING);
            "####" ABCDEFGHIJKLM 1 A_SetRoll(roll+2);
            "####" NOP 1;
        ThrowChainsawHold:
            C7S1 A 0 Saw_SetSprite('C7S2','C7S3','C7S4');
            "####" Q 1;
            "####" A 0 A_JumpIf(PressingAltfire(), "ThrowChainsawHold");
        ThrowChainsawActual:
            C8S1 A 0 Saw_SetSprite('C8S2','C8S3','C8S4');
            "####" ABCD 1;
            "####" EFG 1;
            AXEG A 0 A_FireProjectile("PBX_ThrownChainsaw", 0, 0, 0, 0);
            AXEZ ABC 1 PB_RotateCamera(addPitch:1,addAngle:2);
            AXEZ D 1 PB_RotateCamera(addPitch:0.5,addAngle:1);
            AXEZ E 1 PB_RotateCamera(addPitch:0.2,addAngle:0.5);
            AXEZ E 2;
            AXEZ E 1 PB_RotateCamera(addPitch:-0.2,addAngle:-0.5);
            AXEZ EEF 1 PB_RotateCamera(addPitch:-1,addAngle:-2);
            AXEZ G 1 PB_RotateCamera(addPitch:-0.5,addAngle:-1);
            AXEZ HI 1;
            TNT1 A 0 A_JumpIfInventory("PowerInfiniteAmmo", 1, "GoingToReady");
            Goto SafelyRemoveWeapon;
    }
}

CLASS PBX_ThrownChainsaw : actor
{
	Default
	{
        Radius 10;
        Height 4;
        Speed 45;
        Scale 0.8;
        Damagefunction 0;
        DamageType "Saw";
        +MISSILE;
        +FORCEXYBILLBOARD;
        -NOGRAVITY;
        +THRUSPECIES;
        +BLOODSPLATTER;
        Species "Marines";
        +MTHRUSPECIES;
        //+ripper;
        +skyexplode;
        Gravity 0.9;
        Obituary "%o was cut up by a Chainsaw";
        //SeeSound "weapons/chainsaw/loop"
        Decal "SawVerticalThrown";
        //+ripper
	}	
	
    Vector3 mStickOfs;
    double mStickAngle;
	
	int mSawTimer;
	
	Override int SpecialMissileHit(Actor victim) 
    {

        if (victim && victim.bshootable && victim.health > 0 && !victim.binvulnerable)
        {
            tracer = victim;
            mStickOfs = victim.Vec3To(self);
            mStickAngle = tracer.angle;
        }
        Else if(victim)
            setstatelabel("fall");

        Return -1;
    }
	Override void postbeginplay()
    {
        super.postbeginplay();
        mSawTimer = 0;
        //savedangle = angle;
    }
	
	
	States
	{
        Spawn:
            CSAW B 4 A_ALertMonsters(200);
            SAWG A 0 A_startSound("weapons/chainsaw/loop",4);
            Loop;

        Death:
        Xdeath:
            TNT1 A 0;
            TNT1 A 0 {
                If(!tracer)
                    setstatelabel("explode");
            }
        Stuck:
            CSAW BBBB 1 {
                If(!tracer || tracer.health < 1 || mSawTimer > 150)
                {
                    If(tracer && !tracer.bnoblood)
                        A_startsound("misc/gibbed",24);
                    setstatelabel("fall");
                }
                mSawTimer++;
                if(tracer) 
                { 
                    If(tracer.health > 0)
                    {
                        double angDiff = DeltaAngle(mStickAngle, tracer.angle);
                        if (angDiff)
                        {
                            mStickOfs.xy = RotateVector(mStickOfs.xy, angDiff);
                            angle += angDiff;
                        }
                        SetOrigin(tracer.Vec3Offset(mStickOfs.x, mStickOfs.y, mStickOfs.z), true);
                        mStickAngle = tracer.angle;
                    }
                }
            }
            SAWG AA 0  {
                // A_spawnprojectile("sawdamagevertical",0,0,0,0,0,AAPTR_TRACER);
                A_spawnprojectile("sawswing",0,0,0,0,0,AAPTR_TRACER);
                A_startSound("weapons/chainsaw/loop",4);
                If(tracer && tracer.findstate("pain") && tracer.health > 0)
                    tracer.setstatelabel("pain.cut");
            }
            LOOP;
            
        Explode:
            TNT1 A 0 A_checkceiling("fall");
            AXEG A 0 A_SpawnItemEX("Sparks");
            AXEG A 0 A_startSound("AXECLN", 6);
            TNT1 A 0 A_StopSound(4);
            TNT1 A 0 A_ALertMonsters(200);
            TNT1 A 0  {	
                //We need to make this the physical chainsaw actor because of the new pickup system
                //Through the magic of zscript we can give it the same properties as the original actor
                if(target.FindInventory("PowerInfiniteAmmo"))
                {
                    return resolvestate(null);
                }

                let thrownchainsaw = PBX_ChainsawEditedBase(spawn("PBX_ChainsawEdited",pos));
                If(thrownchainsaw)
                {
                    //Thrown chainsaws are 3d and get stuck in walls, 
                    //so we need to set their state label and disable their gravity
                    thrownchainsaw.setstatelabel("SpawnThrown"); // This state sets the mode to throw
                    thrownchainsaw.bnogravity = true;
                    thrownchainsaw.angle = angle;
                    thrownchainsaw.ammogive1 = 0;
                }
                return resolvestate(null);
            }
            stop;
            
        Fall:
            TNT1 A 0 A_StopSound(4);
            TNT1 A 0 A_ALertMonsters(200);
            TNT1 A 0  {	
                //We need to make this the physical chainsaw actor because of the new pickup system
                //Through the magic of zscript we can give it the same properties as the original actor
                //A_SpawnItemEx ("ChainsawStuckInWall",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
                if(target.FindInventory("PowerInfiniteAmmo"))
                {
                    return resolvestate(null);
                }
                
                let thrownchainsaw = PBX_ChainsawEditedBase(spawn("PBX_ChainsawEdited",pos));
                If(thrownchainsaw)
                {
                    thrownchainsaw.setstatelabel("SpawnThrown"); // This state sets the mode to throw
                    thrownchainsaw.angle = angle;
                    thrownchainsaw.ammogive1 = 0;
                }
                return resolvestate(null);
            }
            stop;
    }
}