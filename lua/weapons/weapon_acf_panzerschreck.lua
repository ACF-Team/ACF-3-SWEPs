AddCSLuaFile()

include("weapon_acf_base.lua")


SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Panzerschreck"

SWEP.IconOffset				= Vector(-2,-8,0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/panzerschreck/v_panzerschreck.mdl"
SWEP.ViewModelFlip          = false
SWEP.ViewModelFOV			= 45

SWEP.ShotSound				= Sound("Weapon_Panzerschreck.Shoot")
SWEP.WorldModel             = "models/weapons/panzerschreck/w_pschreck.mdl"
SWEP.HoldType               = "rpg"

SWEP.Weight                 = 1

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 0.1

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Ammo           = "RPG_Round"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.2

SWEP.UseHybrid				= false

SWEP.Caliber                = 88 -- mm diameter of bullet
SWEP.ACFProjMass            = 3.1546 -- kg of projectile
SWEP.FillerMass				= 1.2552

-- I hate how inaccessible this is
SWEP.ACFHEATDetAngle		= 75
SWEP.ACFHEATStandoff		= 0.006637
SWEP.ACFHEATLinerMass		= 0.283327
SWEP.ACFHEATPropMass		= 0.127116
SWEP.ACFHEATCartMass		= 3.281269
SWEP.ACFHEATCasingMass		= 1.615655
-- I mean what the actual fuck, why can't I just call a single function to build this fucking data
SWEP.ACFHEATJetMass			= 0.135737
SWEP.ACFHEATJetMinVel		= 4396.25
SWEP.ACFHEATJetMaxVel		= 8886.93
SWEP.ACFHEATBoomFillerMass	= 0.5564587
SWEP.ACFHEATRoundVolume		= 1783.8867
SWEP.ACFHEATBreakupDist		= 0.113564
SWEP.ACFHEATBreakupTime		= 1.2778834602665e-05

SWEP.ACFType                = "HEAT"
SWEP.ACFMuzzleVel           = 110 -- m/s of bullet leaving the barrel
SWEP.ACFProjLen				= 13.1
SWEP.Tracer                 = 0

SWEP.IronScale              = 0
SWEP.NextIronToggle         = 0

SWEP.IronSightPos           = Vector(-7.4,0,5.45)
SWEP.IronSightAng           = Angle(0.1,0.285,0)
SWEP.PitchAdjust			= 0

SWEP.SprintAng				= Angle(-5,-10,0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.UseHands				= false

SWEP.AimFocused				= 0.0
SWEP.AimUnfocused			= 5

SWEP.CustomAnim				= true
SWEP.AimAnim				= ACT_VM_DEPLOY
SWEP.IdleAnim				= ACT_VM_UNDEPLOY

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0,0,1)
SWEP.OffsetWorldModelAng	= Angle(10,0,180)

SWEP.FakeFire				= true	-- This shakes the aim bloom so you can't just quickshot to victory
SWEP.MoveBloom				= 2

SWEP.Zoom					= 1.2
SWEP.Recovery				= 0.5

SWEP:SetupACFBullet()

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if self:GetNWBool("iron",false) == false and self:GetOwner():IsPlayer() then
		self:GetOwner():PrintMessage(4,"You have to aim first!")
		return
	end
	local Ply = self:GetOwner()

	local AimMod = self:GetAimMod()
	local Punch = self:GetPunch()

	if SERVER then
		local Aim = self:ResolveAim()
		local Right = Aim:Right()
		local Up = Aim:Up()

		local Cone = math.tan(math.rad(self.Spread * AimMod))
		local randUnitSquare = (Up * (2 * math.random() - 1) + Right * (2 * math.random() - 1))
		local Spread = randUnitSquare:GetNormalized() * Cone * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local Dir = (Aim:Forward() + Spread):GetNormalized()

		self:ShootBullet(Ply:GetShootPos(),(Dir:Angle() + Angle(self.PitchAdjust,0,0)):Forward())

		self:Recoil(Punch)
	end

	self:PostShot(1)
end
