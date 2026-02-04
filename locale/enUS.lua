local ADDON_NAME, private = ...

local L = private:NewLocale("enUS", true)
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\nRight click when finished dragging"
L.AnchorText = "Toggle Frame Anchor"
L.NoAchievementsDisabled = "Addon disabled: Achievements are not enabled on this server."
