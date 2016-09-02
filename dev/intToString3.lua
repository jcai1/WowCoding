-- round an integer to about 3 significant figures with suffix, e.g. 24.5k
local kSuffixes = {"k", "m", "b", "t", "q"}
local function intToString3(x)
    if x < x then
        return "NaN"
    elseif x == math.huge then
        return "+Inf"
    elseif x == -math.huge then
        return "-Inf"
    elseif x < 0 then
        return "-"..intToString3(-x)
    elseif x < 10000 then
        return format("%.f", x)
    else
        local cap, div, count, subcount, final = 99500, 1000, 1, 1, false
        while true do
            if x < cap or (subcount == 2 and not kSuffixes[count + 1]) then
                return format("%."..(2-subcount).."f", x / div)..kSuffixes[count]
            end
            subcount = subcount + 1
            cap = cap * 10
            if subcount == 3 then
                subcount = 0
                count = count + 1
                div = div * 1000
            end
        end
    end
end

-- test
for i = 0, 20 do
    local x = math.pow(10, i)
    print(x, intToString3(x))
    print(5*x, intToString3(5*x))
    print(10*x-1, intToString3(10*x-1))
end