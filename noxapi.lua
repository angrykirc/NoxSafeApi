-- Game logic safe abstractions layer [WORK IN PROGRESS]
-- by KirConjurer aka AngryKirC

-- [BEGIN] Tables/namespaces

-- If already initialized, return cached instance
-- this way events won't get messed up, and everything is just nice and correct
if type(package.loaded["noxapi"]) == "table" then return package.loaded["noxapi"] end

local NoxApi = {}
NoxApi.Object = {} -- metatable
NoxApi.Monster = {} -- metatable
NoxApi.Player = {} -- metatable
NoxApi.Team = {}
NoxApi.Server = {}
NoxApi.Util = {} -- alias for Client
-- Waypoint/Journal WIP

-- Code compatibility marker
NoxApi.Version = 6
-- Set this to true, if you want to trade stability for performance
NoxApi.DisableTableCheck = false

-- [END] Tables/namespaces

-- [BEGIN] NoxApi enumerations

-- Player status flags
NoxApi.PLRSTATUS_OBSERVE_PLR = 1
NoxApi.PLRSTATUS_OBSERVE_CREATURE = 2
NoxApi.PLRSTATUS_MUTED_SYS = 4
NoxApi.PLRSTATUS_MUTED = 8
NoxApi.PLRSTATUS_IN_GAME = 0x10
NoxApi.PLRSTATUS_JOINING = 0x20
NoxApi.PLRSTATUS_NEED_TIMESTAMP = 0x40
NoxApi.PLRSTATUS_RATE_FAILURE = 0x80
NoxApi.PLRSTATUS_JUST_JOINED = 0x100
NoxApi.PLRSTATUS_DIALOG = 0x200
NoxApi.PLRSTATUS_POISONED = 0x400

-- Journal entry flags
NoxApi.JOURNAL_GENERIC = 0
NoxApi.JOURNAL_NORMAL = 1
NoxApi.JOURNAL_QUEST = 2
NoxApi.JOURNAL_COMPLETED = 4
NoxApi.JOURNAL_HINT = 8

-- Spell flags
NoxApi.SFLAG_NPC_ESCAPE = 0x80000000
NoxApi.SFLAG_NPC_OFFENSE = 0x40000000
NoxApi.SFLAG_NPC_CURSE = 0x20000000
NoxApi.SFLAG_NPC_DEFENSE = 0x10000000
NoxApi.SFLAG_NPC_REACTION = 0x08000000

-- Global game flags
NoxApi.GFLAG_SHOW_EXTENTS = 0x2
NoxApi.GFLAG_AI_DEBUG = 0x8
NoxApi.GFLAG_GODMODE = 0x20
NoxApi.GFLAG_DEBUG = 0x1000
NoxApi.GFLAG_NO_TEXT = 0x10000
NoxApi.GFLAG_SERVERONLY = 0x40000
NoxApi.GFLAG_NO_FLOOR = 0x100000
NoxApi.GFLAG_LOG1 = 0x800000
NoxApi.GFLAG_OFFICIAL = 0x1000000
NoxApi.GFLAG_LOG2 = 0x20000000

-- Server Rule Flags
NoxApi.RFLAG_WEAPONS = 0x1
NoxApi.RFLAG_WEAPONSRESPAWN = 0x2
NoxApi.RFLAG_MONSTERS = 0x4
NoxApi.RFLAG_MONSTERRESPAWN = 0x8
NoxApi.RFLAG_STAVES = 0x10
NoxApi.RFLAG_CAMPER_ALARM = 0x2000

-- Monster status flags
NoxApi.MS_DESTROY_WHEN_DEAD = 0x1
NoxApi.MS_CHECK = 0x2
NoxApi.MS_CAN_BLOCK = 0x4
NoxApi.MS_CAN_DODGE = 0x8
NoxApi.MS_unused = 0x10
NoxApi.MS_CAN_CAST_SPELLS = 0x20
NoxApi.MS_HOLD_YOUR_GROUND = 0x40
NoxApi.MS_SUMMONED = 0x80
NoxApi.MS_ALERT = 0x100
NoxApi.MS_INJURED = 0x200
NoxApi.MS_CAN_SEE_FRIENDS = 0x400
NoxApi.MS_CAN_HEAL_SELF = 0x800
NoxApi.MS_CAN_HEAL_OTHERS = 0x1000
NoxApi.MS_CAN_RUN = 0x2000
NoxApi.MS_RUNNING = 0x4000
NoxApi.MS_ALWAYS_RUN = 0x8000
NoxApi.MS_NEVER_RUN = 0x10000
NoxApi.MS_MORPHED = 0x20000
NoxApi.MS_ON_FIRE = 0x40000
NoxApi.MS_STAY_DEAD = 0x80000
NoxApi.MS_FRUSTRATED = 0x100000

-- Monster actions
NoxApi.ACTION_IDLE = 0
NoxApi.ACTION_WAIT = 1
NoxApi.ACTION_WAIT_RELATIVE = 2
NoxApi.ACTION_ESCORT = 3
NoxApi.ACTION_GUARD = 4
NoxApi.ACTION_HUNT = 5
NoxApi.ACTION_RETREAT = 6
NoxApi.ACTION_MOVE_TO = 7
NoxApi.ACTION_FAR_MOVE_TO = 8
NoxApi.ACTION_DODGE = 9
NoxApi.ACTION_ROAM = 10
NoxApi.ACTION_PICKUP_OBJECT = 11
NoxApi.ACTION_DROP_OBJECT = 12
NoxApi.ACTION_FIND_OBJECT = 13
NoxApi.ACTION_RETREAT_TO_MASTER = 14
NoxApi.ACTION_FIGHT = 15
NoxApi.ACTION_MELEE_ATTACK = 16
NoxApi.ACTION_MISSILE_ATTACK = 17
NoxApi.ACTION_CAST_SPELL_ON_OBJECT = 18
NoxApi.ACTION_CAST_SPELL_ON_LOCATION = 19
NoxApi.ACTION_CAST_DURATION_SPELL = 20
NoxApi.ACTION_BLOCK_ATTACK = 21
NoxApi.ACTION_BLOCK_FINISH = 22
NoxApi.ACTION_WEAPON_BLOCK = 23
NoxApi.ACTION_FLEE = 24
NoxApi.ACTION_FACE_LOCATION = 25
NoxApi.ACTION_FACE_OBJECT = 26
NoxApi.ACTION_FACE_ANGLE = 27
NoxApi.ACTION_SET_ANGLE = 28
NoxApi.ACTION_RANDOM_WALK = 29
NoxApi.ACTION_DYING = 30
NoxApi.ACTION_DEAD = 31
NoxApi.ACTION_REPORT = 32
NoxApi.ACTION_MORPH_INTO_CHEST = 33
NoxApi.ACTION_MORPH_BACK_TO_SELF = 34
NoxApi.ACTION_GET_UP = 35
NoxApi.ACTION_CONFUSED = 36
NoxApi.ACTION_MOVE_TO_HOME = 37
NoxApi.ACTION_INVALID = 38

-- Map/gamemode flags
NoxApi.MAPFLAG_SERVER = 1 -- IS NOT SET in Solo games!
NoxApi.MAPFLAG_COMMENCING = 2
NoxApi.MAPFLAG_TEAMS = 4
NoxApi.MAPFLAG_UNK_8 = 8
NoxApi.MAPFLAG_KOTR = 0x10
NoxApi.MAPFLAG_CTF = 0x20
NoxApi.MAPFLAG_FLAGBALL = 0x40
NoxApi.MAPFLAG_CHAT = 0x80
NoxApi.MAPFLAG_DEATHMATCH = 0x100
NoxApi.MAPFLAG_COOP = 0x200
NoxApi.MAPFLAG_ELIM = 0x400
NoxApi.MAPFLAG_SOLO = 0x800
NoxApi.MAPFLAG_GAUNTLET = 0x1000
NoxApi.MAPFLAG_MULTIPLAYER = 0x2000
NoxApi.MAPFLAG_NOSOUNDS = 0x80000
NoxApi.MAPFLAG_SUDDEN = 0x4000000 -- Sudden Death

-- Damage types
NoxApi.DAMAGE_BLADE = 0 -- weapons
NoxApi.DAMAGE_FLAME = 1 -- FlameX, Fireball
NoxApi.DAMAGE_CRUSH = 2 -- Bear, Golem
NoxApi.DAMAGE_IMPALE = 3 -- Halberd, Wasp
NoxApi.DAMAGE_DRAIN = 4 -- Ghost, Shade
NoxApi.DAMAGE_POISON = 5 -- Poison, Toxic cloud
NoxApi.DAMAGE_DISPEL_UNDEAD = 6 -- Dispel undead
NoxApi.DAMAGE_EXPLOSION = 7 -- BlackPowderBarrel explosions
NoxApi.DAMAGE_BITE = 8 -- Spiders, Wolves
NoxApi.DAMAGE_ELECTRIC = 9 -- Lightning?
NoxApi.DAMAGE_CLAW = 10 -- EmberDemon
NoxApi.DAMAGE_IMPACT = 11 -- Ogres, Troll, Hammer?
NoxApi.DAMAGE_LAVA = 12 -- Lava tiles
NoxApi.DAMAGE_DEATH_MAGIC = 13 -- Death spell
NoxApi.DAMAGE_PLASMA = 14 -- Plasma spell (Staff of Oblivion)
NoxApi.DAMAGE_MANA_BOMB = 15 -- Mana Bomb spell
NoxApi.DAMAGE_ZAP_RAY = 16 -- Death Ray spell
NoxApi.DAMAGE_AIRBORNE_ELECTRIC = 17 -- unknown

-- Object flags
NoxApi.OF_BELOW = 0x1 -- object does not collide with airborne units
NoxApi.OF_NO_UPDATE = 0x2 -- O is ignored while executing update queue
NoxApi.OF_ACTIVE = 0x4 -- UNKNOWN
NoxApi.OF_ALLOW_OVERLAP = 0x8 -- O will not be pushed upon collision with obstacles (effects, decorations)
NoxApi.OF_SHORT = 0x10 -- Jumping PC and airborne objects will not collide with O
NoxApi.OF_DESTROYED = 0x20 -- O is going to be removed next frame
NoxApi.OF_NO_COLLIDE = 0x40 -- O ignores collisions with anything (static decorations)
NoxApi.OF_MISSILE_HIT = 0x80 -- O triggers missile collisions
NoxApi.OF_EQUIPPED = 0x100 -- O is being worn by NPC or PC, any armor/weapons for example
NoxApi.OF_PARTITIONED = 0x200 -- UNKNOWN
NoxApi.OF_NO_COLLIDE_OWNER = 0x400 -- O does not collide with its parent
NoxApi.OF_OWNER_VISIBLE = 0x800 -- O is only visible to its parent (TeleportGlyphX)
NoxApi.OF_EDIT_VISIBLE = 0x1000 -- O with OWNER_VISIBLE / EDIT_VISIBLE will not render at all, even with show extents mode enabled
NoxApi.OF_NO_PUSH_CHARACTERS = 0x2000 -- O does not collide with PC
NoxApi.OF_AIRBORNE = 0x4000 -- O ignores collision with some objects
NoxApi.OF_DEAD = 0x8000 -- O is a monster/PC and is dead; used for various tests
NoxApi.OF_SHADOW = 0x10000 -- O blocks PC's line of sight; examples ColumnX, StoneBlock, Boulder
NoxApi.OF_FALLING = 0x20000 -- UNKNOWN, probably related to Pits
NoxApi.OF_IN_HOLE = 0x40000 -- UNKNOWN, probably related to Pits
NoxApi.OF_RESPAWN = 0x80000 -- O is added in respawn list upon creation (only in MP)
NoxApi.OF_ON_OBJECT = 0x100000 -- fall logic related - prevents smth
NoxApi.OF_SIGHT_DESTROY = 0x200000 -- UNKNOWN
NoxApi.OF_TRANSIENT = 0x400000 -- decaying object
NoxApi.OF_BOUNCY = 0x800000 -- obj has special fall logic
NoxApi.OF_ENABLED = 0x1000000 -- O is in "active" state (valid only for interactive objects - elevators, buttons...)
NoxApi.OF_PENDING = 0x2000000 -- set on recently created O's, probably forces MSG_SIMPLE_OBJECT
NoxApi.OF_TRANSLUCENT = 0x4000000 -- UNKNOWN, probably something related to lighting system
NoxApi.OF_STILL = 0x8000000 -- UNKNOWN
NoxApi.OF_NO_AUTO_DROP = 0x10000000 -- O does not drop upon death of its current holder; example OblivionOrb
NoxApi.OF_FLICKER = 0x20000000 -- UNKNOWN, something related to projectiles
NoxApi.OF_SELECTED = 0x40000000
NoxApi.OF_MARKED = 0x80000000

-- Object class flags
NoxApi.OC_MISSILE = 0x1 -- O is treated as projectile (some special update/collision handling)
NoxApi.OC_MONSTER = 0x2 -- O is treated as monster, used mostly in validating
NoxApi.OC_PLAYER = 0x4 -- O represents player in game world. (NewPlayer, PhantomPlayer, Player, PlayerFemale)
NoxApi.OC_OBSTACLE = 0x8 -- O blocks movement, used mostly in monster AI code for static decorations
NoxApi.OC_FOOD = 0x10 -- O is a useful healing item, used in monster AI (ACTION_RETREAT)
NoxApi.OC_EXIT = 0x20 -- O is level finish (exit) point, examples: ExitX, TeleporterExit, PitExit
NoxApi.OC_KEY = 0x40 -- O is a key used for opening locked doors
NoxApi.OC_DOOR = 0x80 -- Object is a door
NoxApi.OC_INFO_BOOK = 0x100 -- O is a spell book or field guide
NoxApi.OC_TRIGGER = 0x200 -- O executes some event upon interaction (Buttons, levers, pressure plates, wells)
NoxApi.OC_TRANSPORTER = 0x400 -- O is used for instant travelling (TeleportPentagram, TeleportExitStoneX)
NoxApi.OC_HOLE = 0x800 -- PitCrumblingFloor / ForestPit
NoxApi.OC_WAND = 0x1000 -- O is a weapon for magic users (InfinitePainWand, LesserFireballWand, ForceWand...)
NoxApi.OC_FIRE = 0x2000 -- O is an instance of fire (Flame, FlameCleanse, BlueFlame...)
NoxApi.OC_ELEVATOR = 0x4000 -- XElevator, never (?) used in code
NoxApi.OC_ELEVATOR_SHAFT = 0x8000 -- XElevatorPit
NoxApi.OC_DANGEROUS = 0x10000 -- Marks O as dangerous for AI, used for pathfinding
NoxApi.OC_MONSTERGENERATOR = 0x20000 -- XGenerator
NoxApi.OC_READABLE = 0x40000 -- Various signs, never used in code
NoxApi.OC_LIGHT = 0x80000 -- Object is a light source
NoxApi.OC_SIMPLE = 0x100000 -- Most objects have this in declaration. MSG_SIMPLE_OBJ contains netID and obj position
NoxApi.OC_COMPLEX = 0x200000 -- Like SIMPLE, but used only (?) for monsters; MSG_COMPLEX_OBJ also contains animation frame
NoxApi.OC_IMMOBILE = 0x400000 -- Used for static decorations. Objects with this class are only synchronized with clients by special packets (MSG_DOOR_ANGLE)
NoxApi.OC_VISIBLE_ENABLE = 0x800000 -- Object is only rendered if "ENABLED" flag set
NoxApi.OC_WEAPON = 0x1000000 -- 
NoxApi.OC_ARMOR = 0x2000000 -- 
NoxApi.OC_NOT_STACKABLE = 0x4000000 -- Multiple objects do not stack in inventory, any WEAPON/ARMOR has this
NoxApi.OC_TREASURE = 0x8000000 -- Object is used in Scavenger Hunt game mode
NoxApi.OC_FLAG = 0x10000000 -- Object is a flag used in CTF game mode
NoxApi.OC_CLIENT_PERSIST = 0x20000000 -- 
NoxApi.OC_CLIENT_PREDICT = 0x40000000 --
NoxApi.OC_PICKUP = 0x80000000 --

-- Some network messages
NoxApi.MSG_FX_PARTICLEFX = 0x7C
NoxApi.MSG_FX_PLASMA = 0x7D
NoxApi.MSG_FX_SUMMON = 0x7E
NoxApi.MSG_FX_SUMMON_CANCEL = 0x7F
NoxApi.MSG_FX_SHIELD = 0x80
NoxApi.MSG_FX_BLUE_SPARKS = 0x81
NoxApi.MSG_FX_YELLOW_SPARKS = 0x82
NoxApi.MSG_FX_CYAN_SPARKS = 0x83
NoxApi.MSG_FX_VIOLET_SPARKS = 0x84
NoxApi.MSG_FX_EXPLOSION = 0x85
NoxApi.MSG_FX_LESSER_EXPLOSION = 0x86
NoxApi.MSG_FX_COUNTERSPELL_EXPLOSION = 0x87
NoxApi.MSG_FX_THIN_EXPLOSION = 0x88
NoxApi.MSG_FX_TELEPORT = 0x89
NoxApi.MSG_FX_SMOKE_BLAST = 0x8A
NoxApi.MSG_FX_DAMAGE_POOF = 0x8B
NoxApi.MSG_FX_LIGHTNING = 0x8C
NoxApi.MSG_FX_ENERGY_BOLT = 0x8D
NoxApi.MSG_FX_CHAIN_LIGHTNING_BOLT = 0x8E
NoxApi.MSG_FX_DRAIN_MANA = 0x8F
NoxApi.MSG_FX_CHARM = 0x90
NoxApi.MSG_FX_GREATER_HEAL = 0x91
NoxApi.MSG_FX_MAGIC = 0x92
NoxApi.MSG_FX_SPARK_EXPLOSION = 0x93
NoxApi.MSG_FX_DEATH_RAY = 0x94
NoxApi.MSG_FX_SENTRY_RAY = 0x95
NoxApi.MSG_FX_RICOCHET = 0x96
NoxApi.MSG_FX_JIGGLE = 0x97
NoxApi.MSG_FX_GREEN_BOLT = 0x98
NoxApi.MSG_FX_GREEN_EXPLOSION = 0x99
NoxApi.MSG_FX_WHITE_FLASH = 0x9A
NoxApi.MSG_FX_GENERATING_MAP = 0x9B
NoxApi.MSG_FX_ASSEMBLING_MAP = 0x9C
NoxApi.MSG_FX_POPULATING_MAP = 0x9D
NoxApi.MSG_FX_DURATION_SPELL = 0x9E
NoxApi.MSG_FX_DELTAZ_SPELL_START = 0x9F
NoxApi.MSG_FX_TURN_UNDEAD = 0xA0
NoxApi.MSG_FX_ARROW_TRAP = 0xA1
NoxApi.MSG_FX_VAMPIRISM = 0xA2
NoxApi.MSG_FX_MANA_BOMB_CANCEL = 0xA3

-- [END] NoxApi enumerations

-- [BEGIN] Low-level memory editing section

local memt = {}
memt.t = memAlloc(4)
memt.memoryPointers = 0 -- tracks how many times scripts allocated memory (leak check)

-- Check for unsigned integer support
if setPtrUInt == nil or getPtrUInt == nil then memt.bug = true end

local shellXorAddress = 0x4F2F62

-- workaround for signed int overflow
function memt.setPtrUInt(ptr, off, int)
    if int <= 0x80000000 then
        setPtrInt(ptr, off, int)
        return
    end
    
    -- build value without sign bit
    int = int - 0x80000000
    setPtrInt(memt.t, 0, int)
    local val = getPtrPtr(memt.t, 0)
    
    -- make a fn call
    val = ptrCall2(shellXorAddress, val, val)

    setPtrPtr(ptr, off, val)
end

if memt.bug then
    -- build pointer to Xor shellcode
    setPtrInt(memt.t, 0, shellXorAddress)
    local shellPtr = getPtrPtr(memt.t, 0)
    
    local shellCode = { 0x35, 0x00, 0x00, 0x00, 0x80, 0xC3, 0x90, 0x25, 0xFF, 0xFF, 0x00, 0x00, 0xC3 }
    -- write shell for Xor
    for i = 1, #shellCode do
        setPtrByte(shellPtr, i - 1, shellCode[i])
    end
    
    memt.shellOk = true
    -- we are already in local context
    setPtrUInt = memt.setPtrUInt
    getPtrUInt = getPtrInt
end

function memt.utilSIntToPtr(num)
    if num <= 0 then return memt.zeroUserdata end
    setPtrInt(memt.t, 0, num)
    
    return getPtrPtr(memt.t, 0)
end

function memt.utilUIntToPtr(num)
    if num <= 0 then return memt.zeroUserdata end
    setPtrUInt(memt.t, 0, num)
    
    return getPtrPtr(memt.t, 0)
end

function memt.utilFltToPtr(num)
    setPtrFloat(memt.t, 0, num)
    local r = getPtrPtr(memt.t, 0)
    if r == nil then return memt.zeroUserdata end
    return r
end

function memt.utilPtrToInt(ptr)
    setPtrPtr(memt.t, 0, ptr)
    local r = getPtrInt(memt.t, 0)
    if r == nil then return 0 end
    return r
end

-- SUPER HACK to get userdata(0)
memt.oneUserdata = memt.utilUIntToPtr(1)
setPtrUInt(memt.utilUIntToPtr(0x6F7B20), 0, 0)
memt.zeroUserdata = ptrCall2(0x4896C0, memt.oneUserdata, memt.oneUserdata)

-- Allocates specified string in game memory. (1 byte char)
function memt.utilMemLdStr8(str)
    local size = #str
    local mem = memt.utilMAlloc(size + 1)
    setPtrByte(mem, size, 0)
    for i = 1, size do
        setPtrByte(mem, i-1, string.byte(str, i))
    end
    return mem
end

-- Allocates specified string in game memory (wchar_t)
function memt.utilMemLdStr16(str)
    local size = #str
    size = size * 2
    local mem = memt.utilMAlloc(size + 1)
    local strNdx = 1
    setPtrShort(mem, size, 0)
    for i = 0, size - 2, 2 do
        setPtrShort(mem, i, string.byte(str, strNdx))
        strNdx = strNdx + 1
    end
    return mem
end

-- Reads 1-byte string from memory
function memt.utilMemRdStr8(ptr, pos)
    local result = ""
    pos = pos or 0
    local z = 0
    while true do
        z = getPtrByte(ptr, pos)
        if z == 0 then break end
        result = result .. string.char(z)
        pos = pos + 1
    end
    return result
end

-- Reads 2-byte string from memory
function memt.utilMemRdStr16(ptr, pos)
    local result = ""
    pos = pos or 0
    local z = 0
    while true do
        z = getPtrShort(ptr, pos)
        if z == 0 then break end
        result = result .. string.char(z)
        pos = pos + 2
    end
    return result
end

function memt.utilMAlloc(size)
    memt.memoryPointers = memt.memoryPointers + 1
    return memAlloc(size)
end

-- workaround for memFree crash
function memt.utilMemFree(mem)
    ptrCall2(0x40425D, mem, mem)
    memt.memoryPointers = memt.memoryPointers - 1
end

local zeroUserdata = memt.zeroUserdata
local oneUserdata = memt.oneUserdata
local utilUIntToPtr = memt.utilUIntToPtr
local utilFltToPtr = memt.utilFltToPtr
local utilPtrToInt = memt.utilPtrToInt
local utilMemLdStr8 = memt.utilMemLdStr8
local utilMemLdStr16 = memt.utilMemLdStr16
local utilMAlloc = memt.utilMAlloc
local utilMemFree = memt.utilMemFree

-- [END] Low-level memory editing section 

-- [BEGIN] NoxApi.Object

-- helper func; attempts to convert string literal into a number found in NoxApi table; if fails, an error is raised
local function tryConvertStringEnum(src, start, val)
    val = string.upper(val)
    local x = NoxApi[start .. val]
    if x == nil then error(string.format("%s: Specified enum value '%s%s' not found", src, start, val)) end
    assert(type(x) == "number", string.format("%s: Enum value '%s%s' is not a number", src, start, val))
    return x
end

local function lookupObjectFields(self, v)
    local r = NoxApi.Object[v]
    
    -- Subclasses: Monster
    if r == nil then
        -- (shouldn't cause recursion in first case, because first lookup is NoxApi.Object)
        
        if self:IsMonster() and NoxApi.Monster[v] then
            return NoxApi.Monster[v]
        end
    end
    return r
end

local function checkExistsImpl(ptr)
    if not ptr then return false end
    -- Check if native implementation exists, if it does, use it instead (faster)
    if unitCheckExists ~= nil then return unitCheckExists(ptr) end
    -- Lua implementation follows
    if ptr == zeroUserdata then return false end
    local it
    -- Check DESTROYED flag
    if bitAnd(getPtrUInt(ptr, 0x10), 0x20) == 0x20 then return false end
    
    -- Check if object is not present on the map, but is contained within somebody's inventory
    local invOwner = getPtrPtr(ptr, 0x1EC)
    if invOwner ~= nil then
        if invOwner == ptr then error("checkExistsImpl: Object is contained within itself, game logic is broken here!") end
        return checkExistsImpl(invOwner)
    end
    
    -- Skip the tables lookup (unsafe)
    if NoxApi.DisableTableCheck then return true end 
    if bitAnd(getPtrUInt(ptr, 8), 1) == 0 then -- MISSILE
        -- Normal object table
        it = ptrCall2(0x4DA790, zeroUserdata, zeroUserdata)
    else
        -- Missile table
        it = ptrCall2(0x4DA840, zeroUserdata, zeroUserdata)
    end
    -- Iterate all objects, return true if found
    while (it ~= zeroUserdata and it ~= nil) do
        if it == ptr then return true end
        it = getPtrPtr(it, 0x1BC)
    end
    -- Do it again for pending creation objects
    it = getPtrPtr(utilUIntToPtr(0x750710), 0)
    while (it ~= zeroUserdata and it ~= nil) do
        if it == ptr then return true end
        it = getPtrPtr(it, 0x1BC)
    end
    return false
end

-- Initialize object from pointer or clone table instance, arg may be nil
function NoxApi.Object:Init(arg, skipTest)
    if arg == nil or arg == zeroUserdata then return nil end
    local t = {}
    t.t = "srvobj"
    if type(arg) == "table" then t.ptr = arg.ptr end
    if type(arg) == "userdata" then t.ptr = arg end
    if not skipTest then -- object is not yet created (FIXME: auto finalize objects?)
        if not checkExistsImpl(t.ptr) then error("Object:Init: attempt to initialize from wrong pointer") end
    end
    
    setmetatable(t, self)
    -- Override methods
    self.__index = lookupObjectFields
    -- Override comparison
    self.__eq = function(lhs, rhs) return lhs.ptr == rhs.ptr end
    
    return t
end

-- Marks object to tell server that some property of this object has changed and needs to be reported back to clients
local function objSetNetworkReportFlag(obj, flag)
    for i = 0, 31 do
        local fl = getPtrInt(obj, 0x230 + 4 * i)
        setPtrUInt(obj, 0x230 + 4 * i, bitOr(fl, flag))
    end
end

-- Creates a new object at specified coordinates with specified type/name
function NoxApi.Object:CreateAt(name, x, y, suppressFinalize)
    if type(name) ~= "number" then
        assert(type(name) == "string", "Object:CreateAt: arg #1 -- name string or type number expected")
    end
    assert(type(x) == "number", "Object:CreateAt: arg #2 -- x number expected")
    assert(type(y) == "number", "Object:CreateAt: arg #3 -- y number expected")

    local o = createObject(name, x, y)
    -- Who ever uses subclass checks today
    if name == "NPC" or name == "Maiden" then
        objSetNetworkReportFlag(o, 0x4000000)
    end
    
    local o = NoxApi.Object:Init(o, true)
    -- Initialize object automatically, so you don't have to do it manually
    -- This way you won't get "Invalid pointer" errors for objects that are not yet initialized by Nox
    if suppressFinalize == nil then NoxApi.Object:FinalizeCreation() end
    return o
end

-- Wrapper for Unimod' createObjectIn
function NoxApi.Object:CreateIn(name, what)
    assert(type(name) == "string", "Object:CreateIn: arg #1 -- Name string expected")
    assert(type(what) == "table", "Object:CreateIn: arg #2 -- Object table expected")
    
    return NoxApi.Object:Init(createObjectIn(name, what.ptr))
end

-- Returns first object ptr on the map with specified script name.
function NoxApi.Object:ByMapName(name)
    assert(type(name) == "string", "Object:ByMapName: string expected")
    
    local mstr = utilMemLdStr8(name)
    local result = ptrCall2(0x4DA4F0, mstr, zeroUserdata)
    utilMemFree(mstr)
    
    if result == zeroUserdata then return nil end
    return NoxApi.Object:Init(result)
end

-- Calls func for each object found to be in a square determined by [x,y,x2,y2]
-- wrapper for unitGetAround
function NoxApi.Object:AllInRect(func, x, y, x2, y2)
    assert(type(func) == "function", "Object:GetInRect: function expected")
    assert(type(x) == "number", "Object:GetInRect: x number expected")
    assert(type(y) == "number", "Object:GetInRect: y number expected")
    assert(type(x2) == "number", "Object:GetInRect: x2 number expected")
    assert(type(y2) == "number", "Object:GetInRect: y2 number expected")
    
    local pick = function(unit)
        func(NoxApi.Object:Init(unit))
    end
    unitGetAround(pick, x, y, x2, y2)
end

-- Checks whenether the object ptr is present in game's object list.
function NoxApi.Object:Exists(what)
    -- can be called static
    if what ~= nil then return checkExistsImpl(what) end
    
    return checkExistsImpl(self.ptr)
end

-- Returns extent/netcode of this object
function NoxApi.Object:Extent()
    assert(self:Exists(), "Object:Extent: invalid object pointer")

    return getPtrUInt(self.ptr, 0x24)
end

-- Deletes object, argument safe
function NoxApi.Object:DeleteInstant()
    assert(self:Exists(), "Object:DeleteInstant: Invalid object pointer ")
    
    unitDelete(self.ptr)
end

-- Removes object after some time, argument safe
function NoxApi.Object:DeleteDelayed(timez)
    assert(self:Exists(), "Object:DeleteDelayed: Invalid object pointer ")
    assert(type(timez) == "number", "Object:DeleteDelayed: time number expected")
    
    unitDecay(self.ptr, timez)
end

-- Returns duration (in frames) of the buff found on specified object and buff power
function NoxApi.Object:BuffGetDuration(buff)
    assert(self:Exists(), "Object:BuffGetDuration: Invalid object pointer ")
    if type(buff) == "string" then buff = NoxApi.Util:GetBuffIdByName(buff) end
    assert(type(buff) == "number", "Object:BuffGetDuration: buff number or string expected")

    local dur = getPtrShort(self.ptr, 0x158 + 2 * buff)
    local pwr = getPtrByte(self.ptr, 0x198 + buff)
    return dur, pwr
end

-- Wrapper for Unimod' unitTestBuff
function NoxApi.Object:HasBuff(buff)
    assert(self:Exists(), "Object:HasBuff: Invalid object pointer ")
    if type(buff) == "string" then buff = NoxApi.Util:GetBuffIdByName(buff) end
    assert(type(buff) == "number", "Object:HasBuff: buff number or string expected")
    
    return unitTestBuff(self.ptr, buff)
end

-- Removes specified buff from specified object, argument safe
function NoxApi.Object:BuffRemove(buff)
    if type(buff) == "string" then buff = NoxApi.Util:GetBuffIdByName(buff) end
    assert(type(buff) == "number", "Object:BuffRemove: buff number or string expected")
    assert(self:Exists(), "Object:BuffRemove: Invalid object pointer")

    local buffUD = zeroUserdata
    if (buff > 0) then buffUD = utilUIntToPtr(buff) end
    return ptrCall2(0x4FF5B0, self.ptr, buffUD)
end

-- Applies specified buff to specified object, argument safe
function NoxApi.Object:BuffApply(buff, duration, power)
    if type(buff) == "string" then buff = NoxApi.Util:GetBuffIdByName(buff) end
    assert(type(buff) == "number", "Object:BuffApply: arg #1 -- number or string expected")
    assert(type(duration) == "number", "Object:BuffApply: arg #2 -- number expected")
    assert(self:Exists(), "Object:BuffApply: Invalid object pointer")

    buffApply(self.ptr, buff, duration)
    if power ~= nil then
        assert(type(power) == "number", "Object:BuffApply: arg #3 -- number expected")
        setPtrByte(self.ptr, 0x198 + buff, power)
    end
end

-- Returns or alters enchantments for an item
function NoxApi.Object:Enchants(tabl)
    assert(self:Exists(), "Object:Enchants: Invalid object pointer")
    if tabl == nil then return itemEnchants(self.ptr) end
    assert(type(tabl) == "table", "Object:Enchants: arg #1 -- table expected")
    
    for i, v in ipairs(tabl) do
        if v ~= "" and v ~= nil then
            if NoxApi.Util:GetItemEnchantId(v) < 0 then
                error(string.format("Object:Enchants: enchantment called '%s' at pos %d does not exist", v, i))
            end
        end
    end
    
    itemEnchants(self.ptr, unpack(tabl))
end

-- Returns or Alters specified object's orientation/direction
function NoxApi.Object:Direction(dir)
    assert(self:Exists(), "Object:Direction: Invalid object pointer ")
    
    if (dir ~= nil) then
        assert(type(dir) == "number", "Object:Direction: direction must be a number")
        setPtrShort(self.ptr, 0x7C, dir) -- current
        setPtrShort(self.ptr, 0x7E, dir) -- guard(monsters)
    end
    
    return getPtrShort(self.ptr, 0x7C)
end

-- Applies or returns force/adds velocity to the specified object
function NoxApi.Object:Velocity(x, y)
    assert(self:Exists(), "Object:Velocity: Invalid object pointer ")
    
    if (x ~= nil and y ~= nil) then
        assert(type(x) == "number", "Object:Velocity: x number expected")
        assert(type(y) == "number", "Object:Velocity: y number expected")
    
        setPtrFloat(self.ptr, 0x58, x + getPtrFloat(self.ptr, 0x58))
        setPtrFloat(self.ptr, 0x5C, y + getPtrFloat(self.ptr, 0x5C))
    end
    
    return getPtrFloat(self.ptr, 0x58), getPtrFloat(self.ptr, 0x5C)
end

-- Returns specified object's current position, argument safe, or instantly moves it to specified position
function NoxApi.Object:Position(x, y)
    assert(self:Exists(), "Object:Position: Invalid object pointer ")

    if (x ~= nil and y ~= nil) then
        assert(type(x) == "number", "Object:Position: x number expected")
        assert(type(y) == "number", "Object:Position: y number expected")
    
        unitMove(self.ptr, x, y)
    end

    return unitPos(self.ptr)
end

-- functionally equal to ObjectOn function in map editor
function NoxApi.Object:Enable()
    assert(self:Exists(), "Object:Enable: Invalid object pointer")
    ptrCall2(0x4E75B0, self.ptr, self.ptr)
end

-- functionally equal to ObjectOff function in map editor
function NoxApi.Object:Disable()
    assert(self:Exists(), "Object:Disable: Invalid object pointer")
    ptrCall2(0x4E7600, self.ptr, self.ptr)
end

-- returns true if specified object has PLAYER class flag, argument safe
function NoxApi.Object:IsPlayer()
    return self:CheckClass(4)
end

-- returns true if specified object has DEAD flag set
function NoxApi.Object:IsDead()
    return self:CheckFlag(0x8000)
end

-- returns true if specified object has MONSTER class flag, argument safe
function NoxApi.Object:IsMonster()
    return self:CheckClass(2)
end

-- returns true if specified object is EQUIPPED 
function NoxApi.Object:IsEquipped()
    return self:CheckFlag(0x100)
end

-- returns playerinfo wrapper for specified object
function NoxApi.Object:GetPlayer()
    -- Exists() check is done inside CheckClass
    assert(self:IsPlayer(), "Object:GetPlayer: Object is not a player")
    
    local uc = getPtrPtr(self.ptr, 0x2EC)
    local plri = getPtrPtr(uc, 0x114)
    return NoxApi.Player:Init(plri)
end

-- Returns or sets number of object's team
function NoxApi.Object:TeamId(val)
    assert(self:Exists(), "Object:TeamId: invalid object ptr")

    if val ~= nil then
        assert(type(val) == "number", "Object:TeamId: arg #1 -- number expected")
        if val >= 0 then
            ptrCall2(0x419090, self.ptr, utilUIntToPtr(val))
        end
    end

    return getPtrUInt(self.ptr, 0x34)
end

-- Returns or sets team that this object belongs to
function NoxApi.Object:Team(val)
    if val ~= nil then
        assert(type(val) == "table", "Object:Team: arg #1 -- team table expected")
        assert(val.t == "team", "Object:Team: arg #1 -- is not a team")
        
        self:TeamId(val:Id())
    end

    return NoxApi.Team:ById(self:TeamId())
end

-- Returns normalized distance to specified location OR point
function NoxApi.Object:DistanceTo(valx, valy)
    assert(self:Exists(), "Object:DistanceTo: invalid object ptr")
    if type(valx) == "table" then
        assert(valx.t == "srvobj", "Object:DistanceTo: arg #1 -- the table specified does not represent server object")
        assert(valx:Exists(), "Object:DistanceTo: arg #1 -- invalid object ptr")
        valx, valy = valx:Position()
    end
    assert(valx == "number", "Object:DistanceTo: arg #1 -- number or table expected")
    assert(valy == "number", "Object:DistanceTo: arg #2 -- number expected")
    
    return NoxApi.Util:Distance(self:Position(), valx, valy)
end

-- checks specified class flag(s), argument safe
function NoxApi.Object:CheckClass(class)
    assert(self:Exists(), "Object:CheckClass: invalid object ptr")
    if type(class) == "string" then
        class = tryConvertStringEnum("Object:CheckClass", "OC_", class)
    end
    assert(type(class) == "number", "Object:CheckClass: arg #1 -- number or string expected")
    
    if (bitAnd(getPtrUInt(self.ptr, 8), class) > 0) then return true end
    return false
end

-- checks whenether object is marked with specific flag, argument safe
function NoxApi.Object:CheckFlag(flag)
    assert(self:Exists(), "Object:CheckFlag: invalid object ptr")
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Object:CheckFlag", "OF_", flag)
    end
    assert(type(flag) == "number", "Object:CheckFlag: arg #1 -- number or string expected")
    
    if (bitAnd(unitFlags(self.ptr), flag) > 0) then return true end
    return false
end

-- Sets or unsets the specified flag value for given object
function NoxApi.Object:SetFlag(flag, val)
    assert(self:Exists(), "Object:SetFlag: invalid object ptr")
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Object:SetFlag", "OF_", flag)
    end
    assert(type(flag) == "number", "Object:SetFlag: arg #1 -- number or string expected")
    assert(type(val) == "boolean", "Object:SetFlag: arg #2 -- boolean expected")
    local oldFlags = unitFlags(self.ptr)
    
    if val then
        setPtrUInt(self.ptr, 0x10, bitOr(oldFlags, flag))
    else
        if (bitAnd(unitFlags(self.ptr), flag) == flag) then 
            setPtrUInt(self.ptr, 0x10, bitXor(oldFlags, flag))
        end
    end
end

-- makes specified object 'say' specified sentence, argument safe
function NoxApi.Object:SayChat(text, whom)
    assert(type(text) == "string", "Object:SayChat: arg #1 -- text string expected")
    assert(self:Exists(), "Object:SayChat: Invalid object pointer")
    if whom == nil then whom = -1 end
    assert(type(whom) == "number", "Object:SayChat: arg #2 -- must be a number or nil")

    sendChat(whom, text, servNetCode(self.ptr))
end

-- restores health to object, native Nox way, makes no sound
function NoxApi.Object:HealthRestore(heal)
    assert(type(heal) == "number", "Object:HealthRestore: arg #1 -- number expected")
    assert(self:Exists(), "Object:HealthRestore: Invalid object pointer")

    if heal > 0 then
        return ptrCall2(0x4EE460, self.ptr, utilUIntToPtr(heal))
    end
end

-- Gets or sets maximum health amount for an object (or nil if object is indestructible)
function NoxApi.Object:MaxHealth(setval)
    assert(self:Exists(), "Object:MaxHealth: Invalid object pointer ")
  
    local hd = getPtrPtr(self.ptr, 0x22C)
    if hd ~= nil then
        if setval ~= nil then
            assert(type(setval) == "number", "Object:MaxHealth: new value must be a number")
            setPtrShort(hd, 4, setval)
            return setval
        end
        
        return getPtrShort(hd, 4)
    end
    return nil
end

-- Returns or alters a specified object's current health (or nil if object is indestructible)
function NoxApi.Object:CurrentHealth(setval)
    assert(self:Exists(), "Object:CurrentHealth: Invalid object pointer ")
  
    local hd = getPtrPtr(self.ptr, 0x22C)
    if hd ~= nil then
        if setval ~= nil then
            assert(type(setval) == "number", "Object:CurrentHealth: new value must be a number")
            setPtrShort(hd, 0, setval)
            return setval
        end
        
        return getPtrShort(hd, 0)
    end
    return nil
end

-- Raises specified object to specified height
function NoxApi.Object:Raise(val)
    assert(type(val) == "number", "Object:Raise: height number expected")
    assert(self:Exists(), "Object:Raise: Invalid object pointer ")

    return ptrCall2(0x4E46F0, self.ptr, utilFltToPtr(val))
end

-- Alters owner(parent) of object
function NoxApi.Object:SetParent(val)
    assert(self:Exists(), "Object:SetParent: Invalid object pointer ")
    
    -- Remove parent
    if val == nil then ptrCall2(0x4EC300, zeroUserdata, self.ptr) end
    assert(type(val) == "table", "Object:SetParent: arg #1 -- object table expected")
    assert(val:Exists(), "Object:SetParent: arg #1 -- Invalid object pointer")
    
    ptrCall2(0x4EC290, val.ptr, self.ptr)
end

-- Wrapper
function NoxApi.Object:ClearParent()
    self:SetParent(nil)
end

-- Returns parent object
function NoxApi.Object:GetParent()
    assert(self:Exists(), "Object:GetParent: Invalid object pointer ")
    
    return NoxApi.Object:Init(getPtrPtr(self.ptr, 0x1FC))
end

-- Returns the object in which inventory this object resides
function NoxApi.Object:GetHolder()
    assert(self:Exists(), "Object:GetHolder: Invalid object pointer ")
    
    return NoxApi.Object:Init(getPtrPtr(self.ptr, 0x1EC))
end

-- Gets or sets poison level of specified monster or player
function NoxApi.Object:Poison(lvl)
    assert(self:Exists(), "Object:Poison: Invalid object pointer")
    if lvl == nil then return getPtrByte(self.ptr, 0x21C) end
    
    assert(type(lvl) == "number", "Object:Poison: arg #1 -- number expected")
    if (lvl > 0) then
        setPtrByte(self.ptr, 0x21C, lvl)
    else
        ptrCall2(0x4EE9D0, self.ptr, self.ptr) -- remove poison
    end
    ptrCall2(0x4EEA90, self.ptr, utilUIntToPtr(lvl)) -- call original function which sends update packet
end

-- Returns true if monster can traverse specified point
function NoxApi.Object:CanVisitPoint(x, y)
    assert(self:Exists(), "Object:CanVisitPoint: Invalid object pointer")
    assert(type(x) == "number", "Object:CanVisitPoint: x number expected")
    assert(type(y) == "number", "Object:CanVisitPoint: y number expected")
    
    local m = utilMAlloc(8)
    setPtrFloat(m, 0, x)
    setPtrFloat(m, 4, y)
    local r = ptrCall2(0x50B810, self.ptr, m)
    utilMemFree(m)
    if r == zeroUserdata then return false end
    return true
end

-- Returns true if monster can traverse specified point
function NoxApi.Object:CanVisitPoint2(x, y)
    assert(self:Exists(), "Object:CanVisitPoint2: Invalid object pointer")
    assert(type(x) == "number", "Object:CanVisitPoint2: x number expected")
    assert(type(y) == "number", "Object:CanVisitPoint2: y number expected")
    
    local x2, y2 = unitPos(self.ptr)
    local m = utilMAlloc(16)
    
    setPtrFloat(m, 0, x)
    setPtrFloat(m, 4, y)
    setPtrFloat(m, 8, x2)
    setPtrFloat(m, 12, y2)
    local r = ptrCall2(0x50B580, self.ptr, m)
    utilMemFree(m)
    if r == zeroUserdata then return false end
    return true
end

-- instantly moves recently created objects and initializes them
function NoxApi.Object:FinalizeCreation()
    ptrCall2(0x4DAC00, oneUserdata, oneUserdata)
end

-- returns ThingId name
function NoxApi.Object:ThingName(val)
    -- can be called static, or from class instance
    if val ~= nil then
        assert(type(val) == "number", "Object:ThingName: number or nil expected")
        return getThingName(val)
    end
    
    assert(self:Exists(), "Object:ThingName: Invalid self object pointer")
    return getThingName(self.ptr)
end

-- iterates through object's inventory, calling func for every item found
function NoxApi.Object:IterateInventory(func)
    assert(self:Exists(), "Object:IterateInventory: Invalid object pointer")
    if func ~= nil then
        assert(type(func) == "function", "Object:IterateInventory: function expected")
    end
    
    local item = getPtrPtr(self.ptr, 0x1F8)
    local c = 0
    while item ~= nil do
        if func ~= nil then func(NoxApi.Object:Init(item)) end
        c = c + 1
        item = getPtrPtr(item, 0x1F0)
    end
    return c
end

-- custom implementation of unitInventoryPut because the current one is bugged
-- Puts object obj into inventory of self, (TODO: alerts player if report is set to true, makes sound...)
-- returns true on success, false otherwise
function NoxApi.Object:InvPut(obj, report)
    assert(self:Exists(), "Object:InvPut: Invalid object pointer")
    assert(obj:Exists(), "Object:InvPut: arg #1 -- Invalid object pointer")
    assert(obj ~= self, "Object:InvPut: arg #1 -- can't put object into itself")
    assert(getPtrUInt(obj.ptr, 0x1EC) == 0, "Object:InvPut: object is already in someone else's inventory")
    
    -- check for native support
    if unitInventoryPlace ~= nil then
        return unitInventoryPlace(self.ptr, obj.ptr) > 0
    end
    
    -- pointer to shellcode
    local shellPtr = utilUIntToPtr(0x4F2F80)
    
    -- save current code
    local shellOrigA = getPtrPtr(shellPtr, 0)
    local shellOrigB = getPtrPtr(shellPtr, 8)

    -- patch code
    setPtrPtr(shellPtr, 0, utilUIntToPtr(0x00076BE8))
    setPtrPtr(shellPtr, 8, utilUIntToPtr(0x90C35E5F))
    
    -- make a fn call
    local result = ptrCall2(0x4F2F70, self.ptr, obj.ptr)
    
    -- restore original code
    setPtrPtr(shellPtr, 0, shellOrigA)
    setPtrPtr(shellPtr, 8, shellOrigB)
    if result == zeroUserdata then return false end
    return true
end

-- Drops an item from someone's inventory
function NoxApi.Object:InvDrop(obj)
    assert(self:Exists(), "Object:InvDrop: Invalid self object pointer")
    if obj == nil then
        obj = self:GetHolder()
    end
    assert(obj:Exists(), "Object:InvDrop: arg #1 -- Object is not in someone's inventory")
    
    ptrCall2(0x4ED930, self.ptr, obj.ptr)
end

-- Attempts to equip a piece of armor or weapon, works only on npc's or players
function NoxApi.Object:TryEquip(obj)
    assert(self:Exists(), "Object:TryEquip: Invalid object pointer")
    assert(not self:IsDead(), "Object:TryEquip: dead players cannot equip items")
    assert(self:CheckClass(4) or self:CheckClass(2), "Object:TryEquip: Only players or NPCs may equip items")
    assert(type(obj) == "table", "Object:TryEquip: arg #1 -- must be an object")
    assert(obj:Exists(), "Object:TryEquip: arg #1 -- Invalid object pointer")
    
    local result = ptrCall2(0x4F2F70, self.ptr, obj.ptr)
    if result == zeroUserdata then return false end
    return true
end

-- Attempts to equip a piece of armor or weapon, works only on npc's or players
function NoxApi.Object:TryDequip(obj)
    assert(self:Exists(), "Object:TryEquip: Invalid object pointer")
    assert(self:CheckClass(4) or self:CheckClass(2), "Object:TryEquip: Only players or NPCs may equip items")
    assert(type(obj) == "table", "Object:TryEquip: arg #1 -- must be an object")
    assert(obj:Exists(), "Object:TryEquip: arg #1 -- Invalid object pointer")
    
    local result = ptrCall2(0x4F2FB0, self.ptr, obj.ptr)
    if result == zeroUserdata then return false end
    return true
end

-- Returns or alters the number of charges for object 
function NoxApi.Object:AmmoCharges(val)
    assert(self:Exists(), "Object:AmmoCharges: Invalid object pointer")
    local wtype = self:GetWeaponType()
    assert(self:CheckClass(0x1000) or wtype == 2, "Object:AmmoCharges: Object is not a wand or quiver")
    
    local data = getPtrPtr(self.ptr, 0x2E0)
    if data == nil then return nil end
    
    if val ~= nil then
        assert(type(val) == "number", "Object:AmmoCharges: arg #1 -- number expected")
        if val > 255 then val = 255 end
        if wtype == 2 then
            -- quiver
            setPtrByte(data, 1, val)
        else
            -- wand
            setPtrByte(data, 0x6C, val)
            -- recalculate percentage (of full charge -- used by obelisks)
            setPtrUInt(data, 0x70, val / getPtrByte(data, 0x6D) * 100)
        end
    end
    
    if wtype == 2 then
        return getPtrByte(data, 1)
    else
        return getPtrByte(data, 0x6C)
    end
end

-- Returns or alters the maximal number of charges for object 
function NoxApi.Object:AmmoMaxCharges(val)
    assert(self:Exists(), "Object:AmmoMaxCharges: Invalid object pointer")
    local wtype = self:GetWeaponType()
    assert(self:CheckClass(0x1000) or wtype == 2, "Object:AmmoMaxCharges: Object is not a wand or quiver")
    
    local data = getPtrPtr(self.ptr, 0x2E0)
    if data == nil then return nil end
    
    if val ~= nil then
        assert(type(val) == "number", "Object:AmmoMaxCharges: arg #1 -- number expected")
        if val > 255 then val = 255 end
        if wtype == 2 then
            -- quiver
            setPtrByte(data, 0, val)
        else
            -- wand
            setPtrByte(data, 0x6D, val)
            -- recalculate percentage (of full charge -- used by obelisks)
            setPtrUInt(data, 0x70, getPtrByte(data, 0x6C) / val * 100)
        end
    end
    
    if wtype == 2 then
        return getPtrByte(data, 0)
    else
        return getPtrByte(data, 0x6D)
    end
end

-- Returns value that Nox uses internally to ditinguish different armor and weapons
function NoxApi.Object:GetWeaponType()
    assert(self:Exists(), "Object:GetWeaponType: Invalid object pointer")
    
    local result = ptrCall2(0x415820, self.ptr, self.ptr)
    return utilPtrToInt(result)
end

-- Deals damage by usage of default object function 0x2CC 
function NoxApi.Object:Damage(value, dtype, source)
    assert(self:Exists(), "Object:Damage: Invalid object pointer")
    if source ~= nil then 
        assert(type(source) == "table", "Object:Damage: arg #3 -- source must be an object")
        assert(source:Exists(), "Object:Damage: arg #3 -- invalid pointer for source object") 
    end
    assert(type(value) == "number", "Object:Damage: arg #1 -- value number expected")
    -- Convert string name into numerical representation 
    if type(dtype) == "string" then
        dtype = tryConvertStringEnum("Object:Damage", "DAMAGE_", dtype)
    end
    assert(type(dtype) == "number", "Object:Damage: arg #2 -- dtype number or string expected")
    assert(getPtrUInt(self.ptr, 0x2CC) > 0, "Object:Damage: object has no damage handler")
    
    -- Use native implementation if exists
    if unitDamage ~= nil then
        if source == nil then
            unitDamage(self.ptr, nil, nil, value, dtype)
        else
            unitDamage(self.ptr, source.ptr, nil, value, dtype)
        end
        return
    end
    -- Use workaround
    local packp = utilMAlloc(12)
    if source == nil then 
        setPtrUInt(packp, 0, 0) 
    else
        setPtrPtr(packp, 0, source.ptr)
    end
    setPtrUInt(packp, 4, value)
    setPtrUInt(packp, 8, dtype)
    ptrCall2(0x512FE0, self.ptr, packp)
    utilMemFree(packp)
end

-- [END] NoxApi.Object

-- [BEGIN] NoxApi.Monster

-- Checks if at least one flag of monster status is set
function NoxApi.Monster:CheckStatusFlag(flag)
    assert(self:Exists(), "Monster:CheckStatusFlag: Invalid object pointer")
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Monster:CheckStatusFlag", "MS_", flag)
    end
    assert(type(flag) == "number", "Monster:CheckStatusFlag: arg #1 -- number or string expected")
    local uc = getPtrPtr(self.ptr, 0x2EC)
    
    return bitAnd(getPtrUInt(uc, 0x5A0), flag) > 0
end

-- Sets monster's status flags 
function NoxApi.Monster:SetStatusFlag(flag, val)
    assert(self:Exists(), "Monster:SetStatusFlag: Invalid object pointer")
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Monster:SetStatusFlag", "MS_", flag)
    end
    assert(type(flag) == "number", "Monster:SetStatusFlag: arg #1 -- number or string expected")
    assert(type(val) == "boolean", "Monster:SetStatusFlag: arg #2 -- boolean expected")
    local uc = getPtrPtr(self.ptr, 0x2EC)
    local of = getPtrUInt(uc, 0x5A0)
    
    if val then
        setPtrUInt(uc, 0x5A0, bitOr(of, flag))
    else
        if bitAnd(of, flag) == flag then
            setPtrUInt(uc, 0x5A0, bitXor(of, flag))
        end
    end
end

-- Returns or alters almost all possible fields for monster
function NoxApi.Monster:MonsterInfo(tab)
    assert(self:Exists(), "Monster:MonsterInfo: Invalid object pointer")
    local uc = getPtrPtr(self.ptr, 0x2EC)
    
    if tab ~= nil then
        assert(type(tab) == "table", "Monster:MonsterInfo: arg #1 -- table expected")
        
        for k, v in pairs(tab) do
            if k == "resurrectTime" then setPtrInt(uc, 0x1EC, v) end
            -- Let's presume all action-related values are read-only
            
            if k == "aggressiveness" then setPtrFloat(uc, 0x518, v) setPtrFloat(uc, 0x51C, v) end
            if k == "visionRange" then setPtrFloat(uc, 0x520, v) end
            if k == "escortDistance" then setPtrFloat(uc, 0x524, v) end
            if k == "aimSkill" then setPtrFloat(uc, 0x528, v) end
            if k == "strength" then setPtrByte(uc, 0x52C, v) end
            if k == "speedMul" then setPtrFloat(uc, 0x530, v) end
            if k == "roamFlag" then setPtrInt(uc, 0x534, v) end
            if k == "retreatCoeff" then setPtrFloat(uc, 0x538, v) end
            if k == "resumeCoeff" then setPtrFloat(uc, 0x540, v) end
            if k == "fleeDistance" then setPtrFloat(uc, 0x54C, v) end
            if k == "defaultAction" then setPtrInt(uc, 0x550, v) end
            
            if k == "inversionTimeoutMin" then setPtrShort(uc, 0x5A8, v) end
            if k == "inversionTimeoutMax" then setPtrShort(uc, 0x5AA, v) end
            if k == "protectionTimeoutMin" then setPtrShort(uc, 0x5B0, v) end
            if k == "protectionTimeoutMax" then setPtrShort(uc, 0x5B2, v) end
            if k == "offensiveTimeoutMin" then setPtrShort(uc, 0x5B8, v) end
            if k == "offensiveTimeoutMax" then setPtrShort(uc, 0x5BA, v) end
            if k == "summoningTimeoutMin" then setPtrShort(uc, 0x5C0, v) end
            if k == "summoningTimeoutMax" then setPtrShort(uc, 0x5C2, v) end
            if k == "blinkTimeoutMin" then setPtrShort(uc, 0x5C8, v) end
            if k == "blinkTimeoutMax" then setPtrShort(uc, 0x5CA, v) end
        end
        return
    end
    
    local t = {}
    --t.t = "monsterinfo"
    t.resurrectTime = getPtrInt(uc, 0x1EC)
    t.enemyDetectTime = getPtrInt(uc, 0x218)
    t.actionStackSize = getPtrInt(uc, 0x220)
    t.currentAction = getPtrInt(uc, 0x228)
    
    t.visibleEnemies = getPtrByte(uc, 0x469)
    t.aggressiveness = getPtrFloat(uc, 0x518)
    t.visionRange = getPtrFloat(uc, 0x520)
    t.escortDistance = getPtrFloat(uc, 0x524)
    t.aimSkill = getPtrFloat(uc, 0x528)
    t.strength = getPtrByte(uc, 0x52C)
    t.speedMul = getPtrFloat(uc, 0x530) -- works only for NPCs, btw
    t.roamFlag = getPtrInt(uc, 0x534)
    t.retreatCoeff = getPtrFloat(uc, 0x538)
    t.resumeCoeff = getPtrFloat(uc, 0x540)
    t.fleeDistance = getPtrFloat(uc, 0x54C)
    t.defaultAction = getPtrInt(uc, 0x550)
    
    -- Spell usage timeout values
    t.inversionTimeoutMin = getPtrShort(uc, 0x5A8)
    t.inversionTimeoutMax = getPtrShort(uc, 0x5AA)
    t.protectionTimeoutMin = getPtrShort(uc, 0x5B0)
    t.protectionTimeoutMax = getPtrShort(uc, 0x5B2)
    t.offensiveTimeoutMin = getPtrShort(uc, 0x5B8)
    t.offensiveTimeoutMax = getPtrShort(uc, 0x5BA)
    t.summoningTimeoutMin = getPtrShort(uc, 0x5C0)
    t.summoningTimeoutMax = getPtrShort(uc, 0x5C2)
    t.blinkTimeoutMin = getPtrShort(uc, 0x5C8)
    t.blinkTimeoutMax = getPtrShort(uc, 0x5CA)
    
    return t
end

-- Wrapper for Unimod' unitBecomePet
function NoxApi.Monster:BecomePet(obj)
    assert(self:Exists(), "Monster:BecomePet: Invalid object pointer")
    assert(obj:Exists(), "Monster:BecomePet: arg #1 -- Invalid object pointer")

    unitBecomePet(self.ptr, obj.ptr)
end

-- Returns weapon in hand of an NPC, if present
function NoxApi.Monster:GetWeapon()
    assert(self:Exists(), "Monster:GetWeapon: Invalid object pointer")
    local uc = getPtrPtr(self.ptr, 0x2EC)

    return NoxApi.Object:Init(getPtrPtr(uc, 0x810))
end

-- Sets current enemy for monster
function NoxApi.Monster:SetEnemy(val)
    assert(self:Exists(), "Monster:SetEnemy: Invalid object pointer")
    local uc = getPtrPtr(self.ptr, 0x2EC)
    
    if val == nil then setPtrInt(uc, 0x4AC, 0) end
    assert(type(val) == "table", "Monster:SetEnemy: arg #1 -- object table expected")
    assert(val:Exists(), "Monster:SetEnemy: arg #1 -- object does not exist")
    setPtrPtr(uc, 0x4AC, val.ptr)
end

-- Returns current enemy for monster
function NoxApi.Monster:GetEnemy(val)
    assert(self:Exists(), "Monster:GetEnemy: Invalid object pointer")
    local uc = getPtrPtr(self.ptr, 0x2EC)
    
    return NoxApi.Object:Init(getPtrPtr(uc, 0x4AC))
end

-- Clears action stack for a monster
function NoxApi.Monster:ClearActionStack()
    assert(self:Exists(), "Monster:ClearActionStack: Invalid object pointer")
    
    ptrCall2(0x50A3A0, self.ptr, zeroUserdata)
end

-- Returns the action on top of the stack, that is currently being performed
function NoxApi.Monster:GetCurrentAction()
    assert(self:Exists(), "Monster:IsActionScheduled: Invalid object pointer")
    
    local uc = getPtrPtr(self.ptr, 0x2EC)
    return getPtrInt(uc, 0x228)
end

-- Pops value from action stack
function NoxApi.Monster:PopActionStack()
    assert(self:Exists(), "Monster:PopActionStack: Invalid object pointer")
    return unitActionPop(self.ptr)
end

-- Returns true if specified event type is found inside monster's action stack
function NoxApi.Monster:IsActionScheduled(act)
    assert(self:Exists(), "Monster:IsActionScheduled: Invalid object pointer")
    assert(type(act) == "number", "Monster:IsActionScheduled: arg #1 -- number expected")

    local x = ptrCall2(0x50A0D0, self.ptr, utilUIntToPtr(act))
    if x == zeroUserdata then return false end
    return true
end

-- helper func
local function monsterValidateObject(obj, argn)
    assert(type(obj) == "table", string.format("Monster:PushActionStack: invalid type for arg #%i -- table expected", argn))
    assert(obj.t == "srvobj", string.format("Monster:PushActionStack: arg #%i must be an object table", argn))
    assert(obj:Exists(), string.format("Monster:PushActionStack: arg #%i refers to an object that does not exist in-game", argn))
end

-- Push action into monster's AI stack
-- Returns true if ok, false + error message in case of failure
function NoxApi.Monster:PushActionStack(idx, vala, valb, valc)
    assert(self:Exists(), "Monster:PushAction: Invalid object pointer")
    if type(idx) == "string" then
        idx = tryConvertStringEnum("Monster:PushActionStack", "ACTION_", idx)
    end
    assert(type(idx) == "number", "Monster:PushActionStack: arg #1 -- number or string expected")
    
    -- Validate range
    assert(idx >= 0 and idx <= 38, "Monster:PushActionStack: arg #1 -- value out of valid range [0; 38]")
    
    -- Validate argument types
    -- [WARNING! UGLY CODE! Think that you are using disassembler]
    if idx == NoxApi.ACTION_WAIT or idx == NoxApi.ACTION_WAIT_RELATIVE or idx == NoxApi.ACTION_FACE_ANGLE or idx == NoxApi.ACTION_SET_ANGLE or idx == NoxApi.ACTION_REPORT then 
        assert(type(vala) == "number", "Monster:PushActionStack: invalid type for arg #2 -- number expected") 
    end
    if idx == NoxApi.ACTION_ESCORT or idx == NoxApi.ACTION_FIGHT or idx == NoxApi.ACTION_PICKUP_OBJECT or idx == NoxApi.ACTION_FACE_OBJECT then 
        monsterValidateObject(vala, 2) 
    end
    -- No arguments for 4, 5, 6
    if idx >= NoxApi.ACTION_MOVE_TO and idx <= NoxApi.ACTION_DODGE or idx == NoxApi.ACTION_MISSILE_ATTACK or idx == NoxApi.ACTION_FLEE or idx == NoxApi.ACTION_FACE_LOCATION then 
        assert(type(vala) == "number", "Monster:PushActionStack: invalid type for arg #2 -- number expected")
        assert(type(valb) == "number", "Monster:PushActionStack: invalid type for arg #3 -- number expected")
    end
    if idx == NoxApi.ACTION_ROAM or idx == NoxApi.ACTION_BLOCK_ATTACK then 
        -- TODO: ACTION_ROAM can accept waypoints as 1'st arg (see 0x5123C0)
        assert(type(vala) == "number", "Monster:PushActionStack: invalid type for arg #2 -- number expected")
    end
    -- 12, 13 are unused
    -- 14 has no arguments
    -- 16 has no arguments
    if idx == NoxApi.ACTION_CAST_SPELL_ON_OBJECT or idx == NoxApi.ACTION_CAST_DURATION_SPELL then
        if type(vala) == "string" then vala = NoxApi.Util:GetSpellIdByName(vala) end
        assert(type(vala) == "number" and vala > 0, "Monster:PushActionStack: invalid type for arg #2 -- number or string expected")
        monsterValidateObject(valb, 3)
    end
    if idx == NoxApi.ACTION_CAST_SPELL_ON_LOCATION then
        if type(vala) == "string" then vala = NoxApi.Util:GetSpellIdByName(vala) end
        assert(type(vala) == "number" and vala > 0, "Monster:PushActionStack: invalid type for arg #2 -- number or string expected")
        assert(type(valb) == "number", "Monster:PushActionStack: invalid type for arg #3 -- number expected")
        assert(type(valc) == "number", "Monster:PushActionStack: invalid type for arg #4 -- number expected")
    end
        
    local x, y = self:Position()
    local act = unitSetAction(self.ptr, idx)
    -- Can be returned by game in case there is too many actions in stack
    if act == zeroUserdata then return false, "Stack overflow" end
    
    -- Set arguments
    if idx == NoxApi.ACTION_WAIT or idx == NoxApi.ACTION_WAIT_RELATIVE or idx == NoxApi.ACTION_FACE_ANGLE or idx == NoxApi.ACTION_SET_ANGLE or idx == NoxApi.ACTION_REPORT then 
        setPtrUInt(act, 4, vala) 
    end 
    if idx == NoxApi.ACTION_ESCORT then
        x, y = vala:Position()
        setPtrFloat(act, 4, x)
        setPtrFloat(act, 8, y)
        setPtrPtr(act, 12, vala.ptr)
    end
    if idx == NoxApi.ACTION_GUARD then 
        setPtrFloat(act, 4, x)
        setPtrFloat(act, 8, y)
        setPtrUInt(act, 12, getPtrByte(self.ptr, 0x7C))
    end
    if idx >= NoxApi.ACTION_MOVE_TO and idx <= NoxApi.ACTION_DODGE or idx == NoxApi.ACTION_MISSILE_ATTACK or idx == NoxApi.ACTION_FLEE or idx == NoxApi.ACTION_FACE_LOCATION then
        setPtrFloat(act, 4, vala)
        setPtrFloat(act, 8, valb)
        setPtrInt(act, 12, 0)
    end
    if idx == NoxApi.ACTION_ROAM then 
        setPtrInt(act, 4, 0)
        setPtrInt(act, 8, vala)
    end
    if idx == NoxApi.ACTION_PICKUP_OBJECT or idx == NoxApi.ACTION_FACE_OBJECT then
        setPtrPtr(act, 4, vala.ptr)
    end
    if idx == NoxApi.ACTION_FIGHT then
        x, y = vala:Position()
        setPtrFloat(act, 4, x)
        setPtrFloat(act, 8, y)
        setPtrUInt(act, 12, getFrameCounter())
    end
    if idx == NoxApi.ACTION_CAST_SPELL_ON_OBJECT or idx == NoxApi.ACTION_CAST_DURATION_SPELL then
        setPtrInt(act, 4, vala)
        setPtrPtr(act, 12, valb.ptr)
    end
    if idx == NoxApi.ACTION_CAST_SPELL_ON_LOCATION then
        setPtrInt(act, 4, vala)
        setPtrInt(act, 8, 0)
        setPtrFloat(act, 12, valb)
        setPtrFloat(act, 16, valc)
        setPtrInt(act, 20, 0)
    end
    if idx == NoxApi.ACTION_BLOCK_ATTACK then
        setPtrInt(act, 4, getFrameCounter() + vala) -- how long the block lasts
    end
    if idx == NoxApi.ACTION_MOVE_TO_HOME then
        local uc = getPtrPtr(self.ptr, 0x2EC)
        x = getPtrFloat(uc, 0x17C)
        y = getPtrFloat(uc, 0x180)
        setPtrFloat(act, 4, x)
        setPtrFloat(act, 8, y)
        setPtrInt(act, 12, 0)
    end
    return true
end

-- Returns or updates color scheme for an NPC 
function NoxApi.Monster:NPCAppearance(colorN, R, G, B)
    assert(self:Exists(), "Monster:NPCAppearance: Invalid object pointer")
    assert(type(colorN) == "number", "Monster:NPCAppearance: arg #1 -- Color index expected")
    assert(colorN >= 0 and colorN <= 6, "Monster:NPCAppearance: arg #1 -- Color index in range [0; 6] expected")

    local uc = getPtrPtr(self.ptr, 0x2EC)
    local offset = 2 * (colorN + 0x2B4) + colorN + 0x2B4
    
    if R ~= nil then
        assert(type(R) == "number", "Monster:NPCAppearance: arg #2 -- Color value expected")
        assert(type(G) == "number", "Monster:NPCAppearance: arg #3 -- Color value expected")
        assert(type(B) == "number", "Monster:NPCAppearance: arg #4 -- Color value expected")
        setPtrByte(uc, offset, R)
        setPtrByte(uc, offset + 1, G)
        setPtrByte(uc, offset + 2, B)
        objSetNetworkReportFlag(self.ptr, 0x4000000)
    end
    return getPtrByte(uc, offset), getPtrByte(uc, offset + 1), getPtrByte(uc, offset + 2)
end

-- Alters NPC's way of spell usage
function NoxApi.Monster:NPCSpell(spell, useflag)
    assert(self:Exists(), "Monster:NPCSpell: Invalid object pointer")
    if type(spell) == "string" then
        spell = NoxApi.Util:GetSpellIdByName(spell)
        if spell <= 0 then return end
    end
    assert(type(spell) == "number", "Monster:NPCSpell: arg #1 -- number or string expected")
    if type(useflag) == "string" then
        useflag = tryConvertStringEnum("Monster:NPCSpell", "SFLAG_", useflag)
    end
    assert(type(useflag) == "number", "Monster:NPCSpell: arg #2 -- number or string expected")
    
    local uc = getPtrPtr(self.ptr, 0x2EC)
    local offset = 4 * spell + 0x5D0
    setPtrUInt(uc, offset, useflag)
end

-- [END] NoxApi.Monster

-- [BEGIN] NoxApi.Player

-- Returns safe player object from player name
local function lookupPlayerFields(self, v)
    return NoxApi.Player[v]
end

-- Initialize player object wrapper from memory pointer
function NoxApi.Player:Init(arg)
    if arg == nil or arg == zeroUserdata then return nil end
    local t = {}
    t.t = "player"
    if type(arg) == "table" then t.ptr = arg.ptr end
    if type(arg) == "userdata" then t.ptr = arg end
    
    local player = ptrCall2(0x416EA0, zeroUserdata, zeroUserdata)
    local fail = true
    while player ~= zeroUserdata do
        if player == t.ptr then fail = false break end
        player = ptrCall2(0x416EE0, player, zeroUserdata)
    end
    if fail then error("Player:Init: attempt to initialize from wrong pointer") end
    
    setmetatable(t, self)
    -- Override methods
    self.__index = lookupPlayerFields
    -- Override comparison
    self.__eq = function(lhs, rhs) return lhs.ptr == rhs.ptr end
    
    return t
end

-- Returns player with specified name (if found)
function NoxApi.Player:ByName(name)
    assert(type(name) == "string", "Player:ByName: arg #1 -- Name string is expected")

    local mstr = utilMemLdStr16(name)
    local result = ptrCall2(0x4170D0, mstr, mstr)
    utilMemFree(mstr)

    if result == zeroUserdata then return nil end
    return NoxApi.Player:Init(result)
end

-- Returns player reference from PlayerId
function NoxApi.Player:ById(id)
    assert(type(id) == "number", "Player:ById: arg #1 -- player number in range [0; 31] expected")
    if id > 31 or id < 0 then return nil end

    local thirtyone = utilUIntToPtr(id)
    local plri = ptrCall2(0x417090, thirtyone, thirtyone)
    if plri == zeroUserdata then return nil end
    
    return NoxApi.Player:Init(plri)
end

-- Iterates through all players on the server
function NoxApi.Player:IterateAll(func)
    if func ~= nil then assert(type(func) == "function", "Player:IterateAll: arg #1 -- function expected") end

    local player = ptrCall2(0x416EA0, zeroUserdata, zeroUserdata)
    local counter = 0
    while player ~= zeroUserdata do
        if func ~= nil then func(NoxApi.Player:Init(player)) end
        counter = counter + 1
        player = ptrCall2(0x416EE0, player, zeroUserdata)
    end
    return counter
end

-- returns true if at least one given player status flags is set 
function NoxApi.Player:CheckStatus(flag)
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Player:CheckStatus", "PLRSTATUS_", flag)
    end
    assert(type(flag) == "number", "Player:CheckStatus: arg #1 -- number or string expected")
    
    local stat = getPtrUInt(self.ptr, 0xE60)
    return bitAnd(stat, flag) > 0
end

-- sets player status flags
function NoxApi.Player:SetStatus(flag)
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Player:SetStatus", "PLRSTATUS_", flag)
    end
    assert(type(flag) == "number", "Player:SetStatus: arg #1 -- number or string expected")
    
    ptrCall2(0x4174F0, self.ptr, utilUIntToPtr(flag))
end

-- removes player status flags
function NoxApi.Player:ClearStatus(flag)
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Player:ClearStatus", "PLRSTATUS_", flag)
    end
    assert(type(flag) == "number", "Player:ClearStatus: arg #1 -- number or string expected")
    
    ptrCall2(0x417530, self.ptr, utilUIntToPtr(flag))
end

-- wrapper for Unimod' playerInfo()
function NoxApi.Player:GetInfo()
    return playerInfo(self:GetObject().ptr)
end

-- returns player's id in range [0; 31]
function NoxApi.Player:Id()
    return getPtrByte(self.ptr, 0x810)
end

-- Returns OR alters player's character name
function NoxApi.Player:CharName(val)
    if val ~= nil then
        assert(type(val) == "string", "Player:CharName: arg #1 -- string expected")
        local obj = self:GetObject()
        if obj ~= nil then netRename(obj.ptr, val) end
    end

    return self:GetInfo().name
end

-- Returns player's character class (as number)
function NoxApi.Player:CharClass()
    return self:GetInfo().class
end

-- Forces player to enter monster observing mode, and then locks camera onto specified object
function NoxApi.Player:ObserveMonster(x_obj)
    local p_obj = self:GetObject()
    if p_obj == nil then return end
    if x_obj == nil then 
        playerLook(p_obj.ptr, nil)
        return
    end
    
    assert(type(x_obj) == "table", "Player:ObserveMonster: arg #1 -- table expected")
    assert(x_obj.t == "srvobj", "Player:ObserveMonster: arg #1 -- is not an object")
    assert(x_obj:Exists(), "Player:ObserveMonster: Invalid object pointer")
    
    playerLook(p_obj.ptr, x_obj.ptr)
end

-- Locks player vision to specified object; this will only have effect in observer mode
function NoxApi.Player:CameraLock(x_obj)
    if x_obj == nil then
        -- Unlock camera
        setPtrUInt(self.ptr, 0xE2C, 0)
        return
    end
    assert(type(x_obj) == "table", "Player:CameraLock: arg #1 -- table expected")
    assert(x_obj.t == "srvobj", "Player:CameraLock: arg #1 -- is not an object")
    assert(x_obj:Exists(), "Player:CameraLock: Invalid object pointer")

    -- Lock the camera on specified object
    setPtrPtr(self.ptr, 0xE2C, x_obj.ptr)
end

-- Returns current camera target for player, if present (default target is always the player itself, specifically self:GetObject():Position())
function NoxApi.Player:CameraTarget()
    local targ = getPtrPtr(self.ptr, 0xE2C)
    
    return NoxApi.Object:Init(targ)
end

-- returns true if player is in normal observer mode (ignoring creature observing)
function NoxApi.Player:IsObserver()
    return self:CheckStatus(0x1)
end

-- returns true if player is connected to server
function NoxApi.Player:IsOnline()
    return self:CheckStatus(0x10)
end

-- Returns wrapped object from playerInfo
function NoxApi.Player:GetObject()
    local uptr = getPtrPtr(self.ptr, 0x808)
    if uptr == zeroUserdata or uptr == nil then return nil end
    return NoxApi.Object:Init(uptr)
end

-- Sends a notice to this player
function NoxApi.Player:SendNotice(text)
    assert(type(text) == "string", "Player:SendNotice: arg #1 -- string expected")
    
    if netMsgBox ~= nil then
        netMsgBox(self:Id(), text)
    else
        NoxApi.Util:ConPrint("[warning] NoxApi.Player:SendNotice() -- unsupported by Unimod version")
    end
end

-- Returns or alters amount of gold carried by given player
function NoxApi.Player:Gold(val)
    if val ~= nil then
        assert(type(val) == "number", "Player:Gold: arg #1 -- number expected")
        -- Gold amount can be negative (!)
        setPtrInt(self.ptr, 0x874, val)
        ptrCall2(0x56F920, getPtrPtr(self.ptr, 0x11EC), utilSIntToPtr(val))
    end
    
    return getPtrUInt(self.ptr, 0x874)
end

-- Kicks player from server
function NoxApi.Player:Kick(reason)
    if reason == nil then reason = 4 end
    assert(type(reason) == "number", "Player:Kick: reason number expected")
    
    local id = getPtrByte(self.ptr, 0x810)
    if id == 31 then error("Player:Kick: can't kick host from server") end
    
    local result = ptrCall2(0x4DEAB0, utilUIntToPtr(id), utilUIntToPtr(reason))
    if result == zeroUserdata then return false end
    return true
end

-- Gets or sets player's mouse coordinates. Doesn't alter direction
function NoxApi.Player:MousePos(x, y)
    if x ~= nil then
        assert(type(x) == "number", "Player:MousePos: arg #1 -- x number is expected")
        assert(type(y) == "number", "Player:MousePos: arg #2 -- y number is expected")
        setPtrUInt(self.ptr, 0x8EC, x)
        setPtrUInt(self.ptr, 0x8F0, y)
    end
    return getPtrUInt(self.ptr, 0x8EC), getPtrUInt(self.ptr, 0x8F0)
end

-- Alias for NoxApi.Player:MousePos
function NoxApi.Player:CursorPos(x, y)
    return NoxApi.Player:MousePos(x, y)
end

-- Returns number of lessons for player
function NoxApi.Player:Lessons(val)
    assert(self:GetObject() ~= nil, "Player:Lessons: player is not spawned yet")
    local objptr = self:GetObject().ptr
    
    if val ~= nil then
        assert(type(val) == "number", "Player:Lessons: arg #1 -- number expected")
        playerScore(objptr, val)
    end
    
    return playerScore(objptr)
end

-- Returns current action for player (or alters it)
function NoxApi.Player:Action(actid)
    local p_obj = self:GetObject()
    if p_obj == nil then return nil end
    assert(p_obj:Exists(), "Player:Action: Invalid object pointer")
    
    local uc = getPtrPtr(p_obj.ptr, 0x2EC)
    if uc == nil then return end
    if actid == nil then return getPtrByte(uc, 0x58) end
    assert(type(actid) == "number", "Player:Action: actid number is expected")
    
    setPtrByte(uc, 0x59, getPtrByte(uc, 0x58))
    setPtrByte(uc, 0x58, actid)
    setPtrInt(self.ptr, 0x88, getFrameCounter())
    
    return actid
end

-- Returns or alters the team player is in
function NoxApi.Player:Team(val)
    local p_obj = self:GetObject()
    if p_obj == nil then return nil end
    
    -- Error checking is done in following function
    return p_obj:Team(val)
end

-- [END] NoxApi.Player

-- [BEGIN] NoxApi.Team

local function lookupTeamFields(self, v)
    return NoxApi.Team[v]
end

-- Initialize team from pointer
function NoxApi.Team:Init(arg)
    if arg == nil or arg == zeroUserdata then return nil end
    local t = {}
    t.t = "team"
    if type(arg) == "table" then t.ptr = arg.ptr end
    if type(arg) == "userdata" then t.ptr = arg end
    
    -- Validate pointer
    local team = ptrCall2(0x418B10, zeroUserdata, zeroUserdata)
    local fail = true
    while team ~= zeroUserdata do
        if team == t.ptr then fail = false break end
        team = ptrCall2(0x418B60, team, zeroUserdata)
    end
    if fail then error("Team:Init: attempt to initialize from wrong pointer") end
    
    setmetatable(t, self)
    -- Override methods
    self.__index = lookupTeamFields
    -- Override comparison
    self.__eq = function(lhs, rhs) return lhs.ptr == rhs.ptr end
    
    return t
end

-- Returns team by its numerical index or nil if unoccupied
function NoxApi.Team:ById(num)
    assert(type(num) == "number", "Team:ById: arg #1 -- team number expected")
    
    local t = teamGet(num, true)
    if t == nil then return t end
    
    return NoxApi.Team:Init(t.teamPtr)
end

-- Creates a new team with default parameters
function NoxApi.Team:Create()
    return NoxApi.Team:Init(teamCreate())
end

-- Iterates through all teams on server, calls func
function NoxApi.Team:IterateAll(func)
    if func ~= nil then assert(type(func) == "function", "Team:IterateAll: arg #1 -- function expected") end
    
    local team = ptrCall2(0x418B10, zeroUserdata, zeroUserdata)
    local ctr = 0
    while team ~= zeroUserdata do
        if func ~= nil then func(NoxApi.Team:Init(team)) end
        ctr = ctr + 1
        team = ptrCall2(0x418B60, zeroUserdata, zeroUserdata)
    end
    return ctr
end

-- Returns or alters team's name
function NoxApi.Team:Name(name)
    if name ~= nil then
        assert(type(name) == "string", "Team:Name: arg #1 -- string expected")
        if string.len(name) > 20 then name = string.sub(name, 0, 20) end
        
        local mem = memt.utilMemLdStr16(name)
        ptrCall2(0x418CD0, self.ptr, mem)
        utilMemFree(mem)
    end
    
    return memt.utilMemRdStr16(self.ptr, 0)
end

-- Returns team's identifier (may be different to color)
function NoxApi.Team:Id()
    return getPtrByte(self.ptr, 0x39)
end

-- Returns or alters team's color
function NoxApi.Team:Color(col)
    if col ~= nil then
        assert(type(col) == "number", "Team:Color: arg #1 -- color number [0;8] expected")
        if col > 8 then col = 8 end
        if col < 0 then col = 0 end
        setPtrByte(self.ptr, 0x38, col)
        ptrCall2(0x4184D0, self.ptr, zeroUserdata)
    end

    return getPtrByte(self.ptr, 0x38)
end

-- Returns or alters team's score/lessons
function NoxApi.Team:Lessons(val)
    if val ~= nil then
        assert(type(val) == "number", "Team:Lessons: arg #1 -- number expected")
        teamScore(self.ptr, val)
    end
    
    return teamScore(self.ptr)
end

-- Returns team's flag object (if present, in CTF/Chat modes; in case there is no flag, returns nil)
function NoxApi.Team:GetFlag()
    -- The flag pointers @ 0x48 are only kept in chat mode, so we have to manually re-scan them
    ptrCall2(0x418640, zeroUserdata, zeroUserdata)
    return NoxApi.Object:Init(getPtrPtr(self.ptr, 0x48))
end

-- Returns team's crown object (if present, in KoTR mode; in case there is no crown, returns nil)
function NoxApi.Team:GetCrown()
    return NoxApi.Object:Init(getPtrPtr(self.ptr, 0x4C))
end

-- [END] NoxApi.Team

-- [BEGIN] NoxApi.Server

local s_EventHandlerTable = {}

local function s_EventExecute(name, args)
    -- Check if server event was executed on client session
    if not NoxApi.Util:IsServer() then return end
    -- Guarantee that args are non-nil
    if args == nil then args = {} end
    -- Call handlers
    for _, v in pairs(s_EventHandlerTable) do
        local status, err = pcall(v, name, args)
        if not status then
            NoxApi.Util:ConPrint("Error executing event handler: " .. err)
        end
    end
end

-- [BEGIN] Event wrappers

-- we are using global table because we are not in a copy of global scope for now
_G.onMapLoad = function()
    s_EventExecute("MapSwitch", {})
end

_G.onEndGame = function()
    s_EventExecute("EndGame", {})
end

_G.onDeathmatchFrag = function(victim, attacker)
    local victim = NoxApi.Object:Init(victim)
    local attacker = NoxApi.Object:Init(attacker)
    s_EventExecute("MultiplayerKill", { victim = victim, attacker = attacker })
end

_G.playerOnJoin = function(plri)
    local w_plr = NoxApi.Player:Init(plri)
    s_EventExecute("PlayerJoin", { player = w_plr })
end

_G.playerOnLeave = function(plro)
    local w_obj = NoxApi.Object:Init(plro, true) -- Unimod returns Object instead of PlayerInfo there
    s_EventExecute("PlayerLeave", { player = w_obj:GetPlayer() })
end

_G.playerOnGoObs = function(plro)
    local w_obj = NoxApi.Object:Init(plro, true) -- Unimod returns Object instead of PlayerInfo there
    s_EventExecute("PlayerStartObserving", { player = w_obj:GetPlayer() })
end

_G.playerOnLeaveObs = function(plro)
    local w_obj = NoxApi.Object:Init(plro, true) -- Unimod returns Object instead of PlayerInfo there
    s_EventExecute("PlayerStopObserving", { player = w_obj:GetPlayer() })
end

_G.playerOnDie = function(plro)
    local w_obj = NoxApi.Object:Init(plro, true) -- Unimod returns Object instead of PlayerInfo there
    s_EventExecute("PlayerDeath", { player = w_obj:GetPlayer() })
end

_G.playerOnChat = function(plri, text, team)
    local w_plr = NoxApi.Player:ById(plri)
    local t = { player = w_plr, text = text, team = team }
    s_EventExecute("PlayerChat", t)
    if t.text == nil or t.filter then
        return true
    end
end

-- [END] Event wrappers

local function s_EventIndex(event)
    local a = 1
    for _, v in pairs(s_EventHandlerTable) do
        if v == event then
            return a
        end
        a = a + 1
    end    
    return 0 -- lua tables are indexed from 1
end

function NoxApi.Server:RegisterEvent(event)
    assert(event ~= nil, "Server:RegisterEvent: event cannot be nil")
    assert(type(event) == "function", "Server:RegisterEvent: event must be a function")

    if s_EventIndex(event) > 0 then 
        error("Server:RegisterEvent: event handler is already registered")
    end

    table.insert(s_EventHandlerTable, event)
    return true
end

function NoxApi.Server:UnregisterEvent(event)
    assert(event ~= nil, "Server:UnregisterEvent: event cannot be nil")
    assert(type(event) == "function", "Server:UnregisterEvent: event must be a function")

    local ndx = s_EventIndex(event)
    if ndx < 1 then
        error("Server:UnregisterEvent: event handler is not registered")
    end

    table.remove(s_EventHandlerTable, ndx)
    return true
end

function NoxApi.Server:UnregisterAllEvents()
    s_EventHandlerTable = {}
end

-- Plays specified sound on specified location, server side, argument safe
-- wraps soundMake
function NoxApi.Server:AudioEvent(sound, x, y)
    assert(sound ~= nil, "Server:AudioEvent: arg #1 -- sound cannot be nil")
    if type(sound) == "string" then sound = NoxApi.Util:GetSoundIdByName(sound) end
    if sound <= 0 then return end
    assert(type(x) == "number", "Server:AudioEvent: arg #2 -- x number expected")
    assert(type(y) == "number", "Server:AudioEvent: arg #3 -- y number expected")
  
    soundMake(sound, x, y)
end

-- Plays specified visual FX on specified location
function NoxApi.Server:PlayFX(name, x1, y1, x2, y2, xv)
    if type(name) == "string" then name = tryConvertStringEnum("Server:PlayFX", "MSG_FX_", name) end
    assert(type(name) == "number", "Server:PlayFX: arg #1 -- number or string expected")

    if name == NoxApi.MSG_FX_SHIELD then
        assert(type(x1) == "table", "Server:PlayFX: arg #2 -- table expected")
        assert(x1:Exists(), "Server:PlayFX: arg #2 -- invalid object pointer")
        
        netShieldFx(x1.ptr, 0, 0)
        
    elseif name == NoxApi.MSG_FX_SPARK_EXPLOSION or name == NoxApi.MSG_FX_JIGGLE or name == NoxApi.MSG_FX_ARROW_TRAP then
        assert(type(x1) == "number", "Server:PlayFX: arg #2 -- number expected")
        assert(type(y1) == "number", "Server:PlayFX: arg #3 -- number expected")
        assert(type(x2) == "number", "Server:PlayFX: arg #4 -- number expected")
        
        local pt = utilMAlloc(8)
        setPtrFloat(pt, 0, x1)
        setPtrFloat(pt, 4, y1)
        
        if name == NoxApi.MSG_FX_SPARK_EXPLOSION then
            ptrCall2(0x5231B0, pt, utilUIntToPtr(x2))
        elseif name == NoxApi.MSG_FX_ARROW_TRAP then
            ptrCall2(0x5238A0, pt, utilUIntToPtr(x2))
        elseif name == NoxApi.MSG_FX_JIGGLE then
            ptrCall2(0x4D9110, pt, utilUIntToPtr(x2))
        end
        utilMemFree(pt)
        
    elseif name == NoxApi.MSG_FX_MAGIC then
        error("Server:PlayFX: unsupported effect type")
        
    elseif name == NoxApi.MSG_FX_GREEN_BOLT then
        assert(type(x1) == "number", "Server:PlayFX: arg #2 -- number expected")
        assert(type(y1) == "number", "Server:PlayFX: arg #3 -- number expected")
        assert(type(x2) == "number", "Server:PlayFX: arg #4 -- number expected")
        assert(type(y2) == "number", "Server:PlayFX: arg #5 -- number expected")
        assert(type(xv) == "number", "Server:PlayFX: arg #6 -- number expected")
        
        local pt = utilMAlloc(16)
        setPtrInt(pt, 0, x1)
        setPtrInt(pt, 4, y1)
        setPtrInt(pt, 8, x2)
        setPtrInt(pt, 12, y2)
        ptrCall2(0x523790, pt, utilUIntToPtr(xv))
        utilMemFree(pt)
        
    elseif name >= NoxApi.MSG_FX_BLUE_SPARKS and name <= NoxApi.MSG_FX_DAMAGE_POOF or name == NoxApi.MSG_FX_RICOCHET or name == NoxApi.MSG_FX_TURN_UNDEAD or name == NoxApi.MSG_FX_WHITE_FLASH or name == NoxApi.MSG_FX_MANA_BOMB_CANCEL then
        assert(type(x1) == "number", "Server:PlayFX: arg #2 -- number expected")
        assert(type(y1) == "number", "Server:PlayFX: arg #3 -- number expected")
        
        netPointFx(name, x1, y1)
        
    elseif name >= NoxApi.MSG_FX_LIGHTNING and name <= NoxApi.MSG_FX_SENTRY_RAY or name == NoxApi.MSG_FX_VAMPIRISM or name == NoxApi.MSG_FX_PLASMA then
        assert(type(x1) == "number", "Server:PlayFX: arg #2 -- number expected")
        assert(type(y1) == "number", "Server:PlayFX: arg #3 -- number expected")
        assert(type(x2) == "number", "Server:PlayFX: arg #4 -- number expected")
        assert(type(y2) == "number", "Server:PlayFX: arg #5 -- number expected")
        
        netRayFx(name, x1, y1, x2, y2)
        
    else
        error("Server:PlayFX: unsupported effect type")
    end
end

local ptr_DeathmatchFlags = utilUIntToPtr(0x654D60)
-- Returns true if specified DeathmatchFlags are set
function NoxApi.Server:CheckDeathmatchFlag(flag)
    assert(type(flag) == "number", "Server:CheckDeathmatchFlag: arg #1 -- number expected")
    return bitAnd(getPtrUInt(ptr_DeathmatchFlags, 0), flag) > 0
end

-- Sets or clears specified DeathmatchFlags 
function NoxApi.Server:SetDeathmatchFlag(flag, val)
    assert(type(flag) == "number", "Server:SetDeathmatchFlag: arg #1 -- number expected")
    assert(type(val) == "boolean", "Server:SetDeathmatchFlag: arg #2 -- boolean expected")
    local f = getPtrUInt(ptr_DeathmatchFlags, 0)
    
    if val then
        setPtrUInt(ptr_DeathmatchFlags, 0, bitOr(f, flag))
    else
        if bitAnd(f, flag) == flag then
            setPtrUInt(ptr_DeathmatchFlags, 0, bitXor(f, flag))
        end
    end
end

-- Returns true if team damage is enabled; enables or disables it if argument is present
function NoxApi.Server:TeamDamage(val)
    if val ~= nil then
        assert(type(val) == "boolean", "Server:TeamDamage: arg #1 -- boolean expected")
        
        NoxApi.Server:SetDeathmatchFlag(1, val)
    end
    
    return NoxApi.Server:CheckDeathmatchFlag(1)
end

local ptr_ServerRuleFlags = utilUIntToPtr(0x5D5330)
-- Returns true if specified RuleFlags are set
function NoxApi.Server:CheckRuleFlag(flag)
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Server:CheckRuleFlag", "RFLAG_", flag)
    end
    assert(type(flag) == "number", "Server:CheckRuleFlag: arg #1 -- number or string expected")
    return bitAnd(getPtrUInt(ptr_ServerRuleFlags, 0), flag) > 0
end

-- Sets or clears specified RuleFlags 
function NoxApi.Server:SetRuleFlag(flag, val)
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Server:SetRuleFlag", "RFLAG_", flag)
    end
    assert(type(flag) == "number", "Server:SetRuleFlag: arg #1 -- number or string expected")
    assert(type(val) == "boolean", "Server:SetRuleFlag: arg #2 -- boolean expected")
    local f = getPtrUInt(ptr_ServerRuleFlags, 0)
    
    if val then
        --setPtrUInt(ptr_ServerRuleFlags, 0, bitOr(f, flag))
        ptrCall2(0x409E40, utilUIntToPtr(bitOr(f, flag)), zeroUserdata)
    else
        if bitAnd(f, flag) == flag then
            ptrCall2(0x409E40, utilUIntToPtr(bitXor(f, flag)), zeroUserdata)
            --setPtrUInt(ptr_ServerRuleFlags, 0, bitXor(f, flag))
        end
    end
end

-- Returns true if camper alarm is enabled; enables or disables it if argument is present
function NoxApi.Server:CamperAlarm(val)
    if val ~= nil then
        assert(type(val) == "boolean", "Server:CamperAlarm: arg #1 -- boolean expected")
        
        NoxApi.Server:SetRuleFlag(0x2000, val)
    end
    
    return NoxApi.Server:CheckRuleFlag(0x2000)
end

-- Returns number of players on the server ignoring these in observer mode
function NoxApi.Server:CountActivePlayers()
    local c = 0
    local f = function(p)
        if not p:IsObserver() then
            c = c + 1
        end
    end
    NoxApi.Player:IterateAll(f)
    return c
end

-- alters the in-game music for ALL active players
function NoxApi.Server:SetMusic(track, vol)
    assert(type(track) == "number", "Server:SetMusic: track number expected")
    assert(type(vol) == "number", "Server:SetMusic: vol number expected")
    
    if track > 29 then return false end
    if track <= 0 or vol <= 0 then 
        ptrCall2(0x516520, oneUserdata, oneUserdata) -- clearMusic
    else
        ptrCall2(0x507230, utilUIntToPtr(track), oneUserdata) -- scriptPushVal
        ptrCall2(0x507230, utilUIntToPtr(vol), oneUserdata) -- scriptPushVal
        ptrCall2(0x516430, oneUserdata, oneUserdata) -- setMusic
    end
end

-- Prints string to all players on the server
function NoxApi.Server:PrintToAll(str)
    assert(type(str) == "string", "Server:PrintToAll: arg #1 -- string expected")

    local strptr = utilMemLdStr8(str)
    ptrCall2(0x4DA390, strptr, zeroUserdata)
    utilMemFree(strptr)
end

-- Returns true if specified game mode flag was set
function NoxApi.Server:CheckMapFlag(mode)
    if type(mode) == "string" then
        mode = tryConvertStringEnum("Server:CheckMapFlag", "MAPFLAG_", flag)
    end
    assert(type(mode) == "number", "Server:CheckMapFlag: mode number or string expected")
    
    if (bitAnd(gameFlags(), mode) == mode) then return true end
    return false
end

-- Sets or unsets specified map flags
function NoxApi.Server:SetMapFlag(flag, value)
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Server:SetMapFlag", "MAPFLAG_", flag)
    end
    assert(type(flag) == "number", "Server:SetMapFlag: arg #1 -- number or string expected")
    assert(type(val) == "boolean", "Server:SetMapFlag: arg #2 -- boolean expected")
    local f = gameFlags()
    
    if val then
        gameFlags(bitOr(f, flag))
    else
        if bitAnd(f, flag) == flag then
            gameFlags(bitXor(f, flag))
        end
    end
end

-- [END] NoxApi.Server

-- [BEGIN] NoxApi.Util

-- Alias for Server:CheckMapFlag (value is shared between client and server)
function NoxApi.Util:CheckMapFlag(mode)
    return NoxApi.Server:CheckMapFlag(mode)
end

-- Returns numerical buff id from specified string literal. -1 if not found.
function NoxApi.Util:GetBuffIdByName(name)
    assert(type(name) == "string", "Util:GetBuffIdByName: string expected")
    -- prepend ENCHANT_
    if string.sub(name, 0, 8) ~= "ENCHANT_" then name = "ENCHANT_" .. name end
    
    local mstr = utilMemLdStr8(name)
    local result = ptrCall2(0x424880, mstr, zeroUserdata)
    utilMemFree(mstr)
    if result == zeroUserdata and result ~= "ENCHANT_INVISIBLE" then return -1 end
    return utilPtrToInt(result)
end

-- Returns numerical spell id from specified string literal. -1 if not found.
function NoxApi.Util:GetSpellIdByName(name)
    assert(type(name) == "string", "Util:GetSpellIdByName: string expected")
    -- prepend SPELL_
    if string.sub(name, 0, 6) ~= "SPELL_" then name = "SPELL_" .. name end

    local mstr = utilMemLdStr8(name)
    local result = ptrCall2(0x4243F0, mstr, zeroUserdata)
    utilMemFree(mstr)
    if result == zeroUserdata then return -1 end
    return utilPtrToInt(result)
end

-- Returns monster action id from specified string literal. -1 if not found.
function NoxApi.Util:GetActionIdByName(name)
    assert(type(name) == "string", "Util:GetActionIdByName: string expected")
    -- prepend ACTION_
    if string.sub(name, 0, 7) ~= "ACTION_" then name = "ACTION_" .. name end

    local result = NoxApi[name]
    if type(result) ~= "number" then return -1 end
    return result
end

-- Returns numeric sound id from string name
function NoxApi.Util:GetSoundIdByName(name)
    assert(type(name) == "string", "Util:GetSoundIdByName: string expected")
    
    local mstr = utilMemLdStr8(name)
    local ud = ptrCall2(0x40AF50, mstr, oneUserdata)
    utilMemFree(mstr)
    return utilPtrToInt(ud)
end

-- Returns thingId for specified thing name.
function NoxApi.Util:GetThingId(name)
    assert(type(name) == "string", "Util:GetThingId: name string expected")
    
    local mstr = utilMemLdStr8(name)
    local res = ptrCall2(0x4E3AA0, mstr, zeroUserdata)
    utilMemFree(mstr)
    return utilPtrToInt(res)
end

-- Returns numerical Id for specified enchantment name, -1 if not found
function NoxApi.Util:GetItemEnchantId(name)
    assert(type(name) == "string", "Util:GetItemEnchantId: name string expected")
    
    local mstr = utilMemLdStr8(name)
    local res = ptrCall2(0x413290, mstr, zeroUserdata)
    utilMemFree(mstr)
    res = utilPtrToInt(res)
    if res == 255 then return -1 end 
    return res
end

-- Prints specified message onto game console (client side)
function NoxApi.Util:ConPrint(text, color)
    assert(type(text) == "string", "Util:ConPrint: arg #1 -- string expected")

    if (color == nil) or (color == 0) then
        color = 4
    end
    assert(type(color) == "number", "Util:ConPrint: arg #2 -- number expected")
    
    local str = utilMemLdStr16(text) -- *wchar_t
    ptrCall2(0x450B90, utilUIntToPtr(color), str)
    utilMemFree(str) -- freeing temporary memory
    -- string gets copied to another buffer
end

--local musicStackTop = utilUIntToPtr(0x69BA74)
local musicCurTrack = utilUIntToPtr(0x69B970) -- client-side

-- returns current music track and volume
function NoxApi.Util:GetMusic()
    return getPtrUInt(musicCurTrack, 0), getPtrUInt(musicCurTrack, 4)
end

-- Returns true if this session hosts a server or solo game
function NoxApi.Util:IsServer()
    return bitAnd(gameFlags(), 0x801) > 0
end

local ptr_PlasmaJmp = utilUIntToPtr(0x4BA99B)
-- Unlock Plasma/Staff of Oblivion visuals in multiplayer (only for client though)
function NoxApi.Util:UnlockPlasma(val)
    if val then 
        setPtrByte(ptr_PlasmaJmp, 0, 0xEB)
    else
        setPtrByte(ptr_PlasmaJmp, 0, 0x75)
    end
end

local ptr_GameGFlags = utilUIntToPtr(0x85B7A0)
-- Returns true if specified GFlags are set
function NoxApi.Util:CheckGFlag(flag)
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Util:CheckGFlag", "GFLAG_", flag)
    end
    assert(type(flag) == "number", "Util:CheckGFlag: arg #1 -- number or string expected")
    return bitAnd(getPtrUInt(ptr_GameGFlags, 0), flag) > 0
end

-- Sets or clears specified GFlags 
function NoxApi.Util:SetGFlag(flag, val)
    if type(flag) == "string" then
        flag = tryConvertStringEnum("Util:SetGFlag", "GFLAG_", flag)
    end
    assert(type(flag) == "number", "Util:SetGFlag: arg #1 -- number or string expected")
    assert(type(val) == "boolean", "Util:SetGFlag: arg #2 -- boolean expected")
    local f = getPtrUInt(ptr_GameGFlags, 0)
    
    if val then
        setPtrUInt(ptr_GameGFlags, 0, bitOr(f, flag))
    else
        if bitAnd(f, flag) == flag then
            setPtrUInt(ptr_GameGFlags, 0, bitXor(f, flag))
        end
    end
end

local ptr_GameFPS = utilUIntToPtr(0x85B3FC)
-- Returns Frames per second value
function NoxApi.Util:GetGameFPS()
    return getPtrInt(ptr_GameFPS, 0)
end

-- returns distance^2 between two points
function NoxApi.Util:DistanceSq(x1, y1, x2, y2)
    assert(type(x1) == "number" and type(y1) == "number", "Util:DistanceSq: arg #1, #2 -- x1, y1 number expected")
    assert(type(x1) == "number" and type(y2) == "number", "Util:DistanceSq: arg #3, #4 -- x2, y2 number expected")
    
    local dx = x1 - x2
    local dy = y1 - y2
    return dx * dx + dy * dy
end
    
-- Returns distance between two points 
function NoxApi.Util:Distance(x1, y1, x2, y2)
    assert(type(x1) == "number" and type(y1) == "number", "Util:Distance: arg #1, #2 -- x1, y1 number expected")
    assert(type(x1) == "number" and type(y2) == "number", "Util:Distance: arg #3, #4 -- x2, y2 number expected")

    return math.sqrt(NoxApi.Util:DistanceSq(x1, y1, x2, y2))
end

local ptr_Build = utilUIntToPtr(0x5D532C)
local ptr_SrvName = utilUIntToPtr(0x5D4AC0)
local ptr_MapName = utilUIntToPtr(0x85B420)
-- Returns information about current game session
function NoxApi.Util:GetGameInfo()
    local r = {}
    -- These are separate for client and player (!)
    local gd = ptrCall2(0x4165B0, zeroUserdata, zeroUserdata)
    -- Returns offset value based on current game mode (!)
    local gd_26 = utilUIntToPtr(getPtrShort(gd, 52)) 
    
    r.build = bitAnd(getPtrUInt(ptr_Build, 0), 0xFFFF)
    r.server = memt.utilMemRdStr8(ptr_SrvName)
    r.mapflags = gameFlags() -- These are actually |map| flags, 'general' game flags are different
    r.gamemode = ptrCall2(0x4573C0, utilUIntToPtr(r.mapflags), zeroUserdata)
    r.gamemode = memt.utilMemRdStr16(r.gamemode)

    r.mapname = mapGetName() --memt.utilMemRdStr8(ptr_MapName)
    r.p_online = ptrCall2(0x416F40, zeroUserdata, zeroUserdata)
    r.p_online = utilPtrToInt(r.p_online)
    r.p_max = ptrCall2(0x409FA0, zeroUserdata, zeroUserdata)
    r.p_max = utilPtrToInt(r.p_max)
    
    r.timelimit = ptrCall2(0x40A180, gd_26, zeroUserdata)
    r.timelimit = utilPtrToInt(r.timelimit)
    r.lessonlimit = ptrCall2(0x40A020, gd_26, zeroUserdata)
    r.lessonlimit = utilPtrToInt(r.lessonlimit)
    return r
end

function NoxApi.Util:Debug()
    NoxApi.Util:ConPrint(string.format("NoxApi by AngryKirC [version: %d]", NoxApi.Version), 13)
    if netGetVersion ~= nil then NoxApi.Util:ConPrint(string.format("UniMod version: %d", netGetVersion()), 9) end
    -- bugs
    if memt.bug then NoxApi.Util:ConPrint("Signed setPtrInt bug detected (this is ok)") end
    -- features
    if unitInventoryPlace ~= nil then NoxApi.Util:ConPrint("Native Object:InventoryPut() support detected", 9) end
    if unitCheckExists ~= nil then NoxApi.Util:ConPrint("Native Object:Exists() support detected", 9) end
    -- stats
    NoxApi.Util:ConPrint(string.format("Non-freed memory pointers: %d", memt.memoryPointers))
    NoxApi.Util:ConPrint(string.format("Event handlers count: %d", #s_EventHandlerTable))
end

function NoxApi.Util:Unload()
    NoxApi.Server:UnregisterAllEvents()
    if memt ~= nil then
        utilMemFree(memt.t)
        memt = nil
    end
    NoxApi = nil
    -- Undo event handlers 
    _G.onMapLoad = nil
    _G.onEndGame = nil
    _G.onDeathmatchFrag = nil
    _G.playerOnJoin = nil
    _G.playerOnLeave = nil
    _G.playerOnGoObs = nil
    _G.playerOnLeaveObs = nil
    _G.playerOnDie = nil
    _G.playerOnChat = nil
    -- Unload package
    package.loaded["noxapi"] = nil
end

-- [END] NoxApi.Util

return NoxApi