local A = aura_env
local refreshRate = 10

local refreshInterval = 1 / refreshRate
local lastRefresh = -999
local customText

local function getLabel()
    local a = ScenarioObjectiveBlock
    a = a and a.currentLine
    a = a and a.Bar
    return a and a.Label
end

local function makeText()
    local _, _, numCriteria, _, _, _, _, _, weightedProgress = C_Scenario.GetStepInfo()
    if numCriteria and numCriteria > 0 then
        for criteriaIndex = 1, numCriteria do
            local criteriaString, _, _, quantity, totalQuantity, _, _, quantityString = C_Scenario.GetCriteriaInfo(criteriaIndex)
            if criteriaString == "Enemy Forces" then
                return format("%s/%d (%d%%)", gsub(quantityString, "%%$", ""), totalQuantity, quantity)
            end
        end
    end
end

local function doText()
    local now = GetTime()
    if now - lastRefresh > refreshInterval then
        local label = getLabel()
        if label then
            local text = makeText()
            if text then
                label:SetText(text)
            end
        end
        lastRefresh = now
    end
end
A.doText = doText
