-- Crosshair, scope and ammo counter

local Black = Color(0, 0, 0)
local White = Color(255, 255, 255)
local ScreenBlack = Color(0, 0, 0, 255)

local SX, SY = ScrW(), ScrH()
local Scale = math.max(SX / 1920, 1)

surface.CreateFont("SWEP-HUD-FONT", {
	font		= "Roboto",
	size		= math.ceil(13 * Scale),
	weight		= 500,
	extended	= true
})

local SM = {x = SX / 2, y = SY / 2}
--local UU = (SX > SY) and (SY / 12) or (SX / 12)
function SWEP:DoDrawCrosshair(x, y)
	local AimMod = self:GetCrosshairAimMod()
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

local Disable = {["CHudAmmo"] = true}
function SWEP:HUDShouldDraw(e)
	if Disable[e] then return false else return true end
end

local FireModeAlias = {[1] = "A", [2] = "1", [3] = "3"}

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

	if (SelfTbl.IronScale >= 0.85) and (SelfTbl.Scope == true) and not self:IsScopeBlinking() then
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
		draw.SimpleTextOutlined(FireModeAlias[self:GetFireMode()], "SWEP-HUD-FONT", SX - 16, SY - 4, White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Black)
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
