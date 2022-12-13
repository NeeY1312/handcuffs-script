ESX = nil

local SearchTable = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('kajdanki', function(source) ##Dodaj "kajdanki do bazdy danych 
    local _source = source
	TriggerClientEvent('esx_kajdankineeya:onUse', _source)
end)

ESX.RegisterServerCallback('esx_policejob:checkSearch', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if SearchTable[target] ~= nil then
        if SearchTable[target] == xPlayer.identifier then
            cb(false)
        else
            cb(true)
        end
    else
        cb(false)
    end
end)

RegisterServerEvent('esx_policejob:isSearching')
AddEventHandler('esx_policejob:isSearching', function(target, boolean)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if boolean == nil then
        SearchTable[target] = xPlayer.identifier
    else
        SearchTable[target] = nil
    end
end)
 
ESX.RegisterServerCallback('esx_policejob:checkSearch2', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if SearchTable[target] ~= nil then
        if SearchTable[target] == xPlayer.identifier then
            cb(true)
        else
            cb(false)
        end
    else
        cb(true)
    end
end)

RegisterServerEvent('neey:namecheck')
AddEventHandler('neey:namecheck', function(state)
    local serverID = source
    TriggerClientEvent('neey:namecheck', -1, serverID, state)
end)

if ( GetCurrentResourceName() ~= "neey_kajdanki" ) then
    print( "^ERROR: Wprowadź poprawną nazwe scryptu, aby poprawnie funkcjonowal^0\n\n" )
  end


