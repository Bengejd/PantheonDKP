local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES

local Media = {}

-- The base path for all interface media
Media.PDKP_MEDIA_PATH = "Interface\\Addons\\PantheonDKP\\Media\\"

-- The base path for our frames
Media.PDKP_FRAMES_PATH = Media.PDKP_MEDIA_PATH .. "Frames\\"

-- The base path for our icons
Media.PDKP_ICONS_PATH = Media.PDKP_MEDIA_PATH .. "Icons\\"

-- Main Interface textures are denoted with "PDKPFrame-"
Media.PDKP_TEXTURE_BASE = Media.PDKP_FRAMES_PATH .. "PDKPFrame-"

-- FRAMES
Media.BID_FRAME = Media.PDKP_FRAMES_PATH .. 'BidFrame.tga'
Media.PDKP_BG = Media.PDKP_TEXTURE_BASE .. "BG.tga"

-- BORDERS
Media.SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
Media.SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"

-- TEXTURES
Media.CHAR_INFO_TEXTURE = 'Interface\\CastingBar\\UI-CastingBar-Border-Small'
Media.HIGHLIGHT_TEXTURE = 'Interface\\QuestFrame\\UI-QuestTitleHighlight'
Media.ARROW_TEXTURE = 'Interface\\MONEYFRAME\\Arrow-Left-Up'
Media.ROW_SEP_TEXTURE = 'Interface\\Artifacts\\_Artifacts-DependencyBar-BG'

-- MISC
Media.CLOSE_BUTTON_TEXT = "|TInterface\\Buttons\\UI-StopButton:0|t"
Media.TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"

Media.addon_version_hex = '0059C5'

local BackdropTemplateMixin = BackdropTemplateMixin
Media.BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate"
Media.BACKDROPTEMPLATE = Media.BackdropTemplate

Media.PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = Media.SCROLL_BORDER,
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}
Media.PaneColor = { 0.1, 0.1, 0.1, 0.5 }
Media.PaneBorderColor = { 0.4, 0.4, 0.4 }

Media.SolidBackDrop  = {
    bgFile = Media.PDKP_TEXTURE_BASE .. "BG.tga",
    edgeFile = Media.SCROLL_BORDER,
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

-- Publish API
MODULES.Media = Media