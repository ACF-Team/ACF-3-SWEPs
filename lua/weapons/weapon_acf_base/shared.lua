-- Settings and state of the ACF-3 SWEP base, the rest of it is split by concern:
-- sh_fire.lua: firing, spread and recoil
-- sh_reload.lua: the reload types
-- cl_view.lua: viewmodel, world model, zoom and view kick
-- cl_hud.lua: crosshair, scope and ammo counter
-- cl_selection.lua: weapon selection box and info text

AddCSLuaFile()
AddCSLuaFile("acf_sweps/acf_adapter.lua")
AddCSLuaFile("sh_fire.lua")
AddCSLuaFile("sh_reload.lua")
AddCSLuaFile("cl_view.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_selection.lua")

local Adapter = include("acf_sweps/acf_adapter.lua")

-- TODO: Prone Mod support
-- TODO: Bipods!

SWEP.Author                 = "LiddulBOFH"
SWEP.Base                   = "weapon_base" -- Loads in functions from this weapon base, don't change!
SWEP.PrintName              = "ACF-3 SWEP Base"
SWEP.Instructions           = "Left click: Shoot\nRight click: Aim down sights" -- This isn't seen as I make my own info panel for all of this
SWEP.Purpose                = "Kills stuff dead"
SWEP.Category               = "ACF-3 SWEPs"
SWEP.ScriptedEntityType     = "acf_swep" -- Our own spawnmenu icon, see acf3sweps_bootstrap.lua
SWEP.BounceWeaponIcon		= false

-- For the nicely rendered model of the weapon in the selector panel
-- Most models will render fine, but you may need to adjust some
SWEP.IconOffset				= Vector()
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = true -- the builtin garry's mod hands, some models have their own hands or are really jank so we may need to turn these off
SWEP.ViewModelFlip          = false -- Flips the viewmodel, apparently its an issue with some models? Haven't run into those yet

SWEP.ShotSound              = ""
SWEP.ViewModel              = "" -- The model seen in the players hands
SWEP.WorldModel             = "" -- The model seen in the world (and also the players hands, just not yours)
-- https://wiki.facepunch.com/gmod/Hold_Types
SWEP.HoldType               = "ar2" -- How another player is seen holding the weapon

SWEP.AutoSwitch             = false
SWEP.AutoSwitchFrom         = false
SWEP.Weight                 = 1 -- not the weight you think it is, this is just for auto-switch when you pickup a weapon, so we'll just ignore this

-- This gets changed based on the weapon class
SWEP.Slot                   = 1
SWEP.SlotPos                = 0

SWEP.Spawnable              = false
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1 -- How fast the weapon's deploy animation plays, and thus the weapon is ready (higher = faster)
SWEP.Spread                 = 1 -- The weapon's actual spread, before being modified by other means like movement and such
SWEP.RecoilMod              = 1 -- A multiplier to the 'bump' a player gets when shooting, only affects clientside
SWEP.PunchAmount            = 1.5 -- Degrees of temporary view punch per shot (before RecoilMod), this springs back to the original aim point
SWEP.KickUp                 = 1 -- Degrees the aim point permanently climbs per shot (before RecoilMod), applied smoothly
SWEP.KickHorizontal         = 0.5 -- Max degrees the view drifts left/right per shot (before RecoilMod)
SWEP.KickSpeed              = 15 -- How fast the pending view kick is applied (higher = snappier)
SWEP.KickBack               = 1.5 -- Units the viewmodel is pushed back per shot (before RecoilMod)
SWEP.KickBackSpeed          = 12 -- How fast the viewmodel returns after a shot
SWEP.CarrySpeedMul          = 1.0 -- Multiplier for player's walk/run speed when carrying this weapon

SWEP.Primary.ClipSize       = 30 -- The size of the magazine in the weapon
SWEP.Primary.DefaultClip    = 30 -- This is what will initially start in the magazine when the weapon is first spawned
SWEP.Primary.Ammo           = "AR2" -- the actual ammo you load (has 0 impact on damage)

-- The firerate of the weapon, can figure this out by 60 / RPM
SWEP.Primary.Delay          = 0.1

SWEP.Primary.Automatic      = true -- Whether or not the weapon can refire by itself

-- 1 is just normal firing (user can't change)
-- 2 is full auto and semi auto
-- 3 is full auto, semi auto and burst
-- If it needs to be just semi auto, just set Automatic to false above
SWEP.FiremodeSetting		= 1

-- 1 is normal full auto
-- 2 is semi-auto
-- 3 is burst fire
SWEP.CurrentFiremode		= 1
SWEP.BurstSize				= 3 -- Rounds fired per trigger pull in burst fire

SWEP.Scope                  = false -- If true, it will hide the viewmodel when aimed and draw a scope overlay
-- Set this to the index of the scope submaterial and it will override
SWEP.HasDropCalc			= false -- If true, will also run a ballistics calculation and draw ticks on the scope
-- Distance in meters to check penetration at (HE/HEAT is distance-less)
-- This is for the info panel as well
SWEP.CalcDistance			= 50
SWEP.CalcDistance2			= 100

-- We aren't using this, so we're disabling any secondary ammo
-- We are actually using the secondary fire for aiming down sights, as well as firemode changing if available
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Automatic    = false

SWEP.Caliber                = 5.56 -- mm size bullet
SWEP.ACFType                = "AP" -- Type of projectile: AP, APDS, HE or HEAT
SWEP.ACFMuzzleVel           = 800 -- Speed of the projectile leaving the barrel
SWEP.ACFProjMass            = 0.004 -- kg of projectile (HEAT works this out itself)
SWEP.Tracer                 = 0 -- Supposed to be length in the final projectile dedicated to tracer filler, but seems to not affect anything except for showing tracers
-- HE: SWEP.ACFProjLen (cm) and SWEP.FillerMass (kg)
-- HEAT: SWEP.ACFProjLen (cm) and SWEP.ACFPropMass (kg), ACF works out the warhead from these and the two ratios below
SWEP.ACFStandoffRatio		= 0.2 -- Same as the ammo menu sliders
SWEP.ACFLinerAngleRatio		= 0.2

SWEP.IronSightPos           = Vector(0, 0, 0) -- Shifts the viewmodel by this much to put the view inline with the iron sights
--SWEP.IronSightAng           = Angle() -- Turns the viewmodel by this much to help line the above too
SWEP.SprintAng				= Angle(-15, 40, 0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.AimFireAnim			= false -- Set true to play the fire animation even while aiming down sights
SWEP.IronTime				= 0.25 -- Seconds to fully raise or lower the sights, the viewmodel gets there a bit sooner and the zoom takes the final stretch
SWEP.AimFocused				= 0.5 -- Multiplier to the weapon spread while aimed down sights
SWEP.AimUnfocused			= 3 -- Same, but when not aimed

-- This is used for the 3D model when it doesn't get attached to the player's hands correctly
-- This only works if the playermodel actually has bones rigged correctly!
SWEP.CustomWorldModelPos	= false -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector()
SWEP.OffsetWorldModelAng	= Angle()
SWEP.CustomAnim				= false

-- This is used to bump the weapon steadiness when changing between aiming and not, so no quickscopes
SWEP.FakeFire				= false
-- Multiplies the movement bloom for heavier weapons
SWEP.MoveBloom				= 1
-- How fast bloom recovers from the last shot fired (higher = faster)
SWEP.Recovery				= 1
-- Further modifies the final bloom from the last shot fired (higher = better)
SWEP.Handling				= 1
-- Attempt a hybrid trace, one that will attempt to ease some pain with the SWEPs
SWEP.UseHybrid				= true
SWEP.UseBloodEffect			= false --Hybrid trace hits will cause blood effects instead of ACF Penetration effect.

-- Firing
SWEP.TracerEvery			= 3 -- If Tracer is set, every this many rounds in the magazine is a tracer
SWEP.RequiresAim			= false -- Can only fire while aimed down sights (launchers)
SWEP.ScopeBlinkOnFire		= false -- Drops the scope overlay for most of the refire delay (bolt actions)
SWEP.FireAnimTime			= nil -- If set, cuts the fire animation back to idle after this many seconds
SWEP.AimHoldType			= nil -- If set, the holdtype used while aimed down sights
-- SWEP.AimTable = {{IronPos = Vector(), IronAng = Angle(), PitchAdjust = 0, Text = "100m"}, ...}
-- Sight settings cycled with use + secondary fire, PitchAdjust is added to the shot. Without it SWEP.PitchAdjust is used

-- Reloading
-- "magazine": the reload animation, the engine moves the ammo
-- "rounds": one animation for the whole clip, cut short for the rounds actually loaded, finishing ReloadFinishOffset later
-- "animation": plays ReloadAct and loads everything at the end of it
-- "shell": loads one shell per animation until full, firing stops it
SWEP.ReloadType				= "magazine"
SWEP.ReloadAct				= ACT_VM_RELOAD
SWEP.ReloadFinishOffset		= 0
-- {{Time = seconds, Sound = name}, ...} played from the start of a reload
-- SWEP:Think is paused during "magazine" reloads, so those can only use Time = 0
SWEP.ReloadSounds			= nil

-- Internal values, don't change!
SWEP.DropCalc				= {}
SWEP.CalcRun				= false
SWEP.IronScale              = 0
SWEP.SprintScale			= 0
SWEP.DisableDuplicator		= true -- why oh why do I even have to do this
SWEP.RateTime				= 0

SWEP.IconOverride			= "materials/vgui/entities/acf_logo.png"
local FiremodeSound = Sound("Weapon_SMG1.Special2")

-- Weapon state lives in network vars so the owner's client predicts it along with the server
-- Times are CurTime() values, 0 means not set
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Iron") -- Aimed down sights
	self:NetworkVar("Bool", 1, "Reloading") -- Also keeps the sights down
	self:NetworkVar("Bool", 2, "ReloadStopQueued") -- The trigger was pulled during a shell reload

	self:NetworkVar("Int", 0, "FireMode") -- 1 automatic, 2 semi-automatic, 3 burst
	self:NetworkVar("Int", 1, "BurstShots") -- Shots fired since the trigger was pulled
	self:NetworkVar("Int", 2, "AimSetting") -- Index into SWEP.AimTable
	self:NetworkVar("Int", 3, "ReloadRounds") -- Rounds being loaded by a manual reload
	self:NetworkVar("Int", 4, "ReloadSoundIndex") -- Next entry of SWEP.ReloadSounds to play

	self:NetworkVar("Float", 0, "LastShot") -- Drives the bloom from firing
	self:NetworkVar("Float", 1, "ReloadStart")
	self:NetworkVar("Float", 2, "ReloadEnd")
	self:NetworkVar("Float", 3, "ScopeBlinkEnd")
	self:NetworkVar("Float", 4, "FireAnimEnd")
end

-- The ACF round this weapon fires, built the first time it's needed
function SWEP:GetBullet()
	local Bullet = self.Bullet

	if not Bullet then
		Bullet = Adapter.BuildBullet(self)
		self.Bullet = Bullet
	end

	return Bullet
end

-- Sounds from predicted code, only played the first time the client predicts them
function SWEP:EmitPredictedSound(Sound)
	if CLIENT and not IsFirstTimePredicted() then return end

	self:EmitSound(Sound)
end

function SWEP:Initialize()
	self.FiremodeSetting = math.Clamp(math.floor(self.FiremodeSetting), 1, 3)
	self:SetFireMode(math.Clamp(math.floor(self.CurrentFiremode), 1, self.FiremodeSetting))
	self:SetAimSetting(1)
	self:SyncAutomatic()

	self:SetHoldType(self.HoldType)

	Adapter.NetworkCrate(self, self:GetBullet())
end

-- Whether the owner is holding the sights up, SWEP:Think stores this in the Iron network var
function SWEP:IsAiming()
	local Owner = self:GetOwner()
	if not Owner:IsPlayer() then return false end

	return Owner:IsOnGround() and not Owner:IsSprinting() and Owner:KeyDown(IN_ATTACK2) and not Owner:KeyDown(IN_USE)
end

-- Primary.Automatic is read by the engine, so it follows the fire mode on both realms
-- Burst fire needs the weapon to keep firing while the trigger is held, CanPrimaryAttack cuts it off after the burst
function SWEP:SyncAutomatic()
	if self.FiremodeSetting == 1 then return end

	self.Primary.Automatic = self:GetFireMode() ~= 2
end

function SWEP:GetAimSettingData()
	local AimTable = self.AimTable
	if not AimTable then return end

	return AimTable[self:GetAimSetting()]
end

function SWEP:GetPitchAdjust()
	local AimSetting = self:GetAimSettingData()
	if AimSetting then return AimSetting.PitchAdjust or 0 end

	return self.PitchAdjust or 0
end

function SWEP:IsScopeBlinking()
	return CurTime() < self:GetScopeBlinkEnd()
end

-- Use + secondary fire cycles the sight settings if the weapon has them, the fire mode otherwise
function SWEP:SecondaryAttack()
	if not self:GetOwner():KeyDown(IN_USE) then return end

	if self.AimTable then
		self:CycleAimSetting()
	elseif self.FiremodeSetting ~= 1 then
		self:CycleFiremode()
	else
		return
	end

	self:EmitPredictedSound(FiremodeSound)
	self:SetNextSecondaryFire(CurTime() + 0.25)
end

function SWEP:CycleFiremode()
	self:SetFireMode(self:GetFireMode() % self.FiremodeSetting + 1)
	self:SyncAutomatic()
end

function SWEP:CycleAimSetting()
	local Setting = self:GetAimSetting() % #self.AimTable + 1

	self:SetAimSetting(Setting)
	if SERVER then self:GetOwner():PrintMessage(HUD_PRINTCENTER, "Range: " .. self.AimTable[Setting].Text) end
end

function SWEP:Deploy()

	if CLIENT then
		self.FOV = self:GetOwner():GetFOV()
	else
		local owner = self:GetOwner()

		-- The bullet effect takes the tracer color from the gun, see SWEP:DrawWorldModel
		if self.Tracer > 0 then
			local Col = Color(255, 255, 255)
			if owner:IsPlayer() then Col = team.GetColor(owner:Team()) end
			self:SetColor(Col)
		end

		if owner:IsPlayer() then
			if not self.OriginalWalkSpeed then
				self.OriginalWalkSpeed = owner:GetWalkSpeed()
				self.OriginalRunSpeed = owner:GetRunSpeed()
			end

			self.NormalPlayerWalkSpeed = self.OriginalWalkSpeed
			self.NormalPlayerRunSpeed = self.OriginalRunSpeed

			if  GetConVar("acf_sweps_speed_mult", 1):GetBool() then
				owner:SetWalkSpeed( self.NormalPlayerWalkSpeed * self.CarrySpeedMul)
				owner:SetRunSpeed( self.NormalPlayerRunSpeed * self.CarrySpeedMul)
			else
				owner:SetWalkSpeed( self.NormalPlayerWalkSpeed )
				owner:SetRunSpeed( self.NormalPlayerRunSpeed )
			end
		end
	end

	if self.HasDropCalc then self.DropCalc = self:CalcDropTable() end

	self:SyncAutomatic()
	self:SetLastShot(CurTime())

	self:SendWeaponAnim(ACT_VM_DRAW) -- another missing anim

	Adapter.NetworkFiller(self, self:GetBullet())

	return true
end

function SWEP:OnRemove()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsPlayer() then
		owner:SetWalkSpeed(self.OriginalWalkSpeed or self.NormalPlayerWalkSpeed or owner:GetWalkSpeed())
		owner:SetRunSpeed(self.OriginalRunSpeed or self.NormalPlayerRunSpeed or owner:GetRunSpeed())
	end
end

-- Has to return true on every call, returning nothing refuses the weapon switch
function SWEP:Holster()
	self:CancelReload()
	self:SetReloading((self:Clip1() <= 0) and (self:Ammo1() > 0))
	self:SetFireAnimEnd(0)
	self:SetScopeBlinkEnd(0)
	self:SetIron(false)
	self.IronScale = 0

	if SERVER then
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then
			owner:SetWalkSpeed(self.OriginalWalkSpeed or self.NormalPlayerWalkSpeed)
			owner:SetRunSpeed(self.OriginalRunSpeed or self.NormalPlayerRunSpeed)
		end
	end

	return true
end

function SWEP:GetNPCBulletSpread()
	return (self.Spread * 2) + self.AimUnfocused
end

function SWEP:GetNPCBurstSettings()
	return math.ceil(self.Primary.ClipSize * 0.05), math.ceil(self.Primary.ClipSize * 0.5), self.Primary.Delay
end

function SWEP:GetNPCRestTimes()
	return self.Primary.Delay, self.Primary.Delay * 5
end

-- Raises or lowers the sights, on both realms so the client predicts it
function SWEP:UpdateIron()
	local Aiming = self:IsAiming()
	if self:GetIron() == Aiming then return end

	self:SetIron(Aiming)

	if self.CustomAnim then
		self:SendWeaponAnim(Aiming and self.AimAnim or self.IdleAnim)
	end

	if self.FakeFire then -- bump the accuracy a bit
		self:SetLastShot(CurTime() + (self.Primary.Delay / 2))
	end
end

function SWEP:Think()
	local Owner = self:GetOwner()
	if not Owner:IsPlayer() then return end

	-- A new burst can start once the trigger has been let go
	if not Owner:KeyDown(IN_ATTACK) then self:SetBurstShots(0) end

	self:SyncAutomatic()
	self:UpdateReload()
	self:UpdateAutoReload()
	self:UpdateIron()

	local FireAnimEnd = self:GetFireAnimEnd()
	if FireAnimEnd > 0 and CurTime() >= FireAnimEnd then
		self:SetFireAnimEnd(0)
		if self:GetActivity() == ACT_VM_PRIMARYATTACK then self:SendWeaponAnim(ACT_VM_IDLE) end
	end

	if self.AimHoldType then
		local HoldType = self:GetIron() and self.AimHoldType or self.HoldType
		if self:GetHoldType() ~= HoldType then self:SetHoldType(HoldType) end
	end
end

function SWEP:CalcDropTable()
	self.CalcRun = true

	return Adapter.CalcDropTable(self:GetBullet())
end

include("sh_fire.lua")
include("sh_reload.lua")

if CLIENT then
	include("cl_view.lua")
	include("cl_hud.lua")
	include("cl_selection.lua")
end
