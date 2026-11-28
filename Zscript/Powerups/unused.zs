// --- PowerDoubleFiringSpeed --- (This is bugged)
class PBX_DoubleFiringSpeedGiver : PB_PowerupGiver { Default { Powerup.Type "PBX_PowerDoubleFiringSpeed"; } }
class PBX_PowerDoubleFiringSpeed : PowerDoubleFiringSpeed
{
	mixin PBX_PowerupTimer;
	Default { Powerup.Duration BUDDHA_DEFAULT_DURATION; }

	override void InitEffect()
	{
		Super.InitEffect();
		if(!Owner) return;
		owner.A_AttachLightDef("DoubleFiringSpeedLight","DoubleFiringSpeedLight");
	}

	override void DoEffect()
	{
		Super.DoEffect();
		PowerupTimer("peru");
	}

	override void EndEffect()
	{
		Super.EndEffect();
		if(!Owner) return;
		EndBlend("peru");
		owner.A_RemoveLight("DoubleFiringSpeedLight");
	}
}