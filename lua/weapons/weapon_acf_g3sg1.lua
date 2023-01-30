AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF G3SG1"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.ViewModelFlip          = false

SWEP.ShotSound				= Sound("Weapon_G3SG1.Single")
SWEP.WorldModel             = "models/weapons/w_snip_g3sg1.mdl"
SWEP.HoldType               = "ar2"

SWEP.Weight                 = 1

SWEP.Slot                   = 1
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 1.5

SWEP.Primary.ClipSize       = 20
SWEP.Primary.DefaultClip    = 20
SWEP.Primary.Ammo           = "AR2"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.1
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 7.62 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.011 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 900 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-6.2,-10,1.9)
--SWEP.IronSightAng           = Angle()

SWEP.Scope					= true
SWEP.Zoom					= 6
SWEP.HasDropCalc			= true

SWEP.AimFocused				= 0.01
SWEP.AimUnfocused			= 4
SWEP.Recovery				= 0.9

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
