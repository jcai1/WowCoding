{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\n-- local R = WeakAuras.regions[A.id].region\n\n-- Custom text\nlocal lastTextRefresh = 0        -- Time of last refresh\nlocal textRefreshInterval = 0.1    -- Interval between refreshes\nlocal text = \"\"                    -- Actual text to display\n\nlocal playerGUID                -- Stored UnitGUID(\"player\")\nlocal trinketID = 124517        -- Item ID for Sacred Draenic Incense\nlocal equipped                    -- Whether the trinket is equipped\n\nlocal procCount = 0                -- # of procs since combat started\nlocal castsPending = 0            -- # of RSK casts expecting an RSK hit\nlocal inCombat                    -- In combat?\nlocal preCombat = false            -- Did we reset stats anticipating combat?\n\n-- RSK cast \"cancels\" the next RSK hit.\nlocal function onRSKCast(t)\n    -- RSK cast can occur immediately before entering combat\n    -- If this is the case, reset stats now, and tell onEnteringCombat not to.\n    if not inCombat then\n        procCount = 0\n        castsPending = 0\n        preCombat = true\n    end\n    castsPending = castsPending + 1\nend\n\n-- If an RSK hits without associated cast, count as trinket proc.\nlocal function onRSKHit(t)\n    if castsPending > 0 then\n        castsPending = castsPending - 1\n    else\n        procCount = procCount + 1\n    end\nend\n\n-- COMBAT_LOG_EVENT_UNFILTERED handler\nlocal function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)\n    if equipped and sourceGUID == playerGUID then\n        if subEvent == \"SPELL_CAST_SUCCESS\" then\n            if ... == 107428 then\n                -- RSK cast event\n                onRSKCast(t)\n            end\n        elseif subEvent == \"SPELL_DAMAGE\" then\n            if ... == 185099 and not select(14, ...) then\n                -- RSK damage event, not multistrike\n                onRSKHit(t)\n            end\n        elseif subEvent == \"SPELL_MISSED\" then\n            if ... == 185099 and not select(6, ...) then\n                -- RSK miss event, not multistrike\n                onRSKHit(t)\n            end\n        end\n    end\nend\n\n-- PLAYER_REGEN_DISABLED handler\nlocal function onEnteringCombat()\n    -- Reset stats, if onRSKCast() didn't do it.\n    if preCombat then\n        preCombat = false\n    else\n        castsPending = 0\n        procCount = 0\n    end\n    -- Update combat status.\n    inCombat = true\nend\n\n-- PLAYER_REGEN_ENABLED handler\nlocal function onLeavingCombat()\n    -- Update combat status.\n    inCombat = false\nend\n\n-- Checks whether Sacred Draenic Incense is equipped\nlocal function isTrinketEquipped()\n    return (GetInventoryItemID(\"player\", INVSLOT_TRINKET1) == trinketID\n        or GetInventoryItemID(\"player\", INVSLOT_TRINKET2) == trinketID)\nend\n\n-- PLAYER_EQUIPMENT_CHANGED handler\nlocal function onEquipmentChanged()\n    equipped = isTrinketEquipped()\nend\n\n-- Called immediately, but also after PLAYER_ENTERING_WORLD with delay.\n-- This prevents issues with cold login.\nlocal function doDelayedLoad()\n    onEquipmentChanged() -- Check equipment\n    playerGUID = UnitGUID(\"player\")\n    inCombat = UnitAffectingCombat(\"player\")\nend\ndoDelayedLoad()\n\n-- PLAYER_ENTERING_WORLD handler\nlocal function onEnteringWorld()\n    C_Timer.After(1, doDelayedLoad) -- Set up delayed load\nend\n\n-- What the trigger should return. true => shown, false => hidden.\nlocal function shouldShow()\n    -- Show WA only if equipped\n    return equipped\nend\n\n-- Trigger dispatch handler\n-- We ignore return value of dispatch functions, and instead use shouldShow()\nlocal dispatchTable = {\n    [\"COMBAT_LOG_EVENT_UNFILTERED\"] = onCombatEvent,\n    [\"PLAYER_REGEN_DISABLED\"] = onEnteringCombat,\n    [\"PLAYER_REGEN_ENABLED\"] = onLeavingCombat,\n    [\"PLAYER_EQUIPMENT_CHANGED\"] = onEquipmentChanged,\n    [\"PLAYER_ENTERING_WORLD\"] = onEnteringWorld,\n}\nlocal function doTrigger(event, ...)\n    local dispatchFunc = dispatchTable[event]\n    dispatchFunc(...)\n    return shouldShow()\nend\nA.doTrigger = doTrigger\n\n-- Return a new custom text string\nlocal function makeText()\n    return tostring(procCount)\nend\n\n-- Custom text function\nlocal function doText()\n    local t = GetTime()\n    if t - lastTextRefresh > textRefreshInterval then\n        lastTextRefresh = t\n        text = makeText()\n    end\n    return text\nend\nA.doText = doText\n\n",
        do_custom = true
      }
    },
    customText = "function()\n    return aura_env.doText()\nend",
    desc = "Arc v0.1 2016-03-26",
    displayIcon = "Interface\\Icons\\ability_monk_risingsunkick",
    displayStacks = "%c",
    fontSize = 24,
    height = 45,
    id = "Furious Sun Counter",
    init_completed = 1,
    load = {
      class = {
        single = "MONK"
      },
      difficulty = {
        multi = {}
      },
      faction = {
        multi = {}
      },
      race = {
        multi = {}
      },
      role = {
        multi = {}
      },
      spec = {
        single = 3
      },
      talent = {
        multi = {}
      },
      use_class = true,
      use_petbattle = false,
      use_spec = true
    },
    numTriggers = 1,
    regionType = "icon",
    stacksPoint = "CENTER",
    textColor = {
      0,
      [3] = 0.94509803921568603
    },
    trigger = {
      custom = "function(...)\n    return aura_env.doTrigger(...)\nend",
      custom_hide = "custom",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, PLAYER_EQUIPMENT_CHANGED, PLAYER_ENTERING_WORLD",
      type = "custom"
    },
    untrigger = {
      custom = "function()\n    return true\nend\n\n\n\n"
    },
    width = 45
  },
  m = "d",
  s = "2.1.0.23",
  v = 1421
}
