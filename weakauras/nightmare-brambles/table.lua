{
  d = {
    actions = {
      init = {
        custom = "----- EN/06CEN/Nightmare Brambles -----\nlocal A = aura_env\n\nlocal castSound = \"Interface\\\\AddOns\\\\WeakAuras\\\\Media\\\\Sounds\\\\RobotBlip.ogg\"\nlocal refixateSound = \"Interface\\\\AddOns\\\\WeakAuras\\\\PowerAurasMedia\\\\Sounds\\\\kaching.ogg\"\n\nlocal classColors = getglobal(\"RAID_CLASS_COLORS\")\nlocal text\nlocal startTime = 0\nlocal castAlerted, refixateAlerted\n\nfunction A.UNIT_SPELLCAST_SUCCEEDED(_, _, _, _, spellID)\n    if spellID == 210290 then\n        local u = \"boss1target\"\n        local name = tostring(UnitName(u))\n        local _, class = UnitClass(u)\n        text = class and format(\"|c%s%s|r\", classColors[class].colorStr, name) or name\n        startTime = GetTime()\n        castAlerted = false\n        refixateAlerted = false\n    end\nend\n\nlocal function playSound(s)\n    if type(s) == \"number\" then PlaySoundKitID(s) else PlaySoundFile(s) end\nend\n\nfunction A.frameTrigger()\n    local t = GetTime() - startTime\n    if t < 1.75 then\n        if not castAlerted then\n            playSound(castSound)\n            castAlerted = true\n        end\n        return true\n    elseif (t > 20 and t < 21.75) then\n        if not refixateAlerted then\n            playSound(refixateSound)\n            refixateAlerted = true\n        end\n        text = \"Refixate\"\n        return true\n    end\nend\n\nfunction A.text()\n    return text\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    additional_triggers = {
      {
        trigger = {
          check = "update",
          custom = "function() return aura_env.frameTrigger() end",
          custom_type = "status",
          event = "Health",
          subeventPrefix = "SPELL",
          subeventSuffix = "_CAST_START",
          type = "custom",
          unevent = "auto",
          unit = "player",
          use_unit = true
        },
        untrigger = {
          custom = "function() return true end"
        }
      }
    },
    animation = {
      finish = {
        preset = "grow",
        type = "preset"
      },
      start = {
        preset = "grow",
        type = "preset"
      }
    },
    customText = "function() return aura_env.text() end",
    desc = "Arc v1.0-beta 2016-10-06",
    disjunctive = "any",
    displayIcon = "1357815",
    displayStacks = "%c",
    font = "FrancoisOne",
    fontFlags = "THICKOUTLINE",
    fontSize = 16,
    height = 50,
    id = "EN/06CEN/Nightmare Brambles",
    init_completed = 1,
    load = {
      difficulty = {
        multi = {}
      },
      encounterid = "1877",
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
      size = {
        single = "twenty"
      },
      talent = {
        multi = {}
      },
      use_encounterid = true,
      use_size = true
    },
    numTriggers = 2,
    regionType = "icon",
    stacksContainment = "OUTSIDE",
    stacksPoint = "TOP",
    trigger = {
      custom = "function(event, ...) return aura_env.UNIT_SPELLCAST_SUCCEEDED(...) end",
      custom_hide = "custom",
      custom_type = "event",
      events = "UNIT_SPELLCAST_SUCCEEDED",
      type = "custom"
    },
    untrigger = {
      custom = "function() return true end"
    },
    width = 50
  },
  m = "d",
  s = "2.2.1.5",
  v = 1421
}
