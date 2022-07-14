AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF MP40"

SWEP.IconOffset				= Vector(-10,6,4)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/mp40/v_mp40.mdl"
SWEP.ViewModelFlip          = false
SWEP.ViewModelFOV			= 55

SWEP.ShotSound				= Sound("Weapon_Mp40.Shoot")
SWEP.WorldModel             = "models/weapons/mp40/w_mp40.mdl"
SWEP.HoldType               = "smg"

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
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.12
SWEP.FiremodeSetting		= 2

SWEP.Caliber                = 9 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.00814 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 400 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IdlePos				= Vector(0,-6,0)
SWEP.IronSightPos           = Vector(-4.425,-6,1.8)
SWEP.IronSightAng           = Angle(0.325,-0.1,0)
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

		self:ShootBullet(Ply:GetShootPos(),Dir)
	else
		self:Recoil(Punch)
	end

	self:PostShot(1)

	timer.Simple(0.5,function() if (Ply:GetActiveWeapon() == self) and self:GetSequenceName(self:GetSequence()) ~= "reload" then self:SendWeaponAnim(ACT_VM_IDLE) end end)

	if Ply:IsPlayer() then Ply:LagCompensation(false) end
end
