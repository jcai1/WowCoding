local A = aura_env
local customText = ""

local throttleInterval = 0.05
local lastRefresh = 0
local refreshPending = true

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

local function progressFractionToColor(frac)
    if not (frac and frac >= 0 and frac <= 1) then
        return "ffffff"
    end
    if frac <= 0.5 then
        return format("ff%02x00", frac * 511.999) -- red to yellow
    else
        return format("%02xff00", (1 - frac) * 511.999) -- yellow to green
    end
end

local GetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local GetCostForPointAtRank = C_ArtifactUI.GetCostForPointAtRank

local function calcCustomText()
    local itemID, altItemID, name, icon, xp, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop, artifactTier = GetEquippedArtifactInfo()
    if not itemID then return end
    
    local pointsAvailable = 0
    local nextRankCost = GetCostForPointAtRank(pointsSpent + pointsAvailable, artifactTier) or 0
    
    while xp >= nextRankCost do
        xp = xp - nextRankCost
        pointsAvailable = pointsAvailable + 1
        nextRankCost = GetCostForPointAtRank(pointsSpent + pointsAvailable, artifactTier) or 0
    end
    
    local fraction = xp / nextRankCost
    local bonusString = (pointsAvailable <= 0) and "" or format(", |cff00ff00%d available|r", pointsAvailable)
    
    return format("[AP: %s / %s (|cff%s%.1f%%|r), next in %s%s]",
        intToString3(xp), intToString3(nextRankCost),
        progressFractionToColor(fraction), fraction * 100,
        intToString3(nextRankCost - xp), bonusString)
end

function A.ARTIFACT_XP_UPDATE()
    refreshPending = true
end

function A.UNIT_INVENTORY_CHANGED(unit)
    if unit == "player" then
        refreshPending = true
    end
end

function A.customTextFunc()
    if refreshPending then
        local now = GetTime()
        if now - lastRefresh > throttleInterval then
            refreshPending = false
            customText = calcCustomText()
        end
    end
    return customText
end
