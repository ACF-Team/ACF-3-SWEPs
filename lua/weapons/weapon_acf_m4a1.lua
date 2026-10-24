AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF M4A1"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_rif_m4a1.mdl"

SWEP.ShotSound				= Sound(")weapons/m4a1/m4a1_unsil-1.wav")
SWEP.WorldModel             = "models/weapons/w_rif_m4a1.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 2
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 0.8

SWEP.Primary.ClipSize       = 30
SWEP.Primary.DefaultClip    = 30
SWEP.Primary.Ammo           = "SMG1"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.075
SWEP.CarrySpeedMul			= 0.8
SWEP.FiremodeSetting		= 3

SWEP.Caliber                = 5.56 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.004 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 800 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.IronSightPos           = Vector(-7.85, -5, -0.2)
SWEP.IronSightAng           = Angle(2, -1.5, -4)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 5

SWEP.FireAnimTime			= 0.1
