class iJustThrowedMySaw : inventory {default{inventory.maxamount 1;}}

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
                if(target.FindInventory("PBX_PowerInfiniteAmmo"))
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
                if(target.FindInventory("PBX_PowerInfiniteAmmo"))
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