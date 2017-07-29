local A = aura_env

local nightbladeID = 195452
local nightbladeName = GetSpellInfo(nightbladeID)
local finalityNightbladeName = GetSpellInfo(197498)

local nightblades = {first = 1, last = 1}
local nightbladesLastCleaned = 0

local function addNightblade(r)
    nightblades[nightblades.last] = r
    nightblades.last = nightblades.last + 1
end

local function cleanNightblades()
    local now = GetTime()
    nightbladesLastCleaned = now
    for i = nightblades.first, nightblades.last - 1 do
        if now - nightblades[i].time >= 60 then
            nightblades.first = i + 1
            nightblades[i] = nil
        end
    end
end

function A.UNIT_SPELLCAST_SUCCEEDED(unitID, spell, rank, lineID, spellID)
    if unitID == "player" and spellID == nightbladeID then
        addNightblade({time = GetTime(),
                finality = UnitBuff("player", finalityNightbladeName, nil, "PLAYER"),
                target = UnitGUID("target")})
    end
end

function A.statusTrigger()
    local now = GetTime()
    if now - nightbladesLastCleaned >= 60 then
        cleanNightblades()
    end
    local _
    _, _, A.icon, A.stacks, _, A.duration, A.expirationTime = UnitDebuff(
    "target", nightbladeName, nil, "PLAYER")
    if not A.duration then
        return false -- nightblade is not on the target
    end
    local target = UnitGUID("target")
    for i = nightblades.last - 1, nightblades.first, -1 do
        if nightblades[i].target == target then
            A.glow = nightblades[i].finality -- glow if affected by finality
            break
        end
    end
    return true -- nightblade is on the target
end
