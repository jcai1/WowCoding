{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal icon\n\nlocal ruptures = {first = 1, last = 1}\nlocal rupturesLastCleaned = 0\n\nlocal function addRupture(r)\n    ruptures[ruptures.last] = r\n    ruptures.last = ruptures.last + 1\nend\n\nlocal function cleanRuptures()\n    local now = GetTime()\n    rupturesLastCleaned = now\n    for i = ruptures.first, ruptures.last-1 do\n        if now - ruptures[i].time >= 60 then\n            ruptures.first = i + 1\n            ruptures[i] = nil\n        end\n    end\nend\n\nfunction A.UNIT_SPELLCAST_SUCCEEDED(unitID, spell, rank, lineID, spellID)\n    if unitID == \"player\" and spell == \"Rupture\" then\n        addRupture({time = GetTime(), stealthed = IsStealthed(), target = UnitGUID(\"target\")})\n    end\nend\n\nfunction A.statusTrigger()\n    local now = GetTime()\n    if now - rupturesLastCleaned >= 60 then\n        cleanRuptures()\n    end\n    if not UnitDebuff(\"target\", \"Rupture\", nil, \"PLAYER\") then\n        return false -- rupture is not on the target\n    end\n    local target = UnitGUID(\"target\")\n    for i = ruptures.last-1, ruptures.first, -1 do\n        local r = ruptures[i]\n        if r.target == target then\n            if r.stealthed then\n                icon = \"Interface\\\\Icons\\\\ability_stealth\"\n                return true -- rupture affected by nightstalker\n            else\n                return false -- rupture not affected by nightstalker\n            end\n        end\n    end\n    icon = \"Interface\\\\icons\\\\inv_misc_questionmark\"\n    return true -- unknown whether affected by nightstalker\nend\n\nfunction A.iconFunc()\n    return icon\nend\n",
        do_custom = true
      }
    },
    activeTriggerMode = 1,
    additional_triggers = {
      {
        trigger = {
          check = "update",
          custom = "function() return aura_env.statusTrigger() end",
          customIcon = "function() return aura_env.iconFunc() end",
          custom_type = "status",
          type = "custom"
        },
        untrigger = {
          custom = "function() return true end"
        }
      }
    },
    desc = "Arc v1.0 2017-02-04",
    disjunctive = "any",
    displayStacks = " ",
    displayText = "%p",
    height = 40,
    id = "Nightstalker Rupture",
    justify = "LEFT",
    load = {
      class = {
        single = "ROGUE"
      },
      spec = {
        single = 1
      },
      talent = {
        single = 4
      },
      use_class = true,
      use_spec = true,
      use_talent = true
    },
    numTriggers = 2,
    outline = "OUTLINE",
    regionType = "icon",
    trigger = {
      custom = "function(event, ...) return aura_env[event](...) end",
      custom_hide = "timed",
      custom_type = "event",
      events = "UNIT_SPELLCAST_SUCCEEDED",
      type = "custom"
    },
    width = 40
  },
  m = "d",
  s = "2.3.0.0",
  v = 1421
}
