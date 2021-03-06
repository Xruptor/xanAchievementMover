
local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
addon = _G[ADDON_NAME]

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then
		if event == "ADDON_LOADED" then
			local arg1 = ...
			if arg1 and arg1 == ADDON_NAME then
				self:UnregisterEvent("ADDON_LOADED")
				self:RegisterEvent("PLAYER_LOGIN")
			end
			return
		end
		if IsLoggedIn() then
			self:EnableAddon(event, ...)
			self:UnregisterEvent("PLAYER_LOGIN")
		end
		return
	end
	if self[event] then
		return self[event](self, event, ...)
	end
end)

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

--[[
	
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
	/run LootAlertSystem:AddAlert("|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0:0:0|h[Broken Fang]|h|r", 1, specID, 3, 1, 3, Awesome);
	 
	/run MoneyWonAlertSystem:AddAlert(815)
	 
	/run AchievementAlertSystem:AddAlert(5192)
	 
	/run CriteriaAlertSystem:ShowAlert(80,1)
	 
	/run GuildChallengeAlertSystem:AddAlert(3, 2, 5)
	 
	/run DungeonCompletionAlertSystem:AddAlert()
	 
	/run InvasionAlertSystem:AddAlert(1,20)
	 
	/run DigsiteCompleteAlertSystem:AddAlert(1)
	 
	 /run LootUpgradeAlertSystem:AddAlert("|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0:0:0|h[Broken Fang]|h|r", 1, specID, 3, "Cesaor", 3, Awesome);
	 
	 /run GarrisonFollowerAlertSystem:AddAlert(112, "Cool Guy", "100", 3, 1)
	 
	 /run GarrisonShipFollowerAlertSystem:AddAlert(592, "Test", "Transport", "GarrBuilding_Barracks_1_H", 3, 2, 1)
	 
	 /run GarrisonBuildingAlertSystem:AddAlert("miau")
	 
	 /run WorldQuestCompleteAlertSystem:AddAlert(112)
 
]]
	
	
UIPARENT_MANAGED_FRAME_POSITIONS["AlertFrame"] = nil; 


----------------------
--  POSITION FIX    --
----------------------
 
local function customFixAnchors(self, ...)
	
	AlertFrame:ClearAllPoints()
	AlertFrame:SetPoint("CENTER", xanAchievementMover_Anchor, "BOTTOM", 0, 0)
	
	--DEBUG ONLY
	---------------------------------
	--[[ 	
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
	]]

end

hooksecurefunc(AlertFrame,"UpdateAnchors", customFixAnchors)

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

	if not XanAM_DB then XanAM_DB = {} end
	
	local anchor = self:DrawAnchor()
	self:RestoreLayout("xanAchievementMover_Anchor")

	SLASH_XANACHIEVEMENTMOVER1 = "/xam";
	SlashCmdList["XANACHIEVEMENTMOVER"] = function(cmd) addon.aboutPanel.btnAnchor.func() end;
	
	if addon.configFrame then addon.configFrame:EnableConfig() end
	
	local ver = GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xam", ADDON_NAME, ver or "1.0"))
	
	anchor.isLoaded = true
end

function addon:DrawAnchor()

	local frame = CreateFrame("Frame", "xanAchievementMover_Anchor", UIParent, BackdropTemplateMixin and "BackdropTemplate")

	frame:SetFrameStrata("DIALOG")
	frame:SetWidth(300)
	frame:SetHeight(88)

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

	frame:SetBackdrop({
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame:SetBackdropColor(153/255, 204/255, 51/255, 1)
	frame:SetBackdropBorderColor(153/255, 204/255, 51/255, 1)

    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetTexCoord(0, .605, 0, .703)
	frame.bg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background")
    frame.bg:SetAllPoints(true)
	
	frame:Hide()

	return frame
end

function addon:SaveLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanAM_DB then XanAM_DB = {} end
	
	local opt = XanAM_DB[frame] or nil

	if not opt or not opt.point or not opt.xOfs then
		XanAM_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = XanAM_DB[frame]
		return
	end

	local point, relativeTo, relativePoint, xOfs, yOfs = _G[frame]:GetPoint()
	opt.point = point
	opt.relativePoint = relativePoint
	opt.xOfs = xOfs
	opt.yOfs = yOfs
end

function addon:RestoreLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanAM_DB then XanAM_DB = {} end

	local opt = XanAM_DB[frame] or nil

	if not opt or not opt.point or not opt.xOfs then
		XanAM_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = XanAM_DB[frame]
	end

	_G[frame]:ClearAllPoints()
	_G[frame]:SetPoint(opt.point, UIParent, opt.relativePoint, opt.xOfs, opt.yOfs)
end
