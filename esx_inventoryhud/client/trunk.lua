local trunkData = nil

RegisterNetEvent("esx_inventoryhud:openTrunkInventory")
AddEventHandler("esx_inventoryhud:openTrunkInventory", function(data, blackMoney, cashMoney, inventory, weapons)
    setTrunkInventoryData(data, blackMoney, cashMoney, inventory, weapons)
    openTrunkInventory()
end)

RegisterNetEvent("esx_inventoryhud:refreshTrunkInventory")
AddEventHandler("esx_inventoryhud:refreshTrunkInventory", function(data, blackMoney, cashMoney, inventory, weapons)
    setTrunkInventoryData(data, blackMoney, cashMoney, inventory, weapons)
end)

function setTrunkInventoryData(data, blackMoney, cashMoney, inventory, weapons)
    trunkData = data

    SendNUIMessage(
        {
            action = "setInfoText",
            text = data.text
        }
    )

    items = {}

    if cashMoney > 0 then
        accountData = {
            label = _U("cash"),
            count = cashMoney,
            type = "item_account",
            name = "money",
            usable = false,
            rare = false,
            limit = -1,
            canRemove = false
        }
        table.insert(items, accountData)
    end

    if blackMoney > 0 then
        accountData = {
            label = _U("black_money"),
            count = blackMoney,
            type = "item_account",
            name = "black_money",
            usable = false,
            rare = false,
            limit = -1,
            canRemove = false
        }
        table.insert(items, accountData)
    end

    if inventory ~= nil then
        for key, value in pairs(inventory) do
            if inventory[key].count <= 0 then
                inventory[key] = nil
            else
                inventory[key].type = "item_standard"
                inventory[key].usable = false
                inventory[key].rare = false
                inventory[key].limit = -1
                inventory[key].canRemove = false
                table.insert(items, inventory[key])
            end
        end
    end

    if Config.IncludeWeapons and weapons ~= nil then
        for key, value in pairs(weapons) do
            local weaponHash = GetHashKey(weapons[key].name)
            if weapons[key].name ~= "WEAPON_UNARMED" then
                table.insert(
                    items,
                    {
                        label = weapons[key].label,
                        count = weapons[key].ammo,
                        limit = -1,
                        type = "item_weapon",
                        name = weapons[key].name,
                        usable = false,
                        rare = false,
                        canRemove = false
                    }
                )
            end
        end
    end

    SendNUIMessage(
        {
            action = "setSecondInventoryItems",
            itemList = items
        }
    )
end

function openTrunkInventory()
    loadPlayerInventory()
    isInInventory = true

    SendNUIMessage(
        {
            action = "display",
            type = "trunk"
        }
    )

    SetNuiFocus(true, true)
end

RegisterNUICallback("PutIntoTrunk", function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end
    
    if type(data.number) == "number" and math.floor(data.number) == data.number then
        local count = tonumber(data.number)

        if data.item.type == "item_weapon" then
            count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
        end

        ESX.TriggerServerCallback("esx_vehicleshop:isPlateTaken", function(isPlateTaken)
            TriggerServerEvent("esx_inventoryhud_trunk:putItem", trunkData.plate, data.item.type, data.item.name, count, trunkData.max, isPlateTaken, data.item.label)
        end,trunkData.plate)
    end

    Wait(250)
    loadPlayerInventory()

    cb("ok")
end)

RegisterNUICallback("TakeFromTrunk", function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end

    if type(data.number) == "number" and math.floor(data.number) == data.number then
        ESX.TriggerServerCallback("esx_vehicleshop:isPlateTaken", function(isPlateTaken)
            TriggerServerEvent("esx_inventoryhud_trunk:getItem", trunkData.plate, data.item.type, data.item.name, tonumber(data.number), trunkData.max, isPlateTaken)
        end,trunkData.plate)
    end

    Wait(250)
    loadPlayerInventory()

    cb("ok")
end)