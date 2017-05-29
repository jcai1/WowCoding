{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal customText = \"\"\n\nlocal aliveColor = \"ffff00\"\nlocal killedColor = \"888888\"\nlocal numColumns = 5\nlocal refreshInterval = 1\n\nlocal rares = {\n    {\"Malgrazo\", 46090},\n    {\"Salethan\", 46091},\n    {\"MalorusS\", 46092},\n    {\"Emberfir\", 46093},\n    {\"PotGloop\", 46094},\n    {\"FelmawEm\", 46095},\n    {\"InqChill\", 46096},\n    {\"DoomZart\", 46097},\n    {\"DreadAnn\", 46098},\n    {\"FelXarth\", 46099},\n    {\"XorogunF\", 46100},\n    {\"CorrBone\", 46101},\n    {\"FelZelth\", 46102},\n    {\"Dreadeye\", 46202},\n    {\"LordHelN\", 46304},\n    {\"ImpBruva\", 46313},\n    {\"Flllurlo\", 46951},\n    {\"Aqueux  \", 46953},\n    {\"BroodNix\", 46965},\n    {\"Grossir \", 46995},\n    {\"BroBadat\", 47001},\n    {\"LadyEldr\", 47026},\n    {\"SombDawn\", 47028},\n    {\"DukeSith\", 47036},\n    {\"EyeGurgh\", 47068},\n}\n\nlocal numRows = ceil(#rares / numColumns)\n\nlocal stringPieces = {} -- table<table<string>>\nlocal rowStrings = {} -- table<string>\n\nfor i = 1, numRows do\n    local rowPieces = {}\n    for j = 1, numColumns do\n        local rare = rares[(i-1)*numColumns + j]\n        if not rare then break end\n        local name = rare[1]\n        tinsert(rowPieces, \"|cff\")\n        tinsert(rowPieces, aliveColor)\n        tinsert(rowPieces, name..(j == numColumns and \"\" or \" \"))\n        tinsert(rowPieces, \"|r\")\n    end\n    tinsert(stringPieces, rowPieces)\nend\n\nlocal function buildCustomText()\n    local count = 0\n    for i = 1, numRows do\n        local rowPieces = stringPieces[i]\n        for j = 1, numColumns do\n            local rare = rares[(i-1)*numColumns + j]\n            if not rare then break end\n            local questID = rare[2]\n            local killed = IsQuestFlaggedCompleted(questID)\n            rowPieces[4*(j-1)+2] = killed and killedColor or aliveColor\n            if killed then count = count + 1 end\n        end\n        rowStrings[i+1] = table.concat(rowPieces)\n    end\n    rowStrings[1] = format(\"[|cff%s%d alive|r || |cff%s%d killed|r]\",\n    aliveColor, #rares-count, killedColor, count)\n    return table.concat(rowStrings, \"\\n\")\nend\n\nlocal lastRefresh = 0\nfunction A.customTextFunc()\n    local now = GetTime()\n    if now - lastRefresh > refreshInterval then\n        lastRefresh = now\n        customText = buildCustomText()\n    end\n    return customText\nend",
        do_custom = true
      }
    },
    activeTriggerMode = -10,
    customText = "function() return aura_env.customTextFunc() end",
    desc = "Arc v1.0 2017-05-28",
    disjunctive = "all",
    displayText = "%c",
    font = "Fira Mono Medium",
    fontSize = 14,
    id = "Broken Shore Rares",
    load = {
      size = {
        single = "none"
      },
      use_size = true,
      use_zone = true,
      zone = "Broken Shore"
    },
    numTriggers = 1,
    regionType = "text",
    selfPoint = "TOP",
    trigger = {
      event = "Conditions",
      type = "status",
      unevent = "auto",
      use_alwaystrue = true
    }
  },
  m = "d",
  s = "2.4.2",
  v = 1421
}
