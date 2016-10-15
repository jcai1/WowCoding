local A = aura_env
local playerGUID = UnitGUID("player")

local function colorText(c, s)
    return format("|cff%s%s|r", c, s)
end

local readyText  = colorText("00ff00", "Ready")
local icdText    = colorText("ffff00", "ICD")
local activeText = colorText("ffffff", "Active")

local equipped
local customText = readyText
local icdEnd
local duration, expires

local function checkEquipped()
    equipped = IsEquippedItem("Sephuz's Secret")
end

checkEquipped()
C_Timer.After(5, checkEquipped)

function A.PLAYER_EQUIPMENT_CHANGED(slot, hasItem)
    if slot == INVSLOT_FINGER1 or slot == INVSLOT_FINGER2 then
        checkEquipped()
    end
end

local function buffRemoved() -- idempotent
    if icdEnd then -- in case reloaded while active
        customText = icdText
        duration = 20
        expires = icdEnd
    end
end

local function icdEnded()
    if GetTime() >= icdEnd then -- avoid race
        customText = readyText
        icdEnd = nil
        duration = nil
        expires = nil
    end
end

local function buffApplied()
    local now = GetTime()
    customText = activeText
    icdEnd = now + 30
    duration = 10
    expires = now + 10
    C_Timer.After(10, buffRemoved)
    C_Timer.After(30, icdEnded)
end

function A.COMBAT_LOG_EVENT_UNFILTERED(_, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)
    if equipped and destGUID == playerGUID then
        if event == "SPELL_AURA_APPLIED" and select(2, ...) == "Sephuz's Secret" then
            buffApplied()
        elseif (event == "SPELL_AURA_REMOVED" and select(2, ...) == "Sephuz's Secret") or event == "UNIT_DIED" then
            buffRemoved()
        end
    end
end

function A.statusTrigger()
    return equipped
end

function A.customTextFunc()
    return customText
end

function A.durationFunc()
    return duration, expires
end
