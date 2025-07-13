AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF P90"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_smg_p90.mdl"

SWEP.ShotSound				= Sound(")weapons/p90/p90-1.wav")
SWEP.WorldModel             = "models/weapons/w_smg_p90.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 2
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.3
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 0.75

SWEP.Primary.ClipSize       = 50
SWEP.Primary.DefaultClip    = 50
SWEP.Primary.Ammo           = "Pistol"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.06
SWEP.FiremodeSetting		= 2

SWEP.CalcDistance			= 25
SWEP.CalcDistance2			= 50

SWEP.Caliber                = 5.7 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.002 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 715 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronSightPos           = Vector(-5.78, -15, 2.2)
SWEP.IronSightAng           = Angle(0, -0.2, 0)

SWEP.Scope					= true -- Because the P90 doesn't have a proper scope or anything for this model, just hide it
SWEP.ScopeTextureOverride	= 1
SWEP.Zoom					= 1.2
SWEP.Recovery				= 4

SWEP:SetupACFBullet()