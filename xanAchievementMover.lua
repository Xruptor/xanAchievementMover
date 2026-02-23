
local ADDON_NAME, private = ...
local _G = _G
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local BackdropTemplate = _G.BackdropTemplateMixin and "BackdropTemplate" or nil
local hooksecurefunc = _G.hooksecurefunc
local IsLoggedIn = _G.IsLoggedIn
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME
local print = _G.print
local type = _G.type
local C_AddOns = _G.C_AddOns
local GetAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or _G.GetAddOnMetadata
local DisableAddOn = _G.DisableAddOn
local AlertFrame = _G.AlertFrame
local function RefreshAlertFrame()
	AlertFrame = _G.AlertFrame or AlertFrame
	return AlertFrame
end

local ALERTFRAME_ANCHOR_NAME = "xanAchievementMover_AlertAnchor"
local LEGACY_ANCHOR_NAME = "xanAchievementMover_Anchor"
-- Shared scale used by both anchors and the AlertFrame.
local MIN_SCALE = 0.5
local MAX_SCALE = 5
local DEFAULT_SCALE = 1

if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplate)
end
local addon = _G[ADDON_NAME]

-- Locale files load with the addon's private table (2nd return from "...").
addon.private = private
addon.L = (private and private.L) or addon.L or {}
local L = addon.L

local WOW_PROJECT_ID = _G.WOW_PROJECT_ID
local WOW_PROJECT_MAINLINE = _G.WOW_PROJECT_MAINLINE
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC
--local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local WOW_PROJECT_WRATH_CLASSIC = _G.WOW_PROJECT_WRATH_CLASSIC

addon.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
addon.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
--BSYC.IsTBC_C = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
addon.IsWLK_C = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local function PrintMessage(message)
	if message == nil then return end
	local prefix = string.format("|cFF99CC33%s|r: ", ADDON_NAME)
	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(prefix .. message)
	else
		print(prefix .. message)
	end
end

local eventHandlers = {}

function eventHandlers:ADDON_LOADED(addonName)
	if addonName == ADDON_NAME then
		self:RegisterEvent("PLAYER_LOGIN")
		return
	end
end

function eventHandlers:PLAYER_LOGIN()
	if not IsLoggedIn() then return end
	self:EnableAddon()
	self:UnregisterEvent("PLAYER_LOGIN")
end

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, ...)
	local handler = eventHandlers[event]
	if handler then
		return handler(self, ...)
	end
	local method = self[event]
	if method then
		return method(self, event, ...)
	end
end)

local function AchievementsAvailable()
	if type(_G.GetAchievementInfo) == "function" then
		return true
	end
	if _G.C_AchievementInfo and type(_G.C_AchievementInfo.GetAchievementInfo) == "function" then
		return true
	end
	return false
end

local function DisableForNoAchievements()
	local message = L.NoAchievementsDisabled or "Addon disabled: Achievements are not enabled on this server."
	PrintMessage(message)
	local disableAddon = (C_AddOns and C_AddOns.DisableAddOn) or DisableAddOn
	if type(disableAddon) == "function" then
		disableAddon(ADDON_NAME)
	end
end

-- Clamp scale input to a safe range.
local function ClampScale(value)
	if value < MIN_SCALE then return MIN_SCALE end
	if value > MAX_SCALE then return MAX_SCALE end
	return value
end

-- Avoid taint/forbidden access when touching protected frames.
local function CanAccessObject(obj)
	if not obj then return false end
	if type(obj.IsForbidden) == "function" and obj:IsForbidden() then
		return false
	end
	return true
end

local function IsEditModeActive()
	local manager = _G.EditModeManagerFrame
	if manager then
		if type(manager.IsEditModeActive) == "function" then
			local ok, active = pcall(manager.IsEditModeActive, manager)
			if ok then return active end
		end
		if manager.editModeActive ~= nil then
			return manager.editModeActive
		end
	end
	if _G.C_EditMode and type(_G.C_EditMode.IsEditModeActive) == "function" then
		local ok, active = pcall(_G.C_EditMode.IsEditModeActive)
		if ok then return active end
	end
	return false
end

local function IsTalkingHeadActive()
	local th = _G.TalkingHeadFrame
	if not th then return false end
	if type(th.IsShown) == "function" and th:IsShown() then
		return true
	end
	return false
end

local function PrintHelp()
	PrintMessage("Available commands:")
	PrintMessage("  /xam")
	PrintMessage("  /xam anchor  - " .. (L.AnchorText or "Toggle Anchors"))
	PrintMessage("  /xam alert   - " .. (L.AlertAnchorText or "Toggle Alert System"))
	PrintMessage("  /xam scale X - " .. (L.ScaleText or "Scale") .. " (0.5 - 5)")
	PrintMessage("  /xam reset   - " .. (L.ResetAll or "Reset all points"))
end


-- Single stored scale for both anchors.
function addon:GetScale()
	if type(XanAM_DB) ~= "table" then
		return DEFAULT_SCALE
	end
	local scale = tonumber(XanAM_DB.scale) or DEFAULT_SCALE
	return ClampScale(scale)
end

local function IsAlertSystemEnabled()
	if type(XanAM_DB) ~= "table" then
		return true
	end
	if XanAM_DB.alertEnabled == nil then
		return true
	end
	return XanAM_DB.alertEnabled
end

-- Update and apply the shared scale.
function addon:SetScale(scale, silent)
	local val = tonumber(scale)
	if not val or val < MIN_SCALE or val > MAX_SCALE then
		if not silent then
			PrintMessage(L.InvalidScale or ("Scale must be between "..MIN_SCALE.." and "..MAX_SCALE.."."))
		end
		return
	end
	XanAM_DB = XanAM_DB or {}
	XanAM_DB.scale = ClampScale(val)
	self:ApplyScale()
	if not silent then
		PrintMessage(string.format(L.CurScale or "Scale is now set to %s.", XanAM_DB.scale))
	end
end

-- Apply scale to legacy anchor, alert anchor, and AlertFrame.
-- AlertFrame scale is the global scale knob for all alert systems.
function addon:ApplyScale()
	local scale = self:GetScale()
	local legacyAnchor = _G[LEGACY_ANCHOR_NAME]
	if legacyAnchor then
		legacyAnchor:SetScale(scale)
	end
	if IsAlertSystemEnabled() then
		local alertAnchor = _G[ALERTFRAME_ANCHOR_NAME]
		if alertAnchor then
			alertAnchor:SetScale(scale)
		end
	end
	local alertFrame = RefreshAlertFrame()
	if CanAccessObject(alertFrame) then
		alertFrame:SetScale(scale)
	end
end

----------------------
--  POSITION FIX    --
----------------------

-- Achievement-related subsystems (long toast + criteria).
local function IsAchievementSubSystem(alertFrameSubSystem)
	return alertFrameSubSystem
		and (alertFrameSubSystem == _G.AchievementAlertSystem
			or alertFrameSubSystem == _G.CriteriaAlertSystem)
end

local function IsTalkingHeadSubSystem(alertFrameSubSystem)
	if not alertFrameSubSystem then return false end
	local th = _G.TalkingHeadFrame
	if not th then return false end
	if alertFrameSubSystem.anchorFrame == th or alertFrameSubSystem.alertFrame == th then
		return true
	end
	if alertFrameSubSystem.alertFrame and alertFrameSubSystem.alertFrame.GetName then
		local name = alertFrameSubSystem.alertFrame:GetName()
		if name and name == "TalkingHeadFrame" then
			return true
		end
	end
	if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame.GetName then
		local name = alertFrameSubSystem.anchorFrame:GetName()
		if name and name == "TalkingHeadFrame" then
			return true
		end
	end
	return false
end

-- Run AdjustAnchors for a filtered set of subsystems against a start anchor.
local function ApplySubSystemAnchors(subsystems, startAnchor, shouldAnchor)
	if not startAnchor then return end
	local relativeFrame = startAnchor
	for i = 1, #subsystems do
		local subSystem = subsystems[i]
		if subSystem and subSystem.AdjustAnchors and shouldAnchor(subSystem) then
			if subSystem.alertFramePool and subSystem.alertFramePool.EnumerateActive then
				for alertFrame in subSystem.alertFramePool:EnumerateActive() do
					alertFrame:ClearAllPoints()
				end
			elseif subSystem.alertFrame and subSystem.alertFrame.ClearAllPoints then
				subSystem.alertFrame:ClearAllPoints()
			elseif subSystem.anchorFrame and subSystem.anchorFrame.ClearAllPoints then
				subSystem.anchorFrame:ClearAllPoints()
			end
			relativeFrame = subSystem:AdjustAnchors(relativeFrame)
		end
	end
end

-- Split Blizzard's alert anchoring into two chains:
-- 1) Achievement/criteria -> legacy anchor
-- 2) Everything else -> alert anchor
local function customFixAnchors(self, ...)
	if IsEditModeActive() then return end
	if IsTalkingHeadActive() then return end
	local container = self or RefreshAlertFrame()
	if not container then return end
	if not CanAccessObject(container) then return end

	addon:ApplyScale()

	local subsystems = container.alertFrameSubSystems
	if type(subsystems) ~= "table" then return end

	-- Achievements/criteria always use the legacy anchor.
	local achievementAnchor = _G[LEGACY_ANCHOR_NAME]
	ApplySubSystemAnchors(subsystems, achievementAnchor, function(subSystem)
		return IsAchievementSubSystem(subSystem) and not IsTalkingHeadSubSystem(subSystem)
	end)

	-- All other alerts use the alert anchor.
	if IsAlertSystemEnabled() then
		local alertAnchor = _G[ALERTFRAME_ANCHOR_NAME]
		ApplySubSystemAnchors(subsystems, alertAnchor, function(subSystem)
			return not IsAchievementSubSystem(subSystem) and not IsTalkingHeadSubSystem(subSystem)
		end)
	end

end

----------------------
--      Enable      --
----------------------

function addon:EnableAddon()
	if not AchievementsAvailable() then
		DisableForNoAchievements()
		self:UnregisterAllEvents()
		return
	end

	-- Ensure the Achievement UI is loaded so test alerts don't error before the frame exists.
	-- This mirrors Blizzard's lazy-load behavior but forces it early for consistency.
	if type(_G.AchievementFrame_LoadUI) == "function" and not _G.AchievementFrame then
		_G.AchievementFrame_LoadUI()
	end

	-- Prevent UIParent's frame manager from re-anchoring AlertFrame.
	if not self._managedOverride then
		local alertFrame = RefreshAlertFrame()
		local managedPositions = _G.UIPARENT_MANAGED_FRAME_POSITIONS
		if type(managedPositions) == "table" then
			managedPositions["AlertFrame"] = nil
		end
		if alertFrame then
			alertFrame.ignoreFramePositionManager = true
		end
		self._managedOverride = true
	end

	XanAM_DB = XanAM_DB or {}
	if XanAM_DB.alertEnabled == nil then
		XanAM_DB.alertEnabled = true
	end

	-- Legacy anchor: achievement/criteria alerts.
	local legacyAnchor = self:DrawLegacyAnchor()
	self:RestoreLayout(LEGACY_ANCHOR_NAME)
	legacyAnchor.isLoaded = true

	-- Hook AlertFrame anchor updates to enforce split anchoring.
	local alertFrame = RefreshAlertFrame()
	if alertFrame and alertFrame.UpdateAnchors and not self._alertHooked then
		hooksecurefunc(alertFrame, "UpdateAnchors", customFixAnchors)
		self._alertHooked = true
	end

	local alertAnchor
	if IsAlertSystemEnabled() then
		-- Alert anchor: non-achievement toast alerts.
		alertAnchor = self:DrawAlertAnchor()
		self:RestoreLayout(ALERTFRAME_ANCHOR_NAME)
	end
	self:ApplyScale()

	SLASH_XANACHIEVEMENTMOVER1 = "/xam"
	SlashCmdList["XANACHIEVEMENTMOVER"] = function(msg)
		local args = msg or ""
		local cmd, rest = args:match("^(%S+)%s*(.-)$")
		if not cmd or cmd == "" then
			PrintHelp()
			return
		end

		cmd = cmd:lower()
		if cmd == ((L.SlashAnchor or "anchor"):lower()) then
			self:ToggleAnchor()
			return
		end
		if cmd == ((L.SlashAlert or "alert"):lower()) then
			self:ToggleAlertSystem()
			return
		end
		if cmd == ((L.SlashReset or "reset"):lower()) then
			self:ResetAlertAnchor()
			return
		end
		if cmd == ((L.SlashScale or "scale"):lower()) then
			self:SetScale(rest)
			return
		end
		PrintHelp()
	end

	if addon.configFrame then addon.configFrame:EnableConfig() end

	local ver = (GetAddOnMetadata and GetAddOnMetadata(ADDON_NAME, "Version")) or "1.0"
	PrintMessage(string.format("[v|cFF20ff20%s|r] loaded:   /xam", ver))

	if alertAnchor then
		alertAnchor.isLoaded = true
	end
end

function addon:ToggleAnchor()
	local anchor = _G[LEGACY_ANCHOR_NAME]
	if not anchor then return end
	if anchor:IsVisible() then
		anchor:Hide()
		local alertAnchor = _G[ALERTFRAME_ANCHOR_NAME]
		if alertAnchor then
			alertAnchor:Hide()
		end
	else
		anchor:Show()
		anchor.wasToggled = true
		if IsAlertSystemEnabled() then
			local alertAnchor = _G[ALERTFRAME_ANCHOR_NAME]
			if alertAnchor then
				alertAnchor:Show()
				alertAnchor.wasToggled = true
			end
		end
	end
end

function addon:ToggleAlertSystem()
	XanAM_DB = XanAM_DB or {}
	XanAM_DB.alertEnabled = not IsAlertSystemEnabled()

	local anchor = _G[ALERTFRAME_ANCHOR_NAME]
	if anchor then
		if XanAM_DB.alertEnabled then
			self:RestoreLayout(ALERTFRAME_ANCHOR_NAME)
			anchor:Show()
			anchor.wasToggled = true
		else
			anchor:Hide()
		end
	end
	self:ApplyScale()
	local alertFrame = RefreshAlertFrame()
	if alertFrame and alertFrame.UpdateAnchors then
		alertFrame:UpdateAnchors()
	end
end

function addon:ResetAlertAnchor()
	XanAM_DB = XanAM_DB or {}
	XanAM_DB[LEGACY_ANCHOR_NAME] = nil
	XanAM_DB[ALERTFRAME_ANCHOR_NAME] = nil
	XanAM_DB.scale = DEFAULT_SCALE
	self:RestoreLayout(LEGACY_ANCHOR_NAME)
	if IsAlertSystemEnabled() then
		self:RestoreLayout(ALERTFRAME_ANCHOR_NAME)
	end
	self:ApplyScale()
end

local function CreateLegacyAnchor()
	local frame = CreateFrame("Frame", LEGACY_ANCHOR_NAME, UIParent, BackdropTemplate)
	frame:SetFrameStrata("DIALOG")
	frame:SetSize(300, 88)

	frame:EnableMouse(true)
	frame:SetMovable(true)

	frame:SetScript("OnMouseDown",function(self, button)
		if button == "LeftButton" then
			self.isMoving = true
			self:StartMoving()
		else
			self:Hide()
		end

	end)
	frame:SetScript("OnMouseUp",function(self)
		if( self.isMoving ) then
			self.isMoving = nil
			self:StopMovingOrSizing()

			addon:SaveLayout(self:GetName())
		end
	end)

	frame:SetScript("OnHide",function(self)
		if self.wasToggled and self.isLoaded then
			addon:SaveLayout(self:GetName())
			self.wasToggled = nil
		end
	end)

	local stringA = frame:CreateFontString()
	stringA:SetAllPoints(frame)
	stringA:SetFontObject("GameFontNormalSmall")
	stringA:SetText(L.DragFrameInfo)

	if frame.SetBackdrop then
		frame:SetBackdrop({
				edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 16,
				insets = { left = 5, right = 5, top = 5, bottom = 5 }
		})
		frame:SetBackdropColor(153/255, 204/255, 51/255, 1)
		frame:SetBackdropBorderColor(153/255, 204/255, 51/255, 1)
	end

    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetTexCoord(0, .605, 0, .703)
	frame.bg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background")
    frame.bg:SetAllPoints(frame)

	frame:Hide()

	return frame
end

local function CreateAlertAnchor()
	local frame = CreateFrame("Frame", ALERTFRAME_ANCHOR_NAME, UIParent, BackdropTemplate)
	frame:SetFrameStrata("DIALOG")
	-- Match LootRollMover's alert anchor sizing (based on AlertFrame).
	local alertBase = _G.AlertFrame
	local alertWidth = (alertBase and alertBase.GetWidth and alertBase:GetWidth()) or 249
	local alertHeight = (alertBase and alertBase.GetHeight and alertBase:GetHeight()) or 71
	if not alertWidth or alertWidth < 15 then alertWidth = 249 end
	if not alertHeight or alertHeight < 15 then alertHeight = 71 end
	frame:SetSize(alertWidth, alertHeight)

	frame:EnableMouse(true)
	frame:SetMovable(true)

	frame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			self.isMoving = true
			self:StartMoving()
		else
			self:Hide()
		end
	end)
	frame:SetScript("OnMouseUp", function(self)
		if self.isMoving then
			self.isMoving = nil
			self:StopMovingOrSizing()
			addon:SaveLayout(self:GetName())
		end
	end)
	frame:SetScript("OnHide", function(self)
		if self.wasToggled and self.isLoaded then
			addon:SaveLayout(self:GetName())
			self.wasToggled = nil
		end
	end)

	if frame.SetBackdrop then
		frame:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		frame:SetBackdropColor(0, 0.75, 0, 0.9)
		frame:SetBackdropBorderColor(0, 1.0, 0, 1.0)
	end

	local stringA = frame:CreateFontString()
	stringA:SetFontObject("GameFontNormalSmall")
	stringA:SetText((L.Alert_Anchor or "xanAchievementMover Alert Frame Anchor \n\nRight click when finished dragging"))
	stringA:SetAllPoints(frame)

	frame:Hide()
	return frame
end

function addon:DrawLegacyAnchor()

	local frame = _G[LEGACY_ANCHOR_NAME]
	if frame then return frame end

	frame = CreateLegacyAnchor()
	return frame
end

function addon:DrawAlertAnchor()
	local frame = _G[ALERTFRAME_ANCHOR_NAME]
	if frame then return frame end

	frame = CreateAlertAnchor()
	return frame
end


local function EnsureLayout(frameName)
	XanAM_DB = XanAM_DB or {}
	local opt = XanAM_DB[frameName]
	if not opt then
		opt = {
			point = "CENTER",
			relativePoint = "CENTER",
			xOfs = 0,
			yOfs = 0,
		}
		XanAM_DB[frameName] = opt
	end
	return opt
end

function addon:SaveLayout(frame)
	if type(frame) ~= "string" then return end
	local frameObj = _G[frame]
	if not frameObj then return end

	local opt = EnsureLayout(frame)

	local point, _, relativePoint, xOfs, yOfs = frameObj:GetPoint()
	if not point then return end
	opt.point = point
	opt.relativePoint = relativePoint
	opt.xOfs = xOfs
	opt.yOfs = yOfs
end

function addon:RestoreLayout(frame)
	if type(frame) ~= "string" then return end
	local frameObj = _G[frame]
	if not frameObj then return end

	local opt = EnsureLayout(frame)

	frameObj:ClearAllPoints()
	frameObj:SetPoint(opt.point, UIParent, opt.relativePoint, opt.xOfs, opt.yOfs)
end

---------------------------
--  MISC Debug Stuff    --
---------------------------
---
---
-- hooksecurefunc(CriteriaAlertSystem,"ShowAlert", function()
	-- Debug("CriteriaAlertSystem (ShowAlert)")
-- end)

-- hooksecurefunc(AlertFrame,"AddAlertFrame", function()
	-- Debug("AlertFrame (AddAlertFrame)")
-- end)


--[=[

	WOW uses an AlertSystem to push out alerts on the screen.
	The two files are AlertFrames.lua and AlertFrameSystems.lua
	https://github.com/tomrus88/BlizzardInterfaceCode/blob/49f059f549c48d5811b13771a52c8a4cfff3b227/Interface/FrameXML/AlertFrameSystems.lua


	AchievementAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("AchievementAlertFrameTemplate", AchievementAlertFrame_SetUp, 2, 6);
	AchievementAlertSystem:SetCanShowMoreConditionFunc(function() return not C_PetBattles.IsInBattle() end);
	CriteriaAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("CriteriaAlertFrameTemplate", CriteriaAlertFrame_SetUp, 2, 0);
	GuildChallengeAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GuildChallengeAlertFrame, GuildChallengeAlertFrame_SetUp);
	DungeonCompletionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(DungeonCompletionAlertFrame, DungeonCompletionAlertFrame_SetUp);
	ScenarioAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(ScenarioAlertFrame, ScenarioAlertFrame_SetUp);
	InvasionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(ScenarioLegionInvasionAlertFrame, ScenarioLegionInvasionAlertFrame_SetUp, ScenarioLegionInvasionAlertFrame_Coalesce);
	DigsiteCompleteAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(DigsiteCompleteToastFrame, DigsiteCompleteToastFrame_SetUp);
	StorePurchaseAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(StorePurchaseAlertFrame, StorePurchaseAlertFrame_SetUp);
	GarrisonBuildingAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonBuildingAlertFrame, GarrisonBuildingAlertFrame_SetUp);
	GarrisonMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonMissionAlertFrame, GarrisonMissionAlertFrame_SetUp);
	GarrisonShipMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonShipMissionAlertFrame, GarrisonMissionAlertFrame_SetUp);
	GarrisonRandomMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonRandomMissionAlertFrame, GarrisonRandomMissionAlertFrame_SetUp);
	GarrisonFollowerAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonFollowerAlertFrame, GarrisonFollowerAlertFrame_SetUp);
	GarrisonShipFollowerAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonShipFollowerAlertFrame, GarrisonShipFollowerAlertFrame_SetUp);
	GarrisonTalentAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonTalentAlertFrame, GarrisonTalentAlertFrame_SetUp);
	WorldQuestCompleteAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(WorldQuestCompleteAlertFrame, WorldQuestCompleteAlertFrame_SetUp, WorldQuestCompleteAlertFrame_Coalesce);
	LegendaryItemAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(LegendaryItemAlertFrame, LegendaryItemAlertFrame_SetUp);
	
	
	local achievementAlertPool = AchievementAlertSystem.alertFramePool
	for alertFrame in achievementAlertPool:EnumerateActive() do
		--modify the alertFrame however
	end

	Examples to push alerts on screen:
	
	--Queued Alerts:
	/run AchievementAlertSystem:AddAlert(5192)
	/run CriteriaAlertSystem:AddAlert(9023, 'Doing great!')
	/run LootAlertSystem:AddAlert('|cffa335ee|Hitem:18832::::::::::|h[Brutality Blade]|h|r', 1, 1, 1, 1, false, false, 0, false, false)
	/run LootUpgradeAlertSystem:AddAlert('|cffa335ee|Hitem:18832::::::::::|h[Brutality Blade]|h|r', 1, 1, 1, nil, nil, false)
	/run MoneyWonAlertSystem:AddAlert(81500)
	/run NewRecipeLearnedAlertSystem:AddAlert(204)

	--Simple Alerts
	/run GuildChallengeAlertSystem:AddAlert(3, 2, 5)
	/run InvasionAlertSystem:AddAlert(678, DUNGEON_FLOOR_THENEXUS1, true, 1, 1)
	/run WorldQuestCompleteAlertSystem:AddAlert(AlertFrameMixin:BuildQuestData(42114))
	/run GarrisonTalentAlertSystem:AddAlert(3, C_Garrison.GetTalentInfo(370))
	/run GarrisonBuildingAlertSystem:AddAlert(GARRISON_CACHE)
	/run GarrisonFollowerAlertSystem:AddAlert(204, 'Ben Stone', 90, 3, false)
	/run GarrisonMissionAlertSystem:AddAlert(681) (Requires a mission ID that is in your mission list.)
	/run GarrisonShipFollowerAlertSystem:AddAlert(592, 'Test', 'Transport', 'GarrBuilding_Barracks_1_H', 3, 2, 1)
	/run LegendaryItemAlertSystem:AddAlert('|cffa335ee|Hitem:18832::::::::::|h[Brutality Blade]|h|r')
	/run EntitlementDeliveredAlertSystem:AddAlert('', [[Interface\Icons\Ability_pvp_gladiatormedallion]], TRINKET0SLOT, 214)
	/run RafRewardDeliveredAlertSystem:AddAlert('', [[Interface\Icons\Ability_pvp_gladiatormedallion]], TRINKET0SLOT, 214)
	/run DigsiteCompleteAlertSystem:AddAlert('Human')

	--Bonus Rolls
	/run BonusRollFrame_CloseBonusRoll()
	/run BonusRollFrame_StartBonusRoll(242969,'test',10,515,1273,14) --515 is darkmoon token, change to another currency id you have
]=]



	--DEBUG ONLY
	---------------------------------
	--[=[
		local alertPool

		for k, v in pairs(AlertFrame) do
			if k then Debug("Parent: "..tostring(k)) end
		end
		
		for k, v in pairs(self) do
			if k then Debug("Self: "..tostring(k)) end
		end
		
		for i, alertFrameSubSystem in ipairs(self.alertFrameSubSystems) do
			
			
			alertPool = alertFrameSubSystem.alertFramePool
			
			if alertPool then
			
				-- for k, v in pairs(alertPool) do
					-- if k then Debug("Pool: "..tostring(k)) end
				-- end

				for alertFrameObj in alertPool:EnumerateActive() do
					local nameText = alertFrameObj.Name

					for k, v in pairs(alertFrameObj) do
						if k then Debug("alertFrameObj: "..tostring(k)) end
					end
				end
				
			end
		
		end
	]=]
