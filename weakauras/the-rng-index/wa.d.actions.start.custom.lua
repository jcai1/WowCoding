local total = 0

local function processSpell(desc, link)
    if not desc then return end
    desc = strlower(desc)
    if strfind(desc, "sometimes") or strfind(desc, "a %S*%s?chance") or strfind(desc, "occasionally") then
        print("+1:", link)
        total = total + 1
    end
end

local spells = {}
local usedSpellIDs = {}

local function addSpellID(spellID)
    if (not spellID) or usedSpellIDs[spellID] then
        return
    end
    tinsert(spells, spellID)
    usedSpellIDs[spellID] = true
end

local name,texture,offset,numSpells = GetSpellTabInfo(2)
for i = offset+1, offset+numSpells do
    local spellID = select(7, GetSpellInfo(i, "spell"))
    addSpellID(spellID)
end

if not (ArtifactFrame and ArtifactFrame:IsVisible()) then
    SocketInventoryItem(INVSLOT_MAINHAND)
end
local artifactPowers = C_ArtifactUI.GetPowers()
if artifactPowers then
    for _, powerID in ipairs(artifactPowers) do
        local spellID = C_ArtifactUI.GetPowerInfo(powerID).spellID
        addSpellID(spellID)
    end
else
    print("Warning: Couldn't open artifact UI")
end
C_ArtifactUI.Clear()

for tier = 1, MAX_TALENT_TIERS do
    for col = 1, NUM_TALENT_COLUMNS do
        local spellID, _, _, _, selected = select(6, GetTalentInfo(tier, col, 1))
        if selected then
            addSpellID(spellID)
            break
        end
    end
end


for _, spellID in ipairs(spells) do
    local desc = GetSpellDescription(spellID)
    local link = GetSpellLink(spellID)
    processSpell(desc, link)
end

print("Your RNG Index:", total)
