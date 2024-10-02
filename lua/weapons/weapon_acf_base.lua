AddCSLuaFile()

-- TODO: Prone Mod support
-- TODO: Bipods!

local AmmoTypes = ACF.Classes.AmmoTypes:GetEntries()
local Damage	= ACF.Damage
local DmgObj	= Damage.Objects

SWEP.Author                 = "LiddulBOFH"
SWEP.Base                   = "weapon_base" -- Loads in functions from this weapon base, don't change!
SWEP.PrintName              = "ACF-3 SWEP Base"
SWEP.Instructions           = [[Left click: Shoot/nRight click: Aim down sights]] -- This isn't seen as I make my own info panel for all of this
SWEP.Purpose                = "Kills stuff dead"
SWEP.Category               = "ACF-3 SWEPs"
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

SWEP.Primary.ClipSize       = 30 -- The size of the magazine in the weapon
SWEP.Primary.DefaultClip    = 30 -- This is what will initially start in the magazine when the weapon is first spawned
SWEP.Primary.Ammo           = "AR2" -- the actual ammo you load (has 0 impact on damage)

-- The firerate of the weapon, can figure this out by 60 / RPM
SWEP.Primary.Delay          = 0.1

SWEP.Primary.Automatic      = true -- Whether or not the weapon can refire by itself

-- 1 is just normal firing (user can't change)
-- 2 is full auto and semi auto
-- If it needs to be just semi auto, just set Automatic to false above
SWEP.FiremodeSetting		= 1

-- 1 is normal full auto
-- 2 is semi-auto
SWEP.CurrentFiremode		= 1

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
SWEP.ACFType                = "AP" -- Type of projectile (currently only AP and HE work)
SWEP.ACFMuzzleVel           = 800 -- Speed of the projectile leaving the barrel
SWEP.ACFProjMass            = 0.004 -- kg of projectile
SWEP.Tracer                 = 0 -- Supposed to be length in the final projectile dedicated to tracer filler, but seems to not affect anything except for showing tracers

SWEP.IronSightPos           = Vector(0, 0, 0) -- Shifts the viewmodel by this much to put the view inline with the iron sights
--SWEP.IronSightAng           = Angle() -- Turns the viewmodel by this much to help line the above too
SWEP.SprintAng				= Angle(-15, 40, 0) -- The angle the viewmodel turns to when the player is sprinting

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

-- Internal values, don't change!
SWEP.DropCalc				= {}
SWEP.CalcRun				= false
SWEP.IronScale              = 0
SWEP.SprintScale			= 0
SWEP.NextAttack2Toggle      = 0
SWEP.LastShot				= 0
SWEP.MeasuredPen			= 0
SWEP.MeasuredPen2			= 0
SWEP.DisableDuplicator		= true -- why oh why do I even have to do this
SWEP.RateTime				= 0
SWEP.Reloading				= false

SWEP.IconOverride			= "materials/acf_logo.png"
local FiremodeSound = Sound("Weapon_SMG1.Special2")

function SWEP:SetupACFBullet()
	local Area = math.pi * (SWEP.Caliber * 0.05) ^ 2
	self.Bullet = {
		DragCoef = Area * 0.0001 / self.ACFProjMass,
		Caliber = self.Caliber * 0.1, -- Caliber in mm, converted to cm
		ProjMass = self.ACFProjMass,
		Type = self.ACFType,
		Diameter = self.Caliber * 0.1, -- Caliber in mm converted to cm, in diameter
		Ricochet = 60,
		ProjArea = Area,
		LimitVel = 800,
		ShovePower = 0.2,
		MuzzleVel = self.ACFMuzzleVel
	}

	if self.ACFType == "APDS" then
		self.Bullet.DragCoef = Area * 0.000125 / self.ACFProjMass
	end

	if self.ACFType == "HE" then
		self.Bullet["ProjLength"] = self.ACFProjLen
		self.Bullet["ShovePower"] = 0.1
		self.Bullet["LimitVel"] = 100
		local FreeVol   = ACF.RoundShellCapacity(0.0, self.Bullet.ProjArea, self.Bullet.Caliber, self.Bullet.ProjLength)
		local FillerVol = FreeVol * 1
		self.Bullet["FillerMass"] = self.FillerMass
		self.Bullet["ProjMass"] = math.max(FillerVol, 0) * ACF.SteelDensity + self.Bullet["FillerMass"]
	end

	if self.ACFType == "HEAT" then -- I hate it I hate it I hate it I hate it I hate it
		--[[
		-- I hate how inaccessible this is
		SWEP.ACFHEATDetAngle		= 75
		SWEP.ACFHEATStandoff		= 0.0198
		SWEP.ACFHEATLinerMass		= 0.2284
		SWEP.ACFHEATCartMass		= 1.4458
		SWEP.ACFHEATCasingMass		= 0.6792
		-- I mean what the actual fuck, why can't I just call a single function to build this fucking data
		SWEP.ACFHEATJetMass			= 0.1713
		SWEP.ACFHEATJetMinVel		= 3369.89
		SWEP.ACFHEATJetMaxVel		= 4744.36
		SWEP.ACFHEATBoomFillerMass	= 0.235
		SWEP.ACFHEATRoundVolume		= 811.3553
		SWEP.ACFHEATBreakupDist		= 0.6481
		SWEP.ACFHEATBreakupTime		= 0.000136606
		]]
		self.Bullet["DetonatorAngle"] = self.ACFHEATDetAngle
		self.Bullet["Standoff"] = self.ACFHEATStandoff
		self.Bullet["JetMass"] = self.ACFHEATJetMass
		self.Bullet["JetMinVel"] = self.ACFHEATJetMinVel
		self.Bullet["JetMaxVel"] = self.ACFHEATJetMaxVel
		self.Bullet["RoundVolume"] = self.ACFHEATRoundVolume
		self.Bullet["BoomFillerMass"] = self.ACFHEATBoomFillerMass
		self.Bullet["LinerMass"] = self.ACFHEATLinerMass
		self.Bullet["FillerMass"] = self.FillerMass
		self.Bullet["BreakupDist"] = self.ACFHEATBreakupDist
		self.Bullet["BreakupTime"] = self.ACFHEATBreakupTime
		self.Bullet["CartMass"] = self.ACFHEATCartMass
		self.Bullet["CasingMass"] = self.ACFHEATCasingMass

		self.Bullet["LimitVel"] = 100
	end

	if self.Fuze then self.Bullet.Fuze = self.Fuze end
end

function SWEP:Initialize()
	self.FiremodeSetting = math.Clamp(math.floor(self.FiremodeSetting), 1, 2)
	self.CurrentFiremode = math.Clamp(math.floor(self.CurrentFiremode), 1, 2)

	if self.FiremodeSetting ~= 1 then
		if self.CurrentFiremode == 1 then self.Primary.Automatic = true else self.Primary.Automatic = false end
	end
	self:UpdateFiremode()

	self:SetHoldType(self.HoldType)

	-- These have to be networked since the clientside ACF bullets don't get information from anything except the crate (the gun represents this in this case)
	self:SetNW2Float("Caliber", self.Bullet.Caliber)
	self:SetNW2Float("ProjMass", self.Bullet.ProjMass)
	self:SetNW2Float("DragCoef", self.Bullet.DragCoef)
	self:SetNW2Float("AmmoType", self.Bullet.Type)

	if self.BulletModel then self:SetNW2String("BulletModel", self.BulletModel) self:SetNW2Float("BulletScale", self.BulletScale or 1) end

	if self.Tracer > 0 then
		self:SetNW2Float("Tracer", self.Tracer)
	end

	if self.Bullet.Type == "HE" or self.Bullet.Type == "HEAT" then
		self:SetNW2Float("FillerMass", self.Bullet.FillerMass)
	end
end

function SWEP:GetAimMod()
	local Owner = self:GetOwner()
	if Owner:IsNPC() then return 1 end
	local LastShot = 0
	if SERVER then LastShot = self.LastShot else LastShot = math.max(self:GetNWFloat("lastshot", CurTime()), self.LastShot) end

	local Prone = false
	if Owner.IsProne then Prone = Owner:IsProne() end -- Prone mod support

	local VelMod = math.Clamp(Owner:GetAbsVelocity():LengthSqr() / 50000, 0, 2) * self.MoveBloom
	local OwnerOnGround = Owner:IsOnGround()
	local StanceMod = (Prone and OwnerOnGround and 0.25) or ((Owner:Crouching() and OwnerOnGround) and 0.5 or 1)
	local OnGround = (OwnerOnGround and 1 or 3)
	local Bloom = (1 - math.Clamp((CurTime() - LastShot) * self.Recovery, 0, 1)) * self.Spread * 6 * (1 / (self.Handling / math.min(1, 1.3 * StanceMod)))
	if SERVER then
		local Focus = (self:GetNWBool("iron") and (not Owner:IsSprinting()) and self.AimFocused or self.AimUnfocused)
		return math.min(30, ((Focus * StanceMod) + Bloom + VelMod) * OnGround)
	else
		local Focus = Lerp((not Owner:IsSprinting()) and self.IronScale or 0, self.AimUnfocused, self.AimFocused)
		return math.min(30, ((Focus * StanceMod) + Bloom + VelMod) * OnGround)
	end
end

local function ShootACFBullet(swep, Pos, Dir, Filter)
	local Ply = swep:GetOwner()

	swep.Bullet.Owner = Ply
	swep.Bullet.Gun = swep
	swep.Bullet.Pos = Pos
	swep.Bullet.Filter = Filter
	swep.Bullet.Crate = swep:EntIndex()

	swep.Bullet.Flight = Dir * swep.ACFMuzzleVel * 39.37 + Ply:GetVelocity()

	AmmoTypes[swep.ACFType]:Create(swep, swep.Bullet)
end

function SWEP:ResolveAim()
	local Ply = self:GetOwner()

	return Ply:GetAimVector():Angle() + Ply:GetViewPunchAngles()
end

local mask = bit.band(MASK_SOLID, MASK_SHOT) + CONTENTS_AUX
function SWEP:ShootBullet(Pos, Dir)
	local Ply = self:GetOwner()
	local SelfTbl = self:GetTable()

	local filter = {Ply, self}
	if Ply:InVehicle() then
		local vic = Ply:GetVehicle()
		table.insert(filter, vic)

		if IsValid(vic.AliasEnt) and vic.AliasEnt ~= NULL then
			table.insert(filter, vic.AliasEnt)
		end
	end

	if SelfTbl.UseHybrid and SelfTbl.ACFType == "AP" then
		Ply:LagCompensation(true)
		local tr = util.TraceLine({start = Pos, endpos = Pos + (Dir * math.min(1024, SelfTbl.ACFMuzzleVel * 39.37 * 0.05) + Ply:GetVelocity()), filter = filter, mask = mask})
		Ply:LagCompensation(false)

		if tr.Hit and ACF.Check(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC()) then --Hybrid trace will fully initiate if it only hits player or npcs.
			local DmgResult, DmgInfo = DmgObj.DamageResult(), DmgObj.DamageInfo()
			local Bullet	= SelfTbl.Bullet
			local Thickness	= tr.Entity.ACF.Armour
			local Dist		= Pos:Distance(tr.HitPos)
			local RangedSpeed	= ACF.GetRangedSpeed(SelfTbl.ACFMuzzleVel, Bullet.DragCoef, Dist / 39.37) * 0.0254
			local ScaleVel	= SelfTbl.ACFMuzzleVel * 39.3701
			local RadiusCal	= SelfTbl.Caliber / 10
			--local DecalIndex = ACF.GetAmmoDecalIndex i have no idea why this function is giving blank output...

			DmgResult:SetPenetration(ACF.Penetration(RangedSpeed, Bullet.ProjMass, Bullet.Diameter * 10))
			DmgResult:SetArea(Bullet.ProjArea)
			DmgResult:SetThickness(Thickness)
			DmgResult:SetAngle(ACF.GetHitAngle(tr, Dir))
			DmgResult:SetFactor(1)

			DmgInfo:SetAttacker(Ply)
			DmgInfo:SetInflictor(self)
			DmgInfo:SetType(DMG_BULLET)
			DmgInfo:SetOrigin(Pos)
			DmgInfo:SetHitPos(tr.HitPos)
			DmgInfo:SetHitGroup(tr.HitGroup)

			local HitRes = Damage.dealDamage(tr.Entity, DmgResult, DmgInfo)

			if SelfTbl.UseBloodEffect then
				local effect = EffectData()
				effect:SetOrigin(tr.HitPos)
				effect:SetNormal(tr.Normal)
				effect:SetEntity(self)
				util.Effect("BloodImpact", effect, true, true)
			else
				local effect = EffectData()
				effect:SetOrigin(tr.HitPos)
				effect:SetNormal(tr.Normal)
				effect:SetScale(ScaleVel)
				effect:SetMagnitude(SelfTbl.ACFProjMass)
				effect:SetRadius(RadiusCal)
				--effect:SetDamageType(DecalIndex(SelfTbl.ACFType)) the penetration decal still displays without this??? i give up.
				util.Effect("ACF_Penetration", effect, true, true)
			end

			if HitRes.Kill and IsValid(tr.Entity) then
				local Energy = ACF.Kinetic(RangedSpeed, Bullet.ProjMass)

				ACF.APKill(tr.Entity, Dir, Energy.Kinetic, DmgInfo)
			end
		else
			ShootACFBullet(self, Pos, Dir, filter)
		end
	else
		ShootACFBullet(self, Pos, Dir, filter)
	end
end

local IsSinglePlayer = game.SinglePlayer()

function SWEP:CanPrimaryAttack()
	if not IsFirstTimePredicted() then return false end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if self.Primary.Automatic ~= self:GetNWBool("automatic", false) then self:UpdateFiremode() end

	if self:GetOwner():IsPlayer() then
		if SERVER and IsSinglePlayer then self:CallOnClient("PrimaryAttack") end

		if CLIENT and (CurTime() - self.LastShot) < self.Primary.Delay then return end
	end

	if (self:Clip1() <= 0) then
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:Reload()

		self.LastShot = CurTime()
		if SERVER then self:SetNWFloat("lastshot", self.LastShot) end

		return false
	end

	local Owner = self:GetOwner()
	if Owner:IsPlayer() and (Owner:IsSprinting() and (Owner:GetAbsVelocity():LengthSqr() > 10000)) then return false end

	-- Calls this hook to see if this gun is allowed to shoot an ACF shell
	-- There isn't a way for the client to know about this, so we'll just replenish the clientside ammo
	if SERVER and (hook.Run("ACF_FireShell", self) == false) then
		self:SetNWInt("lastammo")
		self:CallOnClient("ResetAmmo")

		self.LastShot = CurTime()
		if SERVER then self:SetNWFloat("lastshot", self.LastShot) end

		return false
	end

	return true
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
end

function SWEP:PostShot(NumberShots)
	self:EmitSound(self.ShotSound)

	self:SendWeaponAnim(ACT_VM_IDLE)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	self.LastShot = CurTime()
	if SERVER then self:SetNWFloat("lastshot", self.LastShot) end

	self:TakePrimaryAmmo(NumberShots)
end

function SWEP:ResetAmmo() -- Only called clientside, to replenish "used" ammo if the server denies an ACF bullet being made
	self:SetClip1(self:GetNWInt("lastammo", self:Clip1()))
	self:SetNextPrimaryFire(CurTime() + 0.2)
	self:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:SecondaryAttack()
	local Owner = self:GetOwner()
	if Owner:KeyDown(IN_USE) and (CurTime() > self.NextAttack2Toggle) and self.FiremodeSetting ~= 1 then

		if SERVER then
			local A = self.CurrentFiremode
			if self.FiremodeSetting == 2 then
				if A == 1 then A = 2 else A = 1 end
			end

			self.CurrentFiremode = A
			if self.CurrentFiremode == 1 then self.Primary.Automatic = true else self.Primary.Automatic = false end

			self:UpdateFiremode()
		else
			self:EmitSound(FiremodeSound)
		end

		self.NextAttack2Toggle = CurTime() + 0.2
		return true
	end

	return true
end

function SWEP:UpdateFiremode()
	if SERVER then
		self:SetNWInt("firemode", self.CurrentFiremode)
		self:SetNWBool("automatic", self.Primary.Automatic)
		self:CallOnClient("UpdateFiremode")
	end

	if self.Primary.Automatic ~= self:GetNWBool("automatic", false) then self.Primary.Automatic = self:GetNWBool("automatic", false) end
end

function SWEP:Deploy()
	if CLIENT then
		self.FOV = self:GetOwner():GetFOV()
	else
		if self.Tracer > 0 then
			local Col = Color(255, 255, 255)
			if self:GetOwner():IsPlayer() then Col = team.GetColor(self:GetOwner():Team()) end
			self:SetColor(Col)
		end

		-- Hopefully fixes some weird problem with weapons not "recoiling" as they should
		self.Primary.Automatic = false
		timer.Simple(0, function()
			if IsValid(self) then
				self.Primary.Automatic = self:GetNWBool("automatic", false)
			end
		end)
	end

	if self.HasDropCalc then self.DropCalc = self:CalcDropTable() end

	self.LastShot = CurTime()
	if SERVER then self:SetNWFloat("lastshot", self.LastShot) end

	-- self.Owner = self:GetOwner() -- A quick way to match what ACF does for this

	self:SendWeaponAnim(ACT_VM_DRAW) -- another missing anim

	if self.Bullet.Type == "HE" or self.Bullet.Type == "HEAT" then
		self:SetNW2Float("FillerMass", self.Bullet.FillerMass)
	end
end

function SWEP:Holster()
	if not IsFirstTimePredicted() then return end
	self.Reloading = (self:Clip1() <= 0) and (self:Ammo1() > 0)

	self:SetNWBool("iron", false)
	self.IronScale = 0

	return true
end

function SWEP:Reload()
	local DidReload = self:DefaultReload( ACT_VM_RELOAD ) -- If this is successful, SWEP:Think doesn't run, so we have to handle anything that should happen in there
	if DidReload and not self.Reloading then
		self:SetNWBool("iron", false)
		timer.Simple(self:SequenceDuration() * 0.9, function() self.Reloading = false end)
	end
	self.Reloading = DidReload
end

function SWEP:GetPunch()
	return Angle(-3, 0, 0) * self.RecoilMod * (self:GetNWBool("iron", false) and 0.4 or 1)
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

function SWEP:Think()
	if SERVER then
		local ct = CurTime()
		if ct > (self.NextThinkTime or 0) then
			local Owner = self:GetOwner()
			local Condition = (Owner:IsOnGround()) and (not Owner:IsSprinting())
			and Owner:KeyDown(IN_ATTACK2)
			and (not Owner:KeyDown(IN_USE))

			if self:GetNWBool("iron") ~= Condition then
				self:SetNWBool("iron", Condition) -- only updates as needed

				if self.CustomAnim then
					if Condition then
						self:SendWeaponAnim(self.AimAnim)
					else
						self:SendWeaponAnim(self.IdleAnim)
					end
				end

				if self.FakeFire then -- bump the accuracy a bit
					self.LastShot = CurTime() + (self.Primary.Delay / 2)
					self:SetNWFloat("lastshot", self.LastShot)
				end
			end

			self.NextThinkTime = CurTime() + 0.01
		end
	end
end

function SWEP:CalcDropTable()
	local BD = self.Bullet
	local CheapTime = 1 / 60

	local Valid = true
	local Bullet = {Flight = Vector(1, 0, 0) * (self.ACFMuzzleVel * 39.37), Pos = Vector(), pm = BD.ProjMass, DragCoef = BD.DragCoef, Accel = ACF.Gravity}

	Bullet.NextPos = Bullet.Pos

	local Targets = {200, 400, 500, 600, 700, 800}
	local DropTable = {}

	local Int = 0
	local Time = 0
	while Valid do
		Bullet.Pos = Bullet.NextPos
		Time = Time + CheapTime
		if (#Targets > 0) and ((Bullet.Pos.x / 39.37) >= Targets[1]) or false then
			DropTable[#DropTable + 1] = {Bullet.Pos, Time, Targets[1]}
			table.remove(Targets, 1)
		end
		local Drag = Bullet.Flight:GetNormalized() * (Bullet.DragCoef * Bullet.Flight:LengthSqr()) / ACF.DragDiv
		Bullet.NextPos = Bullet.Pos + ACF.Scale * CheapTime * Bullet.Flight
		Bullet.Flight = Bullet.Flight + (Bullet.Accel - Drag) * CheapTime
		Int = Int + 1
		if (math.abs(Bullet.Pos.x) > 32768) or (math.abs(Bullet.Pos.z) < -32768) or (Int > 2000) then Valid = false end
	end

	if #DropTable > 0 then DropTable = table.Reverse(DropTable) end

	self.CalcRun = true
	return DropTable
end

function SWEP:Recoil(PunchAmt)
	local IFTP = IsFirstTimePredicted()
	local Ply = self:GetOwner()
	if Ply:IsPlayer() and (Ply:IsSprinting() and (Ply:GetAbsVelocity():LengthSqr() > 10000)) then return false end
	if (SP and SERVER) or (not SP and CLIENT and IFTP) then
		local ang = Ply:EyeAngles()
		ang.p = ang.p - self.RecoilMod * 0.5
		ang.y = ang.y + math.Rand(-1, 1) * self.RecoilMod * 0.5

		Ply:SetEyeAngles(ang)
	end
	Ply:ViewPunch(PunchAmt)
end

if CLIENT then
	local Black = Color(0, 0, 0)
	local White = Color(255, 255, 255)
	local Col = Color(127, 65, 65)
	local BGCol = Color(65, 65, 65)
	local ScreenBlack = Color(0, 0, 0, 255)

	local SX, SY = ScrW(), ScrH()
	local Scale = math.max(SX / 1920, 1)

	surface.CreateFont("SWEP-HUD-FONT", {
		font		= "Roboto",
		size		= math.ceil(13 * Scale),
		weight		= 500,
		extended	= true
	})

	function SWEP:DrawWorldModel()
		self:SetColor(White)
		if not self.CustomWorldModelPos then self:DrawModel() return end
		local owner = self:GetOwner()
		if not IsValid(owner) then self:DrawModel() return end
		local bone = owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if not bone then self:DrawModel() return end
		local vmat = owner:GetBoneMatrix(bone)
		if not vmat then self:DrawModel() return end

		local Pos, Ang = LocalToWorld(self.OffsetWorldModelPos, self.OffsetWorldModelAng, vmat:GetTranslation(), vmat:GetAngles())

		self:SetPos(Pos)
		self:SetAngles(Ang)
		self:SetupBones()
		self:DrawModel()
	end

	function SWEP:TranslateFOV(FOV)
		local Owner = self:GetOwner()
		local SelfTbl = self:GetTable()
		local Rate = math.Clamp(RealTime() - SelfTbl.RateTime, 0, 1)

		local InIrons = self:GetNWBool("iron", false) and not SelfTbl.Reloading and not (SelfTbl.TempOut or false)

		local SprintScale = SelfTbl.SprintScale * (1 - (Rate * 7)) + ((Owner:IsSprinting() and (Owner:GetAbsVelocity():LengthSqr() > 10000)) and 1 or 0) * (Rate * 7)

		local IronScale = SelfTbl.IronScale * (1 - (Rate * 5)) + (InIrons and (1 - SprintScale) or 0) * (Rate * 5)

		SelfTbl.RateTime = RealTime()
		local FinalIronScale = IronScale >= 0.75 and ((IronScale - 0.75) / 0.25) or 0

		SelfTbl.SprintScale = SprintScale
		SelfTbl.IronScale = IronScale

		return (FOV / (SelfTbl.Zoom or 1)) * FinalIronScale + (FOV * (1 - FinalIronScale))
	end

	function SWEP:AdjustMouseSensitivity()
		local Sens = 1
		local Zoomed = self:GetNWBool("iron", false) and not (self.TempOut or false)
		if self.Scope and Zoomed then Sens = (1 / (self.Zoom or 1)) * self.IronScale + (1 - self.IronScale) end
		if not Sens then Sens = 1 end
		if Sens == 1 then return nil end -- returning nil actually just leaves the player's default sensitivity
		return math.Clamp(Sens, 0.001, 1)
	end

	function SWEP:GetViewModelPosition(Pos, Ang)
		-- A * ( 1 - X ) + B * X
		local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
		local Mul = math.min(self.IronScale / 0.75, 1)

		local Owner = self:GetOwner()
		local ep = Owner:EyePos()

		local IronPos = self.IronSightPos
		local IronAng = self.IronSightAng

		if self.GetViewAim then
			local AimData = self:GetViewAim()
			IronPos = AimData.IronPos
			IronAng = AimData.IronAng
		end

		local SprintScale = self.SprintScale

		if SprintScale > 0.0001 then
			local SprintAng = self.SprintAng

			Ang:RotateAroundAxis(Right, SprintAng.x * SprintScale)
			Ang:RotateAroundAxis(Up, SprintAng.y * SprintScale)
			Ang:RotateAroundAxis(Forward, SprintAng.z * SprintScale)
		end

		if IronAng then
			Ang:RotateAroundAxis(Right, IronAng.x * Mul)
			Ang:RotateAroundAxis(Up, IronAng.y * Mul)
			Ang:RotateAroundAxis(Forward, IronAng.z * Mul)
		end

		local IdlePos	= (self.IdlePos and self.IdlePos or Vector())
		local ViewShift = (IronPos * Mul) + (IdlePos * (1 - Mul))
		Pos = Pos + (ViewShift.x * Right) + (ViewShift.y * Forward) + (ViewShift.z * Up)

		LastVMPos = ep
		return Pos, Ang
	end

	function SWEP:ShouldDrawViewModel()
		if self.Scope then
			return not (self:GetNWBool("iron", false) and (self.IronScale >= 0.75) and not (self.TempOut or false))
		else return true end
	end

	local SM = {x = SX / 2, y = SY / 2}
	--local UU = (SX > SY) and (SY / 12) or (SX / 12)
	function SWEP:DoDrawCrosshair(x, y)
		local AimMod = self:GetAimMod()
		local Spread = self.Spread
		local SpreadAmt = Spread * AimMod
		if self.CrosshairScale then SpreadAmt = math.max(self.CrosshairScale * AimMod, self.Spread) end
		local ViewSpread = Vector(100, 0, 0)
		ViewSpread:Rotate(Angle(SpreadAmt, 0, 0))
		ViewSpread:Rotate(EyeAngles())
		local Pos = EyePos() + ViewSpread
		local SPos = Pos:ToScreen()
		local SpreadSize = SPos.y - (ScrH() / 2)
		-- we just gonna cheat a little, project the weapons actual spread and get the distance from center, and draw from there

		surface.SetDrawColor(255, 255, 255)
		surface.DrawLine(x - SpreadSize, y, x - SpreadSize - 10, y)
		surface.DrawLine(x, y + SpreadSize, x, y + SpreadSize + 10)

		surface.SetDrawColor(0, 0, 0)
		surface.DrawLine(x + SpreadSize, y, x + SpreadSize + 10, y)
		surface.DrawLine(x, y - SpreadSize, x, y - SpreadSize - 10)

		return true
	end

	local KeyAttack = string.upper(input.LookupBinding("+attack", true))
	local KeyAltAttack = string.upper(input.LookupBinding("+attack2", true))
	local KeyUse = string.upper(input.LookupBinding("+use", true))

	function SWEP:BuildWepSelectionText()
		self.ControlText = {KeyAttack .. ": Shoot", KeyAltAttack .. ": Sights"}
		self.DisplayText = {}

		if self.FiremodeSetting ~= 1 then
			self.ControlText[#self.ControlText + 1] = KeyUse .. "+" .. KeyAltAttack .. ": Fire mode"
		end

		if self.Primary.ClipSize > 1 then
			self.DisplayText[#self.DisplayText + 1] = "Fire rate: " .. math.floor(60 / self.Primary.Delay) .. " RPM"
		end

		local PenText
		if self.Bullet.Type == "HEAT" then
			self.MeasuredPen = math.Round(AmmoTypes["HEAT"]:GetPenetration(self.Bullet, self.ACFHEATStandoff, ACF.SteelDensity), 1)
			PenText = self.MeasuredPen .. "mm @ All distances"
		else
			self.MeasuredPen = math.Round(AmmoTypes[self.ACFType]:GetRangedPenetration(self.Bullet, self.CalcDistance), 1)
			self.MeasuredPen2 = math.Round(AmmoTypes[self.ACFType]:GetRangedPenetration(self.Bullet, self.CalcDistance2), 1)
			PenText = self.CalcDistance .. "m: " .. self.MeasuredPen .. "mm/" .. self.CalcDistance2 .. "m: " .. self.MeasuredPen2 .. "mm"
		end

		self.DisplayText[#self.DisplayText + 1] = PenText

		self.DisplayText[#self.DisplayText + 1] = "Muzzle Velocity: " .. self.ACFMuzzleVel .. "m/s"
	end

	SWEP.FrameCount = 0 -- cheap way to control DPanel
	function SWEP:DrawWeaponSelection(x, y, w, h)
		draw.RoundedBox(8, x, y, w, h, Col)
		draw.RoundedBox(4, x + 8, y + 8, w - 16, h - 16, BGCol)
		surface.SetDrawColor(White)
		--self.DisplayText = nil
		if not self.DisplayText then self:BuildWepSelectionText() return end
		self.FrameCount = FrameNumber()

		if not self.Panel then
			local Panel = vgui.Create("DPanel")
			self.Panel = Panel
			Panel:SetPos(x, y + h / 2)
			Panel:SetSize(w, h / 2)
			Panel:SetAlpha(0)
			Panel.Think = function()
				if (FrameNumber() - 1) > self.FrameCount then self.Panel = nil Panel:Remove() end
			end

			local Icon = vgui.Create("DModelPanel", Panel)
			Icon:SetSize(w, w)
			Icon:Center()
			function Icon:LayoutEntity() return end
			Icon:SetModel(self.WorldModel)
			local E = Icon.Entity
			E:SetMaterial("models/wireframe")
			Icon:SetColor(Color(255 * 0.7, 255 * 0.66, 0))
			function Icon:PreDrawModel()
				render.SuppressEngineLighting(true)
			end

			Icon.Entity:SetPos(self.IconOffset)
			Icon.Entity:SetAngles(self.IconAngOffset)
			Icon:SetCamPos(Vector(0, 50, 0))
			Icon:SetLookAt(Vector())

			function Icon:PostDrawModel()
				render.SuppressEngineLighting(false)
			end
		end

		for I = 1, #self.DisplayText do
			draw.SimpleText(self.DisplayText[I], "HudSelectionText", x + (w / 2), y + h - 24 - 14 * I, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		for I = 1, #self.ControlText do
			draw.SimpleText(self.ControlText[I], "HudSelectionText", x + (w / 2), y - 4 + 14 * I, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end

	local Disable = {["CHudAmmo"] = true}
	function SWEP:HUDShouldDraw(e)
		if Disable[e] then return false else return true end
	end

	local FireModeAlias = {[1] = "A", [2] = "1"}

	local ScopeMat = Material("HUD/scope2.png", "nocull")

	local function DrawMagazine(x, y, s)
		-- Note for any future poor soul, for some reason matrices don't work with DrawPoly like you'd want them
		-- As of writing, DrawPoly individually clamps EACH AND EVERY VALUE to "stay on screen"
		-- So using a matrix to move the "center" will not result in what you want and cause MUCH frustration

		local c = surface.GetDrawColor()

		local poly = {
			{x = x, y = y - s * 0.1},
			{x = x, y = y - s},
			{x = x + s, y = y - s},
			{x = x + s, y = y + s * 0.05},
			{x = x + s * 0.5, y = y + s},
			{x = x - s * 0.45, y = y + s * 0.8}
		}

		local m = Matrix()
		local pos = Vector(x + s * 0.3, y + s * 0.05, 0)
		m:Translate(pos)
		m:Scale(Vector(1.21, 1.1, 0))
		m:Translate(-pos)

		surface.SetDrawColor(0, 0, 0)
		cam.PushModelMatrix(m)
			surface.DrawPoly(poly)
		cam.PopModelMatrix()

		surface.SetDrawColor(c.r, c.g, c.b)
		surface.DrawPoly(poly)
	end

	local function DrawRound(x, y, s)

		local c = surface.GetDrawColor()

		local poly = {
			{x = x - s * 0.25, y = y + s},
			{x = x - s * 0.25, y = y - s * 0.5},
			{x = x, y = y - s},
			{x = x + s * 0.26, y = y - s * 0.5},
			{x = x + s * 0.26, y = y + s}
		}

		local m = Matrix()
		local pos = Vector(x, y, 0)
		m:Translate(pos)
		m:Scale(Vector(1.4, 1.1, 0))
		m:Translate(-pos)

		surface.SetDrawColor(0, 0, 0)
		cam.PushModelMatrix(m)
			surface.DrawPoly(poly)
		cam.PopModelMatrix()

		surface.SetDrawColor(c.r, c.g, c.b)
		surface.DrawPoly(poly)
	end

	local function SetAmmoColor(perc)
		local c = Vector(255, 255, 255)
		if perc == 1 then
			return c:Unpack()
		elseif perc >= 0.5 then
			c = LerpVector((perc - 0.5) / 0.5, Vector(255, 255, 0), Vector(255, 255, 255))
			return c:Unpack()
		elseif perc > 0 then
			c = LerpVector(perc / 0.5, Vector(255, 0, 0), Vector(255, 255, 0))
			return c:Unpack()
		end

		return 0, 0, 0
	end

	function SWEP:DrawHUD()
		local SelfTbl = self:GetTable()
		local Ammo = self:Clip1()
		local SpareAmmo = self:Ammo1()
		local ClipSize = SelfTbl.Primary.ClipSize
		local AmmoPerc = Ammo / ClipSize
		local Size = 1400

		if (SelfTbl.IronScale >= 0.85) and (SelfTbl.Scope == true) and not SelfTbl.TempOut then
			local ShootPos = self:GetOwner():GetShootPos()
			local ShootAng = EyeAngles()
			local FWD = ShootAng:Forward()
			local UP = ShootAng:Up()
			local RGT = ShootAng:Right()
			if SelfTbl.HasDropCalc and (SelfTbl.CalcRun == true) then
				local Spot100 = (ShootPos + (FWD * 200 * 39.37) + (RGT * 200) + (UP * 72)):ToScreen()
				local Spot800 = (ShootPos + (FWD * 800 * 39.37) + (UP * 72)):ToScreen()

				surface.SetDrawColor(Black)

				for I = 1, 4 do
					local Mark = (ShootPos + (FWD * 200 * I * 39.37) + (RGT * 200 * (1 - ((I - 1) / 3))) + (UP * 72)):ToScreen()
					surface.DrawLine(Mark.x + (Size * 0.05), Mark.y, Mark.x + (Size * 0.05), Mark.y - 12)
					draw.SimpleTextOutlined((200 * I) .. "m", "SWEP-HUD-FONT", Mark.x + (Size * 0.05), Mark.y - 12, White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Black)
				end

				surface.DrawLine(Spot100.x + (Size * 0.05), Spot100.y, Spot800.x + (Size * 0.05), Spot800.y)
				surface.SetDrawColor(White)
				surface.DrawLine(Spot100.x + (Size * 0.05), Spot100.y + 1, Spot800.x + (Size * 0.05), Spot800.y + 1)

				local DropCalc = SelfTbl.DropCalc

				for I = 1, #DropCalc do
					local DD = DropCalc[I]
					local BPos = DD[1]
					local Pos = (ShootPos + (FWD * BPos.x) + (vector_up * BPos.z)):ToScreen()
					local LineScale = math.max((200 / DD[3]) * 12, 1)
					surface.SetDrawColor(Black)
					surface.DrawLine(Pos.x - Scale, Pos.y, Pos.x, Pos.y)
					surface.SetDrawColor(White)
					surface.DrawLine(Pos.x, Pos.y, Pos.x + LineScale, Pos.y)

					draw.SimpleTextOutlined(DD[3] .. "m, " .. math.Round(DD[2], 2) .. "s", "SWEP-HUD-FONT", Pos.x - 64, Pos.y, White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Black)
				end
			elseif SelfTbl.HasDropCalc and (SelfTbl.CalcRun == false) then
				SelfTbl.DropCalc = self:CalcDropTable()
			end
			surface.SetDrawColor(Black)
			surface.SetMaterial(ScopeMat)
			-- Scope box
			surface.DrawTexturedRect(SM.x - Size, SM.y - Size, Size * 2, Size * 2)
			-- Edge filler
			surface.DrawRect(0, SM.y + Size * 0.75, SX, SY)
			surface.DrawRect(0, SM.y - (Size * 0.75) - SY, SX, SY)

			surface.DrawRect(SM.x + Size * 0.75, 0, SX, SY)
			surface.DrawRect(SM.x - (Size * 0.75) - SX, 0, SX, SY)

			-- Side dashes
			surface.DrawRect(SM.x + (Size * 0.05), SM.y - 2, SM.x, 4)
			surface.DrawRect(SM.x - (Size * 0.05) - SM.x, SM.y - 2, SM.x, 4)

			draw.NoTexture()

			ScreenBlack.a = 255 * (1 - (SelfTbl.IronScale - 0.75) / 0.25)

			surface.SetDrawColor(ScreenBlack)
			surface.DrawRect(0, 0, SX, SY)
		end

		draw.NoTexture()
		local Mags = math.ceil(SpareAmmo / ClipSize)
		local DrawAmmo = DrawMagazine
		local AmmoScale = math.max(SX / 1920, 1)
		local AmmoSize = 16 * AmmoScale
		if ClipSize == 1 then
			DrawAmmo = DrawRound
			AmmoSize = 10 * AmmoScale
		else
			draw.SimpleTextOutlined(Ammo .. " / " .. ClipSize, "SWEP-HUD-FONT", SX - 12, SY - (48 * AmmoScale), White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Black)
		end

		if SelfTbl.FiremodeSetting ~= 1 then
			draw.SimpleTextOutlined(FireModeAlias[self:GetNWInt("firemode", 1)], "SWEP-HUD-FONT", SX - 16, SY - 4, White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Black)
		end

		draw.SimpleTextOutlined("AMMO TYPE: " .. SelfTbl.Primary.Ammo, "SWEP-HUD-FONT", SX - 40 + (SelfTbl.FiremodeSetting == 1 and 20 or 0), SY - 4, White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Black)

		surface.SetDrawColor(SetAmmoColor(AmmoPerc))
		DrawAmmo(SX - 24, SY - (32 * AmmoScale), 10 * AmmoScale)

		local LastAmmo = (Mags * ClipSize) - SpareAmmo
		for i = 1, math.min(9, Mags) do
			if (LastAmmo > 0) and (i == Mags) then surface.SetDrawColor(SetAmmoColor(1 - (LastAmmo / ClipSize))) else surface.SetDrawColor(255, 255, 255) end
			DrawAmmo(SX - 24 - (i * AmmoSize), SY - (32 * AmmoScale), 10 * AmmoScale)
		end

		if Mags > 9 then
			draw.SimpleTextOutlined((Mags - 9) .. "+", "SWEP-HUD-FONT", SX - (30 * AmmoScale) - (9 * AmmoSize), SY - (32 * AmmoScale), White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Black)
		end
	end
end
