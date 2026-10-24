AddCSLuaFile()

local Adapter = include("acf_sweps/acf_adapter.lua")

DEFINE_BASECLASS("weapon_acf_base")

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF FIM-92 Stinger"

SWEP.IconOffset				= Vector(4, -4, 0)
SWEP.IconAngOffset			= Angle()

-- Models, textures and sounds from Vanilla-Styled FIM-92 Stinger by Rocks: https://steamcommunity.com/sharedfiles/filedetails/?id=3807683332
SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/fim92/c_fim92.mdl"
SWEP.ViewModelFOV			= 54

SWEP.ShotSound				= Sound("Weapon_FIM92.Shoot")
SWEP.WorldModel             = "models/weapons/fim92/w_fim92.mdl"
SWEP.HoldType               = "rpg"
SWEP.CustomWorldModelPos	= true -- Its weapon_bone doesn't bonemerge onto GMod playermodels
SWEP.OffsetWorldModelPos	= Vector(0, 0, -2) -- Lined up with the HL2 RPG on the shoulder
SWEP.OffsetWorldModelAng	= Angle(14, 0, 180)

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.Scope 					= true
SWEP.Zoom					= 1

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.25
SWEP.RecoilMod              = 0.2

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Ammo           = "RPG_Round"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.5
SWEP.CarrySpeedMul			= 0.6
SWEP.UseHybrid				= false

-- The missile itself is ACF's FIM-92, these only describe the warhead for the info panel
SWEP.Caliber                = 70
SWEP.ACFType                = "HE"
SWEP.ACFMuzzleVel           = 28 -- m/s the launch motor kicks it out at, the flight motor takes over from there
SWEP.ACFProjLen				= 60
SWEP.ACFProjMass			= 3
SWEP.FillerMass				= 1
SWEP.Tracer                 = 0

-- Passed to Missiles.CreateSpec
SWEP.Missile				= "FIM-92"
SWEP.MissileAmmo			= "ACF.Ammunition.HE"
-- Same as the ammo menu sliders, the filler is empty without FillerRatio
-- Half the propellant (40 of 80), the full load flies too fast
SWEP.MissileAmmoData		= {FillerRatio = 1, RoundLength = 140, PropRatio = 0.571}
SWEP.MissileGuidance		= "ACF.Missiles.Guidance.Infrared"
-- Inches, the fuze is only checked once a tick and the missile covers ~420 units in one, so less than ~250 can fly past without going off
-- The warhead's blast reaches ~390
SWEP.MissileFuze			= {Type = "ACF.Missiles.Fuze.Radio", Data = {FuzeDistance = 300}}

-- The seeker looks while aimed, growls when it sees a target and locks onto it after holding it this long
SWEP.LockTime				= 2
SWEP.SeekInterval			= 0.1
SWEP.LockPitch				= 170 -- Pitch of the growl once locked
SWEP.NoLockSound			= Sound("buttons/button10.wav") -- Pulling the trigger without a lock

SWEP.IronSightPos			= Vector(-1, -12, -0.5)
SWEP.IdlePos				= Vector(3, 5, -1.5)
SWEP.SprintAng				= Angle(-10, -10, 0)

SWEP.AimFocused				= 0.5
SWEP.AimUnfocused			= 4

SWEP.FakeFire				= true
SWEP.MoveBloom				= 2

SWEP.Zoom					= 1.5
SWEP.Recovery				= 0.5

SWEP.RequiresAim			= true
SWEP.AimSpeedMul			= 0.7 -- On top of CarrySpeedMul while aimed, see the SetupMove hook
SWEP.AimHoldType			= "rpg"
SWEP.PunchAmount			= 0.5

function SWEP:GetPenetrationText()
	return "Infrared homing"
end

-- Server only, built once since every shot is the same missile
function SWEP:GetMissileSpec()
	local Spec = self.MissileSpec

	if not Spec then
		local Err

		Spec, Err = Adapter.CreateMissileSpec({
			Missile = self.Missile,
			AmmoType = self.MissileAmmo,
			Ammo = self.MissileAmmoData,
			Guidance = {Type = self.MissileGuidance},
			Fuze = self.MissileFuze,
		})

		if not Spec then ErrorNoHalt(self:GetClass() .. ": " .. Err .. "\n") return end

		self.MissileSpec = Spec
	end

	return Spec
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	-- The target can be out of the client's PVS, so its position is networked too
	self:NetworkVar("Entity", 0, "SeekTarget")
	self:NetworkVar("Vector", 0, "SeekPos")
	self:NetworkVar("Float", 5, "SeekStart") -- When the seeker first saw the current target, 0 means it sees nothing
	self:NetworkVar("Float", 6, "NoLockTime") -- When the trigger was last pulled without a lock, for the HUD warning
end

-- Only fires once the seeker has locked on
function SWEP:CanFireNow()
	if not BaseClass.CanFireNow(self) then return false end
	if self:IsLocked() then return true end

	self:SetNoLockTime(CurTime())
	self:EmitPredictedSound(self.NoLockSound)

	return false
end

-- The shooter slows down while aiming the launcher
hook.Add("SetupMove", "ACF SWEPs FIM-92 Aim Speed", function(Ply, Move)
	local Weapon = Ply:GetActiveWeapon()
	if not (IsValid(Weapon) and Weapon.AimSpeedMul and Weapon:GetIron()) then return end

	Move:SetMaxClientSpeed(Move:GetMaxClientSpeed() * Weapon.AimSpeedMul)
end)

function SWEP:IsSeeking()
	return self:GetSeekStart() > 0
end

function SWEP:IsLocked()
	return self:IsSeeking() and CurTime() - self:GetSeekStart() >= self.LockTime
end

function SWEP:Think()
	BaseClass.Think(self)

	if SERVER then self:UpdateSeeker() end
end

-- Server only
function SWEP:UpdateSeeker()
	local Owner = self:GetOwner()
	local Target

	if Owner:IsPlayer() and self:GetIron() and self:Clip1() > 0 then
		if CurTime() < (self.NextSeek or 0) then return end
		self.NextSeek = CurTime() + self.SeekInterval

		local Spec = self:GetMissileSpec()
		if Spec then
			Target = Adapter.FindSeekerTarget(Owner, Owner:GetShootPos(), Owner:GetAimVector(), Adapter.GetSeekCone(Spec), self:GetSeekTarget())
		end
	end

	if not Target then
		self:ClearSeeker()

		return
	end

	self:SetSeekPos(Adapter.GetSeekerTargetPos(Target))

	if Target ~= self:GetSeekTarget() then
		self:SetSeekTarget(Target)
		self:SetSeekStart(CurTime())
	end
end

function SWEP:ClearSeeker()
	self:SetSeekTarget(NULL)
	self:SetSeekStart(0)
end

function SWEP:Holster()
	if SERVER then self:ClearSeeker() end

	return BaseClass.Holster(self)
end

function SWEP:FireShots()
	local Spec = self:GetMissileSpec()
	if not Spec then return end

	local Owner = self:GetOwner()
	local Target = self:IsLocked() and self:GetSeekTarget() or nil
	local Missile, Err = Adapter.FireMissile(self, Spec, Owner:GetShootPos(), self:GetShotDirections()[1], {Owner, self}, Target)

	if not Missile and Err then ErrorNoHalt(self:GetClass() .. ": " .. Err .. "\n") end

	self:ClearSeeker()
end

if CLIENT then
	local Black = Color(0, 0, 0)
	local SeekColor = Color(255, 200, 0)
	local LockColor = Color(255, 40, 40)
	local Scale = math.max(ScrW() / 1920, 1)

	function SWEP:UpdateSeekerTone()
		if not self:IsSeeking() then return self:StopSeekerTone() end

		local Tone = self.SeekerTone

		if not Tone then
			Tone = CreateSound(self, "Weapon_FIM92.Seeker")
			self.SeekerTone = Tone
		end

		if not Tone:IsPlaying() then Tone:Play() end

		Tone:ChangePitch(self:IsLocked() and self.LockPitch or 100, 0.1)
	end

	function SWEP:StopSeekerTone()
		if self.SeekerTone then self.SeekerTone:Stop() end
	end

	function SWEP:OnRemove()
		self:StopSeekerTone()

		BaseClass.OnRemove(self)
	end

	function SWEP:DrawHUD()
		BaseClass.DrawHUD(self)

		-- Flashes for a second after trying to fire without a lock
		local NoLock = CurTime() - self:GetNoLockTime()
		if NoLock < 1 and NoLock % 0.25 < 0.125 then
			draw.SimpleTextOutlined("NO LOCK", "SWEP-HUD-FONT", ScrW() * 0.5, ScrH() * 0.5 + 48 * Scale, LockColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Black)
		end

		if not self:IsSeeking() then return end

		local Locked = self:IsLocked()
		if not Locked and CurTime() % 0.25 > 0.125 then return end -- Blinks until it locks

		local Target = self:GetSeekTarget()
		local Pos = (IsValid(Target) and Target:WorldSpaceCenter() or self:GetSeekPos()):ToScreen()
		if not Pos.visible then return end

		local Col = Locked and LockColor or SeekColor
		local Size = 24 * Scale

		surface.SetDrawColor(Col)
		surface.DrawOutlinedRect(Pos.x - Size, Pos.y - Size, Size * 2, Size * 2, 2)

		if Locked then
			draw.SimpleTextOutlined("LOCK", "SWEP-HUD-FONT", Pos.x, Pos.y + Size + 4, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Black)
		end
	end

	-- SWEP:Think isn't run clientside in singleplayer, so the tone is driven from here
	local ToneWeapon

	hook.Add("Think", "ACF SWEPs FIM-92 Seeker Tone", function()
		local Ply = LocalPlayer()
		local Weapon = IsValid(Ply) and Ply:Alive() and Ply:GetActiveWeapon() or nil

		if not (IsValid(Weapon) and Weapon.UpdateSeekerTone) then Weapon = nil end

		if ToneWeapon ~= Weapon and IsValid(ToneWeapon) then ToneWeapon:StopSeekerTone() end

		ToneWeapon = Weapon

		if Weapon then Weapon:UpdateSeekerTone() end
	end)
end
