-- The addon namespace and config frame.
local addon, ns = ...
local cfg = CreateFrame("Frame")
ns.cfg = cfg

-- General settings.
cfg.anchor                 = "CENTER"              -- Frame anchor. Possible values are: "TOP", "RIGHT", "BOTTOM", "LEFT", "TOPRIGHT", "TOPLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER".
cfg.strata                 = "MEDIUM"              -- Frame strata.
cfg.x                      = 0                     -- x-offset.
cfg.y                      = -250                  -- y-offset.
cfg.margin                 = 5                     -- The margin around icons.
cfg.size                   = 60                    -- The icon width and height.
cfg.scale                  = 1                     -- The scale.
cfg.activeAlpha            = 1                     -- Transparency when buffs are active. 0 = fully transparent, 1 = fully opaque.
cfg.inactiveAlpha          = 0.7                   -- Transparency when buffs are inactive. 0 = fully transparent, 1 = fully opaque.
cfg.unavailableTint        = {0.4, 0.4, 1}         -- The rgb color-values of the tint used when abilities are unavailable due to low rage.
cfg.hiddenOutOfCombat      = false                 -- Indicates whether frames are hidden when out of combat.
cfg.showFrames             = false                 -- Show the icon frames (rounded corners).
cfg.showGlow               = true                  -- Show a glow around the ability with the highest predicted mitigation value.
cfg.glowColor              = {1, 1, 1}             -- The rgb color-value of the glow.
cfg.glowAlpha              = 1                     -- Glow transparency.
cfg.barColor               = {0, 1, 0}             -- The rgb color-value of the Shield Barrier bar.
cfg.barAlpha               = 0.5                   -- Shield Barrier bar transparency. Set this to 0 in order to hide the  bar.
cfg.backgroundColor        = {0, 0, 0}             -- The rgb color-value of the background.
cfg.backgroundAlpha        = 0.5                   -- Background transparency. Set this to 0 in order to hide the  bar.
cfg.updateInterval         = 0.1                   -- Time (in seconds) between updates.

-- Text settings.
cfg.font                   = "Fonts\\FRIZQT__.TTF" -- The font used for numbers on icons.
cfg.fontOutline            = "OUTLINE"             -- The font outline. Possible values are any comma-delimited combination of "OUTLINE", "THICKOUTLINE" and "MONOCHROME".
cfg.durationTextSize       = 30                    -- The size of the text that displays remaining buff duration.
cfg.durationTextColor      = {1, 1, 1}             -- The rgb color-values for the duration text. Use values between 0 and 1. 
cfg.durationTextJustifyH   = "CENTER"              -- Horizontal justification of the duration text. Possible values are: "CENTER, "LEFT", "RIGHT".
cfg.durationTextAnchor     = "CENTER"              -- The anchor of the duration text. The anchor is relative to the icon.
cfg.durationTextX          = 0                     -- x-offset for the duration text relative to the icon.
cfg.durationTextY          = 8                     -- y-offset for the duration text relative to the icon.
cfg.infoTextSize           = 16                    -- The size of the text that displays buff information.
cfg.infoTextColorActive    = {0, 1, 0}             -- The rgb color-values for the info text when buffs are active. Use values between 0 and 1.
cfg.infoTextColorInactive  = {1, 1, 1}             -- The rgb color-values for the info text when buffs are inactive. Use values between 0 and 1.
cfg.infoTextJustifyH       = "CENTER"              -- Horizontal justification of the info text. Possible values are: "CENTER, "LEFT", "RIGHT".
cfg.infoTextAnchor         = "CENTER"              -- The anchor of the info text. The anchor is relative to the icon.
cfg.infoTextX              = 3                     -- x-offset for the info text relative to the icon.
cfg.infoTextY              = -16                   -- y-offset for the info text relative to the icon.
cfg.truncatedNumbers       = true                  -- Truncate numbers, ie. 12345 --> 12k.