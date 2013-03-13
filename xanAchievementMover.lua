
local L = XANACHIEVEMENTMOVER_L

local f = CreateFrame("frame","xanAchievementMover",UIParent)
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

UIPARENT_MANAGED_FRAME_POSITIONS["AchievementAlertFrame1"] = nil; 
UIPARENT_MANAGED_FRAME_POSITIONS["AchievementAlertFrame2"] = nil; 
UIPARENT_MANAGED_FRAME_POSITIONS["DungeonCompletionAlertFrame1"] = nil; 
UIPARENT_MANAGED_FRAME_POSITIONS["GuildChallengeAlertFrame"] = nil; 
UIPARENT_MANAGED_FRAME_POSITIONS["AlertFrame"] = nil; 
UIPARENT_MANAGED_FRAME_POSITIONS["ChallengeModeAlertFrame1"] = nil; 
UIPARENT_MANAGED_FRAME_POSITIONS["ScenarioAlertFrame1"] = nil; 

for i=1, MAX_ACHIEVEMENT_ALERTS do
	UIPARENT_MANAGED_FRAME_POSITIONS["AchievementAlertFrame"..i] = nil; 
end

for i=1, MAX_ACHIEVEMENT_ALERTS do
	UIPARENT_MANAGED_FRAME_POSITIONS["CriteriaAlertFrame"..i] = nil; 
end
	
----------------------
--  POSITION FIX    --
----------------------

local function customFixAnchors(...)

	local frame = AchievementAlertFrame1
	local frameTwo = AchievementAlertFrame2
	local frameD = DungeonCompletionAlertFrame1
	local frameG = GuildChallengeAlertFrame
	local frameA = AlertFrame
	local frameC = ChallengeModeAlertFrame1
	local frameS = ScenarioAlertFrame1

	--check for dungeon shown
	if (frameD and frameD:IsShown()) then
		f:LoadPositionHook("DungeonCompletionAlertFrame1", "xanAchievementMover_Anchor")
	end
	
	--check for guild challenge shown
	if (frameG and frameG:IsShown()) then
		f:LoadPositionHook("GuildChallengeAlertFrame", "xanAchievementMover_Anchor")
	end
	
	--check for dungeon challenge shown
	if (frameC and frameC:IsShown()) then
		f:LoadPositionHook("ChallengeModeAlertFrame1", "xanAchievementMover_Anchor")
	end
	
	--check for scenario complete shown
	if (frameS and frameS:IsShown()) then
		f:LoadPositionHook("ScenarioAlertFrame1", "xanAchievementMover_Anchor")
	end
	
	--position the achievements
	for i=1, MAX_ACHIEVEMENT_ALERTS do
		local achframe = _G["AchievementAlertFrame"..i];
		if ( achframe and achframe:IsShown() ) then
			achframe:ClearAllPoints()
			if i == 1 then
				f:LoadPositionHook("AchievementAlertFrame1", "xanAchievementMover_Ach1")
			elseif _G["AchievementAlertFrame"..(i-1)] then
				achframe:SetPoint("TOPLEFT", _G["AchievementAlertFrame"..(i-1)], "BOTTOMLEFT", 0, 4)
			end
		end
	end

	--position the criteria alerts
	for i=1, MAX_ACHIEVEMENT_ALERTS do
		local achframe = _G["CriteriaAlertFrame"..i];
		if ( achframe and achframe:IsShown() ) then
			achframe:ClearAllPoints()
			if i == 1 then
				f:LoadPositionHook("CriteriaAlertFrame1", "xanAchievementMover_Ach1")
			elseif _G["CriteriaAlertFrame"..(i-1)] then
				achframe:SetPoint("TOPLEFT", _G["CriteriaAlertFrame"..(i-1)], "BOTTOMLEFT", 0, 4)
			end
		end
	end
	
end

hooksecurefunc("AlertFrame_FixAnchors", customFixAnchors)

----------------------
--      Enable      --
----------------------

function f:PLAYER_LOGIN()

	if not XanAM_DB then XanAM_DB = {} end
	
	self:DrawAnchor()
	self:RestoreLayout("xanAchievementMover_Anchor")

	SLASH_XANACHIEVEMENTMOVER1 = "/xanam";
	SlashCmdList["XANACHIEVEMENTMOVER"] = xanAchievementMover_SlashCommand;
	
	local ver = GetAddOnMetadata("xanAchievementMover","Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format(L["|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam"], "xanAchievementMover", ver or "1.0"))
	
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

function xanAchievementMover_SlashCommand(cmd)
	if not _G["xanAchievementMover_Anchor"] then return end
	_G["xanAchievementMover_Anchor"]:Show()
end

function f:DrawAnchor()

	--lets do the dungeon one first ;)
	local frame = CreateFrame("Frame", "xanAchievementMover_Anchor", UIParent)

	frame:SetFrameStrata("DIALOG")
	frame:SetWidth(DungeonCompletionAlertFrame1:GetWidth())
	frame:SetHeight(DungeonCompletionAlertFrame1:GetHeight())

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

			f:SaveLayout(self:GetName())
			f:SaveLayout("xanAchievementMover_Ach1")
		end
	end)

	local stringA = frame:CreateFontString()
	stringA:SetAllPoints(frame)
	stringA:SetFontObject("GameFontNormalSmall")
	stringA:SetText(L["xanAchievementMover [DUNGEON POPUP]\n\nRight click when finished dragging"])

	frame:SetBackdrop({
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame:SetBackdropColor(0.15, 0.49, 1, 1)
	frame:SetBackdropBorderColor(0.15, 0.49, 1, 1)

    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetTexCoord(0, 0.546875, 0.28515, 0.5664)
    frame.bg:SetWidth(70)
    frame.bg:SetHeight(72)
	frame.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST")
    frame.bg:SetPoint("BOTTOMLEFT")

    frame.bg1 = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg1:SetTexCoord(0.5546875, 0.671875, 0.28515, 0.5664)
    frame.bg1:SetWidth(15)
    frame.bg1:SetHeight(72)
	frame.bg1:SetTexture("Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST")
    frame.bg1:SetPoint("BOTTOMRIGHT")

    frame.bg2 = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg2:SetTexCoord(0, 0.9921875, 0, 0.28125)
    frame.bg2:SetWidth(127)
    frame.bg2:SetHeight(72)
	frame.bg2:SetTexture("Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST")
    frame.bg2:SetPoint("BOTTOMLEFT", 69, 0)

    frame.bg3 = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg3:SetTexCoord(0, 0.9921875, 0.58203, 0.86328)
    frame.bg3:SetWidth(127)
    frame.bg3:SetHeight(72)
	frame.bg3:SetTexture("Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST")
    frame.bg3:SetPoint("BOTTOMRIGHT", -14, 0)

	
	--achievement popup 1
	local frameAch1 = CreateFrame("Frame", "xanAchievementMover_Ach1", xanAchievementMover_Anchor)

	frameAch1:SetFrameStrata("DIALOG")
	frameAch1:SetWidth(300)
	frameAch1:SetHeight(88)
	frameAch1:ClearAllPoints()
	frameAch1:SetPoint("CENTER", xanAchievementMover_Anchor, "BOTTOM", 0, -(frame:GetHeight()/2 + 4) )
			
	frameAch1:EnableMouse(true)
	frameAch1:SetMovable(true)

	frameAch1:SetScript("OnMouseDown",function(self, button)
		if button == "LeftButton" then
			self:GetParent().isMoving = true
			self:GetParent():StartMoving()
		end
		
	end)
	frameAch1:SetScript("OnMouseUp",function(self)
		if( self:GetParent().isMoving ) then
			self:GetParent().isMoving = nil
			self:GetParent():StopMovingOrSizing()
			f:SaveLayout(self:GetParent():GetName())
			f:SaveLayout("xanAchievementMover_Ach1")
		end
	end)

	local stringAch1 = frameAch1:CreateFontString()
	stringAch1:SetAllPoints(frameAch1)
	stringAch1:SetFontObject("GameFontNormalSmall")
	stringAch1:SetText(L["xanAchievementMover [ACHIEVEMENT 1]"])

	frameAch1:SetBackdrop({
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frameAch1:SetBackdropColor(153/255, 204/255, 51/255, 1)
	frameAch1:SetBackdropBorderColor(153/255, 204/255, 51/255, 1)
	
    frameAch1.bg = frameAch1:CreateTexture(nil, "BACKGROUND")
    frameAch1.bg:SetTexCoord(0, .605, 0, .703)
	frameAch1.bg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background")
    frameAch1.bg:SetAllPoints(true)

	--achievement popup 2
	local frameAch2 = CreateFrame("Frame", "xanAchievementMover_Ach2", xanAchievementMover_Anchor)

	frameAch2:SetFrameStrata("DIALOG")
	frameAch2:SetWidth(300)
	frameAch2:SetHeight(88)
	frameAch2:ClearAllPoints()
	frameAch2:SetPoint("TOPLEFT", frameAch1, "BOTTOMLEFT", 0, 4)
			
	frameAch2:EnableMouse(true)
	frameAch2:SetMovable(true)

	frameAch2:SetScript("OnMouseDown",function(self, button)
		if button == "LeftButton" then
			self:GetParent().isMoving = true
			self:GetParent():StartMoving()
		end
		
	end)
	frameAch2:SetScript("OnMouseUp",function(self)
		if( self:GetParent().isMoving ) then
			self:GetParent().isMoving = nil
			self:GetParent():StopMovingOrSizing()
			f:SaveLayout(self:GetParent():GetName())
			f:SaveLayout("xanAchievementMover_Ach1")
		end
	end)

	local stringAch2 = frameAch2:CreateFontString()
	stringAch2:SetAllPoints(frameAch2)
	stringAch2:SetFontObject("GameFontNormalSmall")
	stringAch2:SetText(L["xanAchievementMover [ACHIEVEMENT 2]"])

	frameAch2:SetBackdrop({
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frameAch2:SetBackdropColor(153/255, 204/255, 51/255, 1)
	frameAch2:SetBackdropBorderColor(153/255, 204/255, 51/255, 1)
	
    frameAch2.bg = frameAch2:CreateTexture(nil, "BACKGROUND")
    frameAch2.bg:SetTexCoord(0, .605, 0, .703)
	frameAch2.bg:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background")
    frameAch2.bg:SetAllPoints(true)
	
	frame:Hide()	
end

function f:SaveLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanAM_DB then XanAM_DB = {} end
	
	local opt = XanAM_DB[frame] or nil

	if not opt then
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

function f:RestoreLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanAM_DB then XanAM_DB = {} end

	local opt = XanAM_DB[frame] or nil

	if not opt then
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

function f:LoadPositionHook(frame, frameAttach)
	if type(frame) ~= "string" then return end
	if type(frameAttach) ~= "string" then return end
	if not _G[frame] then return end
	if not _G[frameAttach] then return end
	if not XanAM_DB then XanAM_DB = {} end

	local opt = XanAM_DB[frame] or nil

	if not opt then
		XanAM_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = XanAM_DB[frame]
	end

	_G[frame]:ClearAllPoints()
	_G[frame]:SetPoint(opt.point, _G[frameAttach], opt.relativePoint, opt.xOfs, opt.yOfs)
	
end

------------------------------
--      Event Handlers      --
------------------------------

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end
