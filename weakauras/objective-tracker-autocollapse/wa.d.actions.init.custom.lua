local A = aura_env
local wasCollapsed = ObjectiveTrackerFrame and ObjectiveTrackerFrame.collapsed

function A.ENCOUNTER_START()
    wasCollapsed = ObjectiveTrackerFrame.collapsed
    if not wasCollapsed then
        ObjectiveTracker_Collapse()
        ObjectiveTracker_Update()
    end
end

function A.ENCOUNTER_END()
    if not wasCollapsed then
        ObjectiveTracker_Expand()
        ObjectiveTracker_Update()
    end
end
