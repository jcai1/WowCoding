{
  d = {
    actions = {
      start = {
        do_sound = true,
        sound = "Interface\\AddOns\\WeakAuras\\Media\\Sounds\\BananaPeelSlip.ogg",
        sound_channel = "Master"
      }
    },
    activeTriggerMode = 0,
    desc = "Arc v0.0 2016-08-10",
    displayText = " ",
    height = 11.999958038330078,
    id = "Volcanic Alert",
    load = {
      difficulty = {
        multi = {},
        single = "challenge"
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
      size = {
        single = "party"
      },
      talent = {
        multi = {}
      },
      use_difficulty = true,
      use_size = true
    },
    numTriggers = 1,
    regionType = "text",
    trigger = {
      custom_hide = "timed",
      custom_type = "event",
      destUnit = "player",
      duration = "1",
      event = "Combat Log",
      spellName = "Volcanic Plume",
      subeventSuffix = "_DAMAGE",
      type = "event",
      unevent = "timed",
      use_destUnit = true,
      use_spellName = true
    },
    width = 6.9999208450317383
  },
  m = "d",
  s = "2.2.1.0",
  v = 1421
}