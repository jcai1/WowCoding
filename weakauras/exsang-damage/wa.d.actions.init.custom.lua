----- WeakAura Name (Init) -----
local A = aura_env
local R = WeakAuras.regions[A.id].region
local S = WeakAurasSaved.displays[A.id]

----- Set options here -----
local refreshRate = 30

----- Custom text -----
local customText = ""
local refreshInterval = 1 / refreshRate
local lastRefresh = -999
local exsangIconString = "|TInterface\\Icons\\ability_deathwing_bloodcorruption_earth:0|t"

----- Main logic -----
--[[
    [damage] and not [end]: ongoing accumulation
    [damage] and     [end]: accumulation ended, but still displaying value
not [damage] and     [end]: accumulation ended, no longer displaying value
]]
local exsangTime = -999
local exsangTarget = "Dummy"
local bleedDamage
local ruptureLastTick, ruptureEnd
local garroteLastTick, garroteEnd

----- Utility -----
local now  -- Current value of GetTime()
local playerGUID = UnitGUID("player")
local exsangIconString = "|TInterface\\Icons\\ability_deathwing_bloodcorruption_earth:0|t"

-- pretty-print damage amount
local function damagePP(amt)
    if amt < 10000 then -- 0 to 9999
        return format("%.f", amt)
    elseif amt < 99950 then -- 10.0k to 99.9k
        return format("%.1fk", amt / 1000)
    elseif amt < 999500 then -- 100k to 999k
        return format("%.fk", amt / 1000)
    else -- 1.00m +
        return format("%.2fm", amt / 1000000)
    end
end

local function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)
    if sourceGUID == playerGUID then
        if ... == 1943 and destGUID == exsangTarget and not ruptureEnd then
            if subEvent == "SPELL_PERIODIC_DAMAGE" then
                local damage, overkill = select(4, ...)
                bleedDamage = bleedDamage + damage - overkill
                ruptureLastTick = now
            elseif subEvent == "SPELL_AURA_REMOVED" or subEvent == "SPELL_AURA_REFRESH" or subEvent == "SPELL_AURA_APPLIED" then
                ruptureEnd = now
            end
        elseif ... == 703 and destGUID == exsangTarget and not garroteEnd then
            if subEvent == "SPELL_PERIODIC_DAMAGE" then
                local damage, overkill = select(4, ...)
                bleedDamage = bleedDamage + damage - overkill
                garroteLastTick = now
            elseif subEvent == "SPELL_AURA_REMOVED" or subEvent == "SPELL_AURA_REFRESH" or subEvent == "SPELL_AURA_APPLIED" then
                garroteEnd = now
            end
        elseif ... == 200806 and subEvent == "SPELL_CAST_SUCCESS" then
            exsangTime = now
            exsangTarget = destGUID
            bleedDamage = 0
            ruptureLastTick = now -- not really, but doesn't matter
            garroteLastTick = now
            ruptureEnd = nil
            garroteEnd = nil
        end
    end
end

local function makeCustomText()
    if not bleedDamage then return end
    if not ruptureEnd and now - ruptureLastTick > 4 then
        ruptureEnd = now - 4
    end
    if not garroteEnd and now - garroteLastTick > 4 then
        garroteEnd = now - 4
    end
    if ruptureEnd and garroteEnd and now - max(ruptureEnd, garroteEnd) > 3 then
        bleedDamage = nil
        return
    end
    local damageStr = damagePP(bleedDamage)
    if not (ruptureEnd and garroteEnd) then
        damageStr = "|cffff6699"..damageStr.."|r"
    end
    return exsangIconString..damageStr
end

local function doCustomText()
    now = GetTime()
    if now - lastRefresh > refreshInterval then
        customText = makeCustomText() or ""
        if customText == "" and WeakAuras.IsOptionsOpen() then
            customText = exsangIconString.."100.0k"
        end
        lastRefresh = now
    end
    return customText
end
A.doCustomText = doCustomText

local function doTrigger(event, ...)
    now = GetTime()
    onCombatEvent(...)
    return true
end
A.doTrigger = doTrigger

