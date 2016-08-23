-- Custom text
function()
    local t = GetTime()
    local A = aura_env
    local F = WeakAuras.regions[A.id].region
    
    if A.aborted then
        return
    end
    
    for k = 1, #(A.periodic) do
        local val = A.periodic[k]
        val.lastCalled = val.lastCalled or -math.huge
        if t - val.lastCalled > val.interval then
            val.callback()
            val.lastCalled = t
        end
    end
end
