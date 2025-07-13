AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF AUG"

SWEP.IconOffset				= Vector(6, 6, -2)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_rif_aug.mdl"

SWEP.ShotSound				= Sound(")weapons/aug/aug-1.wav")
SWEP.WorldModel             = "models/weapons/w_rif_aug.mdl"
SWEP.HoldType               = "smg"

SWEP.Slot                   = 0
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.4
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 30
SWEP.Primary.DefaultClip    = 30
SWEP.Primary.Ammo           = "SMG1"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.085
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 5.56 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.004 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 960 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.Scope					= true
SWEP.Zoom					= 2

SWEP.IronSightPos           = Vector(-8.35, -2, 2.1)
SWEP.IronSightAng           = Angle(0, -3, 0)

SWEP.AimFocused				= 0.5
SWEP.AimUnfocused			= 4
SWEP.Recovery				= 3.5

SWEP:SetupACFBullet()