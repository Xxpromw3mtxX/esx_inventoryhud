ESX = nil

TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

ESX.RegisterServerCallback("esx_inventoryhud:getPlayerInventory", function(source, cb, target)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if targetXPlayer ~= nil then
		cb({inventory = targetXPlayer.inventory, money = targetXPlayer.getMoney(), accounts = targetXPlayer.accounts, weapons = targetXPlayer.loadout})
	else
		cb(nil)
	end
end)

RegisterServerEvent("esx_inventoryhud:tradePlayerItem")
AddEventHandler("esx_inventoryhud:tradePlayerItem", function(from, target, type, itemName, itemCount)
	local _source = from

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if type == "item_standard" then
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		local targetItem = targetXPlayer.getInventoryItem(itemName)

		sourceXPlayer.removeInventoryItem(itemName, itemCount)
		targetXPlayer.addInventoryItem(itemName, itemCount)

		--[[if itemCount > 0 and sourceItem.count >= itemCount then
			if targetItem.limit ~= -1 and (targetItem.count + itemCount) > targetItem.limit then
			else
				sourceXPlayer.removeInventoryItem(itemName, itemCount)
				targetXPlayer.addInventoryItem(itemName, itemCount)
			end
		end]]
	elseif type == "item_money" then
		if itemCount > 0 and sourceXPlayer.getMoney() >= itemCount then
			sourceXPlayer.removeMoney(itemCount)
			targetXPlayer.addMoney(itemCount)
		end
	elseif type == "item_account" then
		if itemCount > 0 and sourceXPlayer.getAccount(itemName).money >= itemCount then
			sourceXPlayer.removeAccountMoney(itemName, itemCount)
			targetXPlayer.addAccountMoney(itemName, itemCount)
		end
	elseif type == "item_weapon" then
		if not targetXPlayer.hasWeapon(itemName) then
			local pos, playerWeapon = sourceXPlayer.getWeapon(itemName)
			local components = playerWeapon.components

			sourceXPlayer.removeWeapon(itemName)
			targetXPlayer.addWeapon(itemName, itemCount)

			if components == nil then
				components = {}
			end

			for i = 1, #components do
				targetXPlayer.addWeaponComponent(itemName, components[i])
			end
		end
	end
end)

RegisterServerEvent("esx_inventoryhud:buyItem")
AddEventHandler("esx_inventoryhud:buyItem", function(item, amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if item.type == "item_standard" then
		local playerItem = xPlayer.getInventoryItem(item.name)

		if amount > 0 then
			if playerItem.limit ~= -1 and (playerItem.count + amount) > playerItem.limit then
				TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("not_enough_space"), 2500, 'info')
			else
				local price = amount * item.price

				if xPlayer.getAccount('bank').money >= price then
					xPlayer.removeMoney(price)
					xPlayer.addInventoryItem(item.name, amount)
					TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("bought", amount, item.label, item.price), 2500, 'info')
				else
					TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("not_enough_money"), 2500, 'info')
				end
			end
		end
	elseif item.type == "item_weapon" then
		if xPlayer.getAccount('bank').money >= item.price then
			if not xPlayer.hasWeapon(item.name) then
				xPlayer.removeMoney(item.price)
				xPlayer.addWeapon(item.name, item.ammo)
				TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("bought", 1, item.label, item.price), 2500, 'info')
			else
				TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("already_have_weapon"), 2500, 'info')
			end
		else
			TriggerClientEvent('okokNotify:Alert', _source, "<span style='color:#5288DB; font-family: serif;'>ATLANTIS</span>", _U("not_enough_money"), 2500, 'info')
		end
	end
end)

ESX.RegisterServerCallback("esx_inventoryhud:getPlayerInventoryWeight", function(source,cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local playerweight = xPlayer.getWeight()
	cb(playerweight)
end)

ESX.RegisterServerCallback("esx_inventoryhud:getMaxInventoryWeight", function(source,cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local maxWeight = Config.Weight
	cb(maxWeight)
end)

-- 3D Notification
RegisterServerEvent('esx_inventoryhud:show')
AddEventHandler('esx_inventoryhud:show', function(name)
	local playerId = source
	local sourceXPlayer = ESX.GetPlayerFromId(playerId)
	local sourceItem = sourceXPlayer.getInventoryItem(name)
    TriggerClientEvent('3dme:shareDisplay', -1, 'Ha passato '..sourceItem.label, source)
end)