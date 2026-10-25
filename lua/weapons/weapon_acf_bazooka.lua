AddCSLuaFile()

local Adapter = include("acf_sweps/acf_adapter.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Bazooka"

SWEP.IconOffset				= Vector(4, -4, 0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/bazooka/v_bazooka.mdl"
SWEP.ViewModelFOV			= 45

SWEP.ShotSound				= Sound("Weapon_Bazooka.Shoot")
SWEP.WorldModel             = "models/weapons/bazooka/w_bazooka.mdl"
SWEP.HoldType               = "rpg"

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 0.1

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Ammo           = "RPG_Round"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.2
SWEP.CarrySpeedMul			= 0.6
SWEP.UseHybrid				= false

-- The 60mm M6 rocket of the M9A1 Bazooka, these only describe the warhead for the info panel
SWEP.Caliber                = 60 -- mm diameter of bullet
SWEP.ACFType                = "HEAT"
SWEP.ACFMuzzleVel           = 82 -- m/s of bullet leaving the barrel
SWEP.ACFProjLen				= 18.5
SWEP.ACFPropMass			= 0.040291 -- kg of propellant
SWEP.Tracer                 = 0

-- Passed to Missiles.CreateSpec, defined in lua/acf/entities/missiles/acf_sweps_rockets.lua
SWEP.Missile				= "ACF.Missiles.ShoulderFiredRocket.M6A3"
SWEP.MissileAmmo			= "ACF.Ammunition.HEAT"
SWEP.MissileAmmoData		= {LinerAngleRatio = 0.25} -- The rocket's own lengths are the real round, only the liner is picked here
SWEP.MissileLaunchVel		= 0 -- The motor burns out in the tube, its boost is the whole muzzle velocity
SWEP.MissileGuidance		= "ACF.Missiles.Guidance.Dumb"
SWEP.MissileFuze			= {Type = "ACF.Missiles.Fuze.Contact"}

SWEP.AimTable = {}
SWEP.AimTable[1] = {IronPos = Vector(-3.83, -8, -0.4), IronAng = Angle(2.9, -0.5, 0),  PitchAdjust = -1.55, Text = "100yd"} -- 100yd
SWEP.AimTable[2] = {IronPos = Vector(-3.79, -8, -1.9), IronAng = Angle(6.9, -0.4, 0),  PitchAdjust = -4.2, Text = "200yd"} -- 200yd
SWEP.AimTable[3] = {IronPos = Vector(-3.77, -8, -3.64), IronAng = Angle(11.6, -0.35, 0),  PitchAdjust = -6.6, Text = "300yd"} -- 300yd

SWEP.SprintAng				= Angle(-5, -10, 0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.AimFocused				= 0.75
SWEP.AimUnfocused			= 5

SWEP.CustomAnim				= true
SWEP.AimAnim				= ACT_VM_DEPLOY
SWEP.IdleAnim				= ACT_VM_UNDEPLOY

SWEP.SprintAng				= Angle(-10, -10, 0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0, 0, 1)
SWEP.OffsetWorldModelAng	= Angle(10, 0, 180)

SWEP.FakeFire				= true	-- This shakes the aim bloom so you can't just quickshot to victory
SWEP.MoveBloom				= 2

SWEP.Zoom					= 1.2
SWEP.Recovery				= 0.5

SWEP.RequiresAim			= true

-- Server only, built once since every shot is the same missile
function SWEP:GetMissileSpec()
	local Spec = self.MissileSpec

	if not Spec then
		local Err

		Spec, Err = Adapter.CreateMissileSpec({
			Missile = self.Missile,
			AmmoType = self.MissileAmmo,
			Ammo = self.MissileAmmoData,
			Guidance = {Type = self.MissileGuidance},
			Fuze = self.MissileFuze,
		})

		if not Spec then ErrorNoHalt(self:GetClass() .. ": " .. Err .. "\n") return end

		self.MissileSpec = Spec
	end

	return Spec
end

function SWEP:FireShots()
	local Spec = self:GetMissileSpec()
	if not Spec then return end

	local Owner = self:GetOwner()
	local Missile, Err = Adapter.FireMissile(self, Spec, Owner:GetShootPos(), self:GetShotDirections()[1], {Owner, self})

	if not Missile and Err then ErrorNoHalt(self:GetClass() .. ": " .. Err .. "\n") end
end
