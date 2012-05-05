
--[[
	xanAchievementMover Localization
--]]

XANACHIEVEMENTMOVER_L = GetLocale() == "zhCN" and {
	["|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam"] = "|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam",
	["/xanam anchor - toggles the anchors to move the frames"] = "/xanam anchor - toggles the anchors to move the frames",
	["xanAchievementMover [DUNGEON POPUP]\n\nRight click when finished dragging"] = "xanAchievementMover [DUNGEON POPUP]\n\nRight click when finished dragging",
	["xanAchievementMover [ACHIEVEMENT 1]"] = "xanAchievementMover [ACHIEVEMENT 1]",
	["xanAchievementMover [ACHIEVEMENT 2]"] = "xanAchievementMover [ACHIEVEMENT 2]",

} 
-- or GetLocale() == "ruRU" and {
	-- ["|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam"] = "|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam",
	-- ["/xanam anchor - toggles the anchors to move the frames"] = "/xanam anchor - toggles the anchors to move the frames",

-- } or GetLocale() == "zhTW" and {
	-- ["|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam"] = "|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam",
	-- ["/xanam anchor - toggles the anchors to move the frames"] = "/xanam anchor - toggles the anchors to move the frames",

-- } or GetLocale() == "frFR" and {
	-- ["|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam"] = "|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam",
	-- ["/xanam anchor - toggles the anchors to move the frames"] = "/xanam anchor - toggles the anchors to move the frames",
	
-- } or GetLocale() == "koKR" and {
	-- ["|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam"] = "|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam",
	-- ["/xanam anchor - toggles the anchors to move the frames"] = "/xanam anchor - toggles the anchors to move the frames",

-- } or GetLocale() == "deDE" and {
	-- ["|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam"] = "|cFF99CC33%s|r [v|cFFDF2B2B%s|r] loaded:   /xanam",
	-- ["/xanam anchor - toggles the anchors to move the frames"] = "/xanam anchor - toggles the anchors to move the frames",
	
-- } 
or { }

setmetatable(XANACHIEVEMENTMOVER_L, {__index = function(self, key) rawset(self, key, key); return key; end})

