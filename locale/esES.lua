local ADDON_NAME, private = ...

local L = private:NewLocale("esES")
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\nClic derecho cuando termine de arrastrar"
L.Alert_Anchor = "xanAchievementMover Ancla de alertas \n\nClic derecho cuando termine de arrastrar"
L.AnchorText = "Alternar anclajes"
L.AlertAnchorText = "Alternar sistema de alertas"
L.ResetAll = "Restablecer todos los puntos"
L.ScaleText = "Escala"
L.SlashScale = "escala"
L.SlashAnchor = "ancla"
L.SlashAlert = "alerta"
L.SlashReset = "reiniciar"
L.InvalidScale = "La escala debe estar entre 0.5 y 5."
L.CurScale = "La escala ahora está establecida en %s."
L.NoAchievementsDisabled = "Addon desactivado: los logros no están habilitados en este servidor."
