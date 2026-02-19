local ADDON_NAME, private = ...

local L = private:NewLocale("zhCN")
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\n拖动完成后右键单击"
L.Alert_Anchor = "xanAchievementMover 提示锚点 \n\n拖动完成后右键单击"
L.AnchorText = "切换锚点"
L.AlertAnchorText = "切换提示系统"
L.ResetAll = "重置所有位置"
L.ScaleText = "缩放"
L.SlashScale = "缩放"
L.SlashAnchor = "锚点"
L.SlashAlert = "提示"
L.SlashReset = "重置"
L.InvalidScale = "缩放必须在 0.5 到 5 之间。"
L.CurScale = "缩放已设置为 %s。"
L.NoAchievementsDisabled = "插件已禁用：此服务器未启用成就。"
