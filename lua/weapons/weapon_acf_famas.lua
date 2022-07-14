AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Famas"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.ViewModelFlip          = false

SWEP.ShotSound				= Sound("Weapon_FAMAS.Single")
SWEP.WorldModel             = "models/weapons/w_rif_famas.mdl"
SWEP.HoldType               = "ar2"

SWEP.Weight                 = 1

SWEP.Slot                   = 0
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 25
SWEP.Primary.DefaultClip    = 25
SWEP.Primary.Ammo           = "SMG1"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.05454
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 5.56 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.004 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 930 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-6.1,-5,1)
SWEP.IronSightAng           = Angle(-0.25,0.25,-2)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 4

SWEP:SetupACFBullet()

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local Ply = self:GetOwner()

	if Ply:IsPlayer() then Ply:LagCompensation(true) end
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

	timer.Simple(0.01,function() if (Ply:GetActiveWeapon() == self) and self:Clip1() > 0 then self:SendWeaponAnim(ACT_VM_IDLE) end end)

	if Ply:IsPlayer() then Ply:LagCompensation(false) end
end
