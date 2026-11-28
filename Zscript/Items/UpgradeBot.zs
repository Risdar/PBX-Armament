// Upgrade Bot
// From DOOM 2016 Arsenal 1.1
// XV117 - ACS, Sprites, Sprite Edits, Monsters Code, Decorate Code
// Sergeant Mark IV - D2K16 Weapon Test 2 (Used as Base)
// Tomtefar1988 - The Base Weapon Code is based on your mod, so it is also credited, some sprites from Tomtefars Extension
// mryayayify, IDDQD_1337 - Sprites Contribution
// Dracologist - DOOM 4 Weapon Forge (Code Taked for Vortex Rifle Damage Upgrades)
// Neccronixis - Original Weapon Sprites
// Doomguy5th - New Sprites, Sounds, Effects and Code Recycled for this Mod
// D4T Team - New Sprites for Revenant Hands
// Xaser - Amazing Mod-Swaping Animations from Argent 0.5.3
// Hexereticdoom - Original version of HXRTC HUD

class PBX_UpgradeBot : SwitchableDecoration
{

	Default
    {	
        Radius 24;
		Height 60;
		+SOLID;
		+Friendly;
		+USESPECIAL;
		MONSTER;
		-COUNTKILL;
		+SHOOTABLE;
		+LOOKALLAROUND;
		-THRUACTORS;
		+NOINFIGHTING;
		MaxTargetRange 120;
		+NOBLOOD;
		Activation THINGSPEC_Activate | THINGSPEC_ThingTargets | THINGSPEC_NoDeathSpecial;
		Mass 999999;
		Speed 0;
		health 1000;
		+FLOATBOB;
		+NOGRAVITY;
		Tag "$UPGRADEBOT_TAG";
		Scale 1.0;
    }

	States
	{
		Spawn:
			UABB AB 2 BRIGHT;
			Loop;

        Active:
           	"####" A 0 A_ChangeFlag("Solid",0);
			"####" A 0 A_Stop;
			"####" A 0 A_Warp(AAPTR_TARGET,-50,0,0,180,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE );
			"####" A 0 A_GiveToTarget("UpgradeBotAnimation", 1);
			"####" ABABABAB 2 BRIGHT;
			"####" CDCDCD 2 BRIGHT;
		Death:	
			PUFF A 0 A_PlaySound("player/cyborg/fist", 3);
			TNT1 A 0 A_SpawnItemEx ("PLOFT2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
			EXPL AAAAAA 0 A_CustomMissile ("MeleeSmoke", 0, 0, random (0, 360), 2, random (0, 360));
			TNT1 A 0 Radius_Quake (2, 6, 0, 5, 0);
			UABB E 1;
			TNT1 A 0 A_PlaySound("weapons/explode");
			TNT1 A 0 A_Scream;
			TNT1 A 0 A_NoBlocking;
			TNT1 A 0 {
				for(int i = 0; i < 5; i++)
				{
					A_CustomMissile ("MetalShard1", 5, 0, random[sfx](-10, -20), 2, random[sfx](0, 30));
					A_CustomMissile ("MetalShard2", 5, 0, random[sfx](-10, -20), 2, random[sfx](0, 30));
					A_CustomMissile ("MetalShard3", 5, 0, random[sfx](-10, -20), 2, random[sfx](0, 30));
				}
                bCorpse = true;
            }
			TNT1 AAAAAAAAA 0 A_CustomMissile ("ExplosionParticleHeavy", 50, 0, random (0, 360), 2, random (0, 180));
			TNT1 AAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("ExplosionParticleHeavy", 50, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAAAAAAA 0 A_CustomMissile ("ExplosionParticleVeryFast", 50, 0, random (0, 360), 2, random (0, 360));
			TNT1 AAAAA 0 A_CustomMissile ("MediumExplosionFlames", 50, 0, random (0, 360), 2, random (0, 360));
			EXPL AAAAA 0 A_CustomMissile ("ExplosionSmokeFast22", 50, 0, random (0, 360), 2, random (0, 360));
			UABB E 1 A_FaceTarget();
			TNT1 A 0 A_ChangeFlag("USESPECIAL", 0);
			TNT1 A 0 A_ChangeFlag("THRUACTORS", 1);
			TNT1 A 0 A_ChangeFlag("NOGRAVITY", 0);
			TNT1 A 0 A_ChangeFlag("FLOATBOB", 0);
			TNT1 A 0 ThrustThingZ(0,25,0,1);
			UABB E 8 A_Recoil(3);
			UABB F 500;
            Stop;
	}
}

// Gets all the upgrade and puts them into an array
// This way its only called once
class PBX_UpgradeBotHandler : StaticEventHandler
{
    private Array<Class<PB_UpgradeItem> > cachedUpgrades;

    // Fill the array with upgrade items
    override void OnEngineInitialize()
    {
        FillArray();
    }

    private 
	void FillArray()
    {
        cachedUpgrades.Clear();

        // Look for every class in the game
        for (int i = 0; i < AllActorClasses.Size(); i++)
        {
            // Try casting the class into PB_UpgradeItem
            Class<PB_UpgradeItem> cls = (Class<PB_UpgradeItem>)(AllActorClasses[i]);

            // Make sure its not the base PB_UpgradeItem or an Abstract class
            if (!cls || cls == 'PB_UpgradeItem' || cls.IsAbstract())
                continue;

            // Push to array
            cachedUpgrades.Push(cls);
			PBXCore_Debug.print("Found Upgrade Item");
        }

        PBXCore_Debug.printInt("PBX_UpgradeBotHandler: found %d upgrade item(s).", cachedUpgrades.Size());
    }

    // Returns a pointer to a random member of the array
    Class<PB_UpgradeItem> GetRandomUpgrade()
    {
        // If array is empty return null
        if (cachedUpgrades.Size() == 0)
            return null;

        int idx = Random(0, cachedUpgrades.Size() - 1);
        Class<PB_UpgradeItem> picked = cachedUpgrades[idx];
        cachedUpgrades.Delete(idx); // Delete it from the array so it always return a new upgrade
        return picked;
    }

    // Returns true if there's no more ugprade to be given
    bool IsUpgradeArrayEmpty()
    {
        return cachedUpgrades.Size() == 0;
    }

    // Easy way to get the handler
    static PBX_UpgradeBotHandler Get()
    {
        return PBX_UpgradeBotHandler(StaticEventHandler.Find('PBX_UpgradeBotHandler'));
    }
}

// Plays an animation and actually gives the upgrade
class UpgradeBotAnimation : PB_WeaponBase
{
    PBX_UpgradeBotHandler handler;
    Weapon savedWeapon; // what the player was holding before force switch

    Default
    {
        Weapon.SelectionOrder 999999999; // never picked by weapon-cycling
        +WEAPON.NOAUTOFIRE
        +WEAPON.NO_AUTO_SWITCH
        +WEAPON.CHEATNOTWEAPON
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNTOSSABLE
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        // Get the Handler
        handler = PBX_UpgradeBotHandler.Get();
        if (!handler)
        {
            Console.Printf("PB_UpgradeAnimWeapon: PBX_UpgradeBotHandler not found!");
        }

        // Save the last weapon used so we can switch back to it
        savedWeapon = owner.player.ReadyWeapon; 

        // Force switch
        if(owner.player.readyweapon != self)
            owner.player.PendingWeapon = self;
    }

    States
    {
		Select:
            P2ND A 0; P3ND A 0; P4NO A 0;
            P4ND A 0; P1NO A 0;
            P2NO A 0; P3NO A 0;
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				A_ZoomFactor(1.0);
			}
			TNT1 A 0 SetPlayerProperty(0,1,4);
			TNT1 A 0 A_UnsetShootable();
			TNT1 A 0 A_Stop();
			TNT1 A 0 A_SetPitch(0);
			PK4P ABCDEFGH 2;
			// TNT1 A 6;
            TNT1 A 6;
            TNT1 A 0 A_PlaySound("weapons/ultrwhoosh", 5);
            P1ND EF 1 {
                PBX_SetFistSprite('P2ND','P3ND','P4ND','P1NO','P2NO','P3NO','P4NO');
                PB_SetRoll(roll-2);
            }
            "####" G 1;
            "####" HIJKLMNO 1 PB_SetRoll(roll-1);
            "####" O 1;
            "####" PQ 1 PB_SetRoll(roll+2);
            TNT1 A 0 PB_SetRoll(0);
            
			TNT1 A 5;
			TNT1 A 0 A_SetShootable();
			TNT1 A 0 SetPlayerProperty(0,0,4);
			TNT1 A 0 PBX_GiveUpgrade();
			Stop;
    }

    action void PBX_SetFistSprite(
        name red, 
        name blue, 
        name green, 
        name berserk, 
        name berserkRed, 
        name berserkBlue,
        name berserkGreen
    )
    {
        name spriteToUse;
        bool hasBerserk = invoker.OwnerHasBerserk();

        if(hasBerserk) 
            spriteToUse = berserk;

        if(PB_IsVisorBlood())
        {
            switch(PB_GetVisorBlood())
            {
                case REDBLOODVISOR:     spriteToUse = hasBerserk ? berserkRed   : red;      break;
                case BLUEBLOODVISOR:    spriteToUse = hasBerserk ? berserkBlue  : blue;     break;
                case GREENBLOODVISOR:   spriteToUse = hasBerserk ? berserkGreen : green;    break;
            }
        }
        if(spriteToUse != "")
            A_SetWeaponSpriteEX(spriteToUse);
    }

    // Called on the last animation frame: grants the upgrade, restores the
    // player's previous weapon, then cleans itself out of the inventory.
    action void PBX_GiveUpgrade()
    {
		PBXCore_Debug.print("Start Giving Upgrade");
        if (invoker.handler && !invoker.handler.IsUpgradeArrayEmpty())
        {
            Class<PB_UpgradeItem> upgradeCls = invoker.handler.GetRandomUpgrade();
            if (upgradeCls)
            {
        		// Console.Printf("Given %s", upgradeCls.getClassName());
                A_Print(String.Format(StringTable.Localize("$UPGRADEBOT_GIVE"),upgradeCls.getClassName()));
                GiveInventoryType(upgradeCls);
            }
        }
        else if (invoker.handler.IsUpgradeArrayEmpty())
        {
            A_Print("$UPGRADEBOT_GIVEBACKPACK");
            GiveInventoryType("PB_Backpack");
        }
		player.pendingweapon = invoker.savedWeapon ? invoker.savedWeapon : player.mo.BestWeapon(null);
		self.RemoveInventory(invoker);
    }
}

// Modified from PB's execution handler
class PBX_UpgradeBotDisplay : EventHandler
{
    private pb_ProjScreen 	    mProjection;
    private pb_uiHack 		    mTranslator;
    private transient bool      mInitialized;
    private Font                mNameFont;
    
    private
    void initialize()
    {
        mNameFont       = Font.FindFont("PBBOLD");
        mProjection  	= new("pb_ProjScreen");
        mInitialized 	= true;
    }

    override void playerEntered(PlayerEvent event)
    {
        if (level.mapName == "TITLEMAP")
        {
            destroy();
            return;
        }

        if (event.playerNumber != consolePlayer) return;
        mTranslator = NULL;
    }

    override
    void renderOverlay(RenderEvent event)
    {
        if (!mInitialized || automapActive || players[consolePlayer].mo == NULL)
            return;
        drawEverything(event);
    }

// private: ////////////////////////////////////////////////////////////////////////////////////////

    private ui
    void drawEverything(RenderEvent event)
    {
        Actor target = getTarget();
        if(target && target is "PBX_UpgradeBot") 
        {
            Draw(event, target);
        }
    }

    private ui
    Vector2 makeDrawPos(RenderEvent event, Actor target, double offset)
    {
        PlayerInfo player = players[consolePlayer];

        mProjection.cacheResolution();
        mProjection.cacheFov(player.fov);
        mProjection.orientForRenderOverlay(event);
        mProjection.beginProjection();

        mProjection.projectWorldPos(target.pos + (0, 0, offset));

        pb_Viewport viewport;
        viewport.fromHud();

        Vector2 drawPos = viewport.sceneToWindow(mProjection.projectToNormal());

        return drawPos;
    }

    private ui
    void Draw(RenderEvent event, Actor target)
    {
        PlayerInfo player = players[consolePlayer];
        
        Vector2 centerPos = makeDrawPos(event, target, target.height / 2.0);
        double distance = player.mo.distance3D(target);
        double dist = player.mo.radius + player.mo.userange;

        // Skip if the player is far or if the bot is dead
        if ((distance > dist*2.5) || target.bCorpse || distance == 0) return;
        
        string ky,ky2;
        ky = "$UPGRADEBOT_DISPLAY";
        ky2 = string.format("[%s]",PB_HelpNotificationsHandler.PB_FormatKeybinds("+USE"));

        int wd,wd2,hg;
        wd = mNameFont.StringWidth(ky);
        wd2 = mNameFont.StringWidth(ky2);
        hg = mNameFont.getheight();

        screen.drawtext(mNameFont, font.CR_UNTRANSLATED, centerPos.x - int(wd/2) - 50, centerPos.y+hg-80, ky, DTA_ScaleX, 1.8, DTA_ScaleY, 1.8);
        screen.drawtext(mNameFont, font.CR_UNTRANSLATED, centerPos.x - int(wd2/2) - 15, (centerPos.y+hg-80)+hg+15, ky2, DTA_ScaleX, 1.8, DTA_ScaleY, 1.8);

        if(PBX_SEND_TIP)
        {
            Array<String> tips;
			tips.Push("$PBX_UpgradeBot_Tip1");
            PBX_Handler.SendTipArrayIfNeeded(tips,PBX_ITEM_HELP_FLAG,PBX_Armory_Tip_UpgradeBot);
        }
            
    }
    
    private ui
    Actor getTarget()
    {
        PlayerInfo player = players[consolePlayer];
        if (player.mo == NULL) return NULL;
        Actor target = mTranslator.aimTargetWrapper(player.mo);
        return target;
    }

    override void worldTick()
    {
        if (!mInitialized) { initialize(); }
    }

}