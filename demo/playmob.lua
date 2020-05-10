LUA_PATH = (LUA_PATH or package.path or "?;?.lua"); package.path = LUA_PATH
NoxApi = require("noxapi")

if NoxApi.Version < 5 then NoxApi.Util:ConPrint("[playmob] Error: unsupported NoxApi version, required >= 5") return end

-- Table that contains monsters referenced by player ID's
local PlayerToMonster = {}
-- Table that contains monster extra data referenced by player ID's
local PlayerToExtra = {}
-- Definitions for local functions
local PlayerIsMonster, MonsterOnDie, PlayerTurnMonster, PlayerRemoveMonster, PlayerHandleInput, RemoveInputHandlers, eventHandler
-- Enable debug?
local d = false
local function dp(msg)
	if d then NoxApi.Util:ConPrint("[playmob] " .. msg, 9) end
end

-- Returns true if player is currently a monster
function PlayerIsMonster(plr)
	if PlayerToMonster[plr:Id()] ~= nil then return true end
	return false
end

-- Turns player to play as a monster
function PlayerTurnMonster(plr, monname)
	dp("PlayerTurnMonster")
	-- Player already controls monster 
	if PlayerIsMonster(plr) then return nil end
	
	local p_obj = plr:GetObject()
	if p_obj == nil then return nil end
	
	local m_obj = NoxApi.Object:CreateAt(monname, p_obj:Position())
	m_obj:MonsterInfo({ fleeDistance = 0, retreatCoeff = 0, aggressiveness = 0})
	m_obj:BecomePet(p_obj)
	unitOnDie(m_obj.ptr, MonsterOnDie)
	plr:ObserveMonster(m_obj)
	PlayerToMonster[plr:Id()] = m_obj
	PlayerToExtra[plr:Id()] = { n = m_obj:ThingName() }
	
	p_obj:SetFlag("NO_COLLIDE", true)
	p_obj:BuffApply("INVULNERABLE", 0)
	p_obj:BuffApply("INVISIBLE", 0)
	playerOnInput[p_obj.ptr] = PlayerHandleInput
end

-- Despawns monster and frees player control
function PlayerRemoveMonster(plr)
	dp("PlayerRemoveMonster")
	if not PlayerIsMonster(plr) then return nil end
	RemoveInputHandlers(plr)
	
	local p_obj = plr:GetObject()
	if p_obj == nil then return nil end
	
	local m_obj = PlayerToMonster[plr:Id()]
	if m_obj:Exists() then
		m_obj:DeleteDelayed(60)
		plr:ObserveMonster(nil)
	end
	PlayerToMonster[plr:Id()] = nil
	
	p_obj:SetFlag("NO_COLLIDE", false)
	p_obj:BuffRemove("INVULNERABLE")
	p_obj:BuffRemove("INVISIBLE")
end

-- Removes player handlers for monster
function MonsterOnDie(obj)
	dp("MonsterOnDie")
	local obj = NoxApi.Object:Init(obj)
	
	for k, v in pairs(PlayerToMonster) do
		if obj == v then
			PlayerRemoveMonster(NoxApi.Player:ById(k))
			return
		end
	end
end

-- Player input handler
function PlayerHandleInput(plr, c)
	-- wrap pointer 
	plr = NoxApi.Object:Init(plr):GetPlayer()
	
	local mx, my = plr:MousePos()
    local fram = getFrameCounter()
	local mob = PlayerToMonster[plr:Id()]
	local ox, oy = mob:Position()
	local ca = mob:GetCurrentAction()
	local xd = PlayerToExtra[plr:Id()]
	
	if xd.input == nil then xd.input = fram end
	mob:BuffRemove("CHARMING") -- Fix for charming enemy monsters

	if c == 1 and fram - xd.input >= 2 and (ca == 0 or ca == NoxApi.ACTION_MELEE_ATTACK) then 
		--xd.input = fram
		-- look
		mob:Direction(directGet(mx, my, ox, oy))
	elseif c == 2 and fram - xd.input >= 5 then 
		xd.input = fram
		-- move
		mob:Direction(directGet(mx, my, ox, oy))
		mob:PopActionStack()
		mob:PushActionStack("DODGE", mx, my)
		-- play step audio
        ptrCall2(0x534030, mob.ptr, mob.ptr)
	elseif c == 6 then 
		-- attack
		if xd.n == "Wolf" and fram - xd.input >= 13 then
			xd.input = fram
			mob:PopActionStack()
			mob:PushActionStack("MELEE_ATTACK", mx, my)
		end
		if xd.n == "Archer" and fram - xd.input >= 18 then
			xd.input = fram
			mob:PopActionStack()
			mob:PushActionStack("MISSILE_ATTACK", mx, my)
		end
		if xd.n == "WizardWhite" and fram - xd.input >= 20 then
			xd.input = fram
			mob:PopActionStack()
			mob:PushActionStack("CAST_SPELL_ON_LOCATION", "CHAIN_LIGHTNING", mx, my)
		end
	elseif c == 47 then 
		-- use first ability
        if xd.n == "WizardWhite" and fram - xd.input >= 20 then
			xd.input = fram
			mob:PopActionStack()
			mob:PushActionStack("CAST_SPELL_ON_LOCATION", "TELEPORT_TO_TARGET", mx, my)
		end
		
	elseif c == 49 then 
		-- use second ability
		if xd.n == "WizardWhite" and fram - xd.input >= 20 then
			xd.input = fram
			mob:PopActionStack()
			mob:PushActionStack("CAST_SPELL_ON_OBJECT", "LESSER_HEAL", mob)
		end
	elseif c == 48 then 
		-- use third ability
		if xd.n == "Archer" and fram - xd.input >= 20 then
			xd.input = fram
			mob:BuffApply("INVISIBLE", NoxApi.Util:GetGameFPS() * 5)
		end
		if xd.n == "WizardWhite" and fram - xd.input >= 20 then
			xd.input = fram
			mob:PopActionStack()
			mob:PushActionStack("CAST_SPELL_ON_OBJECT", "SHIELD", mob)
		end
		
	end
	
	-- Don't walk infinitely long
	if fram - xd.input >= 9 and ca == NoxApi.ACTION_DODGE then
		mob:PopActionStack()
	end

	return true
end

-- Removes input handler for player
function RemoveInputHandlers(plr)
	dp("RemoveInputHandlers")
	playerOnInput[plr:GetObject().ptr] = nil
end

function eventHandler(name, args)
	if name == "PlayerLeave" or name == "PlayerStartObserving" then
		if PlayerIsMonster(args.player) then
			PlayerRemoveMonster(args.player)
		end
	elseif name == "PlayerJoin" then
		-- Safeguard
		if PlayerIsMonster(args.player) then
			PlayerToMonster[args.player:Id()] = nil
			NoxApi.Util:ConPrint("[playmob] Warning: player cleanup was not complete")
		end
	elseif name == "PlayerChat" then
		--dp("Chat: " .. args.text)
		if string.sub(args.text, 0, 8) == "/monster" then
			args.filter = true
			if PlayerIsMonster(args.player) then
				PlayerRemoveMonster(args.player)
				return
			end
		
			-- Find monster name
			local mname = string.sub(args.text, 10)
			-- Set lower case
			if mname ~= nil then mname = string.lower(mname) end
			dp(mname)
			if mname ~= "wolf" and mname ~= "wizardwhite" and mname ~= "archer" then return end

			PlayerTurnMonster(args.player, mname)
		end
	elseif name == "MapSwitch" then
		NoxApi.Player:IterateAll(PlayerRemoveMonster)
	end
end

NoxApi.Server:RegisterEvent(eventHandler)
dp("Loaded")