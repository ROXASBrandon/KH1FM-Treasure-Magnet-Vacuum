-- Treasure Magnet Vacuum v1.0.0
-- Steam Global 1.0.0.2 / LuaBackend. Standalone; no shared packages required.
-- Expands item AND HP/MP/munny pickup radius by 500x with Treasure Magnet.
-- Does not grant abilities or change AP. Remove and restart to restore range.
-- Range functions reverse-engineered and verified against this Steam build.

LUAGUI_NAME = "Treasure Magnet Vacuum"
LUAGUI_AUTH = "ROXASBrandon"
LUAGUI_DESC = "500x Treasure Magnet range for items and HP/MP/munny orbs."

local A = { rangeOne=0x2AB539, rangeTwo=0x2AB543, rangeData=0x2AB588 }
local enabled = false
local rangeAttempted = false

function _OnInit()
    enabled = false
    rangeAttempted = false
    if GAME_ID ~= 0xAF71841E or ENGINE_TYPE ~= "BACKEND" then
        ConsolePrint("Treasure Magnet Vacuum: KH1 LuaBackend required; disabled.")
        return
    end
    if ReadByte(0x4698D2) ~= 106
        or ReadInt(0x3EA388) ~= 540680280
        or ReadByte(0x26E20C) ~= 9 then
        ConsolePrint("Treasure Magnet Vacuum: unsupported executable; disabled. Requires Steam Global 1.0.0.2.")
        return
    end
    enabled = true
    ConsolePrint("Treasure Magnet Vacuum: Steam Global 1.0.0.2 detected.")
end

local function bytesMatch(address, expected)
    for i, value in ipairs(expected) do
        if ReadByte(address + i - 1) ~= value then return false end
    end
    return true
end

local function expandMagnetRange()
    if rangeAttempted then return end
    rangeAttempted = true
    -- Items and orbs use separate functions, both counting equipped ability 5.
    -- Redirect their four range loads to private squared-distance constants.
    -- 200 -> 100000 and 400 -> 200000: 500x radius, 250000x squared threshold.
    -- The orb function also reuses its one-copy register for one base pickup
    -- mode, so that mode gets the large radius even without the ability.
    -- Shared constants are untouched. Private floats occupy verified INT3
    -- padding after a RET, before the next function at 0x2AB590.
    local nearSquared, farSquared = 10000000000, 40000000000
    local loads = {
        {address=A.rangeOne, size=8, offset=4, original=0x1428E7, slot=0, prefix={0xF3,0x0F,0x10,0x35}},
        {address=A.rangeTwo, size=8, offset=4, original=0x144185, slot=4, prefix={0xF3,0x0F,0x10,0x35}},
        {address=0x2AC145, size=8, offset=4, original=0x141CDB, slot=0, prefix={0xF3,0x0F,0x10,0x3D}},
        {address=0x2AC156, size=9, offset=5, original=0x143571, slot=4, prefix={0xF3,0x44,0x0F,0x10,0x1D}},
    }
    local paddingFree = bytesMatch(A.rangeData, {0xCC,0xCC,0xCC,0xCC,0xCC,0xCC,0xCC,0xCC})
    local nearCurrent, farCurrent = ReadFloat(A.rangeData), ReadFloat(A.rangeData + 4)
    local paddingOurs = (nearCurrent == 360000 and farCurrent == 1440000)
        or (nearCurrent == nearSquared and farCurrent == farSquared)
    if not bytesMatch(0x2AB522, {0xB9,0x05,0,0,0,0x0F,0xB7,0x50,0x4C})
        or not bytesMatch(0x2AC268, {0xB9,0x05,0,0,0,0x0F,0xB7,0x50,0x4C})
        or not (paddingFree or paddingOurs) then
        ConsolePrint("Treasure Magnet Vacuum: range signature mismatch; range patch skipped.")
        return
    end
    for _, load in ipairs(loads) do
        load.target = A.rangeData + load.slot - (load.address + load.size)
        load.current = ReadInt(load.address + load.offset) % 0x100000000
        -- RIP-relative offsets can be negative. LuaBackend may return unsigned.
        if load.target < 0 then load.target = load.target + 0x100000000 end
        if not bytesMatch(load.address, load.prefix)
            or (load.current ~= load.original and load.current ~= load.target) then
            ConsolePrint("Treasure Magnet Vacuum: item/orb range signature mismatch; range patch skipped.")
            return
        end
    end
    if nearCurrent ~= nearSquared then WriteFloat(A.rangeData, nearSquared) end
    if farCurrent ~= farSquared then WriteFloat(A.rangeData + 4, farSquared) end
    if ReadFloat(A.rangeData) ~= nearSquared or ReadFloat(A.rangeData + 4) ~= farSquared then
        ConsolePrint("Treasure Magnet Vacuum: range data write failed; range patch skipped.")
        return
    end
    for _, load in ipairs(loads) do
        if load.current ~= load.target then WriteInt(load.address + load.offset, load.target) end
        if ReadInt(load.address + load.offset) % 0x100000000 ~= load.target then
            ConsolePrint("Treasure Magnet Vacuum: range instruction write failed; restart before retrying.")
            return
        end
    end
    ConsolePrint("Treasure Magnet Vacuum: VACUUM active for items AND HP/MP/munny orbs (500x radius). Keep Treasure Magnet equipped.")
end

function _OnFrame()
    if enabled then expandMagnetRange() end
end
