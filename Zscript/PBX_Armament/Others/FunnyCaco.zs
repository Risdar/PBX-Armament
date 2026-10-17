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
    const CACO_DURATION = 48;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        // Save the last weapon used so we can switch back to it
        savedWeapon = owner.player.ReadyWeapon; 

        // Force switch
        if(owner.player.readyweapon != self)
            owner.player.PendingWeapon = self;
    }

    States
    {
		Select:
            TNT1 A 0 A_GiveInventory("CacoTimer",48);
            TNT1 A 0 setplayerproperty (1, 1, 3);
            TNT1 A 0 A_SetInvulnerable();
			TNT1 A 0 {
                // This is a modified PB_WeaponRaise
                A_weaponoffset(0,32);
		
                PB_SetRoll(0);
                A_zoomfactor(1.0);
                invoker.curBlood = (0,0,0);
                
                //this was in the SelectFirstPersonLegs state
                A_StopSound(1);
                A_StopSound(CHAN_VOICE);
                A_StopSound(5);
                A_StopSound(6);
                A_StopSound(7);
                A_StopSOund(CHAN_AUTO);
                
                A_SetInventory("CantWeaponSpecial",0);		//Fixes bug with Weapon Special Key no longer working when changing SGL grenade type or RL missile mode
                A_SetInventory("Grabbing_A_Ledge", 0);		//Fixed bug where movement is locked when vaulting after entering a level
                A_SetInventory("DualFireReload",0);
                A_SetInventory("Kicking",0);
                A_SetInventory("Zoomed",0);
                
                A_ClearOverlays(-999, -999);
                // A_Overlay(PSP_MELEEEQHANDLER, "Melee_Equipment_Handler_Overlay");
                // A_Overlay(PSP_KICKHANDLER, "KickHandler_Overlay");
                // A_Overlay(PSP_EQTOGGLEHANDLER, "Equipment_Toggle_Handler_Overlay");
                invoker.WeaponScaleX = 1.0;
                // A_Overlay(PSP_FIRSPERSONLEGS, "FirstPersonLegsStand");
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
            TNT1 A 0 PB_JumpIfNoAmmo("TimeOut");
            TNT1 A 0 A_PlaySound ("pb/monsters/caco/pain", 6);
            CAPL ABCDEEEE 4 {
                A_WeaponReady(WRF_NOBOB | WRF_NOSWITCH | WRF_DISABLESWITCH);
                PB_SetRoll(roll-3);
                A_CustomMissile ("Blue_FlyingBlood", 47, 0, random (0, 360), 2, random (30, 150));
            }
            TNT1 A 0 A_Recoil3D(8);
            CAPL ABCDEEEE 4 {
                A_WeaponReady(WRF_NOBOB | WRF_NOSWITCH | WRF_DISABLESWITCH);
                PB_SetRoll(roll+3);
                A_CustomMissile ("Blue_FlyingBlood", 47, 0, random (0, 360), 2, random (30, 150));
            }
            TNT1 A 0 A_Recoil3D(-5);
            TNT1 A 0 A_Jump(90, "Fire"); // A chance to randomly fire
            TNT1 A 0 PB_TakeAmmo(invoker.ammo1.getClassName());
            Loop;

        Fire:
            TNT1 A 0 PB_SetRoll(0);
            TNT1 A 0 A_Recoil3D(-8);
            TNT1 A 0 PB_TakeAmmo(invoker.ammo1.getClassName());
            TNT1 A 0 A_FireCustomMissile("CacoBallPlayer");
            CAPL EFGHIHGFE 2 PB_SetRoll(roll-2);
            TNT1 A 0 PB_SetRoll(0);
            Goto Ready;

        TimeOut:
        AltFire:
            TNT1 A 0 PB_SetRoll(0);
            TNT1 A 0 SetPlayerProperty(1,0,3);
            TNT1 A 0 PB_SetPlayerExecutionProperties();
        Execution_Cacodemon1:
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
			TNT1 A 0 A_SetInventory("CantWeaponSpecial",0);
            TNT1 A 0 {
                player.pendingweapon = invoker.savedWeapon ? invoker.savedWeapon : player.mo.BestWeapon(null);
		        self.RemoveInventory(invoker);
            }
            stop;
                    
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