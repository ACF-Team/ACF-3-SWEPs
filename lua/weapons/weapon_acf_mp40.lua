AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF MP40"
SWEP.SubCategory            = "Submachine Guns"

SWEP.IconOffset				= Vector(-10, 6, 4)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/mp40/v_mp40.mdl"
SWEP.ViewModelFOV			= 55

SWEP.ShotSound				= Sound("Weapon_Mp40.Shoot")
SWEP.WorldModel             = "models/weapons/mp40/w_mp40.mdl"
SWEP.HoldType               = "smg"

SWEP.Slot                   = 2
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 0.75

SWEP.Primary.ClipSize       = 30
SWEP.Primary.DefaultClip    = 30
SWEP.Primary.Ammo           = "SMG1"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.12
SWEP.CarrySpeedMul			= 0.9
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 9 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.00814 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 400 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IdlePos				= Vector(0, -6, 0)
SWEP.IronSightPos           = Vector(-4.425, -6, 1.8)
SWEP.IronSightAng           = Angle(0.325, -0.1, 0)

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0, 0, 1.5)
SWEP.OffsetWorldModelAng	= Angle(10, 0, 180)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 3
SWEP.Handling				= 1.5

SWEP.FireAnimTime			= 0.5
