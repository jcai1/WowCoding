---- ToV/03HEL/Taint Assign ----
local A = aura_env
local S = WeakAurasSaved.displays[A.id]
local customText = ""
local debugOn = false

local function debugPrint(...)
    if debugOn then return print(...) end
end

local tickerCallbacks = {}
local function every(dt, callback, tickASAP)
    local now = GetTime()
    local last = tickASAP and (now - dt - 1) or now
    tinsert(tickerCallbacks, {dt = dt, last = last, callback = callback})
end

function A.statusTrigger()
    local now = GetTime()
    for _, entry in ipairs(tickerCallbacks) do
        if now - entry.last >= entry.dt then
            entry.last = now
            entry.callback()
        end
    end
    return customText ~= ""
end

function A.customTextFunc()
    return customText
end

-- our dispel tracking only tracks 1 dispel spell per player
-- not fully general, but simplifies code a little
local isHealerDispel = {
    [527]    = true, -- Purify        (Healing Priest)
    [4987]   = true, -- Cleanse       (Holy Paladin)
    [88423]  = true, -- Nature's Cure (Resto Druid)
    [77130]  = true, -- Purify Spirit (Resto Shaman)
    [115450] = true, -- Detox         (Mistweaver Monk)
}
local isOtherDispel = {
    [32375]  = true, -- Mass Dispel   (Shadow Priest)
    [89808]  = true, -- Singe Magic   (Warlock with Imp pet)
    [115276] = true, -- Sear Magic    (Warlock with Fel Imp pet)
}

---- continuously detect everyone's guid/name/class/etc, also assign canonical index ----
local MRM = MAX_RAID_MEMBERS
local raidInfo = {}
for i = 1, MRM do raidInfo[i] = {} end
local guidToRaidIndexMap = {}
local petGuidToRaidIndexMap = {}
local ambNameToGuidMap = {}
local fullNameToGuidMap = {}
local canonicalIndexToGuidMap = {} -- actually just an array
local guidToCanonicalIndexMap = {}

local function canonicalIndexToRaidIndex(canonicalIndex)
    return guidToRaidIndexMap[canonicalIndexToGuidMap[canonicalIndex]]
end

local function myCanonicalIndex()
    return guidToCanonicalIndexMap[UnitGUID("player")]
end

local function nameToGuid(name) -- can take either fullName or ambName
    return ambNameToGuidMap[name] or fullNameToGuidMap[name]
end

local function nameToCanonicalIndex(name) -- can take either fullName or ambName
    return guidToCanonicalIndexMap[nameToGuid(name)]
end

local myRealm = gsub(GetRealmName(), "%s+", "")

-- returns name, realm, fullName, ambName
-- ambName: if same realm, name; if diff realm, name-realm
local function playerNameInfo(unit)
    local name, realm = UnitName(unit)
    if not name then
        return nil, nil, nil, nil
    end
    if (not realm) or (realm == "") or (realm == myRealm) then -- same realm as me
        return name, myRealm, (name.."-"..myRealm), name
    end
    -- different realm
    local fullName = name.."-"..realm
    return name, realm, fullName, fullName
end

local function addCanonical(guid, fullName)
    local i = 1
    while true do
        local guidI = canonicalIndexToGuidMap[i]
        if not guidI then break end
        local fullNameI = raidInfo[guidToRaidIndexMap[guidI]].fullName
        if fullNameI >= fullName then break end
        i = i + 1
    end
    tinsert(canonicalIndexToGuidMap, i, guid)
    for j = i, #canonicalIndexToGuidMap do
        guidToCanonicalIndexMap[canonicalIndexToGuidMap[j]] = j
    end
    return i
end

local function removeCanonical(guid)
    local i = guidToCanonicalIndexMap[guid]
    if not i then return end
    tremove(canonicalIndexToGuidMap, i)
    guidToCanonicalIndexMap[guid] = nil
    for j = i, #canonicalIndexToGuidMap do
        guidToCanonicalIndexMap[canonicalIndexToGuidMap[j]] = j
    end
end

local function refreshRaidMember(raidIndex)
    local unit = "raid"..raidIndex
    local p = raidInfo[raidIndex]
    
    local exists, guid
    local name, realm, fullName, ambName
    
    exists = UnitExists(unit)
    if exists then
        guid = UnitGUID(unit)
        name, realm, fullName, ambName = playerNameInfo(unit)
        exists = guid and fullName and (name ~= "Unknown")
    end
    
    if p.guid then -- old one exists
        if (not exists) or (p.guid ~= guid) then -- clear or modify
            -- invalidate old mappings
            debugPrint("invalidating", p.guid, p.dispName)
            guidToRaidIndexMap[p.guid] = nil
            if p.petGUID then petGuidToRaidIndexMap[p.petGUID] = nil end
            ambNameToGuidMap[p.ambName] = nil
            fullNameToGuidMap[p.fullName] = nil
            removeCanonical(p.guid)
            
            -- wipe info, will replace with new if exists
            wipe(p)
        end -- otherwise it's the same as old
    end -- otherwise old one doesn't exist
    
    if exists and guid ~= p.guid then -- includes (exists and not p.guid)
        local oldRaidIndex = guidToRaidIndexMap[guid]
        if oldRaidIndex then
            -- swap tables with old raid index, old one becomes empty
            assert(not p.guid)
            debugPrint("swapping", guid, ambName)
            raidInfo[raidIndex] = raidInfo[oldRaidIndex]
            raidInfo[oldRaidIndex] = p
            p = raidInfo[raidIndex]
            -- set basic info
            assert(p.guid == guid)
            p.name, p.realm, p.fullName, p.ambName = name, realm, fullName, ambName
            -- update mappings
            guidToRaidIndexMap[guid] = raidIndex
            ambNameToGuidMap[ambName] = guid
            fullNameToGuidMap[fullName] = guid
            -- remove canonical in case name changed
            removeCanonical(guid)
        else
            debugPrint("installing", guid, ambName)
            -- set basic info
            p.guid = guid
            p.name, p.realm, p.fullName, p.ambName = name, realm, fullName, ambName
            -- install new mappings
            guidToRaidIndexMap[guid] = raidIndex
            ambNameToGuidMap[ambName] = guid
            fullNameToGuidMap[fullName] = guid
        end
    end
    
    if not exists then return end
    
    p.class = select(2, UnitClass(unit))
    p.role = UnitGroupRolesAssigned(unit)
    local classColor = p.class and RAID_CLASS_COLORS[p.class].colorStr or "ff888888"
    p.dispName = format("|c%s%s|r", classColor, p.ambName)
    -- p.inCombat = UnitAffectingCombat(unit)
    p.group = select(3, GetRaidRosterInfo(raidIndex))
    p.visible = UnitIsVisible(unit)
    
    if p.visible and not guidToCanonicalIndexMap[guid] then
        addCanonical(guid, fullName)
    elseif guidToCanonicalIndexMap[guid] and not p.visible then
        removeCanonical(guid)
    end
    
    local petUnit = unit.."pet"
    local petGUID = UnitGUID(petUnit)
    if p.petGUID then -- old one exists
        if (not petGUID) or (p.petGUID ~= petGUID) then -- clear or modify
            petGuidToRaidIndexMap[p.petGUID] = nil
            if petGUID then petGuidToRaidIndexMap[petGUID] = raidIndex end
        end -- otherwise it's the same as old
    else -- old one doesn't exist
        if petGUID then petGuidToRaidIndexMap[petGUID] = raidIndex end
    end
    p.petGUID = petGUID
    
    -- any healer, warlock with Imp, shadow priest with Mass Dispel
    p.isDispeller = (p.role == "HEALER") or (p.class == "WARLOCK" and strfind(tostring(UnitCreatureFamily(petUnit)), "Imp")) or (p.class == "PRIEST")
    p.lastDispel = p.lastDispel or 0
end

local lastRaidRefresh = GetTime()
local curRaidRefreshIndex = 1
local raidRefreshInterval = 1 -- rolling refresh raid every X seconds

every(raidRefreshInterval/MRM, function()
        local now = GetTime()
        local timeSinceLast = now - lastRaidRefresh
        lastRaidRefresh = now
        for count = 1, MRM*min(1, timeSinceLast/raidRefreshInterval) do
            refreshRaidMember(curRaidRefreshIndex)
            curRaidRefreshIndex = (curRaidRefreshIndex % MRM) + 1
        end
end)

function A.COMBAT_LOG_EVENT_UNFILTERED(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName)
    if (subEvent == "SPELL_DISPEL" and isHealerDispel[spellID]) or (subEvent == "SPELL_CAST_SUCCESS" and isOtherDispel[spellID]) then
        local raidIndex = guidToRaidIndexMap[sourceGUID] or petGuidToRaidIndexMap[sourceGUID]
        if raidIndex then
            local p = raidInfo[raidIndex]
            if p.role == "HEALER" and spellID == 32375 then -- don't track Mass Dispel for healing priests
                debugPrint("ignored", sourceName, spellID, spellName)
            else
                debugPrint("dispel", sourceName, spellID, spellName)
                p.lastDispel = GetTime()
            end
        end
    end
end

local function unitIsActive(unit)
    return UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit)
end

local function unitIsAfflicted(unit)
    return UnitDebuff(unit, "Taint of the Sea")
end

local function getNextAfflicted(canonicalIndex)
    local raidIndex = canonicalIndexToRaidIndex(canonicalIndex)
    if not raidIndex then
        return nil -- no more canonical indices
    end
    local p = raidInfo[raidIndex]
    local unit = "raid"..raidIndex
    if unitIsActive(unit) and unitIsAfflicted(unit) then
        return canonicalIndex
    end
    return getNextAfflicted(canonicalIndex + 1)
end

local function getNextDispeller(canonicalIndex)
    local raidIndex = canonicalIndexToRaidIndex(canonicalIndex)
    if not raidIndex then
        return nil -- no more canonical indices
    end
    local now = GetTime()
    local p = raidInfo[raidIndex]
    local unit = "raid"..raidIndex
    if p.isDispeller and unitIsActive(unit) then
        local dispelCD
        if p.role == "HEALER" then
            dispelCD = 8 -- healer dispel
        elseif p.class == "WARLOCK" then -- isDispeller ensures pet is out
            dispelCD = 10 -- Singe Magic
        elseif p.class == "PRIEST" then -- non-healing (i.e. shadow) priest
            dispelCD = 15 -- Mass Dispel
        end
        if (not p.lastDispel) or (now - p.lastDispel >= dispelCD) then
            return canonicalIndex
        end
    end
    return getNextDispeller(canonicalIndex + 1)
end

-- assignment is simply (dispeller index) -> (afflicted index)
local assignmentPrefix = "HelTaintA"
local curAssignment = {}
local curAssignerIndex = 99
local lastAssigned = 0

-- tables and functions local to calcAndSetCurAssignment
local allAfflicted = {}
local allDispellers = {}
local newAssignment = {}
local function assign_(d, a)
    allAfflicted[a] = nil
    allDispellers[d] = nil
    newAssignment[d] = a
end
local function calcAndSetCurAssignment()
    wipe(allAfflicted)
    wipe(allDispellers)
    wipe(newAssignment)
    do
        local a = 0 -- afflicted
        local d = 0 -- dispeller
        while true do
            a = getNextAfflicted(a + 1)
            if not a then break end
            local p = raidInfo[canonicalIndexToRaidIndex(a)]
            -- canonical index -> 1=tank, 2=other
            allAfflicted[a] = p.role == "TANK" and 1 or 2
        end
        while true do
            d = getNextDispeller(d + 1)
            if not d then break end
            local p = raidInfo[canonicalIndexToRaidIndex(d)]
            -- canonical index -> dispeller priority
            -- priority: 1=healers 2=warlocks 3=spriests
            allDispellers[d] = p.role == "HEALER" and 1 or p.class == "WARLOCK" and 2 or 3
        end
    end
    -- preserve old assignments if possible
    for d, a in pairs(curAssignment) do
        if allAfflicted[a] and allDispellers[d] then -- still valid
            assign_(d, a)
        end
    end
    -- assign warlocks to tanks if possible
    for a, aprio in pairs(allAfflicted) do
        if aprio == 1 then -- tank
            for d, dprio in pairs(allDispellers) do
                if dprio == 2 then -- warlock
                    assign_(d, a)
                    break
                end
            end
        end
    end
    -- self-assign if possible
    for d, dprio in pairs(allDispellers) do
        if allAfflicted[d] then
            assign_(d, d)
        end
    end
    -- other new assignments
    for dispellerPriority = 1, 3 do
        for d, dprio in pairs(allDispellers) do
            if dprio == dispellerPriority then
                local a = next(allAfflicted)
                if not a then break end
                assign_(d, a)
            end
        end
        if not next(allAfflicted) then break end
    end
    -- swap new and old assignments
    wipe(curAssignment)
    local tmp = curAssignment
    curAssignment = newAssignment
    newAssignment = tmp
    -- set metadata
    curAssignerIndex = myCanonicalIndex()
    lastAssigned = GetTime()
end

local function assignmentToString(assignment)
    local stringTbl = {}
    for k, v in pairs(assignment) do
        tinsert(stringTbl, tostring(k))
        tinsert(stringTbl, tostring(v))
    end
    return table.concat(stringTbl, " ")
end

local function stringToAssignment(str)
    local assignment = {}
    local key = nil
    gsub(str, "%d+", function(tok)
            local num = tonumber(tok)
            if not key then
                key = num
            else
                assignment[key] = num
                key = nil
            end
    end)
    return assignment
end

local function broadcastToRaid(prefix, message)
    if not IsInGroup() then return end
    local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
    debugPrint("sending message:", prefix, message)
    SendAddonMessage(prefix, message, channel)
end

local function broadcastAssignment(assignment)
    broadcastToRaid(assignmentPrefix, assignmentToString(assignment))
end

local function onAssignmentReceived(assignment, assignerIndex)
    local now = GetTime()
    if now - lastAssigned >= 0.25 or assignerIndex <= curAssignerIndex then
        debugPrint("got assignment from", assignerIndex, ":", assignmentToString(assignment))
        curAssignment, curAssignerIndex, lastAssigned = assignment, assignerIndex, now
    end
end

function A.CHAT_MSG_ADDON(prefix, message, channel, sender)
    if prefix == assignmentPrefix then
        local senderCI = nameToCanonicalIndex(sender)
        if not senderCI then return end
        onAssignmentReceived(stringToAssignment(message), senderCI)
    end
end

local function raidTargetIconString(raidTargetIndex)
    if raidTargetIndex then
        return format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t", raidTargetIndex)
    else
        return ""
    end
end

local function dispelString(raidIndex)
    if not raidIndex then return "" end
    
    local unit = "raid"..raidIndex
    local markerString = raidTargetIconString(GetRaidTargetIndex(unit))
    
    local p = raidInfo[raidIndex]
    local groupText = p.group and tostring(p.group) or "?"
    return format("G%s:%s%s", groupText, markerString, tostring(p.dispName))
end

local function getDefaultAssignmentText(myCI)
    local a = getNextAfflicted(0)
    if not a then -- no one to dispel
        return
    end
    local a2 = getNextAfflicted(a + 1)
    if not a2 then -- only 1 person to dispel
        return dispelString(canonicalIndexToRaidIndex(a))
    end
    -- more than 1 person to dispel
    return "Dispel Anyone"
end

local function getMyAssignmentText(myCI)
    local afflictedCI = curAssignment[myCI]
    if not afflictedCI then return end
    
    local afflictedRI = canonicalIndexToRaidIndex(afflictedCI)
    if not afflictedRI then return end
    
    -- check debuff locally, since assignment may not be up-to-date
    if not unitIsAfflicted("raid"..afflictedRI) then return end
    
    return dispelString(afflictedRI)
end

if debugOn then
    -- print out list of canonical indices
    every(5, function()
            local line = {}
            for i, guid in ipairs(canonicalIndexToGuidMap) do
                local raidIndex = guidToRaidIndexMap[guid]
                local p = raidInfo[raidIndex]
                local dispName = tostring(p.dispName)
                tinsert(line, i..":"..dispName.."/"..tostring(p.group))
                if #line >= 5 then
                    debugPrint(table.concat(line, " "))
                    wipe(line)
                end
            end
            if #line >= 1 then
                debugPrint(table.concat(line, " "))
            end
    end)
end

local lastSound = 0
local soundInterval = 2

local function WA_playSound(actions)
    if(actions.do_sound and actions.sound) then
        if(actions.sound == " custom") then
            if(actions.sound_path) then
                PlaySoundFile(actions.sound_path, actions.sound_channel or "Master");
            end
        elseif(actions.sound == " KitID") then
            if(actions.sound_kit_id) then
                PlaySoundKitID(actions.sound_kit_id, actions.sound_channel or "Master");
            end
        else
            PlaySoundFile(actions.sound, actions.sound_channel or "Master");
        end
    end
end

local function playSound()
    if S.actions.start then
        WA_playSound(S.actions.start)
    end
end

-- called close to every frame
local function everyFrame()
    local now = GetTime()
    local myCI = myCanonicalIndex()
    if not myCI then return end
    if now - lastAssigned > 0.1 + 0.15 * sqrt(myCI) then
        calcAndSetCurAssignment()
        broadcastAssignment(curAssignment)
    end
    customText = getMyAssignmentText(myCI) or getDefaultAssignmentText(myCI) or ""
    if customText ~= "" then
        if now - lastSound >= soundInterval then
            lastSound = now
            playSound()
        end
    else
        -- sound is already played "On Show", prevent duplicate sound
        lastSound = now
    end
end
every(0.05, everyFrame)
