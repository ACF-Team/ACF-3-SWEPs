AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF XM25"

SWEP.IconOffset				= Vector(12, 0, 2)
SWEP.IconAngOffset			= Angle(0, 180, 0)

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/v_xm25.mdl"

SWEP.ShotSound				= Sound(")acf_base/weapons/grenadelauncher.mp3")
SWEP.WorldModel             = "models/weapons/w_xm25.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 5
SWEP.Primary.DefaultClip    = 5
SWEP.Primary.Ammo           = "SMG1_Grenade"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.3

SWEP.UseHybrid				= false

SWEP.Caliber                = 25 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.5 -- kg of projectile
SWEP.FillerMass				= 0.1
SWEP.ACFType                = "HE"
SWEP.ACFMuzzleVel           = 300 -- m/s of bullet leaving the barrel
SWEP.ACFProjLen				= 3
SWEP.Tracer                 = 1
--SWEP.Fuze					= 0.025

SWEP.IronSightPos           = Vector(-3.48, 0, -0.35)
SWEP.HasDropCalc			= true

SWEP.Scope					= true
SWEP.Zoom					= 4
SWEP.Recovery				= 2.5

SWEP:SetupACFBullet()