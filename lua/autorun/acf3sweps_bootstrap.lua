AddCSLuaFile()

if CLIENT then
    -- This is such a hack...
    -- I tried using AddContentType but NOTHING wanted to work.
    -- So screw it, I have to play dirty here to get what I'm trying to achieve.

    local PANEL = {}
    function PANEL:OpenForPanel(Panel)
        local Height = Panel:GetTall() * 0.9

        self:SetPos(Panel:LocalToScreen(-((Panel:GetWide() * 2) + 2), (Panel:GetTall() / 2) - (Height / 2)))
        self:SetSize(Panel:GetWide() * 2, Height)
        self:SetDrawOnTop(true)

        self.SWEP = weapons.GetStored(Panel.WeaponClassName)
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
    end
    function PANEL:Close()
        self:Remove()
    end
    vgui.Register("ACF3.SWEPs.ViewWeaponInfo", PANEL, "DPanel")

    local Category = "ACF-3 SWEPs"
    local matOverlay_Normal = Material("gui/ContentIcon-normal.png")
    local matOverlay_Hovered = Material("gui/ContentIcon-hovered.png")

    -- Annoying how much source code I have to copy from base gmod to pull this off...
    local shadowColor = Color(0, 0, 0, 200)
    local function DrawTextShadow(text, x, y)
        draw.SimpleText(text, "DermaDefault", x + 1, y + 1, shadowColor)
        draw.SimpleText(text, "DermaDefault", x, y, color_white)
    end
    local function DrawWeaponIcon(self, w, h)
        local SWEP = weapons.GetStored(self.WeaponClassName)
        local SKIN = self:GetSkin()

        for _ = 1, 2 do
            SKIN.tex.Shadow(0, 0, w, h)
        end

        if not IsValid(self.SpawnIcon) then
            self.SpawnIcon = self:Add("SpawnIcon")
            self.SpawnIcon:SetModel(SWEP.WorldModel)
            self.SpawnIcon:SetWide(self:GetWide())
            self.SpawnIcon:SetTall(self:GetTall())
            self.SpawnIcon:SetMouseInputEnabled(false) -- fallback to the parent
            self.SpawnIcon.IsHovered = function() return self:IsHovered() end
            self.SpawnIcon:SetPaintedManually(true)
        end

        if self.Depressed and not self.Dragging then
            if self.Border ~= 8 then
                self.Border = 8
                self:OnDepressionChanged(true)
            end
        else
            if self.Border ~= 0 then
                self.Border = 0
                self:OnDepressionChanged(false)
            end
        end

        self.SpawnIcon:PaintManual()

        surface.SetDrawColor(255, 255, 255, 255)

        local drawText = false
        if not dragndrop.IsDragging() and (self:IsHovered() or self.Depressed or self:IsChildHovered()) then
            surface.SetMaterial(matOverlay_Hovered)
        else
            surface.SetMaterial(matOverlay_Normal)
            drawText = true
        end

        surface.DrawTexturedRect(self.Border, self.Border, w - self.Border * 2, h - self.Border * 2)

        if drawText then
            local buffere = self.Border + 10

            -- Set up smaller clipping so cut text looks nicer
            local px, py = self:LocalToScreen(buffere, 0)
            local pw, ph = self:LocalToScreen(w - buffere, h)
            render.SetScissorRect(px, py, pw, ph, true)

            -- Calculate X pos
            surface.SetFont("DermaDefault")
            local tW, tH = surface.GetTextSize(self.m_NiceName)

            local x = w / 2 - tW / 2
            if tW > (w - buffere * 2) then
                local mx, _ = self:ScreenToLocal(input.GetCursorPos())
                local diff = tW - w + buffere * 2

                x = buffere + math.Remap(math.Clamp(mx, 0, w), 0, w, 0, -diff)
            end

            -- Draw
            DrawTextShadow(self.m_NiceName, x, h - tH - 9)
            render.SetScissorRect(0, 0, 0, 0, false)
        end
    end

    local function AddWeaponToCategory(PropPanel, Weapon)
        local WeaponIcon = spawnmenu.CreateContentIcon(Weapon.ScriptedEntityType or "weapon", PropPanel, {
            nicename	= Weapon.PrintName or Weapon.ClassName,
            spawnname	= Weapon.ClassName,
            material	= Weapon.IconOverride or ("entities/" .. Weapon.ClassName .. ".png"),
            admin		= Weapon.AdminOnly
        })

        WeaponIcon.WeaponClassName = Weapon.ClassName
        WeaponIcon:SetTooltipDelay(0)
        WeaponIcon:SetTooltipPanelOverride("ACF3.SWEPs.ViewWeaponInfo")
        function WeaponIcon:Paint(w, h)
            DrawWeaponIcon(self, w, h)
        end
        local Think = WeaponIcon.Think
        function WeaponIcon:Think()
            if Think then Think(self) end
            if IsValid(self.SpawnIcon) then
                self.SpawnIcon:SetPos(3 + self.Border, 3 + self.Border)
                self.SpawnIcon:SetSize(128 - 8 - self.Border * 2, 128 - 8 - self.Border * 2)
            end
        end
        return WeaponIcon
    end

    local function BuildWeaponCategories()
        local weapons = list.Get("Weapon")
        local Categorised = {}

        -- Build into categories
        for _, weapon in pairs(weapons) do
            if not weapon.Spawnable then continue end

            local Category = language.GetPhrase(weapon.Category ~= "Other" and weapon.Category or "#spawnmenu.category.other")
            if not isstring(Category) then Category = tostring(Category) end

            Categorised[Category] = Categorised[Category] or {}
            table.insert(Categorised[Category], weapon)
        end

        return Categorised
    end

    local function AddACF3Sweps(tree, cat)
        -- Add a node to the tree
        local node = tree:AddNode(cat, "vgui/entities/acf_logo.png")
        tree.Categories[cat] = node

        -- When we click on the node - populate it using this function
        node.DoPopulate = function(self)

            -- If we've already populated it - forget it.
            if IsValid(self.PropPanel) then return end

            -- Create the container panel
            self.PropPanel = vgui.Create("ContentContainer", tree.pnlContent)
            self.PropPanel:SetVisible(false)
            self.PropPanel:SetTriggerSpawnlistChange(false)

            local weps = BuildWeaponCategories()[cat]
            if not weps then return end -- May no longer have any weapons due to autorefresh

            for _, ent in SortedPairsByMemberValue( weps, "PrintName" ) do
                AddWeaponToCategory( self.PropPanel, ent )
            end

        end

        -- If we click on the node populate it and switch to it.
        node.DoClick = function(self)
            self:DoPopulate()
            tree.pnlContent:SwitchPanel(self.PropPanel)
        end

        node.OnRemove = function(self)
            if IsValid(self.PropPanel) then self.PropPanel:Remove() end
        end

        return node
    end

    ORIGINAL_GMOD_POPULATEWEAPONS = ORIGINAL_GMOD_POPULATEWEAPONS or hook.GetTable().PopulateWeapons.AddWeaponContent

    local BuildWeaponCategoriesName, BuildWeaponCategories = debug.getupvalue(ORIGINAL_GMOD_POPULATEWEAPONS, 1)
    if BuildWeaponCategoriesName ~= "BuildWeaponCategories" then error("Garry's Mod moved upvalue #1, please fix (got " .. BuildWeaponCategoriesName .. ")") end

    local AddCategoryName, AddCategory = debug.getupvalue(ORIGINAL_GMOD_POPULATEWEAPONS, 2)
    if AddCategoryName ~= "AddCategory" then error("Garry's Mod moved upvalue #2, please fix (got " .. AddCategoryName .. ")") end

    hook.Add("PopulateWeapons", "AddWeaponContent", function(Content, Tree)
        local Categorised = BuildWeaponCategories()

        -- Helper
        Tree.Categories = {}
        Tree.pnlContent = Content

        -- Loop through each category
        for cat, _ in SortedPairs(Categorised) do
            if cat ~= Category then
                AddCategory(Tree, cat)
            else
                AddACF3Sweps(Tree, cat)
            end
        end

        -- Select the first node
        local FirstNode = Tree:Root():GetChildNode(0)
        if IsValid(FirstNode) then FirstNode:InternalDoClick() end
    end)
end


-- i'd joke about there being pain involved in making this, but in reality i made a script to do this for me
do
    local pt = {98, 102}

    sound.Add({name = "Weapon_30cal.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^30cal/30cal_shoot.wav"})
    sound.Add({name = "Weapon_30cal.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "30cal/30cal_boltback.wav"})
    sound.Add({name = "Weapon_30cal.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "30cal/30cal_boltforward.wav"})
    sound.Add({name = "Weapon_30cal.BulletChain1", channel = 3, volume = 1, level = 75, pitch = 100, sound = "30cal/30cal_bulletchain1.wav"})
    sound.Add({name = "Weapon_30cal.BulletChain2", channel = 3, volume = 1, level = 75, pitch = 100, sound = "30cal/30cal_bulletchain2.wav"})
    sound.Add({name = "Weapon_30cal.CoverUp", channel = 3, volume = 1, level = 75, pitch = 100, sound = "30cal/30cal_coverup.wav"})
    sound.Add({name = "Weapon_30cal.CoverDown", channel = 1, volume = 1, level = 75, pitch = 100, sound = "30cal/30cal_coverdown.wav"})
    sound.Add({name = "Weapon_30cal.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_30cal.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "30cal/30cal_worldreload.wav"})

    sound.Add({name = "Weapon_Bar.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^bar/bar_shoot.wav"})
    sound.Add({name = "Weapon_Bar.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "bar/bar_boltback.wav"})
    sound.Add({name = "Weapon_Bar.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "bar/bar_boltforward.wav"})
    sound.Add({name = "Weapon_Bar.ClipIn1", channel = 3, volume = 1, level = 75, pitch = 100, sound = "bar/bar_clipin1.wav"})
    sound.Add({name = "Weapon_Bar.ClipIn2", channel = 3, volume = 1, level = 75, pitch = 100, sound = "bar/bar_clipin2.wav"})
    sound.Add({name = "Weapon_Bar.ClipOut", channel = 3, volume = 1, level = 75, pitch = 100, sound = "bar/bar_clipout.wav"})
    sound.Add({name = "Weapon_Bar.SelectorSwitch", channel = 3, volume = 1, level = 75, pitch = 100, sound = "bar/bar_selectorswitch.wav"})
    sound.Add({name = "Weapon_Bar.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Bar.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "bar/bar_worldreload.wav"})

    sound.Add({name = "Weapon_Bazooka.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^bazooka/rocket1.wav"})
    sound.Add({name = "Weapon_Bazooka.ClipIn", channel = 3, volume = 1, level = 75, pitch = 100, sound = "bazooka/rocket_clipin.wav"})
    sound.Add({name = "Weapon_Bazooka.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Bazooka.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "bazooka/rocket_worldreload.wav"})

    sound.Add({name = "Weapon_Carbine.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^m1carbine/m1carbine_shoot.wav"})
    sound.Add({name = "Weapon_Carbine.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "m1carbine/m1carbine_boltback.wav"})
    sound.Add({name = "Weapon_Carbine.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "m1carbine/m1carbine_boltforward.wav"})
    sound.Add({name = "Weapon_Carbine.ClipIn1", channel = 3, volume = 1, level = 75, pitch = 100, sound = "m1carbine/m1carbine_clipin1.wav"})
    sound.Add({name = "Weapon_Carbine.ClipIn2", channel = 3, volume = 1, level = 75, pitch = 100, sound = "m1carbine/m1carbine_clipin2.wav"})
    sound.Add({name = "Weapon_Carbine.ClipOut", channel = 3, volume = 1, level = 75, pitch = 100, sound = "m1carbine/m1carbine_clipout.wav"})
    sound.Add({name = "Weapon_Carbine.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Carbine.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "m1carbine/m1carbine_worldreload.wav"})

    sound.Add({name = "Weapon_Colt.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^colt/colt_shoot.wav"})
    sound.Add({name = "Weapon_Colt.ClipOut", channel = 3, volume = 1, level = 75, pitch = 100, sound = "colt/colt_clipout.wav"})
    sound.Add({name = "Weapon_Colt.ClipIn", channel = 3, volume = 1, level = 75, pitch = 100, sound = "colt/colt_clipin.wav"})
    sound.Add({name = "Weapon_Colt.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "colt/colt_boltback.wav"})
    sound.Add({name = "Weapon_Colt.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "colt/colt_boltforward.wav"})
    sound.Add({name = "Weapon_Colt.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_pistol.wav"})
    sound.Add({name = "Weapon_Colt.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "colt/colt_worldreload.wav"})

    sound.Add({name = "Weapon_C96.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^c96/c96_shoot.wav"})
    sound.Add({name = "Weapon_C96.ClipOut", channel = 3, volume = 1, level = 75, pitch = 100, sound = "c96/c96_clipout.wav"})
    sound.Add({name = "Weapon_C96.ClipIn1", channel = 3, volume = 1, level = 75, pitch = 100, sound = "c96/c96_clipin1.wav"})
    sound.Add({name = "Weapon_C96.ClipIn2", channel = 3, volume = 1, level = 75, pitch = 100, sound = "c96/c96_clipin2.wav"})
    sound.Add({name = "Weapon_C96.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "c96/c96_boltback.wav"})
    sound.Add({name = "Weapon_C96.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "c96/c96_boltforward.wav"})
    sound.Add({name = "Weapon_C96.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_pistol.wav"})
    sound.Add({name = "Weapon_C96.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "c96/c96_worldreload.wav"})

    sound.Add({name = "Weapon_Garand.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^garand/garand_shoot.wav"})
    sound.Add({name = "Weapon_Garand.ClipIn1", channel = 3, volume = 1, level = 75, pitch = 100, sound = "garand/garand_clipin1.wav"})
    sound.Add({name = "Weapon_Garand.ClipIn2", channel = 3, volume = 1, level = 75, pitch = 100, sound = "garand/garand_clipin2.wav"})
    sound.Add({name = "Weapon_Garand.ClipDing", channel = 6, volume = 1, level = 75, pitch = 100, sound = "garand/garand_clipding.wav"})
    sound.Add({name = "Weapon_Garand.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "garand/garand_boltforward.wav"})
    sound.Add({name = "Weapon_Garand.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Garand.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "garand/garand_worldreload.wav"})

    sound.Add({name = "Weapon_Kar.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^k98/k98_shoot.wav"})
    sound.Add({name = "Weapon_KarScoped.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^k98/k98scoped_shoot.wav"})
    sound.Add({name = "Weapon_K98.BoltBack1", channel = 3, volume = 1, level = 75, pitch = 100, sound = "k98/k98_boltback1.wav"})
    sound.Add({name = "Weapon_K98.BoltBack2", channel = 3, volume = 1, level = 75, pitch = 100, sound = "k98/k98_boltback2.wav"})
    sound.Add({name = "Weapon_K98.BoltForward1", channel = 3, volume = 1, level = 75, pitch = 100, sound = "k98/k98_boltforward1.wav"})
    sound.Add({name = "Weapon_K98.BoltForward2", channel = 3, volume = 1, level = 75, pitch = 100, sound = "k98/k98_boltforward2.wav"})
    sound.Add({name = "Weapon_K98.ClipIn", channel = 3, volume = 1, level = 75, pitch = 100, sound = "k98/k98_clipin.wav"})
    sound.Add({name = "Weapon_K98.ClipIn2", channel = 3, volume = 0.5, level = 75, pitch = 100, sound = "k98/k98_clipin2.wav"})
    sound.Add({name = "Weapon_K98.ClipOut", channel = 6, volume = 1, level = 75, pitch = 100, sound = "k98/k98_clipout.wav"})
    sound.Add({name = "Weapon_K98.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_K98.SinglShotReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "k98/k98_singleshotreload.wav"})
    sound.Add({name = "Weapon_K98.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "k98/k98_worldreload.wav"})

    sound.Add({name = "Weapon_Luger.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^p38/p38_shoot.wav"})
    sound.Add({name = "Weapon_Luger.ClipIn", channel = 3, volume = 1, level = 75, pitch = 100, sound = "p38/p38_clipin.wav"})
    sound.Add({name = "Weapon_Luger.ClipOut", channel = 3, volume = 1, level = 75, pitch = 100, sound = "p38/p38_clipout.wav"})
    sound.Add({name = "Weapon_Luger.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "p38/p38_boltback.wav"})
    sound.Add({name = "Weapon_Luger.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "p38/p38_boltforward.wav"})
    sound.Add({name = "Weapon_Luger.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_pistol.wav"})
    sound.Add({name = "Weapon_Luger.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "p38/p38_worldreload.wav"})

    sound.Add({name = "Weapon_Mg42.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^mg42/mg42_shoot.wav"})
    sound.Add({name = "Weapon_Mg42.OverHeat", channel = 6, volume = 1, level = 75, pitch = 100, sound = "mg42/mg42_overheat.wav"})
    sound.Add({name = "Weapon_Mg42.CoverUp", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mg42/mg42_coverup.wav"})
    sound.Add({name = "Weapon_Mg42.CoverDown", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mg42/mg42_coverdown.wav"})
    sound.Add({name = "Weapon_Mg42.BulletChain1", channel = 6, volume = 1, level = 75, pitch = 100, sound = "mg42/mg42_bulletchain1.wav"})
    sound.Add({name = "Weapon_Mg42.BulletChain2", channel = 6, volume = 1, level = 75, pitch = 100, sound = "mg42/mg42_bulletchain2.wav"})
    sound.Add({name = "Weapon_Mg42.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mg42/mg42_boltback.wav"})
    sound.Add({name = "Weapon_Mg42.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mg42/mg42_boltforward.wav"})
    sound.Add({name = "Weapon_Mg42.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Mg42.DeployBipod", channel = 1, volume = 1, level = 75, pitch = 100, sound = "mg42/mg42_deploybipod.wav"})
    sound.Add({name = "Weapon_Mg42.RaiseBipod", channel = 1, volume = 1, level = 75, pitch = 100, sound = "mg42/mg42_raisebipod.wav"})
    sound.Add({name = "Weapon_Mg42.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "mg42/mg42_worldreload.wav"})

    sound.Add({name = "Weapon_Mp40.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^mp40/mp40_shoot.wav"})
    sound.Add({name = "Weapon_Mp40.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Mp40.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp40/mp40_boltback.wav"})
    sound.Add({name = "Weapon_Mp40.ClipIn", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp40/mp40_clipin.wav"})
    sound.Add({name = "Weapon_Mp40.ClipOut", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp40/mp40_clipout.wav"})
    sound.Add({name = "Weapon_Mp40.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp40/mp40_boltforward.wav"})
    sound.Add({name = "Weapon_Mp40.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "mp40/mp40_worldreload.wav"})

    sound.Add({name = "Weapon_Mp44.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^mp44/mp44_shoot.wav"})
    sound.Add({name = "Weapon_Mp44.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp44/mp44_boltback.wav"})
    sound.Add({name = "Weapon_Mp44.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp44/mp44_boltforward.wav"})
    sound.Add({name = "Weapon_Mp44.ClipIn1", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp44/mp44_clipin1.wav"})
    sound.Add({name = "Weapon_Mp44.ClipIn2", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp44/mp44_clipin2.wav"})
    sound.Add({name = "Weapon_Mp44.ClipOut", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp44/mp44_clipout.wav"})
    sound.Add({name = "Weapon_Mp44.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Mp44.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "mp44/mp44_worldreload.wav"})
    sound.Add({name = "Weapon_Mp44.SelectorSwitch", channel = 3, volume = 1, level = 75, pitch = 100, sound = "mp44/mp44_selectorswitch.wav"})

    sound.Add({name = "Weapon_Panzerschreck.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^bazooka/rocket1.wav"})
    sound.Add({name = "Weapon_Panzerschreck.ClipIn", channel = 3, volume = 1, level = 75, pitch = 100, sound = "bazooka/rocket_clipin.wav"})
    sound.Add({name = "Weapon_Panzerschreck.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Panzerschreck.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "bazooka/rocket_worldreload.wav"})

    sound.Add({name = "Weapon_Springfield.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^springfield/spring_shoot.wav"})
    sound.Add({name = "Weapon_Springfield.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Springfield.SinglShotReload", channel = 3, volume = 0.76953125, level = 75, pitch = 0, sound = "k98/k98_singleshotreload.wav"})
    sound.Add({name = "Weapon_Springfield.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "k98/k98_worldreload.wav"})

    sound.Add({name = "Weapon_Thompson.Shoot", channel = 1, volume = 1, level = 150, pitch = pt, sound = "^thompson/thompson_shoot.wav"})
    sound.Add({name = "Weapon_Thompson.ClipIn", channel = 3, volume = 1, level = 75, pitch = 100, sound = "thompson/thompson_clipin.wav"})
    sound.Add({name = "Weapon_Thompson.ClipOut", channel = 3, volume = 1, level = 75, pitch = 100, sound = "thompson/thompson_clipout.wav"})
    sound.Add({name = "Weapon_Thompson.BoltBack", channel = 3, volume = 1, level = 75, pitch = 100, sound = "thompson/thompson_boltback.wav"})
    sound.Add({name = "Weapon_Thompson.BoltForward", channel = 3, volume = 1, level = 75, pitch = 100, sound = "thompson/thompson_boltforward.wav"})
    sound.Add({name = "Weapon_Thompson.Draw", channel = 4, volume = 1, level = 75, pitch = 100, sound = "general/draw_rifle.wav"})
    sound.Add({name = "Weapon_Thompson.WorldReload", channel = 3, volume = 0.76953125, level = 65, pitch = 100, sound = "thompson/thompson_worldreload.wav"})
end

print("ACF-3 SWEPs ready!")