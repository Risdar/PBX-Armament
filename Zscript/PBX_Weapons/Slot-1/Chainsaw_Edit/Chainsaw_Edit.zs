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
        ERROR_WHEEL = -2
        ,NO_SSG
        ,CLOSE_WHEEL
		,SELECT_SLASH
		,SELECT_THROW
		,SELECT_QUICKSSG
		,TOGGLE_LIFESTEAL
	}

    override void PostBeginPlay()
    {
        super.PostBeginPlay();
        mChainsawAlt = SELECT_SLASH;
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

            case SELECT_SLASH: 
                Saw_SetMode(tokens);
                A_Print("$PBX_ChainsawEdit_Slash");
                break;

            case SELECT_THROW: 
                Saw_SetMode(tokens);
                A_Print("$PBX_ChainsawEdit_Throw");
                break;
                
            case SELECT_QUICKSSG:
                Saw_GetSSG();
                Saw_SetMode(tokens);
			    A_Overlay(SAWSSG_LAYER,"SSGSelect",false);
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

    States
    {
        ReloadChainsawSSGContinue:
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
            TNT1 A 0 A_JumpIf(Saw_GetSSGPtr().ammo2.amount >= 1, "HalfReloadRight");
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
		    Goto Ready;
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
	
    Vector3 stickOfs;
    double stickAngle;
	
	int sawtimer;
	
	Override int SpecialMissileHit(Actor victim) 
    {

        if (victim && victim.bshootable && victim.health > 0 && !victim.binvulnerable)
        {
            tracer = victim;
            stickOfs = victim.Vec3To(self);
            stickAngle = tracer.angle;
        }
        Else if(victim)
            setstatelabel("fall");

        Return -1;
    }
	Override void postbeginplay()
    {
        super.postbeginplay();
        sawtimer = 0;
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
                If(!tracer || tracer.health < 1 || sawtimer > 150)
                {
                    If(tracer && !tracer.bnoblood)
                        A_startsound("misc/gibbed",24);
                    setstatelabel("fall");
                }
                sawtimer++;
                if(tracer) 
                { 
                    If(tracer.health > 0)
                    {
                        double angDiff = DeltaAngle(stickAngle, tracer.angle);
                        if (angDiff)
                        {
                            stickOfs.xy = RotateVector(stickOfs.xy, angDiff);
                            angle += angDiff;
                        }
                        SetOrigin(tracer.Vec3Offset(stickOfs.x, stickOfs.y, stickOfs.z), true);
                        stickAngle = tracer.angle;
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

                let thrownchainsaw = spawn("PBX_ChainsawEdited",pos);
                If(thrownchainsaw)
                {
                    //Thrown chainsaws are 3d and get stuck in walls, 
                    //so we need to set their state label and disable their gravity
                    thrownchainsaw.setstatelabel("SpawnThrown");
                    thrownchainsaw.bnogravity = true;
                    thrownchainsaw.angle = angle;
                    let weap = Weapon(thrownchainsaw);
                    if(weap) weap.ammogive1 = 0;

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
                
                let thrownchainsaw = spawn("PBX_ChainsawEdited",pos);
                If(thrownchainsaw)
                {
                    thrownchainsaw.setstatelabel("SpawnThrown");
                    thrownchainsaw.angle = angle;
                    let weap = Weapon(thrownchainsaw);
                    if(weap) weap.ammogive1 = 0;
                }
                return resolvestate(null);
            }
            stop;
    }
}