-------------------------------------
--- PatreonDonatorPerks by Badger ---
-------------------------------------
ESX                           = nil

Citizen.CreateThread(function ()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)
AddEventHandler('playerSpawned', function()
	if not alreadyTriggered then 
		TriggerServerEvent('PatreonDonatorPerks:CheckPerks');
		alreadyTriggered = true;
	end
end)
alreadyTriggered = false;
offers = {}
RegisterNetEvent('Perksy')
AddEventHandler('Perksy', function(offer)
	print("AddOffer was triggered");
	local temp = {}
	for i = 1, #offers do 
		table.insert(temp, offers[i])
	end
	table.insert(temp, offer);
	offers = temp;
	print(#offers);
	print("Temp: " .. #temp);
end)
RegisterNetEvent('PatreonDonatorPerks:Client:RemoveFromStack')
AddEventHandler('PatreonDonatorPerks:Client:RemoveFromStack', function()
	-- Remove latest from top of stack 
	local temp = {}
	for i = 2, #offers do 
		table.insert(temp, offers[i])
	end
	offers = temp;
end)
Citizen.CreateThread(function()
	while true do 
		Wait(0);
		local src = source;
		if #offers > 0 then 
			-- They have offers 
			local label = offers[1][1];
			if label == 'Money' then 
				local nameLab = offers[1][2];
				local amt = offers[1][3];
				Draw2DText(.5, .5, '~w~You have a ~g~' .. nameLab .. ' ~w~donator perk ', 1.0);
				Draw2DText(.5, .55, '~y~Press ~b~ARROW_UP ~y~to accept or ~b~ARROW_DOWN ~y~to reject on this character...', 1.0);
			end
			if label == 'Job' then 
				local nameLab = offers[1][2];
				local jobName = offers[1][3];
				local jobGrade = offers[1][4];
				Draw2DText(.5, .5, '~w~You have a donator perk for ~p~' .. nameLab 
					.. '~w~ of level grade ~p~' .. jobGrade, 1.0);
				Draw2DText(.5, .55, '~y~Press ~b~ARROW_UP ~y~to accept or ~b~ARROW_DOWN ~y~to reject on this character...', 1.0);
			end
		end  
	end
end)
Citizen.CreateThread(function()
	while true do 
		Wait(0);
		if #offers > 0 then 
			local label = offers[1][1];
			if (IsControlJustPressed(0, 172)) then -- They pressed ARROW_UP 
				if label == 'Money' then 
					local nameLab = offers[1][2];
					local amt = offers[1][3];
					TriggerServerEvent('PatreonDonatorPerks:GiveMoney', amt);
					Wait(500);
				end
				if label == 'Job' then 
					local nameLab = offers[1][2];
					local jobName = offers[1][3];
					local jobGrade = offers[1][4];
					TriggerServerEvent('PatreonDonatorPerks:GiveJob', jobName, jobGrade);
					Wait(500);
				end
				TriggerEvent('PatreonDonatorPerks:Client:RemoveFromStack');
			end
			if (IsControlJustPressed(0, 173)) then -- They pressed ARROW_DOWN 
				if label == 'Job' then 
					local jobName = offers[1][3];
					local jobGrade = offers[1][4];
					TriggerServerEvent('PatreonDonatorPerks:DenyJob', jobName, jobGrade);
				end
				TriggerEvent('PatreonDonatorPerks:Client:RemoveFromStack');
				Wait(500);
			end
		end
	end
end)

function Draw2DText(x, y, text, scale)
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    SetTextJustification(0)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
print("We get to bottom of client.lua");