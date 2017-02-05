{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal wasCollapsed = ObjectiveTrackerFrame and ObjectiveTrackerFrame.collapsed\n\nfunction A.ENCOUNTER_START()\n    wasCollapsed = ObjectiveTrackerFrame.collapsed\n    if not wasCollapsed then\n        ObjectiveTracker_Collapse()\n        ObjectiveTracker_Update()\n    end\nend\n\nfunction A.ENCOUNTER_END()\n    if not wasCollapsed then\n        ObjectiveTracker_Expand()\n        ObjectiveTracker_Update()\n    end\nend\n",
        do_custom = true
      }
    },
    activeTriggerMode = 0,
    additional_triggers = {},
    desc = "Arc v1.1 2017-02-04",
    displayText = "",
    id = "Objective Tracker Autocollapse",
    load = {
      size = {
        multi = {
          flexible = true,
          fortyman = true,
          ten = true,
          twenty = true,
          twentyfive = true
        }
      },
      use_size = false
    },
    numTriggers = 1,
    regionType = "text",
    trigger = {
      custom = "function(event, ...) return aura_env[event](...) end",
      custom_hide = "timed",
      custom_type = "event",
      events = "ENCOUNTER_START,ENCOUNTER_END",
      type = "custom"
    }
  },
  m = "d",
  s = "2.3.0.0",
  v = 1421
}
