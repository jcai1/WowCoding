--------------------------------------------------------------
-- Init
local A = aura_env
local R = WeakAuras.regions[A.id].region

local playerGUID                -- Stored UnitGUID("player")
local trinketID = 124518        -- Item ID for Libram of Vindication
local equipped                    -- Whether the trinket is equipped
local lastProc = 0                -- Time of last proc
local icd = 12                    -- ICD between procs
local refract = 6                -- Refractory period for proc detection

R.cooldown:SetReverse(false)

-- COMBAT_LOG_EVENT_UNFILTERED handler
local function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    -- Don't feel like checking heal/dmg/absorb cases for subEvent,
    -- so I cheat a little and check spellName directly.
    if select(2, ...) == "Savior's Boon" and sourceGUID == playerGUID then
        local t = GetTime()
        if t - lastProc > refract then
            lastProc = t
            CooldownFrame_SetTimer(R.cooldown, lastProc, icd, true)
        end
    end
end

-- Checks whether Libram of Vindication is equipped
local function isTrinketEquipped()
    return (GetInventoryItemID("player", INVSLOT_TRINKET1) == trinketID
        or GetInventoryItemID("player", INVSLOT_TRINKET2) == trinketID)
end

-- PLAYER_EQUIPMENT_CHANGED handler
local function onEquipmentChanged()
    equipped = isTrinketEquipped()
end

-- Called immediately, but also after PLAYER_ENTERING_WORLD with delay.
-- This prevents issues with cold login.
local function doDelayedLoad()
    onEquipmentChanged() -- Check whether equipped
    playerGUID = UnitGUID("player") -- Initialize playerGUID
end
doDelayedLoad()

-- PLAYER_ENTERING_WORLD handler
local function onEnteringWorld()
    C_Timer.After(1, doDelayedLoad) -- Set up delayed load
end

-- What the trigger should return. true => shown, false => hidden.
local function shouldShow()
    -- Show WA only if equipped
    return equipped
end

-- Trigger dispatch handler
-- We ignore return value of dispatch functions, and instead use shouldShow()
local dispatchTable = {
    ["COMBAT_LOG_EVENT_UNFILTERED"] = onCombatEvent,
    ["PLAYER_EQUIPMENT_CHANGED"] = onEquipmentChanged,
    ["PLAYER_ENTERING_WORLD"] = onEnteringWorld,
}
local function doTrigger(event, ...)
    local dispatchFunc = dispatchTable[event]
    dispatchFunc(...)
    return shouldShow()
end
A.doTrigger = doTrigger
