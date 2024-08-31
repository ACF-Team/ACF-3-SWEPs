AddCSLuaFile()

include("weapon_acf_base.lua")

SWEP.Base                   = "weapon_base"
SWEP.PrintName              = "ACF Shotgun"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.ViewModelFlip          = false

SWEP.ShotSound				= Sound(")weapons/m3/m3-1.wav")
SWEP.WorldModel             = "models/weapons/w_shot_m3super90.mdl"
SWEP.HoldType               = "shotgun"

SWEP.Weight                 = 1

SWEP.Slot                   = 1
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1.1
SWEP.Spread                 = 2.5
SWEP.RecoilMod              = 2

SWEP.Reloading              = false
SWEP.ReloadSpeed            = 1
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

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0
SWEP.IronSightPos           = Vector(-7.65,-8,3.48)
--SWEP.IronSightAng           = Angle()

-- Overrides the Spread variable used in drawing the crosshair
-- Used pretty much just for shotguns due to spread being calculated differently
SWEP.CrosshairScale			= 0.75

SWEP.Zoom					= 1.2
SWEP.Recovery				= 5

SWEP:SetupACFBullet()

function SWEP:CanPrimaryAttack()

	if ( self:Clip1() <= 0 ) then
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		self:Reload()
		return false
	end

	return true
end

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
		timer.Simple(self:SequenceDuration(),function() if self.Reloading then self:SetClip1(self:Clip1() + 1) self:GetOwner():RemoveAmmo(1,self.Primary.Ammo) self:DoReload() end end)

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

function SWEP:Holster()
	if not IsFirstTimePredicted() then return end

	self:SetNWBool("iron",false)
	self.IronScale = 0
	self.IronToggle = false

	self.Reloading = false

	return true
end

function SWEP:PrimaryAttack()
	if self.Reloading and self:Clip1() > 0 then self:FinishReload() return end

	if not self:CanPrimaryAttack() then return end
	local Ply = self:GetOwner()

	local AimMod = self:GetAimMod()
	local Punch = self:GetPunch()

	if SERVER then
		local Aim = self:GetForward()
		local Right = self:GetRight()
		local Up = self:GetUp()
		if Ply:IsNPC() then Aim = Ply:GetAimVector() end

		local Cone = math.tan(math.rad(0.75 * AimMod))
		local randUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
		local Spread = randUnitSquare:GetNormalized() * Cone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local Dir = (Aim + Spread):GetNormalized()

		for _ = 1, 24 do
			local BCone = math.tan(math.rad(self.Spread))
			local BrandUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
			local BSpread = BrandUnitSquare:GetNormalized() * BCone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
			local AimSpread = (Dir + BSpread):GetNormalized()

			self:ShootBullet(Ply:GetShootPos(),AimSpread)
		end

		self:Recoil(Punch)
	end

	self:PostShot(1)
end
