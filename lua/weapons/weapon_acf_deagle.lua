AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Desert Eagle"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_pist_deagle.mdl"

SWEP.ShotSound				= Sound(")weapons/DEagle/deagle-1.wav")
SWEP.WorldModel             = "models/weapons/w_pist_deagle.mdl"
SWEP.HoldType               = "pistol"

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.5
SWEP.Spread                 = 1
SWEP.RecoilMod              = 3

SWEP.Primary.ClipSize       = 7
SWEP.Primary.DefaultClip    = 7
SWEP.Primary.Ammo           = "Pistol"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.23

SWEP.CalcDistance			= 25
SWEP.CalcDistance2			= 50

SWEP.Caliber                = 12.7 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.019 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 470 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronSightPos           = Vector(-6.375, 0, 2.1)
--SWEP.IronSightAng           = Angle(0, -0.2, 0)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 3

SWEP:SetupACFBullet()

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:Reload()
		self:SetNextPrimaryFire(CurTime() + 0.25)

		self.LastShot = CurTime()
		if SERVER then self:SetNWFloat("lastshot", self.LastShot) end

		return false
	end

	local Punch = self:GetPunch()
	self:Recoil(Punch)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not self:CanPrimaryAttack() then return end

	local Ply = self:GetOwner()
	local AimMod = self:GetAimMod()

	if SERVER then
		local Aim = self:ResolveAim()
		local Right = Aim:Right()
		local Up = Aim:Up()

		local Cone = math.tan(math.rad(self.Spread * AimMod))
		local randUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
		local Spread = randUnitSquare:GetNormalized() * Cone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local Dir = (Aim:Forward() + Spread):GetNormalized()

		self:ShootBullet(Ply:GetShootPos(), Dir)

	end

	self:PostShot(1)
end
