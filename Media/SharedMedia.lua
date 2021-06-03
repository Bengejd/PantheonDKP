local _, PDKP = ...;
local _G = _G;
local L = PDKP.L;

local Media = PDKP.Media

Media.CLOSE_BUTTON_TEXT = "|TInterface\\Buttons\\UI-StopButton:0|t"
Media.TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"
Media.PDKP_TEXTURE_BASE = "Interface\\Addons\\PantheonDKP\\Media\\Main_UI\\PDKPFrame-"
Media.SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
Media.SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
Media.CHAR_INFO_TEXTURE = 'Interface\\CastingBar\\UI-CastingBar-Border-Small'

Media.adoon_version_hex = '0059c5'

Media.PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}