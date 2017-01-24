{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal R = WeakAuras.regions[A.id].region\n\nR.customText = \"\"\n\nlocal function colorLatency(x)\n    if not x then\n        return \"??\"\n    elseif x < 100 then\n        return format(\"|cff00ff00%d|r\", x) -- less than 100 ms = green\n    elseif x < 300 then\n        return format(\"|cffffff00%d|r\", x) -- 100-300 ms = yellow\n    else\n        return format(\"|cffff0000%d|r\", x) -- more than 300 ms = red\n    end\nend\n\nlocal function refresh()\n    local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()\n    R.customText = colorLatency(latencyHome)..\" / \"..colorLatency(latencyWorld)\nend\n\nfunction A.customTextFunc()\n    return R.customText\nend\n\nR.ticker = R.ticker or C_Timer.NewTicker(30, refresh)",
        do_custom = true
      }
    },
    customText = "function() return aura_env.customTextFunc() end",
    desc = "Arc v1.0 2017-01-24",
    disjunctive = "all",
    displayText = "%c",
    font = "FrancoisOne",
    fontSize = 9,
    id = "Latency",
    numTriggers = 1,
    regionType = "text",
    selfPoint = "TOPRIGHT",
    trigger = {
      event = "Conditions",
      type = "status",
      unevent = "auto",
      use_alwaystrue = true
    }
  },
  m = "d",
  s = "2.2.2.6",
  v = 1421
}
