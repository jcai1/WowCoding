local A = aura_env
local icon

local garrotes = {first = 1, last = 1}
local garrotesLastCleaned = 0

local function addGarrote(r)
    garrotes[garrotes.last] = r
    garrotes.last = garrotes.last + 1
end

local function cleanGarrotes()
    local now = GetTime()
    garrotesLastCleaned = now
    for i = garrotes.first, garrotes.last-1 do
        if now - garrotes[i].time >= 60 then
            garrotes.first = i + 1
            garrotes[i] = nil
        end
    end
end

function A.UNIT_SPELLCAST_SUCCEEDED(unitID, spell, rank, lineID, spellID)
    if unitID == "player" and spell == "Garrote" then
        addGarrote({time = GetTime(), stealthed = IsStealthed() or UnitBuff("player", "Subterfuge", nil, "PLAYER"), target = UnitGUID("target")})
    end
end

function A.statusTrigger()
    local now = GetTime()
    if now - garrotesLastCleaned >= 60 then
        cleanGarrotes()
    end
    if not UnitDebuff("target", "Garrote", nil, "PLAYER") then
        return false -- garrote is not on the target
    end
    local target = UnitGUID("target")
    for i = garrotes.last-1, garrotes.first, -1 do
        local r = garrotes[i]
        if r.target == target then
            if r.stealthed then
                icon = "Interface\\Icons\\rogue_subterfuge"
                return true -- garrote affected by subterfuge
            else
                return false -- garrote not affected by subterfuge
            end
        end
    end
    icon = "Interface\\icons\\inv_misc_questionmark"
    return true -- unknown whether affected by subterfuge
end

function A.iconFunc()
    return icon
end
