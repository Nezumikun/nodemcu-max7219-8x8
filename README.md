# nodemcu-max7219-8x8
A NodeMCU library to write to MAX7219 8x8 matrix displays using SPI

Based on https://github.com/marcelstoer/nodemcu-max7219

## Example
```Lua
max7219 = require("max7219_8x8")
max7219.setup({
    numberOfModules = 4,
    slaveSelectPin = 8,
    intensity = 1,
    rotate = "left",
    drawMode = "mix"
})
max7219.clear()

a = { 0x20, 0x74, 0x54, 0x54, 0x3C, 0x78, 0x40, 0x00 }
b = { 0x41, 0x7F, 0x3F, 0x48, 0x48, 0x78, 0x30, 0x00 }
c = { 0x38, 0x7C, 0x44, 0x44, 0x6C, 0x28, 0x00, 0x00 }
d = { 0x30, 0x78, 0x48, 0x49, 0x3F, 0x7F, 0x40, 0x00 }

max7219.draw_sprite(0, 0, a)
max7219.draw_sprite(8, 0, b)
max7219.draw_sprite(16, 0, c)
max7219.draw_sprite(24, 0, d)

max7219.update()
```
