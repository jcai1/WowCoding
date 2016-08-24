----- Demonwrath Targets -----
local A = aura_env
local R = WeakAuras.regions[A.id].region
-- local S = WeakAurasSaved.displays[A.id]
local playerGUID = UnitGUID("player")

----- Set options here -----
local refreshThrottle = 100

----- Utility -----
local now
local refreshInterval = 1 / refreshThrottle
local lastRefresh     = -refreshInterval - 1
local customText
local shouldShow      = true
local isOptionsOpen   = WeakAuras.IsOptionsOpen
local playerGUID      = UnitGUID("player")

----- GUI -----
local widgetName    = "DemonwrathTargets"
local squareTexture = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White"

----- Main logic -----
local state = "ready"  -- ready, collect
local counter = 0
local lastTransition = -999

local function initGUI()
    local bgName = widgetName.."BG"
    
    R.bg = R.bg or R:CreateTexture(bgName, "MEDIUM")
    R.bg:ClearAllPoints()
    R.bg:SetAllPoints(R)
    R.bg:SetTexture("Interface\\Icons\\spell_warlock_demonwrath")
    R.bg:SetVertexColor(1, 1, 1, 0)
    R.bg:Show()
    
    R.bgAnimGroup = R.bgAnimGroup or R.bg:CreateAnimationGroup(bgName.."AnimGroup")
    R.bgAnim = R.bgAnim or R.bgAnimGroup:CreateAnimation("Alpha", bgName.."Anim")
    R.bgAnim:SetFromAlpha(1)
    R.bgAnim:SetToAlpha(0)
    R.bgAnim:SetDuration(0.25)
    R.bgAnim:SetSmoothing("IN")
end

local function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _,
    destGUID, destName, destFlags, _, spellID, spellName, _, ...)
    
    if sourceGUID == playerGUID and subEvent == "SPELL_DAMAGE" and spellID == 193439 then
        if state == "ready" then
            state = "collect"
            counter = 0
            lastTransition = now
            R.bgAnim:SetDuration(0.5 / (1 + .01 * GetHaste()))
            R.bgAnimGroup:Play()
        end
        if state == "collect" then
            counter = counter + 1
        end
    end
end

local function onRefresh()
    if state == "collect" then
        if now - lastTransition > 0.20 then
            state = "ready"
            lastTransition = now
        end
        customText = tostring(counter)
    elseif state == "ready" then
        customText = (now - lastTransition < 2.0) and tostring(counter) or ""
    end
end

local function doCustomText()
    now = GetTime()
    if now - lastRefresh >= refreshInterval then
        onRefresh()
        lastRefresh = now
    end
    return customText
end
A.doCustomText = doCustomText

local triggerDispatch = {
    ["COMBAT_LOG_EVENT_UNFILTERED"] = onCombatEvent,
}
local function doTrigger(event, ...)
    now = GetTime()
    triggerDispatch[event](...)
    return shouldShow
end
A.doTrigger = doTrigger

initGUI()
