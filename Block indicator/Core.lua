-----Mod 兰娜瑟爾-盖斯 @CN

local addon, ns = ...
local cfg = ns.cfg

local function CreateIcon(texture, parent)
    local icon = CreateFrame("Frame", nil, parent)
    icon:SetWidth(cfg.size)
    icon:SetHeight(cfg.size)
    icon:SetScale(cfg.scale)
    icon:SetFrameStrata(cfg.strata)
    icon:SetAlpha(cfg.inactiveAlpha)
    icon.texture = icon:CreateTexture(nil, "BACKGROUND")
    icon.texture:SetAllPoints(icon)
    icon.texture:SetTexture(texture)
    icon.texture:SetVertexColor(cfg.unavailableTint[1], cfg.unavailableTint[2], cfg.unavailableTint[3])
    if not cfg.showFrames then
        icon.texture:SetTexCoord(0.1, 0.8, 0.1, 0.8)
    end  
    icon.glow = CreateFrame("Frame", nil, icon, "ActionBarButtonSpellActivationAlert")
    icon.glow:SetWidth(cfg.size * 1.6)
    icon.glow:SetHeight(cfg.size * 1.6)
    icon.glow:SetScale(cfg.scale)
    icon.glow:SetPoint("CENTER", icon, -1, -1);
    icon.glow.spark:SetVertexColor(cfg.glowColor[1], cfg.glowColor[2], cfg.glowColor[3])
    icon.glow.innerGlow:SetVertexColor(cfg.glowColor[1], cfg.glowColor[2], cfg.glowColor[3])
    icon.glow.innerGlowOver:SetVertexColor(cfg.glowColor[1], cfg.glowColor[2], cfg.glowColor[3])
    icon.glow.outerGlow:SetVertexColor(cfg.glowColor[1], cfg.glowColor[2], cfg.glowColor[3])
    icon.glow.outerGlowOver:SetVertexColor(cfg.glowColor[1], cfg.glowColor[2], cfg.glowColor[3])
    icon.glow.ants:SetVertexColor(cfg.glowColor[1], cfg.glowColor[2], cfg.glowColor[3])
    icon.glow:SetAlpha(0)
    icon.glow.animIn:Play()
    icon.durationText = icon:CreateFontString(nil, "OVERLAY")
    icon.durationText:SetJustifyH(cfg.durationTextJustifyH)
    icon.durationText:SetPoint(cfg.durationTextAnchor, cfg.durationTextX, cfg.durationTextY)
    icon.durationText:SetFont(cfg.font, cfg.durationTextSize, cfg.fontOutline)	
    icon.durationText:SetTextColor(cfg.durationTextColor[1], cfg.durationTextColor[2], cfg.durationTextColor[3], 1)
    icon.durationText:SetText("")
    icon.infoText = icon:CreateFontString(nil, "OVERLAY")
    icon.infoText:SetJustifyH(cfg.infoTextJustifyH)
    icon.infoText:SetPoint(cfg.infoTextAnchor, cfg.infoTextX, cfg.infoTextY)
    icon.infoText:SetFont(cfg.font, cfg.infoTextSize, cfg.fontOutline)	
    icon.infoText:SetTextColor(cfg.infoTextColorInactive[1], cfg.infoTextColorInactive[2], cfg.infoTextColorInactive[3], 1)
    icon.infoText:SetText("") 
    icon:EnableMouse(false)
    return icon
end

local active = false
local playerName = UnitName("player") 
local currentRage = 0
local estimatedAbsorb = 0
local totalBlocked = 0;
local estimatedBlock = 0;
local shieldBlockActive = false
local shieldBarrierSpellId = 112048
local shieldBlockSpellId = 132404
local shieldBarrierSpellName, _, shieldBarrierTexture = GetSpellInfo(shieldBarrierSpellId)
local shieldBlockSpellName, _, shieldBlockTexture = GetSpellInfo(shieldBlockSpellId)

local main =  CreateFrame("Frame", nil, UIParent)
main:SetPoint(cfg.anchor, cfg.x, cfg.y)
main.background = main:CreateTexture(nil, "BACKGROUND")
main.background:SetTexture(cfg.backgroundColor[1], cfg.backgroundColor[2], cfg.backgroundColor[3], cfg.backgroundAlpha)
main.background:SetAllPoints(main)
main:SetWidth(2 * cfg.size + 3 * cfg.margin)
main:SetHeight(cfg.size + 2 * cfg.margin)
main:SetScale(cfg.scale)
local shieldBarrierIcon = CreateIcon(shieldBarrierTexture, main)
local shieldBlockIcon = CreateIcon(shieldBlockTexture, main)	
shieldBarrierIcon:SetPoint("TOPLEFT", main, "TOPLEFT", cfg.margin, -cfg.margin)
shieldBlockIcon:SetPoint("TOPRIGHT", main, "TOPRIGHT", -cfg.margin, -cfg.margin)

shieldBarrierIcon.bar = shieldBarrierIcon:CreateTexture(nil, "ARTWORK")
shieldBarrierIcon.bar:SetTexture(cfg.barColor[1], cfg.barColor[2], cfg.barColor[3], cfg.barAlpha)
shieldBarrierIcon.bar:SetPoint("BOTTOMLEFT", shieldBarrierIcon, "BOTTOMLEFT")
shieldBarrierIcon.bar:SetPoint("BOTTOMRIGHT", shieldBarrierIcon, "BOTTOMRIGHT")
shieldBarrierIcon.bar.max = 0

local function FormatNumber(number)
    if not cfg.truncatedNumbers then
        number = floor(number)
        local left,middle,right = string.match(number,"^([^%d]*%d)(%d*)(.-)$")
        return left..(middle:reverse():gsub("(%d%d%d)","%1,"):reverse())..right
    elseif number > 1E10 then
        return floor(number / 1E9).."b"
    elseif number > 1E9 then
        return (floor((number / 1E9) * 10) / 10).."b"
    elseif number > 1E7 then
        return floor(number / 1E6).."m"
    elseif number > 1E6 then
        return (floor((number / 1E6) * 10) / 10).."m"
    elseif number > 1E4 then
        return floor(number / 1E3).."k"
    elseif number > 1E3 then
        return (floor((number / 1E3) * 10) / 10).."k"
    else
        return floor(number)
    end
end


local function RoundNumber(number)
    return math.floor(number + 0.5)
end


local function UpdateTint(icon, requiredRage)
    if currentRage < requiredRage then
        icon.texture:SetVertexColor(cfg.unavailableTint[1], cfg.unavailableTint[2], cfg.unavailableTint[3])
    else
        icon.texture:SetVertexColor(1, 1, 1)  
    end
end


local function CalculateEstimatedAbsorbValue(rage)
    local baseAttackPower, positiveBuff, negativeBuff = UnitAttackPower("player")
    local attackPower = baseAttackPower + positiveBuff + negativeBuff
    local _, strength = UnitStat("player", 1)
    local _, stamina = UnitStat("player", 3)
    local rageMultiplier = max(20, min(60, rage)) / 60.0
    return max(1.8 * (attackPower - 2 * strength), stamina * 2.5) * rageMultiplier
end

local amounts = nil
local function AddToMovingSum(value)
    local systemTime = GetTime()

    amounts = { next = amounts, amount = value, time = systemTime }
end

local function UpdateEstimatedBlock()
    local systemTime = GetTime()
      
    local sum = 0
    local current = amounts
    while current do
        if systemTime - current.time > 6 then
            current.next = nil
        else
            sum = sum + current.amount
        end
        current = current.next
    end
    
    local masteryValue = GetMastery()
    local criticalBlockChance = (masteryValue / 272.7 * 1.5) + (8 * 1.5)
    estimatedBlock = sum * criticalBlockChance * 0.6 + sum * (1 - criticalBlockChance) * 0.3
end

local function UpdateBar(absorb)
    if absorb > 0 then
        if shieldBarrierIcon.bar.max < absorb then
            shieldBarrierIcon.bar.max = absorb
        end
        shieldBarrierIcon.bar:Show()
        shieldBarrierIcon.bar:SetHeight(cfg.size * (absorb / shieldBarrierIcon.bar.max))        
    else
       shieldBarrierIcon.bar.max = 0
       shieldBarrierIcon.bar:Hide()
    end
end

local function ShowGlow(icon)
    if cfg.showGlow then
        icon.glow:Show()
    end
end

local function HideGlow(icon)
    icon.glow:Hide()
end

local function UpdateGlow()
    local shieldBarrier = UnitBuff("player", shieldBarrierSpellName)
    local shieldBlock = UnitBuff("player", shieldBlockSpellName)
    if shieldBarrier or shieldBlock or currentRage < 20 then
        HideGlow(shieldBarrierIcon)
        HideGlow(shieldBlockIcon)
    else   
        if CalculateEstimatedAbsorbValue(60) >= estimatedBlock then   
            if currentRage >= 20 then
                ShowGlow(shieldBarrierIcon)
                HideGlow(shieldBlockIcon)
            end
        else
            if currentRage >= 60 then
                ShowGlow(shieldBlockIcon)
                HideGlow(shieldBarrierIcon)
            end
        end
    end
end

local function UpdateShieldBarrierIcon()
    local name, _, _, _, _, _, expires, _, _, _, _, _, _, _, absorb = UnitBuff("player", shieldBarrierSpellName)
    if name then
        UpdateTint(shieldBarrierIcon, 0)
        UpdateBar(absorb)
        shieldBarrierIcon.infoText:SetTextColor(cfg.infoTextColorActive[1], cfg.infoTextColorActive[2], cfg.infoTextColorActive[3], 1)
        local systemTime = GetTime()
        shieldBarrierIcon.infoText:SetText(FormatNumber(absorb))        
        shieldBarrierIcon.durationText:SetText(RoundNumber(expires - systemTime))
        shieldBarrierIcon:SetAlpha(cfg.activeAlpha)
    else
        shieldBarrierIcon:SetAlpha(cfg.inactiveAlpha)
        UpdateTint(shieldBarrierIcon, 20)
        UpdateBar(0)
        shieldBarrierIcon.infoText:SetTextColor(cfg.infoTextColorInactive[1], cfg.infoTextColorInactive[2], cfg.infoTextColorInactive[3], 1)
        shieldBarrierIcon.infoText:SetText(FormatNumber(estimatedAbsorb)) 
        shieldBarrierIcon.durationText:SetText("")        
    end
end

local function UpdateShieldBlockIcon()
    local name, _, _, _, _, _, expires = UnitBuff("player", shieldBlockSpellName)
    if name then
        UpdateTint(shieldBlockIcon, 0)
        shieldBlockIcon.infoText:SetText(FormatNumber(totalBlocked))
        shieldBlockIcon.infoText:SetTextColor(cfg.infoTextColorActive[1], cfg.infoTextColorActive[2], cfg.infoTextColorActive[3], 1)
        local systemTime = GetTime()
        shieldBlockIcon.durationText:SetText(RoundNumber(expires - systemTime))
        shieldBlockIcon:SetAlpha(cfg.activeAlpha)
    else
        shieldBlockIcon:SetAlpha(cfg.inactiveAlpha)
        UpdateTint(shieldBlockIcon, 60)
        shieldBlockIcon.infoText:SetText(FormatNumber(estimatedBlock))
        shieldBlockIcon.infoText:SetTextColor(cfg.infoTextColorInactive[1], cfg.infoTextColorInactive[2], cfg.infoTextColorInactive[3], 1)
        shieldBlockIcon.durationText:SetText("")     
    end
end

local function Tick() 
    estimatedAbsorb = CalculateEstimatedAbsorbValue(currentRage)
    UpdateEstimatedBlock()
    UpdateGlow()
    UpdateShieldBarrierIcon()
    UpdateShieldBlockIcon()
end
 
local function Load()
    local _, class = UnitClassBase("player")
    local spec = GetSpecialization() or -1
    if class == "WARRIOR" and spec == 3 then
        active = true
        if UnitAffectingCombat("player") or not cfg.hiddenOutOfCombat then
            main:Show()
        else
            main:Hide()
        end
        
        estimatedAbsorb = CalculateEstimatedAbsorbValue(currentRage)
        
        print("|c00C79C6EBlock indicator:|r |c0000FF00loaded|r")
    else
        active = false
        main:Hide()
        
        print("|c00C79C6EBlock indicator:|r |c00FF0000unloaded|r")
    end
end

local handlers, listeners = {}, {}

function handlers:COMBAT_LOG_EVENT_UNFILTERED(...)
    local eventType = select(2, ...)
    local target = select(9, ...)
    local spellId = select(12, ...)
    if (eventType == "SWING_DAMAGE" or eventType == "SPELL_DAMAGE") and target == playerName and shieldBlockActive then  
        local blocked = select(16, ...) 
        if blocked and blocked > 0 then
            totalBlocked = totalBlocked + blocked
        end
    end 
    if eventType == "SPELL_AURA_APPLIED" and spellId == shieldBlockSpellId and target == playerName then
        shieldBlockActive = true
        totalBlocked = 0;
    end 
    if eventType == "SPELL_AURA_REMOVED" and spellId == shieldBlockSpellId and target == playerName then
        shieldBlockActive = false
    end 
    if (eventType == "SWING_DAMAGE" or eventType == "SPELL_DAMAGE") and target == playerName then
        local damage = select(eventType == "SWING_DAMAGE" and 12 or 15, ...) or 0
        local school = select(14, ...)
        local blocked = select(16, ...) or 0
        local absorbed = select(17, ...) or 0
        if bit.band(school, 1) ~= 0 then
            AddToMovingSum(damage + blocked + absorbed)
        end
    end
    if (eventType == "SWING_MISSED" or eventType == "SPELL_MISSED") and target == playerName then
        local missType = select(eventType == "SWING_MISSED" and 12 or 15, ...)
        local school = select(eventType == "SWING_MISSED" and 13 or 14, ...) or 1
        local absorbed = select(eventType == "SWING_MISSED" and 14 or 17, ...) or 0
        if missType == "ABSORB" and bit.band(school, 1) ~= 0 then
            AddToMovingSum(absorbed)
        end
    end
end

function handlers:UNIT_POWER(...)
    local unitId = select(1, ...)
    if unitId == "player" then
        currentRage = UnitPower("player", SPELL_POWER_RAGE)
    end
end

function handlers:PLAYER_REGEN_ENABLED(...)
	if cfg.hiddenOutOfCombat then
		main:Hide()
	end
end

function handlers:PLAYER_REGEN_DISABLED(...)
	if cfg.hiddenOutOfCombat then
		main:Show()
	end
end

function listeners:ACTIVE_TALENT_GROUP_CHANGED(...)
    Load()
end

function listeners:PLAYER_LOGIN(...)
    Load()
end

for k, v in pairs(handlers) do
    main:RegisterEvent(k);
end
for k, v in pairs(listeners) do
    main:RegisterEvent(k);
end

local elapsedTime = 0.0
local function OnUpdateHandler(self, seconds)
    elapsedTime = elapsedTime + seconds
    while active and elapsedTime > cfg.updateInterval do
        Tick()
        elapsedTime = elapsedTime - cfg.updateInterval
    end
end

local function OnEventHandler(self, event, ...)
    if active and handlers[event] then
        handlers[event](self, ...)
    end
    if listeners[event] then
        listeners[event](self, ...)
    end
end

main:SetScript("OnUpdate", OnUpdateHandler)
main:SetScript("OnEvent", OnEventHandler)