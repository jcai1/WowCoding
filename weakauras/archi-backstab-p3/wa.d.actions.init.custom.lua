local refresh = 0.05
local goodColor = "00dd00"
local badColor = "ff0000"

local A, t = aura_env, GetTime()
A.t = 0
A.dt = refresh
A.display = ""
A.phase = 1

local P3Spells = {"Dark Pursuit", "Eternal Flame", "Dark Conduit", "Mark of the Legion",
"Summon Source of Chaos", "Seething Corruption", "Twisted Darkness", "Nether Ascension"}
local P12Spells = {"Allure of Flames", "Shackled Torment", "Wrought Chaos", "Death Brand",
"Desecrate", "Desecration"}
local by, bx = 4067.29, -2285.92

local band = bit.band

local function updatePhase(spellName)
    if P3Spells[spellName] then
        A.phase = 3
    elseif P12Spells[spellName] then
        A.phase = 1
    end
end
A.updatePhase = updatePhase

local function doCombatTrigger(
        event, timestamp, subEvent, hideCaster,
        sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags, ...
    )
    if subEvent == "SPELL_CAST_SUCCESS"
    and band(sourceFlags, COMBATLOG_OBJECT_REACTION_MASK) == COMBATLOG_OBJECT_REACTION_HOSTILE then
        local spellName = select(2, ...)
        updatePhase(spellName)
    end
end
A.doCombatTrigger = doCombatTrigger

local function updateDisplay()
    -- if A.phase ~= 3 then
    -- A.display = "--"
    -- return
    -- end
    local ty, tx = UnitPosition("boss1target")
    if ty then
        local py, px = UnitPosition("player")
        if py then
            local angle = atan2(py - by, px - bx) - atan2(ty - by, tx - bx)
            angle = (angle + 180) % 360 - 180
            local good = (angle > 45 or angle < -45)
            A.display = format("|cff%s%3.f|r", good and goodColor or badColor, angle)
            return
        end
    end
    A.display = "--"
end
A.updateDisplay = updateDisplay
