// Ridable Caco
// RENEGADE_ANDROiD (I got the rideable cacodemon code from his PB2022 Build, if anyone know who the original author was then please contact me)
// ThePopeOfDope (For the Cacodemon stealth kill idea)
// Jaih1r0 (For finding out how to actually code the stealth kill)

class PBX_RideableCaco : PBX_WeaponBase
{
    Default
    {
        Weapon.SelectionOrder 999999999; // never picked by weapon-cycling
	    Inventory.AltHUDIcon "CPARA0";
        Weapon.AmmoType1 "CacoTimer";
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
        +INVENTORY.UNDROPPABLE;
        +INVENTORY.UNTOSSABLE;
        +INVENTORY.ALWAYSPICKUP;
        +WEAPON.CHEATNOTWEAPON;
    }

    Weapon savedWeapon; // what the player was holding before force switch
    const CACOBALL_DIRECT_DAMAGE = 150;
    const CACOBALL_SEEKER_DAMAGE = 50;
    const CACO_DURATION = 60; //In seconds
    const CACO_HP = 120;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        // Save the last weapon used so we can switch back to it
        savedWeapon = owner.player.ReadyWeapon; 

        // Force switch
        if(owner.player.readyweapon != self)
        {
            owner.player.PendingWeapon = self;
        }

        owner.A_GiveInventory("CacoTimer",CACO_DURATION);
        owner.A_GiveInventory("CacoHP",CACO_HP);
    }

    override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
    {
        if (owner && passive && damage > 0)
        {
            int damageTake = Int(damage * 0.9); // The Caco takes 90% of the damage
            int taken = min(damageTake, owner.CountInv("CacoHP"));

            if(taken > 0)
            {
                owner.TakeInventory("CacoHP", taken);
                newdamage = damage - taken;
            }
        }
    }

    States
    {
		Select:
			TNT1 A 0 {
                bfloatbob 	= true;
                bfloat 		= true;
                bnogravity 	= true;
                bfly 		= true;

                // This is a modified PB_WeaponRaise
                A_weaponoffset(0,32);
		
                PB_SetRoll(0);
                A_zoomfactor(1.0);
                invoker.curBlood = (0,0,0);
                
                //this was in the SelectFirstPersonLegs state
                A_StopSound(CHAN_WEAPON);
                A_StopSound(CHAN_VOICE);
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_7);
                A_StopSOund(CHAN_AUTO);
                
                A_SetInventory("CantWeaponSpecial",1);
                A_SetInventory("Grabbing_A_Ledge", 0);		//Fixed bug where movement is locked when vaulting after entering a level
                A_SetInventory("DualFireReload",0);
                A_SetInventory("Kicking",0);
                A_SetInventory("Zoomed",0);
                
                A_ClearOverlays(-999, -999);
                invoker.WeaponScaleX = 1.0;
                invoker.WeaponScaleX = PB_PixelRenderingFix ? 1.2 : 1.0;
                
                PB_SetUsingKick(false);
                PB_SetUsingMelee(false);
                PB_SetUsingEquipment(false);
                PB_SetExecutingEnemy(false);
                PB_SetReloading(false);
            }
		SelectAnimation:
			TNT1 A 0;
        Ready3:
            TNT1 A 0 A_StartSound("pb/monsters/caco/pain",CHAN_AUTO);
            TNT1 A 0 A_Recoil3D(random(0,1) ? 8 : -5);
            CAPL ABCDEEEEABCDEEEEABCDEEEEABCDEEEE 1 {
                PB_SetRoll(random(-3,3));
                A_CustomMissile("Blue_FlyingBlood", 47, 0, random (0, 360), 2, random (30, 150));
                if(CountInv("CacoHP") <= 0 || CountInv("CacoTimer") <= 0)
                {
                    return resolvestate("TimeOut");
                }
                return A_DoPBWeaponAction(WRF_NOBOB | WRF_NOSWITCH | WRF_DISABLESWITCH);
            }
            TNT1 A 0 A_Jump(90, "Fire"); // A chance to randomly fire
            TNT1 A 0 PB_TakeAmmo(invoker.ammo1.getClassName(),emptyMag:0);
            Loop;

        Fire:
            TNT1 A 0 PB_JumpIfNoAmmo("TimeOut",chamber:false,secondary:false);
            TNT1 A 0 {
                PB_SetRoll(0);
                A_Recoil3D(-8);
                PB_TakeAmmo(invoker.ammo1.getClassName(),emptyMag:0);
                PBX_FireBullets("CacoBallPlayer",1,0,0,0,0);
                PB_WeaponRecoil(-2,random[sfx](-1,1));
                PB_FireOffset();
            }
            CAPL EFGHIHGFE 2;
            Goto Ready3;

        TimeOut:
        AltFire:
            TNT1 A 0 {
                PB_SetRoll(0);
                bfloatbob 	= false;
                bfloat 		= false;
                bnogravity 	= false;
                bfly 	    = false;
            }
            TNT1 A 0 A_JumpIf(CountInv("CacoHP") <= 0, "Death_Caco"); // If it died because of HP and not manual (pressing altfire)
        Execution_Cacodemon1:
            TNT1 A 0 PB_SetPlayerExecutionProperties();
            TNT1 A 0  {
				A_SpawnItemEx("PB_Cacodemon_Execution_1", 32, 0,0,0,0,0,0,SXF_NOCHECKPOSITION);
				A_ZoomFactor(0.8);
			}
			// Frame 1: 5 Ticks
			TNT1 A 0 A_StartSound("weapons/ultrwhoosh", CHAN_AUTO);
			PBFT A 1 {
				A_ZoomFactor(1.25, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:1.0,addPitch:2.0,addRoll:-5.0);
			}
			PBFT B 1 {
				A_ZoomFactor(1.35, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:2.0,addPitch:2.0,addRoll:-5.0);
			}
			PBFT C 1 {
				A_ZoomFactor(1.45, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:2.0,addPitch:2.0,addRoll:-5.0);
			}
			PBFT D 1 {
				A_ZoomFactor(1.55, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:3.0,addPitch:2.0,addRoll:-5.0);
			}
			PBFT E 1 {
				A_ZoomFactor(1.65, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:-8.0,addPitch:2.0,addRoll:-5.0);
			}
			TNT1 A 0 {
				A_FireProjectile("ShakeYourAss");
				A_StartSound("NECK_BRK", CHAN_AUTO);
				A_StartSound("EYEPULL", CHAN_AUTO);
			}
			// Frame 2: 24 ticks
			TNT1 A 0 A_StartSound("gore/tension", CHAN_BODY);
			G004 FFGH 1 {
				A_ZoomFactor(1.67, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:-1.0,addPitch:-2.0,addRoll:2.0);
			}
			G004 FFGH 1 {
				A_ZoomFactor(1.68, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:1.0,addPitch:2.0,addRoll:-2.0);
			}
			G004 IJKL 1 {
				A_ZoomFactor(1.69, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:-1.0,addPitch:-2.0,addRoll:2.0);
                PB_FireOffset();
			}
			G004 MNOP 1 {
				A_ZoomFactor(1.70, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:1.0,addPitch:2.0,addRoll:-2.0);
			}
			G004 QRST 1 {
				A_ZoomFactor(1.71, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:-1.0,addPitch:-2.0,addRoll:2.0);
			}
			TNT1 A 0 A_StartSound("NeckSnap", CHAN_AUTO);
			G004 UVWXY 1 {
				A_ZoomFactor(1.72, ZOOM_INSTANT);
                PB_RotateCamera(addAngle:1.0,addPitch:2.0,addRoll:-2.0);
			}
			G004 Z 1 {
				A_FireProjectile("ShakeYourAss");
				A_ZoomFactor(1.8, ZOOM_INSTANT);
				A_StopSound(CHAN_BODY);
				A_StartSound("misc/gibbed", CHAN_AUTO);
			}
			G004 A 1 PB_RotateCamera(addAngle:-8.0,addPitch:6.0,addRoll:10.0);
			G004 BCD 1 PB_RotateCamera(addAngle:-2.0,addPitch:3.0,addRoll:8.0);
			TNT1 A 0 A_ZoomFactor(1.2);
			TNT1 AA 1 PB_RotateCamera(addAngle:0.0,addPitch:1.0,addRoll:0.0);
			TNT1 AA 1;
			TNT1 AAAAA 1 PB_RotateCamera(addAngle:1.0,addPitch:-4.0,addRoll:-9.0);	
			TNT1 A 0 PB_UnsetPlayerExecutionProperties();
        TakeWeapon:
			TNT1 A 0 A_SetInventory("CantWeaponSpecial",0);
            TNT1 A 0 {
                player.pendingweapon = invoker.savedWeapon ? invoker.savedWeapon : player.mo.BestWeapon(null);
		        self.RemoveInventory(invoker);
            }
            stop;

        Death_Caco:
            TNT1 A 0 {
                A_SpawnProjectile("PB_CacodemonGib3", 30, 0, random (0, 360), 2, random (-30, -150));
				A_SpawnProjectile ("PB_CacodemonGib11", 35, 0, random (0, 360), 2, random (-30, -150));
				A_SpawnProjectile("PB_CacodemonGib2", 30, 0, random (0, 360), 2, random (-30, -150));
				A_SpawnProjectile("PB_CacodemonGib10", 30, 0, random (0, 360), 2, random (-30, -150));
				A_SpawnProjectile ("PB_CacodemonGib12", 24, 0, random (0, 360), 2, random (-65, -150));
				A_SpawnProjectile ("PB_CacodemonGib13", 32, 0, random (0, 360), 2, random (-65, -150));
				A_SpawnProjectile("PB_CacoDemonGib14", 48, 0, random (160, 220), 2, random (-30, -150));
				A_SpawnProjectile ("PB_CacodemonGib5", 24, 0, random (0, 360), 2, random (-65, -150));
				A_SpawnProjectile ("PB_CacodemonGib5", 24, 0, random (0, 360), 2, random (-65, -150));
				A_SpawnProjectile("PB_CacodemonGib8", 30, 0, random (0, 360), 2, random (-30, -150));

                for(int i = 0; i < 8; i++) {
                    A_CustomMissile("PB_BloodMistBig", 47, 0, random (0, 360), 2, random (30, 150));
                    A_CustomMissile("PB_FlyingBlood", 47, 0, random (0, 360), 2, random (30, 150));
				}

            }
            CCD3 A 7;
			CCD3 B 6;
			CCD3 C 0 A_SpawnItemEx ("PB_DeadCacodemon7",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
            goto TakeWeapon;
    }
}

class CacoHandler : EventHandler
{
    const CACO_GRAB_RANGE = 128.0;

    private pb_ProjScreen   mProjection;
    private pb_uiHack       mTranslator;
    private transient bool  mInitialized;
    private Font            mNameFont;

    // Check if the caco is in ready/see state
    clearscope bool CanRideCaco(Actor a)
    {
        if (!a || !(a is "PB_Cacodemon")) return false;
        if (!a.bIsMonster || a.bFriendly || a.bCorpse || a.health <= 0) return false;

        return Actor.InStateSequence(a.curstate, a.FindState("See"))
            || Actor.InStateSequence(a.curstate, a.FindState("Spawn"))
            || a.Target == NULL;
    }

    // UI
    override void renderOverlay(RenderEvent event)
    {
        if(PBX_MonsterWeapon_filter & DisablePBX_RideableCaco) return;
        if (!mInitialized || automapActive || players[consolePlayer].mo == NULL)
            return;
        drawEverything(event);
    }

    private 
    ui void drawEverything(RenderEvent event)
    {
        Actor target = getTarget();
        if (CanRideCaco(target))
            Draw(event, target);
    }

    private 
    ui Actor getTarget()
    {
        PlayerInfo player = players[consolePlayer];
        if (player.mo == NULL) return NULL;
        return mTranslator.aimTargetWrapper(player.mo);
    }

    private 
    ui Vector2 makeDrawPos(RenderEvent event, Actor target, double offset)
    {
        PlayerInfo player = players[consolePlayer];

        mProjection.cacheResolution();
        mProjection.cacheFov(player.fov);
        mProjection.orientForRenderOverlay(event);
        mProjection.beginProjection();

        mProjection.projectWorldPos(target.pos + (0, 0, offset));

        pb_Viewport viewport;
        viewport.fromHud();

        return viewport.sceneToWindow(mProjection.projectToNormal());
    }

    private 
    ui void Draw(RenderEvent event, Actor target)
    {
        PlayerInfo player = players[consolePlayer];

        if (player.mo.distance3D(target) > CACO_GRAB_RANGE) 
        {
            return;
        }

        Vector2 centerPos = makeDrawPos(event, target, target.height / 2.0);

        string ky  = "$PBX_PBX_RideableCaco_Stealth";   // add this to your LANGUAGE lump
        string ky2 = string.format("[%s]", PB_HelpNotificationsHandler.PB_FormatKeybinds("+USE"));

        int wd  = mNameFont.StringWidth(ky);
        int wd2 = mNameFont.StringWidth(ky2);
        int hg  = mNameFont.getheight();

        screen.drawtext(mNameFont, font.CR_UNTRANSLATED, centerPos.x - int(wd/2) - 50,  centerPos.y + hg - 80,            ky,  DTA_ScaleX, 1.8, DTA_ScaleY, 1.8);
        screen.drawtext(mNameFont, font.CR_UNTRANSLATED, centerPos.x - int(wd2/2) - 15, (centerPos.y + hg - 80) + hg + 15, ky2, DTA_ScaleX, 1.8, DTA_ScaleY, 1.8);
    }

    // Play
    override void playerEntered(PlayerEvent event)
    {
        if (level.mapName == "TITLEMAP")
        {
            destroy();
            return;
        }

        if(PBX_MonsterWeapon_filter & DisablePBX_RideableCaco) return;
        if (event.playerNumber != consolePlayer) return;
        mTranslator = NULL;
    }

    override void WorldTick()
    {
        if(PBX_MonsterWeapon_filter & DisablePBX_RideableCaco) return;
        if (!mInitialized) initialize();

        for (int pn = 0; pn < MAXPLAYERS; pn++)
        {
            if (!playerInGame[pn]) continue;

            PlayerInfo player = players[pn];
            PlayerPawn mo = player.mo;
            if (!mo || mo.FindInventory("PBX_RideableCaco")) continue;

            if (!(player.cmd.buttons & BT_USE)) continue;

            FLineTraceData traceData;
            double viewHeight = player.viewz - mo.pos.z - mo.attackZOffset;
            bool hit = mo.LineTrace(mo.angle, CACO_GRAB_RANGE, mo.pitch, 0, viewHeight, 0, 0, traceData);
            if (!hit) continue;

            Actor dacaco = traceData.HitActor;
            if (!CanRideCaco(dacaco)) continue;

            mo.A_GiveInventory("PBX_RideableCaco", 1);
            dacaco.Destroy();
        }
    }

    private 
    void initialize()
    {
        mNameFont   = Font.FindFont("PBBOLD");
        mProjection = new("pb_ProjScreen");
        mInitialized = true;
    }
}