local shopZone = nil

RegisterNetEvent("esx_inventoryhud:openShop")
AddEventHandler("esx_inventoryhud:openShop", function(zone, items)
        setShopData(zone, items)
        openShop()
    end
)

function setShopData(zone, items)
    shopZone = zone

    SendNUIMessage(
        {
            action = "setType",
            type = "shop"
        }
    )

    SendNUIMessage(
        {
            action = "setInfoText",
            text = _U("store")
        }
    )

    SendNUIMessage(
        {
            action = "setShopInventoryItems",
            itemList = items
        }
    )
end

function openShop()
    loadPlayerInventory()
    isInInventory = true

    SendNUIMessage(
        {
            action = "display",
            type = "shop"
        }
    )

    SetNuiFocus(true, true)
end

RegisterNUICallback("BuyItem", function(data, cb)
        if type(data.number) == "number" and math.floor(data.number) == data.number then
            local count = tonumber(data.number)

            if shopZone == "custom" then
                TriggerServerEvent("esx_inventoryhud:buyItem", data.item, count)
            elseif shopZone == "atlantis_shops" then
                local totalamount = count * data.item.price
                TriggerServerEvent('atlantis_shops:sellItems', data.item.name, count, totalamount)
            else
                TriggerServerEvent("esx_shops:buyItem", data.item.name, count, shopZone)
            end
        end

        Wait(250)
        loadPlayerInventory()

        cb("ok")
    end
)
