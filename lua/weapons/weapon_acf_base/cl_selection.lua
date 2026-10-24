-- Weapon selection box, its info text is also used by the spawnmenu tooltip

local Adapter = include("acf_sweps/acf_adapter.lua")

local White = Color(255, 255, 255)
local Col = Color(127, 65, 65)
local BGCol = Color(65, 65, 65)

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

function SWEP:DrawWeaponSelection(x, y, w, h)
	draw.RoundedBox(8, x, y, w, h, Col)
	draw.RoundedBox(4, x + 8, y + 8, w - 16, h - 16, BGCol)

	if not self.DisplayText then self:BuildWepSelectionText() end

	for I = 1, #self.DisplayText do
		draw.SimpleText(self.DisplayText[I], "HudSelectionText", x + (w / 2), y + h - 24 - 14 * I, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	for I = 1, #self.ControlText do
		draw.SimpleText(self.ControlText[I], "HudSelectionText", x + (w / 2), y - 4 + 14 * I, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end
