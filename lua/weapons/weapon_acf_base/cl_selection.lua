-- Weapon selection icon, and the info text for the spawnmenu tooltip

local Adapter = include("acf_sweps/acf_adapter.lua")

local IconCol = Color(255, 220, 0) -- HL2's selection yellow

local IconW, IconH = 512, 256
local IconPad = 24 -- room around the model for the glow
local GlowRings, GlowStep, GlowStrength = 6, 3, 0.14

local FillMat = CreateMaterial("acf_sweps_icon_fill", "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$model"] = 1,
})

local Icons = {}

local function KeyName(Binding)
	local Key = input.LookupBinding(Binding, true)

	return Key and string.upper(Key) or Binding
end

function SWEP:GetPenetrationText()
	local Bullet = self:GetBullet()

	if Bullet.Type == "HEAT" then
		return math.Round(Adapter.GetPenetration(Bullet), 1) .. "mm @ All distances"
	end

	local Near = math.Round(Adapter.GetPenetration(Bullet, self.CalcDistance), 1)
	local Far = math.Round(Adapter.GetPenetration(Bullet, self.CalcDistance2), 1)

	return self.CalcDistance .. "m: " .. Near .. "mm/" .. self.CalcDistance2 .. "m: " .. Far .. "mm"
end

function SWEP:BuildWepSelectionText()
	local Attack, AltAttack = KeyName("+attack"), KeyName("+attack2")

	self.ControlText = {Attack .. ": Shoot", AltAttack .. ": Sights"}
	self.DisplayText = {}

	if self.FiremodeSetting ~= 1 then
		self.ControlText[#self.ControlText + 1] = KeyName("+use") .. "+" .. AltAttack .. ": Fire mode"
	end

	if self.Primary.ClipSize > 1 then
		self.DisplayText[#self.DisplayText + 1] = "Fire rate: " .. math.floor(60 / self.Primary.Delay) .. " RPM"
	end

	self.DisplayText[#self.DisplayText + 1] = self:GetPenetrationText()
	self.DisplayText[#self.DisplayText + 1] = "Muzzle Velocity: " .. self.ACFMuzzleVel .. "m/s"
end

-- Renders the world model side on as a flat white silhouette, the same way HL2's icons look
local function RenderSilhouette(RT, Ent, Origin, Ang, Half)
	render.PushRenderTarget(RT)
	render.Clear(0, 0, 0, 255, true, true)

	cam.Start({
		type = "3D",
		origin = Origin,
		angles = Ang,
		x = 0, y = 0, w = IconW, h = IconH,
		znear = 1, zfar = 4096,
		ortho = {left = -Half.x, right = Half.x, top = -Half.y, bottom = Half.y},
	})
		render.SuppressEngineLighting(true)
		render.MaterialOverride(FillMat)
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)

		Ent:DrawModel()

		render.MaterialOverride()
		render.SuppressEngineLighting(false)
	cam.End3D()

	render.PopRenderTarget()
end

local function IconMaterial(Name, RT)
	local Mat = CreateMaterial(Name, "UnlitGeneric", {
		["$basetexture"] = RT:GetName(),
		["$additive"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
	})

	Mat:SetTexture("$basetexture", RT)

	return Mat
end

local function BuildIcon(SWEP)
	local Model = SWEP.WorldModel
	if not Model or Model == "" or not file.Exists(Model, "GAME") then return false end

	local Ent = ClientsideModel(Model, RENDERGROUP_OPAQUE)
	if not IsValid(Ent) then return false end

	local ModelAng = SWEP.IconAngOffset or Angle()

	Ent:SetNoDraw(true)
	Ent:SetPos(vector_origin)
	Ent:SetAngles(ModelAng)
	Ent:SetupBones()

	-- Looking at the model's side, so its X is across the icon and its Z is up
	local CamAng = Angle(0, 90, 0)
	local Right, Up = CamAng:Right(), CamAng:Up()
	local Forward = CamAng:Forward()
	local Mins, Maxs = Ent:GetModelRenderBounds()
	local MinX, MaxX, MinY, MaxY = math.huge, -math.huge, math.huge, -math.huge
	local Depth = 0

	for I = 0, 7 do
		local Corner = Vector(bit.band(I, 1) > 0 and Maxs.x or Mins.x, bit.band(I, 2) > 0 and Maxs.y or Mins.y, bit.band(I, 4) > 0 and Maxs.z or Mins.z)
		Corner:Rotate(ModelAng)

		local CX, CY = Corner:Dot(Right), Corner:Dot(Up)
		MinX, MaxX = math.min(MinX, CX), math.max(MaxX, CX)
		MinY, MaxY = math.min(MinY, CY), math.max(MaxY, CY)
		Depth = Depth + Corner:Dot(Forward) / 8
	end

	local Scale, Half, Mid, Origin

	local function Frame()
		Scale = math.max((MaxX - MinX) / (IconW - IconPad * 2), (MaxY - MinY) / (IconH - IconPad * 2))
		Half = Vector(IconW * Scale * 0.5, IconH * Scale * 0.5)
		Mid = Right * ((MinX + MaxX) * 0.5) + Up * ((MinY + MaxY) * 0.5)
		Origin = Mid + Forward * (Depth - 1024)
	end

	local Name = "acf_sweps_icon_" .. SWEP.ClassName
	local Flags = bit.bor(4, 8, 256, 512) -- clamp, no mips, no lod
	local Sharp = GetRenderTargetEx(Name, IconW, IconH, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_SEPARATE, Flags, 0, IMAGE_FORMAT_RGB888)
	local Glow = GetRenderTargetEx(Name .. "_glow", IconW, IconH, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_SEPARATE, Flags, 0, IMAGE_FORMAT_RGB888)

	-- The render bounds on CS:S models have a lot of empty space, so the first render is only to find where the gun actually is
	Frame()
	RenderSilhouette(Sharp, Ent, Origin, CamAng, Half)

	render.PushRenderTarget(Sharp)
	render.CapturePixels()

	local PxMinX, PxMaxX, PxMinY, PxMaxY = math.huge, -math.huge, math.huge, -math.huge
	for PX = 0, IconW - 1, 2 do
		for PY = 0, IconH - 1, 2 do
			if render.ReadPixel(PX, PY) > 127 then
				PxMinX, PxMaxX = math.min(PxMinX, PX), math.max(PxMaxX, PX)
				PxMinY, PxMaxY = math.min(PxMinY, PY), math.max(PxMaxY, PY)
			end
		end
	end

	render.PopRenderTarget()

	if PxMinX <= PxMaxX then
		local CenterX, CenterY = Mid:Dot(Right), Mid:Dot(Up)

		MinX, MaxX = CenterX + (PxMinX - 2 - IconW * 0.5) * Scale, CenterX + (PxMaxX + 2 - IconW * 0.5) * Scale
		MinY, MaxY = CenterY - (PxMaxY + 2 - IconH * 0.5) * Scale, CenterY - (PxMinY - 2 - IconH * 0.5) * Scale

		Frame()
		RenderSilhouette(Sharp, Ent, Origin, CamAng, Half)
	end

	Ent:Remove()

	local SharpMat = IconMaterial(Name, Sharp)

	-- render.BlurRenderTarget goes through the shared framebuffer copies and picks up whatever's on screen,
	-- so the glow is the silhouette stamped around itself instead
	render.PushRenderTarget(Glow)
	render.Clear(0, 0, 0, 255, true, true)
	cam.Start2D()
		surface.SetMaterial(SharpMat)

		for Ring = 1, GlowRings do
			local Radius = Ring * GlowStep
			local Bright = 255 * GlowStrength * (1 - (Ring - 1) / GlowRings)

			surface.SetDrawColor(Bright, Bright, Bright, 255)

			for Step = 0, 11 do
				local Rad = math.rad(Step * 30)
				surface.DrawTexturedRect(math.cos(Rad) * Radius, math.sin(Rad) * Radius, IconW, IconH)
			end
		end
	cam.End2D()
	render.PopRenderTarget()

	return {
		Sharp = SharpMat,
		Glow = IconMaterial(Name .. "_glow", Glow),
	}
end

function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	alpha = alpha or 255

	local Class = self.ClassName
	if Icons[Class] == nil then Icons[Class] = BuildIcon(self) end

	local Icon = Icons[Class]
	if Icon then
		-- Fit the icon above the weapon's name, which HL2 draws at the bottom of the box
		local AreaW, AreaH = w - 8, h - 24
		local DrawW = math.min(AreaW, AreaH * (IconW / IconH))
		local DrawH = DrawW * (IconH / IconW)
		local DrawX, DrawY = x + (w - DrawW) * 0.5, y + 4 + (AreaH - DrawH) * 0.5

		surface.SetDrawColor(IconCol.r, IconCol.g, IconCol.b, alpha)
		surface.SetMaterial(Icon.Glow)
		surface.DrawTexturedRect(DrawX, DrawY, DrawW, DrawH)
		surface.DrawTexturedRect(DrawX, DrawY, DrawW, DrawH)
		surface.SetMaterial(Icon.Sharp)
		surface.DrawTexturedRect(DrawX, DrawY, DrawW, DrawH)
	end
end
