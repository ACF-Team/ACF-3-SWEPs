-- The reload types, started by SWEP:Reload and driven by SWEP:Think

-- How each SWEP.ReloadType starts, progresses (from SWEP:Think) and gets interrupted by firing
local ReloadTypes = {}

-- The engine does not call SWEP:Think during DefaultReload, so this finishes on the first Think after it
ReloadTypes.magazine = {
	Start = function(self)
		if not self:DefaultReload(self.ReloadAct) then self:SetReloading(false) return false end

		self:SetReloadEnd(CurTime() + self:SequenceDuration())
		return true
	end,
	Finish = function(self)
		self:SetReloading(false)
	end,
}

-- Loads the missing rounds in one go once ReloadEnd is reached
local function StartManualReload(self, Duration)
	self:SetReloadRounds(math.min(self.Primary.ClipSize - self:Clip1(), self:Ammo1()))
	self:SendWeaponAnim(self.ReloadAct)
	self:GetOwner():SetAnimation(PLAYER_RELOAD)
	self:SetReloadEnd(CurTime() + Duration(self))

	return true
end

local function FinishManualReload(self)
	local Rounds = math.min(self:GetReloadRounds(), self:Ammo1())

	self:SendWeaponAnim(ACT_VM_IDLE)
	self:SetClip1(self:Clip1() + Rounds)
	self:GetOwner():RemoveAmmo(Rounds, self.Primary.Ammo)
	self:SetReloading(false)
end

local function RoundsDuration(self)
	-- The animation loads a full clip, about a sixth of it per round after the first second
	return (self:SequenceDuration() - 1) / 6 * self:GetReloadRounds() + self.ReloadFinishOffset
end

local function AnimationDuration(self)
	return self:SequenceDuration()
end

ReloadTypes.rounds = {
	Start = function(self) return StartManualReload(self, RoundsDuration) end,
	Finish = FinishManualReload,
}

ReloadTypes.animation = {
	Start = function(self) return StartManualReload(self, AnimationDuration) end,
	Finish = FinishManualReload,
}

-- Pumps the gun if the model has an animation for it, the next shot waits for it
local function FinishShellReload(self)
	self:SetReloadEnd(0)
	self:SetReloading(false)

	local ViewModel = self:GetOwner():GetViewModel()
	if IsValid(ViewModel) and ViewModel:SelectWeightedSequence(ACT_SHOTGUN_RELOAD_FINISH) >= 0 then
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
	else
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end

local function LoadNextShell(self)
	self:SendWeaponAnim(self.ReloadAct)
	self:SetReloadEnd(CurTime() + self:SequenceDuration())
	self:SetNextPrimaryFire(self:GetReloadEnd())
end

ReloadTypes.shell = {
	Start = function(self)
		LoadNextShell(self)

		return true
	end,
	-- Each shell holds off the next shot until it's in, so the trigger is noticed here and stops the reload after it
	Think = function(self)
		if self:Clip1() > 0 and self:GetOwner():KeyDown(IN_ATTACK) then self:SetReloadStopQueued(true) end
	end,
	Finish = function(self)
		self:SetClip1(self:Clip1() + 1)
		self:GetOwner():RemoveAmmo(1, self.Primary.Ammo)

		if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 and not self:GetReloadStopQueued() then
			LoadNextShell(self)
		else
			FinishShellReload(self)
		end
	end,
	Interrupt = function(self)
		if self:Clip1() <= 0 then return false end

		FinishShellReload(self)
		return true
	end,
}

function SWEP:GetReloadType()
	return ReloadTypes[self.ReloadType] or ReloadTypes.magazine
end

function SWEP:IsReloadPending()
	return self:GetReloadEnd() > 0
end

function SWEP:Reload()
	if self:IsReloadPending() then return end
	if self.ReloadType ~= "magazine" and (self:Clip1() >= self.Primary.ClipSize or self:Ammo1() <= 0) then return end

	if not self:GetReloadType().Start(self) then return end

	self:SetIron(false)
	self:SetReloading(true)
	self:SetReloadStopQueued(false)
	self:SetReloadStart(CurTime())
	self:SetReloadSoundIndex(1)

	self:PlayReloadSounds()
end

-- Plays every ReloadSounds entry that is due
function SWEP:PlayReloadSounds()
	local Sounds = self.ReloadSounds
	if not Sounds then return end

	local Elapsed = CurTime() - self:GetReloadStart()
	local Index = self:GetReloadSoundIndex()
	local Next = Sounds[Index]

	while Next and Elapsed >= Next.Time do
		self:EmitPredictedSound(Next.Sound)
		Index = Index + 1
		Next = Sounds[Index]
	end

	self:SetReloadSoundIndex(Index)
end

-- From SWEP:Think
function SWEP:UpdateReload()
	if not self:IsReloadPending() then return end

	self:PlayReloadSounds()

	local ReloadType = self:GetReloadType()
	if ReloadType.Think then ReloadType.Think(self) end

	if CurTime() < self:GetReloadEnd() then return end

	self:SetReloadEnd(0)
	self:GetReloadType().Finish(self)
end

-- Returns true if firing was used up stopping a reload
function SWEP:InterruptReload()
	if not self:IsReloadPending() then return false end

	local Interrupt = self:GetReloadType().Interrupt
	return Interrupt and Interrupt(self) or false
end

function SWEP:CancelReload()
	self:SetReloadEnd(0)
	self:SetReloadRounds(0)
end
