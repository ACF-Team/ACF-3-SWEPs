AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Lapua"
SWEP.SubCategory            = "Sniper Rifles"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_snip_awp.mdl"

SWEP.ShotSound				= Sound(")weapons/awp/awp1.wav")
SWEP.WorldModel             = "models/weapons/w_snip_awp.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 2

SWEP.Primary.ClipSize       = 5
SWEP.Primary.DefaultClip    = 5
SWEP.Primary.Ammo           = "AR2"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 1.25
SWEP.CarrySpeedMul			= 0.7

SWEP.Caliber                = 8.61 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.0162 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 925 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.IronSightPos           = Vector(-7.4, -6, 2.3)

SWEP.Scope					= true
SWEP.Zoom					= 10
SWEP.HasDropCalc			= true

SWEP.AimFocused				= 0.01
SWEP.AimUnfocused			= 3
SWEP.Recovery				= 0.25

SWEP.ScopeBlinkOnFire		= true
