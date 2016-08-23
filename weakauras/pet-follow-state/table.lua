{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal refreshInterval = 0.05\nlocal lastRefresh = -999\nlocal shouldShow\nlocal now\n\nlocal followTexture = getglobal(\"PET_FOLLOW_TEXTURE\")\nlocal moveToTexture = getglobal(\"PET_MOVE_TO_TEXTURE\")\n\nlocal function refresh()\n    for i = 1, NUM_PET_ACTION_SLOTS do\n        local name, _, texture, _, isActive = GetPetActionInfo(i)\n        if isActive then\n            if name == \"PET_ACTION_FOLLOW\" then\n                A.texture = followTexture\n                A.name = \"Follow\"\n                return true\n            elseif name == \"PET_ACTION_MOVE_TO\" then\n                A.texture = moveToTexture\n                A.name = \"Move To\"\n                return true\n            end\n        end\n    end\n    return false\nend\n\nfunction A.trigger()\n    now = GetTime()\n    if now - lastRefresh > refreshInterval then\n        shouldShow = refresh()\n        lastRefresh = now\n    end\n    return shouldShow\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    desc = "Arc v0.0 2016-07-26",
    disjunctive = "all",
    displayStacks = "%n",
    height = 48,
    id = "Pet Follow State",
    init_completed = 1,
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
      }
    },
    numTriggers = 1,
    regionType = "icon",
    stacksContainment = "OUTSIDE",
    stacksPoint = "TOP",
    trigger = {
      check = "update",
      custom = "function() return aura_env.trigger() end",
      customIcon = "function() return aura_env.texture end",
      customName = "function() return aura_env.name end",
      custom_type = "status",
      event = "Conditions",
      type = "custom",
      unevent = "auto",
      use_unit = true
    },
    untrigger = {
      custom = "function() return true end"
    },
    width = 48,
    xOffset = -518.99996948242199,
    yOffset = 314
  },
  m = "d",
  s = "2.2.0.8",
  v = 1421
}