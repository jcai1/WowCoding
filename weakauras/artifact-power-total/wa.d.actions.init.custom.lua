local A = aura_env
local R = WeakAuras.regions[A.id].region

local tooltipName = "ArtifactPowerTotalTooltip"

local bags = {BACKPACK_CONTAINER}
local bankBags = {BANK_CONTAINER}
for i = 1, NUM_BAG_SLOTS do tinsert(bags, i) end
for i = 1, NUM_BANKBAGSLOTS do tinsert(bankBags, NUM_BAG_SLOTS + i) end

local function printf(...) return print(format(...)) end

local tooltip
local cache = {}

local function scanBag(bag)
    local a = 0
    for slot = 1, GetContainerNumSlots(bag) do
        local link = GetContainerItemLink(bag, slot)
        if link then
            if cache[link] then
                a = a + cache[link]
            elseif strfind(link, ":8388608:") then
                tooltip:ClearLines()
                tooltip:SetHyperlink(link)
                for i = 1, tooltip:NumLines() do
                    local fontString = _G[tooltipName.."TextLeft"..i]
                    local text = fontString:GetText()
                    text = gsub(text, "[.,]", "")
                    gsub(text, "Grants (%d+) Artifact Power", function(s)
                            local n = tonumber(s)
                            a = a + n
                            cache[link] = n
                    end)
                    if cache[link] then break end
                end
            end
        end
    end
    return a
end

function R.doCalc()
    tooltip = _G[tooltipName]
    if not tooltip then
        CreateFrame("GameTooltip", tooltipName, nil, "GameTooltipTemplate")
        tooltip = _G[tooltipName]
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end
    
    wipe(cache)
    
    local bagTotal = 0
    local bankTotal = 0
    for _, bag in ipairs(bags) do
        bagTotal = bagTotal + scanBag(bag)
    end
    for _, bag in ipairs(bankBags) do
        bankTotal = bankTotal + scanBag(bag)
    end
    
    local B = BreakUpLargeNumbers or tostring
    printf("Total artifact power: %s (Bag %s, Bank %s)",
        B(bagTotal + bankTotal), B(bagTotal), B(bankTotal))
end

local playerName = format("%s-%s", UnitFullName("player"))

function aura_env.onMessage(event, message, sender)
    if sender == playerName and strfind(strlower(message), "^%s*af%s*power%s*$") then
        R.doCalc()
    end
end
