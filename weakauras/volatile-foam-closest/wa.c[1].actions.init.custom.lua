---- ToV/02GUA/Volatile Foam Closest ----
local A = aura_env
local guarmColors = {
    {debuff = "Fiery Phlegm",   foam = "Flaming Volatile Foam", color = "Orange", code = "ff8800"},
    {debuff = "Salty Spittle",  foam = "Briney Volatile Foam",  color = "Green",  code = "00ffaa"},
    {debuff = "Dark Discharge", foam = "Shadowy Volatile Foam", color = "Purple", code = "aa55aa"}
}
local FRC = {} -- Friendly Range Check
local noneColorCode = "ffffff"
local unsafeColorCode = "ff2222"
local maxSafeNearbyShown = 2
local maxUnsafeNearbyShown = 2

local refreshInterval = 0.15
local lastRefresh = 0
local customText = ""

local function colorize(colorCode, str)
    return format("|cff%s%s|r", colorCode, str)
end

local function checkColor(unit)
    for _, c in ipairs(guarmColors) do
        if UnitDebuff(unit, c.debuff) then
            return c
        end
    end
end

local function refresh(foamColor)
    local youLine = colorize(foamColor.code, format("%s on YOU!", foamColor.color))
    local youColor = checkColor("player")
    if (not youColor) or (foamColor == youColor) then
        return youLine.."\n".."Foam color matches!"
    end
    
    local safeNearby, unsafeNearby = {}, {}
    local extraSafeNearby, extraUnsafeNearby = 0, 0
    
    local closestUnits, closestRange = FRC:GetClosestInGroup()
    for i, unit in ipairs(closestUnits) do
        local theirColor  = checkColor(unit)
        local colorCode = theirColor and theirColor.code or noneColorCode
        local str = colorize(colorCode, tostring(UnitName(unit)))
        
        if theirColor == foamColor or not theirColor then
            if #safeNearby < maxSafeNearbyShown then
                tinsert(safeNearby, str)
            else
                extraSafeNearby = extraSafeNearby + 1
            end
        else
            if #unsafeNearby < maxUnsafeNearbyShown then
                tinsert(unsafeNearby, str)
            else
                extraUnsafeNearby = extraUnsafeNearby + 1
            end
        end
    end
    
    safeNearby = table.concat(safeNearby, " ")
    safeNearby = colorize(foamColor.code,  "Safe: ")..safeNearby
    if extraSafeNearby > 0 then
        safeNearby = safeNearby..colorize(foamColor.code, " +"..extraSafeNearby)
    end
    
    if #unsafeNearby == 0 and extraUnsafeNearby == 0 then
        customText = youLine.."\n"..safeNearby
        return
    end
    
    unsafeNearby = table.concat(unsafeNearby, " ")
    unsafeNearby = colorize(unsafeColorCode, "Unsafe: ")..unsafeNearby
    if extraUnsafeNearby > 0 then
        unsafeNearby = unsafeNearby..colorize(unsafeColorCode, " +"..extraUnsafeNearby)
    end
    customText = youLine.."\n"..safeNearby.."\n"..unsafeNearby
    return
end

function A.statusTrigger()
    local foamColor
    for _, c in ipairs(guarmColors) do
        if UnitDebuff("player", c.foam) then
            foamColor = c
            break
        end
    end
    
    local now = GetTime()
    if foamColor then
        if now - lastRefresh > refreshInterval then
            lastRefresh = now
            refresh(foamColor)
        end
        return true
    else
        customText = ""
        return false
    end
end

function A.customTextFunc()
    return customText
end

---- Friendly Range Check ----
FRC.items = {
    {1,    90175},
    {2,    63390},
    {3,    42732},
    {4,    129055},
    {5,    85267},
    {7,    88589},
    {8,    68678},
    {10,   79884},
    {15,   20235},
    {20,   88587},
    {25,   74771},
    {30,   22218},
    {35,   41505},
    {40,   52490},
    {45,   62794},
    {50,   116139},
    {55,   74637},
    {60,   50851},
    {70,   41265},
    {80,   42769},
    {90,   133925},
    {100,  109082},
    {200,  86546},
}

FRC.raidUnits, FRC.partyUnits, FRC.noUnits = {}, {}, {}
for i = 1, MAX_RAID_MEMBERS do
    FRC.raidUnits[i] = "raid"..i
end
for i = 1, MAX_PARTY_MEMBERS do
    FRC.partyUnits[i] = "party"..i
end

-- Range(0) = 0, Range(N+1) = infinity
-- 0 <= i <= N
-- range index <= i : unit is below Range(i+1)
-- range index >= i : unit is above Range(i)
-- range index == i : unit is between Range(i) and Range(i+1)

-- Returns true if unit's range index < threshold.
-- threshold may be fractional or infinite.
function FRC:RangeBelow(unit, threshold)
    local N = #self.items
    if threshold <= 0 then
        return false
    elseif threshold > N then
        return true
    else
        threshold = ceil(threshold)
        local itemID = self.items[threshold][2]
        return IsItemInRange(itemID, unit)
    end
end

-- Implementation of binary search to find the unit's range index.
-- Precondition (lb <= unit's range index <= ub) must be met.
-- lb: inclusive lower bound
-- ub: inclusive upper bound
-- recdepth: current recursion depth (safety check)
function FRC:_BSearch(unit, lb, ub, recdepth)
    assert(recdepth < 100)
    assert(lb <= ub)
    if lb == ub then
        return lb
    end
    local mid = ceil((lb + ub) / 2)
    if self:RangeBelow(unit, mid) then
        return self:_BSearch(unit, lb, mid - 1, recdepth + 1)
    else
        return self:_BSearch(unit, mid, ub, recdepth + 1)
    end
end

-- Finds the unit's range index, if between lb and ub.
-- lb: Optional, inclusive lower bound.
--     Returns lb - 1 if unit's range index < lb.
-- ub: Optional, inclusive upper bound.
--     Returns ub + 1 if unit's range index > ub.
function FRC:FindRange(unit, lb, ub)
    local N = #self.items
    lb = lb or 0
    ub = ub or N
    if self:RangeBelow(unit, lb) then
        return lb - 1
    end
    if not self:RangeBelow(unit, ub + 1) then
        return ub + 1
    end
    return self:_BSearch(unit, lb, ub, 0)
end

function FRC:GetClosestInGroupAux(scanUnits)
    local N = #self.items
    local closestUnits = {}
    local closestRange = N
    for _, unit in ipairs(scanUnits) do
        if UnitIsVisible(unit) and not UnitIsUnit(unit, "player") then
            local range = self:FindRange(unit, nil, closestRange)
            if range < closestRange then
                closestRange = range
                wipe(closestUnits)
                tinsert(closestUnits, unit)
            elseif range == closestRange then
                tinsert(closestUnits, unit)
            end
        end
    end
    return closestUnits, closestRange
end

function FRC:GetClosestInGroup()
    if IsInRaid() then
        return self:GetClosestInGroupAux(self.raidUnits)
    elseif IsInGroup() then
        return self:GetClosestInGroupAux(self.partyUnits)
    else
        return self:GetClosestInGroupAux(self.noUnits)
    end
end
