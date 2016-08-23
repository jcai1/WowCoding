local function init()
    local A, t = aura_env, GetTime()
    
    local disp = WeakAurasSaved.displays[A.id]
    if disp and disp.actions and disp.actions.finish then
        local f = disp.actions.finish
        if f.do_sound and f.sound then
            function A.playSound()
                PlaySoundFile(f.sound, f.sound_channel or MASTER)
            end
        end
    end
    if not A.playSound then
        function A.playSound() end
    end
    
    A.t1 = -math.huge -- Time when sound last played
    
    A.rings = {[124634] = "Thorasus", [124635] = "Nithramus", [124636] = "Maalus", [124637] = "Sanctus", [124638] = "Etheralus"}
    
    local function getRingInfo()
        local id1, id2, name1, name2, rings
        rings = A.rings
        id1 = GetInventoryItemID("player", INVSLOT_FINGER1)
        name1 = rings[id1]
        if name1 then return id1, name1 end
        id2 = GetInventoryItemID("player", INVSLOT_FINGER2)
        name2 = rings[id2]
        if name2 then return id2, name2 end
    end
    
    function A.updateRing()
        A.currRing, A.currRingName = getRingInfo()
    end
    
    A.updateRing()
    A.t2 = t -- Time when ring info last updated
end
init()
