AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Famas"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_rif_famas.mdl"

SWEP.ShotSound				= Sound(")weapons/famas/famas-1.wav")
SWEP.WorldModel             = "models/weapons/w_rif_famas.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 2
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 25
SWEP.Primary.DefaultClip    = 25
SWEP.Primary.Ammo           = "SMG1"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.05454
SWEP.CarrySpeedMul			= 0.8
SWEP.FiremodeSetting		= 3

SWEP.Caliber                = 5.56 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.004 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 930 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.IronSightPos           = Vector(-6.1, -5, 1)
SWEP.IronSightAng           = Angle(-0.25, 0.25, -2)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 4

SWEP.FireAnimTime			= 0.01
