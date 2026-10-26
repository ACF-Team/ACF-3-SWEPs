AddCSLuaFile()

local Category = "ACF-3 SWEPs"
local ContentType = "acf_swep"

-- The spawnmenu list entry is made from the weapon's own table before it inherits from the base, so give it the base's
hook.Add("PreRegisterSWEP", "ACF SWEPs List Entry", function(SWEP)
	if SWEP.Base ~= "weapon_acf_base" then return end

	SWEP.Category = SWEP.Category or Category
	SWEP.ScriptedEntityType = SWEP.ScriptedEntityType or ContentType
	SWEP.IconOverride = SWEP.IconOverride or "materials/vgui/entities/acf_logo.png"
end)

if CLIENT then
	local PANEL = {}
	function PANEL:OpenForPanel(Panel)
		local Height = Panel:GetTall() * 0.9

		self:SetPos(Panel:LocalToScreen(-((Panel:GetWide() * 2) + 2), (Panel:GetTall() / 2) - (Height / 2)))
		self:SetSize(Panel:GetWide() * 2, Height)
		self:SetDrawOnTop(true)

		self.SWEP = weapons.Get(Panel:GetSpawnName())
		self.SWEP:BuildWepSelectionText()

		local Name = self:Add("DLabel")
		Name:Dock(TOP)
		Name:SetText(self.SWEP.PrintName)
		Name:SetDark(true)
		Name:SetFont("ACF_Title")
		Name:DockMargin(4, 4, 0, 0)

		local Caliber = self:Add("DLabel")
		Caliber:SetContentAlignment(3)
		Caliber:SetPos(self:GetWide() - 64, 0)
		Caliber:SetText(("%smm "):format(self.SWEP.Caliber))
		Caliber:SetDark(true)
		Caliber:SetFont("ACF_Label")
		Caliber:DockMargin(4, 4, 0, -8)

		for _, V in ipairs(self.SWEP.DisplayText) do
			local Text = self:Add("DLabel")
			Text:Dock(TOP)
			Text:SetText(V)
			Text:SetDark(true)
			Text:SetFont("ACF_Label")
			Text:DockMargin(4, 4, 0, -8)
		end

		for I, V in ipairs(self.SWEP.ControlText) do
			local Text = self:Add("DLabel")
			Text:Dock(TOP)
			Text:SetText(V)
			Text:SetDark(true)
			Text:SetFont("ACF_Label")
			Text:DockMargin(4, I == 1 and 12 or 4, 0, -8)
		end

		-- Grow to fit everything, the controls don't fit in the spawnicon's height
		self:InvalidateLayout(true)

		local Bottom = 0
		for _, Child in ipairs(self:GetChildren()) do
			if Child:IsVisible() then Bottom = math.max(Bottom, Child:GetY() + Child:GetTall()) end
		end

		self:SetTall(math.max(self:GetTall(), Bottom + 8))
	end
	function PANEL:Close()
		self:Remove()
	end
	vgui.Register("ACF3.SWEPs.ViewWeaponInfo", PANEL, "DPanel")

	-- ContentIcon:Paint draws its Image with PaintAt, this lets a spawnicon stand in for it
	local function PaintSpawnIconAt(self, X, Y, W, H)
		self:SetPos(X, Y)
		self:SetSize(W, H)
		self:PaintManual()
	end

	-- Sandbox's weapon icon with the weapon's model as a spawnicon instead of an image, and our info panel as the tooltip
	spawnmenu.AddContentType(ContentType, function(Container, Obj)
		local Icon = spawnmenu.GetContentType("weapon")(Container, Obj)
		if not IsValid(Icon) then return end

		Icon:SetContentType(ContentType)
		Icon:SetTooltipDelay(0)
		Icon:SetTooltipPanelOverride("ACF3.SWEPs.ViewWeaponInfo")

		local SWEP = weapons.Get(Obj.spawnname)
		if SWEP and SWEP.WorldModel ~= "" then
			local SpawnIcon = Icon:Add("SpawnIcon")
			SpawnIcon:SetModel(SWEP.WorldModel)
			SpawnIcon:SetMouseInputEnabled(false) -- fallback to the parent
			SpawnIcon:SetPaintedManually(true)
			SpawnIcon.IsHovered = function() return Icon:IsHovered() end
			SpawnIcon.PaintAt = PaintSpawnIconAt

			Icon.Image:Remove()
			Icon.Image = SpawnIcon
		end

		local BasePaint = Icon.Paint
		function Icon:Paint(W, H)
			local SKIN = self:GetSkin()

			for _ = 1, 2 do
				SKIN.tex.Shadow(0, 0, W, H)
			end

			BasePaint(self, W, H)
		end

		-- Dragging the icon into a spawnlist copies it, keep the copy one of ours
		function Icon:Copy()
			return spawnmenu.CreateContentIcon(ContentType, self:GetParent(), {
				nicename = self.m_NiceName,
				spawnname = self:GetSpawnName(),
				material = self.m_MaterialName,
				admin = self:GetAdminOnly(),
			})
		end

		return Icon
	end)

	list.Set("ContentCategoryIcons", Category, "vgui/entities/acf_logo.png")

	-- Groups the category's icons under bold section headers on the main node, and mirrors each as its own
	-- child node, so a group can be browsed on its own instead of scrolling through the full list
	local Groups = {
		{"Assault Rifles", "icon16/gun.png"},
		{"Sniper Rifles", "icon16/find.png"},
		{"Machine Guns", "icon16/package.png"},
		{"Submachine Guns", "icon16/wand.png"},
		{"Pistols", "icon16/gun.png"},
		{"Shotguns", "icon16/bomb.png"},
		{"Anti Vehicle", "icon16/star.png"},
	}

	local function ItemsInGroup(GroupName)
		local Items = {}

		for ClassName, SWEP in pairs(list.Get("Weapon")) do
			if SWEP.Category == Category and SWEP.SubCategory == GroupName then
				Items[#Items + 1] = {ClassName = ClassName, SWEP = SWEP}
			end
		end

		table.sort(Items, function(A, B)
			return (A.SWEP.PrintName or A.ClassName) < (B.SWEP.PrintName or B.ClassName)
		end)

		return Items
	end

	local function BuildGroupedPanel(Content)
		local Panel = vgui.Create("DScrollPanel", Content)
		Panel:SetVisible(false)

		for _, Group in ipairs(Groups) do
			local GroupName = Group[1]
			local Items = ItemsInGroup(GroupName)
			if #Items > 0 then
				local Header = Panel:Add("DLabel")
				Header:Dock(TOP)
				Header:DockMargin(4, #Panel:GetChildren() == 1 and 4 or 12, 4, 4)
				Header:SetFont("ACF_Title")
				Header:SetTextColor(color_white)
				Header:SetText(GroupName)

				local Layout = Panel:Add("DIconLayout")
				Layout:Dock(TOP)
				Layout:SetSpaceX(4)
				Layout:SetSpaceY(4)

				for _, Item in ipairs(Items) do
					spawnmenu.CreateContentIcon(ContentType, Layout, {
						nicename = Item.SWEP.PrintName or Item.ClassName,
						spawnname = Item.ClassName,
						material = Item.SWEP.IconOverride or "materials/vgui/entities/acf_logo.png",
						admin = Item.SWEP.AdminOnly,
					})
				end
			end
		end

		return Panel
	end

	local function GroupCategoryContent(Content, Tree)
		local Root = Tree.Categories and Tree.Categories[Category]
		if not IsValid(Root) then return end

		function Root:DoPopulate()
			if IsValid(self.PropPanel) then return end

			self.PropPanel = BuildGroupedPanel(Content)
		end

		for _, Group in ipairs(Groups) do
			local GroupName = Group[1]
			local Node = Root:AddNode(GroupName, Group[2])

			function Node:DoPopulate()
				if IsValid(self.PropPanel) then return end

				self.PropPanel = vgui.Create("ContentContainer", Content)
				self.PropPanel:SetVisible(false)
				self.PropPanel:SetTriggerSpawnlistChange(false)

				for _, Item in ipairs(ItemsInGroup(GroupName)) do
					spawnmenu.CreateContentIcon(ContentType, self.PropPanel, {
						nicename = Item.SWEP.PrintName or Item.ClassName,
						spawnname = Item.ClassName,
						material = Item.SWEP.IconOverride or "materials/vgui/entities/acf_logo.png",
						admin = Item.SWEP.AdminOnly,
					})
				end
			end

			function Node:DoClick()
				self:DoPopulate()
				Content:SwitchPanel(self.PropPanel)
			end
		end
	end

	hook.Add("PopulateWeapons", "ACF SWEPs Category Headers", GroupCategoryContent)

	-- ACF sizes the flight model by caliber, which shrinks models like the crossbow bolt to nothing
	hook.Add("ACF_OnCreateBulletEffect", "ACF SWEPs Bullet Model Scale", function(Effect, BulletData)
		local Gun = BulletData.Crate
		if not IsValid(Gun) or not Gun:IsWeapon() or not Gun.BulletModel then return end

		Effect:SetModelScale(Gun.BulletScale or 1, 0)
	end)

	-- GMod's fallback DoD:S textures have no alpha, so these masked envmaps make the whole gun chrome
	local Chromed = {
		"models/weapons/v_models/30cal/v_30cal",
		"models/weapons/v_models/c96/v_c96",
		"models/weapons/v_models/k98_scoped/v_k98_scoped",
		"models/weapons/v_models/mg42/v_mg42",
		"models/weapons/v_models/springfield/v_springfield",
	}

	local function FixChrome()
		for _, Path in ipairs(Chromed) do
			local Mat = Material(Path)

			Mat:SetUndefined("$envmap")
			Mat:Recompute()
		end
	end

	-- Autorun is before the map loads, and loading it reloads these materials, so it's done again afterwards
	FixChrome()
	hook.Add("InitPostEntity", "ACF SWEPs Fix Chrome", FixChrome)
end

if SERVER then
	hook.Add("ACF_OnLoadPersistedData", "ACF SWEPs Workshop Content", function()
		if ACF.ServerData.WorkshopContent then
			resource.AddWorkshop("2923573966") -- ACF-3 SWEPs
		end
	end)

	-- Our bullets are lag compensated, so vehicles have to be rewound for them too
	-- Done once the baseplate entity is registered, which is after autorun
	hook.Add("Initialize", "ACF SWEPs Baseplate Lag Compensation", function()
		if ACF.SetBaseplateLagCompensation then ACF.SetBaseplateLagCompensation(true) end
	end)
end

do
	-- {name, sound, settings}, settings left out are CHAN_ITEM at full volume, level 75 and pitch 100
	local Shot = {channel = CHAN_WEAPON, level = 150, pitch = {98, 102}}
	local Draw = {channel = CHAN_BODY}
	local WorldReload = {volume = 0.76953125, level = 65}

	local Sounds = {
		{"Weapon_30cal.Shoot", "^30cal/30cal_shoot.wav", Shot},
		{"Weapon_30cal.BoltBack", "30cal/30cal_boltback.wav"},
		{"Weapon_30cal.BoltForward", "30cal/30cal_boltforward.wav"},
		{"Weapon_30cal.BulletChain1", "30cal/30cal_bulletchain1.wav"},
		{"Weapon_30cal.BulletChain2", "30cal/30cal_bulletchain2.wav"},
		{"Weapon_30cal.CoverUp", "30cal/30cal_coverup.wav"},
		{"Weapon_30cal.CoverDown", "30cal/30cal_coverdown.wav", {channel = CHAN_WEAPON}},
		{"Weapon_30cal.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_30cal.WorldReload", "30cal/30cal_worldreload.wav", WorldReload},

		{"Weapon_Bar.Shoot", "^bar/bar_shoot.wav", Shot},
		{"Weapon_Bar.BoltBack", "bar/bar_boltback.wav"},
		{"Weapon_Bar.BoltForward", "bar/bar_boltforward.wav"},
		{"Weapon_Bar.ClipIn1", "bar/bar_clipin1.wav"},
		{"Weapon_Bar.ClipIn2", "bar/bar_clipin2.wav"},
		{"Weapon_Bar.ClipOut", "bar/bar_clipout.wav"},
		{"Weapon_Bar.SelectorSwitch", "bar/bar_selectorswitch.wav"},
		{"Weapon_Bar.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Bar.WorldReload", "bar/bar_worldreload.wav", WorldReload},

		{"Weapon_Bazooka.Shoot", "^bazooka/rocket1.wav", Shot},
		{"Weapon_Bazooka.ClipIn", "bazooka/rocket_clipin.wav"},
		{"Weapon_Bazooka.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Bazooka.WorldReload", "bazooka/rocket_worldreload.wav", WorldReload},

		{"Weapon_Carbine.Shoot", "^m1carbine/m1carbine_shoot.wav", Shot},
		{"Weapon_Carbine.BoltBack", "m1carbine/m1carbine_boltback.wav"},
		{"Weapon_Carbine.BoltForward", "m1carbine/m1carbine_boltforward.wav"},
		{"Weapon_Carbine.ClipIn1", "m1carbine/m1carbine_clipin1.wav"},
		{"Weapon_Carbine.ClipIn2", "m1carbine/m1carbine_clipin2.wav"},
		{"Weapon_Carbine.ClipOut", "m1carbine/m1carbine_clipout.wav"},
		{"Weapon_Carbine.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Carbine.WorldReload", "m1carbine/m1carbine_worldreload.wav", WorldReload},

		{"Weapon_Colt.Shoot", "^colt/colt_shoot.wav", Shot},
		{"Weapon_Colt.ClipOut", "colt/colt_clipout.wav"},
		{"Weapon_Colt.ClipIn", "colt/colt_clipin.wav"},
		{"Weapon_Colt.BoltBack", "colt/colt_boltback.wav"},
		{"Weapon_Colt.BoltForward", "colt/colt_boltforward.wav"},
		{"Weapon_Colt.Draw", "general/draw_pistol.wav", Draw},
		{"Weapon_Colt.WorldReload", "colt/colt_worldreload.wav", WorldReload},

		{"Weapon_C96.Shoot", "^c96/c96_shoot.wav", Shot},
		{"Weapon_C96.ClipOut", "c96/c96_clipout.wav"},
		{"Weapon_C96.ClipIn1", "c96/c96_clipin1.wav"},
		{"Weapon_C96.ClipIn2", "c96/c96_clipin2.wav"},
		{"Weapon_C96.BoltBack", "c96/c96_boltback.wav"},
		{"Weapon_C96.BoltForward", "c96/c96_boltforward.wav"},
		{"Weapon_C96.Draw", "general/draw_pistol.wav", Draw},
		{"Weapon_C96.WorldReload", "c96/c96_worldreload.wav", WorldReload},

		-- SideWinderGrowl.wav by FrazierWing, CC0: https://freesound.org/people/FrazierWing/sounds/569666/
		{"Weapon_FIM92.Seeker", "weapons/fim92/seeker_growl.wav", {channel = CHAN_STATIC, volume = 0.5, level = 60}},
		-- Vanilla-Styled FIM-92 Stinger by Rocks: https://steamcommunity.com/sharedfiles/filedetails/?id=3807683332
		{"Weapon_FIM92.Shoot", "^acf_missiles/missiles/missile_rocket.mp3", Shot},
		{"Weapon_FIM92.Deploy", "weapons/fim92/deploy.wav", Draw},
		{"Weapon_FIM92.ShellIn", "bazooka/rocket_clipin.wav"},

		{"Weapon_Garand.Shoot", "^garand/garand_shoot.wav", Shot},
		{"Weapon_Garand.ClipIn1", "garand/garand_clipin1.wav"},
		{"Weapon_Garand.ClipIn2", "garand/garand_clipin2.wav"},
		{"Weapon_Garand.ClipDing", "garand/garand_clipding.wav", {channel = CHAN_STATIC}},
		{"Weapon_Garand.BoltForward", "garand/garand_boltforward.wav"},
		{"Weapon_Garand.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Garand.WorldReload", "garand/garand_worldreload.wav", WorldReload},

		{"Weapon_Kar.Shoot", "^k98/k98_shoot.wav", Shot},
		{"Weapon_KarScoped.Shoot", "^k98/k98scoped_shoot.wav", Shot},
		{"Weapon_K98.BoltBack1", "k98/k98_boltback1.wav"},
		{"Weapon_K98.BoltBack2", "k98/k98_boltback2.wav"},
		{"Weapon_K98.BoltForward1", "k98/k98_boltforward1.wav"},
		{"Weapon_K98.BoltForward2", "k98/k98_boltforward2.wav"},
		{"Weapon_K98.ClipIn", "k98/k98_clipin.wav"},
		{"Weapon_K98.ClipIn2", "k98/k98_clipin2.wav", {volume = 0.5}},
		{"Weapon_K98.ClipOut", "k98/k98_clipout.wav", {channel = CHAN_STATIC}},
		{"Weapon_K98.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_K98.SingleShotReload", "k98/k98_singleshotreload.wav", WorldReload},
		{"Weapon_K98.WorldReload", "k98/k98_worldreload.wav", WorldReload},

		{"Weapon_Luger.Shoot", "^p38/p38_shoot.wav", Shot},
		{"Weapon_Luger.ClipIn", "p38/p38_clipin.wav"},
		{"Weapon_Luger.ClipOut", "p38/p38_clipout.wav"},
		{"Weapon_Luger.BoltBack", "p38/p38_boltback.wav"},
		{"Weapon_Luger.BoltForward", "p38/p38_boltforward.wav"},
		{"Weapon_Luger.Draw", "general/draw_pistol.wav", Draw},
		{"Weapon_Luger.WorldReload", "p38/p38_worldreload.wav", WorldReload},

		{"Weapon_Mg42.Shoot", "^mg42/mg42_shoot.wav", Shot},
		{"Weapon_Mg42.OverHeat", "mg42/mg42_overheat.wav", {channel = CHAN_STATIC}},
		{"Weapon_Mg42.CoverUp", "mg42/mg42_coverup.wav"},
		{"Weapon_Mg42.CoverDown", "mg42/mg42_coverdown.wav"},
		{"Weapon_Mg42.BulletChain1", "mg42/mg42_bulletchain1.wav", {channel = CHAN_STATIC}},
		{"Weapon_Mg42.BulletChain2", "mg42/mg42_bulletchain2.wav", {channel = CHAN_STATIC}},
		{"Weapon_Mg42.BoltBack", "mg42/mg42_boltback.wav"},
		{"Weapon_Mg42.BoltForward", "mg42/mg42_boltforward.wav"},
		{"Weapon_Mg42.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Mg42.DeployBipod", "mg42/mg42_deploybipod.wav", {channel = CHAN_WEAPON}},
		{"Weapon_Mg42.RaiseBipod", "mg42/mg42_raisebipod.wav", {channel = CHAN_WEAPON}},
		{"Weapon_Mg42.WorldReload", "mg42/mg42_worldreload.wav", WorldReload},

		{"Weapon_Mp40.Shoot", "^mp40/mp40_shoot.wav", Shot},
		{"Weapon_Mp40.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Mp40.BoltBack", "mp40/mp40_boltback.wav"},
		{"Weapon_Mp40.ClipIn", "mp40/mp40_clipin.wav"},
		{"Weapon_Mp40.ClipOut", "mp40/mp40_clipout.wav"},
		{"Weapon_Mp40.BoltForward", "mp40/mp40_boltforward.wav"},
		{"Weapon_Mp40.WorldReload", "mp40/mp40_worldreload.wav", WorldReload},

		{"Weapon_Mp44.Shoot", "^mp44/mp44_shoot.wav", Shot},
		{"Weapon_Mp44.BoltBack", "mp44/mp44_boltback.wav"},
		{"Weapon_Mp44.BoltForward", "mp44/mp44_boltforward.wav"},
		{"Weapon_Mp44.ClipIn1", "mp44/mp44_clipin1.wav"},
		{"Weapon_Mp44.ClipIn2", "mp44/mp44_clipin2.wav"},
		{"Weapon_Mp44.ClipOut", "mp44/mp44_clipout.wav"},
		{"Weapon_Mp44.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Mp44.WorldReload", "mp44/mp44_worldreload.wav", WorldReload},
		{"Weapon_Mp44.SelectorSwitch", "mp44/mp44_selectorswitch.wav"},

		{"Weapon_Panzerschreck.Shoot", "^bazooka/rocket1.wav", Shot},
		{"Weapon_Panzerschreck.ClipIn", "bazooka/rocket_clipin.wav"},
		{"Weapon_Panzerschreck.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Panzerschreck.WorldReload", "bazooka/rocket_worldreload.wav", WorldReload},

		{"Weapon_Springfield.Shoot", "^springfield/spring_shoot.wav", Shot},
		{"Weapon_Springfield.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Springfield.SingleShotReload", "k98/k98_singleshotreload.wav", {volume = 0.76953125}},
		{"Weapon_Springfield.WorldReload", "k98/k98_worldreload.wav", WorldReload},

		{"Weapon_Thompson.Shoot", "^thompson/thompson_shoot.wav", Shot},
		{"Weapon_Thompson.ClipIn", "thompson/thompson_clipin.wav"},
		{"Weapon_Thompson.ClipOut", "thompson/thompson_clipout.wav"},
		{"Weapon_Thompson.BoltBack", "thompson/thompson_boltback.wav"},
		{"Weapon_Thompson.BoltForward", "thompson/thompson_boltforward.wav"},
		{"Weapon_Thompson.Draw", "general/draw_rifle.wav", Draw},
		{"Weapon_Thompson.WorldReload", "thompson/thompson_worldreload.wav", WorldReload},
	}

	for _, Entry in ipairs(Sounds) do
		local Settings = Entry[3] or {}

		sound.Add({
			name = Entry[1],
			sound = Entry[2],
			channel = Settings.channel or CHAN_ITEM,
			volume = Settings.volume or 1,
			level = Settings.level or 75,
			pitch = Settings.pitch or 100,
		})
	end
end

CreateConVar("acf_sweps_speed_mult", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Movespeed modifier for ACF SWEPs (true/false)", 0, 1)

print("ACF-3 SWEPs ready!")
