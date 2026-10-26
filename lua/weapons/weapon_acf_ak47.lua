AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF AK47"
SWEP.SubCategory            = "Assault Rifles"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_rif_ak47.mdl"

SWEP.ShotSound				= Sound(")weapons/ak47/ak47-1.wav")
SWEP.WorldModel             = "models/weapons/w_rif_ak47.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 2
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 30
SWEP.Primary.DefaultClip    = 30
SWEP.Primary.Ammo           = "SMG1"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.1
SWEP.CarrySpeedMul			= 0.8
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 7.62 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.008 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 715 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.IronSightPos           = Vector(-6.57, -7, 2.25)
SWEP.IronSightAng           = Angle(2.25, 0, 1)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 3

SWEP.FireAnimTime			= 0.01
