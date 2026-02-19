local ADDON_NAME, private = ...

local L = private:NewLocale("koKR")
if not L then return end

L.DragFrameInfo = "xanAchievementMover \n\n드래그를 끝내면 우클릭하세요"
L.Alert_Anchor = "xanAchievementMover 알림 앵커 \n\n드래그를 끝내면 우클릭하세요"
L.AnchorText = "앵커 전환"
L.AlertAnchorText = "알림 시스템 전환"
L.ResetAll = "모든 위치 초기화"
L.ScaleText = "크기"
L.SlashScale = "크기"
L.SlashAnchor = "앵커"
L.SlashAlert = "알림"
L.SlashReset = "초기화"
L.InvalidScale = "크기는 0.5에서 5 사이여야 합니다."
L.CurScale = "크기가 이제 %s(으)로 설정되었습니다."
L.NoAchievementsDisabled = "애드온 비활성화: 이 서버에서는 업적이 활성화되어 있지 않습니다."
