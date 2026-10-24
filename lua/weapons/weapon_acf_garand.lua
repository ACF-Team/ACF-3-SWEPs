AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Garand"

SWEP.IconOffset				= Vector(-16, 0, 0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/garand/v_garand.mdl"
SWEP.ViewModelFOV			= 55

SWEP.ShotSound				= Sound("Weapon_Garand.Shoot")
SWEP.WorldModel             = "models/weapons/garand/w_garand.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 2

SWEP.Primary.ClipSize       = 8
SWEP.Primary.DefaultClip    = 8
SWEP.Primary.Ammo           = "357"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.2
SWEP.CarrySpeedMul			= 0.8

SWEP.Caliber                = 7.62 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.01 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 850 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronSightPos           = Vector(-6.95, -2, 5.1)

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0, 0, 1.5)
SWEP.OffsetWorldModelAng	= Angle(10, 0, 180)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 3
SWEP.Handling				= 1.5

local Ping = Sound("Weapon_Garand.ClipDing")

function SWEP:OnShotFired()
	if self:Clip1() == 0 then self:EmitPredictedSound(Ping) end
end
