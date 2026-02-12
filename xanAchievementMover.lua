
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

local ANCHOR_NAME = "xanAchievementMover_Anchor"

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
	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(message)
	else
		print(message)
	end
end

local eventHandlers = {}

function eventHandlers:ADDON_LOADED(addonName)
	if addonName ~= ADDON_NAME then return end
	self:UnregisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGIN")
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
	
----------------------
--  POSITION FIX    --
----------------------
 
local function customFixAnchors(self, ...)
	if not AlertFrame then return end
	local anchor = _G[ANCHOR_NAME]
	if not anchor then return end

	AlertFrame:ClearAllPoints()
	AlertFrame:SetPoint("CENTER", anchor, "BOTTOM", 0, 0)
	
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

end

if AlertFrame and AlertFrame.UpdateAnchors then
	hooksecurefunc(AlertFrame, "UpdateAnchors", customFixAnchors)
end

-- hooksecurefunc(CriteriaAlertSystem,"ShowAlert", function()
	-- Debug("CriteriaAlertSystem (ShowAlert)")
-- end)

-- hooksecurefunc(AlertFrame,"AddAlertFrame", function()
	-- Debug("AlertFrame (AddAlertFrame)")
-- end)

----------------------
--      Enable      --
----------------------

function addon:EnableAddon()
	if not AchievementsAvailable() then
		DisableForNoAchievements()
		self:UnregisterAllEvents()
		return
	end

	if not self._managedOverride then
		local managedPositions = _G.UIPARENT_MANAGED_FRAME_POSITIONS
		if type(managedPositions) == "table" then
			managedPositions["AlertFrame"] = nil
		end
		self._managedOverride = true
	end

	XanAM_DB = XanAM_DB or {}

	local anchor = self:DrawAnchor()
	self:RestoreLayout(ANCHOR_NAME)

	SLASH_XANACHIEVEMENTMOVER1 = "/xam"
	SlashCmdList["XANACHIEVEMENTMOVER"] = function()
		self:ToggleAnchor()
	end
	
	if addon.configFrame then addon.configFrame:EnableConfig() end
	
	local ver = (GetAddOnMetadata and GetAddOnMetadata(ADDON_NAME, "Version")) or "1.0"
	PrintMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xam", ADDON_NAME, ver))
	
	anchor.isLoaded = true
end

function addon:ToggleAnchor()
	local anchor = _G[ANCHOR_NAME]
	if not anchor then return end
	if anchor:IsVisible() then
		anchor:Hide()
	else
		anchor:Show()
		anchor.wasToggled = true
	end
end

function addon:DrawAnchor()

	local frame = _G[ANCHOR_NAME]
	if frame then return frame end

	frame = CreateFrame("Frame", ANCHOR_NAME, UIParent, BackdropTemplate)

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
    frame.bg:SetAllPoints(true)
	
	frame:Hide()

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
