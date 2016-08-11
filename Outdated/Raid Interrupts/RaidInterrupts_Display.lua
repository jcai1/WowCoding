-- Custom text
function()
    local A, t = aura_env, GetTime()
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
    
    -- Display logic run every frame
    local bg, header, tiles, names, icons, cds, cdFrames, borders
    = F.bg, F.header, F.tiles, F.names, F.icons, F.cds, F.cdFrames, F.borders
    local scaleText = A.scaleText
    do
        local header = header
        header:SetText(A.headerMsg)
        local delta = t - A.headerMsgTime
        local alpha = (delta < 10) and (1 - delta / 10) ^ 2 or 0
        header:SetTextColor(1, 1, 1, alpha)
        scaleText(header)
    end
    local rightmostPoint = 0
    local unitList = A.getUnitList()
    local usedTiles = {}
    for j = 1, #unitList do
        local u = unitList[j]
        local p = UnitExists(u) and A.players[UnitGUID(u)]
        local i = j -- i = display index; j = index in unitList
        local show
        if p then
            local inCombat = UnitAffectingCombat("player")
            if inCombat then
                show = p.seen and not p.dead
            else
                show = UnitIsVisible(p.unit)
            end
        end
        
        local tile, name, icon, cd, cdFrame, border
        = tiles[i], names[i], icons[i], cds[i], cdFrames[i], borders[i]
        
        if show then
            usedTiles[i] = true
            rightmostPoint = math.max(rightmostPoint, tile:GetRight())
            
            do
                local c = RAID_CLASS_COLORS[p.class]
                name:SetText(string.sub(p.name, 1, A.nameLengthLimit))
                name:SetTextColor(c.r, c.g, c.b)
                scaleText(name)
                name:Show()
            end
            
            local count, charges, minRecharge, iconName = 0, 0, math.huge, nil
            local intWithMinRecharge
            
            for k = 1, #(p.ints) do
                local int = p.ints[k]
                if int.on then
                    count = count + 1
                    local elapsed = t - (int.lastCast or -math.huge)
                    local remain = math.max(0, int.cd - elapsed)
                    if remain == 0 then
                        if charges == 0 then
                            iconName = int.icon
                        end
                        charges = charges + 1
                    elseif remain < minRecharge then
                        minRecharge = remain
                        intWithMinRecharge = int
                        iconName = int.icon
                    end
                end
            end
            if count > 0 then
                icon:SetTexture("Interface\\Icons\\" .. iconName)
                icon:Show()
                if minRecharge < math.huge then
                    cd:SetText(A.formatTime(minRecharge))
                    cdFrame:SetCooldown(intWithMinRecharge.lastCast, intWithMinRecharge.cd)
                    if charges > 0 then
                        cd:SetTextColor(0, 1, 1, 1)
                    else
                        if minRecharge < 5.5 then
                            cd:SetTextColor(1, 0, 0, 1)
                        elseif minRecharge < 59.5 then
                            cd:SetTextColor(1, 1, 0, 1)
                        else
                            cd:SetTextColor(1, 1, 1, 1)
                        end
                    end
                    cd:Show()
                    cdFrame:Show()
                else
                    cd:Hide()
                    cdFrame:Hide()
                end
                if charges >= 1 then
                    border:SetVertexColor(1, 1, 1)
                else
                    border:SetVertexColor(0, 0, 0)
                end
                border:Show()
            else
                icon:Hide()
                cd:Hide()
                cdFrame:Hide()
                border:Hide()
            end
        end
    end
    for i = 1, 40 do
        if not usedTiles[i] then
            names[i]:Hide()
            icons[i]:Hide()
            cds[i]:Hide()
            cdFrames[i]:Hide()
            borders[i]:Hide()
        end
    end
    bg:SetWidth(math.max(F:GetWidth(), rightmostPoint - bg:GetLeft()))
end
