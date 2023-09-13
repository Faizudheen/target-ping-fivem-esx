local config = {}
if Config then
    config = Config
else
    config = require("config")
end

local markerCoords = {x = 0.0, y = 0.0, z = 0.0}


local markerVisible = false
local markerStartTime = 0

local blip = nil
local pingProtection = false

function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end


function CopyToClipboard(x, y, z)
    local x = math.round(x, 2)
    local y = math.round(y, 2)
    local z = math.round(z, 2)
    
    
    -- Set marker properties
    markerCoords = {x = x, y = y, z = z}
    markerVisible = true
    markerStartTime = GetGameTimer()

    if Config.BlipEnabled then
        blip = AddBlipForCoord(x, y, z)
        SetBlipSprite(blip, 1)
        SetBlipScale(blip, 1.0)
        SetBlipAsShortRange(blip, true)
    end

    


    DrawMarker(1, x, y, z - 1.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, -40.0, 200, 20, 20, 50, false, true, 2, false, nil, nil, false)
end

function math.round(input, decimalPlaces)
    return tonumber(string.format("%." .. (decimalPlaces or 0) .. "f", input))
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
 
        local _, coords , _ = RayCastGamePlayCamera(2000.0)
        
        
        
        if markerVisible then
            local elapsedTime = GetGameTimer() - markerStartTime
            if elapsedTime >= config.markerDuration then
                pingProtection = false
                markerVisible = false
                

               if Config.BlipEnabled then
                if blip ~= nil then
                    RemoveBlip(blip)
                    blip = nil
                end
               end
            else
 
                DrawMarker(1, markerCoords.x, markerCoords.y, markerCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, -40.0, 200, 20, 20, 50, false, true, 2, false, nil, nil, false)
            end
        end
        if IsControlJustPressed(0, 47) then
           -- CopyToClipboard(coords.x, coords.y, coords.z)
            if not pingProtection then 
                TriggerServerEvent('faizu-ping:SendPing',coords)
                pingProtection = true
            end
            
            
        end
        
    end
end)

RegisterNetEvent('faizu-ping:RecievePing')
AddEventHandler('faizu-ping:RecievePing',function(coords)
    print(coords)
    CopyToClipboard(coords.x, coords.y, coords.z)
end)
