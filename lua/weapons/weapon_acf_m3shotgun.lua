AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Shotgun"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_shot_m3super90.mdl"

SWEP.ShotSound				= Sound(")weapons/m3/m3-1.wav")
SWEP.WorldModel             = "models/weapons/w_shot_m3super90.mdl"
SWEP.HoldType               = "shotgun"

SWEP.Slot                   = 1
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 2.5
SWEP.RecoilMod              = 2

SWEP.NextShell              = 0

SWEP.Primary.ClipSize       = 7
SWEP.Primary.DefaultClip    = 7
SWEP.Primary.Ammo           = "Buckshot"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.9

SWEP.CalcDistance			= 25
SWEP.CalcDistance2			= 50

SWEP.Caliber                = 2.5
SWEP.ACFProjMass            = 0.001 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 400 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IronSightPos           = Vector(-7.65, -8, 3.48)

-- Overrides the Spread variable used in drawing the crosshair
-- Used pretty much just for shotguns due to spread being calculated differently
SWEP.CrosshairScale			= 0.75

SWEP.Zoom					= 1.2
SWEP.Recovery				= 5

SWEP:SetupACFBullet()

function SWEP:FinishReload()
	self:SendWeaponAnim(ACT_VM_IDLE)
	self.Reloading = false
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
end

function SWEP:DoReload()
	if (self:Clip1() < self:GetMaxClip1()) and (self:Ammo1() > 0) and self.Reloading == true then
		if CurTime() < self.NextShell then return end
		self:SendWeaponAnim(ACT_VM_RELOAD)

		self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
		timer.Simple(self:SequenceDuration(), function() if self.Reloading then self:SetClip1(self:Clip1() + 1) self:GetOwner():RemoveAmmo(1, self.Primary.Ammo) self:DoReload() end end)

		self.NextShell = (CurTime() + self:SequenceDuration())
	else
		self:FinishReload()
	end
end

function SWEP:Reload()
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	self.Reloading = true
	self:DoReload()
end

function SWEP:PrimaryAttack()
	if self.Reloading and self:Clip1() > 0 then self:FinishReload() return end

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

		local Cone = math.tan(math.rad(0.75 * AimMod))
		local randUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
		local Spread = randUnitSquare:GetNormalized() * Cone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local Dir = (Aim:Forward() + Spread):GetNormalized()

		for _ = 1, 24 do
			local BCone = math.tan(math.rad(self.Spread))
			local BrandUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
			local BSpread = BrandUnitSquare:GetNormalized() * BCone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
			local AimSpread = (Dir + BSpread):GetNormalized()

			self:ShootBullet(Ply:GetShootPos(), AimSpread)
		end

	end

	self:PostShot(1)
end
