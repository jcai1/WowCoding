{
  d = {
    actions = {
      init = {
        custom = "local refresh = 0.05\nlocal goodColor = \"00dd00\"\nlocal badColor = \"ff0000\"\n\nlocal A, t = aura_env, GetTime()\nA.t = 0\nA.dt = refresh\nA.display = \"\"\nA.phase = 1\n\nlocal P3Spells = {\"Dark Pursuit\", \"Eternal Flame\", \"Dark Conduit\", \"Mark of the Legion\",\n\"Summon Source of Chaos\", \"Seething Corruption\", \"Twisted Darkness\", \"Nether Ascension\"}\nlocal P12Spells = {\"Allure of Flames\", \"Shackled Torment\", \"Wrought Chaos\", \"Death Brand\",\n\"Desecrate\", \"Desecration\"}\nlocal by, bx = 4067.29, -2285.92\n\nlocal band = bit.band\n\nlocal function updatePhase(spellName)\n    if P3Spells[spellName] then\n        A.phase = 3\n    elseif P12Spells[spellName] then\n        A.phase = 1\n    end\nend\nA.updatePhase = updatePhase\n\nlocal function doCombatTrigger(\n        event, timestamp, subEvent, hideCaster,\n        sourceGUID, sourceName, sourceFlags, sourceRaidFlags,\n        destGUID, destName, destFlags, destRaidFlags, ...\n    )\n    if subEvent == \"SPELL_CAST_SUCCESS\"\n    and band(sourceFlags, COMBATLOG_OBJECT_REACTION_MASK) == COMBATLOG_OBJECT_REACTION_HOSTILE then\n        local spellName = select(2, ...)\n        updatePhase(spellName)\n    end\nend\nA.doCombatTrigger = doCombatTrigger\n\nlocal function updateDisplay()\n    -- if A.phase ~= 3 then\n    -- A.display = \"--\"\n    -- return\n    -- end\n    local ty, tx = UnitPosition(\"boss1target\")\n    if ty then\n        local py, px = UnitPosition(\"player\")\n        if py then\n            local angle = atan2(py - by, px - bx) - atan2(ty - by, tx - bx)\n            angle = (angle + 180) % 360 - 180\n            local good = (angle > 45 or angle < -45)\n            A.display = format(\"|cff%s%3.f|r\", good and goodColor or badColor, angle)\n            return\n        end\n    end\n    A.display = \"--\"\nend\nA.updateDisplay = updateDisplay\n\n",
        do_custom = true
      }
    },
    customText = "function()\n    local A, t = aura_env, GetTime()\n    if t - A.t > A.dt then\n        A.t = t\n        A.updateDisplay()\n    end\n    return A.display\nend",
    desc = "Arc v0.2 yolo",
    displayText = "%c",
    font = "Fira Mono Medium",
    fontSize = 20,
    height = 20.000017166137695,
    id = "Archi Backstab P3",
    init_completed = 1,
    load = {
      class = {
        multi = {
          ROGUE = true
        },
        single = "ROGUE"
      },
      difficulty = {
        multi = {}
      },
      encounterid = "1799",
      faction = {
        multi = {}
      },
      race = {
        multi = {}
      },
      role = {
        multi = {}
      },
      size = {
        multi = {
          twenty = true
        },
        single = "twenty"
      },
      spec = {
        multi = {
          [3] = true
        },
        single = 3
      },
      talent = {
        multi = {}
      },
      use_class = true,
      use_encounterid = true,
      use_size = true,
      use_spec = true
    },
    numTriggers = 1,
    regionType = "text",
    trigger = {
      custom = "function(...)\n    aura_env.doCombatTrigger(...)\n    return true\nend",
      custom_hide = "timed",
      custom_type = "event",
      events = "COMBAT_LOG_EVENT_UNFILTERED",
      type = "custom"
    },
    width = 28.000011444091797,
    xOffset = 0.00018310546875,
    yOffset = 317
  },
  m = "d",
  s = "2.1.0.23",
  v = 1421
}
