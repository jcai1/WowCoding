{
  d = {
    actions = {
      init = {
        custom = "--------------------------------------------------------------\n-- Init\nlocal A = aura_env\nlocal R = WeakAuras.regions[A.id].region\n\nlocal playerGUID                -- Stored UnitGUID(\"player\")\nlocal trinketID = 124518        -- Item ID for Libram of Vindication\nlocal equipped                    -- Whether the trinket is equipped\nlocal lastProc = 0                -- Time of last proc\nlocal icd = 12                    -- ICD between procs\nlocal refract = 6                -- Refractory period for proc detection\n\nR.cooldown:SetReverse(false)\n\n-- COMBAT_LOG_EVENT_UNFILTERED handler\nlocal function onCombatEvent(_, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)\n    -- Don't feel like checking heal/dmg/absorb cases for subEvent,\n    -- so I cheat a little and check spellName directly.\n    if select(2, ...) == \"Savior's Boon\" and sourceGUID == playerGUID then\n        local t = GetTime()\n        if t - lastProc > refract then\n            lastProc = t\n            CooldownFrame_SetTimer(R.cooldown, lastProc, icd, true)\n        end\n    end\nend\n\n-- Checks whether Libram of Vindication is equipped\nlocal function isTrinketEquipped()\n    return (GetInventoryItemID(\"player\", INVSLOT_TRINKET1) == trinketID\n        or GetInventoryItemID(\"player\", INVSLOT_TRINKET2) == trinketID)\nend\n\n-- PLAYER_EQUIPMENT_CHANGED handler\nlocal function onEquipmentChanged()\n    equipped = isTrinketEquipped()\nend\n\n-- Called immediately, but also after PLAYER_ENTERING_WORLD with delay.\n-- This prevents issues with cold login.\nlocal function doDelayedLoad()\n    onEquipmentChanged() -- Check whether equipped\n    playerGUID = UnitGUID(\"player\") -- Initialize playerGUID\nend\ndoDelayedLoad()\n\n-- PLAYER_ENTERING_WORLD handler\nlocal function onEnteringWorld()\n    C_Timer.After(1, doDelayedLoad) -- Set up delayed load\nend\n\n-- What the trigger should return. true => shown, false => hidden.\nlocal function shouldShow()\n    -- Show WA only if equipped\n    return equipped\nend\n\n-- Trigger dispatch handler\n-- We ignore return value of dispatch functions, and instead use shouldShow()\nlocal dispatchTable = {\n    [\"COMBAT_LOG_EVENT_UNFILTERED\"] = onCombatEvent,\n    [\"PLAYER_EQUIPMENT_CHANGED\"] = onEquipmentChanged,\n    [\"PLAYER_ENTERING_WORLD\"] = onEnteringWorld,\n}\nlocal function doTrigger(event, ...)\n    local dispatchFunc = dispatchTable[event]\n    dispatchFunc(...)\n    return shouldShow()\nend\nA.doTrigger = doTrigger\n\n",
        do_custom = true
      }
    },
    auto = false,
    desc = "Arc v0.1 2016-03-26",
    displayIcon = "Interface\\Icons\\INV_Relics_LibramofHope",
    displayStacks = " ",
    height = 45,
    id = "Savior's Boon",
    load = {
      class = {
        single = "PALADIN"
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
        single = 2
      },
      talent = {
        multi = {}
      },
      use_class = true,
      use_spec = true
    },
    numTriggers = 1,
    regionType = "icon",
    trigger = {
      custom = "function(...)\n    return aura_env.doTrigger(...)\nend",
      custom_hide = "custom",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED, PLAYER_EQUIPMENT_CHANGED, PLAYER_ENTERING_WORLD",
      type = "custom"
    },
    untrigger = {
      custom = "function()\n    return true\nend\n\n\n\n\n\n\n\n\n\n"
    },
    width = 45
  },
  m = "d",
  s = "2.1.0.23",
  v = 1421
}