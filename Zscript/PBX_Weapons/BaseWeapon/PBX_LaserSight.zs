// Copyright 2018-2020 Alexander Kromm (m8f/mmaulwurff)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/

// Modified code of m8f's laser sights mod

//////////////////////////// LASER SIGHTS ////////////////////////////////////////////////////////////////////////////////////
extend class PBX_WeaponBase
{
// constants section /////////////////////////////////////////////////////////
    enum PBX_LaserColor
    {
        RED_DOT,
        GREEN_DOT,
        BLUE_DOT
    }

    const maxDistance = 400000.0;
    const minDistance = 50.0;
    const lFlags      = LAF_NOIMPACTDECAL | LAF_NORANDOMPUFFZ;

    const beamLifetime = 1;
    const beamFlags    = SPF_FULLBRIGHT;
    const beamAngle    = 0.0;
    const beamVel      = 0.0;
    const beamAcc      = 0.0;

// Modify these values if you want to change how the beams look
    const beamScale = 1.0;
    const beamStep = 5.0;

// attributes section ////////////////////////////////////////////////////////
    private bool mLaserSightActivated;
    protected bool mLaserInitialized;
    protected Actor mLaserPuff;

// methods section ////////////////////////////////////////////////////////
    // Call in wherever the function to handle the weapon special is located
    action void PBX_ToggleLaserSight(bool skipPlaySound = false)
    {
        invoker.mLaserSightActivated = !invoker.mLaserSightActivated;
        A_Print(invoker.mLaserSightActivated ? "$PBX_LaserOn" : "$PBX_LaserOff");
        if(!skipPlaySound) 
        {
            A_StartSound("MS/Button", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
        }
    }

    clearscope bool GetLaserActive() const
    {
        return mLaserSightActivated;
    }

    protected 
    void SetupPuff()
    {
        if (!owner || !owner.player || !owner.player.mo) 
        { 
            return; 
        }

        ClearPuff();

        mLaserPuff              = Actor.Spawn("PBX_LaserPuff");
        mLaserInitialized       = true;
        mLaserPuff.bInvisible   = true;
    }

    protected
    void ClearPuff()
    {
        // clear existing laser points
        Array<Actor> deleteList;
        let iterator = ThinkerIterator.Create("PBX_LaserPuff");
        Actor toDelete;
        while (toDelete = Actor(iterator.next(true)))
        {
            deleteList.push(toDelete);
        }
        int size = deleteList.size();
        for (int i = 0; i < size; ++i)
        {
            deleteList[i].Destroy();
        }
    }

    protected 
    void ShowLaserSight(PBX_LaserColor laserColor)
    {
        if (!owner || !owner.player || !owner.player.mo) 
        { 
            return; 
        }

        let a = owner.player.mo;

        double pitch = a.AimTarget() ? a.BulletSlope(null, ALF_PORTALRESTRICT) : a.pitch;

        string shade; 
        switch(laserColor)
        {
            case RED_DOT:   shade = "FF 00 00"; break;
            case BLUE_DOT:  shade = "00 00 FF"; break;
            case GREEN_DOT: shade = "00 FF 00"; break;
        }
        
        MaybeShowDot(pitch, a, shade);
        MaybeShowBeam(pitch, a, shade);
    }

    protected 
    void MaybeShowDot(double pitch, Actor a, string shade)
    {
        let tempPuffClass = "PBX_InvisibleSkyPuff";

        Actor tempPuff = a.LineAttack( a.angle
                                    , maxDistance
                                    , pitch
                                    , 0
                                    , "none"
                                    , tempPuffClass
                                    , lFlags
                                    );

        if (!tempPuff || !mLaserPuff) 
        { 
            return; 
        }

        double distance = a.Distance3D(tempPuff);

        double scale = 1.0;
        double opacity = 1.0;

        mLaserPuff.SetShade(shade);
        mLaserPuff.scale.x    = scale;
        mLaserPuff.scale.y    = scale;
        mLaserPuff.bInvisible = false;
        mLaserPuff.alpha      = opacity;
        mLaserPuff.SetOrigin(tempPuff.pos, true);
    }

    protected 
    void MaybeShowBeam(double pitch, Actor a, string shade)
    {
        if(!PBX_Weapons_LaserShowBeam)
        {
            return;
        }
        
        Actor  tempPuff = a.LineAttack( a.angle
                                    , maxDistance
                                    , pitch
                                    , 0
                                    , "none"
                                    , "PBX_BeamInvisiblePuff"
                                    , lFlags
                                    );

        if (!tempPuff) 
        { 
            return; 
        }

        double distance = a.Distance3D(tempPuff);
        showBeam(a, tempPuff.pos, distance, shade);
    }

    protected 
    void ShowBeam(Actor a, vector3 targetPos, double distance, string shade)
    {
        color   beamColor  = shade;
        double  size       = 2.0 * beamScale;

        double  viewHeight = a.player.viewz - a.pos.z - PlayerPawn(a).attackZOffset;
        targetPos.z -= viewHeight;

        vector3 relPos = targetPos - a.pos;
        int     nSteps = int(distance / beamStep);

        if (nSteps == 0) 
        { 
            return; 
        }

        double  xStep     = relPos.x / nSteps;
        double  yStep     = relPos.y / nSteps;
        double  zStep     = relPos.z / nSteps;
        double  alpha     = 1.0;
        int     drawSteps = nSteps - 2;

        for (int i = 2; i < drawSteps; ++i)
        {
            double xoff = xStep * i;
            double yoff = yStep * i;
            double zoff = zStep * i + viewHeight;

            a.A_SpawnParticle( beamColor, beamFlags, beamLifetime, size, beamAngle
                            , xoff, yoff, zoff
                            , beamVel, beamVel, beamVel, beamAcc, beamAcc, beamAcc
                            , alpha
                            );
        }
    }

}

// Mixin because the states used as an exception varies from weapon
// So its a static array
// Call in DoEffect()
mixin class PBX_LaserSight
{
    private
    void PBX_SpawnLaserSight(PBX_LaserColor laserColor = RED_DOT, StateLabel defaultReadyState = "Ready3")
    {
        if(!GetLaserActive() || PB_executingEnemy() || !mLaserInitialized || !mLaserPuff) 
        {
            SetupPuff();
            return;
        }

		let psp = owner.player.FindPSprite(PSP_WEAPON); if(!psp) return;

        for (int i = 0; i < blockedLaserStates.Size(); i++)
        {
            if(InStateSequence(psp.curstate, ResolveState(blockedLaserStates[i])) && !InStateSequence(psp.curstate, ResolveState(defaultReadyState)))
            {
                ClearPuff();
                return;
            }
        }

        ShowLaserSight(laserColor);
    }
}

class PBX_PuffBase : Actor abstract
{
    Default
    {
        Mass        0;
        Radius      1;
        Height      2;
        RenderStyle "Stencil";

        +NOBLOCKMAP;
        +NOGRAVITY;
        +BLOODLESSIMPACT;
        +PUFFONACTORS;
        +DONTSPLASH;
        +NOTRIGGER;
        +FORCEXYBILLBOARD;
        +NOTONAUTOMAP;
    }

    States
    {
        Spawn:
            TNT1 A 0;
            WDOB A 1 BRIGHT;
            Stop;
    }

} // class PBX_PuffBase

class PBX_InvisiblePuff : PBX_PuffBase 
{
    States 
    {
        Spawn: 
            TNT1 A 0; 
            Stop;
    }
}

class PBX_LaserPuff : PBX_PuffBase 
{
    States 
    {
        Spawn: 
            TNT1 A 0; 
            WDO1 A -1 BRIGHT; 
            Stop;
    }
}

class PBX_InvisibleSkyPuff : PBX_InvisiblePuff { Default { +SKYEXPLODE; } }

class PBX_BeamInvisiblePuff : PBX_PuffBase
{
    Default
    {
        +SKYEXPLODE;
    }

    States
    {
        Spawn:
        TNT1 A 0;
        Stop;
    }

} // class PBX_BeamInvisiblePuff