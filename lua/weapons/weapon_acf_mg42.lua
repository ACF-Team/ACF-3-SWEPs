AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF MG42"

SWEP.IconOffset				= Vector(-16, -4, 6)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/mg42/v_mg42.mdl"
SWEP.ViewModelFOV			= 55

SWEP.ShotSound				= Sound("Weapon_Mg42.Shoot")
SWEP.WorldModel             = "models/weapons/mg42/w_mg42bd.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 0
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.7
SWEP.RecoilMod              = 1.1

SWEP.Primary.ClipSize       = 250
SWEP.Primary.DefaultClip    = 250
SWEP.Primary.Ammo           = "AR2"
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.05

SWEP.Caliber                = 7.92 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.011 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 740 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 1

SWEP.IdlePos				= Vector(2, 0, -4)
SWEP.IronSightPos           = Vector(0, 0, -2)

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0, 0, 1.5)
SWEP.OffsetWorldModelAng	= Angle(10, 0, 180)

SWEP.Zoom					= 1.2
SWEP.Recovery				= 1
SWEP.Handling				= 1

SWEP.AimFocused				= 1.2
SWEP.AimUnfocused			= 10

SWEP:SetupACFBullet()

function SWEP:Reload()
	if self:GetSequenceActivity(self:GetSequence()) == ACT_VM_RELOAD then return end
	if self:Clip1() == self.Primary.ClipSize then return end
	if self:Ammo1() == 0 then return false end
	self:SetNWBool("iron", false)
	self:SendWeaponAnim(ACT_VM_RELOAD)
	local RoundsMissing = math.min(self.Primary.ClipSize - self:Clip1(), self:Ammo1())
	self.Reloading = true
	timer.Simple(self:SequenceDuration(), function()
		if not IsValid(self) then return end

		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		if owner:GetActiveWeapon() ~= self then self.Reloading = false return end
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SetClip1(math.Clamp(self:Clip1() + self:Ammo1(), 0, self.Primary.ClipSize))
		owner:RemoveAmmo(RoundsMissing, self.Primary.Ammo)
		self.Reloading = false
	end)
end