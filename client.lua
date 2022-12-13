ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function proc(time, cb)
	if cb ~= nil then
		Citizen.CreateThread(function()
			timeLeft = 0
			repeat
				timeLeft = timeLeft + 1
				Citizen.Wait(time)
			until timeLeft == 100
			timeLeft = nil
			cb()
		end)
	else
		timeLeft = 0
		repeat
			timeLeft = timeLeft + 1
			Citizen.Wait(time)
		until timeLeft == 100
		timeLeft = nil
	end
end

function HandcuffsAction()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu', {
		title = 'Kajdanki',
		align = 'right',
		elements = {
			{label = 'Skuj / Rozkuj',		value = 'handcuff'},
			{label = 'Przeszukaj',			value = 'body_search'},
			{label = 'Chwyć / Puść',		value = 'drag'},
			{label = 'Włóż do pojazdu',		value = 'put_in_vehicle'},
			{label = 'Wyjmij z pojazdu',	value = 'out_the_vehicle'},
            {label = 'Wsadź do bagażnika', value = 'bagaj'},
            {label = 'Wyciągnij z bagażnika', value = 'bagaj'},
		}
	}, function(data, menu)
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			ESX.ShowNotification("~r~Nie można wykonać w aucie")
		else
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestPlayer ~= -1 and IsEntityVisible(GetPlayerPed(closestPlayer)) and closestDistance <= 3.0 then
				local closestPed = GetPlayerPed(closestPlayer)
				if data.current.value == 'body_search' then
            if (IsPedCuffed(closestPed) or IsPlayerDead(closestPlayer)) then
                proc(15, function()
                            menu.close()
                OpenBodySearchMenu(closestPlayer)
                end)
				  end
        elseif data.current.value == 'kajdanki' then
          ESX.ShowNotification('~b~Zakułeś|Rozkułeś ~r~' .. GetPlayerServerId(closestPlayer))
            if not exports['esx_property']:isInProperty() then
                TriggerServerEvent('esx_policejob:handcufftype', GetPlayerServerId(closestPlayer))
            else
                TriggerEvent('esx:showNotification', 'Nie możesz zakuć osoby w Interiorze')
            end
				elseif data.current.value == 'drag' then
          if IsPedCuffed(GetPlayerPed(closestPlayer)) or IsPlayerDead(closestPlayer) then
          --  ESX.ShowNotification('~o~Przenosisz obywatela ~b~' .. GetPlayerServerId(closestPlayer))
            exports["taskbar"]:taskBar(1000, "Łapanie|Puszczanie", false, true)
            TriggerServerEvent('esx_policejob:drag', GetPlayerServerId(closestPlayer))
          else
            ESX.ShowNotification("~r~Pierw musisz zakuć gracza.")
          end
        elseif data.current.value == 'put_in_vehicle' then
          ESX.ShowNotification('~b~Wsadzasz do pojazdu ~b~' .. GetPlayerServerId(closestPlayer))
					TriggerServerEvent('esx_policejob:putInVehicle', GetPlayerServerId(closestPlayer))
        elseif data.current.value == 'out_the_vehicle' then
          ESX.ShowNotification('~b~Wyciągasz z pojazdu ~b~' .. GetPlayerServerId(closestPlayer))
					TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(closestPlayer))
                elseif action == 'bagaj' then
					TriggerServerEvent('exile:putTargetInTrunk', GetPlayerServerId(closestPlayer))
				elseif action == 'bagaj' then
					TriggerServerEvent('esx_policejob:outTargetFromTrunk', GetPlayerServerId(closestPlayer))
				end
			else
				ESX.ShowNotification('~y~Brak graczy w pobliżu')
			end
		end
    end, function(data, menu)
		menu.close()
	end)
end
function OpenBodySearchMenu(target)
    local serverId = GetPlayerServerId(target)
    ESX.TriggerServerCallback('esx_policejob:checkSearch', function(cb)
        if cb == true then
            ESX.ShowAdvancedNotification("Ta osoba jest już przeszukiwana!") 
        else
            ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
                TriggerServerEvent('esx_policejob:isSearching', serverId)
				local elements = {}
                for i=1, #data.accounts, 1 do
                    if data.accounts[i].money > 0 then
                        if data.accounts[i].name == 'black_money' then
                            table.insert(elements, {
                                label    = '[Brudna Gotówka] $'..data.accounts[i].money,
                                value    = 'black_money',
                                type     = 'item_account',
                                amount   = data.accounts[i].money
                            })
                            break
                        end
                    end
                end
                
                for i=1, #data.inventory, 1 do
                    if data.inventory[i].count > 0 then
                        table.insert(elements, {
                            label    = data.inventory[i].label .. " x" .. data.inventory[i].count,
                            value    = data.inventory[i].name,
                            type     = 'item_standard',
                            amount   = data.inventory[i].count
                        })
                    end
                end
 
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
                    title    = 'Przeszukaj',
                    align    = 'right',
                    elements = elements
                }, function(data, menu)
                    local itemType = data.current.type
                    local itemName = data.current.value
                    local amount   = data.current.amount
                    local playerCoords = GetEntityCoords(Citizen.InvokeNative(0x43A66C31C68491C0, -1))
                    local targetCoords = GetEntityCoords(Citizen.InvokeNative(0x43A66C31C68491C0, target))
                    if itemType == 'item_sim' then
                        ESX.TriggerServerCallback('esx_policejob:checkSearch2', function(cb)
                            if cb == true then
                                ESX.UI.Menu.CloseAll()
                                if #(playerCoords - targetCoords) <= 3.0 then
                                    proc(5, function()
                                        TriggerServerEvent('esx_policejob:isSearching', serverId, false)
                                        OpenBodySearchMenu(target)
                                    end)
                                end
                            else
								print('xD?')
                            end
                        end, serverId)
                    else
                        if data.current.value ~= nil then
                            ESX.TriggerServerCallback('esx_policejob:checkSearch2', function(cb)
                                if cb == true then
                                    ESX.UI.Menu.CloseAll()
                                    if #(playerCoords - targetCoords) <= 3.0 then
                                        TriggerServerEvent('esx_policejob:confiscatePlayerItem', serverId, itemType, itemName, amount)
                                        proc(5, function()
                                            TriggerServerEvent('esx_policejob:isSearching', serverId, false)
                                            OpenBodySearchMenu(target)
                                        end)
                                    end
                                else
                                    print('xd?')
                                end
                            end, serverId)
                        end
                    end
                end, function(data, menu)
                    menu.close()
                    TriggerServerEvent('esx_policejob:isSearching', serverId, false)
                end)
            end, serverId)
        end
    end, serverId)
end