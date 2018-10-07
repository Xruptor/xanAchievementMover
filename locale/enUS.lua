local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\nRight click when finished dragging"
L.AnchorText = "Toggle Frame Anchor"
