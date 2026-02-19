local ADDON_NAME, private = ...

local L = private:NewLocale("enUS", true)
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\nRight click when finished dragging"
L.Alert_Anchor = "xanAchievementMover Alert Frame Anchor \n\nRight click when finished dragging"
L.AnchorText = "Toggle Anchors"
L.AlertAnchorText = "Toggle Alert System"
L.ResetAll = "Reset all points"
L.ScaleText = "Scale"
L.SlashScale = "scale"
L.SlashAnchor = "anchor"
L.SlashAlert = "alert"
L.SlashReset = "reset"
L.InvalidScale = "Scale must be between 0.5 and 5."
L.CurScale = "Scale is now set to %s."
L.NoAchievementsDisabled = "Addon disabled: Achievements are not enabled on this server."
