{
  a = {
    ["Touch of Karma"] = 651728
  },
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal playerGUID = UnitGUID(\"player\")\nlocal legendary\nlocal absorbLeft = 0\n\nlocal function checkLegendary()\n    legendary = IsEquippedItem(\"Cenedril, Reflector of Hatred\")\nend\n\ncheckLegendary()\nC_Timer.After(5, checkLegendary)\n\nfunction A.PLAYER_EQUIPMENT_CHANGED(slot, hasItem)\n    if slot == INVSLOT_BACK then\n        if hasItem then\n            checkLegendary()\n        else\n            legendary = false\n        end\n    end\nend\n\nfunction A.COMBAT_LOG_EVENT_UNFILTERED(_, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)\n    if subEvent == \"SPELL_CAST_SUCCESS\" and sourceGUID == playerGUID then\n        local spellID, spellName, _ = ...\n        if spellName == \"Touch of Karma\" then\n            absorbLeft = (legendary and 2 or 0.5) * (UnitHealthMax(\"player\") or 0)\n        end\n    elseif subEvent == \"SPELL_ABSORBED\" and destGUID == playerGUID then\n        local index = (... == destGUID) and 5 or 8\n        local absorbSpellID, absorbSpellName, _, absorbAmount = select(index, ...)\n        if absorbSpellName == \"Touch of Karma\" then\n            absorbLeft = absorbLeft - absorbAmount\n        end\n    end\nend\n\n-- round an integer to about 3 significant figures with suffix, e.g. 24.5k\nlocal kSuffixes = {\"k\", \"m\", \"b\", \"t\", \"q\"}\nlocal function intToString3(x)\n    if x < x then\n        return \"NaN\"\n    elseif x == math.huge then\n        return \"+Inf\"\n    elseif x == -math.huge then\n        return \"-Inf\"\n    elseif x < 0 then\n        return \"-\"..intToString3(-x)\n    elseif x < 10000 then\n        return format(\"%.f\", x)\n    else\n        local cap, div, count, subcount, final = 99500, 1000, 1, 1, false\n        while true do\n            if x < cap or (subcount == 2 and not kSuffixes[count + 1]) then\n                return format(\"%.\"..(2-subcount)..\"f\", x / div)..kSuffixes[count]\n            end\n            subcount = subcount + 1\n            cap = cap * 10\n            if subcount == 3 then\n                subcount = 0\n                count = count + 1\n                div = div * 1000\n            end\n        end\n    end\nend\n\nfunction A.customTextFunc()\n    return intToString3(absorbLeft)\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {
      {
        trigger = {
          custom = "function(event, ...) aura_env[event](...) end",
          custom_type = "event",
          events = "COMBAT_LOG_EVENT_UNFILTERED, PLAYER_EQUIPMENT_CHANGED",
          type = "custom"
        },
        untrigger = {
          custom = "function() return true end"
        }
      }
    },
    cooldown = true,
    customText = "function() return aura_env.customTextFunc() end",
    desc = "Arc v1.0 2016-10-15",
    disjunctive = "any",
    displayStacks = "%c",
    fontSize = 16,
    height = 36,
    id = "Touch of Karma",
    init_completed = 1,
    load = {
      class = {
        single = "MONK"
      },
      spec = {
        single = 3
      },
      use_class = true,
      use_spec = true
    },
    numTriggers = 2,
    regionType = "icon",
    stacksContainment = "OUTSIDE",
    stacksPoint = "TOP",
    trigger = {
      names = {
        "Touch of Karma"
      }
    },
    width = 36
  },
  i = 651728,
  m = "d",
  s = "2.2.1.6",
  v = 1421
}
