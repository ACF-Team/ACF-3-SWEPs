AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF M1919"

SWEP.IconOffset				= Vector(-22, -8, 6)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/30cal/v_30cal.mdl"
SWEP.ViewModelFOV			= 75

SWEP.ShotSound				= Sound("Weapon_30cal.Shoot")
SWEP.WorldModel             = "models/weapons/30cal/w_30cal.mdl"
SWEP.HoldType               = "ar2"

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

SWEP.IdlePos				= Vector(2, 0, -4)
SWEP.IronSightPos           = Vector(-2, -4, 2)

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0, 1, -2)
SWEP.OffsetWorldModelAng	= Angle(0, 0, 180)

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
	self:SetNWBool("iron", false)
	self:SendWeaponAnim(ACT_VM_RELOAD_DEPLOYED)
	local RoundsMissing = math.min(self.Primary.ClipSize - self:Clip1(), self:Ammo1())
	self.Reloading = true
	timer.Simple(self:SequenceDuration(), function()
		if self:GetOwner():GetActiveWeapon() ~= self then self.Reloading = false return end
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SetClip1(math.Clamp(self:Clip1() + self:Ammo1(), 0, self.Primary.ClipSize))
		self:GetOwner():RemoveAmmo(RoundsMissing, self.Primary.Ammo)
		self.Reloading = false
	end)
end