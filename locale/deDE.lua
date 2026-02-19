local ADDON_NAME, private = ...

local L = private:NewLocale("deDE")
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\nRechtsklick, wenn du mit dem Ziehen fertig bist"
L.Alert_Anchor = "xanAchievementMover Alarmfenster-Anker \n\nRechtsklick, wenn du mit dem Ziehen fertig bist"
L.AnchorText = "Anker umschalten"
L.AlertAnchorText = "Alarmsystem umschalten"
L.ResetAll = "Alle Punkte zurücksetzen"
L.ScaleText = "Skalierung"
L.SlashScale = "skalierung"
L.SlashAnchor = "anker"
L.SlashAlert = "alarm"
L.SlashReset = "reset"
L.InvalidScale = "Skalierung muss zwischen 0.5 und 5 liegen."
L.CurScale = "Skalierung ist jetzt auf %s gesetzt."
L.NoAchievementsDisabled = "Addon deaktiviert: Erfolge sind auf diesem Server nicht aktiviert."
