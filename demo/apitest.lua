LUA_PATH = (LUA_PATH or package.path or "?;?.lua"); package.path = LUA_PATH
NoxApi = require("noxapi")

-- Get host player
plr = NoxApi.Player:ById(31)
if plr ~= nil then
	plr:GetObject():SayChat("API test; My name is " .. plr:CharName())
	
	-- Create magic apple
	magicapple = NoxApi.Object:CreateIn("RedApple", plr:GetObject())
	-- Use unsafe pointer to register legacy Unimod event
	unitOnDrop(magicapple.ptr, function(what, who)
		who = NoxApi.Object:Init(who) -- Initialize from unsafe pointer
		if who ~= nil then -- If object really exists...
			-- Fix for duplicate wizards
			-- (game thinks that apple is still inside your inventory if you die from death ray)
			if who:CurrentHealth() <= 0 then return end 
			-- Damage the owner if dropped
			who:Damage(50, "ZAP_RAY")
			
			-- Make a wizard 
			wiz = NoxApi.Object:CreateAt("Wizard", who:Position())
			-- Initialize (or else our spells will be overriden one frame later)
			--NoxApi.Object:FinalizeCreation() -- now NoxApi framework does that automatically
			
			-- Leave only death ray spell
			for i = 1, 137 do
				wiz:NPCSpell(i, 0)
			end
			wiz:NPCSpell(16, "NPC_OFFENSE")
			-- 100% accuracy
			wiz:MonsterInfo({ aimSkill = 1, offensiveTimeoutMin = 5, offensiveTimeoutMax = 10 })
			-- He knows where you are
			wiz:SetEnemy(who)
			-- And he is deadly
			wiz:PushActionStack("CAST_SPELL_ON_OBJECT", "SPELL_DEATH_RAY", who)
			wiz:PushActionStack("CAST_SPELL_ON_OBJECT", "SPELL_SHIELD", wiz)
		end
	end)
	unitOnPickup(magicapple.ptr, function(what, who)
		who = NoxApi.Object:Init(who)
		if who ~= nil then
			who:BuffApply("ENCHANT_INVULNERABLE", 60)
		end
	end)
end

-- Test Events
local function myEventHandler(name, args)
	if name == "PlayerStartObserving" then
		local obj = args.player:GetObject()
		if obj ~= nil then
			obj:SayChat("I'm observing now")
			-- You can call native Unimod functions, while referencing safe NoxApi objects by using .ptr field
			unitDropAll(obj.ptr)
		end
	elseif name == "PlayerDeath" then
		local obj = args.player:GetObject()
		if obj ~= nil then
			obj:SayChat("I died :(")
		end
	end
	
	-- Unload all script handlers when map changes!
	if name == "MapSwitch" then
		NoxApi.Server:UnregisterAllEvents()
	end
end

NoxApi.Server:RegisterEvent(myEventHandler)
NoxApi.Server:SetMusic(7, 50)

-- Print debug info
NoxApi.Util:Debug()
-- Print current map name and gamemode
local gm = NoxApi.Util:GetGameInfo()
NoxApi.Util:ConPrint(string.format("Map: %s, mode: %s", gm.mapname, gm.gamemode))

