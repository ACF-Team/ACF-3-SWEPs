AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Kar98k (Scoped)"

SWEP.IconOffset				= Vector(-14, 0, 0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/k98/v_k98_scoped.mdl"
SWEP.ViewModelFOV			= 55

SWEP.ShotSound				= Sound("Weapon_KarScoped.Shoot") -- why different sounds for the two?
SWEP.WorldModel             = "models/weapons/k98/w_k98s.mdl"
SWEP.HoldType               = "ar2"

SWEP.Slot                   = 1
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 0.75

SWEP.Primary.ClipSize       = 5
SWEP.Primary.DefaultClip    = 5
SWEP.Primary.Ammo           = "AR2"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 1.5

SWEP.CalcDistance			= 100
SWEP.CalcDistance2			= 300

SWEP.Caliber                = 7.92 -- mm diameter of bullet
SWEP.ACFProjMass            = 0.011 -- kg of projectile
SWEP.ACFType                = "AP"
SWEP.ACFMuzzleVel           = 790 -- m/s of bullet leaving the barrel
SWEP.Tracer                 = 0

SWEP.IdlePos				= Vector(0, -6, 0)
SWEP.IronSightPos           = Vector(-5.2, -10, 2.7)
--SWEP.IronSightAng           = Angle(0.0, 0, 0)

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0, 0, 1.5)
SWEP.OffsetWorldModelAng	= Angle(10, 0, 180)

SWEP.Scope					= true
SWEP.Zoom					= 4
SWEP.Recovery				= 1
SWEP.Handling				= 1

SWEP.AimFocused				= 0.05

SWEP:SetupACFBullet()

function SWEP:Reload() -- Since this weapon actually loads individual rounds but does it all in one animation,   we're gonna cut it to how many we are actually loading
	if self:GetSequenceActivity(self:GetSequence()) == ACT_VM_RELOAD then return end
	if self:Clip1() == self.Primary.ClipSize then return end
	if self:Ammo1() == 0 then return false end
	self:SetNWBool("iron", false)
	self:SendWeaponAnim(ACT_VM_RELOAD)
	local RoundsMissing = math.min(self.Primary.ClipSize - self:Clip1(), self:Ammo1())
	self.Reloading = true
	timer.Simple((((self:SequenceDuration() - 1) / 6) * RoundsMissing) + 0.4, function()
		if self:GetOwner():GetActiveWeapon() ~= self then self.Reloading = false return end
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SetClip1(math.Clamp(self:Clip1() + self:Ammo1(), 0, self.Primary.ClipSize))
		self:GetOwner():RemoveAmmo(RoundsMissing, self.Primary.Ammo)
		self.Reloading = false
	end)
end

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
		self.TempOut = true
		timer.Simple(self.Primary.Delay * 0.8, function() self.TempOut = false end)
	end

	self:PostShot(1)
end
