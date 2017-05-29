local A = aura_env
local customText = ""

local aliveColor = "ffff00"
local killedColor = "888888"
local numColumns = 5
local refreshInterval = 1

local rares = {
    {"Malgrazo", 46090},
    {"Salethan", 46091},
    {"MalorusS", 46092},
    {"Emberfir", 46093},
    {"PotGloop", 46094},
    {"FelmawEm", 46095},
    {"InqChill", 46096},
    {"DoomZart", 46097},
    {"DreadAnn", 46098},
    {"FelXarth", 46099},
    {"XorogunF", 46100},
    {"CorrBone", 46101},
    {"FelZelth", 46102},
    {"Dreadeye", 46202},
    {"LordHelN", 46304},
    {"ImpBruva", 46313},
    {"Flllurlo", 46951},
    {"Aqueux  ", 46953},
    {"BroodNix", 46965},
    {"Grossir ", 46995},
    {"BroBadat", 47001},
    {"LadyEldr", 47026},
    {"SombDawn", 47028},
    {"DukeSith", 47036},
    {"EyeGurgh", 47068},
}

local numRows = ceil(#rares / numColumns)

local stringPieces = {} -- table<table<string>>
local rowStrings = {} -- table<string>

for i = 1, numRows do
    local rowPieces = {}
    for j = 1, numColumns do
        local rare = rares[(i-1)*numColumns + j]
        if not rare then break end
        local name = rare[1]
        tinsert(rowPieces, "|cff")
        tinsert(rowPieces, aliveColor)
        tinsert(rowPieces, name..(j == numColumns and "" or " "))
        tinsert(rowPieces, "|r")
    end
    tinsert(stringPieces, rowPieces)
end

local function buildCustomText()
    local count = 0
    for i = 1, numRows do
        local rowPieces = stringPieces[i]
        for j = 1, numColumns do
            local rare = rares[(i-1)*numColumns + j]
            if not rare then break end
            local questID = rare[2]
            local killed = IsQuestFlaggedCompleted(questID)
            rowPieces[4*(j-1)+2] = killed and killedColor or aliveColor
            if killed then count = count + 1 end
        end
        rowStrings[i+1] = table.concat(rowPieces)
    end
    rowStrings[1] = format("[|cff%s%d alive|r || |cff%s%d killed|r]",
    aliveColor, #rares-count, killedColor, count)
    return table.concat(rowStrings, "\n")
end

local lastRefresh = 0
function A.customTextFunc()
    local now = GetTime()
    if now - lastRefresh > refreshInterval then
        lastRefresh = now
        customText = buildCustomText()
    end
    return customText
end
