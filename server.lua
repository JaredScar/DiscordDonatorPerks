-------------------------------------
--- DiscordDonatorPerks by Badger ---
-------------------------------------

--- CONFIG ---
roleList = Config.RoleList;

--- CODE ---
ESX = nil;
QBCore = nil;
if (Config.Use_ESX) then 
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end);
else
	QBCore = exports['qb-core']:GetCoreObject(); 
end
function setPlayerJob(src, jobName, jobGrade)
	if (Config.Use_QBCore) then 
		local qbPlayer = QBCore.Functions.GetPlayer(src);
		qbPlayer.SetJob(jobName, jobGrade);
	else
		local xPlayer = ESX.GetPlayerFromId(src);
		xPlayer.setJob(jobName, tonumber(jobGrade));
	end
end
function setPlayerGang(src, gangName, gangGrade)
	if (Config.Use_QBCore) then 
		-- QBCore
		local qbPlayer = QBCore.Functions.GetPlayer(src);
		qbPlayer.SetJob(gangName, gangGrade);
	else 
		-- ESX
		local xPlayer = ESX.GetPlayerFromId(src);
		xPlayer.setJob(gangName, tonumber(gangGrade));
	end
end
function addPlayerMoney(src, money)
	if (Config.Use_QBCore) then 
		-- QBCore
		local qbPlayer = QBCore.Functions.GetPlayer(src);
		qbPlayer.AddMoney("cash", money, "DiscordDonatorPerks");
	else 
		-- ESX
		local xPlayer = ESX.GetPlayerFromId(src);
		xPlayer.addMoney(amount);
	end
end

RegisterNetEvent('PatreonDonatorPerks:OfferMoney')
AddEventHandler('PatreonDonatorPerks:OfferMoney', function(src, label, amount)
	-- Offer them their money
	-- {'Money', label, amount}
	TriggerClientEvent('Perksy', src, {'Money', label, amount});
end)
RegisterNetEvent('PatreonDonatorPerks:OfferJob')
AddEventHandler('PatreonDonatorPerks:OfferJob', function(src, label, jobName, jobGrade)
	-- Offer them their job 
	TriggerClientEvent('Perksy', src, {'job', label, jobName, jobGrade});
end)
RegisterNetEvent('PatreonDonatorPerks:DenyJob')
AddEventHandler('PatreonDonatorPerks:DenyJob', function(jobName, jobGrade)
	-- Check to see if they have value perk queued for this 
	local src = source;
	local steamID = ExtractIdentifiers(src).steam;
	-- table.insert(perkQueue[src], {offerDetails, rankName, i});
	local removeIndex = nil;
	if perkQueue[src] ~= nil then 
		-- They have valid perks to obtain 
		local perks = perkQueue[src];
		for i = 1, #perks do 
			-- Perks 
			local perkType = perks[i][1][1];
			if perkType:lower() == 'job' or perkType:lower() == 'gang' then 
				local perkJob = perks[i][1][2];
				local perkGrade = perks[i][1][3];
				if perkJob == jobName and jobGrade == perkGrade then 
					-- This is a valid request, give them it and remove this index 
					--xPlayer.setJob(jobName, tonumber(perkGrade));
					-- SQL 
					local rankName = perks[i][2];
					local perkID = perks[i][3];
					local datesOfPerks = MySQL.Sync.fetchAll('SELECT id FROM tebex_data WHERE identifier = "' ..
						steamID .. '" AND rankPackage = "' .. rankName .. '" AND acceptedPerkID = ' .. perkID); 
					local dateNow = os.time() + (60 * 60 * 24 * 30);
					if datesOfPerks ~= nil and #datesOfPerks > 1 then 
						-- They had this package last month 
						local patDataID = datesOfPerks[1].id;
						MySQL.Async.execute('UPDATE tebex_data SET dateReceiveNext = @date WHERE id = @patData', 
							{
								['@date'] = dateNow,
								['@patData'] = patDataID
							});
					else 
						-- Never had package, add it 
						MySQL.Async.execute('INSERT INTO tebex_data VALUES (@id, @ident, @playerName, @dateNext, @perkID, @rankPack)', {
							['@id'] = 0,
							['@ident'] = steamID,
							['@playerName'] = GetPlayerName(src),
							['@dateNext'] = dateNow,
							['@perkID'] = perkID,
							['@rankPack'] = rankName
						});
					end
					removeIndex = i;
					break;
				end
			end
		end
		local temp = {};
		for i = 1, #perks do 
			if i ~= removeIndex then 
				table.insert(temp, perks[i]);
			end
		end
		perkQueue[src] = temp;
	end
end)
RegisterNetEvent('PatreonDonatorPerks:GiveJob')
AddEventHandler('PatreonDonatorPerks:GiveJob', function(jobName, jobGrade)
	-- Check to see if they have value perk queued for this 
	local src = source;
	local steamID = ExtractIdentifiers(src).steam;
	-- table.insert(perkQueue[src], {offerDetails, rankName, i});
	local removeIndex = nil;
	if perkQueue[src] ~= nil then 
		-- They have valid perks to obtain 
		local perks = perkQueue[src];
		for i = 1, #perks do 
			-- Perks 
			local perkType = perks[i][1][1];
			if perkType:lower() == 'job' or perkType:lower() == 'gang' then 
				local perkJob = perks[i][1][2];
				local perkGrade = perks[i][1][3];
				if perkJob == jobName and jobGrade == perkGrade then 
					-- This is a valid request, give them it and remove this index 
					-- SQL 
					local rankName = perks[i][2];
					local perkID = perks[i][3];
					local datesOfPerks = MySQL.Sync.fetchAll('SELECT id FROM tebex_data WHERE identifier = "' ..
						steamID .. '" AND rankPackage = "' .. rankName .. '" AND acceptedPerkID = ' .. perkID); 
					local dateNow = os.time() + (60 * 60 * 24 * 30);
					if datesOfPerks ~= nil and #datesOfPerks > 1 then 
						-- They had this package last month 
						local patDataID = datesOfPerks[1].id;
						MySQL.Async.execute('UPDATE tebex_data SET dateReceiveNext = @date WHERE id = @patData', 
							{
								['@date'] = dateNow,
								['@patData'] = patDataID
							});
					else 
						-- Never had package, add it 
						MySQL.Async.execute('INSERT INTO tebex_data VALUES (@id, @ident, @playerName, @dateNext, @perkID, @rankPack)', {
							['@id'] = 0,
							['@ident'] = steamID,
							['@playerName'] = GetPlayerName(src),
							['@dateNext'] = dateNow,
							['@perkID'] = perkID,
							['@rankPack'] = rankName
						});
					end
					if (perkType:lower() == 'gang') then 
						setPlayerGang(src, jobName, tonumber(perkGrade));
					else 
						setPlayerJob(src, jobName, tonumber(perkGrade));
					end
					removeIndex = i;
					break;
				end
			end
		end
		local temp = {};
		for i = 1, #perks do 
			if i ~= removeIndex then 
				table.insert(temp, perks[i]);
			end
		end
		perkQueue[src] = temp;
	end
end)
RegisterNetEvent('PatreonDonatorPerks:GiveMoney')
AddEventHandler('PatreonDonatorPerks:GiveMoney', function(amount)
	-- Check to see if they have valid perk queued for this 
	local src = source;
	local steamID = ExtractIdentifiers(src).steam;
	-- table.insert(perkQueue[src], {offerDetails, rankName, i});
	local removeIndex = nil;
	if perkQueue[src] ~= nil then 
		-- They have valid perks to obtain 
		local perks = perkQueue[src];
		for i = 1, #perks do 
			-- Perks 
			local perkType = perks[i][1][1];
			if perkType == 'Money' then 
				local perkMoney = perks[i][1][2];
				if perkMoney == amount then 
					-- This is a valid request, give them it and remove this index 
					-- SQL 
					local rankName = perks[i][2];
					local perkID = perks[i][3];
					local datesOfPerks = MySQL.Sync.fetchAll('SELECT id FROM tebex_data WHERE identifier = "' ..
						steamID .. '" AND rankPackage = "' .. rankName .. '" AND acceptedPerkID = ' .. perkID); 
					local dateNow = os.time() + (60 * 60 * 24 * 30);
					if datesOfPerks ~= nil and #datesOfPerks > 1 then 
						-- They had this package last month 
						local patDataID = datesOfPerks[1].id;
						MySQL.Async.execute('UPDATE tebex_data SET dateReceiveNext = @date WHERE id = @patData', 
							{
								['@date'] = dateNow,
								['@patData'] = patDataID
							});
					else 
						-- Never had package, add it 
						MySQL.Async.execute('INSERT INTO tebex_data VALUES (@id, @ident, @playerName, @dateNext, @perkID, @rankPack)', {
							['@id'] = 0,
							['@ident'] = steamID,
							['@playerName'] = GetPlayerName(src),
							['@dateNext'] = dateNow,
							['@perkID'] = perkID,
							['@rankPack'] = rankName
						});
					end
					addPlayerMoney(src, amount);
					removeIndex = i;
					break;
				end
			end
		end
		local temp = {};
		for i = 1, #perks do 
			if i ~= removeIndex then 
				table.insert(temp, perks[i]);
			end
		end
		perkQueue[src] = temp;
	end
end)
perkQueue = {}
hasPerkAccess = {}
RegisterNetEvent('PatreonDonatorPerks:CheckPerks')
AddEventHandler('PatreonDonatorPerks:CheckPerks', function()
	local src = source;
	local identifierDiscord = ExtractIdentifiers(src).discord;
	local steamID = ExtractIdentifiers(src).steam; 
	if identifierDiscord then
		local roleIDs = exports.Badger_Discord_API:GetDiscordRoles(src)
		if not (roleIDs == false) then
			for i = 1, #roleList do
				for j = 1, #roleIDs do
					if (tostring(roleList[i][2]) == tostring(roleIDs[j])) then
						-- They have the role 
						-- Now check if they got their perks already 
						local maxPerks = #roleList[i] - 2;
						local rankName = roleList[i][1];
						local currentPerkCount = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM tebex_data WHERE ' ..
							'identifier = "' .. steamID .. '" AND rankPackage = "' .. rankName .. '"');
						if (currentPerkCount == nil or currentPerkCount < maxPerks) then 
							-- Offer them their perks
							hasPerkAccess[src] = true;
							if (perkQueue[src] == nil) then 
								perkQueue[src] = {};
							end
							--[[
									1                2                        ((1))      (3)      ((2))
								{"Bronze-Tier", 698239215388983417, {"$1,000,000 voucher", {'Money', 1000000} } }, -- Bronze Tier 
							]]--
							for k = 3, #roleList[i] do 
								-- These are the offers 
								local offer = roleList[i][k]; -- (Offer)
								local offerName = offer[1]; -- ((1))
								local offerDetails = offer[2]; -- ((2))
								table.insert(perkQueue[src], {offerDetails, rankName, (k - 2)});
								for l = 1, #offer do 
									local offerEvent = offer[l];
									if type(offerEvent) == 'table' then 
										if offerEvent[1]:lower() == 'job' or offerEvent[1]:lower() == 'gang' then 
											-- Give them job 2 args 
											TriggerEvent('PatreonDonatorPerks:OfferJob', src, offerName, offerEvent[2], offerEvent[3]);
										end
										if offerEvent[1] == 'Money' then 
											-- Give them money 1 args 
											TriggerEvent('PatreonDonatorPerks:OfferMoney', src, offerName, offerEvent[2]);
										end 
									end
								end 
							end
							-- We have finished giving them the offers
						else 
							-- Check if the month has pasted and if so, update the date and offer perks
							local datesOfPerks = MySQL.Sync.fetchAll('SELECT dateReceiveNext, id FROM tebex_data WHERE identifier = "' ..
								steamID .. '" AND rankPackage = "' .. rankName .. '"'); 
							local dateNow = os.time();
							for kk = 1, #datesOfPerks do 
								local dateReceiveNext = datesOfPerks[kk].dateReceiveNext;
								local id = datesOfPerks[kk].id;
								if (dateReceiveNext <= dateNow) then 
									-- Offer perks 
									--[[
											1                2                        ((1))      (3)      ((2))
										{"Bronze-Tier", 698239215388983417, {"$1,000,000 voucher", {'Money', 1000000} } }, -- Bronze Tier 
									]]--
									for k = 3, #roleList[i] do 
										-- These are the offers 
										local offer = roleList[i][k]; -- (Offer)
										local offerName = offer[1]; -- ((1))
										local offerDetails = offer[2]; -- ((2))
										table.insert(perkQueue[src], {offerDetails, rankName, (k - 2)});
										for l = 1, #offer do 
											local offerEvent = offer[l];
											if type(offerEvent) == 'table' then 
												if offerEvent[1]:lower() == 'job' or offerEvent[1]:lower() == 'gang' then 
													-- Give them job 2 args 
													TriggerEvent('PatreonDonatorPerks:OfferJob', src, offerName, offerEvent[2], offerEvent[3]);
												end
												if offerEvent[1] == 'Money' then 
													-- Give them money 1 args 
													TriggerEvent('PatreonDonatorPerks:OfferMoney', src, offerName, offerEvent[2]);
												end 
											end
										end
									end
								end
							end
						end
					end
				end
			end 
		else
			print("[PatreonDonatorPerks] " .. GetPlayerName(src) .. " has not gotten their donator role checked cause roleIDs == false")
		end
	else
		print("[PatreonDonatorPerks] " .. GetPlayerName(src) .. " has not gotten their (possible) donator perks cause their discord was not detected...")
	end
	-- We update their name in MySQL down here 
	MySQL.Async.execute('UPDATE tebex_data SET playerName = @pname WHERE identifier = @sid', {['@pname'] = GetPlayerName(src), ['@sid'] = steamID});
end)

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end
