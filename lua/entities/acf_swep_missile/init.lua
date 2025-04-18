AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local ACF        = ACF
local Debug      = ACF.Debug
local Missiles   = ACF.ActiveMissiles
local Ballistics = ACF.Ballistics
local AmmoTypes  = ACF.Classes.AmmoTypes
local Damage     = ACF.Damage
local Clock      = ACF.Utilities.Clock
local TraceData  = { start = true, endpos = true, filter = true }
local ZERO       = Vector()

local function CheckViewCone(Missile, HitPos)
	local Position = Missile.Position
	local Forward  = Missile.Velocity:GetNormalized()
	local Direction = (HitPos - Position):GetNormalized()

	return Direction:Dot(Forward) >= Missile.ViewCone
end

local function ClampAngle(Object, Limit)
	local Pitch, Yaw, Roll = Object:Unpack()

	return Angle(
		math.Clamp(Pitch, -Limit, Limit),
		math.Clamp(Yaw, -Limit, Limit),
		math.Clamp(Roll, -Limit, Limit)
	)
end

local function DetonateMissile(Missile, Inflictor)
	Debug.Cross(Gun:GetPos(), 15, 15, Color(255, 255, 0), true)

	local CanExplode = hook.Run("ACF_PreExplodeMissile", Missile, Missile.BulletData)

	if not CanExplode then return end

	if IsValid(Inflictor) and Inflictor:IsPlayer() then
		Missile.Inflictor = Inflictor
	end

	Missile:Detonate()
end

function MakeACF_SWEPATGM(Gun, BulletData)
	local Entity = ents.Create("acf_swep_missile")

		timer.Simple(60, function()
				if not IsValid(Entity) then return end

				Entity:Remove()
		end)

	if not IsValid(Entity) then return end

	local Velocity = math.Clamp(BulletData.MuzzleVel / ACF.Scale, 200, 1600)
	local Caliber  = BulletData.Caliber
	local Owner    = Gun.Owner

	Entity:SetAngles(Gun:GetAngles())
	Entity:SetPos(BulletData.Pos)
	Entity:CPPISetOwner(Owner)
	Entity:SetPlayer(Owner)
	Entity:Spawn()

	if Caliber >= 140 then
		Entity:SetModel("models/missiles/glatgm/mgm51.mdl")
		Entity:SetModelScale(Caliber / 150, 0)
	elseif Caliber >= 120 then
		Entity:SetModel("models/missiles/glatgm/9m112.mdl")
		Entity:SetModelScale(Caliber / 125, 0)
	else
		Entity:SetModel("models/missiles/glatgm/9m117.mdl")
		Entity:SetModelScale(Caliber * 0.01, 0)
	end

	Entity:PhysicsInit(SOLID_VPHYSICS)
	Entity:SetMoveType(MOVETYPE_VPHYSICS)

	ParticleEffectAttach("Rocket Motor GLATGM", 4, Entity, 1)

	Entity.Owner        = Gun.Owner
	Entity.Name         = Caliber .. "mm SWEP Launched Missile"
	Entity.ShortName    = Caliber .. "mmSLATGM"
	Entity.EntType      = "SWEP Launched Anti-Tank Guided Missile"
	Entity.Caliber      = Caliber
	Entity.Weapon       = Gun
	Entity.BulletData   = table.Copy(BulletData)
	Entity.ForcedArmor  = 5 -- All missiles should get 5mm
	Entity.ForcedMass   = BulletData.CartMass
	Entity.UseGuidance  = true
	Entity.ViewCone     = math.cos(math.rad(50)) -- Number inside is on degrees
	Entity.KillTime     = CurTime() + 20
	Entity.GuideDelay   = CurTime() + 0.25 -- Missile won't be guided for the first quarter of a second
	Entity.LastThink    = CurTime()
	Entity.Filter       = Entity.BulletData.Filter
	Entity.Agility      = 50 -- Magic multiplier that controls the agility of the missile
	Entity.IsSubcaliber = false -- just set this to false because its a handheld and the rockets are gonna be small
	Entity.LaunchVel    = math.Round(Velocity * 0.2, 2) * 39.37
	Entity.DiffVel      = math.Round(Velocity * 0.5, 2) * 39.37 - Entity.LaunchVel
	Entity.AccelLength  = BulletData.BurnDuration
	Entity.AccelTime    = Entity.LastThink + Entity.AccelLength
	Entity.Speed        = Entity.LaunchVel
	Entity.SpiralRadius = 10
	Entity.SpiralSpeed  = 1
	Entity.SpiralAngle  = 0
	Entity.Position     = BulletData.Pos
	Entity.Velocity     = BulletData.Flight:GetNormalized() * Entity.LaunchVel
	Entity.Inaccuracy   = 0
	Entity.Diameter     = Caliber
	Entity.DropMult     = BulletData.DropMult

	Entity.BulletData.Diameter 	= Caliber
	Entity.BulletData.Speed 	= Entity.Speed

	Entity.Filter[#Entity.Filter + 1] = Entity
	Entity.Filter[#Entity.Filter + 1] = Entity:GetOwner()

	BulletData.Filter[#BulletData.Filter + 1] = Entity
	BulletData.Filter[#BulletData.Filter + 1] = Entity:GetOwner()

	local PhysObj = Entity:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:EnableGravity(false)
		PhysObj:EnableMotion(false)
		PhysObj:SetMass(Entity.ForcedMass)
	end

	ACF.Activate(Entity)

	Missiles[Entity] = true -- no clue what this line does, just copied from ACF-3-Missiles, doesnt seem useful

	hook.Run("ACF_ActivateEntity", Entity)
	hook.Run("ACF_OnLaunchMissile", Entity)

	return Entity
end

function ENT:ACF_Activate(Recalc)
	local PhysObj = self.ACF.PhysObj
	local Area    = PhysObj:GetSurfaceArea() * ACF.InchToCmSq
	local Armor   = self.ForcedArmor
	local Health  = Area / ACF.Threshold
	local Percent = 1

	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health / self.ACF.MaxHealth
	end

	self.ACF.Area      = Area
	self.ACF.Ductility = 0
	self.ACF.Health    = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour    = Armor * (0.5 + Percent * 0.5)
	self.ACF.MaxArmour = Armor * ACF.ArmorMod
	self.ACF.Mass      = self.ForcedMass
	self.ACF.Type      = "Prop"
end

function ENT:ACF_OnDamage(DmgResult, DmgInfo)
	if self.Detonated then
		return {
			Damage = 0,
			Overkill = 1,
			Loss = 0,
			Kill = false
		}
	end

	local HitRes = Damage.doPropDamage(self, DmgResult, DmgInfo) -- Calling the standard prop damage function
	local Owner  = DmgInfo:GetAttacker()

	-- If the missile was destroyed, then we detonate it.
	if HitRes.Kill then
		DetonateMissile(self, Owner)

		return HitRes
	elseif HitRes.Overkill > 0 then
		local Ratio = self.ACF.Health / self.ACF.MaxHealth

		-- We give it a chance to explode when it gets penetrated aswell.
		if math.random() > 0.75 * Ratio then
			DetonateMissile(self, Owner)

			return HitRes
		end

		-- Turning off the missile's guidance.
		if self.UseGuidance and math.random() > 0.5 * Ratio then
			self.UseGuidance = nil
		end
	end

	return HitRes -- This function needs to return HitRes
end

function ENT:GetComputer()
	if not self.UseGuidance then return end

	local Weapon = self.Weapon

	if not IsValid(Weapon) then return end

	local Computer = Weapon.Computer

	if not IsValid(Computer) then return end
	if Computer.Disabled then return end
	if not Computer.IsComputer then return end
	if Computer.HitPos == ZERO then return end

	return Computer
end

function ENT:Think()
	if self.Detonated then return end

	local Time = Clock.CurTime

	if Time >= self.KillTime then
		return self:Detonate()
	end

	local DeltaTime = Time - self.LastThink
	local CanGuide  = self.GuideDelay <= Time
	local Computer  = self:GetComputer()
	local CanSee    = IsValid(Computer) and CheckViewCone(self, Computer.HitPos)
	local Position  = self.Position
	local NextDir, NextAng

	self.Speed = self.LaunchVel + self.DiffVel * math.Clamp(1 - (self.AccelTime - Time) / self.AccelLength, 0, 1)

	if CanGuide and CanSee then
		local Origin      = Computer:LocalToWorld(Computer.Offset)
		local Distance    = Origin:Distance(Position) + self.Speed * 0.15
		local Target      = Origin + Computer.TraceDir * Distance
		local Expected    = (Target - Position):GetNormalized():Angle()
		local Current     = self.Velocity:GetNormalized():Angle()
		local _, LocalAng = WorldToLocal(Target, Expected, Position, Current)
		local Clamped     = ClampAngle(LocalAng, self.Agility * DeltaTime)
		local _, WorldAng = LocalToWorld(Vector(), Clamped, Position, Current)

		NextAng = WorldAng
		NextDir = WorldAng:Forward()

		self.Inaccuracy = 0
	else
		local Spread = self.Inaccuracy * DeltaTime * 0.005
		local Added  = VectorRand() * Spread

		NextDir = (self.Velocity:GetNormalized() + Vector(0,0, -0.0003 * (self.DropMult or 1)) + Added):GetNormalized()
		NextAng = NextDir:Angle()

		self.Inaccuracy = self.Inaccuracy + DeltaTime * 1
	end

	self.Position = self.Position + NextDir * self.Speed * DeltaTime
	self.Velocity = (self.Position - Position) / DeltaTime

	TraceData.start  = Position
	TraceData.endpos = self.Position
	TraceData.filter = self.Filter

	local Result = ACF.trace(TraceData)

	if Result.Hit then
		self.Position = Result.HitPos
		self:SetPos(Result.HitPos)

		return self:Detonate()
	end

	self:SetPos(self.Position)
	self:SetAngles(NextAng)
	self:NextThink(Time)

	self.LastThink = Time

	return true
end

function ENT:GetPenetration(BulletData, Standoff)
	if not isnumber(Standoff) then
		return 1 -- Does not matter, just so calls to damage functions don't go sneedmode
	end

	local BreakupT      = BulletData.BreakupTime
	local MaxVel        = BulletData.JetMaxVel
	local PenMul        = BulletData.PenMul or 1
	local Gamma         = 1 --math.sqrt(TargetDensity / ACF.CopperDensity) (Set to 1 to maintain continuity)

	local Penetration = 0
	if Standoff < BulletData.BreakupDist then
		local JetTravel = BreakupT * MaxVel
		local K1 = 1 + Gamma
		local K2 = 1 / K1
		Penetration = (K1 * (JetTravel * Standoff) ^ K2 - math.sqrt(K1 * ACF.HEATMinPenVel * BreakupT * JetTravel ^ K2 * Standoff ^ (Gamma * K2))) / Gamma - Standoff
	else
		Penetration = (MaxVel * BreakupT - math.sqrt(ACF.HEATMinPenVel * BreakupT * (MaxVel * BreakupT + Gamma * Standoff))) / Gamma
	end

	return math.max(Penetration * ACF.HEATPenMul * PenMul * 1e3, 0) -- m to mm
end

function ENT:Detonate()
	if self.Detonated then return end	-- Prevents GLATGM spawned HEAT projectiles from detonating twice, or for that matter this running twice at all
	self.Detonated = true


	local HitPos = self:GetPos()
	local BulletData = self.BulletData
	local Filler    = BulletData.BoomFillerMass
	local Fragments = BulletData.CasingMass
	local DmgInfo   = Damage.Objects.DamageInfo(self.Owner, self.Gun)

	Damage.createExplosion(HitPos, Filler, Fragments, nil, DmgInfo)

	-- Find ACF entities in the range of the damage (or simplify to like 6m)
	local FoundEnts = ents.FindInSphere(HitPos, 250)
	local Squishies = {}
	for _, v in ipairs(FoundEnts) do
		local Class = v:GetClass()

		-- Blacklist armor and props, the most common entities
		if Class ~= "acf_armor" and Class ~= "prop_physics" and (Class:find("^acf") or Class:find("^gmod_wire") or Class:find("^prop_vehicle") or v:IsPlayer()) then
			Squishies[#Squishies + 1] = v
		end
	end

	-- Move the jet start to the impact point and back it up by the passive standoff
	local Start		= BulletData.Standoff * ACF.MeterToInch
	local End		= BulletData.BreakupDist * 10 * ACF.MeterToInch
	local Direction = BulletData.Flight:GetNormalized()
	local JetStart  = HitPos - Direction * Start
	local JetEnd    = HitPos + Direction * End

	Debug.Cross(JetStart, 15, 15, Color(0, 255, 0), true)
	Debug.Cross(JetEnd, 15, 15, Color(255, 0, 0), true)

	local TraceData = {start = JetStart, endpos = JetEnd, filter = {}, mask = BulletData.Mask}
	local Penetrations = 0
	local JetMassPct   = 1
	-- Main jet penetrations
	while Penetrations < 20 do
		local TraceRes  = ACF.trace(TraceData)
		local PenHitPos = TraceRes.HitPos
		local Ent       = TraceRes.Entity

		if TraceRes.Fraction == 1 and not IsValid(Ent) then break end

		Debug.Line(JetStart, PenHitPos, 15, ColorRand(100, 255))

		if not Ballistics.TestFilter(Ent, self) then TraceData.filter[#TraceData.filter + 1] = TraceRes.Entity continue end

		-- Get the (full jet's) penetration
		local Standoff    = (PenHitPos - JetStart):Length() * ACF.InchToMeter -- Back to m
		local Penetration = self:GetPenetration(self.BulletData, Standoff) * math.max(0, JetMassPct)
		-- If it's out of range, stop here
		if Penetration == 0 then break end

		-- Get the effective armor thickness
		local BaseArmor = 0
		local DamageDealt
		if TraceRes.HitWorld or TraceRes.Entity and TraceRes.Entity:IsWorld() then
			-- Get the surface and calculate the RHA equivalent
			local Surface = util.GetSurfaceData(TraceRes.SurfaceProps)
			local Density = ((Surface and Surface.density * 0.5 or 500) * math.Rand(0.9, 1.1)) ^ 0.9 / 10000
			local Penetrated, Exit = Ballistics.DigTrace(PenHitPos + Direction, PenHitPos + Direction * math.max(Penetration / Density, 1) / ACF.InchToMm)
			-- Base armor is the RHAe if penetrated, or simply more than the penetration so the jet loses all mass and penetration stops
			BaseArmor = Penetrated and ((Exit - PenHitPos):Length() * Density * ACF.InchToMm) or (Penetration + 1)
			-- Update the starting position of the trace because world is not filterable
			TraceData.start = Exit
		--elseif Ent:CPPIGetOwner() == game.GetWorld() then
			-- TODO: Fix world entity penetration
			--BaseArmor = Penetration + 1
		elseif TraceRes.Hit then
			BaseArmor = Ent.GetArmor and Ent:GetArmor(TraceRes) or Ent.ACF and Ent.ACF.Armour or 0
			-- Enable damage if a valid entity is hit
			DamageDealt = 0
		end

		local Angle          = ACF.GetHitAngle(TraceRes, Direction)
		local EffectiveArmor = Ent.GetArmor and BaseArmor or BaseArmor / math.abs(math.cos(math.rad(Angle)))

		-- Percentage of total jet mass lost to this penetration
		local LostMassPct =  EffectiveArmor / Penetration
		-- Deal damage based on the volume of the lost mass
		local Cavity = ACF.HEATCavityMul * math.min(LostMassPct, JetMassPct) * self.JetMass / ACF.CopperDensity -- in cm^3
		local _Cavity = Cavity -- Remove when health scales with armor
		if DamageDealt == 0 then
			_Cavity = Cavity * (Penetration / EffectiveArmor) * 0.035 -- Remove when health scales with armor

			local JetDmg, JetInfo = Damage.getselfDamage(self, TraceRes)

			JetInfo:SetType(DMG_BULLET)
			JetDmg:SetDamage(_Cavity)

			local JetResult = Damage.dealDamage(Ent, JetDmg, JetInfo)

			if JetResult.Kill then
				ACF.APKill(Ent, Direction, 0, JetInfo)
			end
		end
		-- Reduce the jet mass by the lost mass
		JetMassPct = JetMassPct - LostMassPct

		if JetMassPct < 0 then break end

		-- Filter the hit entity
		if TraceRes.Entity then TraceData.filter[#TraceData.filter + 1] = TraceRes.Entity end

		-- Determine how much damage the squishies will take
		local Damageables = {}
		local AreaSum     = 0
		local AvgDist     = 0
		for _, v in ipairs(Squishies) do
			local TargetPos = v:GetPos()
			local DotProd   = (TargetPos - PenHitPos):GetNormalized():Dot(Direction)
			-- If within the arc of spalling
			if DotProd > 0 then
				-- Run a trace to determine if the target is occluded
				local TargetTrace = {start = PenHitPos, endpos = TargetPos, filter = TraceData.filter, mask = self.Mask}
				local TargetRes   = ACF.trace(TargetTrace)
				local SpallEnt    = TargetRes.Entity
				-- If the trace hits something, deal damage to it (doesn't matter if it's not the squishy we wanted)
				if TraceRes.HitNonWorld and ACF.Check(SpallEnt) then
					Debug.Line(PenHitPos, TargetPos, 15, ColorRand(100, 255))

					local DistSqr = math.max(1, (TargetRes.HitPos - PenHitPos):LengthSqr())
					-- Calculate how much shrapnel will hit the target based on it's relative area
					-- Divided by the distance because far away things seem smaller, mult'd by the dot product because
					--  spalling is concentrated around the main jet, and divided by 6 because (simplifying the target
					--  as a cube, good enough) one of the 6 faces is visible
					local Area    = SpallEnt.ACF.Area
					local RelArea = (DotProd ^ 3) * Area / (DistSqr * 6)

					AreaSum = AreaSum + RelArea
					AvgDist = AvgDist + math.sqrt(DistSqr)

					local EntArmor = SpallEnt.GetArmor and SpallEnt:GetArmor(TraceRes) or SpallEnt.ACF and SpallEnt.ACF.Armour
					local EffArmor = (EffectiveArmor * 0.5 / EntArmor) * 14 -- Magic multiplier to prevent nuking armored plates

					Damageables[#Damageables + 1] = { SpallEnt, RelArea * EffArmor, TargetRes }
				end
			end
		end

		AvgDist = AvgDist / #Damageables

		local Radius  = AvgDist * SpallingSin
		-- Minimum area is the base of the spalling cone, with the distance being the average squishy distance
		-- Divided by the average distance squared so it's the same as the relative area
		local MinArea = Radius * Radius * math.pi / (AvgDist * AvgDist)

		AreaSum = math.max(AreaSum, MinArea)

		for _, v in ipairs(Damageables) do
			

			local Entity, Area, TraceRes = unpack(v)
			local SpallDmg, SpallInfo    = Damage.getBulletDamage(self, TraceRes)
			-- Damage is proportional to how much relative surface area the target occupies from the jet's POV
			local SpallDamage = _Cavity * Area / AreaSum  -- change from _Cavity to Cavity when health scales with armor

			SpallInfo:SetType(DMG_BULLET)
			SpallDmg:SetDamage(SpallDamage)

			local JetResult = Damage.dealDamage(Entity, SpallDmg, SpallInfo)

			if JetResult.Kill then
				ACF.APKill(Entity, Direction, 0, SpallInfo)
			end
		end

		Penetrations = Penetrations + 1
	end

	self:Remove()
end

function ENT:OnRemove()
	Missiles[self] = nil

	WireLib.Remove(self)
end
