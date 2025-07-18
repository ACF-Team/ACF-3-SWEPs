AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF M1 Thompson"

SWEP.IconOffset				= Vector(-4, 0, 4)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/thompson/v_thompson.mdl"
SWEP.ViewModelFOV			= 55

SWEP.ShotSound				= Sound("Weapon_Thompson.Shoot")
SWEP.WorldModel             = "models/weapons/thompson/w_thompson.mdl"
SWEP.HoldType               = "ar2"

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
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.085
SWEP.FiremodeSetting		= 2

SWEP.CalcDistance			= 25
SWEP.CalcDistance2			= 50

SWEP.Caliber                = 11.5 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.015 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 285 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IdlePos				= Vector(0, -2, -2)
SWEP.IronSightPos           = Vector(-4.52, -4, 2.04)
SWEP.IronSightAng           = Angle(0, 0, 0)

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0.75, 0.25, 1.5)
SWEP.OffsetWorldModelAng	= Angle(8, 0, 180)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 3
SWEP.Handling				= 2

SWEP:SetupACFBullet()