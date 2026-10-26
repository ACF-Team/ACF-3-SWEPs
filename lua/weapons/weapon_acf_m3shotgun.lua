AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Shotgun"
SWEP.SubCategory            = "Shotguns"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_shot_m3super90.mdl"

SWEP.ShotSound				= Sound(")weapons/m3/m3-1.wav")
SWEP.WorldModel             = "models/weapons/w_shot_m3super90.mdl"
SWEP.HoldType               = "shotgun"

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 2.5
SWEP.RecoilMod              = 2

SWEP.Primary.ClipSize       = 7
SWEP.Primary.DefaultClip    = 7
SWEP.Primary.Ammo           = "Buckshot"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.9
SWEP.CarrySpeedMul			= 0.8

SWEP.CalcDistance			= 25
SWEP.CalcDistance2			= 50

SWEP.Caliber                = 2.5
SWEP.ACFProjMass            = 0.001 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 400 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronSightPos           = Vector(-7.65, -8, 3.48)

-- Overrides the Spread variable used in drawing the crosshair
-- Used pretty much just for shotguns due to spread being calculated differently
SWEP.CrosshairScale			= 0.75

SWEP.Zoom					= 1.2
SWEP.Recovery				= 5

SWEP.ReloadType				= "shell"
SWEP.Pellets				= 24
SWEP.PatternSpread			= 0.75 -- Degrees the whole pattern wanders by (before aim modifiers), Spread is the spread of the pellets in it

function SWEP:GetShotDirections()
	local Aim = self:ResolveAim()
	local Right, Up = Aim:Right(), Aim:Up()
	local Center = self:SpreadDirection(Aim:Forward(), Right, Up, self.PatternSpread * self:GetAimMod())

	local Directions = {}
	for I = 1, self.Pellets do
		Directions[I] = self:SpreadDirection(Center, Right, Up, self.Spread)
	end

	return Directions
end