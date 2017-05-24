local A = aura_env
local displayText = ""

local buildings = {
    {name = "Mage Tower", contributionID = 1, trackingQuestID = 46793},
    {name = "Command Center", contributionID = 3, trackingQuestID = 46870},
    {name = "Nether Disruptor", contributionID = 4, trackingQuestID = 46871},
}

local outputNames = {}

local function refresh()
    if not IsQuestFlaggedCompleted(46286) then
        displayText = ""
        return
    end
    
    wipe(outputNames)
    
    for _, building in ipairs(buildings) do
        local state = C_ContributionCollector.GetState(building.contributionID)
        if (state == 2 or state == 3) and not IsQuestFlaggedCompleted(building.trackingQuestID) then
            tinsert(outputNames, building.name)
        end
    end
    
    if #outputNames > 0 then
        displayText = "Missing buffs: "..table.concat(outputNames, ", ")
    else 
        displayText = ""
    end
end

local lastRefresh = 0
function A.statusTrigger()
    local now = GetTime()
    if now - lastRefresh > 3 then
        lastRefresh = now
        refresh()
    end
    return true
end

function A.customTextFunc()
    return displayText
end
