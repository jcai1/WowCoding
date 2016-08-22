{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\n-- local R = WeakAuras.regions[A.id].region\nlocal S = WeakAurasSaved.displays[A.id]\n\nlocal xdInterval = 1800            -- Interval between xd's, in seconds\nlocal zavinnBTag = \"Zavinn#1156\"\nlocal zavinnID                    -- Zavinn's presenceID\nS.lastXd = S.lastXd or 0        -- Time of last xd\n\n-- Returns Zavinn's presenceID, or nil if he's not your BTag friend.\nlocal function getZavinn()\n    for i = 1, BNGetNumFriends() do\n        local presenceID, _, battleTag = BNGetFriendInfo(i)\n        if battleTag == zavinnBTag then\n            return presenceID\n        end\n    end\nend\n\n-- xd\nlocal function xd()\n    if not zavinnID then\n        return\n    end\n    local isOnline = select(8, BNGetFriendInfoByID(zavinnID))\n    if isOnline then\n        BNSendWhisper(zavinnID, \"xd\")\n    end\nend\n\nlocal loaded = false\nlocal LOAD_SUCCESS, LOAD_UNSURE, LOAD_FAILED = 0, 1, 2\nlocal lastLoadResult\nlocal loadUnsureStreak = 0\nlocal loadFailedCount = 0\n\n-- Performs load operations that may fail.\nlocal function tryLoad()\n    zavinnID = getZavinn()\n    if zavinnID then\n        return LOAD_SUCCESS\n    else\n        return LOAD_UNSURE\n    end\nend\n\n-- Calls tryLoad and controls retry attempts.\nlocal function doLoadAttempt()\n    if loaded then return end\n    \n    local result = tryLoad()\n    \n    if result == LOAD_SUCCESS then\n        loaded = true\n    elseif result == LOAD_UNSURE then\n        if lastLoadResult == LOAD_UNSURE then\n            loadUnsureStreak = loadUnsureStreak + 1\n        else\n            loadUnsureStreak = 1\n        end\n        if loadUnsureStreak >= 2 then\n            -- Assume we succeeded.\n            loaded = true\n        end\n    elseif result == LOAD_FAILED then\n        loadFailedCount = loadFailedCount + 1\n    end\n    \n    lastLoadResult = result\n    \n    if not loaded then\n        if loadFailedCount >= 4 then\n            -- Give up.\n            print(\"WA [\" .. A.id .. \"] failed to load.\")\n        else\n            C_Timer.After(1, doLoadAttempt)\n        end\n    end\nend\n\n-- Custom text function\nlocal function doText()\n    if not loaded then return end\n    local rt = time() -- Real time (since epoch)\n    if rt - S.lastXd > xdInterval then\n        xd()\n        S.lastXd = rt\n    end\nend\nA.doText = doText\n\ndoLoadAttempt()",
        do_custom = true
      }
    },
    customText = "function()\n    return aura_env.doText()\nend",
    desc = "Arc v0.1 2016-04-09",
    displayText = "%c",
    height = 1.0000075101852417,
    id = "Zavinn xd",
    init_completed = 1,
    lastXd = 1460193473,
    load = {
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
      talent = {
        multi = {}
      }
    },
    numTriggers = 1,
    regionType = "text",
    trigger = {
      event = "Conditions",
      type = "status",
      unevent = "auto",
      use_alwaystrue = true,
      use_unit = true
    },
    width = 1.0000075101852417
  },
  m = "d",
  s = "2.1.0.25",
  v = 1421
}