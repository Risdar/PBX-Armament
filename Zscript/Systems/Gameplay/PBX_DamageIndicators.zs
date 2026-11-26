Class D4DHandler : EventHandler
{
	override void OnRegister()
	{
		SetOrder(666);
		Super.OnRegister();
	}
	
	override void WorldLoaded(WorldEvent e)
	{
		ArrowManager = D4VisualDamageManager.Create();
	}
	
	override void RenderOverlay(RenderEvent e)
	{
		RenderDamageIndicators(e);
	}
	
	override void WorldTick()
	{
		TickDamageIndicators();
	}
	
	override void WorldThingDamaged(WorldEvent e)
	{
		Actor damaged =	e.Thing;
		
		if (damaged.player)
		{
			Actor	src = e.DamageSource,
					inf = e.Inflictor;
			if (!src && !inf)
				return;
			//console.printf("Damagetype: (\cd%s\c-).",e.damagetype);
			AddEventDamageIndicator(e);
		}
	
	}
	
	private D4VisualDamageManager ArrowManager;
	
	private ui void RenderDamageIndicators(RenderEvent e)
	{
		if (ArrowManager)
			ArrowManager.Render(e);
	}
	
	private void TickDamageIndicators()
	{
		if (ArrowManager)
			ArrowManager.Tick();
	}
	
	private void AddEventDamageIndicator(WorldEvent e)
	{
		if (ArrowManager)
			ArrowManager.AddIndicator(e.DamageSource, e.Inflictor, e.Thing, e.Damage,e.DamageType);
	}
	
}

//==============================================================================
// Damage Indicators
//==============================================================================

Class D4VisualDamageManager play
{
	private Array<D4DamageIndicator> Arrows;
	private int Timer;
	const ClearTimer = 5 * 5;
	int indtype;
	bool nocolor;
	color defaultColor;
	static D4VisualDamageManager Create()
	{
		let vdm = new('D4VisualDamageManager');
		vdm.Init();
		return vdm;
	}
	
	protected void Init()
	{
		Arrows.Clear();
		defaultColor = "FF0000";
	}
	
	void AddIndicator(Actor src, Actor inf, Actor plr, int damage = 0, name dmgtype = 'Normal')
	{
		if ((!src && !inf) || !plr || src == plr)
			return;
		
		for (int i = 0; i < Arrows.Size(); i++)
		{
			if (Arrows[i] && Arrows[i].src == src)
			{
				Arrows[i].ResetTimer(plr.player ? cvar.getcvar("D4D_DITimer",plr.player).getint() : -1);
				if(nocolor)
					Arrows[i].col = defaultColor;
				else
					Arrows[i].col = GetArrowColor(dmgtype);
				//Console.Printf("Updated arrow.");
				return;
			}
		}
		if(plr.player)
		{
			indtype 	 = cvar.GetCVar("D4D_IndicatorType",plr.player).getint();
			nocolor 	 = cvar.getcvar("D4D_NoColorType",plr.player).getbool();
			defaultColor = cvar.getcvar("D4D_DefColor",plr.player).getint();
		}	
		let arrow = new('D4DamageIndicator');
		arrow.src = src;
		arrow.inf = inf;
		if (src)	arrow.srcpos = src.pos;
		else if ((inf && inf.bMISSILE && inf.target) || inf)
		{
			src = (inf.target) ? inf.target : inf;
			arrow.srcpos = src.pos;
		}
		if (inf)	arrow.infpos = inf.pos;
		
		if(nocolor)
			arrow.col = defaultColor;
		else
			arrow.col = GetArrowColor(dmgtype);
		
		arrow.plr = plr;
		arrow.highlightreq = false;
		switch(indtype)
		{
			case 0:
			default:
				arrow.tex = TexMan.CheckForTexture("Graphics/HUD/DmgDir3.png",TexMan.Type_Any);
				break;
			case 1:
				arrow.tex = TexMan.CheckForTexture("Graphics/HUD/DmgDir2.png",TexMan.Type_Any);
				arrow.htex = TexMan.CheckForTexture("Graphics/HUD/DmgDir2H.png",TexMan.Type_Any);
				arrow.highlightreq = true;
				break;
			case 2:
				arrow.tex = TexMan.CheckForTexture("Graphics/HUD/DmgDir4.png",TexMan.Type_Any);
				break;
			case 3:
				arrow.tex = TexMan.CheckForTexture("Graphics/HUD/DmgDir5.png",TexMan.Type_Any);
				break;

		}
		
		arrow.type = indtype;
		arrow.ResetTimer(plr.player ? cvar.getcvar("D4D_DITimer",plr.player).getint() : -1);
		arrow.Init();
		Arrows.Push(arrow);
	}
	
	void Tick()
	{
		int size = Arrows.Size();
		if (size < 1)	return;
		
		// Tick all the arrows and keep their information up to date.
		for (int i = 0; i < size; i++)
		{
			if (Arrows[i])
				Arrows[i].Tick();
		}
		
		// Memory management. Remove all empty slots.
		if (++Timer >= ClearTimer)
		{
			Timer = 0;
			Array<D4DamageIndicator> temp; temp.Clear();
			
			for (int i = 0; i < size; i++)
				if (Arrows[i])	temp.Push(Arrows[i]);
			
			Arrows.Move(temp);
		}
	}
	
	ui void Render(RenderEvent e)
	{
		if (Arrows.Size() < 1)
			return;
		
		PlayerInfo plr = players[consoleplayer];
		
		bool disabled;
		let CDEnable = Cvar.GetCvar('PBX_CVAR_DD', plr);
		if(CDEnable) disabled = CDEnable.getBool();
		if(disabled) return;
		
		let CDIAlpha = Cvar.GetCvar('D4D_DIAlpha', plr);
		let CDIScale = Cvar.GetCvar('D4D_DIScale', plr);
		let CDIAnim  = Cvar.GetCvar('D4D_DIAnim',plr);
		double Alpha = 1.0, Scale = 0.5;
		int AnimType = 0;
		
		
		if (CDIAlpha)	Alpha 	 = CDIAlpha.GetFloat();
		if (CDIScale)	Scale 	 = CDIScale.GetFloat();
		if (CDIAnim)	AnimType = CDIAnim.GetInt();
		
		int size = Arrows.Size();
		for (int i = 0; i < size; i++)
		{
			let arrow = D4DamageIndicator(Arrows[i]);
			if (arrow && arrow.pinfo == plr)
				Arrows[i].Render(e, Alpha, Scale,AnimType);
		}
	}
	
	//damage type based color handling
	//to add a new color for a type, add a case and return a hex color number 
	color GetArrowColor(name damagetype = 'Normal')
	{
		switch(damagetype)
		{
			case 'ExplosiveImpact':
			case 'Explosive':	return color("F2AE24"); 	break;
			
			case 'Electric':	return color("FFFFFF");		break;
			
			case 'Disintegrate': case 'GreenFire': case 'Slime':
			case 'Acid':		return color("00FF00");		break;
			
			case 'incinerate': case 'Burn':
			case 'Fire':		return color("FF5101");		break;
			
			case 'Freeze':
			case 'Ice':			return color("98F5F9"); 	break;
			
			case 'Plasma':		return color("0675F5");		break;
			
			case 'blackhole':
			case 'Void':		return color("B732DC");		break;
			
			case 'Hitscan':
			case 'Normal':
			default:			return defaultColor;		break;
		}
		return defaultColor;//("FF0000");
	}
}

Class D4DamageIndicator play
{
	Actor inf, src, plr;
	PlayerInfo pinfo;
	Vector3 infpos, srcpos;
	TextureID tex,htex;
	color col;
	int type;
	bool highlightreq;
	private double Alpha, Scale;
	private int Timer,origTimer;
	private bool hadsrc, hadinf;
	private Vector2 siz;
	private Shape2D flat;
	private Shape2DTransform trans;
	
	void Init()
	{
		hadsrc = src != null;
		hadinf = inf != null;
		pinfo = plr.player;
		flat = new("Shape2D");
		
		// simple coords
		flat.PushCoord((0,0));	// 0
		flat.PushCoord((1,0));	// 1
		flat.PushCoord((0,1));	// 2
		flat.PushCoord((1,1));	// 3
		
		// PushTriangle takes INDEXES of coords pushed to it in order from
		// first to last, as numbered above.
		flat.PushTriangle(0,2,1); // (0,0) (0,1) (1,0)
		flat.PushTriangle(2,3,1); // (0,1) (1,1) (1,0)
		
		siz = TexMan.GetScaledSize(tex);
		
		// Create the vertices and push them into the array.
		Vector2 vertices[4];
		vertices[0] = (-siz.x,-siz.y);
		vertices[1] = ( siz.x,-siz.y);
		vertices[2] = (-siz.x, siz.y);
		vertices[3] = ( siz.x, siz.y);
		
		flat.Clear(Shape2D.C_Verts);
		for ( int i=0; i<4; i++ ) flat.PushVertex(vertices[i]);
		
		trans = new('Shape2DTransform');
	}
	
	void ResetTimer(int time = -1)
	{
		if (time < 1)	time = (5 * 5);
		Timer = time;
		origTimer = time;
	}
	
	void Tick()
	{
		if (--Timer < 0 || !plr)
		{
			Destroy();	return;	
		}
		
		if (!src && inf && inf.bMISSILE)
			src = inf.target;
		
		if (src)	srcpos = src.pos;
		if (inf)	infpos = inf.pos;
		
	}
	const ThirtyFifth = (1.0 / 35.0);
	ui void Render( RenderEvent e, double _Alpha, double _Scale,int animType = 0)
	{	
		// Alpha is already clamped below.
		double Alpha = (ThirtyFifth * Timer) * _Alpha;
		double maxalpha = clamp(min(_Alpha,1.0),0.0,1.0);	//use the alpha defined in the option rather than 1.0 always
		double Scale = _Scale;
		if (bDESTROYED || Alpha <= 0.0 || !plr || plr.pos == srcpos || !hadsrc)
			return;
		double pers = 0.75;
		vector2 Scaler = (1.0,1.0);
		
		//animations handling
		//nothing fancy, actually
		double t0 = LinearMap(timer,1,origTimer+1,0.0,1.0);
		switch(AnimType)
		{
			case 0:		//expand but subtle
				scale += Lerp(_Scale*0.3,-0.01,t0);
				break;
				
			case 1:		//shrink fast
				/*double sl = lerp(0.0,_scale * 0.5,(t0 * t0)**6);
				Scale += sl;*/
				Scale += LinearMap(timer,origTimer,0,_scale * 0.3,-_scale*2);
				if(Scale < _Scale)	//go back to its original scale fast
					Scale = _Scale;
				break;
			
			case 2:		//expand fast
				/*double el = lerp(0.0,_scale * 0.5,sqrt(1-(t0**2)));
				Scale += el;*/
				Scale += LinearMap(timer,0,origTimer,_Scale * 1.5,0.0);
				if(Scale > (_Scale * 1.2))
					Scale = _Scale * 1.2;
				break;
			
			case 3:		//shrink subtle
				scale += Lerp(-0.01,_Scale * 0.3,t0);
				break;
				
			case 4:		//blink	
				double alp = linearmap(timer,0,OrigTimer,0,int(20.57*OrigTimer));	//720 deg / 35 tics * duration, so it floats the same way regardless of duration
				double sinA = sin(alp);
				if(alpha >= maxalpha - (maxalpha * 0.1))
					alpha = Lerp(0.05,maxalpha,sinA);
				else
				{
					double curalpha = Alpha;
					alpha = Lerp(0.0,curalpha,sinA);
				}
				break;
				
			case 5:		//funny float
				double t = linearmap(timer,0,OrigTimer,0,int(7.71*OrigTimer));	//270 deg / 35 tics * duration, so it floats the same way regardless of duration
				double ts = sin(t)**2;
				pers += Lerp(-0.05,0.1,ts);
				break;
				
			case 6:	//float and expand and return
				double t2 = linearmap(timer,0,OrigTimer,0,int(7.71*OrigTimer));	//270 deg / 35 tics * duration, so it floats the same way regardless of duration
				double ts2 = sin(t2)**2;
				double gw = Lerp(-0.05,0.1,ts2);
				pers += gw;
				Scale += gw * 0.75;
				break;
			
				
			default:	//none
				break;
		}
		// Grab the player preferences.
		trans.Clear();
		
		// Rotate the damage indicator towards the one responsible.
		Vector3 diff = level.Vec3Diff(srcpos, plr.pos);
		double ang = VectorAngle(diff.X, diff.Y);
		ang = -plr.DeltaAngle(plr.angle, ang);

		Vector2 s = (Screen.GetWidth() / 2, Screen.GetHeight() / 2);
		
		double off = (siz.y + (siz.y * Scale)) * pers;
		Vector2 add = (-sin(ang) * off, cos(ang) * off);
		s += add;
		
		trans.Scale(Scaler * Scale);
		trans.Rotate(ang + 180.0);
		trans.Translate(s);
		
		flat.SetTransform(trans);
		
		// draw the shape 
		Screen.DrawShape(tex,false,flat,DTA_Alpha, Clamp(Alpha, 0.0,maxalpha),DTA_ColorOverlay,col | 0xFF000000); // this requires a color in format AARRGGBB, so mask the Alpha at the beggining or it will be just white
		if(highlightreq) //keep the white part of the graphic white
			Screen.DrawShape(htex,false,flat,DTA_Alpha, Clamp(Alpha, 0.0,maxalpha));
		
	}
	
	clearscope Double LinearMap(Double Val, Double O_Min, Double O_Max, Double N_Min, Double N_Max) 
	{
		Return (Val - O_Min) * (N_Max - N_Min) / (O_Max - O_Min) + N_Min;
	}
	
	clearscope Double Lerp(double v0, double v1, double t) 
	{
	  return (1 - t) * v0 + t * v1;
	}
}

