AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Rebar Crossbow"

SWEP.IconOffset				= Vector(-8, 0, 0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/c_crossbow.mdl"

SWEP.ShotSound				= Sound("Weapon_Crossbow.Single")
SWEP.WorldModel             = "models/weapons/w_crossbow.mdl"
SWEP.HoldType               = "crossbow"

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 0.5

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Ammo           = "XBowBolt"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 1.25
SWEP.CarrySpeedMul			= 1.0

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.Caliber                = 12.7 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.12 -- kg of projectile
SWEP.ACFType                = "APDS"
SWEP.ACFMuzzleVel           = 400 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0
SWEP.BulletModel			= "models/crossbow_bolt.mdl"
SWEP.BulletScale			= 1

SWEP.IronSightPos           = Vector(-8, -8, 2)

SWEP.Scope					= true
SWEP.Zoom					= 6
SWEP.HasDropCalc			= false
SWEP.Recovery				= 0.5

SWEP.AimFocused				= 0.01
SWEP.AimUnfocused			= 2

SWEP.ReloadType				= "animation" -- Not "magazine", the bolt sound needs SWEP:Think during the reload
SWEP.ReloadSounds			= {
	{Time = 0, Sound = "Weapon_Crossbow.Reload"},
	{Time = 0.62, Sound = "Weapon_Crossbow.BoltElectrify"},
}

SWEP:SetupACFBullet()

function SWEP:OnShotFired()
	self:EmitPredictedSound("Weapon_Crossbow.BoltFly")
end
