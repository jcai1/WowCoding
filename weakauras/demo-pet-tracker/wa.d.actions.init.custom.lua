----- Legion Demo Pet Tracker -----
local A = aura_env
local R = WeakAuras.regions[A.id].region
-- local S = WeakAurasSaved.displays[A.id]

----- Set options here -----
local numColumns = 8
local showStacksOf1 = false
local stackTextOptions = {
    font = {"Fonts\\FRIZQT__.TTF", 20, "OUTLINE"},
    pos = {"BOTTOMRIGHT", -8, 8}
}
local aspectRatio = 1  -- height / width
local coalesceTime = 0.6  -- Timeframe to coalesce spawns

----- GUI -----
-- R (Region) > tiles (array of Frames) > cooldown, icon, stackText
R.tiles = R.tiles or {}
local tiles = R.tiles  -- tile index -> Frame
local tilesActive = 0
local tilesExpired = 0
local tileHeight = R:GetHeight()
local tileWidth = tileHeight / aspectRatio
local tileNamePrefix = "LegionDemoPetTracker"
local squareTexture = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White"

----- Pet logic -----
local pets = {}  -- Table of active pets (petGUID -> pet)
local expires = {}
local empowerEnds = {}
local petGY1 = {}
local petGY2 = {}
local lastGYSwap = 0
local permPetGUID

----- Utility -----
local now
local playerGUID = UnitGUID("player")

local function bound(x, lower, upper)
    if x <= lower then return lower
    elseif x >= upper then return upper
    else return x
    end
end

local warnPrefix = "\124cff33ffff" .. A.id .. ": \124r"
local function warn(str)
    DEFAULT_CHAT_FRAME:AddMessage(warnPrefix .. str)
end
local function warnf(fmt, ...)
    warn(format(fmt, ...))
end

----- GUI reset -----
for i = 1, #tiles do
    tiles[i]:Hide()
end


--[[
pet fields: type, guid, start, duration, icon, tile, empowerStart, empowerDuration
tile fields: index, stacks, empowerStacks, empowerStartSum, empowerDurationSum, empowerNeedsRefresh
GUI fields: icon, cooldown, highFrame, stackText, empowerBG, empower, empowerAG, empowerAnim
]]

----- Pet types and base tables -----
local petDB =
{
    -- Standard demons
    ["Imp"]        = {duration = 0, icon = "spell_shadow_summonimp"},
    ["Voidwalker"] = {duration = 0, icon = "spell_shadow_summonvoidwalker"},
    ["Succubus"]   = {duration = 0, icon = "spell_shadow_summonsuccubus"},
    ["Felhunter"]  = {duration = 0, icon = "spell_shadow_summonfelhunter"},
    ["Felguard"]   = {duration = 0, icon = "spell_shadow_summonfelguard"},
    ["Fel Imp"]    = {duration = 0, icon = "spell_warlock_summonimpoutland"},
    ["Voidlord"]   = {duration = 0, icon = "warlock_summon_ voidlord"},
    ["Shivarra"]   = {duration = 0, icon = "warlock_summon_ shivan"},
    ["Observer"]   = {duration = 0, icon = "warlock_summon_ beholder"},
    ["Wrathguard"] = {duration = 0, icon = "spell_warlock_summonwrathguard"},
    -- Doomguard/Infernal
    ["Doomguard"]  = {duration = 25, icon = "warlock_summon_doomguard"},
    ["Infernal"]   = {duration = 25, icon = "spell_shadow_summoninfernal"},
    -- GrimSup versions
    ["SupDoomguard"] = {duration = 0, icon = "warlock_summon_doomguard"},
    ["SupInfernal"]  = {duration = 0, icon = "spell_shadow_summoninfernal"},
    -- GrimServ versions
    ["ServImp"]        = {duration = 25, icon = "spell_shadow_summonimp"},
    ["ServVoidwalker"] = {duration = 25, icon = "spell_shadow_summonvoidwalker"},
    ["ServSuccubus"]   = {duration = 25, icon = "spell_shadow_summonsuccubus"},
    ["ServFelhunter"]  = {duration = 25, icon = "spell_shadow_summonfelhunter"},
    ["ServFelguard"]   = {duration = 25, icon = "spell_shadow_summonfelguard"},
    -- Demonology rotation demons
    ["Wild Imp"]     = {duration = 12, icon = "ability_warlock_impoweredimp"},
    ["Dreadstalker"] = {duration = 12, icon = "spell_warlock_calldreadstalkers"},
    ["Darkglare"]    = {duration = 12, icon = "achievement_boss_durumu"},
}
-- Prefix icon paths with Interface\Icons
for _, pet in pairs(petDB) do
    if type(pet.icon) == "string" and not strfind(pet.icon, "\\") then
        pet.icon = "Interface\\Icons\\" .. pet.icon
    end
end

local detectDB =
{
    [416] = "Imp",
    [1860] = "Voidwalker",
    [417] = "Felhunter",
    [1863] = "Succubus",
    [17252] = "Felguard",
    [58959] = "Fel Imp",
    [58960] = "Voidlord",
    [58963] = "Shivarra",
    [58964] = "Observer",
    [58965] = "Wrathguard",
    [11859] = "Doomguard",
    [89] = "Infernal",
    [78158] = "SupDoomguard",
    [78217] = "SupInfernal",
    [55659] = "Wild Imp",
    [99737] = "Wild Imp", -- Improved Dreadstalkers
    [98035] = "Dreadstalker",
    [103673] = "Darkglare",
}


local function createTile(i)
    -- warnf("Creating tile %d", i)
    -- Name isn't necessary, but helps with debugging
    local tileName
    -- Tile frame (parent)
    if not tiles[i] then
        R.tileNameCtr = 1 + (R.tileNameCtr or 0)
        tileName = tileNamePrefix .. R.tileNameCtr
        tiles[i] = CreateFrame("Frame", tileName .. "Tile", R)
    else
        tileName = tiles[i]:GetName()
    end
    local tile = tiles[i]
    tile:SetSize(tileWidth, tileHeight)
    
    tile.index = i
    tile.stacks = 0
    tile.empowerStacks = 0
    tile.empowerStartSum = 0
    tile.empowerDurationSum = 0
    
    -- Pet icon texture
    tile.icon = tile.icon
    or tile:CreateTexture(tileName .. "Icon", "BACKGROUND")
    tile.icon:ClearAllPoints()
    tile.icon:SetAllPoints(tile)
    tile.icon:Show()
    
    -- Cooldown frame
    tile.cooldown = tile.cooldown
    or CreateFrame("Cooldown", tileName .. "Cooldown", tile, "CooldownFrameTemplate")
    tile.cooldown:ClearAllPoints()
    tile.cooldown:SetAllPoints(tile)
    tile.cooldown:SetReverse(true)
    tile.cooldown:Show()
    
    -- A frame manually set to higher frameLevel than cooldown
    tile.highFrame = tile.highFrame
    or CreateFrame("Frame", tileName .. "HighFrame", tile)
    tile.highFrame:SetFrameLevel(tile.cooldown:GetFrameLevel() + 1)
    tile.highFrame:ClearAllPoints()
    tile.highFrame:SetAllPoints(tile)
    tile.highFrame:Show()
    
    -- Text for # of pets in stack
    tile.stackText = tile.stackText
    or tile.highFrame:CreateFontString(tileName .. "StackText", "BACKGROUND")
    tile.stackText:SetFont(unpack(stackTextOptions.font))
    tile.stackText:ClearAllPoints()
    tile.stackText:SetPoint("CENTER", tile, unpack(stackTextOptions.pos))
    tile.stackText:Show()
    
    -- Demonic Empowerment bar
    tile.empowerBG = tile.empowerBG
    or tile:CreateTexture(tileName .. "EmpowerBG", "BACKGROUND", nil, 0)
    tile.empowerBG:ClearAllPoints()
    tile.empowerBG:SetPoint("BOTTOMLEFT", tile, "TOPLEFT")
    tile.empowerBG:SetSize(tileWidth, tileHeight * 0.2)
    tile.empowerBG:SetTexture(squareTexture)
    tile.empowerBG:SetVertexColor(0, 0, 0, 0.5)
    tile.empowerBG:Hide()
    
    tile.empower = tile.empower
    or tile:CreateTexture(tileName .. "Empower", "BACKGROUND", nil, 1)
    tile.empower:ClearAllPoints()
    tile.empower:SetPoint("BOTTOMLEFT", tile, "TOPLEFT")
    tile.empower:SetSize(tileWidth, tileHeight * 0.2)
    tile.empower:SetTexture(squareTexture)
    tile.empower:SetVertexColor(1, 0, 1, 1)
    tile.empower:Hide()
    
    tile.empowerAG = tile.empowerAG
    or tile.empower:CreateAnimationGroup(tileName .. "EmpowerAG")
    tile.empowerAG.tile = tile
    
    tile.empowerAnim = tile.empowerAnim
    or tile.empowerAG:CreateAnimation("Scale")
    tile.empowerAnim:SetOrigin("LEFT", 0, 0)
    tile.empowerAnim:SetScale(0, 1)
    tile.empowerAnim:SetDuration(12)
    
    return tile
end

local function setTilePos(tile, i)
    local col = (i - 1) % numColumns
    local row = floor((i - 1) / numColumns)
    
    tile:ClearAllPoints()
    tile:SetPoint("TOPLEFT", R, "TOPLEFT",
    col * tileWidth, -row * tileHeight * 1.2)
end


local function refreshEmpowerAnim(tile)
    if tile.empowerStacks == 0 then
        -- Stop the animation
        tile.empowerAG:Stop()
        tile.empowerBG:Hide()
        tile.empower:Hide()
    else
        -- Refresh animation using buff means
        local startTime = tile.empowerStartSum / tile.empowerStacks
        local duration = tile.empowerDurationSum / tile.empowerStacks
        local endTime = startTime + duration
        local remain = bound(endTime - now, 0, duration)
        local fullDuration = max(duration, 12)
        
        -- Set initial width, bar will smoothly shrink to 0 over remaining duration
        tile.empower:SetWidth(tileWidth * (remain / fullDuration))
        -- Set height to fraction of pets empowered
        tile.empower:SetHeight(tileHeight * 0.2 * tile.empowerStacks / tile.stacks)
        -- Reset and play new animation
        tile.empowerAG:Stop()
        tile.empowerAnim:SetDuration(remain)
        tile.empowerAG:Play()
        tile.empowerBG:Show()
        tile.empower:Show()
    end
    tile.empowerNeedsRefresh = false
end

-- Runs every frame (must precede collapseTiles)
local function refreshEmpowerAnims()
    for i = 1, tilesActive do
        if tiles[i].empowerNeedsRefresh then
            refreshEmpowerAnim(tiles[i])
        end
    end
end


local function clearEmpower(pet)
    if not pet.empowerStart then return end
    local tile = pet.tile
    tile.empowerNeedsRefresh = true
    tile.empowerStacks = tile.empowerStacks - 1
    if tile.empowerStacks == 0 then
        -- Just to prevent float error accumulation
        tile.empowerStartSum = 0
        tile.empowerDurationSum = 0
    else
        tile.empowerStartSum = tile.empowerStartSum - pet.empowerStart
        tile.empowerDurationSum = tile.empowerDurationSum - pet.empowerDuration
    end
    pet.empowerStart = nil
    pet.empowerDuration = nil
end

local function clearEmpowerIfEnded(pet)
    if not pet.empowerStart then return end
    if now >= (pet.empowerStart + pet.empowerDuration) then
        clearEmpower(pet)
    end
end

local function setEmpower(pet, duration)
    local tile = pet.tile
    duration = max(0, duration)
    clearEmpower(pet)
    pet.empowerStart = now
    pet.empowerDuration = duration
    tile.empowerNeedsRefresh = true
    tile.empowerStacks = tile.empowerStacks + 1
    tile.empowerStartSum = tile.empowerStartSum + now
    tile.empowerDurationSum = tile.empowerDurationSum + duration
    C_Timer.After(duration, function() tinsert(empowerEnds, pet.guid) end)
end

-- Run every frame
local function endEmpowers()
    for i, guid in ipairs(empowerEnds) do
        empowerEnds[i] = nil
        local pet = pets[guid]
        if pet then
            clearEmpowerIfEnded(pet)
        end
    end
end

-- Handle Demonic Empowerment aura apply/refresh
local function onEmpower(subEvent, guid)
    if guid == playerGUID then return end
    local pet = pets[guid]
    if not pet then return end
    local tile = pet.tile
    -- warnf("Empower [type=%s] [guid=%s] [tile=%d]", pet.type, guid, tile.index)
    
    local newDuration
    if subEvent == "SPELL_AURA_APPLIED" or not pet.empowerStart then
        newDuration = 12
    else
        local remain = pet.empowerDuration - (now - pet.empowerStart)
        newDuration = 12 + bound(remain, 0, 3.6)
    end
    setEmpower(pet, newDuration)
end


-- Get the pet from pets table or GYs
local function knownPet(guid)
    return pets[guid] or petGY1[guid] or petGY2[guid]
end

local function addPet(type, guid)
    local base = petDB[type]
    if not base then return end
    -- warnf("Add [type=%s] [guid=%s])", type, guid)
    local pet = { type = type, guid = guid, start = now }
    for k, v in pairs(base) do pet[k] = v end
    pets[guid] = pet
    
    -- duration 0 = permanent
    if pet.duration ~= 0 then
        C_Timer.After(pet.duration, function() tinsert(expires, guid) end)
    end
    
    local i, tile
    for j = tilesActive, 1, -1 do
        local tile_ = tiles[j]
        if now - tile_.start >= coalesceTime then
            break
        end
        if tile_.type == type then
            i = j
            tile = tile_
            break
        end
    end
    
    if i then
        -- warnf("Coalesced spawn to tile %d", i)
        tile.stacks = tile.stacks + 1
    else
        tilesActive = tilesActive + 1
        i = tilesActive
        -- warnf("Didn't coalesce spawn; new tile %d", i)
        if not tiles[i] then
            tiles[i] = createTile(i)
            setTilePos(tiles[i], i)
        end
        tile = tiles[i]
        tile.stacks = 1
        tile.start = now
        tile.type = type
    end
    pet.tile = tile
    
    if pet.duration ~= 0 then
        tile.cooldown:SetCooldown(now, pet.duration)
    end
    tile.stackText:SetText(
        (tile.stacks ~= 1 or showStacksOf1) and tile.stacks or nil)
    tile.icon:SetTexture(pet.icon)
    tile:Show()
end

local function expireOne(guid)
    -- Move pet to gy; inactivate tile if 0 stacks
    local pet = pets[guid]
    if pet then
        -- warnf("Expire [type=%s] [guid=%s]", pet.type, guid)
        pets[guid] = nil
        petGY1[guid] = pet
        
        clearEmpower(pet)
        
        local tile = pet.tile
        tile.stacks = tile.stacks - 1
        tile.stackText:SetText(tile.stacks)
        
        if tile.stacks == 0 then
            tilesExpired = tilesExpired + 1
            assert(tile.empowerStacks == 0)
            tile:Hide()
        end
    end
end

-- Run every frame
local function expirePets()
    assert(tilesExpired == 0)
    for i, guid in ipairs(expires) do
        expires[i] = nil
        expireOne(guid)
    end
end

-- Run every frame (after expirePets)
local function collapseTiles()
    if tilesExpired == 0 then
        return
    end
    tilesActive = tilesActive - tilesExpired
    tilesExpired = 0
    assert(tilesActive >= 0)
    
    local j = 1
    for i = 1, tilesActive do
        if tiles[i].stacks == 0 then
            if j < i + 1 then
                j = i + 1
            end
            while true do
                if tiles[j].stacks > 0 then -- Swap i with j
                    local t1, t2 = tiles[i], tiles[j]
                    tiles[j] = t1 -- Swap their indices
                    t1.index = j
                    tiles[i] = t2
                    t2.index = i
                    setTilePos(t1, j) -- Swap their positions
                    setTilePos(t2, i)
                    break
                else
                    j = j + 1
                end
            end
        end
    end
end

-- Run every frame
local function handleGYSwap()
    if now - lastGYSwap < 30 then return end
    lastGYSwap = now
    wipe(petGY2)
    local tmp = petGY2
    petGY2 = petGY1
    petGY1 = tmp
end

local detectPetType_
detectPetType_ = {
    gsubFun = function(b, i)
        detectPetType_.base = b
        detectPetType_.id = tonumber(i)
    end
}

local function detectPetType(guid)
    local base, id, type
    local env = detectPetType_
    env.base, env.id = nil
    gsub(guid, "(%w*)-.*-(%d*)-%w*", env.gsubFun)
    type = detectDB[env.id]
    if not type then return nil end
    if base == "Creature" and petDB["Serv" .. type] then
        return "Serv" .. type
    else
        return type
    end
end

local function isMine(flags)
    return (bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE)
    == COMBATLOG_OBJECT_AFFILIATION_MINE)
end

local function detectAndAdd(guid)
    if guid ~= playerGUID
    and not knownPet(guid) then
        local type = detectPetType(guid)
        -- Don't add permanent pets from combat log events
        if type and petDB[type].duration > 0 then
            addPet(type, guid)
        end
    end
end

-- Runs on event COMBAT_LOG_EVENT_UNFILTERED
local function onCombatEvent(_, subEvent, _,
        sourceGUID, sourceName, sourceFlags, _,
    destGUID, destName, destFlags, _, ...)
    
    if isMine(sourceFlags) then
        detectAndAdd(sourceGUID)
    end
    
    if isMine(destFlags)
    or (sourceGUID == playerGUID and subEvent == "SPELL_SUMMON") then
        detectAndAdd(destGUID)
    end
    
    if sourceGUID == playerGUID then
        if subEvent == "SPELL_AURA_APPLIED"
        or subEvent == "SPELL_AURA_REFRESH" then
            local spellId, spellName = ...
            if spellName == "Demonic Empowerment" then
                onEmpower(subEvent, destGUID)
            end
        end
    end
    
    if (subEvent == "SPELL_INSTAKILL" or subEvent == "UNIT_DIED")
    and pets[destGUID] then
        tinsert(expires, destGUID)
    end
end

-- Run every frame
local function checkPermPet()
    local guid = UnitGUID("pet")
    if guid == permPetGUID then return end
    
    if permPetGUID and pets[permPetGUID] then
        -- Expire the old pet
        tinsert(expires, permPetGUID)
    end
    
    if guid and not pets[guid] then
        -- Add the new pet
        local type = detectPetType(guid)
        if type then
            if petDB[type].duration == 0 then
                addPet(type, guid)
            else
                warnf("Pet detected as non-permanent type %s", type)
            end
        end
    end
    
    permPetGUID = guid
end

-- Runs on every frame
local function onUpdate()
    checkPermPet()
    endEmpowers()
    expirePets()
    refreshEmpowerAnims()
    collapseTiles()
    handleGYSwap()
end

-- Custom text function
local function doText()
    now = GetTime()
    onUpdate()
end
A.doText = doText

-- Trigger handler
local function doTrigger(event, ...)
    now = GetTime()
    onCombatEvent(...)
    return true
end
A.doTrigger = doTrigger


