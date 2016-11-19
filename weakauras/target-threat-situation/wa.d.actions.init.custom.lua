---- BEGIN OPTIONS ----

-- The sound to use for the audio alert.
local alertSound = "Sound\\SPELLS\\SPELL_DR_Artifact_MoonSpells_ImpactLight_02.ogg"

-- Mutes the audio alert if you are not using a tank spec.
local muteIfNotTanking = true

-- Disables the WeakAura entirely (audio + text) if you are not using a tank spec.
local disableIfNotTanking = false

-- Disables the text display (but not the audio alert) regardsless of your role.
local disableTextDisplay = false

-- How often to scan the raid for general player info.
local raidRefreshInterval = 0.5

-- How often to scan the raid for threat.
local refreshInterval = 0.1

-- How often to play the alert sound (if enabled).
local audioInterval = 2

-- The role icons on the text display.
local roleIconNone = "Interface\\Icons\\inv_misc_questionmark"
local roleIconTank = "Interface\\Icons\\spell_holy_devotionaura"
local roleIconHealer = "Interface\\Icons\\spell_nature_resistnature"
local roleIconDamager = "Interface\\Icons\\ability_warrior_punishingblow"

-- List of NPCs for which to hide the threat table and disable the audio alert
-- You can include either the NPC name or the NPC id
local npcBlacklist = {
}
-- List of NPCs for which to disable the audio alert only
local npcAudioBlacklist = {
}

---- END OPTIONS ----

local A = aura_env
local customText = ""
local audioOn = false

local function makeTextureString(icon)
    -- The preceding space is necessary or the alignment gets fucked
    return " |T" .. icon .. ":12|t"
end

local roleIconStrings = {
    ["NONE"] = makeTextureString(roleIconNone),
    ["TANK"] = makeTextureString(roleIconTank),
    ["HEALER"] = makeTextureString(roleIconHealer),
    ["DAMAGER"] = makeTextureString(roleIconDamager)
}

local npcBlacklistTest = {}
for _, v in ipairs(npcBlacklist) do
    npcBlacklistTest[v] = true
end

local npcAudioBlacklistTest = {}
for _, v in ipairs(npcAudioBlacklist) do
    npcAudioBlacklistTest[v] = true
end

-- Returns "BOTH", "AUDIO", or "NONE" based on blacklist status
local function npcBlacklistStatus(npcName, npcId)
    if npcBlacklistTest[npcName] or npcBlacklistTest[npcId] then
        return "BOTH"
    elseif npcAudioBlacklistTest[npcName] or npcAudioBlacklistTest[npcId] then
        return "AUDIO"
    else
        return "NONE"
    end
end

-- Key: unit GUID
-- Value: table with the following keys:
--     If not isPet: unit, name, role (all guaranteed); class, pet (optional)
--     If isPet: unit, owner, ownerRole, family (all guaranteed)
local players = {}

-- Entry: { player = <entry in players>, threat = <raw threat> }
-- [1] = <primary target>
-- [2] = <highest tank>
-- [3] = <highest non-tank>
-- [4] = <player>
local threatTbl = {{}, {}, {}, {}}

local lines = {}

local unitDB = {
    none = {"player"},
    party = {"player", "party1", "party2", "party3", "party4"},
    raid = {}
}
for i = 1, 40 do unitDB.raid[i] = "raid" .. i end

local function resetThreatTbl(threatTbl)
    for i = 1, 4 do
        threatTbl[i].player = nil
        threatTbl[i].threat = -1
        threatTbl[i].alert = nil
    end
end

local function cmpThreat(a, b)
    return a.threat > b.threat
end

local function sortThreatTbl(threatTbl)
    sort(threatTbl, cmpThreat)
end

local function getUnitList()
    if IsInRaid() then
        return unitDB.raid
    elseif IsInGroup() then
        return unitDB.party
    else
        return unitDB.none
    end
end

local function getPlayerSpecRole()
    local playerSpec = GetSpecialization()
    return playerSpec and select(6, GetSpecializationInfo(playerSpec)) or "NONE"
end

local function refreshRaid()
    local playerSpecRole = getPlayerSpecRole()
    if playerSpecRole ~= "TANK" then
        if disableIfNotTanking or (disableTextDisplay and muteIfNotTanking) then
            return
        end
    end
    
    local unitList = getUnitList()
    
    for i = 1, #unitList do
        local u = unitList[i]
        local upet = u .. "pet"
        local _, guid, name, class, role
        if UnitExists(u) then
            guid = UnitGUID(u)
            name = UnitName(u)
            _, class = UnitClass(u)
            role = UnitGroupRolesAssigned(u)
        end
        if guid and name and role then
            players[guid] = players[guid] or {}
            local p = players[guid]
            p.unit = u
            p.name = name
            p.class = class
            p.role = role
            -- p.dead = UnitIsDeadOrGhost(u)
            p.isPet = false
            
            if UnitExists(upet) then
                local petGUID = UnitGUID(upet)
                players[petGUID] = players[petGUID] or {}
                local pet = players[petGUID]
                pet.isPet = true
                pet.unit = upet
                pet.owner = guid
                pet.ownerRole = role
                pet.family = UnitCreatureFamily(upet) or "Pet"
                
                p.pet = petGUID
            else
                p.pet = nil
            end
            
            -- p.inCombat = UnitAffectingCombat(u)
        end
    end
end

local function guidToNpcId(guid)
    if not guid then
        return
    end
    local n = strlen(guid)
    if strsub(guid, 1, 8) ~= "Creature" then
        return
    end
    local lastHyphen, penultHyphen
    for i = n, 1, -1 do
        if strsub(guid, i, i) == "-" then
            lastHyphen = i
            break
        end
    end
    if lastHyphen then
        for i = (lastHyphen - 1), 1, -1 do
            if strsub(guid, i, i) == "-" then
                penultHyphen = i
                break
            end
        end
        if penultHyphen then
            return tonumber(strsub(guid, penultHyphen + 1, lastHyphen - 1))
        end
    end
end

local function getRoleOrOwnerRole(p)
    if p then
        return p.isPet and p.ownerRole or p.role
    end
end

local function playerToString(p)
    if p.isPet then
        return playerToString(players[p.owner]) .. "'s " .. p.family
    else
        local classColorCode = p.class and RAID_CLASS_COLORS[p.class].colorStr or "ff888888"
        return "|c" .. classColorCode .. p.name .. "|r"
    end
end

local function colorIfTruthy(text, cond, trueColor)
    if cond then
        return "|cff" .. trueColor .. text .. "|r"
    else
        return text
    end
end

local healerOrDamagerTest = {
    ["HEALER"] = true,
    ["DAMAGER"] = true
}

local usedPlayers = {}
local function refresh()
    customText = ""
    audioOn = false
    
    if WeakAuras.IsOptionsOpen() then
        customText = "Target Threat Situation"
        return
    end
    
    local playerSpecRole = getPlayerSpecRole()
    if playerSpecRole ~= "TANK" then
        if disableIfNotTanking or (disableTextDisplay and muteIfNotTanking) then
            return
        end
    end
    
    local targetGUID = UnitGUID("target")
    local targetNpcId = targetGUID and guidToNpcId(targetGUID)
    local targetName = UnitName("target")
    if not targetNpcId and targetName then
        return
    end
    
    local blacklistStatus = npcBlacklistStatus(targetName, targetNpcId)
    if blacklistStatus == "BOTH" then
        return
    end
    
    if not (UnitCanAttack("player", "target") and UnitCanAttack("target", "player")) then
        return
    end
    
    local unitList = getUnitList()
    local tankThreat = 0
    local tt = threatTbl
    resetThreatTbl(tt)
    
    for i = 1, #unitList do
        local u = unitList[i]
        local upet = u .. "pet"
        local p, pet
        if UnitExists(u) then
            p = players[UnitGUID(u)]
        end
        if UnitExists(upet) then
            pet = players[UnitGUID(upet)]
        end
        
        if p then
            local isTanking, _, _, _, threat = UnitDetailedThreatSituation(u, "target")
            if isTanking then
                tt[1].player = p
                tt[1].threat = threat or 0
                tankThreat = threat or 0
            end
            if threat then
                if p.role == "TANK" then
                    if threat > tt[2].threat then
                        tt[2].player = p
                        tt[2].threat = threat
                    end
                else
                    if threat > tt[3].threat then
                        tt[3].player = p
                        tt[3].threat = threat
                    end
                end
                if UnitIsUnit(u, "player") then
                    tt[4].player = p
                    tt[4].threat = threat
                end
            end
        end
        
        if pet then
            local isTanking, _, _, _, threat = UnitDetailedThreatSituation(upet, "target")
            if isTanking then
                tt[1].player = pet
                tt[1].threat = threat or 0
                tankThreat = threat or 0
            end
            if threat then
                if p.role == "TANK" then
                    if threat > tt[2].threat then
                        tt[2].player = pet
                        tt[2].threat = threat
                    end
                else
                    if threat > tt[3].threat then
                        tt[3].player = pet
                        tt[3].threat = threat
                    end
                end
            end
        end
    end
    
    local tt1Player = tt[1].player
    local tt3Player = tt[3].player
    local tt1Role = tt1Player and getRoleOrOwnerRole(tt1Player)
    local tt3Role = tt3Player and getRoleOrOwnerRole(tt3Player)
    
    -- Alert visually if primary target isn't a tank (or tank's pet)
    -- Alert aurally if primary target is specifically a player with healer/DPS role (minimize annoyance / false positives)
    if tt1Player and (tt1Role ~= "TANK") then
        tt[1].alert = true
        if healerOrDamagerTest[tt1Role] and not tt1Player.isPet then
            audioOn = true
        end
        -- Alert visually if top non-tank's threat > the top tank's threat
        -- Alert aurally if top non-tank is specifically a player with healer/DPS role
    elseif tt3Player and (tt[3].threat > tt[2].threat) then
        tt[3].alert = true
        if healerOrDamagerTest[tt3Role] and not tt3Player.isPet then
            audioOn = true
        end
    end
    if playerSpecRole ~= "TANK" and muteIfNotTanking then
        audioOn = false
    end
    
    if not disableTextDisplay then
        local primaryTarget = tt[1].player
        -- Sort threat table before display, invalidating special meaning of tt[1]...tt[4]
        sortThreatTbl(tt)
        wipe(lines)
        wipe(usedPlayers)
        for i = 1, 4 do
            local x = tt[i]
            if x.threat == -1 then break end
            local p = x.player
            if p and not usedPlayers[p] then
                usedPlayers[p] = true
                local role = getRoleOrOwnerRole(p)
                local threatPctStr = tankThreat > 0 and format("%3.f%%%%", 100 * x.threat / tankThreat) or "Inf%%"
                threatPctStr = (p == primaryTarget) and (">" .. threatPctStr .. "<") or (" " .. threatPctStr .. " ")
                lines[#lines + 1] =
                colorIfTruthy(threatPctStr, x.alert, "ff0000")
                .. roleIconStrings[role]
                .. playerToString(p)
            end
        end
        customText = table.concat(lines, "\n")
    end
end

local lastRaidRefresh = 0
local lastRefresh = 0
local lastAudio = 0

function A.statusTrigger()
    local now = GetTime()
    if now - lastRaidRefresh > raidRefreshInterval then
        lastRaidRefresh = now
        refreshRaid()
    end
    if now - lastRefresh > refreshInterval then
        lastRefresh = now
        refresh()
    end
    if audioOn and now - lastAudio > audioInterval then
        lastAudio = now
        PlaySoundFile(alertSound, MASTER)
    end
    return customText ~= ""
end

function A.customTextFunc()
    return customText
end
