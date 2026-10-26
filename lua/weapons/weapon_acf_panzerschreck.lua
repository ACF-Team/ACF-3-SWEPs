AddCSLuaFile()

local Adapter = include("acf_sweps/acf_adapter.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Panzerschreck"
SWEP.SubCategory            = "Anti Vehicle"

SWEP.IconOffset				= Vector(-2, -8, 0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/panzerschreck/v_panzerschreck.mdl"
SWEP.ViewModelFOV			= 45

SWEP.ShotSound				= Sound("Weapon_Panzerschreck.Shoot")
SWEP.WorldModel             = "models/weapons/panzerschreck/w_pschreck.mdl"
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

-- The 88mm Raketenpanzerbüchse 54 rocket, these only describe the warhead for the info panel
SWEP.Caliber                = 88 -- mm diameter of bullet

SWEP.ACFType                = "HEAT"
SWEP.ACFMuzzleVel           = 110 -- m/s of bullet leaving the barrel
SWEP.ACFProjLen				= 27.1
SWEP.ACFPropMass			= 0.127116 -- kg of propellant
SWEP.Tracer                 = 0

-- Passed to Missiles.CreateSpec, defined in lua/acf/entities/missiles/acf_sweps_rockets.lua
SWEP.Missile				= "ACF.Missiles.ShoulderFiredRocket.RPzBGr4322"
SWEP.MissileAmmo			= "ACF.Ammunition.HEAT"
SWEP.MissileAmmoData		= {LinerAngleRatio = 0.25} -- The rocket's own lengths are the real round, only the liner is picked here
SWEP.MissileLaunchVel		= 0 -- The motor's boost is the whole muzzle velocity
SWEP.MissileGuidance		= "ACF.Missiles.Guidance.Dumb"
SWEP.MissileFuze			= {Type = "ACF.Missiles.Fuze.Contact"}

SWEP.IronSightPos           = Vector(-7.4, 0, 5.45)
SWEP.IronSightAng           = Angle(0.1, 0.285, 0)
SWEP.PitchAdjust			= 0

SWEP.SprintAng				= Angle(-5, -10, 0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.AimFocused				= 0.0
SWEP.AimUnfocused			= 5

SWEP.CustomAnim				= true
SWEP.AimAnim				= ACT_VM_DEPLOY
SWEP.IdleAnim				= ACT_VM_UNDEPLOY

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
