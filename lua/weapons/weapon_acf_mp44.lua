AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF MP44"

SWEP.IconOffset				= Vector(-10,4,4)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/mp44/v_mp44.mdl"
SWEP.ViewModelFlip          = false
SWEP.ViewModelFOV			= 55

SWEP.ShotSound				= Sound("Weapon_Mp44.Shoot")
SWEP.WorldModel             = "models/weapons/mp44/w_mp44.mdl"
SWEP.HoldType               = "ar2"

SWEP.Weight                 = 1

SWEP.Slot                   = 0
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 0.75

SWEP.Primary.ClipSize       = 30
SWEP.Primary.DefaultClip    = 30
SWEP.Primary.Ammo           = "SMG1"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.1
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 7.92 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.008 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 685 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-3.575,-7,1.64)
SWEP.IronSightAng           = Angle(-0.45,0.35,0)
SWEP.UseHands				= false

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0,0,1.5)
SWEP.OffsetWorldModelAng	= Angle(10,0,180)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 3
SWEP.Handling				= 1.5

SWEP:SetupACFBullet()

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local Ply = self:GetOwner()

	local AimMod = self:GetAimMod()
	local Punch = self:GetPunch()

	if SERVER then
		local Aim = self:ResolveAim()
		local Right = Aim:Right()
		local Up = Aim:Up()

		local Cone = math.tan(math.rad(self.Spread * AimMod))
		local randUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
		local Spread = randUnitSquare:GetNormalized() * Cone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local Dir = (Aim:Forward() + Spread):GetNormalized()

		self:ShootBullet(Ply:GetShootPos(),Dir)

		self:Recoil(Punch)
	end

	self:PostShot(1)
end
