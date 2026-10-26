AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Anti-Material Rifle"
SWEP.SubCategory            = "Sniper Rifles"

SWEP.IconOffset				= Vector(4, 4, 0)
SWEP.IconAngOffset			= Angle(0, 180, 0)

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/v_sniper.mdl"

SWEP.ShotSound				= Sound(")acf_base/weapons/sniper_fire.mp3")
SWEP.WorldModel             = "models/weapons/w_sniper.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.5
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 2

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Ammo           = "XBowBolt"
SWEP.Primary.Automatic      = false
SWEP.CarrySpeedMul			= 0.6
SWEP.Primary.Delay          = 1.25

SWEP.UseHybrid				= false

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.Caliber                = 14.5 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.1 -- kg of projectile
SWEP.ACFType                = "APDS"
SWEP.ACFMuzzleVel           = 700 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.IronSightPos           = Vector(-5.775, -4, 0.92)

SWEP.Scope					= true
SWEP.Zoom					= 8
SWEP.HasDropCalc			= true
SWEP.Recovery				= 0.2

SWEP.AimFocused				= 0.1
SWEP.AimUnfocused			= 3

SWEP.ReloadSounds			= {{Time = 0, Sound = "acf_base/weapons/sniper_reload.mp3"}}
