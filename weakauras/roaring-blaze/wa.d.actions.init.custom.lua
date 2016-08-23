----- Roaring Blaze -----
local A = aura_env
-- local R = WeakAuras.regions[A.id].region
-- local S = WeakAurasSaved.displays[A.id]
local playerGUID = UnitGUID("player")

----- Set options here -----
local refreshRate = 20

----- Utility -----
local now
local refreshInterval = 1 / refreshRate
local lastRefresh     = -refreshInterval - 1
local customText
local shouldShow      = true
local isOptionsOpen   = WeakAuras.IsOptionsOpen
local playerGUID      = UnitGUID("player")

----- Main logic -----
local rbCounts = {}
local rbMults = {[0] = "1.00", [1] = "1.25", [2] = "1.56", [3] = "1.95"}

local function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _,
    destGUID, destName, destFlags, _, spellID, spellName, _, ...)
    
    if spellID == 17962 then
        if subEvent == "SPELL_DAMAGE" then
            rbCounts[destGUID] = (rbCounts[destGUID] or 0) + 1
        end
    elseif spellID == 157736 then
        if strsub(subEvent, 1, 11) == "SPELL_AURA_" then
            rbCounts[destGUID] = (subEvent ~= "SPELL_AURA_REMOVED") and 0 or nil
        end
    end
end

local function onRefresh()
    if UnitDebuff("target", "Immolate", nil, "PLAYER") then
        customText = rbMults[rbCounts[UnitGUID("target")]] or "???"
    else
        customText = isOptionsOpen() and "1.00" or ""
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
