{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal playerGUID = UnitGUID(\"player\")\n\nlocal function colorText(c, s)\n    return format(\"|cff%s%s|r\", c, s)\nend\n\nlocal readyText  = colorText(\"00ff00\", \"Ready\")\nlocal icdText    = colorText(\"ffff00\", \"ICD\")\nlocal activeText = colorText(\"ffffff\", \"Active\")\n\nlocal equipped\nlocal customText = readyText\nlocal icdEnd\nlocal duration, expires\n\nlocal function checkEquipped()\n    equipped = IsEquippedItem(\"Sephuz's Secret\")\nend\n\ncheckEquipped()\nC_Timer.After(5, checkEquipped)\n\nfunction A.PLAYER_EQUIPMENT_CHANGED(slot, hasItem)\n    if slot == INVSLOT_FINGER1 or slot == INVSLOT_FINGER2 then\n        checkEquipped()\n    end\nend\n\nlocal function buffRemoved() -- idempotent\n    if icdEnd then -- in case reloaded while active\n        customText = icdText\n        duration = 20\n        expires = icdEnd\n    end\nend\n\nlocal function icdEnded()\n    if GetTime() >= icdEnd then -- avoid race\n        customText = readyText\n        icdEnd = nil\n        duration = nil\n        expires = nil\n    end\nend\n\nlocal function buffApplied()\n    local now = GetTime()\n    customText = activeText\n    icdEnd = now + 30\n    duration = 10\n    expires = now + 10\n    C_Timer.After(10, buffRemoved)\n    C_Timer.After(30, icdEnded)\nend\n\nfunction A.COMBAT_LOG_EVENT_UNFILTERED(_, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, ...)\n    if equipped and destGUID == playerGUID then\n        if event == \"SPELL_AURA_APPLIED\" and select(2, ...) == \"Sephuz's Secret\" then\n            buffApplied()\n        elseif (event == \"SPELL_AURA_REMOVED\" and select(2, ...) == \"Sephuz's Secret\") or event == \"UNIT_DIED\" then\n            buffRemoved()\n        end\n    end\nend\n\nfunction A.statusTrigger()\n    return equipped\nend\n\nfunction A.customTextFunc()\n    return customText\nend\n\nfunction A.durationFunc()\n    return duration, expires\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {
      {
        trigger = {
          custom = "function(event, ...) aura_env[event](...) end",
          custom_hide = "custom",
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
    displayIcon = 645145,
    displayStacks = "%c",
    height = 36,
    id = "Sephuz's Secret",
    numTriggers = 2,
    regionType = "icon",
    stacksContainment = "OUTSIDE",
    stacksPoint = "TOP",
    trigger = {
      check = "update",
      custom = "function() return aura_env.statusTrigger() end",
      customDuration = "function() return aura_env.durationFunc() end",
      custom_type = "status",
      type = "custom"
    },
    untrigger = {
      custom = "function() return true end"
    },
    width = 36
  },
  m = "d",
  s = "2.2.1.6",
  v = 1421
}
