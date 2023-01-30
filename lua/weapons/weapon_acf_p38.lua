AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF P38"

SWEP.IconOffset				= Vector(0,0,0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/p38/v_p38.mdl"
SWEP.ViewModelFlip          = false
SWEP.ViewModelFOV			= 55

SWEP.ShotSound				= Sound("Weapon_C96.Shoot") -- wrong one, I know, but the normal sound is shitty
SWEP.WorldModel             = "models/weapons/p38/w_p38.mdl"
SWEP.HoldType               = "pistol"

SWEP.Weight                 = 1

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.5
SWEP.Spread                 = 1
SWEP.RecoilMod              = 1.5

SWEP.Primary.ClipSize       = 8
SWEP.Primary.DefaultClip    = 8
SWEP.Primary.Ammo           = "Pistol"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.13

SWEP.CalcDistance			= 25
SWEP.CalcDistance2			= 50

SWEP.Caliber                = 9 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.00814 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 320 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-5.68,-4,4)
SWEP.IronSightAng           = Angle(0,0,0)

SWEP.SprintAng				= Angle(-5,10,0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0,0,1)
SWEP.OffsetWorldModelAng	= Angle(10,0,180)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 3

SWEP:SetupACFBullet()

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local Ply = self:GetOwner()

	
	local AimMod = self:GetAimMod()
	local Punch = self:GetPunch()

	if SERVER then
		local Aim = self:GetForward()
		local Right = self:GetRight()
		local Up = self:GetUp()
		if Ply:IsNPC() then Aim = Ply:GetAimVector() end

		local Cone = math.tan(math.rad(self.Spread * AimMod))
		local randUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
		local Spread = randUnitSquare:GetNormalized() * Cone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local Dir = (Aim + Spread):GetNormalized()

		self:ShootBullet(Ply:GetShootPos(),Dir)
	else
		self:Recoil(Punch)
	end

	self:PostShot(1)

	
end
