function()
    local bossUnit
    for i = 1, 5 do
        if UnitName("boss"..i) == "Emeriss" then
            bossUnit = "boss"..i
        end
    end
    if not bossUnit then
        return "[??]"
    end
    if not UnitCanAttack("player", bossUnit) then
        return "[--]"
    end
    if IsItemInRange(23836, bossUnit) then
        return "|cffff2020[In]|r"
    else
        return "|cff40ff40[Out]|r"
    end
end
