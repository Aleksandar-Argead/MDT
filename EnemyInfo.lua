---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Nnogga.
--- DateTime: 09.07.2018 07:35
---
local MDT = MethodDungeonTools
local AceGUI = LibStub("AceGUI-3.0")
local db

local tinsert,Model_Reset = table.insert,Model_Reset



local tconcat, tremove, tinsert = table.concat, table.remove, table.insert

local function CreateDispatcher(argCount)
    local code = [[
        local xpcall, eh = ...
        local method, ARGS
        local function call() return method(ARGS) end

        local function dispatch(func, ...)
            method = func
            if not method then return end
            ARGS = ...
            return xpcall(call, eh)
        end

        return dispatch
    ]]

    local ARGS = {}
    for i = 1, argCount do ARGS[i] = "arg"..i end
    code = code:gsub("ARGS", tconcat(ARGS, ", "))
    return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall, errorhandler)
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
    local dispatcher = CreateDispatcher(argCount)
    rawset(self, argCount, dispatcher)
    return dispatcher
end})
Dispatchers[0] = function(func)
    return xpcall(func, errorhandler)
end

local function safecall(func, ...)
    return Dispatchers[select("#", ...)](func, ...)
end


AceGUI:RegisterLayout("ThreeColums", function(content, children)
    if children[1] then
        children[1]:SetWidth(content:GetWidth()/3)
        children[1].frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        children[1].frame:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 0)
        children[1].frame:Show()
    end
    if children[2] then
        children[2]:SetWidth(content:GetWidth()/3)
        children[2].frame:SetPoint("TOPLEFT", children[1].frame, "TOPRIGHT", 0, 0)
        children[2].frame:SetPoint("BOTTOMLEFT", children[1].frame, "BOTTOMRIGHT", 0, 0)
        children[2].frame:Show()
    end
    if children[3] then
        children[3]:SetWidth(content:GetWidth()/3)
        children[3].frame:SetPoint("TOPLEFT", children[2].frame, "TOPRIGHT", 0, 0)
        children[3].frame:SetPoint("BOTTOMLEFT", children[2].frame, "BOTTOMRIGHT", 0, 0)
        children[3].frame:Show()
    end
    safecall(content.obj.LayoutFinished, content.obj, nil, nil)
end)


local currentTab = "tab1"
local function MakeEnemeyInfoFrame()
    --frame
    local f = AceGUI:Create("Frame")
    f:SetTitle("Enemy Info")
    f:EnableResize(false)
    f.frame:SetMovable(false)
    function f.frame:StartMoving() end
    f:SetLayout("Fill")
    f:SetCallback("OnClose", function(widget)

    end)
    f.frame:SetAllPoints(MethodDungeonToolsScrollFrame)

    local originalHide = MethodDungeonTools.main_frame.Hide
    function MethodDungeonTools.main_frame:Hide(...)
        f.frame:Hide()
        return originalHide(self, ...);
    end

    --tabGroup
    f.tabGroup = AceGUI:Create("TabGroup")
    local tabGroup = f.tabGroup
    tabGroup:SetTabs(
            {
                {text="Enemy Info", value="tab1"},
                --{text="Damage Calc", value="tab2"},
            }
    )
    tabGroup:SetLayout("ThreeColums")
    f:AddChild(tabGroup)

    --EnemyInfo
    local function DrawGroup1(container)

        ---LEFT
        local leftContainer = AceGUI:Create("SimpleGroup")
        leftContainer.frame:SetBackdropColor(1,1,1,0)
        leftContainer:SetLayout("List")
        leftContainer:SetWidth(container.frame:GetWidth()/3)
        leftContainer:SetHeight(container.frame:GetHeight())

        --enemyDropDown
        f.enemyDropDown = AceGUI:Create("Dropdown")
        local enemyDropDown = f.enemyDropDown
        enemyDropDown:SetCallback("OnValueChanged", function(widget,callbackName,key)
            MDT:UpdateEnemyInfoFrame(key)
        end)

        --model
        f.model = f.model or CreateFrame("PlayerModel", nil, f.frame,"ModelWithControlsTemplate")
        local model = f.model
        --ViragDevTool_AddData(model)
        model:SetFrameLevel(1)
        model:SetSize(leftContainer.frame:GetWidth()-30,269)
        model:SetScript("OnEnter",nil)
        model:SetFrameLevel(15)
        model:Show()
        local modelContainer = AceGUI:Create("InlineGroup")
        modelContainer.frame:SetBackdropColor(1,1,1,0)
        modelContainer:SetWidth(leftContainer.frame:GetWidth()-20)
        modelContainer:SetHeight(249)
        modelContainer:SetLayout("Flow")
        local modelDummyIcon = AceGUI:Create("Icon")
        modelDummyIcon:SetImageSize(leftContainer.frame:GetWidth()-20, 249)
        modelDummyIcon:SetDisabled(true)
        modelContainer:AddChild(modelDummyIcon)
        model:SetPoint("BOTTOM",modelContainer.frame,"BOTTOM",0,10)
        MethodDungeonTools:FixAceGUIShowHide(model,modelContainer.frame,true)

        f.characteristicsContainer = AceGUI:Create("InlineGroup")
        f.characteristicsContainer.frame:SetBackdropColor(1,1,1,0)
        f.characteristicsContainer:SetWidth(leftContainer.frame:GetWidth()-20)
        f.characteristicsContainer:SetHeight(80)
        f.characteristicsContainer:SetLayout("Flow")

        leftContainer:AddChild(enemyDropDown)
        leftContainer:AddChild(modelContainer)
        leftContainer:AddChild(f.characteristicsContainer)

        ---MIDDLE
        local midContainer = AceGUI:Create("SimpleGroup")
        midContainer.frame:SetBackdropColor(1,1,1,0)
        midContainer:SetLayout("List")
        midContainer:SetWidth(container.frame:GetWidth()/3)
        midContainer:SetHeight(container.frame:GetHeight())

        --spacing
        local midDummyIcon = AceGUI:Create("Icon")
        midDummyIcon:SetImageSize(20, 20)
        midDummyIcon:SetHeight(enemyDropDown.frame:GetHeight())
        midDummyIcon:SetDisabled(true)
        midContainer:AddChild(midDummyIcon)

        f.enemyDataContainer = AceGUI:Create("InlineGroup")
        f.enemyDataContainer.frame:SetBackdropColor(1,1,1,0)
        f.enemyDataContainer:SetWidth(leftContainer.frame:GetWidth()-20)
        f.enemyDataContainer:SetHeight(235)
        f.enemyDataContainer:SetLayout("Flow")

        f.enemyDataContainer.idEditBox = AceGUI:Create("EditBox")
        f.enemyDataContainer.idEditBox:SetLabel("NPC Id")
        f.enemyDataContainer.idEditBox:DisableButton(true)
        f.enemyDataContainer.idEditBox:SetCallback("OnTextChanged", function(self)
            self:SetText(self.defaultText)
        end)
        f.enemyDataContainer:AddChild(f.enemyDataContainer.idEditBox)

        f.enemyDataContainer.healthEditBox = AceGUI:Create("EditBox")
        f.enemyDataContainer.healthEditBox:SetLabel("Health")
        f.enemyDataContainer.healthEditBox:DisableButton(true)
        f.enemyDataContainer.healthEditBox:SetCallback("OnTextChanged", function(self)
            self:SetText(self.defaultText)
        end)
        f.enemyDataContainer:AddChild(f.enemyDataContainer.healthEditBox)

        f.enemyDataContainer.creatureTypeEditBox = AceGUI:Create("EditBox")
        f.enemyDataContainer.creatureTypeEditBox:SetLabel("Creature Type")
        f.enemyDataContainer.creatureTypeEditBox:DisableButton(true)
        f.enemyDataContainer.creatureTypeEditBox:SetCallback("OnTextChanged", function(self)
            self:SetText(self.defaultText)
        end)
        f.enemyDataContainer:AddChild(f.enemyDataContainer.creatureTypeEditBox)

        f.enemyDataContainer.levelEditBox = AceGUI:Create("EditBox")
        f.enemyDataContainer.levelEditBox:SetLabel("Level")
        f.enemyDataContainer.levelEditBox:DisableButton(true)
        f.enemyDataContainer.levelEditBox:SetCallback("OnTextChanged", function(self)
            self:SetText(self.defaultText)
        end)
        f.enemyDataContainer:AddChild(f.enemyDataContainer.levelEditBox)

        f.enemyDataContainer.countEditBox = AceGUI:Create("EditBox")
        f.enemyDataContainer.countEditBox:SetLabel("Enemy Forces")
        f.enemyDataContainer.countEditBox:DisableButton(true)
        f.enemyDataContainer.countEditBox:SetCallback("OnTextChanged", function(self)
            self:SetText(self.defaultText)
        end)
        f.enemyDataContainer:AddChild(f.enemyDataContainer.countEditBox)

        f.enemyDataContainer.stealthCheckBox = AceGUI:Create("CheckBox")
        f.enemyDataContainer.stealthCheckBox:SetLabel("Stealth")
        f.enemyDataContainer.stealthCheckBox:SetWidth((f.enemyDataContainer.frame:GetWidth()/2)-40)
        f.enemyDataContainer.stealthCheckBox:SetCallback("OnValueChanged", function(self)
            self:SetValue(self.defaultValue)
        end)
        f.enemyDataContainer:AddChild(f.enemyDataContainer.stealthCheckBox)

        f.enemyDataContainer.stealthDetectCheckBox = AceGUI:Create("CheckBox")
        f.enemyDataContainer.stealthDetectCheckBox:SetLabel("Stealth Detect")
        f.enemyDataContainer.stealthDetectCheckBox:SetWidth((f.enemyDataContainer.frame:GetWidth()/2))
        f.enemyDataContainer.stealthDetectCheckBox:SetCallback("OnValueChanged", function(self)
            self:SetValue(self.defaultValue)
        end)
        f.enemyDataContainer:AddChild(f.enemyDataContainer.stealthDetectCheckBox)


        midContainer:AddChild(f.enemyDataContainer)

        ---RIGHT
        local rightContainer = AceGUI:Create("SimpleGroup")
        rightContainer.frame:SetBackdropColor(1,1,1,0)
        rightContainer:SetLayout("List")
        rightContainer:SetWidth(container.frame:GetWidth()/3)
        rightContainer:SetHeight(container.frame:GetHeight())

        --spacing
        local rightDummyIcon = AceGUI:Create("Icon")
        rightDummyIcon:SetImageSize(20, 20)
        rightDummyIcon:SetHeight(enemyDropDown.frame:GetHeight())
        rightDummyIcon:SetDisabled(true)
        rightContainer:AddChild(rightDummyIcon)

        --spells
        local spellScrollContainer = AceGUI:Create("InlineGroup")
        spellScrollContainer.frame:SetBackdropColor(1,1,1,0)
        spellScrollContainer:SetWidth(leftContainer.frame:GetWidth()-20)
        spellScrollContainer:SetHeight(282)
        spellScrollContainer:SetLayout("Fill")

        f.spellScroll = AceGUI:Create("ScrollFrame")
        f.spellScroll:SetLayout("List")
        spellScrollContainer:AddChild(f.spellScroll)

        rightContainer:AddChild(spellScrollContainer)


        container:AddChild(leftContainer)
        container:AddChild(midContainer)
        container:AddChild(rightContainer)
    end

    --Damage Calc
    local function DrawGroup2(container)

    end


    -- Callback function for OnGroupSelected
    local function SelectGroup(container, event, group)
        container:ReleaseChildren()
        if group == "tab1" then
            DrawGroup1(container)
        elseif group == "tab2" then
            DrawGroup2(container)
        end
        currentTab = group
    end
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab(currentTab)

    return f
end

local characteristics = {
    ["Stun"] = "Interface\\ICONS\\spell_frost_stun",
    ["Sap"] = "Interface\\ICONS\\ability_sap",
    ["Incapacitate"] = "Interface\\ICONS\\ability_monk_paralysis",
    ["Repentance"] = "Interface\\ICONS\\spell_holy_prayerofhealing",
    ["Disorient"] = "Interface\\ICONS\\spell_shadow_mindsteal",
    ["Banish"] = "Interface\\ICONS\\spell_shadow_cripple",
    ["Fear"] = "Interface\\ICONS\\spell_shadow_possession",
    ["Root"] = "Interface\\ICONS\\spell_frost_frostnova",
    ["Polymorph"] = "Interface\\ICONS\\spell_nature_polymorph",
    ["Shackle Undead"] = "Interface\\ICONS\\spell_nature_slow",
    ["Mind Control"] = "Interface\\ICONS\\spell_shadow_shadowworddominate",
    ["Grip"] = "Interface\\ICONS\\spell_deathknight_strangulate",
    ["Knock"] = "Interface\\ICONS\\ability_druid_typhoon",
    ["Silence"] = "Interface\\ICONS\\ability_priest_silence",
    ["Taunt"] = "Interface\\ICONS\\spell_nature_reincarnation",
    ["Control Undead"] = "Interface\\ICONS\\inv_misc_bone_skull_01",
    ["Enslave Demon"] = "Interface\\ICONS\\spell_shadow_enslavedemon",
    ["Slow"] = "Interface\\ICONS\\ability_rogue_trip",
}

function MDT:UpdateEnemyInfoFrame(enemyIdx)
    local data = MDT.dungeonEnemies[db.currentDungeonIdx][enemyIdx]
    local f = MDT.EnemyInfoFrame
    f:SetTitle(data.name)
    f.model:SetDisplayInfo(data.displayId)
    Model_Reset(f.model)

    local enemies = {}
    for mobIdx,edata in ipairs(MDT.dungeonEnemies[db.currentDungeonIdx]) do
        tinsert(enemies,mobIdx,edata.name)
    end
    f.enemyDropDown:SetList(enemies)
    f.enemyDropDown:SetValue(enemyIdx)

    --characteristics
    f.characteristicsContainer:ReleaseChildren()
    local characteristicsText = AceGUI:Create("Label")
    characteristicsText:SetWidth(f.characteristicsContainer.frame:GetWidth())
    characteristicsText:SetText("Affected by:")
    f.characteristicsContainer:AddChild(characteristicsText)
    for text,iconPath in pairs(characteristics) do
        if data.characteristics and data.characteristics[text] then
            local icon = AceGUI:Create("Icon")
            icon:SetImage(iconPath)
            icon:SetImageSize(25,25)
            icon:SetWidth(25)
            icon:SetHeight(27)
            icon:SetCallback("OnEnter",function()
                GameTooltip:SetOwner(icon.frame, "ANCHOR_BOTTOM",0,3)
                GameTooltip:SetText(text,1,1,1,1)
                GameTooltip:Show()
            end)
            icon:SetCallback("OnLeave",function()
                GameTooltip:Hide()
            end)
            f.characteristicsContainer:AddChild(icon)
            if IsAddOnLoaded("AddOnSkins") then
                local AS = unpack(AddOnSkins)
                AS:SkinTexture(icon.image)
            end
        end
    end

    --data
    f.enemyDataContainer.idEditBox:SetText(data.id)
    f.enemyDataContainer.idEditBox.defaultText = data.id
    f.enemyDataContainer.healthEditBox:SetText(data.health)
    f.enemyDataContainer.healthEditBox.defaultText = data.health
    f.enemyDataContainer.creatureTypeEditBox:SetText(data.creatureType)
    f.enemyDataContainer.creatureTypeEditBox.defaultText = data.creatureType
    f.enemyDataContainer.levelEditBox:SetText(data.level)
    f.enemyDataContainer.levelEditBox.defaultText = data.level
    f.enemyDataContainer.countEditBox:SetText(data.count)
    f.enemyDataContainer.countEditBox.defaultText = data.count
    f.enemyDataContainer.stealthCheckBox:SetValue(data.stealth)
    f.enemyDataContainer.stealthCheckBox.defaultValue = data.stealth
    f.enemyDataContainer.stealthDetectCheckBox:SetValue(data.stealthDetect)
    f.enemyDataContainer.stealthDetectCheckBox.defaultValue = data.stealthDetect

    --spells
    f.spellScroll:ReleaseChildren()
    if data.spells then
        for spellId,spellData in pairs(data.spells) do
            local spellButton = AceGUI:Create("MethodDungeonToolsSpellButton")
            spellButton:SetSpell(spellId)
            spellButton:Initialize()
            spellButton:Enable()
            f.spellScroll:AddChild(spellButton)
        end
    end

end

function MDT:ShowEnemyInfoFrame(blip)
    db = MDT:GetDB()
    MDT.EnemyInfoFrame = MDT.EnemyInfoFrame or MakeEnemeyInfoFrame()
    MDT:UpdateEnemyInfoFrame(blip.enemyIdx)
    MDT.EnemyInfoFrame:Show()
end
