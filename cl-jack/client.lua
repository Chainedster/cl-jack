local inJackZone = false

local jack_car = nil
local car_model = GetHashKey('ageraone')
local car_coords = vector4(-1796.09, 455.27, 127.95, 89.47)

local jack_ped = nil
local jack_coords = vector4(-1801.41, 450.85, 128.51, 3.13)

local hug_coords = vector4(-1801.44, 451.71, 127.52, 183.13)

local render_zone = {
    vector2(-1861.39, 440.65),
    vector2(-1846.14, 494.46),
    vector2(-1770.56, 492.27),
    vector2(-1753.06, 419.36),
}

CreateThread(function()
    exports["PolyZone"]:AddPolyZone("cl-jack", render_zone, {
        minZ = 126.20,
        maxZ = 142.03,
        -- debugPoly = true,
    })
end)

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
    
    DecorSetInt(jack_ped, "Ped.DrugBlocker", true)
    ClearPedTasks(jack_ped)
    ClearPedSecondaryTask(jack_ped)
    TaskSetBlockingOfNonTemporaryEvents(jack_ped, true)
    SetPedFleeAttributes(jack_ped, 0, 0)
    SetPedCombatAttributes(jack_ped, 17, 1)
    SetPedAlertness(jack_ped, 0)
    SetEntityInvincible(jack_ped, true)
    SetPedSeeingRange(jack_ped, 0.0)
    SetPedHearingRange(jack_ped, 0.0)
    SetPedShouldPlayFleeScenarioExit(jack_ped, 0, 0, 0)
    SetPedAlertness(jack_ped, 0)
    SetPedKeepTask(jack_ped, true)
    CanPedRagdoll(jack_ped)
    SetPedConfigFlag(jack_ped, 294, 1)
    SetPedCanLosePropsOnDamage(jack_ped, false, 0)
    FreezeEntityPosition(jack_ped, true)
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

local isShowing = false
local isHugging = false
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

        if IsControlJustPressed(0, 38) and dist < 1.5 and isHugging == false then -- Pressed E
            TriggerServerEvent('Klownzz:Hug')
        end

        if jack_ped ~= nil then
            if IsPedFleeing(jack_ped) then
                LoadAnim("mp_ped_interaction")
                TaskSetBlockingOfNonTemporaryEvents(jack_ped, true)
                SetPedConfigFlag(jack_ped, 294, 1)
                SetEntityCoords(jack_ped, jack_coords.x, jack_coords.y, jack_coords.z-1, 324.7266, false, true, false, false)
                TaskStartScenarioInPlace(jack_ped, "WORLD_HUMAN_GUARD_STAND", 0, true)
            end
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
        SetEntityCoords(jack_ped, jack_coords.x, jack_coords.y, jack_coords.z-1, 324.7266, false, true, false, false)
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

AddEventHandler("cl-polyzone:enter", function(zone, data)
    if zone ~= 'cl-jack' then return end
    if inJackZone == true then return end

    if not jack_ped then
        CreateJackPed()
    end

    if not jack_car then
        SpawnJackCar()
    end

    inJackZone = true

    CreateThread(handleJackFocker)
    TriggerServerEvent('Klownzz:EnteredZone')
end)
  
AddEventHandler("cl-polyzone:exit", function(zone, data)
    if zone ~= 'cl-jack' then return end
    
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
end)