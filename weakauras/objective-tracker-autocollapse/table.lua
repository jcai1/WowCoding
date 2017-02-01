{
  d = {
    actions = {
      init = {
        custom = "local A = aura_env\nlocal wasCollapsed = ObjectiveTrackerFrame and ObjectiveTrackerFrame.collapsed\n\nfunction A.ENCOUNTER_START()\n    wasCollapsed = ObjectiveTrackerFrame.collapsed\n    if not wasCollapsed then\n        ObjectiveTracker_Collapse()\n        ObjectiveTracker_Update()\n    end\nend\n\nfunction A.ENCOUNTER_END()\n    if not wasCollapsed then\n        ObjectiveTracker_Expand()\n        ObjectiveTracker_Update()\n    end\nend\n",
        do_custom = true
      }
    },
    desc = "Arc v1.0 2017-02-01",
    displayText = "",
    id = "Objective Tracker Autocollapse",
    numTriggers = 1,
    regionType = "text",
    trigger = {
      custom = "function(event, ...) return aura_env[event](...) end",
      custom_type = "event",
      events = "ENCOUNTER_START,ENCOUNTER_END",
      type = "custom"
    }
  },
  m = "d",
  s = "2.3.0.0",
  v = 1421
}
