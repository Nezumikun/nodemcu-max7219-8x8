--------------------------------------------------------------------------------
-- MAX7219 module (8x8 LED Matrix only) for NodeMCU
-- SOURCE: https://github.com/Nezumikun/nodemcu-max7219-8x8
-- AUTHOR: alexey dot kozhevnikov at gmail dot com
-- LICENSE: http://opensource.org/licenses/MIT
--------------------------------------------------------------------------------

-- Set module name as parameter of require
local modname = ...
local M = {}
_G[modname] = M
--------------------------------------------------------------------------------
-- Local variables
--------------------------------------------------------------------------------
local debug = false
local numberOfModules
-- ESP8266 pin which is connected to CS of the MAX7219
local slaveSelectPin
local totalRotate = "none"
local drawMode = "replace"
local buffer = {}

local MAX7219_REG_DECODEMODE = 0x09
local MAX7219_REG_INTENSITY = 0x0A
local MAX7219_REG_SCANLIMIT = 0x0B
local MAX7219_REG_SHUTDOWN = 0x0C
local MAX7219_REG_DISPLAYTEST = 0x0F

--------------------------------------------------------------------------------
-- Local/private functions
--------------------------------------------------------------------------------
local function start_write()
    gpio.write(slaveSelectPin, gpio.LOW)
end

local function stop_write()
    gpio.write(slaveSelectPin, gpio.HIGH)
end

local function write_to_all(register, data)
    start_write()
    for i = 1, numberOfModules do
        local write_data = register * 256 + data
        spi.send(1, write_data)
    end
    stop_write()
end

local function set_byte(module, row, value, draw_mode)
    draw_mode = draw_mode ~= nil and draw_mode or drawMode
    local index = row * numberOfModules + module + 1
    if draw_mode == "mix" then
        buffer[index] = bit.bor(buffer[index], bit.band(value, 0xff))
    else
        buffer[index] = bit.band(value, 0xff)
    end
end

local function get_byte(module, row)
    local index = row * numberOfModules + module + 1
    return buffer[index]
end

local function rotate_left(bytes)
    local result = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
    for i = 1, 8 do
        local mask = 0x80
        for j = 1, 8 do
            local index = 8 - j + 1
            result[index] = bit.lshift(result[index], 1)
            if bit.band(mask, bytes[i]) ~= 0 then
                result[index] = bit.bor(result[index], 0x01)
            end
            mask = bit.rshift(mask, 1)
        end
    end
    return result
end

--------------------------------------------------------------------------------
-- Public functions
--------------------------------------------------------------------------------

function M.setup(config)
    local lconfig = config or {}
    
    numberOfModules = assert(lconfig.numberOfModules, "'numberOfModules' is a mandatory parameter")
    slaveSelectPin = assert(lconfig.slaveSelectPin, "'slaveSelectPin' is a mandatory parameter")
    totalRotate = lconfig.rotate and lconfig.rotate or "none"
    drawMode = lconfig.drawMode and lconfig.drawMode or "replace"
    
    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 16, 8)
    -- Must NOT be done _before_ spi.setup() because that function configures all HSPI* pins for SPI. Hence,
    -- if you want to use one of the HSPI* pins for slave select spi.setup() would overwrite that.
    gpio.mode(slaveSelectPin, gpio.OUTPUT)
    stop_write()

    write_to_all(MAX7219_REG_SCANLIMIT, 7)
    write_to_all(MAX7219_REG_DECODEMODE, 0x00)
    write_to_all(MAX7219_REG_DISPLAYTEST, 0)
    M.set_intensity(lconfig.intensity and lconfig.intensity or 1)
    M.clear()
    M.update()
    M.turn_on()
end

function M.update()
    for row = 0, 7 do
        start_write()
        for module = 0, numberOfModules - 1 do
            local index = row * numberOfModules + module + 1
            local write_data = (row + 1) * 256 + buffer[index]
            spi.send(1, write_data)
        end
        stop_write()
    end
end

function M.draw_sprite(x, y, bytes, rotate)
    if rotate == nil then
        rotate = totalRotate
    end
    if rotate == "left" then
        bytes = rotate_left(bytes)
    end
    local module = math.floor(x/8)
    local shift = x % 8
    if shift > 0 then
        shift = 8 - shift
    end
    for i = 1, #bytes do
        local value = bytes[i]
        if shift > 0 then
            value = bit.lshift(value, shift)
            set_byte(module, y + i - 1, bit.rshift(value, 8))
            if module + 1 < numberOfModules then
                set_byte(module + 1, y + i - 1, value)
            end
        else
            set_byte(module, y + i - 1, value)
        end
    end
end

function M.set_pixel(x, y, value)
    local module = math.floor(x/8)
    if module < 0 or module >= numberOfModules then
        return
    end
    local temp = get_byte(module, y)
    if value > 0 then
        temp = bit.bor(temp, bit.rshift(0x100, x % 8 + 1))
    else
        temp = bit.band(temp, bit.rshift(0xfeff, x % 8 + 1))
    end
    set_byte(module, y, temp, "replace")
end

function M.fill()
    for module = 0, numberOfModules - 1 do
        for row = 0, 7 do
            set_byte(module, row, 0xff, "replace")
        end
    end
end

function M.clear()
    for module = 0, numberOfModules - 1 do
        for row = 0, 7 do
            set_byte(module, row, 0x00, "replace")
        end
    end
end

function M.set_intensity(value)
    if value >= 16 then
        value = 15
    elseif value < 0 then
        value = 0
    end
    write_to_all(MAX7219_REG_INTENSITY, value)
end

function M.turn_on()
    write_to_all(MAX7219_REG_SHUTDOWN, 1)
end

function M.turn_off()
    write_to_all(MAX7219_REG_SHUTDOWN, 0)
end

return M
