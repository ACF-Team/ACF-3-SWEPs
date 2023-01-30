AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF SG552"

SWEP.IconOffset				= Vector(5,4,-2)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_rif_sg552.mdl"
SWEP.ViewModelFlip          = false

SWEP.ShotSound				= Sound("Weapon_SG552.Single")
SWEP.WorldModel             = "models/weapons/w_rif_sg552.mdl"
SWEP.HoldType               = "smg"

SWEP.Weight                 = 1

SWEP.Slot                   = 0
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.4
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 30
SWEP.Primary.DefaultClip    = 30
SWEP.Primary.Ammo           = "SMG1"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.085
SWEP.FiremodeSetting		= 2

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.Caliber                = 5.56 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.004 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 911 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.Scope					= true
SWEP.Zoom					= 4

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-7.9,-2,2.5)
SWEP.IronSightAng           = Angle(0,0,0)

SWEP.AimFocused				= 0.4
SWEP.AimUnfocused			= 4
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

		if self:Clip1() % 3 == 1 then self:SetNW2Float("Tracer",self.Tracer) else self:SetNW2Float("Tracer",0) end

		self:ShootBullet(Ply:GetShootPos(),Dir)
	else
		self:Recoil(Punch)
	end

	self:PostShot(1)

	
end
