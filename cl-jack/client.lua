local inJackZone = false

local isShowing = false
local isHugging = false

local jack_car = nil
local car_model = GetHashKey('ageraone')
local car_coords = vector4(-1796.09, 455.27, 127.95, 89.47)

local jack_ped = nil
local jack_coords = vector4(-1801.41, 450.85, 128.51, 3.13)
local jack_coords3 = vector3(jack_coords.x, jack_coords.y, jack_coords.z)

local hug_coords = vector4(-1801.44, 451.71, 127.52, 183.13)

local function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
      RequestAnimDict(dict)
      Wait(50)
    end
end

local function DoHugAnimation(ped)
    Citizen.CreateThread(function()
        ClearPedTasksImmediately(ped)
        TaskPlayAnim(ped, "mp_ped_interaction", "kisses_guy_a", 2.0, 2.0, 5000, 1, 0, false, false, false)       
    end)
end

local function SetClothes(jackPed)
    -- Hair
    SetPedComponentVariation(jackPed, 2, 2, 0, 0)
    SetPedHairColor(jackPed, 0, 0)

    -- Face
    SetPedHeadBlendData(jackPed, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, true)

    -- Mask
    SetPedComponentVariation(jackPed, 1, 51, 0, 2)
    SetPedComponentVariation(jackPed, 1, 51, 1, 0)

    -- Clothing
    SetPedComponentVariation(jackPed, 11, 253, 2, 0) -- Jacket
    SetPedComponentVariation(jackPed, 8, 15, 0, 0) -- Undershirt
    SetPedComponentVariation(jackPed, 4, 83, 0, 0) -- Leg
    SetPedComponentVariation(jackPed, 6, 55, 9, 0) -- Shoes 
    SetPedComponentVariation(jackPed, 5, 45, 0, 0) -- Parachute/Bag
    SetPedComponentVariation(jackPed, 3, 4, 0, 0) -- Arms

    -- Props etc
    SetPedPropIndex(jackPed, 0, 96, 0, 0, true) -- Hat
    SetPedPropIndex(jackPed, 1, 9, 0, 0, true) -- Glasses
end

local function CreateJackPed()
    local hash = 1885233650
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(20)
    end

    jack_ped = CreatePed(0, hash, jack_coords.x, jack_coords.y, jack_coords.z-1, jack_coords.w, false, false)
    SetClothes(jack_ped)
    GiveWeaponToPed(jack_ped, GetHashKey('WEAPON_ASSAULTRIFLE'), 1, true, true)
    
    ClearPedTasks(jack_ped)
    SetPedCanLosePropsOnDamage(jack_ped, false, 0)
    FreezeEntityPosition(jack_ped, true)
    SetEntityInvincible(jack_ped, true)
    SetBlockingOfNonTemporaryEvents(jack_ped, true)
    TaskStartScenarioInPlace(jack_ped, "WORLD_HUMAN_GUARD_STAND", 0, true) 
end

local function SnowPatrolTheVehicle(vehicle)
    SetVehicleColours(vehicle, 112, 12)
    SetVehicleNumberPlateText(vehicle,"KLOWNZZ")
    SetVehicleWindowTint(vehicle, 1)

    SetVehicleWindowTint(vehicle, 2)
    SetVehicleExtraColours(vehicle, 0, 0)
    SetVehicleNumberPlateTextIndex(vehicle, 0)  
end

local function SpawnJackCar()
    if not IsModelInCdimage(car_model) then return end
    RequestModel(car_model)
    while not HasModelLoaded(car_model) do 
        Citizen.Wait(10)
    end
    jack_car = CreateVehicle(car_model, car_coords.x, car_coords.y, car_coords.z, car_coords.w, false, false) 
    SetModelAsNoLongerNeeded(car_model) 
    FreezeEntityPosition(jack_car, true)
    SetVehicleEngineOn(jack_car, false, true, true)
    SetVehicleDoorsLockedForAllPlayers(jack_car, true)
    SnowPatrolTheVehicle(jack_car)
    SetEntityInvincible(jack_car, true)
end 

local function handleJackFocker()
    while true do 
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - vector3(jack_coords.x, jack_coords.y, jack_coords.z))

        if dist < 1.5 and isShowing == false then
            isShowing = true
            exports["cl_ui_interaction"]:showInteraction('[E] - Hug', 'info')
        elseif dist > 1.5 and isShowing then
            isShowing = false
            exports["cl_ui_interaction"]:hideInteraction()
        end

        if IsControlJustPressed(0, 38) and dist < 1.5 and isHugging == false and not IsPedInAnyVehicle(playerPed, false) then -- Pressed E
                TriggerServerEvent('Klownzz:Hug')
        end

        if inJackZone == false then
            if isShowing then
                isShowing = false
                exports["cl_ui_interaction"]:hideInteraction()
            end
            break
        end
        Wait(1)
    end
end

RegisterNetEvent('Klownzz:HandleHug')
AddEventHandler('Klownzz:HandleHug', function(who)
    LoadAnim("mp_ped_interaction")

    if who == 'jack' then
        SetEntityCoords(jack_ped, jack_coords.x, jack_coords.y, jack_coords.z-1, false, true, false, false)
        DoHugAnimation(jack_ped)
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 6.0, 'Jack-Dying-Laughing', 0.4)	
    elseif who == 'self' then
        isHugging = true
        playerPed = PlayerPedId()
        SetEntityCoords(playerPed, hug_coords.x, hug_coords.y, hug_coords.z, false, true, false, false)
        SetEntityHeading(playerPed, GetEntityHeading(jack_ped) + 180)
        FreezeEntityPosition(playerPed, true)
        DoHugAnimation(playerPed)
        
        Wait(5000)
        
        isHugging = false
        FreezeEntityPosition(playerPed, false)
        TaskStartScenarioInPlace(jack_ped, "WORLD_HUMAN_GUARD_STAND", 0, true)
    end
end)

CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(jack_coords3 - playerCoords)
        
        if not inJackZone and dist <= 100 then
            
            if not jack_ped then
                CreateJackPed()
            end
        
            if not jack_car then
                SpawnJackCar()
            end
        
            inJackZone = true
        
            CreateThread(handleJackFocker)
            TriggerServerEvent('Klownzz:EnteredZone')
        elseif inJackZone and dist > 100 then
            if jack_ped then
                DeleteEntity(jack_ped)
                jack_ped = nil
            end
            
            if jack_car then
                DeleteEntity(jack_car)
                jack_car = nil
            end

            inJackZone = false
            TriggerServerEvent('Klownzz:ExitedZone')
        end

        Wait(2000)
    end

end)