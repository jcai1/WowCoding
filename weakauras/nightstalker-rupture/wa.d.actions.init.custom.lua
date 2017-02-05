local A = aura_env
local icon

local ruptures = {first = 1, last = 1}
local rupturesLastCleaned = 0

local function addRupture(r)
    ruptures[ruptures.last] = r
    ruptures.last = ruptures.last + 1
end

local function cleanRuptures()
    local now = GetTime()
    rupturesLastCleaned = now
    for i = ruptures.first, ruptures.last-1 do
        if now - ruptures[i].time >= 60 then
            ruptures.first = i + 1
            ruptures[i] = nil
        end
    end
end

function A.UNIT_SPELLCAST_SUCCEEDED(unitID, spell, rank, lineID, spellID)
    if unitID == "player" and spell == "Rupture" then
        addRupture({time = GetTime(), stealthed = IsStealthed(), target = UnitGUID("target")})
    end
end

function A.statusTrigger()
    local now = GetTime()
    if now - rupturesLastCleaned >= 60 then
        cleanRuptures()
    end
    if not UnitDebuff("target", "Rupture", nil, "PLAYER") then
        return false -- rupture is not on the target
    end
    local target = UnitGUID("target")
    for i = ruptures.last-1, ruptures.first, -1 do
        local r = ruptures[i]
        if r.target == target then
            if r.stealthed then
                icon = "Interface\\Icons\\ability_stealth"
                return true -- rupture affected by nightstalker
            else
                return false -- rupture not affected by nightstalker
            end
        end
    end
    icon = "Interface\\icons\\inv_misc_questionmark"
    return true -- unknown whether affected by nightstalker
end

function A.iconFunc()
    return icon
end
