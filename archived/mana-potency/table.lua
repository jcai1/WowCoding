{
  d = {
    actions = {
      init = {
        custom = "-- Custom text refresh\nlocal lastTextRefresh = 0\nlocal textRefreshInterval = 0.05\n\n-- Custom text string\nlocal text = \"\"\n\n\nlocal function refreshText()\n    lastTextRefresh = GetTime()\n    local mastery = GetMasteryEffect()\n    local manaFrac = UnitPower(\"player\", SPELL_POWER_MANA) / UnitPowerMax(\"player\", SPELL_POWER_MANA)\n    local damage = 100 + mastery * manaFrac\n    local maxDamage = 100 + mastery\n    local potency = damage / maxDamage\n    text = format(\"%.f\", potency * 100) .. \"%%\"\nend\n\nlocal function doText()\n    local t = GetTime()\n    if t - lastTextRefresh > textRefreshInterval then\n        refreshText()\n    end\n    return text\nend\naura_env.doText = doText",
        do_custom = true
      }
    },
    activeTriggerMode = 0,
    customText = "function()\n    return aura_env.doText()\nend",
    desc = "Arc v0.0 2016-03-04",
    displayText = "%c",
    fontSize = 18,
    height = 18.000003814697266,
    id = "Mana Potency",
    init_completed = 1,
    load = {
      class = {
        single = "MAGE"
      },
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
      spec = {
        single = 1
      },
      talent = {
        multi = {}
      },
      use_class = true,
      use_never = false,
      use_spec = true
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
    width = 53,
    xOffset = -544.00006103515602,
    yOffset = 304.00006103515602
  },
  m = "d",
  s = "2.2.1.1",
  v = 1421
}
