local playerGUID = UnitGUID("player")
local rings = {
    ["Nithramus"] = 187616, -- These are buff IDs
    ["Thorasus"] = 187619,
    ["Maalus"] = 187620
}
local rings2 = {}; for k, v in pairs(rings) do rings2[v] = k end
local bonusMap = {
    [0]   = 25.00,
    [622] = 25.71,
    [623] = 26.42,
    [624] = 27.19,
    [625] = 27.96,
    [626] = 28.73,
    [627] = 29.56,
    [628] = 30.38,
    [629] = 31.24,
    [630] = 32.13,
    [631] = 33.05,
    [632] = 33.99,
    [633] = 34.94,
    [634] = 35.95,
    [635] = 36.95,
    [636] = 38.02,
    [637] = 39.08,
    [638] = 40.21,
    [639] = 41.33,
    [640] = 42.51,
    [641] = 43.70
}
local accum = 0
local buffTime = 0
local unbuffTime = 0
local pct = nil

local band, bor = bit.band, bit.bor

local isMine_types = bor(COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_TYPE_PET, COMBATLOG_OBJECT_TYPE_GUARDIAN)
-- Returns true if flags indicate unit is myself, my pet, or my guardian
local function isMine(flags)
    return band(flags, isMine_types) ~= 0 and band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0
end

local function buffAbsent()
    if buffed then
        unbuffTime = GetTime()
        buffed = false
    end
end

local function recalc()
    for ring, _ in pairs(rings) do
        -- pct1 = from UnitBuff, pct2 = from item link
        local pct1, pct2
        pct1 = select(18, UnitBuff("player", ring))
        if pct1 then -- buff is active
            for i = 1, 2 do
                local link, bonus
                link = GetInventoryItemLink("player", _G["INVSLOT_FINGER"..i])
                if link then
                    gsub(link, "(%d+)\124h%["..ring, function(bonusStr) bonus = tonumber(bonusStr) end)
                    if bonus then
                        pct2 = bonusMap[bonus]
                        break
                    end
                end
            end
            if pct2 and abs(pct2 - pct1) <= 1 then
                pct = pct2
            else
                -- Occurs when ring is scaled down (e.g. timewalking); item link doesn't reflect that
                pct = pct1
            end
            if not buffed then
                accum = 0
                buffed = true
                buffTime = GetTime()
            end
            return
        end
    end
    buffAbsent()
end

local function doCombatTrigger(_, _, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)
    if destGUID == playerGUID then
        if subEvent == "SPELL_AURA_APPLIED" then
            local spellID = ...
            if rings2[spellID] then
                recalc()
                return
            end
        elseif subEvent == "SPELL_AURA_REMOVED" then
            local spellID = ...
            if rings2[spellID] then
                buffAbsent()
                return
            end
        end
    end
    
    if buffed then
        if sourceGUID == playerGUID and subEvent == "SPELL_DAMAGE" and rings[select(2, ...)] then
            buffAbsent()
            return
        end
        
        -- Count damage done by myself/pets to targets that are not myself/pets
        if isMine(sourceFlags) and not isMine(destFlags) and destName ~= "Prismatic Crystal" then
            local dmg, okill = 0, 0
            if subEvent == "SWING_DAMAGE" then
                dmg, okill = ...
            elseif subEvent == "RANGE_DAMAGE" or subEvent == "SPELL_DAMAGE" or subEvent == "SPELL_PERIODIC_DAMAGE" then
                dmg, okill = select(4, ...)
            else
                return
            end
            accum = accum + dmg - okill
        end
    end
end
aura_env.doCombatTrigger = doCombatTrigger

local function doText()
    if WeakAuras.IsOptionsOpen() then
        return "1.11m"
    end
    
    local t = GetTime()
    
    if buffed and t - buffTime > 17.5 then
        -- Assume buff has expired
        buffAbsent()
    end
    
    if not buffed and t - unbuffTime > 4 then
        return ""
    end
    
    local amt, guess, dispAmt
    if pct then
        amt = accum * pct / 100
        guess = false
    else
        amt = accum * 0.25
        guess = true
    end
    
    if amt < 10000 then -- 0 to 9999
        dispAmt = format("%.f", amt)
    elseif amt < 99950 then -- 10.0k to 99.9k
        dispAmt = format("%.1f", amt / 1000) .. "k"
    elseif amt < 999500 then -- 100k to 999k
        dispAmt = format("%.f", amt / 1000) .. "k"
    else -- 1.00m +
        dispAmt = format("%.2f", amt / 1000000) .. "m"
    end
    
    return (buffed and "|c00FF6699"..dispAmt.."|r" or dispAmt)
    .. (guess and "?" or "")
end
aura_env.doText = doText

recalc()
