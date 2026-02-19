local ADDON_NAME, private = ...

local L = private:NewLocale("frFR")
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\nClic droit lorsque vous avez fini de déplacer"
L.Alert_Anchor = "xanAchievementMover Ancre des alertes \n\nClic droit lorsque vous avez fini de déplacer"
L.AnchorText = "Basculer les ancrages"
L.AlertAnchorText = "Basculer le système d'alertes"
L.ResetAll = "Réinitialiser tous les points"
L.ScaleText = "Échelle"
L.SlashScale = "echelle"
L.SlashAnchor = "ancre"
L.SlashAlert = "alerte"
L.SlashReset = "reinitialiser"
L.InvalidScale = "L'échelle doit être comprise entre 0.5 et 5."
L.CurScale = "L'échelle est maintenant définie sur %s."
L.NoAchievementsDisabled = "Addon désactivé : les hauts faits ne sont pas activés sur ce serveur."
