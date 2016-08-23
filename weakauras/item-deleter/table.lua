{
  d = {
    actions = {
      init = {
        custom = "-- Here is where you put the items you want deleted. You can add either the item ID (e.g. 113821) or the item name (e.g. \"Battered Iron Horde Helmet\"). Examples are provided, feel free to delete them.\nlocal itemList = {\n    42042069,\n    \"Gay Ass Item\",\n}\n-- Whether a chat message notification should be displayed\n-- when this WeakAura deletes an item.\nlocal bNotify = true\n\n-- Don't touch anything below here unless you know what you're doing.\n\nlocal strformat = string.format\n\nlocal A = aura_env\nlocal t0 = 0\nlocal bag = 0\n\nlocal itemIDTest, itemNameTest = {}, {}\n\nfor i = 1, #itemList do\n    local item = itemList[i]\n    if type(item) == \"number\" then\n        itemIDTest[item] = true\n    else\n        itemNameTest[item] = true\n    end\nend\n\n-- Does sweep for bag i\n-- Returns true if should move to next bag, false if not.\nlocal function sweep(i)\n    -- Don't do sweep if player has picked up an item\n    -- (since PickupContainerItem() will replace it)\n    local cursor = GetCursorInfo()\n    if cursor then\n        return false\n    end\n    ClearCursor() -- paranoia\n    \n    local n = GetContainerNumSlots(i)\n    if not n then\n        return\n    end\n    for j = 1, n do\n        local id = GetContainerItemID(i, j)\n        if id then\n            local name = GetItemInfo(id)\n            if itemIDTest[id] or itemNameTest[name] then\n                PickupContainerItem(i, j)\n                DeleteCursorItem()\n                ClearCursor()\n                if bNotify then\n                    print(strformat(\n                            \"|cffffff00Item deleted:|r %s (itemID %d)\",\n                            tostring(name), id))\n                end\n            end\n        end\n    end\n    return true\nend\n\nlocal function customText()\n    local t = GetTime()\n    local result\n    if t - t0 > 1 then\n        t0 = t\n        result = sweep(bag)\n        if result then\n            bag = (bag == NUM_BAG_SLOTS) and 0 or (bag + 1)\n        end\n    end\nend\nA.customText = customText\n\n\n",
        do_custom = true
      }
    },
    customText = "function()return aura_env.customText()end",
    desc = "Arc v0.0 2016-02-16",
    displayText = "%c",
    height = 1.0000075101852417,
    id = "Item Deleter",
    init_completed = 1,
    load = {
      difficulty = {
        multi = {}
      },
      faction = {
        multi = {}
      },
      race = {
        multi = {}
      },
      role = {
        multi = {}
      },
      talent = {
        multi = {}
      }
    },
    numTriggers = 1,
    regionType = "text",
    trigger = {
      event = "Conditions",
      type = "status",
      unevent = "auto",
      use_alwaystrue = true,
      use_unit = true
    },
    width = 1.0000075101852417
  },
  m = "d",
  s = "2.1.0.19",
  v = 1421
}
