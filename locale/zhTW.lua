local ADDON_NAME, private = ...

local L = private:NewLocale("zhTW")
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\n拖曳完成後右鍵點擊"
L.Alert_Anchor = "xanAchievementMover 提示錨點 \n\n拖曳完成後右鍵點擊"
L.AnchorText = "切換錨點"
L.AlertAnchorText = "切換提示系統"
L.ResetAll = "重置所有位置"
L.ScaleText = "縮放"
L.SlashScale = "縮放"
L.SlashAnchor = "錨點"
L.SlashAlert = "提示"
L.SlashReset = "重置"
L.InvalidScale = "縮放必須在 0.5 到 5 之間。"
L.CurScale = "縮放已設定為 %s。"
L.NoAchievementsDisabled = "插件已停用：此伺服器未啟用成就。"
