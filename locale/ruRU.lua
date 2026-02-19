local ADDON_NAME, private = ...

local L = private:NewLocale("ruRU")
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\nЩёлкните правой кнопкой после перемещения"
L.Alert_Anchor = "xanAchievementMover Якорь оповещений \n\nЩёлкните правой кнопкой после перемещения"
L.AnchorText = "Переключить якоря"
L.AlertAnchorText = "Переключить систему оповещений"
L.ResetAll = "Сбросить все точки"
L.ScaleText = "Масштаб"
L.SlashScale = "масштаб"
L.SlashAnchor = "якорь"
L.SlashAlert = "оповещение"
L.SlashReset = "сброс"
L.InvalidScale = "Масштаб должен быть между 0.5 и 5."
L.CurScale = "Масштаб теперь установлен на %s."
L.NoAchievementsDisabled = "Аддон отключён: достижения на этом сервере не включены."
