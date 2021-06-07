local _, core = ...;
local _G = _G;

local Media = core.PDKP:GetInst('Media')

Media.CLOSE_BUTTON_TEXT = "|TInterface\\Buttons\\UI-StopButton:0|t"
Media.TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"
Media.PDKP_TEXTURE_BASE = "Interface\\Addons\\PantheonDKP\\Media\\New_UI\\PDKPFrame-"
--Media.PDKP_TEXTURE_BASE = "Interface\\Addons\\PantheonDKP\\Media\\New_UI\\PDKPFrame-"
Media.SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
Media.SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
Media.CHAR_INFO_TEXTURE = 'Interface\\CastingBar\\UI-CastingBar-Border-Small'

Media.addon_version_hex = '0059C5'

Media.PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}