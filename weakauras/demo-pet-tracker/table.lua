{
  d = {
    actions = {
      init = {
        custom = "----- Legion Demo Pet Tracker -----\nlocal A = aura_env\nlocal R = WeakAuras.regions[A.id].region\n-- local S = WeakAurasSaved.displays[A.id]\n\n----- Set options here -----\nlocal numColumns = 8\nlocal showStacksOf1 = false\nlocal stackTextOptions = {\n    font = {\"Fonts\\\\FRIZQT__.TTF\", 20, \"OUTLINE\"},\n    pos = {\"BOTTOMRIGHT\", -8, 8}\n}\nlocal aspectRatio = 1  -- height / width\nlocal coalesceTime = 0.6  -- Timeframe to coalesce spawns\n\n----- GUI -----\n-- R (Region) > tiles (array of Frames) > cooldown, icon, stackText\nR.tiles = R.tiles or {}\nlocal tiles = R.tiles  -- tile index -> Frame\nlocal tilesActive = 0\nlocal tilesExpired = 0\nlocal tileHeight = R:GetHeight()\nlocal tileWidth = tileHeight / aspectRatio\nlocal tileNamePrefix = \"LegionDemoPetTracker\"\nlocal squareTexture = \"Interface\\\\AddOns\\\\WeakAuras\\\\Media\\\\Textures\\\\Square_White\"\n\n----- Pet logic -----\nlocal pets = {}  -- Table of active pets (petGUID -> pet)\nlocal expires = {}\nlocal empowerEnds = {}\nlocal petGY1 = {}\nlocal petGY2 = {}\nlocal lastGYSwap = 0\nlocal permPetGUID\n\n----- Utility -----\nlocal now\nlocal playerGUID = UnitGUID(\"player\")\n\nlocal function bound(x, lower, upper)\n    if x <= lower then return lower\n    elseif x >= upper then return upper\n    else return x\n    end\nend\n\nlocal warnPrefix = \"\\124cff33ffff\" .. A.id .. \": \\124r\"\nlocal function warn(str)\n    DEFAULT_CHAT_FRAME:AddMessage(warnPrefix .. str)\nend\nlocal function warnf(fmt, ...)\n    warn(format(fmt, ...))\nend\n\n----- GUI reset -----\nfor i = 1, #tiles do\n    tiles[i]:Hide()\nend\n\n\n--[[\npet fields: type, guid, start, duration, icon, tile, empowerStart, empowerDuration\ntile fields: index, stacks, empowerStacks, empowerStartSum, empowerDurationSum, empowerNeedsRefresh\nGUI fields: icon, cooldown, highFrame, stackText, empowerBG, empower, empowerAG, empowerAnim\n]]\n\n----- Pet types and base tables -----\nlocal petDB =\n{\n    -- Standard demons\n    [\"Imp\"]        = {duration = 0, icon = \"spell_shadow_summonimp\"},\n    [\"Voidwalker\"] = {duration = 0, icon = \"spell_shadow_summonvoidwalker\"},\n    [\"Succubus\"]   = {duration = 0, icon = \"spell_shadow_summonsuccubus\"},\n    [\"Felhunter\"]  = {duration = 0, icon = \"spell_shadow_summonfelhunter\"},\n    [\"Felguard\"]   = {duration = 0, icon = \"spell_shadow_summonfelguard\"},\n    [\"Fel Imp\"]    = {duration = 0, icon = \"spell_warlock_summonimpoutland\"},\n    [\"Voidlord\"]   = {duration = 0, icon = \"warlock_summon_ voidlord\"},\n    [\"Shivarra\"]   = {duration = 0, icon = \"warlock_summon_ shivan\"},\n    [\"Observer\"]   = {duration = 0, icon = \"warlock_summon_ beholder\"},\n    [\"Wrathguard\"] = {duration = 0, icon = \"spell_warlock_summonwrathguard\"},\n    -- Doomguard/Infernal\n    [\"Doomguard\"]  = {duration = 25, icon = \"warlock_summon_doomguard\"},\n    [\"Infernal\"]   = {duration = 25, icon = \"spell_shadow_summoninfernal\"},\n    -- GrimSup versions\n    [\"SupDoomguard\"] = {duration = 0, icon = \"warlock_summon_doomguard\"},\n    [\"SupInfernal\"]  = {duration = 0, icon = \"spell_shadow_summoninfernal\"},\n    -- GrimServ versions\n    [\"ServImp\"]        = {duration = 25, icon = \"spell_shadow_summonimp\"},\n    [\"ServVoidwalker\"] = {duration = 25, icon = \"spell_shadow_summonvoidwalker\"},\n    [\"ServSuccubus\"]   = {duration = 25, icon = \"spell_shadow_summonsuccubus\"},\n    [\"ServFelhunter\"]  = {duration = 25, icon = \"spell_shadow_summonfelhunter\"},\n    [\"ServFelguard\"]   = {duration = 25, icon = \"spell_shadow_summonfelguard\"},\n    -- Demonology rotation demons\n    [\"Wild Imp\"]     = {duration = 12, icon = \"ability_warlock_impoweredimp\"},\n    [\"Dreadstalker\"] = {duration = 12, icon = \"spell_warlock_calldreadstalkers\"},\n    [\"Darkglare\"]    = {duration = 12, icon = \"achievement_boss_durumu\"},\n}\n-- Prefix icon paths with Interface\\Icons\nfor _, pet in pairs(petDB) do\n    if type(pet.icon) == \"string\" and not strfind(pet.icon, \"\\\\\") then\n        pet.icon = \"Interface\\\\Icons\\\\\" .. pet.icon\n    end\nend\n\nlocal detectDB =\n{\n    [416] = \"Imp\",\n    [1860] = \"Voidwalker\",\n    [417] = \"Felhunter\",\n    [1863] = \"Succubus\",\n    [17252] = \"Felguard\",\n    [58959] = \"Fel Imp\",\n    [58960] = \"Voidlord\",\n    [58963] = \"Shivarra\",\n    [58964] = \"Observer\",\n    [58965] = \"Wrathguard\",\n    [11859] = \"Doomguard\",\n    [89] = \"Infernal\",\n    [78158] = \"SupDoomguard\",\n    [78217] = \"SupInfernal\",\n    [55659] = \"Wild Imp\",\n    [99737] = \"Wild Imp\", -- Improved Dreadstalkers\n    [98035] = \"Dreadstalker\",\n    [103673] = \"Darkglare\",\n}\n\n\nlocal function createTile(i)\n    -- warnf(\"Creating tile %d\", i)\n    -- Name isn't necessary, but helps with debugging\n    local tileName\n    -- Tile frame (parent)\n    if not tiles[i] then\n        R.tileNameCtr = 1 + (R.tileNameCtr or 0)\n        tileName = tileNamePrefix .. R.tileNameCtr\n        tiles[i] = CreateFrame(\"Frame\", tileName .. \"Tile\", R)\n    else\n        tileName = tiles[i]:GetName()\n    end\n    local tile = tiles[i]\n    tile:SetSize(tileWidth, tileHeight)\n    \n    tile.index = i\n    tile.stacks = 0\n    tile.empowerStacks = 0\n    tile.empowerStartSum = 0\n    tile.empowerDurationSum = 0\n    \n    -- Pet icon texture\n    tile.icon = tile.icon\n    or tile:CreateTexture(tileName .. \"Icon\", \"BACKGROUND\")\n    tile.icon:ClearAllPoints()\n    tile.icon:SetAllPoints(tile)\n    tile.icon:Show()\n    \n    -- Cooldown frame\n    tile.cooldown = tile.cooldown\n    or CreateFrame(\"Cooldown\", tileName .. \"Cooldown\", tile, \"CooldownFrameTemplate\")\n    tile.cooldown:ClearAllPoints()\n    tile.cooldown:SetAllPoints(tile)\n    tile.cooldown:SetReverse(true)\n    tile.cooldown:Show()\n    \n    -- A frame manually set to higher frameLevel than cooldown\n    tile.highFrame = tile.highFrame\n    or CreateFrame(\"Frame\", tileName .. \"HighFrame\", tile)\n    tile.highFrame:SetFrameLevel(tile.cooldown:GetFrameLevel() + 1)\n    tile.highFrame:ClearAllPoints()\n    tile.highFrame:SetAllPoints(tile)\n    tile.highFrame:Show()\n    \n    -- Text for # of pets in stack\n    tile.stackText = tile.stackText\n    or tile.highFrame:CreateFontString(tileName .. \"StackText\", \"BACKGROUND\")\n    tile.stackText:SetFont(unpack(stackTextOptions.font))\n    tile.stackText:ClearAllPoints()\n    tile.stackText:SetPoint(\"CENTER\", tile, unpack(stackTextOptions.pos))\n    tile.stackText:Show()\n    \n    -- Demonic Empowerment bar\n    tile.empowerBG = tile.empowerBG\n    or tile:CreateTexture(tileName .. \"EmpowerBG\", \"BACKGROUND\", nil, 0)\n    tile.empowerBG:ClearAllPoints()\n    tile.empowerBG:SetPoint(\"BOTTOMLEFT\", tile, \"TOPLEFT\")\n    tile.empowerBG:SetSize(tileWidth, tileHeight * 0.2)\n    tile.empowerBG:SetTexture(squareTexture)\n    tile.empowerBG:SetVertexColor(0, 0, 0, 0.5)\n    tile.empowerBG:Hide()\n    \n    tile.empower = tile.empower\n    or tile:CreateTexture(tileName .. \"Empower\", \"BACKGROUND\", nil, 1)\n    tile.empower:ClearAllPoints()\n    tile.empower:SetPoint(\"BOTTOMLEFT\", tile, \"TOPLEFT\")\n    tile.empower:SetSize(tileWidth, tileHeight * 0.2)\n    tile.empower:SetTexture(squareTexture)\n    tile.empower:SetVertexColor(1, 0, 1, 1)\n    tile.empower:Hide()\n    \n    tile.empowerAG = tile.empowerAG\n    or tile.empower:CreateAnimationGroup(tileName .. \"EmpowerAG\")\n    tile.empowerAG.tile = tile\n    \n    tile.empowerAnim = tile.empowerAnim\n    or tile.empowerAG:CreateAnimation(\"Scale\")\n    tile.empowerAnim:SetOrigin(\"LEFT\", 0, 0)\n    tile.empowerAnim:SetScale(0, 1)\n    tile.empowerAnim:SetDuration(12)\n    \n    return tile\nend\n\nlocal function setTilePos(tile, i)\n    local col = (i - 1) % numColumns\n    local row = floor((i - 1) / numColumns)\n    \n    tile:ClearAllPoints()\n    tile:SetPoint(\"TOPLEFT\", R, \"TOPLEFT\",\n    col * tileWidth, -row * tileHeight * 1.2)\nend\n\n\nlocal function refreshEmpowerAnim(tile)\n    if tile.empowerStacks == 0 then\n        -- Stop the animation\n        tile.empowerAG:Stop()\n        tile.empowerBG:Hide()\n        tile.empower:Hide()\n    else\n        -- Refresh animation using buff means\n        local startTime = tile.empowerStartSum / tile.empowerStacks\n        local duration = tile.empowerDurationSum / tile.empowerStacks\n        local endTime = startTime + duration\n        local remain = bound(endTime - now, 0, duration)\n        local fullDuration = max(duration, 12)\n        \n        -- Set initial width, bar will smoothly shrink to 0 over remaining duration\n        tile.empower:SetWidth(tileWidth * (remain / fullDuration))\n        -- Set height to fraction of pets empowered\n        tile.empower:SetHeight(tileHeight * 0.2 * tile.empowerStacks / tile.stacks)\n        -- Reset and play new animation\n        tile.empowerAG:Stop()\n        tile.empowerAnim:SetDuration(remain)\n        tile.empowerAG:Play()\n        tile.empowerBG:Show()\n        tile.empower:Show()\n    end\n    tile.empowerNeedsRefresh = false\nend\n\n-- Runs every frame (must precede collapseTiles)\nlocal function refreshEmpowerAnims()\n    for i = 1, tilesActive do\n        if tiles[i].empowerNeedsRefresh then\n            refreshEmpowerAnim(tiles[i])\n        end\n    end\nend\n\n\nlocal function clearEmpower(pet)\n    if not pet.empowerStart then return end\n    local tile = pet.tile\n    tile.empowerNeedsRefresh = true\n    tile.empowerStacks = tile.empowerStacks - 1\n    if tile.empowerStacks == 0 then\n        -- Just to prevent float error accumulation\n        tile.empowerStartSum = 0\n        tile.empowerDurationSum = 0\n    else\n        tile.empowerStartSum = tile.empowerStartSum - pet.empowerStart\n        tile.empowerDurationSum = tile.empowerDurationSum - pet.empowerDuration\n    end\n    pet.empowerStart = nil\n    pet.empowerDuration = nil\nend\n\nlocal function clearEmpowerIfEnded(pet)\n    if not pet.empowerStart then return end\n    if now >= (pet.empowerStart + pet.empowerDuration) then\n        clearEmpower(pet)\n    end\nend\n\nlocal function setEmpower(pet, duration)\n    local tile = pet.tile\n    duration = max(0, duration)\n    clearEmpower(pet)\n    pet.empowerStart = now\n    pet.empowerDuration = duration\n    tile.empowerNeedsRefresh = true\n    tile.empowerStacks = tile.empowerStacks + 1\n    tile.empowerStartSum = tile.empowerStartSum + now\n    tile.empowerDurationSum = tile.empowerDurationSum + duration\n    C_Timer.After(duration, function() tinsert(empowerEnds, pet.guid) end)\nend\n\n-- Run every frame\nlocal function endEmpowers()\n    for i, guid in ipairs(empowerEnds) do\n        empowerEnds[i] = nil\n        local pet = pets[guid]\n        if pet then\n            clearEmpowerIfEnded(pet)\n        end\n    end\nend\n\n-- Handle Demonic Empowerment aura apply/refresh\nlocal function onEmpower(subEvent, guid)\n    if guid == playerGUID then return end\n    local pet = pets[guid]\n    if not pet then return end\n    local tile = pet.tile\n    -- warnf(\"Empower [type=%s] [guid=%s] [tile=%d]\", pet.type, guid, tile.index)\n    \n    local newDuration\n    if subEvent == \"SPELL_AURA_APPLIED\" or not pet.empowerStart then\n        newDuration = 12\n    else\n        local remain = pet.empowerDuration - (now - pet.empowerStart)\n        newDuration = 12 + bound(remain, 0, 3.6)\n    end\n    setEmpower(pet, newDuration)\nend\n\n\n-- Get the pet from pets table or GYs\nlocal function knownPet(guid)\n    return pets[guid] or petGY1[guid] or petGY2[guid]\nend\n\nlocal function addPet(type, guid)\n    local base = petDB[type]\n    if not base then return end\n    -- warnf(\"Add [type=%s] [guid=%s])\", type, guid)\n    local pet = { type = type, guid = guid, start = now }\n    for k, v in pairs(base) do pet[k] = v end\n    pets[guid] = pet\n    \n    -- duration 0 = permanent\n    if pet.duration ~= 0 then\n        C_Timer.After(pet.duration, function() tinsert(expires, guid) end)\n    end\n    \n    local i, tile\n    for j = tilesActive, 1, -1 do\n        local tile_ = tiles[j]\n        if now - tile_.start >= coalesceTime then\n            break\n        end\n        if tile_.type == type then\n            i = j\n            tile = tile_\n            break\n        end\n    end\n    \n    if i then\n        -- warnf(\"Coalesced spawn to tile %d\", i)\n        tile.stacks = tile.stacks + 1\n    else\n        tilesActive = tilesActive + 1\n        i = tilesActive\n        -- warnf(\"Didn't coalesce spawn; new tile %d\", i)\n        if not tiles[i] then\n            tiles[i] = createTile(i)\n            setTilePos(tiles[i], i)\n        end\n        tile = tiles[i]\n        tile.stacks = 1\n        tile.start = now\n        tile.type = type\n    end\n    pet.tile = tile\n    \n    if pet.duration ~= 0 then\n        tile.cooldown:SetCooldown(now, pet.duration)\n    end\n    tile.stackText:SetText(\n        (tile.stacks ~= 1 or showStacksOf1) and tile.stacks or nil)\n    tile.icon:SetTexture(pet.icon)\n    tile:Show()\nend\n\nlocal function expireOne(guid)\n    -- Move pet to gy; inactivate tile if 0 stacks\n    local pet = pets[guid]\n    if pet then\n        -- warnf(\"Expire [type=%s] [guid=%s]\", pet.type, guid)\n        pets[guid] = nil\n        petGY1[guid] = pet\n        \n        clearEmpower(pet)\n        \n        local tile = pet.tile\n        tile.stacks = tile.stacks - 1\n        tile.stackText:SetText(tile.stacks)\n        \n        if tile.stacks == 0 then\n            tilesExpired = tilesExpired + 1\n            assert(tile.empowerStacks == 0)\n            tile:Hide()\n        end\n    end\nend\n\n-- Run every frame\nlocal function expirePets()\n    assert(tilesExpired == 0)\n    for i, guid in ipairs(expires) do\n        expires[i] = nil\n        expireOne(guid)\n    end\nend\n\n-- Run every frame (after expirePets)\nlocal function collapseTiles()\n    if tilesExpired == 0 then\n        return\n    end\n    tilesActive = tilesActive - tilesExpired\n    tilesExpired = 0\n    assert(tilesActive >= 0)\n    \n    local j = 1\n    for i = 1, tilesActive do\n        if tiles[i].stacks == 0 then\n            if j < i + 1 then\n                j = i + 1\n            end\n            while true do\n                if tiles[j].stacks > 0 then -- Swap i with j\n                    local t1, t2 = tiles[i], tiles[j]\n                    tiles[j] = t1 -- Swap their indices\n                    t1.index = j\n                    tiles[i] = t2\n                    t2.index = i\n                    setTilePos(t1, j) -- Swap their positions\n                    setTilePos(t2, i)\n                    break\n                else\n                    j = j + 1\n                end\n            end\n        end\n    end\nend\n\n-- Run every frame\nlocal function handleGYSwap()\n    if now - lastGYSwap < 30 then return end\n    lastGYSwap = now\n    wipe(petGY2)\n    local tmp = petGY2\n    petGY2 = petGY1\n    petGY1 = tmp\nend\n\nlocal detectPetType_\ndetectPetType_ = {\n    gsubFun = function(b, i)\n        detectPetType_.base = b\n        detectPetType_.id = tonumber(i)\n    end\n}\n\nlocal function detectPetType(guid)\n    local base, id, type\n    local env = detectPetType_\n    env.base, env.id = nil\n    gsub(guid, \"(%w*)-.*-(%d*)-%w*\", env.gsubFun)\n    type = detectDB[env.id]\n    if not type then return nil end\n    if base == \"Creature\" and petDB[\"Serv\" .. type] then\n        return \"Serv\" .. type\n    else\n        return type\n    end\nend\n\nlocal function isMine(flags)\n    return (bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE)\n    == COMBATLOG_OBJECT_AFFILIATION_MINE)\nend\n\nlocal function detectAndAdd(guid)\n    if guid ~= playerGUID\n    and not knownPet(guid) then\n        local type = detectPetType(guid)\n        -- Don't add permanent pets from combat log events\n        if type and petDB[type].duration > 0 then\n            addPet(type, guid)\n        end\n    end\nend\n\n-- Runs on event COMBAT_LOG_EVENT_UNFILTERED\nlocal function onCombatEvent(_, subEvent, _,\n        sourceGUID, sourceName, sourceFlags, _,\n    destGUID, destName, destFlags, _, ...)\n    \n    if isMine(sourceFlags) then\n        detectAndAdd(sourceGUID)\n    end\n    \n    if isMine(destFlags)\n    or (sourceGUID == playerGUID and subEvent == \"SPELL_SUMMON\") then\n        detectAndAdd(destGUID)\n    end\n    \n    if sourceGUID == playerGUID then\n        if subEvent == \"SPELL_AURA_APPLIED\"\n        or subEvent == \"SPELL_AURA_REFRESH\" then\n            local spellId, spellName = ...\n            if spellName == \"Demonic Empowerment\" then\n                onEmpower(subEvent, destGUID)\n            end\n        end\n    end\n    \n    if (subEvent == \"SPELL_INSTAKILL\" or subEvent == \"UNIT_DIED\")\n    and pets[destGUID] then\n        tinsert(expires, destGUID)\n    end\nend\n\n-- Run every frame\nlocal function checkPermPet()\n    local guid = UnitGUID(\"pet\")\n    if guid == permPetGUID then return end\n    \n    if permPetGUID and pets[permPetGUID] then\n        -- Expire the old pet\n        tinsert(expires, permPetGUID)\n    end\n    \n    if guid and not pets[guid] then\n        -- Add the new pet\n        local type = detectPetType(guid)\n        if type then\n            if petDB[type].duration == 0 then\n                addPet(type, guid)\n            else\n                warnf(\"Pet detected as non-permanent type %s\", type)\n            end\n        end\n    end\n    \n    permPetGUID = guid\nend\n\n-- Runs on every frame\nlocal function onUpdate()\n    checkPermPet()\n    endEmpowers()\n    expirePets()\n    refreshEmpowerAnims()\n    collapseTiles()\n    handleGYSwap()\nend\n\n-- Custom text function\nlocal function doText()\n    now = GetTime()\n    onUpdate()\nend\nA.doText = doText\n\n-- Trigger handler\nlocal function doTrigger(event, ...)\n    now = GetTime()\n    onCombatEvent(...)\n    return true\nend\nA.doTrigger = doTrigger\n\n\n",
        do_custom = true
      }
    },
    activeTriggerMode = 0,
    additional_triggers = {},
    auto = false,
    color = {
      [4] = 0
    },
    customText = "function()\n    return aura_env.doText()\nend",
    desc = "Arc v1.1 2016-08-16",
    displayIcon = "Interface\\Icons\\inv_misc_questionmark",
    displayStacks = "%c",
    height = 39.999641418457003,
    id = "Legion Demo Pet Tracker",
    init_completed = 1,
    load = {
      difficulty = {
        multi = {}
      },
      faction = {
        multi = {}
      },
      pvptalent = {
        multi = {}
      },
      race = {
        multi = {}
      },
      role = {
        multi = {}
      },
      talent = {
        multi = {}
      },
      use_never = false
    },
    numTriggers = 1,
    regionType = "icon",
    selfPoint = "LEFT",
    trigger = {
      custom = "function(...)\n    return aura_env.doTrigger(...)\nend",
      custom_hide = "timed",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED",
      type = "custom"
    },
    width = 40.000053405761697,
    xOffset = -956.55195260047901,
    yOffset = 338.444580078125
  },
  m = "d",
  s = "2.2.1.1",
  v = 1421
}
