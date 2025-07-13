AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Revolver"

SWEP.IconOffset				= Vector(-6, 24, 2)
SWEP.IconAngOffset			= Angle(4, 0, 0)

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/c_357.mdl"

SWEP.ShotSound				= Sound("Weapon_357.Single")
SWEP.WorldModel             = "models/weapons/w_357.mdl"
SWEP.HoldType               = "revolver"

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 2
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 3

SWEP.Primary.ClipSize       = 6
SWEP.Primary.DefaultClip    = 6
SWEP.Primary.Ammo           = "357"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.2

SWEP.Caliber                = 9.06 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.014 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 450 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronSightPos           = Vector(-4.71, -6, 0.62)
SWEP.IronSightAng           = Angle(0, -0.2, 0)

SWEP.Zoom					= 1.3

SWEP.AimFocused				= 0.1
SWEP.AimUnfocused			= 2
SWEP.Recovery				= 2.5

SWEP:SetupACFBullet()