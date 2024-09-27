AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Revolver"

SWEP.IconOffset				= Vector(-6,24,2)
SWEP.IconAngOffset			= Angle(4,0,0)

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/c_357.mdl"
SWEP.ViewModelFlip          = false

SWEP.ShotSound				= Sound("Weapon_357.Single")
SWEP.WorldModel             = "models/weapons/w_357.mdl"
SWEP.HoldType               = "revolver"

SWEP.Weight                 = 1

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 2
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 3

SWEP.Primary.ClipSize       = 6
SWEP.Primary.DefaultClip    = 6
SWEP.Primary.Ammo           = "357"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.2

SWEP.Caliber                = 9.06 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.014 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 450 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-4.71,-6,0.62)
SWEP.IronSightAng           = Angle(0,-0.2,0)

SWEP.Zoom					= 1.3

SWEP.AimFocused				= 0.1
SWEP.AimUnfocused			= 2
SWEP.Recovery				= 2.5

SWEP:SetupACFBullet()

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:Reload()
		self:SetNextPrimaryFire(CurTime() + 0.25)

		self.LastShot = CurTime()
		if SERVER then self:SetNWFloat("lastshot",self.LastShot) end

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

		if self:Clip1() % 3 == 1 then self:SetNW2Float("Tracer",self.Tracer) else self:SetNW2Float("Tracer",0) end

		self:ShootBullet(Ply:GetShootPos(),Dir)

	end

	self:PostShot(1)
end
