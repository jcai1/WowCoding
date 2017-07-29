{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\n\nlocal nightbladeID = 195452\nlocal nightbladeName = GetSpellInfo(nightbladeID)\nlocal finalityNightbladeName = GetSpellInfo(197498)\n\nlocal nightblades = {first = 1, last = 1}\nlocal nightbladesLastCleaned = 0\n\nlocal function addNightblade(r)\n    nightblades[nightblades.last] = r\n    nightblades.last = nightblades.last + 1\nend\n\nlocal function cleanNightblades()\n    local now = GetTime()\n    nightbladesLastCleaned = now\n    for i = nightblades.first, nightblades.last - 1 do\n        if now - nightblades[i].time >= 60 then\n            nightblades.first = i + 1\n            nightblades[i] = nil\n        end\n    end\nend\n\nfunction A.UNIT_SPELLCAST_SUCCEEDED(unitID, spell, rank, lineID, spellID)\n    if unitID == \"player\" and spellID == nightbladeID then\n        addNightblade({time = GetTime(),\n                finality = UnitBuff(\"player\", finalityNightbladeName, nil, \"PLAYER\"),\n                target = UnitGUID(\"target\")})\n    end\nend\n\nfunction A.statusTrigger()\n    local now = GetTime()\n    if now - nightbladesLastCleaned >= 60 then\n        cleanNightblades()\n    end\n    local _\n    _, _, A.icon, A.stacks, _, A.duration, A.expirationTime = UnitDebuff(\n    \"target\", nightbladeName, nil, \"PLAYER\")\n    if not A.duration then\n        return false -- nightblade is not on the target\n    end\n    local target = UnitGUID(\"target\")\n    for i = nightblades.last - 1, nightblades.first, -1 do\n        if nightblades[i].target == target then\n            A.glow = nightblades[i].finality -- glow if affected by finality\n            break\n        end\n    end\n    return true -- nightblade is on the target\nend",
        do_custom = true
      }
    },
    activeTriggerMode = 0,
    additional_triggers = {
      {
        trigger = {
          custom = "function(event, ...) local f = aura_env[event] return f and f(...) end",
          custom_hide = "timed",
          custom_type = "event",
          events = "UNIT_SPELLCAST_SUCCEEDED",
          type = "custom"
        },
        untrigger = {}
      },
      {
        trigger = {
          check = "update",
          custom = "function() return aura_env.glow end",
          custom_type = "status",
          type = "custom"
        },
        untrigger = {
          custom = "function() return true end"
        }
      }
    },
    conditions = {
      {
        changes = {
          {
            property = "glow",
            value = true
          }
        },
        check = {
          trigger = 2,
          value = 1,
          variable = "show"
        }
      }
    },
    cooldown = true,
    customTriggerLogic = "function(triggers) return triggers[1] end",
    desc = "Arc v1.0 2017-07-29",
    disjunctive = "custom",
    displayText = "%p",
    height = 40,
    id = "Finality: Nightblade",
    justify = "LEFT",
    load = {
      class = {
        single = "ROGUE"
      },
      spec = {
        single = 3
      },
      use_class = true,
      use_spec = true
    },
    numTriggers = 3,
    outline = "OUTLINE",
    regionType = "icon",
    text1 = " ",
    text1Enabled = false,
    trigger = {
      check = "update",
      custom = "function() local f = aura_env.statusTrigger return f and f() end",
      customDuration = "function() return aura_env.duration, aura_env.expirationTime end",
      customIcon = "function() return aura_env.icon end",
      customStacks = "function() return aura_env.stacks end",
      custom_type = "status",
      type = "custom"
    },
    untrigger = {
      custom = "function() return true end"
    },
    width = 40
  },
  m = "d",
  s = "2.4.16",
  v = 1421
}
