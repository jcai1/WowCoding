{
  d = {
    actions = {
      init = {
        custom = "local playerGUID = UnitGUID(\"player\")\nlocal rings = {\n    [\"Nithramus\"] = 187616, -- These are buff IDs\n    [\"Thorasus\"] = 187619,\n    [\"Maalus\"] = 187620\n}\nlocal rings2 = {}; for k, v in pairs(rings) do rings2[v] = k end\nlocal bonusMap = {\n    [0]   = 25.00,\n    [622] = 25.71,\n    [623] = 26.42,\n    [624] = 27.19,\n    [625] = 27.96,\n    [626] = 28.73,\n    [627] = 29.56,\n    [628] = 30.38,\n    [629] = 31.24,\n    [630] = 32.13,\n    [631] = 33.05,\n    [632] = 33.99,\n    [633] = 34.94,\n    [634] = 35.95,\n    [635] = 36.95,\n    [636] = 38.02,\n    [637] = 39.08,\n    [638] = 40.21,\n    [639] = 41.33,\n    [640] = 42.51,\n    [641] = 43.70\n}\nlocal accum = 0\nlocal buffTime = 0\nlocal unbuffTime = 0\nlocal pct = nil\n\nlocal band, bor = bit.band, bit.bor\n\nlocal isMine_types = bor(COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_TYPE_PET, COMBATLOG_OBJECT_TYPE_GUARDIAN)\n-- Returns true if flags indicate unit is myself, my pet, or my guardian\nlocal function isMine(flags)\n    return band(flags, isMine_types) ~= 0 and band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0\nend\n\nlocal function buffAbsent()\n    if buffed then\n        unbuffTime = GetTime()\n        buffed = false\n    end\nend\n\nlocal function recalc()\n    for ring, _ in pairs(rings) do\n        -- pct1 = from UnitBuff, pct2 = from item link\n        local pct1, pct2\n        pct1 = select(18, UnitBuff(\"player\", ring))\n        if pct1 then -- buff is active\n            for i = 1, 2 do\n                local link, bonus\n                link = GetInventoryItemLink(\"player\", _G[\"INVSLOT_FINGER\"..i])\n                if link then\n                    gsub(link, \"(%d+)\\124h%[\"..ring, function(bonusStr) bonus = tonumber(bonusStr) end)\n                    if bonus then\n                        pct2 = bonusMap[bonus]\n                        break\n                    end\n                end\n            end\n            if pct2 and abs(pct2 - pct1) <= 1 then\n                pct = pct2\n            else\n                -- Occurs when ring is scaled down (e.g. timewalking); item link doesn't reflect that\n                pct = pct1\n            end\n            if not buffed then\n                accum = 0\n                buffed = true\n                buffTime = GetTime()\n            end\n            return\n        end\n    end\n    buffAbsent()\nend\n\nlocal function doCombatTrigger(_, _, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)\n    if destGUID == playerGUID then\n        if subEvent == \"SPELL_AURA_APPLIED\" then\n            local spellID = ...\n            if rings2[spellID] then\n                recalc()\n                return\n            end\n        elseif subEvent == \"SPELL_AURA_REMOVED\" then\n            local spellID = ...\n            if rings2[spellID] then\n                buffAbsent()\n                return\n            end\n        end\n    end\n    \n    if buffed then\n        if sourceGUID == playerGUID and subEvent == \"SPELL_DAMAGE\" and rings[select(2, ...)] then\n            buffAbsent()\n            return\n        end\n        \n        -- Count damage done by myself/pets to targets that are not myself/pets\n        if isMine(sourceFlags) and not isMine(destFlags) and destName ~= \"Prismatic Crystal\" then\n            local dmg, okill = 0, 0\n            if subEvent == \"SWING_DAMAGE\" then\n                dmg, okill = ...\n            elseif subEvent == \"RANGE_DAMAGE\" or subEvent == \"SPELL_DAMAGE\" or subEvent == \"SPELL_PERIODIC_DAMAGE\" then\n                dmg, okill = select(4, ...)\n            else\n                return\n            end\n            accum = accum + dmg - okill\n        end\n    end\nend\naura_env.doCombatTrigger = doCombatTrigger\n\nlocal function doText()\n    if WeakAuras.IsOptionsOpen() then\n        return \"1.11m\"\n    end\n    \n    local t = GetTime()\n    \n    if buffed and t - buffTime > 17.5 then\n        -- Assume buff has expired\n        buffAbsent()\n    end\n    \n    if not buffed and t - unbuffTime > 4 then\n        return \"\"\n    end\n    \n    local amt, guess, dispAmt\n    if pct then\n        amt = accum * pct / 100\n        guess = false\n    else\n        amt = accum * 0.25\n        guess = true\n    end\n    \n    if amt < 10000 then -- 0 to 9999\n        dispAmt = format(\"%.f\", amt)\n    elseif amt < 99950 then -- 10.0k to 99.9k\n        dispAmt = format(\"%.1f\", amt / 1000) .. \"k\"\n    elseif amt < 999500 then -- 100k to 999k\n        dispAmt = format(\"%.f\", amt / 1000) .. \"k\"\n    else -- 1.00m +\n        dispAmt = format(\"%.2f\", amt / 1000000) .. \"m\"\n    end\n    \n    return (buffed and \"|c00FF6699\"..dispAmt..\"|r\" or dispAmt)\n    .. (guess and \"?\" or \"\")\nend\naura_env.doText = doText\n\nrecalc()",
        do_custom = true
      },
      start = {
        do_custom = false
      }
    },
    activeTriggerMode = 0,
    customText = "function()\n    return aura_env.doText()\nend\n\n\n\n\n\n\n\n\n\n",
    desc = "Arc v0.7 2016-07-20",
    displayText = "%c",
    font = "FrancoisOne",
    fontSize = 18,
    height = 18.000003814697266,
    id = "L.Ring Dmg (Self)",
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
    regionType = "text",
    trigger = {
      custom = "function(...)\n    aura_env.doCombatTrigger(...)\n    return true\nend",
      custom_hide = "custom",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED",
      type = "custom"
    },
    untrigger = {
      custom = "function() return true end\n\n\n\n\n\n"
    },
    width = 46.999992370605469,
    xOffset = -261,
    yOffset = 290.00027465820301
  },
  m = "d",
  s = "2.2.0.1",
  v = 1421
}