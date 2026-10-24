-- Viewmodel, world model, zoom and view kick

local White = Color(255, 255, 255)

-- Cosmetic, client only effects of a shot: queued view kick, viewmodel kick and muzzle light
function SWEP:ShotEffects()
	-- Queued here, applied over the next few frames in SWEP:HandleRecoil
	self.PendingPitch = (self.PendingPitch or 0) - self.KickUp * self.RecoilMod
	self.PendingYaw = (self.PendingYaw or 0) + math.Rand(-1, 1) * self.KickHorizontal * self.RecoilMod
	self.VMKick = (self.VMKick or 0) + self.KickBack * self.RecoilMod
end

-- Spreads the queued view kick over a few frames instead of snapping the camera
function SWEP:HandleRecoil(Cmd)
	local Pitch, Yaw = self.PendingPitch or 0, self.PendingYaw or 0
	if Pitch == 0 and Yaw == 0 then return end

	local Decay = math.exp(-self.KickSpeed * FrameTime())
	local DeltaP, DeltaY = Pitch * (1 - Decay), Yaw * (1 - Decay)

	if math.abs(Pitch) < 0.001 and math.abs(Yaw) < 0.001 then
		DeltaP, DeltaY = Pitch, Yaw
		self.PendingPitch, self.PendingYaw = 0, 0
	else
		self.PendingPitch, self.PendingYaw = Pitch - DeltaP, Yaw - DeltaY
	end

	local Ang = Cmd:GetViewAngles()
	Ang.p = Ang.p + DeltaP
	Ang.y = Ang.y + DeltaY
	Cmd:SetViewAngles(Ang)
end

-- Once a frame, even with the HUD hidden, and the kick goes into the command the server gets
hook.Add("CreateMove", "ACF SWEPs Recoil", function(Cmd)
	local Weapon = LocalPlayer():GetActiveWeapon()
	if not IsValid(Weapon) or not Weapon.HandleRecoil then return end

	Weapon:HandleRecoil(Cmd)
end)

function SWEP:PlaceWorldModel()
	if not self.CustomWorldModelPos then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local bone = owner:LookupBone("ValveBiped.Bip01_R_Hand")
	if not bone then return end
	local vmat = owner:GetBoneMatrix(bone)
	if not vmat then return end

	local Pos, Ang = LocalToWorld(self.OffsetWorldModelPos, self.OffsetWorldModelAng, vmat:GetTranslation(), vmat:GetAngles())

	self:SetPos(Pos)
	self:SetAngles(Ang)
	self:SetupBones()
end

function SWEP:DrawWorldModel()
	self:PlaceWorldModel()

	-- The networked color is the tracer color ACF reads from the gun, so only draw white and put it back afterwards
	local TracerCol = self:GetColor()
	self:SetColor(White)
	self:DrawModel()
	self:SetColor(TracerCol)
end

function SWEP:TranslateFOV(FOV)
	local Owner = self:GetOwner()
	local SelfTbl = self:GetTable()
	local Delta = math.Clamp(RealTime() - SelfTbl.RateTime, 0, 0.1)

	local InIrons = self:IsAiming() and not self:GetReloading() and not self:IsScopeBlinking()

	local Sprinting = Owner:IsSprinting() and (Owner:GetAbsVelocity():LengthSqr() > 10000)
	local SprintScale = math.Approach(SelfTbl.SprintScale, Sprinting and 1 or 0, Delta * 7)

	local IronScale = math.Approach(SelfTbl.IronScale, InIrons and (1 - SprintScale) or 0, Delta / SelfTbl.IronTime)

	SelfTbl.RateTime = RealTime()
	local FinalIronScale = IronScale >= 0.75 and ((IronScale - 0.75) / 0.25) or 0

	SelfTbl.SprintScale = SprintScale
	SelfTbl.IronScale = IronScale

	return (FOV / (SelfTbl.Zoom or 1)) * FinalIronScale + (FOV * (1 - FinalIronScale))
end

function SWEP:AdjustMouseSensitivity()
	local Sens = 1
	local Zoomed = self:IsAiming() and not self:IsScopeBlinking()
	if self.Scope and Zoomed then Sens = (1 / (self.Zoom or 1)) * self.IronScale + (1 - self.IronScale) end
	if not Sens then Sens = 1 end
	if Sens == 1 then return nil end -- returning nil actually just leaves the player's default sensitivity
	return math.Clamp(Sens, 0.001, 1)
end

function SWEP:GetViewModelPosition(Pos, Ang)
	-- A * ( 1 - X ) + B * X
	local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
	local Mul = math.ease.InOutQuad(math.min(self.IronScale / 0.75, 1))

	local IronPos = self.IronSightPos
	local IronAng = self.IronSightAng

	local AimSetting = self:GetAimSettingData()
	if AimSetting then
		IronPos = AimSetting.IronPos
		IronAng = AimSetting.IronAng
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

	-- The engine reads these every frame, so the sights stay steady while strafing
	local Steady = Mul * (1 - self.SprintScale)
	self.SwayScale = Lerp(Steady, 1, 0.05)
	self.BobScale = Lerp(Steady, 1, 0.05)

	-- Push the viewmodel back on firing, easing out
	local Kick = self.VMKick or 0
	if Kick > 0.001 then
		Pos = Pos - Forward * Kick * (1 - Mul * 0.5)
		self.VMKick = Kick * math.exp(-self.KickBackSpeed * FrameTime())
	end

	local IdlePos	= (self.IdlePos and self.IdlePos or Vector())
	local ViewShift = (IronPos * Mul) + (IdlePos * (1 - Mul))
	Pos = Pos + (ViewShift.x * Right) + (ViewShift.y * Forward) + (ViewShift.z * Up)

	return Pos, Ang
end

function SWEP:ShouldDrawViewModel()
	if self.Scope then
		return not (self:IsAiming() and (self.IronScale >= 0.75) and not self:IsScopeBlinking())
	else return true end
end
