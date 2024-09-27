AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Glock 18"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.ViewModelFlip          = false

SWEP.ShotSound				= Sound(")weapons/glock/glock18-1.wav")
SWEP.WorldModel             = "models/weapons/w_pist_glock18.mdl"
SWEP.HoldType               = "revolver"

SWEP.Weight                 = 1

SWEP.Slot                   = 3
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.5
SWEP.Spread                 = 0.6
SWEP.RecoilMod              = 1

SWEP.Primary.ClipSize       = 24
SWEP.Primary.DefaultClip    = 24
SWEP.Primary.Ammo           = "Pistol"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.06
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 9 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.00814 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 375 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.CalcDistance			= 25
SWEP.CalcDistance2			= 50

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-5.78,0,2.6)
--SWEP.IronSightAng           = Angle(0,-0.2,0)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 4

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
