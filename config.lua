local ADDON_NAME, private = ...
local _G = _G
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local BackdropTemplate = _G.BackdropTemplateMixin and "BackdropTemplate" or nil
local C_AddOns = _G.C_AddOns
local GetAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or _G.GetAddOnMetadata

if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplate)
end
local addon = _G[ADDON_NAME]

addon.configFrame = CreateFrame("frame", ADDON_NAME.."_config_eventFrame", UIParent, BackdropTemplate)
local configFrame = addon.configFrame

addon.private = private
addon.L = (private and private.L) or addon.L or {}
local L = addon.L

local lastObject
local function addConfigEntry(objEntry, adjustX, adjustY)
	
	objEntry:ClearAllPoints()
	
	if not lastObject then
		objEntry:SetPoint("TOPLEFT", 20, -150)
	else
		objEntry:SetPoint("LEFT", lastObject, "BOTTOMLEFT", adjustX or 0, adjustY or -30)
	end
	
	lastObject = objEntry
end

local buttonIndex = 0
local function createButton(parentFrame, displayText)
	buttonIndex = buttonIndex + 1
	
	local button = CreateFrame("Button", ADDON_NAME.."_config_button_" .. buttonIndex, parentFrame, "UIPanelButtonTemplate")
	button:SetText(displayText)
	button:SetHeight(30)
	button:SetWidth(button:GetTextWidth() + 30)

	return button
end

local function createSlider(parentFrame, displayText)
	buttonIndex = buttonIndex + 1

	local slider = CreateFrame("Slider", ADDON_NAME.."_config_slider_" .. buttonIndex, parentFrame, "OptionsSliderTemplate")
	slider:SetMinMaxValues(0.5, 5)
	slider:SetValueStep(0.1)
	slider:SetObeyStepOnDrag(true)
	slider:SetWidth(220)
	slider:SetHeight(16)

	local text = _G[slider:GetName().."Text"]
	if text then
		text:SetText(displayText)
	end
	local low = _G[slider:GetName().."Low"]
	if low then
		low:SetText("0.5")
	end
	local high = _G[slider:GetName().."High"]
	if high then
		high:SetText("5.0")
	end

	return slider
end

local function LoadAboutFrame()

	--Code inspired from tekKonfigAboutPanel
	if addon.aboutPanel then
		return addon.aboutPanel
	end

	local parent = _G.InterfaceOptionsFramePanelContainer or _G.SettingsPanel or UIParent
	local about = CreateFrame("Frame", ADDON_NAME.."AboutPanel", parent, BackdropTemplate)
	about.name = ADDON_NAME
	about:Hide()
	
    local fields = {"Version", "Author"}
	local notes = (GetAddOnMetadata and GetAddOnMetadata(ADDON_NAME, "Notes")) or ""

    local title = about:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")

	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(ADDON_NAME)

	local subtitle = about:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(32)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", about, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(notes or "")

	local anchor
	for i = 1, #fields do
		local field = fields[i]
		local val = GetAddOnMetadata and GetAddOnMetadata(ADDON_NAME, field)
		if val then
			local title = about:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			title:SetWidth(75)
			if not anchor then title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -8)
			else title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6) end
			title:SetJustifyH("RIGHT")
			title:SetText(field:gsub("X%-", ""))

			local detail = about:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			detail:SetPoint("LEFT", title, "RIGHT", 4, 0)
			detail:SetPoint("RIGHT", -16, 0)
			detail:SetJustifyH("LEFT")
			detail:SetText(val)

			anchor = title
		end
	end
	
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(about)
	else
		local category, layout = _G.Settings.RegisterCanvasLayoutCategory(about, about.name);
		_G.Settings.RegisterAddOnCategory(category);
		addon.settingsCategory = category
	end

	return about
end

function configFrame:EnableConfig()
	if addon.aboutPanel and addon.aboutPanel.btnAnchor then
		return
	end

	addon.aboutPanel = LoadAboutFrame()
	
	--anchor
	local btnAnchor = createButton(addon.aboutPanel, L.AnchorText)
	btnAnchor.func = function() addon:ToggleAnchor() end
	btnAnchor:SetScript("OnClick", btnAnchor.func)
	
	addConfigEntry(btnAnchor, 0, -30)
	addon.aboutPanel.btnAnchor = btnAnchor

	local btnAlertAnchor = createButton(addon.aboutPanel, L.AlertAnchorText or "Toggle Alert Frame Anchor")
	btnAlertAnchor.func = function() addon:ToggleAlertSystem() end
	btnAlertAnchor:SetScript("OnClick", btnAlertAnchor.func)

	addConfigEntry(btnAlertAnchor, 0, -20)
	addon.aboutPanel.btnAlertAnchor = btnAlertAnchor

	local btnReset = createButton(addon.aboutPanel, L.ResetAll)
	btnReset.func = function() addon:ResetAlertAnchor() end
	btnReset:SetScript("OnClick", btnReset.func)

	addConfigEntry(btnReset, 0, -20)
	addon.aboutPanel.btnReset = btnReset

	local scaleSlider = createSlider(addon.aboutPanel, L.ScaleText)
	scaleSlider:SetScript("OnValueChanged", function(self, value)
		if addon and addon.SetScale then
			addon:SetScale(value, true)
		end
	end)
	scaleSlider:SetScript("OnShow", function(self)
		if addon and addon.GetScale then
			self:SetValue(addon:GetScale())
		end
	end)

	addConfigEntry(scaleSlider, 0, -25)
	addon.aboutPanel.scaleSlider = scaleSlider
end
