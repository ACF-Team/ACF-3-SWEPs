-- Everything the SWEPs need from ACF's internals goes through here, so an ACF update only breaks this file
-- Loaded with include, which returns the Adapter table

local Adapter = {}

local function GetAmmoType(Type)
	return ACF.Classes.GetTypeByName("ACF.Ammunition." .. Type)
end

local function BuildKinetic(SWEP, Bullet)
	Bullet.ProjMass = SWEP.ACFProjMass
	Bullet.DragCoef = Bullet.ProjArea * (SWEP.ACFType == "APDS" and 0.000125 or 0.0001) / SWEP.ACFProjMass
	Bullet.Ricochet = 60
	Bullet.LimitVel = 800
	Bullet.ShovePower = 0.2
end

local function BuildHE(SWEP, Bullet)
	local FreeVol = ACF.RoundShellCapacity(0, Bullet.ProjArea, Bullet.Caliber, SWEP.ACFProjLen)

	Bullet.ProjLength = SWEP.ACFProjLen
	Bullet.FillerMass = SWEP.FillerMass
	Bullet.ProjMass = math.max(FreeVol, 0) * ACF.SteelDensity + SWEP.FillerMass
	Bullet.DragCoef = Bullet.ProjArea * 0.0001 / SWEP.ACFProjMass
	Bullet.Ricochet = 60
	Bullet.LimitVel = 100
	Bullet.ShovePower = 0.1
end

-- Runs the round through ACF's own HEAT maths, like the ammo menu does for a crate
local function BuildHEAT(SWEP, Bullet)
	local ProjLength = SWEP.ACFProjLen
	local PropLength = SWEP.ACFPropMass * 1000 / (Bullet.ProjArea * ACF.PDensity)
	local RoundLength = ProjLength + PropLength

	local Ammo = GetAmmoType("HEAT")()
	Ammo.Tracer = false
	Ammo.RoundLength = RoundLength
	Ammo.PropRatio = PropLength / RoundLength
	Ammo.StandoffRatio = SWEP.ACFStandoffRatio
	Ammo.LinerAngleRatio = SWEP.ACFLinerAngleRatio

	Bullet.PropAreaBase = Bullet.ProjArea
	Bullet.Efficiency = 1
	Bullet.MaxCaseScale = 1
	Bullet.Ricochet = 60
	Bullet.LimitVel = 100
	Bullet.ShovePower = 0.1
	Bullet.DetonatorAngle = 75

	Ammo.BulletData = Bullet
	Ammo.GUIData = {
		MinPropLength = 0.01,
		MinProjLength = math.min(Bullet.Caliber * 1.5, ProjLength),
		MaxPropLength = PropLength,
		MaxProjLength = ProjLength,
		MaxRoundLength = RoundLength,
		MinCaseScale = 1,
		MaxCaseScale = 1,
	}

	Ammo:UpdateRoundData()
end

local Builders = {
	AP = BuildKinetic,
	APDS = BuildKinetic,
	HE = BuildHE,
	HEAT = BuildHEAT,
}

-- The bullet table ACF fires, from the weapon's ACF settings
function Adapter.BuildBullet(SWEP)
	local Caliber = SWEP.Caliber * 0.1 -- mm to cm
	local Bullet = {
		Type = SWEP.ACFType,
		AmmoType = "ACF.Ammunition." .. SWEP.ACFType,
		Caliber = Caliber,
		Diameter = Caliber,
		ProjArea = math.pi * (Caliber * 0.5) ^ 2,
		Fuze = SWEP.Fuze,
	}

	Builders[SWEP.ACFType](SWEP, Bullet)

	-- The weapon decides the velocity, HEAT would otherwise get one from its propellant
	Bullet.MuzzleVel = SWEP.ACFMuzzleVel

	return Bullet
end

function Adapter.HasFiller(Bullet)
	return Bullet.Type == "HE" or Bullet.Type == "HEAT"
end

-- ACF's bullet effect reads the round from the crate it came from, the weapon stands in for it
function Adapter.NetworkCrate(Weapon, Bullet)
	Weapon:SetNW2Float("Caliber", Bullet.Caliber)
	Weapon:SetNW2Float("ProjMass", Bullet.ProjMass)
	Weapon:SetNW2Float("DragCoef", Bullet.DragCoef)
	Weapon:SetNW2String("AmmoType", Bullet.AmmoType)

	-- The scale is applied in the ACF_OnCreateBulletEffect hook
	if Weapon.BulletModel then Weapon:SetNW2String("FlightModel", Weapon.BulletModel) end

	Adapter.NetworkFiller(Weapon, Bullet)
	Adapter.NetworkTracer(Weapon, Weapon.Tracer)
end

function Adapter.NetworkFiller(Weapon, Bullet)
	if Adapter.HasFiller(Bullet) then Weapon:SetNW2Float("FillerMass", Bullet.FillerMass) end
end

-- The tracer color is the weapon's color
function Adapter.NetworkTracer(Weapon, Tracer)
	Weapon:SetNW2Float("Tracer", Tracer)
end

-- Server only, ACF and other addons can stop guns from firing
function Adapter.CanFire(Weapon)
	return ACF.GunsCanFire ~= false and hook.Run("ACF_FireShell", Weapon) ~= false
end

function Adapter.GetInaccuracyBias()
	return ACF.GunInaccuracyBias
end

-- Server only
function Adapter.FireProjectile(Weapon, Bullet, Pos, Dir, Filter)
	local Owner = Weapon:GetOwner()

	Bullet.Owner = Owner
	Bullet.Gun = Weapon
	Bullet.Pos = Pos
	Bullet.Filter = Filter
	Bullet.Crate = Weapon:EntIndex()
	Bullet.Flight = Dir * Bullet.MuzzleVel * 39.37 + Owner:GetVelocity()

	GetAmmoType(Bullet.Type):Create(Weapon, Bullet)
end

-- Server only, the missile a launcher fires, from ACF's own missile classes
-- Params are Missiles.CreateSpec's: {Missile, AmmoType, Ammo, Guidance, Fuze}
function Adapter.CreateMissileSpec(Params)
	return ACF.Missiles.CreateSpec(Params)
end

-- What ACF's missiles ask the thing that fired them, see launcher_sv.lua in ACF
local WeaponLauncher = {}
WeaponLauncher.__index = WeaponLauncher

function WeaponLauncher:GetEntity()
	return self.Weapon
end

function WeaponLauncher:GetMissileFilter()
	return self.Filter
end

-- Server only, how wide the missile's seeker looks in degrees
function Adapter.GetSeekCone(Spec)
	return Spec.Class.SeekCone
end

-- The vehicle or contraption the player is in or standing on, so the seeker doesn't lock onto it
local function GetOwnContraption(Owner)
	local Entity = Owner:InVehicle() and Owner:GetVehicle() or Owner:GetGroundEntity()
	if IsValid(Entity) then return Entity:CFW_GetContraption() end
end

local SeekerTrace = {start = true, endpos = true, mask = MASK_SOLID_BRUSHONLY}
local SeekerMinDistance = 38750 -- Squared, ~5 meters, same as ACF's infrared guidance

-- Server only, what an infrared seeker held by Owner sees, like ACF's infrared guidance does
-- Current keeps its lock as long as it stays in view
function Adapter.FindSeekerTarget(Owner, Pos, Dir, Cone, Current)
	local ConeCos = math.cos(math.rad(Cone))
	local Target, BestDot

	for Entity in pairs(ACF.GetEntitiesInCone(Pos, Dir, Cone, GetOwnContraption(Owner))) do
		local EntPos = Entity.ACF_Position
		if not EntPos or Pos:DistToSqr(EntPos) < SeekerMinDistance then continue end

		local Dot = (EntPos - Pos):GetNormalized():Dot(Dir)
		if Dot < ConeCos then continue end

		SeekerTrace.start = Pos
		SeekerTrace.endpos = EntPos
		if ACF.trace(SeekerTrace).Hit then continue end

		if Entity == Current then return Entity end

		if not BestDot or Dot > BestDot then
			Target, BestDot = Entity, Dot
		end
	end

	return Target
end

-- Server only, the target's position as the seeker sees it
function Adapter.GetSeekerTargetPos(Target)
	return Target.ACF_Position or Target:WorldSpaceCenter()
end

-- Server only, Target is what the seeker locked onto before launch, the missile looks for its own without it
function Adapter.FireMissile(Weapon, Spec, Pos, Dir, Filter, Target)
	local Missiles = ACF.Missiles
	local Owner = Weapon:GetOwner()

	local Missile, Err = Missiles.Create(Spec, {
		Owner = Owner,
		Pos = Pos,
		Ang = Dir:Angle(),
		Launcher = setmetatable({Weapon = Weapon, Filter = Filter}, WeaponLauncher),
		Filter = Filter,
	})

	if not Missile then return nil, Err end

	Missiles.Launch(Missile, {
		Velocity = Dir * Weapon.ACFMuzzleVel * 39.37 + Owner:GetVelocity(),
		Direction = Dir,
	})

	if IsValid(Target) then Missile.GuidanceData.Target = Target end

	return Missile
end

-- Players and NPCs get hit instantly at close range instead of by a projectile
function Adapter.IsHybridTarget(Entity)
	return ACF.Check(Entity) and (Entity:IsPlayer() or Entity:IsNPC())
end

-- Server only, deals the damage the projectile would have done to Trace.Entity
function Adapter.HybridHit(Weapon, Bullet, Trace, Pos, Dir)
	local Objects = ACF.Damage.Objects
	local Target = Trace.Entity
	local DmgResult, DmgInfo = Objects.DamageResult(), Objects.DamageInfo()
	local RangedSpeed = ACF.GetRangedSpeed(Bullet.MuzzleVel, Bullet.DragCoef, Pos:Distance(Trace.HitPos) / 39.37) * 0.0254

	DmgResult:SetPenetration(ACF.Penetration(RangedSpeed, Bullet.ProjMass, Bullet.Diameter * 10))
	DmgResult:SetArea(Bullet.ProjArea)
	DmgResult:SetThickness(Target.ACF.Armour)
	DmgResult:SetAngle(ACF.GetHitAngle(Trace, Dir))
	DmgResult:SetFactor(1)

	DmgInfo:SetAttacker(Weapon:GetOwner())
	DmgInfo:SetInflictor(Weapon)
	DmgInfo:SetType(DMG_BULLET)
	DmgInfo:SetOrigin(Pos)
	DmgInfo:SetHitPos(Trace.HitPos)
	DmgInfo:SetHitGroup(Trace.HitGroup)

	local HitRes = ACF.Damage.dealDamage(Target, DmgResult, DmgInfo)

	local Effect = EffectData()
	Effect:SetOrigin(Trace.HitPos)
	Effect:SetNormal(Trace.Normal)

	if Weapon.UseBloodEffect then
		Effect:SetEntity(Weapon)
		util.Effect("BloodImpact", Effect, true, true)
	else
		Effect:SetScale(Bullet.MuzzleVel * 39.3701)
		Effect:SetMagnitude(Bullet.ProjMass)
		Effect:SetRadius(Bullet.Caliber)
		util.Effect("ACF_Penetration", Effect, true, true)
	end

	if HitRes.Kill and IsValid(Target) then
		ACF.APKill(Target, Dir, ACF.Kinetic(RangedSpeed, Bullet.ProjMass).Kinetic, DmgInfo)
	end
end

-- HEAT penetrates the same at any distance, so Distance (meters) is ignored for it
function Adapter.GetPenetration(Bullet, Distance)
	local AmmoType = GetAmmoType(Bullet.Type)

	if Bullet.Type == "HEAT" then
		return AmmoType:GetPenetration(Bullet, Bullet.Standoff)
	end

	return AmmoType:GetRangedPenetration(Bullet, Distance)
end

-- Bullet drop for the scope marks: {{Position, Time, Range}, ...} from the farthest range down
function Adapter.CalcDropTable(Bullet)
	local CheapTime = 1 / 60
	local Flight = Vector(Bullet.MuzzleVel * 39.37, 0, 0)
	local Pos = Vector()
	local Targets = {200, 400, 500, 600, 700, 800}
	local DropTable = {}

	for Step = 1, 2000 do
		if #Targets > 0 and Pos.x / 39.37 >= Targets[1] then
			DropTable[#DropTable + 1] = {Pos, Step * CheapTime, Targets[1]}
			table.remove(Targets, 1)
		end

		local Drag = Flight:GetNormalized() * (Bullet.DragCoef * Flight:LengthSqr()) / ACF.DragDiv
		Pos = Pos + ACF.Scale * CheapTime * Flight
		Flight = Flight + (ACF.Gravity - Drag) * CheapTime

		if math.abs(Pos.x) > 32768 or Pos.z < -32768 then break end
	end

	return table.Reverse(DropTable)
end

return Adapter
