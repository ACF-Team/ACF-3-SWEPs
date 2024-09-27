AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF M1919"

SWEP.IconOffset				= Vector(-22,-8,6)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/30cal/v_30cal.mdl"
SWEP.ViewModelFlip          = false
SWEP.ViewModelFOV			= 75

SWEP.ShotSound				= Sound("Weapon_30cal.Shoot")
SWEP.WorldModel             = "models/weapons/30cal/w_30cal.mdl"
SWEP.HoldType               = "ar2"

SWEP.Weight                 = 1

SWEP.Slot                   = 0
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 1.1

SWEP.Primary.ClipSize       = 250
SWEP.Primary.DefaultClip    = 250
SWEP.Primary.Ammo           = "AR2"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.1

SWEP.Caliber                = 7.8 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.01 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 815 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IdlePos				= Vector(2,0,-4)
SWEP.IronSightPos           = Vector(-2,-4,2)
--SWEP.IronSightAng           = Angle(0,0,0)
SWEP.UseHands				= false

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0,1,-2)
SWEP.OffsetWorldModelAng	= Angle(0,0,180)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 1
SWEP.Handling				= 1

SWEP.AimFocused				= 1.5
SWEP.AimUnfocused			= 10

SWEP:SetupACFBullet()

function SWEP:Reload()
	if self:GetSequenceActivity(self:GetSequence()) == ACT_VM_RELOAD_DEPLOYED then return end
	if self:Clip1() == self.Primary.ClipSize then return end
	if self:Ammo1() == 0 then return false end
	self:SetNWBool("iron",false)
	self:SendWeaponAnim(ACT_VM_RELOAD_DEPLOYED)
	local RoundsMissing = math.min(self.Primary.ClipSize - self:Clip1(),self:Ammo1())
	self.Reloading = true
	timer.Simple(self:SequenceDuration(),function()
		if self:GetOwner():GetActiveWeapon() ~= self then self.Reloading = false return end
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SetClip1(math.Clamp(self:Clip1() + self:Ammo1(),0,self.Primary.ClipSize))
		self:GetOwner():RemoveAmmo(RoundsMissing,self.Primary.Ammo)
		self.Reloading = false
	end)
end

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
