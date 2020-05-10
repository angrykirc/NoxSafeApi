LUA_PATH = (LUA_PATH or package.path or "?;?.lua"); package.path = LUA_PATH
NoxApi = require("noxapi")

if NoxApi.Version < 6 then NoxApi.Util:ConPrint("[inv] Error: unsupported NoxApi version, required >= 6") return end

-- If true, script will save and restore amount of money the player has
local saveGold = true
-- If true, the player inventory is first cleaned before loading items
local clearPlayerInventory = true

-- The file we are writing to or reading from
local playerFile
-- file i/o helper functions
local rwint, rwstr
-- Definitions for local functions
local eventHandler, CheckFolder, OpenPlayerFile, ClosePlayerFile, SavePlayerInventory, LoadPlayerInventory, WriteObject, ReadObject
-- Enable debug?
local d = false
local function dp(msg)
	if d then NoxApi.Util:ConPrint("[inv] " .. msg, 9) end
end

function rwint(val)
    if val ~= nil then
        playerFile:write(val)
        playerFile:write("\n")
    else
        val = playerFile:read("*n")
        playerFile:read(1) -- skip nullterm
        return val
    end
end

function rwstr(val)
    if val ~= nil then
        playerFile:write(val)
        playerFile:write("\n")
    else
        return playerFile:read("*l")
    end
end

function CheckFolder()
    local t = getDirectoryListing(".")
    for _, v in pairs(t) do
        if v.directory and v.name == "inv" then return true end
    end
    NoxApi.Util:ConPrint("[inv] Error: directory 'inv' does not exist. Please create it before using the script")
    return false
end

function OpenPlayerFile(plr, mode)
    if not CheckFolder() then return end
    
    local path = getNormalizedPath(string.format(".\\inv\\%s_%s.dat", plr:CharName(), plr:GetInfo().className))
    dp("fopen: " .. path)
    playerFile = io.open(path, mode)
end

function WriteObject(obj)
    -- write thing name
    rwstr(obj:ThingName())
    
    -- write equipped flag
    if obj:CheckFlag("EQUIPPED") then
        rwint(1)
    else
        rwint(0)
    end
    
    -- write health
    local durability = obj:CurrentHealth()
    if durability == nil then
        rwint(-1)
    else
        rwint(durability)
    end
    
    -- write enchants (if applicable)
    if obj:CheckClass("WEAPON") or obj:CheckClass("ARMOR") or obj:CheckClass("WAND") then
        rwint(1)
        
        -- write wand/quiver charges
        if obj:CheckClass("WAND") or obj:GetWeaponType() == 2 then
            rwint(1)
            rwint(obj:AmmoCharges())
            rwint(obj:AmmoMaxCharges())
        else
            rwint(0)
        end
        
        local es = obj:Enchants()
        
        for i = 1, 4 do
            local en = es[i]
            if type(en) == "string" then
                rwstr(en)
            else
                rwstr("")
            end
        end
    else
        rwint(0)
    end
end

function SavePlayerInventory(plr)
    local p_obj = plr:GetObject()
    if p_obj:IsDead() then dp(string.format("Cannot save inventory for %s: Player is dead", plr:CharName())) return end
    
    rwstr("PINV")
    rwstr("ITEM")
    local count_pos = playerFile:seek()
    -- write number of items
    -- not the fastest variation, but Lua's seek() is just bad
    playerFile:write(p_obj:IterateInventory(nil))
    playerFile:write("\n")
    
    local items = p_obj:IterateInventory(WriteObject)
    dp(string.format("written %d items", items))
    
    if saveGold then
        rwstr("GOLD")
        rwint(plr:Gold())
    end
end

function ReadObject(p_obj)
    local name = rwstr()
    local eq = rwint()
    local durability = rwint()
    local ench = rwint()
    
    -- FIXME: objects created this way will NOT have enchantments shown in the inventory
    --local n_obj = NoxApi.Object:CreateIn(name, p_obj)
    local n_obj = NoxApi.Object:CreateAt(name, 0, 0)

    -- Read and set enchants first, because Nox differentiates mundane and enchanted items
    if ench > 0 then
        -- read ammo charges
        local ammo = rwint()
        if ammo > 0 then
            n_obj:AmmoCharges(rwint())
            n_obj:AmmoMaxCharges(rwint())
            dp(string.format("%s charges: %d", n_obj:ThingName(), n_obj:AmmoCharges()))
        end
        
        local t = {}
        for i = 1, 4 do table.insert(t, rwstr()) end
        n_obj:Enchants(t)
    end
    
    if durability >= 0 then
        n_obj:CurrentHealth(durability)
    end
     
    p_obj:InvPut(n_obj) 

    if eq > 0 then
        p_obj:TryEquip(n_obj)
    end
end

function LoadPlayerInventory(plr)
    local p_obj = plr:GetObject()
    if p_obj:IsDead() then dp(string.format("Cannot save inventory for %s: Player is dead", plr:CharName())) return end
    
    if rwstr() ~= "PINV" then
        dp("Wrong playerinventory file header!")
        return
    end
    
    -- Process file
    local head = nil
    repeat
        head = rwstr()
        
        if head == "ITEM" then
            -- item section
            if clearPlayerInventory then
                p_obj:IterateInventory(function(obj) obj:DeleteInstant() end)
                -- Items will be actually removed from inventory only one frame later, so the game will print "DuplicateArmor" message
            end
            
            local count = rwint()
            dp("items stored: " .. count)
            
            for i = 1, count do 
                ReadObject(p_obj)
            end
        elseif head == "GOLD" then
            -- money section
            local gold = rwint()
            if saveGold then plr:Gold(gold) end
        end
        
    until head ~= nil
end

function ClosePlayerFile()
    if playerFile ~= nil then
        playerFile:close()
        playerFile = nil
        dp("fclose")
    end
end

function eventHandler(name, args)
    if name == "PlayerChat" then
        local chars = string.sub(args.text, 0, 8)
        
        if chars == "/invsave" then
            args.filter = true

            OpenPlayerFile(args.player, "w+")
            SavePlayerInventory(args.player)
            ClosePlayerFile()
        elseif chars == "/invload" then
            args.filter = true

            OpenPlayerFile(args.player, "r")
            LoadPlayerInventory(args.player)
            ClosePlayerFile()
        end
    end
end

NoxApi.Server:RegisterEvent(eventHandler)
dp("Loaded")