-- Import necessary libraries
local QBCore = exports['qb-core']:GetCoreObject()

-- Configuration
local huntingZones = {
    {name = "Hunting Zone 1", coords = vector3(-933.56, 5130.59, 167.41), blipId = 141, blipColor = 2},
    {name = "Hunting Zone 2", coords = vector3(2345.67, 890.12, 22.45), blipId = 141, blipColor = 2}
}

local storeZone = {coords = vector3(-773.96, 5603.24, 33.74)}

local animals = {"a_c_deer", "a_c_boar", "a_c_rabbit"}
local rewards = {deer = 50, boar = 75, rabbit = 30}

-- Create blips for hunting zones
Citizen.CreateThread(function()
    for _, zone in pairs(huntingZones) do
        local blip = AddBlipForCoord(zone.coords)
        SetBlipSprite(blip, zone.blipId)
        SetBlipColour(blip, zone.blipColor)
        SetBlipScale(blip, 1.0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Command to start hunting
RegisterCommand("startHunting", function()
    local playerPed = PlayerPedId()
    local animal = animals[math.random(#animals)]
    local animalEntity = CreatePed(28, GetHashKey(animal), GetEntityCoords(playerPed) + vector3(10, 10, 0), true, false)
    TaskWanderStandard(animalEntity, 10.0, 10)
end)

-- Event to reward player for skinned animal
RegisterNetEvent('qb-hunting:reward', function(animalType)
    local reward = rewards[animalType]
    if reward then
        QBCore.Functions.AddMoney("cash", reward)
        TriggerEvent('QBCore:Notify', "You received $" .. reward .. " for skinning a " .. animalType)
    end
end)

-- Client-side event to handle skinning
RegisterNetEvent('qb-hunting:skinAnimal', function(animalType)
    TriggerEvent('qb-hunting:reward', animalType)
end)

-- Store interaction
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        if Vdist(playerCoords, storeZone.coords) < 2.0 then
            DrawText3D(storeZone.coords.x, storeZone.coords.y, storeZone.coords.z, "[E] - Open Hunting Store")
            if IsControlJustReleased(0, 38) then
                -- Open store menu (implement store menu logic here)
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = Vdist(p.x, p.y, p.z, x, y, z)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = string.len(text) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 100)
    end
end

