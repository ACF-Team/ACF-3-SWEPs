AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Rebar Crossbow"

SWEP.IconOffset				= Vector(-8, 0, 0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/c_crossbow.mdl"

SWEP.ShotSound				= Sound("Weapon_Crossbow.Single")
SWEP.WorldModel             = "models/weapons/w_crossbow.mdl"
SWEP.HoldType               = "crossbow"

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 0.5
SWEP.RecoilMod              = 0.5

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Ammo           = "XBowBolt"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 1.25

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.Caliber                = 12.7 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.12 -- kg of projectile
SWEP.ACFType                = "APDS"
SWEP.ACFMuzzleVel           = 400 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0
SWEP.BulletModel			= "models/crossbow_bolt.mdl"
SWEP.BulletScale			= 1

SWEP.IronSightPos           = Vector(-8, -8, 2)

SWEP.Scope					= true
SWEP.Zoom					= 6
SWEP.HasDropCalc			= false
SWEP.Recovery				= 0.5

SWEP.AimFocused				= 0.01
SWEP.AimUnfocused			= 2

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
	else
		timer.Simple(self.Primary.Delay * 0.8, function() self.TempOut = false end)
	end

	self:PostShot(1)
	self:EmitSound("Weapon_Crossbow.BoltFly")
end

function SWEP:Reload()
	local DidReload = self:DefaultReload( ACT_VM_RELOAD ) -- If this is successful, SWEP:Think doesn't run, so we have to handle anything that should happen in there
	if DidReload and not self.Reloading then
		self:SetNWBool("iron", false)
		timer.Simple(self:SequenceDuration() * 0.9, function() self.Reloading = false end)
		self:EmitSound("Weapon_Crossbow.Reload")
		timer.Simple(0.62, function() self:EmitSound("Weapon_Crossbow.BoltElectrify") end)
	end
	self.Reloading = DidReload
end
