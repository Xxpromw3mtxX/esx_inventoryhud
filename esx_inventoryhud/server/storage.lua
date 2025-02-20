ESX.RegisterServerCallback("esx_inventoryhud:getStorageInventory", function(source, cb, storage)
        local targetXPlayer = ESX.GetPlayerFromId(target)
        local weapons, items, blackMoney, cash

        TriggerEvent("esx_datastore:getSharedDataStore", storage, function(store)
                weapons = store.get("weapons")

                if weapons == nil then
                    weapons = {}
                end

                TriggerEvent("esx_addoninventory:getSharedInventory", storage, function(inventory)
                        items = inventory.items

                        if items == nil then
                            items = {}
                        end

                        TriggerEvent("esx_addonaccount:getSharedAccount", storage .. "_blackMoney", function(account)
                                if account ~= nil then
                                    blackMoney = account.money
                                else
                                    blackMoney = 0
                                end

                                TriggerEvent("esx_addonaccount:getSharedAccount", storage .. "_money", function(account)
                                    if account ~= nil then
                                        cash = account.money
                                    else
                                        cash = 0
                                    end

                                    cb({inventory = items, blackMoney = blackMoney, weapons = weapons, cash = cash})
                                end
                                )
                            end
                        )
                    end
                )
            end
        )
    end
)

RegisterServerEvent("esx_inventoryhud:getStorageItem")
AddEventHandler("esx_inventoryhud:getStorageItem", function(storage, type, item, count)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)

        if type == "item_standard" then

            TriggerEvent("esx_addoninventory:getSharedInventory", storage, function(inventory)
                    local inventoryItem = inventory.getItem(item)

                    -- is there enough in the property?
                    if count > 0 and inventoryItem.count >= count then
                        inventory.removeItem(item, count)
                        xPlayer.addInventoryItem(item, count)

                        TriggerEvent("esx_adminmenu:logSociety", storage, GetPlayerIdentifiers(_source), xPlayer, "TAKE", inventoryItem.label, count, inventoryItem.count - count)
                        TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("took_from_storage", count, inventoryItem.label), 2500, 'info')
                    else
                        TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("took_not_enough"), 2500, 'info')
                    end
                end
            )
        elseif type == "item_account" then
            TriggerEvent("esx_addonaccount:getSharedAccount", storage .. "_blackMoney", function(account)
                local roomAccountMoney = account.money

                if roomAccountMoney >= count then
                    account.removeMoney(count)
                    xPlayer.addAccountMoney(item, count)

                    TriggerEvent("esx_adminmenu:logSociety", storage, GetPlayerIdentifiers(_source), xPlayer, "TAKE", "Špinavé prachy", count, roomAccountMoney)
                else
                    TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("bad_amount"), 2500, 'info')
                end
            end
            )
        elseif type == "item_weapon" then
            TriggerEvent(
                "esx_datastore:getSharedDataStore",
                storage,
                function(store)
                    local storeWeapons = store.get("weapons") or {}
                    local weaponName = nil
                    local ammo = nil
                    local components = {}

                    for i = 1, #storeWeapons, 1 do
                        if storeWeapons[i].name == item then
                            weaponName = storeWeapons[i].name
                            ammo = storeWeapons[i].ammo

                            if storeWeapons[i].components ~= nil then
                                components = storeWeapons[i].components
                            end

                            table.remove(storeWeapons, i)
                            break
                        end
                    end

                    store.set("weapons", storeWeapons)
                    xPlayer.addWeapon(weaponName, ammo)

                    TriggerEvent("esx_adminmenu:logSociety", storage, GetPlayerIdentifiers(_source), xPlayer, "TAKE", weaponName, ammo, 0)

                    for i = 1, #components do
                        xPlayer.addWeaponComponent(weaponName, components[i])
                    end
                end
            )
        elseif type == "item_money" then
            TriggerEvent("esx_addonaccount:getSharedAccount", storage .. "_money", function(account)
                local roomAccountMoney = account.money

                if roomAccountMoney >= count then
                    account.removeMoney(count)
                    xPlayer.addAccountMoney('money', count)

                    TriggerEvent("esx_adminmenu:logSociety", storage, GetPlayerIdentifiers(_source), xPlayer, "TAKE", "Špinavé prachy", count, roomAccountMoney)
                else
                    TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("bad_amount"), 2500, 'info')
                end
            end
            )
        end
    end
)

RegisterServerEvent("esx_inventoryhud:putStorageItem")
AddEventHandler("esx_inventoryhud:putStorageItem", function(storage, type, item, count)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)

        if type == "item_standard" then
            local playerItemCount = xPlayer.getInventoryItem(item).count

            if playerItemCount >= count and count > 0 then
                TriggerEvent(
                    "esx_addoninventory:getSharedInventory",
                    storage,
                    function(inventory)
                        xPlayer.removeInventoryItem(item, count)
                        inventory.addItem(item, count)

                        local inventoryItem = inventory.getItem(item)
                        TriggerEvent("esx_adminmenu:logSociety", storage, GetPlayerIdentifiers(_source), xPlayer, "PUT", inventoryItem.label, count, inventoryItem.count)
                        TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("put_into_storage", count, inventoryItem.label), 2500, 'info')
                    end
                )
            else
                TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("bad_amount"), 2500, 'info')
            end
        elseif type == "item_account" then
            local playerAccountType = xPlayer.getAccount(item).name
            local playerAccountMoney = xPlayer.getAccount(item).money

            if playerAccountType == 'money' then
                if playerAccountMoney >= count and count > 0 then
                    xPlayer.removeAccountMoney(item, count)
                    
                    TriggerEvent("esx_addonaccount:getSharedAccount", storage .. "_money", function(account)
                            account.addMoney(count)
    
                            TriggerEvent("esx_adminmenu:logSociety", storage, GetPlayerIdentifiers(_source), xPlayer, "PUT", "Špinavé prachy", count, account.money + count)
                        end
                    )
                else
                    TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("bad_amount"), 2500, 'info')
                end
            else
                if playerAccountMoney >= count and count > 0 then
                    xPlayer.removeAccountMoney(item, count)
                    
                    TriggerEvent("esx_addonaccount:getSharedAccount", storage .. "_blackMoney", function(account)
                            account.addMoney(count)
    
                            TriggerEvent("esx_adminmenu:logSociety", storage, GetPlayerIdentifiers(_source), xPlayer, "PUT", "Špinavé prachy", count, account.money + count)
                        end
                    )
                else
                    TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("bad_amount"), 2500, 'info')
                end
            end

            
        elseif type == "item_weapon" then
            TriggerEvent(
                "esx_datastore:getSharedDataStore",
                storage,
                function(store)
                    local storeWeapons = store.get("weapons") or {}

                    local pos, playerWeapon = xPlayer.getWeapon(item)
                    local components = playerWeapon.components
                    if components == nil then
                        components = {}
                    end

                    table.insert(
                        storeWeapons,
                        {
                            name = item,
                            ammo = count,
                            components = components
                        }
                    )

                    TriggerEvent("esx_adminmenu:logSociety", storage, GetPlayerIdentifiers(_source), xPlayer, "PUT", item, count, count)

                    store.set("weapons", storeWeapons)
                    xPlayer.removeWeapon(item)
                end
            )
        end
    end
)
