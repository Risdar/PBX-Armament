// Cyberdemon Rocket Launcher
// From a Brutal Doom Addon by Dox778
// Ali Jr. - base sprites
// IDDQD_1337 - base brightmaps
// Sechtera - improved firing frames
// SgtMarkIV, TypicalSF, Acclaim Entertainment and Probe Entertainment - muzzle flashes
// Jenny - Port to PB (maybe?)
// Pickup sprite is from Brutal Doom Arthur Edition by arthoriusb2593
// The idea for the laser altfire is from HyperExia's Brutal Doom Addon, however the code is from PB's Railgun

// Includes
// #include "./CyberRL_Functions.zs"

class PBX_CyberdemonRL : PBX_WeaponBase
{
	Default
	{
        //$Title Cyberdemon RL
        //$Category Weapons
        //$Sprite CYBFA0
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        Inventory.AltHudIcon "CYBFV0";
		PB_WeaponBase.ReserveToMagAmmoFactor 3;
		
//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
		Weapon.AmmoType1 "PB_RocketAmmo";
	    Weapon.AmmoGive1 30;
		
//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
		Obituary "$OB_WEAP_CYBERRL";
		Inventory.Pickupmessage "$PBX_CyberdemonRL_Pickup";
		Inventory.PickupSound "BFGREADY";
		Tag "$PBX_CyberdemonRL_Tag";
        
//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.EXPLOSIVE;
        +WEAPON.NOAUTOFIRE;
		+Inventory.AUTOACTIVATE;
        +Inventory.AlwaysPickUp;
        +FORCEXYBILLBOARD;
        +FLOORCLIP;
        +DONTGIB;
	}

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
	bool mLaserMode;
	int shotCount;

	enum CyberRL_AmmoTakes
	{
		AMMO_PER_DURABILITY = 3, // How many rockets does it take for one point of durability
		AMMO_PER_DURABILITY_LASER = 5, // The laser mode takes this much rocket per firing
		DURABILITY = 75, // Durability Amount
		DURABILITY_TAKE_NORMAL = 1,
		DURABILITY_TAKE_LASER = 15
	}

	const DURABILITY_NAME = "CyberRLDurability"; 
      
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
	override bool TryPickup(in out Actor toucher)
    {
        bool pickup = Super.TryPickup(toucher);
        if (pickup)
			toucher.A_giveinventory(DURABILITY_NAME,DURABILITY);
		
        return pickup;
    }
    
//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
	action void CyberRl_FireWeapon(int ticCount)
	{
		switch (ticCount)
		{
			default:
			case 1:
				A_AlertMonsters();
				A_StartSound("0SRFIRE", CHAN_WEAPON, CHANF_OVERLAP);
				A_ZoomFactor(0.98);
				PB_LowAmmoSoundWarning("default", invoker.ammotype1.getclassname());
				A_TakeInventory(invoker.AmmoType1, AMMO_PER_DURABILITY, TIF_NOTAKEINFINITE);
				A_TakeInventory(DURABILITY_NAME,DURABILITY_TAKE_NORMAL,TIF_NOTAKEINFINITE);
				PB_FireBullets("CRL_Rocket", 1, 0, 0, 0, 0.5);
				PB_IncrementHeat(4);
				break;
			//Tic 2
			case 2:
				A_ZoomFactor(1.0);
				PB_WeaponRecoil(-4,frandom[sfx](-4,4));
				break;
		}
	}

	// Modified from PB's railgun code
	action void CyberRL_FireLaser()
	{
		double vz = (height * 0.5 - floorclip + player.mo.AttackZOffset*player.crouchFactor) - 8; //little offset
		Vector3 dir = (AngleToVector(angle, cos(pitch)), -sin(pitch));
		vector3 spos = (pos.xy,pos.z + vz);

		let rail = new("PB_Rail"); if(!rail) return;

		rail.Trace(spos,cursector,dir,8192,TRACE_NoSky,Line.ML_BLOCKEVERYTHING|Line.ML_BLOCKHITSCAN,false,invoker.owner);
		vector3 fpos = rail.results.HitPos;
		fpos -= rail.results.HitVector; //step back 1 map unit, not necessary now, but for spawning something at hitlocation is useful
		
		vector3 dif = levellocals.Vec3diff(spos,fpos);
		vector3 dr = dif.unit();
		double dis = dif.length();
		
		int q = int(dis / railpartstep) + 1; //+ 1 to ensure its always more than 0, since distance cant be negative but can be 0
		
		for(int i = 0; i < rail.hitActors.Size(); i++)
		{
			int raildmg = 757;
			string raildmgtype = "Railgun";
			[raildmg, raildmgtype] = GetLimbDamage(raildmg, raildmgtype, (rail.hitX[i], rail.hitY[i], rail.hitZ[i]), rail.hitActors[i], invoker.owner);
			rail.hitActors[i].DamageMobj(invoker, invoker.owner, raildmg, raildmgtype, DMG_THRUSTLESS);
		}
		
		for(int i = 0; i < q; i++)
		{
			spos += (dr * railpartstep);
			if(i > 0)
				PB_DrawRailFx1(spos);
			
			if(i % 4 == 0)
				PB_SpawnRailShockWave(spos,1,i/4);
		}

		// Take Durability and Ammo
		A_TakeInventory(DURABILITY_NAME,DURABILITY_TAKE_LASER,TIF_NOTAKEINFINITE);
		A_TakeInventory(invoker.AmmoType1, AMMO_PER_DURABILITY_LASER, TIF_NOTAKEINFINITE);
	}

	action Void CyberRL_VisualLaser()
	{
		double vz = (height * 0.5 - floorclip + player.mo.AttackZOffset*player.crouchFactor) - 8; //little offset
		Vector3 dir = (AngleToVector(angle, cos(pitch)), -sin(pitch));
		vector3 spos = (pos.xy,pos.z + vz);

		let laser = new("PB_Laser"); if(!laser) return;

		laser.Trace(spos,cursector,dir,8192,TRACE_NoSky,Line.ML_BLOCKEVERYTHING|Line.ML_BLOCKHITSCAN,false,invoker.owner);
		let res = laser.results;
		vector3 fpos = res.HitPos;
		fpos -= res.HitVector; //step back 1 map unit, not necessary now, but for spawning something at hitlocation is useful
		
		vector3 dif = levellocals.Vec3diff(spos,fpos);
		vector3 dr = dif.unit();
		double dis = dif.length();
		
		int q = int(dis / railpartstepaim + 1); //+ 1 to ensure its always more than 0, since distance cant be negative but can be 0
		
		for(int i = 0; i < q; i++)
		{
			spos += (dr * railpartstepaim);
			if(i > 0) //skip the first iteration, so it doesnt spawn a particle blocking the view
				PB_DrawRailFx1(spos,0);
		}
	}
	

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
	States
	{
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
		Spawn:
            CYBF V -1;
            Stop;

        Deselect:
           TNT1 A 0 {
                PBX_WeaponLower();
				A_StopSound(CHAN_6);
			}
			CYBF LMNO 1 BRIGHT;
			TNT1 A 0 A_Lower();
			Wait;
			
		Select:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(78);
                PBX_WeaponRaise("BFGREADY");
			    return PB_RespectIfNeeded();
			}
		SelectAnimation:
			TNT1 A 0 A_StartSound("RLCYCLE", CHAN_AUTO, CHANF_OVERLAP);
			CYBF I 0 A_GunFlash();
			CYBF ONML 1 BRIGHT;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
		Ready3:
			TNT1 A 0 {
				PB_HandleCrosshair(78);
				PB_CoolDownBarrel();
				A_StartSound("BFGHUM",CHAN_6,CHAN_LOOP);
			}
			CYBF IJ 1 BRIGHT A_DoPBWeaponAction();
			Loop;
		
//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
		Fire:
            TNT1 A 0 PBX_HandleDurability(DURABILITY_NAME,AMMO_PER_DURABILITY);
            TNT1 AAAA 0;
			CYBF A 1 BRIGHT CyberRl_FireWeapon(1);
			CYBF B 1 BRIGHT CyberRl_FireWeapon(2);
			CYBF CDD 1 BRIGHT;
			CYBF EFG 1 BRIGHT {
				if(JustPressed(BT_ATTACK)) return ResolveState("Fire");
                return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOPRIMARY);
			}
			CYBF HJ 1 BRIGHT {
				if(JustPressed(BT_ATTACK)) return ResolveState("Fire");
                return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOPRIMARY);
			}
			TNT1 A 0 PB_ReFire();
			goto Ready3;

		Reload:
			TNT1 A 0;
			goto Ready3;

//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
		AltFire:
			TNT1 A 0 { 
				if(invoker.mLaserMode)
				{
					return resolvestate("FireLaser");
				} 
				return resolvestate(null);
			}
			TNT1 A 0 { invoker.shotCount = 0; }
		AltFireLoop:
            TNT1 A 0 PBX_HandleDurability(DURABILITY_NAME,AMMO_PER_DURABILITY);
			CYBF A 1 Bright CyberRl_FireWeapon(1);
			CYBF B 1 Bright CyberRl_FireWeapon(2);
			TNT1 A 0 { invoker.shotCount++; }
			TNT1 A 0 A_JumpIf(invoker.shotCount == 4, "FinishLoop");
			CYBF CDEFG 1 Bright;
			TNT1 A 0 A_JumpIf(invoker.shotCount < 4, "AltFireLoop");
		FinishLoop:
			CYBF C 1 Bright;
			CYBF D 3 Bright;
			CYBF DEEFFGG 1 Bright;
			CYBF HHJ 1 Bright;
			CYBF IJIJIJ 1 Bright;
			TNT1 A 0 PB_ReFire();
			goto Ready3;

		FireLaser:
            TNT1 A 0 PBX_HandleDurability(DURABILITY_NAME,AMMO_PER_DURABILITY_LASER);
			TNT1 A 0 {
				if(CountInv(DURABILITY_NAME) < DURABILITY_TAKE_LASER)
				{
					return resolvestate("NoAmmo");
				}
				return resolvestate(null);
			}
			TNT1 A 0 A_StartSound("CYBRLZR",CHAN_6);
			CYBF IJ 1 CyberRL_VisualLaser();
			CYBF IJ 1 CyberRL_VisualLaser();
			CYBF IJ 1 CyberRL_VisualLaser();
			CYBF IJ 1 CyberRL_VisualLaser();
		LaserHold:
			TNT1 A 0 A_StartSound("weapons/railgun/laserfullycharged", CHAN_5, CHANF_OVERLAP|CHANF_LOOPING,0.37, ATTN_NORM, 1.1);
			CYBF IJ 1 CyberRL_VisualLaser();
			TNT1 A 0 PB_ReFire("LaserHold");
			CYBF I 1 BRIGHT; 
			CYBF J 1 BRIGHT {
				CyberRL_FireLaser();
				A_SetBlend("Red",0.32,6);
				A_StartSound("weapons/railgun/laser_huge", CHAN_5, CHANF_OVERLAP);
				A_StopSound(CHAN_6);
				A_ZoomFactor(0.92);
			}
			CYBF A 1;
			CYBF I 0 PB_WeaponRecoil(pitchDelta:0,angleDelta:-2);
			CYBF BC 1 A_ZoomFactor(0.94);
			TNT1 A 0 PB_WeaponRecoil(pitchDelta:0,angleDelta:-1);
			CYBF DE 1 A_ZoomFactor(0.96);
			TNT1 A 0 PB_WeaponRecoil(pitchDelta:0,angleDelta:0.6);
			CYBF F 1 A_ZoomFactor(0.98);
			CYBF G 1 PB_WeaponRecoil(pitchDelta:0,angleDelta:0.8);
			TNT1 A 0 PB_WeaponRecoil(pitchDelta:0,angleDelta:0.8);
			CYBF H 1 PB_WeaponRecoil(pitchDelta:0,angleDelta:0.8);
			CYBF J 1 A_ZoomFactor(1.0);
			TNT1 A 0 PB_ReFire();
			goto Ready3;
		AltFire2Cancel:
			TNT1 A 0 A_StopSound(CHAN_6);
			CYBF IJ 1;
			goto Ready3;

        NoAmmo:
            TNT1 A 0 A_PlaySound("weapons/empty", 4);
			CYBF IJIJ 1 BRIGHT A_DoPBWeaponAction(WRF_NOFIRE);
		   	goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
		Weaponspecial:
			TNT1 A 0 A_Takeinventory("GoWeaponSpecialAbility",1);
			TNT1 A 0 {
				invoker.mLaserMode = !invoker.mLaserMode;
            	A_StartSound("MS/Button", CHAN_AUTO, CHANF_OVERLAP);
				A_Print(invoker.mLaserMode ? "$PBX_CyberdemonRL_Laser" : "$PBX_CyberdemonRL_Triple");
			}
			goto Ready3;

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
		FlashPunching:
            CYBF PQRSTTUUUTTSRQP 1;
			goto Ready3;

        FlashKicking:
			CYBF PQRSTTUUUUTTSRQP 1;
			goto Ready3;
			
		FlashAirKicking:
            CYBF PQRSTTTUUUTTTSRQP 1;
			goto Ready3;
			
		FlashSlideKicking:
            CYBF PQQRRSSTTTTUUUUUTTTTSSRRQQP 1;
			goto Ready3;
			
		FlashSlideKickingStop:
			CYBF SRRQQPP 1;
			goto Ready3;
	}
}