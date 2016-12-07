{
  d = {
    actions = {
      init = {
        custom = "---- ToV/03HEL/Taint Assign ----\nlocal A = aura_env\nlocal S = WeakAurasSaved.displays[A.id]\nlocal customText = \"\"\nlocal debugOn = false\n\nlocal function debugPrint(...)\n    if debugOn then return print(...) end\nend\n\nlocal tickerCallbacks = {}\nlocal function every(dt, callback, tickASAP)\n    local now = GetTime()\n    local last = tickASAP and (now - dt - 1) or now\n    tinsert(tickerCallbacks, {dt = dt, last = last, callback = callback})\nend\n\nfunction A.statusTrigger()\n    local now = GetTime()\n    for _, entry in ipairs(tickerCallbacks) do\n        if now - entry.last >= entry.dt then\n            entry.last = now\n            entry.callback()\n        end\n    end\n    return customText ~= \"\"\nend\n\nfunction A.customTextFunc()\n    return customText\nend\n\n-- our dispel tracking only tracks 1 dispel spell per player\n-- not fully general, but simplifies code a little\nlocal isHealerDispel = {\n    [527]    = true, -- Purify        (Healing Priest)\n    [4987]   = true, -- Cleanse       (Holy Paladin)\n    [88423]  = true, -- Nature's Cure (Resto Druid)\n    [77130]  = true, -- Purify Spirit (Resto Shaman)\n    [115450] = true, -- Detox         (Mistweaver Monk)\n}\nlocal isOtherDispel = {\n    [32375]  = true, -- Mass Dispel   (Shadow Priest)\n    [89808]  = true, -- Singe Magic   (Warlock with Imp pet)\n    [115276] = true, -- Sear Magic    (Warlock with Fel Imp pet)\n}\n\n---- continuously detect everyone's guid/name/class/etc, also assign canonical index ----\nlocal MRM = MAX_RAID_MEMBERS\nlocal raidInfo = {}\nfor i = 1, MRM do raidInfo[i] = {} end\nlocal guidToRaidIndexMap = {}\nlocal petGuidToRaidIndexMap = {}\nlocal ambNameToGuidMap = {}\nlocal fullNameToGuidMap = {}\nlocal canonicalIndexToGuidMap = {} -- actually just an array\nlocal guidToCanonicalIndexMap = {}\n\nlocal function canonicalIndexToRaidIndex(canonicalIndex)\n    return guidToRaidIndexMap[canonicalIndexToGuidMap[canonicalIndex]]\nend\n\nlocal function myCanonicalIndex()\n    return guidToCanonicalIndexMap[UnitGUID(\"player\")]\nend\n\nlocal function nameToGuid(name) -- can take either fullName or ambName\n    return ambNameToGuidMap[name] or fullNameToGuidMap[name]\nend\n\nlocal function nameToCanonicalIndex(name) -- can take either fullName or ambName\n    return guidToCanonicalIndexMap[nameToGuid(name)]\nend\n\nlocal myRealm = gsub(GetRealmName(), \"%s+\", \"\")\n\n-- returns name, realm, fullName, ambName\n-- ambName: if same realm, name; if diff realm, name-realm\nlocal function playerNameInfo(unit)\n    local name, realm = UnitName(unit)\n    if not name then\n        return nil, nil, nil, nil\n    end\n    if (not realm) or (realm == \"\") or (realm == myRealm) then -- same realm as me\n        return name, myRealm, (name..\"-\"..myRealm), name\n    end\n    -- different realm\n    local fullName = name..\"-\"..realm\n    return name, realm, fullName, fullName\nend\n\nlocal function addCanonical(guid, fullName)\n    local i = 1\n    while true do\n        local guidI = canonicalIndexToGuidMap[i]\n        if not guidI then break end\n        local fullNameI = raidInfo[guidToRaidIndexMap[guidI]].fullName\n        if fullNameI >= fullName then break end\n        i = i + 1\n    end\n    tinsert(canonicalIndexToGuidMap, i, guid)\n    for j = i, #canonicalIndexToGuidMap do\n        guidToCanonicalIndexMap[canonicalIndexToGuidMap[j]] = j\n    end\n    return i\nend\n\nlocal function removeCanonical(guid)\n    local i = guidToCanonicalIndexMap[guid]\n    if not i then return end\n    tremove(canonicalIndexToGuidMap, i)\n    guidToCanonicalIndexMap[guid] = nil\n    for j = i, #canonicalIndexToGuidMap do\n        guidToCanonicalIndexMap[canonicalIndexToGuidMap[j]] = j\n    end\nend\n\nlocal function refreshRaidMember(raidIndex)\n    local unit = \"raid\"..raidIndex\n    local p = raidInfo[raidIndex]\n    \n    local exists, guid\n    local name, realm, fullName, ambName\n    \n    exists = UnitExists(unit)\n    if exists then\n        guid = UnitGUID(unit)\n        name, realm, fullName, ambName = playerNameInfo(unit)\n        exists = guid and fullName and (name ~= \"Unknown\")\n    end\n    \n    if p.guid then -- old one exists\n        if (not exists) or (p.guid ~= guid) then -- clear or modify\n            -- invalidate old mappings\n            debugPrint(\"invalidating\", p.guid, p.dispName)\n            guidToRaidIndexMap[p.guid] = nil\n            if p.petGUID then petGuidToRaidIndexMap[p.petGUID] = nil end\n            ambNameToGuidMap[p.ambName] = nil\n            fullNameToGuidMap[p.fullName] = nil\n            removeCanonical(p.guid)\n            \n            -- wipe info, will replace with new if exists\n            wipe(p)\n        end -- otherwise it's the same as old\n    end -- otherwise old one doesn't exist\n    \n    if exists and guid ~= p.guid then -- includes (exists and not p.guid)\n        local oldRaidIndex = guidToRaidIndexMap[guid]\n        if oldRaidIndex then\n            -- swap tables with old raid index, old one becomes empty\n            assert(not p.guid)\n            debugPrint(\"swapping\", guid, ambName)\n            raidInfo[raidIndex] = raidInfo[oldRaidIndex]\n            raidInfo[oldRaidIndex] = p\n            p = raidInfo[raidIndex]\n            -- set basic info\n            assert(p.guid == guid)\n            p.name, p.realm, p.fullName, p.ambName = name, realm, fullName, ambName\n            -- update mappings\n            guidToRaidIndexMap[guid] = raidIndex\n            ambNameToGuidMap[ambName] = guid\n            fullNameToGuidMap[fullName] = guid\n            -- remove canonical in case name changed\n            removeCanonical(guid)\n        else\n            debugPrint(\"installing\", guid, ambName)\n            -- set basic info\n            p.guid = guid\n            p.name, p.realm, p.fullName, p.ambName = name, realm, fullName, ambName\n            -- install new mappings\n            guidToRaidIndexMap[guid] = raidIndex\n            ambNameToGuidMap[ambName] = guid\n            fullNameToGuidMap[fullName] = guid\n        end\n    end\n    \n    if not exists then return end\n    \n    p.class = select(2, UnitClass(unit))\n    p.role = UnitGroupRolesAssigned(unit)\n    local classColor = p.class and RAID_CLASS_COLORS[p.class].colorStr or \"ff888888\"\n    p.dispName = format(\"|c%s%s|r\", classColor, p.ambName)\n    -- p.inCombat = UnitAffectingCombat(unit)\n    p.group = select(3, GetRaidRosterInfo(raidIndex))\n    p.visible = UnitIsVisible(unit)\n    \n    if p.visible and not guidToCanonicalIndexMap[guid] then\n        addCanonical(guid, fullName)\n    elseif guidToCanonicalIndexMap[guid] and not p.visible then\n        removeCanonical(guid)\n    end\n    \n    local petUnit = unit..\"pet\"\n    local petGUID = UnitGUID(petUnit)\n    if p.petGUID then -- old one exists\n        if (not petGUID) or (p.petGUID ~= petGUID) then -- clear or modify\n            petGuidToRaidIndexMap[p.petGUID] = nil\n            if petGUID then petGuidToRaidIndexMap[petGUID] = raidIndex end\n        end -- otherwise it's the same as old\n    else -- old one doesn't exist\n        if petGUID then petGuidToRaidIndexMap[petGUID] = raidIndex end\n    end\n    p.petGUID = petGUID\n    \n    -- any healer, warlock with Imp, shadow priest with Mass Dispel\n    p.isDispeller = (p.role == \"HEALER\") or (p.class == \"WARLOCK\" and strfind(tostring(UnitCreatureFamily(petUnit)), \"Imp\")) or (p.class == \"PRIEST\")\n    p.lastDispel = p.lastDispel or 0\nend\n\nlocal lastRaidRefresh = GetTime()\nlocal curRaidRefreshIndex = 1\nlocal raidRefreshInterval = 1 -- rolling refresh raid every X seconds\n\nevery(raidRefreshInterval/MRM, function()\n        local now = GetTime()\n        local timeSinceLast = now - lastRaidRefresh\n        lastRaidRefresh = now\n        for count = 1, MRM*min(1, timeSinceLast/raidRefreshInterval) do\n            refreshRaidMember(curRaidRefreshIndex)\n            curRaidRefreshIndex = (curRaidRefreshIndex % MRM) + 1\n        end\nend)\n\nfunction A.COMBAT_LOG_EVENT_UNFILTERED(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName)\n    if (subEvent == \"SPELL_DISPEL\" and isHealerDispel[spellID]) or (subEvent == \"SPELL_CAST_SUCCESS\" and isOtherDispel[spellID]) then\n        local raidIndex = guidToRaidIndexMap[sourceGUID] or petGuidToRaidIndexMap[sourceGUID]\n        if raidIndex then\n            local p = raidInfo[raidIndex]\n            if p.role == \"HEALER\" and spellID == 32375 then -- don't track Mass Dispel for healing priests\n                debugPrint(\"ignored\", sourceName, spellID, spellName)\n            else\n                debugPrint(\"dispel\", sourceName, spellID, spellName)\n                p.lastDispel = GetTime()\n            end\n        end\n    end\nend\n\nlocal function unitIsActive(unit)\n    return UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit)\nend\n\nlocal function unitIsAfflicted(unit)\n    return UnitDebuff(unit, \"Taint of the Sea\")\nend\n\nlocal function getNextAfflicted(canonicalIndex)\n    local raidIndex = canonicalIndexToRaidIndex(canonicalIndex)\n    if not raidIndex then\n        return nil -- no more canonical indices\n    end\n    local p = raidInfo[raidIndex]\n    local unit = \"raid\"..raidIndex\n    if unitIsActive(unit) and unitIsAfflicted(unit) then\n        return canonicalIndex\n    end\n    return getNextAfflicted(canonicalIndex + 1)\nend\n\nlocal function getNextDispeller(canonicalIndex)\n    local raidIndex = canonicalIndexToRaidIndex(canonicalIndex)\n    if not raidIndex then\n        return nil -- no more canonical indices\n    end\n    local now = GetTime()\n    local p = raidInfo[raidIndex]\n    local unit = \"raid\"..raidIndex\n    if p.isDispeller and unitIsActive(unit) then\n        local dispelCD\n        if p.role == \"HEALER\" then\n            dispelCD = 8 -- healer dispel\n        elseif p.class == \"WARLOCK\" then -- isDispeller ensures pet is out\n            dispelCD = 10 -- Singe Magic\n        elseif p.class == \"PRIEST\" then -- non-healing (i.e. shadow) priest\n            dispelCD = 15 -- Mass Dispel\n        end\n        if (not p.lastDispel) or (now - p.lastDispel >= dispelCD) then\n            return canonicalIndex\n        end\n    end\n    return getNextDispeller(canonicalIndex + 1)\nend\n\n-- assignment is simply (dispeller index) -> (afflicted index)\nlocal assignmentPrefix = \"HelTaintA\"\nlocal curAssignment = {}\nlocal curAssignerIndex = 99\nlocal lastAssigned = 0\n\n-- tables and functions local to calcAndSetCurAssignment\nlocal allAfflicted = {}\nlocal allDispellers = {}\nlocal newAssignment = {}\nlocal function assign_(d, a)\n    allAfflicted[a] = nil\n    allDispellers[d] = nil\n    newAssignment[d] = a\nend\nlocal function calcAndSetCurAssignment()\n    wipe(allAfflicted)\n    wipe(allDispellers)\n    wipe(newAssignment)\n    do\n        local a = 0 -- afflicted\n        local d = 0 -- dispeller\n        while true do\n            a = getNextAfflicted(a + 1)\n            if not a then break end\n            local p = raidInfo[canonicalIndexToRaidIndex(a)]\n            -- canonical index -> 1=tank, 2=other\n            allAfflicted[a] = p.role == \"TANK\" and 1 or 2\n        end\n        while true do\n            d = getNextDispeller(d + 1)\n            if not d then break end\n            local p = raidInfo[canonicalIndexToRaidIndex(d)]\n            -- canonical index -> dispeller priority\n            -- priority: 1=healers 2=warlocks 3=spriests\n            allDispellers[d] = p.role == \"HEALER\" and 1 or p.class == \"WARLOCK\" and 2 or 3\n        end\n    end\n    -- preserve old assignments if possible\n    for d, a in pairs(curAssignment) do\n        if allAfflicted[a] and allDispellers[d] then -- still valid\n            assign_(d, a)\n        end\n    end\n    -- assign warlocks to tanks if possible\n    for a, aprio in pairs(allAfflicted) do\n        if aprio == 1 then -- tank\n            for d, dprio in pairs(allDispellers) do\n                if dprio == 2 then -- warlock\n                    assign_(d, a)\n                    break\n                end\n            end\n        end\n    end\n    -- self-assign if possible\n    for d, dprio in pairs(allDispellers) do\n        if allAfflicted[d] then\n            assign_(d, d)\n        end\n    end\n    -- other new assignments\n    for dispellerPriority = 1, 3 do\n        for d, dprio in pairs(allDispellers) do\n            if dprio == dispellerPriority then\n                local a = next(allAfflicted)\n                if not a then break end\n                assign_(d, a)\n            end\n        end\n        if not next(allAfflicted) then break end\n    end\n    -- swap new and old assignments\n    wipe(curAssignment)\n    local tmp = curAssignment\n    curAssignment = newAssignment\n    newAssignment = tmp\n    -- set metadata\n    curAssignerIndex = myCanonicalIndex()\n    lastAssigned = GetTime()\nend\n\nlocal function assignmentToString(assignment)\n    local stringTbl = {}\n    for k, v in pairs(assignment) do\n        tinsert(stringTbl, tostring(k))\n        tinsert(stringTbl, tostring(v))\n    end\n    return table.concat(stringTbl, \" \")\nend\n\nlocal function stringToAssignment(str)\n    local assignment = {}\n    local key = nil\n    gsub(str, \"%d+\", function(tok)\n            local num = tonumber(tok)\n            if not key then\n                key = num\n            else\n                assignment[key] = num\n                key = nil\n            end\n    end)\n    return assignment\nend\n\nlocal function broadcastToRaid(prefix, message)\n    if not IsInGroup() then return end\n    local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and \"INSTANCE_CHAT\" or \"RAID\"\n    debugPrint(\"sending message:\", prefix, message)\n    SendAddonMessage(prefix, message, channel)\nend\n\nlocal function broadcastAssignment(assignment)\n    broadcastToRaid(assignmentPrefix, assignmentToString(assignment))\nend\n\nlocal function onAssignmentReceived(assignment, assignerIndex)\n    local now = GetTime()\n    if now - lastAssigned >= 0.25 or assignerIndex <= curAssignerIndex then\n        debugPrint(\"got assignment from\", assignerIndex, \":\", assignmentToString(assignment))\n        curAssignment, curAssignerIndex, lastAssigned = assignment, assignerIndex, now\n    end\nend\n\nfunction A.CHAT_MSG_ADDON(prefix, message, channel, sender)\n    if prefix == assignmentPrefix then\n        local senderCI = nameToCanonicalIndex(sender)\n        if not senderCI then return end\n        onAssignmentReceived(stringToAssignment(message), senderCI)\n    end\nend\n\nlocal function raidTargetIconString(raidTargetIndex)\n    if raidTargetIndex then\n        return format(\"|TInterface\\\\TargetingFrame\\\\UI-RaidTargetingIcon_%d:0|t\", raidTargetIndex)\n    else\n        return \"\"\n    end\nend\n\nlocal function dispelString(raidIndex)\n    if not raidIndex then return \"\" end\n    \n    local unit = \"raid\"..raidIndex\n    local markerString = raidTargetIconString(GetRaidTargetIndex(unit))\n    \n    local p = raidInfo[raidIndex]\n    local groupText = p.group and tostring(p.group) or \"?\"\n    return format(\"G%s:%s%s\", groupText, markerString, tostring(p.dispName))\nend\n\nlocal function getDefaultAssignmentText(myCI)\n    local a = getNextAfflicted(0)\n    if not a then -- no one to dispel\n        return\n    end\n    local a2 = getNextAfflicted(a + 1)\n    if not a2 then -- only 1 person to dispel\n        return dispelString(canonicalIndexToRaidIndex(a))\n    end\n    -- more than 1 person to dispel\n    return \"Dispel Anyone\"\nend\n\nlocal function getMyAssignmentText(myCI)\n    local afflictedCI = curAssignment[myCI]\n    if not afflictedCI then return end\n    \n    local afflictedRI = canonicalIndexToRaidIndex(afflictedCI)\n    if not afflictedRI then return end\n    \n    -- check debuff locally, since assignment may not be up-to-date\n    if not unitIsAfflicted(\"raid\"..afflictedRI) then return end\n    \n    return dispelString(afflictedRI)\nend\n\nif debugOn then\n    -- print out list of canonical indices\n    every(5, function()\n            local line = {}\n            for i, guid in ipairs(canonicalIndexToGuidMap) do\n                local raidIndex = guidToRaidIndexMap[guid]\n                local p = raidInfo[raidIndex]\n                local dispName = tostring(p.dispName)\n                tinsert(line, i..\":\"..dispName..\"/\"..tostring(p.group))\n                if #line >= 5 then\n                    debugPrint(table.concat(line, \" \"))\n                    wipe(line)\n                end\n            end\n            if #line >= 1 then\n                debugPrint(table.concat(line, \" \"))\n            end\n    end)\nend\n\nlocal lastSound = 0\nlocal soundInterval = 2\n\nlocal function WA_playSound(actions)\n    if(actions.do_sound and actions.sound) then\n        if(actions.sound == \" custom\") then\n            if(actions.sound_path) then\n                PlaySoundFile(actions.sound_path, actions.sound_channel or \"Master\");\n            end\n        elseif(actions.sound == \" KitID\") then\n            if(actions.sound_kit_id) then\n                PlaySoundKitID(actions.sound_kit_id, actions.sound_channel or \"Master\");\n            end\n        else\n            PlaySoundFile(actions.sound, actions.sound_channel or \"Master\");\n        end\n    end\nend\n\nlocal function playSound()\n    if S.actions.start then\n        WA_playSound(S.actions.start)\n    end\nend\n\n-- called close to every frame\nlocal function everyFrame()\n    local now = GetTime()\n    local myCI = myCanonicalIndex()\n    if not myCI then return end\n    if now - lastAssigned > 0.1 + 0.15 * sqrt(myCI) then\n        calcAndSetCurAssignment()\n        broadcastAssignment(curAssignment)\n    end\n    customText = getMyAssignmentText(myCI) or getDefaultAssignmentText(myCI) or \"\"\n    if customText ~= \"\" then\n        if now - lastSound >= soundInterval then\n            lastSound = now\n            playSound()\n        end\n    else\n        -- sound is already played \"On Show\", prevent duplicate sound\n        lastSound = now\n    end\nend\nevery(0.05, everyFrame)",
        do_custom = true
      },
      start = {
        do_sound = true,
        sound = " custom",
        sound_path = "Sound\\Spells\\Spell_FrostCleave_Cast_03.ogg"
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {
      {
        trigger = {
          check = "update",
          custom = "function() return aura_env.statusTrigger() end",
          custom_type = "status",
          type = "custom"
        },
        untrigger = {
          custom = "function() return true end"
        }
      }
    },
    animation = {
      finish = {
        preset = "slideright"
      },
      main = {
        preset = "alphaPulse",
        type = "preset"
      },
      start = {
        preset = "slideleft"
      }
    },
    customText = "function() return aura_env.customTextFunc() end",
    desc = "Arc v1.1-beta 2016-12-07",
    disjunctive = "any",
    displayText = "%c",
    fontSize = 54,
    id = "ToV/03HEL/Taint Assign",
    load = {
      encounterid = "2008",
      size = {
        single = "twenty"
      },
      use_encounterid = true,
      use_size = true
    },
    numTriggers = 2,
    regionType = "text",
    trigger = {
      custom = "function(event, ...) aura_env[event](...) end",
      custom_hide = "custom",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED,CHAT_MSG_ADDON",
      type = "custom"
    },
    untrigger = {
      custom = "function() return true end"
    }
  },
  m = "d",
  s = "2.2.2.1",
  v = 1421
}
