AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF M249"

SWEP.IconOffset				= Vector(0, 0, -3)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_mach_m249para.mdl"

SWEP.ShotSound				= Sound(")weapons/m249/m249-1.wav")
SWEP.WorldModel             = "models/weapons/w_mach_m249para.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 0.7
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 100
SWEP.Primary.DefaultClip    = 100
SWEP.Primary.Ammo           = "SMG1"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.075
SWEP.CarrySpeedMul			= 0.65
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 5.56
SWEP.ACFProjMass            = 0.004 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 900 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.IronToggle             = true
SWEP.IronSightPos           = Vector(-5.95, -4, 2.3)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 5

SWEP.AimFocused				= 1.2
SWEP.AimUnfocused			= 10

SWEP.TracerEvery			= 4

SWEP:SetupACFBullet()
