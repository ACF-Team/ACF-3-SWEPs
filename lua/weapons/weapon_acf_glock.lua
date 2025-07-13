AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Glock 18"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_pist_glock18.mdl"

SWEP.ShotSound				= Sound(")weapons/glock/glock18-1.wav")
SWEP.WorldModel             = "models/weapons/w_pist_glock18.mdl"
SWEP.HoldType               = "revolver"

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.5
SWEP.Spread                 = 0.6
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 24
SWEP.Primary.DefaultClip    = 24
SWEP.Primary.Ammo           = "Pistol"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.06
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 9 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.00814 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 375 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.CalcDistance			= 25
SWEP.CalcDistance2			= 50

SWEP.IronSightPos           = Vector(-5.78, 0, 2.6)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 4

SWEP:SetupACFBullet()