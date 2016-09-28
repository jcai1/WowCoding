{
  a = {},
  c = {
    {
      actions = {
        init = {
          do_custom = false
        }
      },
      activeTriggerMode = -10,
      additional_triggers = {
        {
          trigger = {
            custom_hide = "timed",
            duration = "7",
            event = "Combat Log",
            spellName = "Mark of Ysondre",
            subeventPrefix = "SPELL",
            subeventSuffix = "_AURA_APPLIED_DOSE",
            type = "event",
            unevent = "timed",
            use_spellId = false,
            use_spellName = true
          },
          untrigger = {}
        }
      },
      backgroundColor = {
        [4] = 0.74096351861953735
      },
      barColor = {
        0.12156862745098039,
        0.60784313725490191,
        0.098039215686274508
      },
      customText = "function()\n    local bossUnit\n    for i = 1, 5 do\n        if UnitName(\"boss\"..i) == \"Ysondre\" then\n            bossUnit = \"boss\"..i\n        end\n    end\n    if not bossUnit then\n        return \"[??]\"\n    end\n    if not UnitCanAttack(\"player\", bossUnit) then\n        return \"[--]\"\n    end\n    if IsItemInRange(23836, bossUnit) then\n        return \"|cffff2020[In]|r\"\n    else\n        return \"|cff40ff40[Out]|r\"\n    end\nend",
      disjunctive = "any",
      displayTextRight = "%c %p",
      fontFlags = "OUTLINE",
      icon_side = "LEFT",
      id = "Mark of Ysondre",
      init_completed = 1,
      load = {
        difficulty = {
          multi = {}
        },
        encounterid = "1854",
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
      regionType = "aurabar",
      spark = true,
      stacks = false,
      textFont = "FrancoisOne",
      timerFont = "FrancoisOne",
      trigger = {
        duration = "7",
        event = "Combat Log",
        spellName = "Mark of Ysondre",
        subeventSuffix = "_AURA_APPLIED",
        type = "event",
        unevent = "timed",
        use_spellName = true
      },
      width = 180,
      xOffset = 30.9999389648438,
      yOffset = 224
    },
    {
      activeTriggerMode = -10,
      additional_triggers = {
        {
          trigger = {
            custom_hide = "timed",
            duration = "7",
            event = "Combat Log",
            spellName = "Mark of Emeriss",
            subeventPrefix = "SPELL",
            subeventSuffix = "_AURA_APPLIED_DOSE",
            type = "event",
            unevent = "timed",
            use_spellId = false,
            use_spellName = true
          },
          untrigger = {}
        }
      },
      backgroundColor = {
        [4] = 0.74096351861953735
      },
      barColor = {
        0.15686274509803899,
        0.168627450980392,
        0.79607843137254897
      },
      customText = "function()\n    local bossUnit\n    for i = 1, 5 do\n        if UnitName(\"boss\"..i) == \"Emeriss\" then\n            bossUnit = \"boss\"..i\n        end\n    end\n    if not bossUnit then\n        return \"[??]\"\n    end\n    if not UnitCanAttack(\"player\", bossUnit) then\n        return \"[--]\"\n    end\n    if IsItemInRange(23836, bossUnit) then\n        return \"|cffff2020[In]|r\"\n    else\n        return \"|cff40ff40[Out]|r\"\n    end\nend",
      disjunctive = "any",
      displayTextRight = "%c %p",
      fontFlags = "OUTLINE",
      icon_side = "LEFT",
      id = "Mark of Emeriss",
      init_completed = 1,
      load = {
        difficulty = {
          multi = {}
        },
        encounterid = "1854",
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
      regionType = "aurabar",
      spark = true,
      stacks = false,
      textFont = "FrancoisOne",
      timerFont = "FrancoisOne",
      trigger = {
        duration = "7",
        event = "Combat Log",
        spellName = "Mark of Emeriss",
        subeventSuffix = "_AURA_APPLIED",
        type = "event",
        unevent = "timed",
        use_spellName = true
      },
      width = 180,
      xOffset = 30.9999389648438,
      yOffset = 224
    },
    {
      activeTriggerMode = -10,
      additional_triggers = {
        {
          trigger = {
            duration = "7",
            event = "Combat Log",
            spellName = "Mark of Lethon",
            subeventPrefix = "SPELL",
            subeventSuffix = "_AURA_APPLIED_DOSE",
            type = "event",
            unevent = "timed",
            use_spellId = false,
            use_spellName = true
          },
          untrigger = {}
        }
      },
      backgroundColor = {
        [4] = 0.74096351861953735
      },
      barColor = {
        0.63921568627450998,
        0.50196078431372604,
        0.17647058823529399
      },
      customText = "function()\n    local bossUnit\n    for i = 1, 5 do\n        if UnitName(\"boss\"..i) == \"Lethon\" then\n            bossUnit = \"boss\"..i\n        end\n    end\n    if not bossUnit then\n        return \"[??]\"\n    end\n    if not UnitCanAttack(\"player\", bossUnit) then\n        return \"[--]\"\n    end\n    if IsItemInRange(23836, bossUnit) then\n        return \"|cffff2020[In]|r\"\n    else\n        return \"|cff40ff40[Out]|r\"\n    end\nend",
      disjunctive = "any",
      displayTextRight = "%c %p",
      fontFlags = "OUTLINE",
      icon_side = "LEFT",
      id = "Mark of Lethon",
      init_completed = 1,
      load = {
        difficulty = {
          multi = {}
        },
        encounterid = "1854",
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
      regionType = "aurabar",
      spark = true,
      stacks = false,
      textFont = "FrancoisOne",
      timerFont = "FrancoisOne",
      trigger = {
        custom_hide = "timed",
        duration = "7",
        event = "Combat Log",
        spellName = "Mark of Lethon",
        subeventSuffix = "_AURA_APPLIED",
        type = "event",
        unevent = "timed",
        use_spellName = true
      },
      width = 180,
      xOffset = 30.9999389648438,
      yOffset = 224
    },
    {
      activeTriggerMode = -10,
      additional_triggers = {
        {
          trigger = {
            duration = "7",
            event = "Combat Log",
            spellName = "Mark of Taerar",
            subeventPrefix = "SPELL",
            subeventSuffix = "_AURA_APPLIED_DOSE",
            type = "event",
            unevent = "timed",
            use_spellId = false,
            use_spellName = true
          },
          untrigger = {}
        }
      },
      backgroundColor = {
        [4] = 0.74096351861953735
      },
      barColor = {
        0.3529411764705882,
        0.36862745098039218,
        0.35686274509803922
      },
      customText = "function()\n    local bossUnit\n    for i = 1, 5 do\n        if UnitName(\"boss\"..i) == \"Taerar\" then\n            bossUnit = \"boss\"..i\n        end\n    end\n    if not bossUnit then\n        return \"[??]\"\n    end\n    if not UnitCanAttack(\"player\", bossUnit) then\n        return \"[--]\"\n    end\n    if IsItemInRange(23836, bossUnit) then\n        return \"|cffff2020[In]|r\"\n    else\n        return \"|cff40ff40[Out]|r\"\n    end\nend",
      disjunctive = "any",
      displayTextRight = "%c %p",
      fontFlags = "OUTLINE",
      icon_side = "LEFT",
      id = "Mark of Taerar",
      init_completed = 1,
      load = {
        difficulty = {
          multi = {}
        },
        encounterid = "1854",
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
      regionType = "aurabar",
      spark = true,
      stacks = false,
      textFont = "FrancoisOne",
      timerFont = "FrancoisOne",
      trigger = {
        custom_hide = "timed",
        duration = "7",
        event = "Combat Log",
        spellName = "Mark of Taerar",
        subeventSuffix = "_AURA_APPLIED",
        type = "event",
        unevent = "timed",
        use_spellName = true
      },
      width = 180,
      xOffset = 30.9999389648438,
      yOffset = 224
    }
  },
  d = {
    activeTriggerMode = -10,
    desc = "Arc v1.0-beta 2016-09-28",
    disjunctive = "all",
    expanded = true,
    height = 63.00006103515625,
    id = "EN/05DRA/Mark of the Nightmare",
    load = {
      difficulty = {
        multi = {}
      },
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
      talent = {
        multi = {}
      },
      use_class = false
    },
    numTriggers = 1,
    regionType = "dynamicgroup",
    selfPoint = "TOP",
    space = 1,
    width = 179.99981689453125,
    yOffset = 310
  },
  m = "d",
  s = "2.2.1.5",
  v = 1421
}
