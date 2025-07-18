AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF SG550 Commando"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_snip_sg550.mdl"

SWEP.ShotSound				= Sound(")weapons/sg550/sg550-1.wav")
SWEP.WorldModel             = "models/weapons/w_snip_sg550.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 0
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 1.2

SWEP.Primary.ClipSize       = 30
SWEP.Primary.DefaultClip    = 30
SWEP.Primary.Ammo           = "AR2"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.085
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 5.56 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.004 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 911 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.IronSightPos           = Vector(-7.5, -10, 1.5)

SWEP.Scope					= true
SWEP.Zoom					= 4
SWEP.HasDropCalc			= true

SWEP.AimFocused				= 0.01
SWEP.AimUnfocused			= 4
SWEP.Recovery				= 0.9

SWEP:SetupACFBullet()