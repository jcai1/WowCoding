{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal refreshInterval = 0.05\nlocal lastRefresh = -999\nlocal shouldShow\nlocal now\n\nlocal function refresh()\n    if not UnitCanAttack(\"player\", \"target\") then return end\n    for i = 1, 50 do\n        local name, _, texture, count, debuffType, duration, expirationTime = UnitBuff(\"target\", i)\n        if not name then break end\n        if debuffType == \"Magic\" then\n            A.name, A.texture, A.count, A.duration, A.expirationTime = name, texture, count, duration, expirationTime\n            return true\n        end\n    end\nend\n\nfunction A.trigger()\n    now = GetTime()\n    if now - lastRefresh > refreshInterval then\n        shouldShow = refresh()\n        lastRefresh = now\n    end\n    return shouldShow\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    cooldown = true,
    desc = "Arc v0.0 2016-07-26",
    disjunctive = "all",
    height = 48,
    id = "Magic Buff",
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
    trigger = {
      check = "update",
      custom = "function() return aura_env.trigger() end\n\n\n\n\n\n\n\n",
      customDuration = "function() return aura_env.duration, aura_env.expirationTime end",
      customIcon = "function() return aura_env.texture end\n\n\n\n\n\n\n\n\n\n",
      customName = "function() return aura_env.name end\n\n\n\n\n\n",
      customStacks = "function() return aura_env.count end\n    \n    \n    \n    \n    \n    \n    \n    \n\n",
      customTexture = "\n\n",
      custom_hide = "timed",
      custom_type = "status",
      type = "custom"
    },
    untrigger = {
      custom = "function() return true end"
    },
    width = 48,
    xOffset = -0.0001220703125,
    yOffset = 100.00006103515599
  },
  m = "d",
  s = "2.2.0.8",
  v = 1421
}
