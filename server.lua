local ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('faizu-ping:SendPing', function(coords)

	local source = source 
  	local xPlayer = ESX.GetPlayerFromId(source) 

    for _, playerId in ipairs(GetPlayers()) do
        local targetPlayer = ESX.GetPlayerFromId(playerId)
        
        for _, jobName in ipairs(Config.Jobs) do
            if targetPlayer.job.name == jobName then
                print(coords)
                TriggerClientEvent('faizu-ping:RecievePing', playerId, coords)
                break

            end
        end
    end

end)