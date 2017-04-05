{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal customText = \"\"\n\nlocal throttleInterval = 0.05\nlocal lastRefresh = 0\nlocal refreshPending = true\n\n-- round an integer to about 3 significant figures with suffix, e.g. 24.5k\nlocal kSuffixes = {\"k\", \"m\", \"b\", \"t\", \"q\"}\nlocal function intToString3(x)\n    if x < x then\n        return \"NaN\"\n    elseif x == math.huge then\n        return \"+Inf\"\n    elseif x == -math.huge then\n        return \"-Inf\"\n    elseif x < 0 then\n        return \"-\"..intToString3(-x)\n    elseif x < 10000 then\n        return format(\"%.f\", x)\n    else\n        local cap, div, count, subcount, final = 99500, 1000, 1, 1, false\n        while true do\n            if x < cap or (subcount == 2 and not kSuffixes[count + 1]) then\n                return format(\"%.\"..(2-subcount)..\"f\", x / div)..kSuffixes[count]\n            end\n            subcount = subcount + 1\n            cap = cap * 10\n            if subcount == 3 then\n                subcount = 0\n                count = count + 1\n                div = div * 1000\n            end\n        end\n    end\nend\n\nlocal function progressFractionToColor(frac)\n    if not (frac and frac >= 0 and frac <= 1) then\n        return \"ffffff\"\n    end\n    if frac <= 0.5 then\n        return format(\"ff%02x00\", frac * 511.999) -- red to yellow\n    else\n        return format(\"%02xff00\", (1 - frac) * 511.999) -- yellow to green\n    end\nend\n\nlocal GetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo\nlocal GetCostForPointAtRank = C_ArtifactUI.GetCostForPointAtRank\n\nlocal function calcCustomText()\n    local itemID, altItemID, name, icon, xp, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop, artifactTier = GetEquippedArtifactInfo()\n    if not itemID then return end\n    \n    local pointsAvailable = 0\n    local nextRankCost = GetCostForPointAtRank(pointsSpent + pointsAvailable, artifactTier) or 0\n    \n    while xp >= nextRankCost do\n        xp = xp - nextRankCost\n        pointsAvailable = pointsAvailable + 1\n        nextRankCost = GetCostForPointAtRank(pointsSpent + pointsAvailable, artifactTier) or 0\n    end\n    \n    local fraction = xp / nextRankCost\n    local bonusString = (pointsAvailable <= 0) and \"\" or format(\", |cff00ff00%d available|r\", pointsAvailable)\n    \n    return format(\"[AP: %s / %s (|cff%s%.1f%%%%|r), next in %s%s]\",\n        intToString3(xp), intToString3(nextRankCost),\n        progressFractionToColor(fraction), fraction * 100,\n        intToString3(nextRankCost - xp), bonusString)\nend\n\nfunction A.ARTIFACT_XP_UPDATE()\n    refreshPending = true\nend\n\nfunction A.UNIT_INVENTORY_CHANGED(unit)\n    if unit == \"player\" then\n        refreshPending = true\n    end\nend\n\nfunction A.customTextFunc()\n    if refreshPending then\n        local now = GetTime()\n        if now - lastRefresh > throttleInterval then\n            refreshPending = false\n            customText = calcCustomText()\n        end\n    end\n    return customText\nend\n\n\n",
        do_custom = true
      }
    },
    activeTriggerMode = 1,
    additional_triggers = {
      {
        trigger = {
          event = "Conditions",
          subeventPrefix = "SPELL",
          subeventSuffix = "_CAST_START",
          type = "status",
          unevent = "auto",
          unit = "player",
          use_alwaystrue = true,
          use_unit = true
        },
        untrigger = {}
      }
    },
    customText = "function() return aura_env.customTextFunc() end",
    disjunctive = "any",
    displayText = "%c",
    font = "FrancoisOne",
    fontSize = 14,
    height = 13.999973297119141,
    id = "Artifact Power",
    init_completed = 1,
    load = {
      difficulty = {
        multi = {}
      },
      faction = {
        multi = {}
      },
      level = "100",
      level_operator = ">=",
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
      use_level = true,
      use_petbattle = false
    },
    numTriggers = 2,
    regionType = "text",
    trigger = {
      custom = "function(event, ...) aura_env[event](...) end",
      custom_hide = "timed",
      custom_type = "event",
      events = "ARTIFACT_XP_UPDATE,UNIT_INVENTORY_CHANGED",
      type = "custom"
    },
    width = 277.00003051757813,
    yOffset = 524
  },
  m = "d",
  s = "2.3.9",
  v = 1421
}
