local A = aura_env
local playerGUID = UnitGUID("player")
local legendary
local absorbLeft = 0

local function checkLegendary()
    legendary = IsEquippedItem("Cenedril, Reflector of Hatred")
end

checkLegendary()
C_Timer.After(5, checkLegendary)

function A.PLAYER_EQUIPMENT_CHANGED(slot, hasItem)
    if slot == INVSLOT_BACK then
        if hasItem then
            checkLegendary()
        else
            legendary = false
        end
    end
end

function A.COMBAT_LOG_EVENT_UNFILTERED(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)
    if subEvent == "SPELL_CAST_SUCCESS" and sourceGUID == playerGUID then
        local spellID, spellName, _ = ...
        if spellName == "Touch of Karma" then
            absorbLeft = (legendary and 2 or 0.5) * (UnitHealthMax("player") or 0)
        end
    elseif subEvent == "SPELL_ABSORBED" and destGUID == playerGUID then
        local index = (... == destGUID) and 5 or 8
        local absorbSpellID, absorbSpellName, _, absorbAmount = select(index, ...)
        if absorbSpellName == "Touch of Karma" then
            absorbLeft = absorbLeft - absorbAmount
        end
    end
end

-- round an integer to about 3 significant figures with suffix, e.g. 24.5k
local kSuffixes = {"k", "m", "b", "t", "q"}
local function intToString3(x)
    if x < x then
        return "NaN"
    elseif x == math.huge then
        return "+Inf"
    elseif x == -math.huge then
        return "-Inf"
    elseif x < 0 then
        return "-"..intToString3(-x)
    elseif x < 10000 then
        return format("%.f", x)
    else
        local cap, div, count, subcount, final = 99500, 1000, 1, 1, false
        while true do
            if x < cap or (subcount == 2 and not kSuffixes[count + 1]) then
                return format("%."..(2-subcount).."f", x / div)..kSuffixes[count]
            end
            subcount = subcount + 1
            cap = cap * 10
            if subcount == 3 then
                subcount = 0
                count = count + 1
                div = div * 1000
            end
        end
    end
end

function A.customTextFunc()
    return intToString3(absorbLeft)
end
