{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal icon\n\nlocal garrotes = {first = 1, last = 1}\nlocal garrotesLastCleaned = 0\n\nlocal function addGarrote(r)\n    garrotes[garrotes.last] = r\n    garrotes.last = garrotes.last + 1\nend\n\nlocal function cleanGarrotes()\n    local now = GetTime()\n    garrotesLastCleaned = now\n    for i = garrotes.first, garrotes.last-1 do\n        if now - garrotes[i].time >= 60 then\n            garrotes.first = i + 1\n            garrotes[i] = nil\n        end\n    end\nend\n\nfunction A.UNIT_SPELLCAST_SUCCEEDED(unitID, spell, rank, lineID, spellID)\n    if unitID == \"player\" and spell == \"Garrote\" then\n        addGarrote({time = GetTime(), stealthed = IsStealthed() or UnitBuff(\"player\", \"Subterfuge\", nil, \"PLAYER\"), target = UnitGUID(\"target\")})\n    end\nend\n\nfunction A.statusTrigger()\n    local now = GetTime()\n    if now - garrotesLastCleaned >= 60 then\n        cleanGarrotes()\n    end\n    if not UnitDebuff(\"target\", \"Garrote\", nil, \"PLAYER\") then\n        return false -- garrote is not on the target\n    end\n    local target = UnitGUID(\"target\")\n    for i = garrotes.last-1, garrotes.first, -1 do\n        local r = garrotes[i]\n        if r.target == target then\n            if r.stealthed then\n                icon = \"Interface\\\\Icons\\\\rogue_subterfuge\"\n                return true -- garrote affected by subterfuge\n            else\n                return false -- garrote not affected by subterfuge\n            end\n        end\n    end\n    icon = \"Interface\\\\icons\\\\inv_misc_questionmark\"\n    return true -- unknown whether affected by subterfuge\nend\n\nfunction A.iconFunc()\n    return icon\nend",
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
    desc = "Arc v1.0 2017-02-11",
    disjunctive = "any",
    displayStacks = " ",
    displayText = "%p",
    height = 40,
    id = "Subterfuge Garrote",
    justify = "LEFT",
    load = {
      class = {
        single = "ROGUE"
      },
      spec = {
        single = 1
      },
      talent = {
        single = 5
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
