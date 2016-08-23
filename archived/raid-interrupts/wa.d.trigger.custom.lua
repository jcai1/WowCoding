-- Trigger: COMBAT_LOG_EVENT_UNFILTERED
function(_, _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, ...)
    local t = GetTime()
    local A = aura_env
    if A.aborted then
        return
    end
    
    local p, p2 = A.players[sourceGUID], A.players[destGUID]
    
    if p then
        p.seen = true
        p.lastSeen = t
    end
    if p2 then
        p2.seen = true
        p2.lastSeen = t
    end
    
    if not p and subEvent == "SPELL_INTERRUPT" and sourceGUID:sub(1, 3) == "Pet" then
        -- Pretend the master is the source
        sourceGUID = A.petMap[sourceGUID]
        if sourceGUID then
            p = A.players[sourceGUID]
            sourceName = p.name
        end
    end
    
    if not p then
        return
    end
    
    local class = p.class
    
    if subEvent == "SPELL_CAST_SUCCESS" then
        local spellID, spell = ...
        
        if class == "PALADIN" then
            -- If pally casts prot-only spell, we know they can cast Avenger's Shield.
            if A.ProtPallySpells[spell] then
                p:getInt("Avenger's Shield").on = true
            end
        elseif class == "ROGUE" then
            -- If the spell is Kick, and the last Kick happened < 15 seconds ago, it's glyphed.
            if spell == "Kick" then
                local int = p:getInt("Kick")
                local castDelta = t - (int.lastCast or -math.huge)
                if castDelta < 14.8 then
                    int.glyphed = true -- cue more special processing
                end
                if int.glyphed then
                    int.cd = 19 -- reduced to 13 if we see a successful Kick
                end
            end
        elseif class == "PRIEST" then
            if A.HolyPriestSpells[spell] then
                p:getInt("Silence").on = false
            end
            if spell == "Silence" then
                local int = p:getInt("Silence")
                local castDelta = t - (int.lastCast or -math.huge)
                if castDelta < 44.5 then
                    int.cd = 25
                end
            end
        elseif class == "DEATHKNIGHT" then
            if spell == "Strangulate" or spell == "Asphyxiate" then
                local int1, int2 = p:getInt("Strangulate"), p:getInt("Asphyxiate")
                int1.on = (spell == "Strangulate")
                int2.on = (not int1.on)
            end
            if spell == "Mind Freeze" then
                local int = p:getInt("Mind Freeze")
                local castDelta = t - (int.lastCast or -math.huge)
                if castDelta < 14.8 then
                    int.cd = 14
                end
            end
        elseif class == "MAGE" then
            -- If mage is casting/channeling when Counterspell is used, it's glyphed.
            if spell == "Counterspell" then
                local int = p:getInt("Counterspell")
                if int.cd == 24 and UnitExists(p.unit) and (UnitCastingInfo(p.unit) or UnitChannelInfo(p.unit)) then
                    int.cd = 28
                end
            end
        elseif class == "WARLOCK" then
            if spellID == 132409 then
                p.lastPet = "Felhunter"
            end
        elseif class == "DRUID" then
            if A.BalanceDruidSpells[spell] then
                p:getInt("Solar Beam").on = true
            elseif A.MeleeDruidSpells[spell] then
                p:getInt("Skull Bash").on = true
            end
        end
        
        local int = A.lookup(p.ints, spellID, spell, false)
        if int then
            int.lastCast = t
        else
        end
    elseif subEvent == "SPELL_INTERRUPT" then
        local spellID, spell = ...
        local class = p.class
        
        if class == "ROGUE" then
            if spell == "Kick" then
                local int = p:getInt("Kick")
                if int.glyphed then
                    int.cd = 13
                end
            end
        end
        
        local int = A.lookup(p.ints, spellID, spell, false)
        if int then
            int.on = true -- If spell was used to interrupt, it must be on
            int.lastInt = t
        else
            --A.error("Unknown interrupt '"..spell.."' ("..spellID..") occurred")
        end
        
        do
            local extraSpellName = select(5, ...)
            local s1, s2, len, limit = sourceName, extraSpellName, string.len, A.headerLengthLimit
            local iter = 0
            while len(s1) + 1 + len(s2) > limit do
                iter = iter + 1
                if iter == 1 then
                    s1 = s1:sub(1, A.nameLengthLimit)
                elseif iter == 2 then
                    local s = ""
                    for tok in s2:gmatch("%S+") do
                        s = s .. tok:gsub("^%l", string.upper)
                    end
                    s2 = s
                else
                    s2 = s2:sub(1, limit - (len(s1) + 1))
                    break
                end
            end
            local F = WeakAuras.regions[A.id].region
            local header = F.header
            local c = RAID_CLASS_COLORS[class]
            header:SetText(string.format("|c%s%s|r>%s", c.colorStr, s1, s2))
            A.scaleText(header)
        end
    end
end