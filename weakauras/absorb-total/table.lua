{
  a = {},
  c = {
    {
      actions = {
        init = {
          custom = "----- Absorb Total -----\nlocal A = aura_env\n-- local R = WeakAuras.regions[A.id].region\n-- local S = WeakAurasSaved.displays[A.id]\n\n----- Set options here -----\nlocal refreshRate = 20\n\n----- Utility -----\nlocal now\nlocal refreshInterval = 1 / refreshRate\nlocal lastRefresh     = -refreshInterval - 1\nlocal customText\nlocal shouldShow      = true\nlocal isOptionsOpen   = WeakAuras.IsOptionsOpen\n-- local playerGUID      = UnitGUID(\"player\")\n\n-- round an integer to about 3 significant figures with suffix, e.g. 24.5k\nlocal kSuffixes = {\"k\", \"m\", \"b\", \"t\", \"q\"}\nlocal function intToString3(x)\n    if x < x then\n        return \"NaN\"\n    elseif x == math.huge then\n        return \"+Inf\"\n    elseif x == -math.huge then\n        return \"-Inf\"\n    elseif x < 0 then\n        return \"-\"..intToString3(-x)\n    elseif x < 10000 then\n        return format(\"%.f\", x)\n    else\n        local cap, div, count, subcount, final = 99500, 1000, 1, 1, false\n        while true do\n            if x < cap or (subcount == 2 and not kSuffixes[count + 1]) then\n                return format(\"%.\"..(2-subcount)..\"f\", x / div)..kSuffixes[count]\n            end\n            subcount = subcount + 1\n            cap = cap * 10\n            if subcount == 3 then\n                subcount = 0\n                count = count + 1\n                div = div * 1000\n            end\n        end\n    end\nend\n\nlocal function onRefresh()\n    local amt = UnitGetTotalAbsorbs(\"player\")\n    if amt == 0 then\n        if isOptionsOpen() then\n            customText = \"999k\"\n        else\n            customText = \"\"\n        end\n    else\n        customText = intToString3(amt)\n    end\nend\n\nlocal function doCustomText()\n    now = GetTime()\n    if now - lastRefresh >= refreshInterval then\n        onRefresh()\n        lastRefresh = now\n    end\n    return customText\nend\nA.doCustomText = doCustomText",
          do_custom = true
        }
      },
      color = {
        [2] = 0.96862745098039205,
        [3] = 0.29411764705882398
      },
      customText = "function() return aura_env.doCustomText() end",
      displayText = "%c",
      font = "Arial Narrow",
      fontSize = 16,
      height = 15.999987602233887,
      id = "Absorb Total",
      init_completed = 1,
      numTriggers = 1,
      regionType = "text",
      selfPoint = "RIGHT",
      trigger = {
        event = "Conditions",
        type = "status",
        use_alwaystrue = true
      },
      width = 36.000007629394531,
      yOffset = 0.5
    },
    {
      color = {
        0,
        0,
        0
      },
      frameStrata = 2,
      height = 18,
      id = "Absorb Total BG",
      numTriggers = 1,
      regionType = "texture",
      rotate = false,
      selfPoint = "RIGHT",
      texture = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White",
      trigger = {
        event = "Conditions",
        type = "status",
        use_alwaystrue = true
      },
      width = 42
    }
  },
  d = {
    disjunctive = "all",
    expanded = true,
    id = "Absorb Total Grp",
    numTriggers = 1,
    regionType = "group",
    selfPoint = "BOTTOMLEFT",
    xOffset = -661,
    yOffset = 472
  },
  m = "d",
  s = "2.2.1.4",
  v = 1421
}
