local targetPlayer
local targetPlayerName

AddEventHandler( "onResourceStop", function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent("chat:removeSuggestion", "/openinventory")
	end
end)

RegisterNetEvent("esx_inventoryhud:openPlayerInventory")
AddEventHandler("esx_inventoryhud:openPlayerInventory", function(target, playerName)
	targetPlayer = target
	targetPlayerName = playerName
	setPlayerInventoryData()
	openPlayerInventory()
	TriggerServerEvent('esx_inventoryhud:disableTargetInv', target)
end)

function refreshPlayerInventory()
	setPlayerInventoryData()
end

function setPlayerInventoryData()
	ESX.TriggerServerCallback("esx_inventoryhud:getPlayerInventory", function(data)
		SendNUIMessage({
			action = "setInfoText",
			text = "<strong>" .. _U("player_inventory") .. "</strong><br>" .. targetPlayerName .. " (" .. targetPlayer .. ")"
		})

		items = {}
		inventory = data.inventory
		accounts = data.accounts
		money = data.money
		weapons = data.weapons

		if Config.IncludeCash and money ~= nil and money > 0 then
			moneyData = {
				label = _U("cash"),
				name = "cash",
				type = "item_money",
				count = money,
				usable = false,
				rare = false,
				weight = -1,
				canRemove = true
			}
			table.insert(items, moneyData)
		end

		if Config.IncludeAccounts and accounts ~= nil then
			for key, value in pairs(accounts) do
				if not shouldSkipAccount(accounts[key].name) then
					local canDrop = accounts[key].name ~= "bank"
					if accounts[key].money > 0 then
						accountData = {
							label = accounts[key].label,
							count = accounts[key].money,
							type = "item_account",
							name = accounts[key].name,
							usable = false,
							rare = false,
							weight = -1,
							canRemove = canDrop
						}
						table.insert(items, accountData)
					end
				end
			end
		end

		if inventory ~= nil then
			for key, value in pairs(inventory) do
				if inventory[key].count <= 0 then
					inventory[key] = nil
				else
					inventory[key].type = "item_standard"
					table.insert(items, inventory[key])
				end
			end
		end

		SendNUIMessage({
			action = "setSecondInventoryItems",
			itemList = items
		})
	end, targetPlayer)
end

function openPlayerInventory()
	loadPlayerInventory()
	isInInventory = true
	SendNUIMessage({
		action = "display",
		type = "player"
	})
	SetNuiFocus(true, true)
end

RegisterNUICallback("PutIntoPlayer", function(data, cb)
	if IsPedSittingInAnyVehicle(playerPed) then
		return
	end
	if type(data.number) == "number" and math.floor(data.number) == data.number then
		local count = tonumber(data.number)
		if data.item.type == "item_weapon" then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end
		TriggerServerEvent("esx_inventoryhud:tradePlayerItem", GetPlayerServerId(PlayerId()), targetPlayer, data.item.type, data.item.name, count)
	end
	Wait(250)
	refreshPlayerInventory()
	loadPlayerInventory()
	cb("ok")
end)

RegisterNUICallback("TakeFromPlayer", function(data, cb)
	if IsPedSittingInAnyVehicle(playerPed) then
		return
	end
	if type(data.number) == "number" and math.floor(data.number) == data.number then
		local count = tonumber(data.number)
		if data.item.type == "item_weapon" then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end
		TriggerServerEvent("esx_inventoryhud:tradePlayerItem", targetPlayer, GetPlayerServerId(PlayerId()), data.item.type, data.item.name, count)
	end
	Wait(250)
	refreshPlayerInventory()
	loadPlayerInventory()
	cb("ok")
end)