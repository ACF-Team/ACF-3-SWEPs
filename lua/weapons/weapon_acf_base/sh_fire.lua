-- Firing, spread and recoil

local Adapter = include("acf_sweps/acf_adapter.lua")
local IsSinglePlayer = game.SinglePlayer()

-- Focus is the spread multiplier from the sights, the rest comes from stance, movement and firing
function SWEP:CalcAimMod(Focus)
	local Owner = self:GetOwner()
	local LastShot = self:GetLastShot()

	local Prone = false
	if Owner.IsProne then Prone = Owner:IsProne() end -- Prone mod support

	local VelMod = math.Clamp(Owner:GetAbsVelocity():LengthSqr() / 50000, 0, 2) * self.MoveBloom
	local OwnerOnGround = Owner:IsOnGround()
	local StanceMod = (Prone and OwnerOnGround and 0.25) or ((Owner:Crouching() and OwnerOnGround) and 0.5 or 1)
	local OnGround = (OwnerOnGround and 1 or 3)
	local Bloom = (1 - math.Clamp((CurTime() - LastShot) * self.Recovery, 0, 1)) * self.Spread * 6 * (1 / (self.Handling / math.min(1, 1.3 * StanceMod)))

	return math.min(30, ((Focus * StanceMod) + Bloom + VelMod) * OnGround)
end

-- The spread of a shot, the same on both realms so the client can predict it
function SWEP:GetAimMod()
	local Owner = self:GetOwner()
	if Owner:IsNPC() then return 1 end

	return self:CalcAimMod((self:GetIron() and (not Owner:IsSprinting())) and self.AimFocused or self.AimUnfocused)
end

if CLIENT then
	-- Follows the sights as they come up, this is only used to draw the crosshair
	function SWEP:GetCrosshairAimMod()
		local Owner = self:GetOwner()
		if Owner:IsNPC() then return 1 end

		return self:CalcAimMod(Lerp((not Owner:IsSprinting()) and self.IronScale or 0, self.AimUnfocused, self.AimFocused))
	end
end

function SWEP:ResolveAim()
	local Ply = self:GetOwner()
	if not Ply:IsPlayer() then return Ply:GetAimVector():Angle() end

	return Ply:GetAimVector():Angle() + Ply:GetViewPunchAngles()
end

function SWEP:GetShotFilter()
	local Ply = self:GetOwner()
	local filter = {Ply, self}
	if Ply:IsPlayer() and Ply:InVehicle() then
		local vic = Ply:GetVehicle()
		table.insert(filter, vic)

		if IsValid(vic.AliasEnt) and vic.AliasEnt ~= NULL then
			table.insert(filter, vic.AliasEnt)
		end
	end

	return filter
end

-- Players and NPCs this close are hit straight away instead of by a projectile, returns the trace if that happens
-- The server runs it lag compensated, the client sees the world as the server rewinds it anyway
local mask = bit.band(MASK_SOLID, MASK_SHOT) + CONTENTS_AUX
function SWEP:TraceHybrid(Pos, Dir, Filter)
	local Bullet = self:GetBullet()
	if not self.UseHybrid or Bullet.Type ~= "AP" then return end

	local Ply = self:GetOwner()
	local tr = util.TraceLine({start = Pos, endpos = Pos + (Dir * math.min(1024, Bullet.MuzzleVel * 39.37 * 0.05) + Ply:GetVelocity()), filter = Filter, mask = mask})

	-- Hybrid trace will fully initiate if it only hits players or npcs
	if tr.Hit and Adapter.IsHybridTarget(tr.Entity) then return tr end
end

-- Server only
function SWEP:ShootBullet(Pos, Dir, PredictionID)
	local Ply = self:GetOwner()
	local Bullet = self:GetBullet()
	local IsPlayer = Ply:IsPlayer()
	local filter = self:GetShotFilter()

	if IsPlayer then Ply:LagCompensation(true) end
	local tr = self:TraceHybrid(Pos, Dir, filter)
	if IsPlayer then Ply:LagCompensation(false) end

	if tr then
		Adapter.HybridHit(self, Bullet, tr, Pos, Dir)

		return
	end

	Adapter.FireProjectile(self, Bullet, Pos, Dir, filter, PredictionID)
end

-- The server and the owner's client both work this out for a shot, it ties the client's bullet to the server's
-- nil when the client doesn't predict the shot
function SWEP:GetPredictionID(Pellet)
	if IsSinglePlayer then return end -- The client never runs the shot itself in single player

	local Owner = self:GetOwner()
	if not Owner:IsPlayer() or Owner:IsBot() or Owner:IsListenServerHost() then return end

	local Command = Owner:GetCurrentCommand()
	if not Command then return end

	return Command:CommandNumber() * 256 + Pellet
end

-- Runs on every prediction pass like the rest of the firing code, only the effects check IsFirstTimePredicted
function SWEP:CanPrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SyncAutomatic()

	-- The burst is spent, wait for the trigger to be released (see SWEP:Think)
	if self:GetFireMode() == 3 and self:GetBurstShots() >= self.BurstSize then return false end

	if self:Clip1() <= 0 then
		self:EmitPredictedSound("Weapon_Pistol.Empty")

		-- DefaultReload refuses to start while the next shot is pending
		self:SetNextPrimaryFire(CurTime())
		self:Reload()
		self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), CurTime() + 0.25))

		self:SetLastShot(CurTime())

		return false
	end

	local Owner = self:GetOwner()
	if Owner:IsPlayer() and (Owner:IsSprinting() and (Owner:GetAbsVelocity():LengthSqr() > 10000)) then return false end

	-- The client can't know about this and predicts the shot, the server's ammo count corrects it
	if SERVER and not Adapter.CanFire(self) then
		self:SetLastShot(CurTime())

		return false
	end

	return true
end

-- Weapons customize a shot through the hooks below and the firing settings, not by replacing this
function SWEP:PrimaryAttack()
	if self:InterruptReload() then return end
	if not self:CanPrimaryAttack() then return end
	if not self:CanFireNow() then return end

	self:Recoil(self:GetPunch())

	if SERVER then
		self:FireShots()
	elseif IsFirstTimePredicted() then
		self:PredictShots()
	end

	self:PostShot(1)
	self:OnShotFired()
end

-- Launchers can only be fired from the shoulder
function SWEP:CanFireNow()
	local Owner = self:GetOwner()
	if not self.RequiresAim or not Owner:IsPlayer() or self:GetIron() then return true end

	if SERVER then Owner:PrintMessage(HUD_PRINTCENTER, "You have to aim first!") end

	return false
end

-- Called after a shot has been fired, on both realms and on every prediction pass (use SWEP:EmitPredictedSound)
function SWEP:OnShotFired()
end

-- A direction within Cone degrees of Forward, Right and Up give the plane the offset is picked in
-- util.SharedRandom gives the owner's client the same spread as the server, every call in a shot takes the next seed
function SWEP:SpreadDirection(Forward, Right, Up, Cone)
	local Seed = (self.SpreadSeed or 0) + 1
	self.SpreadSeed = Seed

	local Offset = (Up * util.SharedRandom("ACFSpreadUp", -1, 1, Seed) + Right * util.SharedRandom("ACFSpreadRight", -1, 1, Seed)):GetNormalized()
	local Spread = Offset * math.tan(math.rad(Cone)) * (util.SharedRandom("ACFSpread", 0, 1, Seed) ^ (1 / Adapter.GetInaccuracyBias()))

	return (Forward + Spread):GetNormalized()
end

-- Every projectile direction of one shot, on both realms so the client can predict them
-- Call SWEP:StartShot before it, so the spread seeds line up with the other realm's
function SWEP:GetShotDirections()
	local Aim = self:ResolveAim()
	local Dir = self:SpreadDirection(Aim:Forward(), Aim:Right(), Aim:Up(), self.Spread * self:GetAimMod())

	local PitchAdjust = self:GetPitchAdjust()
	if PitchAdjust ~= 0 then Dir = (Dir:Angle() + Angle(PitchAdjust, 0, 0)):Forward() end

	return {Dir}
end

function SWEP:UpdateTracer()
	local Tracer = self.Tracer
	if Tracer == 0 then return end

	local Every = self.TracerEvery
	local IsTracer = Every <= 1 or self:Clip1() % Every == 1

	Adapter.NetworkTracer(self, IsTracer and Tracer or 0)
end

function SWEP:StartShot()
	self.SpreadSeed = 0
end

-- Server only
function SWEP:FireShots()
	local Pos = self:GetOwner():GetShootPos()

	self:UpdateTracer()
	self:StartShot()

	for Pellet, Dir in ipairs(self:GetShotDirections()) do
		self:ShootBullet(Pos, Dir, self:GetPredictionID(Pellet))
	end
end

-- Client only, the owner sees their own shots straight away instead of a round trip later
-- The server's bullets take these over when they arrive, see ACF's predicted bullets
function SWEP:PredictShots()
	local Pos = self:GetOwner():GetShootPos()
	local Bullet = self:GetBullet()
	local Filter = self:GetShotFilter()

	self:UpdateTracer()
	self:StartShot()

	for Pellet, Dir in ipairs(self:GetShotDirections()) do
		local PredictionID = self:GetPredictionID(Pellet)

		if PredictionID and not self:TraceHybrid(Pos, Dir, Filter) then
			Adapter.PredictProjectile(self, Bullet, Pos, Dir, PredictionID)
		end
	end
end

function SWEP:PostShot(NumberShots)
	self:EmitPredictedSound(self.ShotSound)

	self:SendWeaponAnim(ACT_VM_IDLE)
	-- Fire animations usually pull the gun off the sights, so keep it steady while aiming (scoped weapons hide the viewmodel anyway)
	if self.AimFireAnim or self.Scope or not self:GetIron() then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		if self.FireAnimTime then self:SetFireAnimEnd(CurTime() + self.FireAnimTime) end
	end

	if self.ScopeBlinkOnFire then self:SetScopeBlinkEnd(CurTime() + self.Primary.Delay * 0.8) end

	if CLIENT then
		if IsFirstTimePredicted() then self:ShotEffects() end
	elseif IsSinglePlayer then
		-- The client never runs the shot itself in single player, so hand it the effects
		self:CallOnClient("ShotEffects")
	end

	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	self:SetLastShot(CurTime())
	self:SetBurstShots(self:GetBurstShots() + 1)

	self:TakePrimaryAmmo(NumberShots)
end

function SWEP:GetPunch()
	return Angle(-self.PunchAmount, 0, 0) * self.RecoilMod * (self:GetIron() and 0.4 or 1)
end

function SWEP:Recoil(PunchAmt)
	local Ply = self:GetOwner()
	if not Ply:IsPlayer() then return false end
	if Ply:IsSprinting() and (Ply:GetAbsVelocity():LengthSqr() > 10000) then return false end
	Ply:ViewPunch(PunchAmt)
end
