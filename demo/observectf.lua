LUA_PATH = (LUA_PATH or package.path or "?;?.lua"); package.path = LUA_PATH
local NoxApi = require("noxapi")

-- Time in frames to switch flags
local switchFlagViewTimeout = 120
-- Table which contains all players that used /obsctf command
-- Hint: do not use raw table/pointer values to reference something in a long-term manner; use numbers instead
local obsPlayers = {}

local observeFlag = function(plr)
	-- Player must be in observer mode for CameraLock() to work properly
	if not plr:IsObserver() or not obsPlayers[plr:Id()] then return end
	local watching = plr:CameraTarget()
	
	for i = 1, 2 do
		-- Switch teams
		local team = NoxApi.Team:ById(i)
	
		if team ~= nil then -- Team exists
			local flag = team:GetFlag()
			
			if flag ~= nil and flag ~= watching then -- This team has a flag and it's not currently being watched
				local holder = flag:GetHolder() 
				
				if holder ~= watching or watching == nil then -- If we are not currently watching the flag holder
					if holder ~= nil then -- And if it is a valid object
						plr:CameraLock(holder)
					else
						plr:CameraLock(flag)
					end
					-- Lock on to this flag/player
					break 
				end
				-- Else switch to another team
			end
		end
	end
end

local switchFlags -- defined first b/c setTimeout call needs a valid reference
switchFlags = function()
	NoxApi.Player:IterateAll(observeFlag)
	setTimeout(switchFlags, switchFlagViewTimeout)
end

-- Enable observing the flags in CTF mode
if NoxApi.Util:CheckMapFlag(NoxApi.MAPFLAG_CTF) then 
	setTimeout(switchFlags, 1)
else
	NoxApi.Util:ConPrint("Not in CTF mode, exiting")
end

local function ctfEventHandler(name, args)
	if name == "PlayerLeave" or name == "PlayerStopObserving" then
		-- Mark as non-eligible for switching
		obsPlayers[args.player:Id()] = false
	elseif name == "PlayerChat" then
		if string.sub(args.text, 0, 7) == "/obsctf" then
			-- Make player observe flags, and vice versa
			if obsPlayers[args.player:Id()] then
				obsPlayers[args.player:Id()] = false
			else
				obsPlayers[args.player:Id()] = true
			end
			args.filter = true
		end
	elseif name == "MapSwitch" then
		-- Unload all script handlers when map changes!
		NoxApi.Server:UnregisterAllEvents()
		switchFlags = nil
	end
end

NoxApi.Server:RegisterEvent(ctfEventHandler)
NoxApi.Util:ConPrint("ObserveCtf load ok")