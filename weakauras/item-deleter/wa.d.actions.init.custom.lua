-- Here is where you put the items you want deleted. You can add either the item ID (e.g. 113821) or the item name (e.g. "Battered Iron Horde Helmet"). Examples are provided, feel free to delete them.
local itemList = {
    42042069,
    "Gay Ass Item",
}
-- Whether a chat message notification should be displayed
-- when this WeakAura deletes an item.
local bNotify = true

-- Don't touch anything below here unless you know what you're doing.

local strformat = string.format

local A = aura_env
local t0 = 0
local bag = 0

local itemIDTest, itemNameTest = {}, {}

for i = 1, #itemList do
    local item = itemList[i]
    if type(item) == "number" then
        itemIDTest[item] = true
    else
        itemNameTest[item] = true
    end
end

-- Does sweep for bag i
-- Returns true if should move to next bag, false if not.
local function sweep(i)
    -- Don't do sweep if player has picked up an item
    -- (since PickupContainerItem() will replace it)
    local cursor = GetCursorInfo()
    if cursor then
        return false
    end
    ClearCursor() -- paranoia
    
    local n = GetContainerNumSlots(i)
    if not n then
        return
    end
    for j = 1, n do
        local id = GetContainerItemID(i, j)
        if id then
            local name = GetItemInfo(id)
            if itemIDTest[id] or itemNameTest[name] then
                PickupContainerItem(i, j)
                DeleteCursorItem()
                ClearCursor()
                if bNotify then
                    print(strformat(
                            "|cffffff00Item deleted:|r %s (itemID %d)",
                            tostring(name), id))
                end
            end
        end
    end
    return true
end

local function customText()
    local t = GetTime()
    local result
    if t - t0 > 1 then
        t0 = t
        result = sweep(bag)
        if result then
            bag = (bag == NUM_BAG_SLOTS) and 0 or (bag + 1)
        end
    end
end
A.customText = customText


