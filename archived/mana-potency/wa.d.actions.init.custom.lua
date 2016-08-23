-- Custom text refresh
local lastTextRefresh = 0
local textRefreshInterval = 0.05

-- Custom text string
local text = ""


local function refreshText()
    lastTextRefresh = GetTime()
    local mastery = GetMasteryEffect()
    local manaFrac = UnitPower("player", SPELL_POWER_MANA) / UnitPowerMax("player", SPELL_POWER_MANA)
    local damage = 100 + mastery * manaFrac
    local maxDamage = 100 + mastery
    local potency = damage / maxDamage
    text = format("%.f", potency * 100) .. "%%"
end

local function doText()
    local t = GetTime()
    if t - lastTextRefresh > textRefreshInterval then
        refreshText()
    end
    return text
end
aura_env.doText = doText

