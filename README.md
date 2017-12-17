# nodemcu-max7219-8x8
A NodeMCU library to write to MAX7219 8x8 matrix displays using SPI

Based on https://github.com/marcelstoer/nodemcu-max7219

## Require
```Lua
max7219 = require("max7219_8x8")
```
## Release
```lua
max7219 = nil
package.loaded["max7219_8x8"]=nil
```
## API

### setup(config)
#### Description
Setting the parameters of led matrix.
#### Parameters
config: a table with parameters:
* **slaveSelectPin**: number of pin which is connected to CS of the MAX7219
* **numberOfModules**: count of connected modules
* intensity: bright value (1 - 15)
* rotate: rotate all sprites on draw. Avalable values are "none" and "left". Default value is "none"
* drawMode: mode of draw sprites/ Available values are "mix" (bitwize OR) and "replace". Default value is "replace"
#### Returns
nil
#### Example
```Lua
max7219.setup({
    numberOfModules = 4,
    slaveSelectPin = 8,
    intensity = 1,
    rotate = "left",
    drawMode = "mix"
})
```

### clear()
#### Description
Clear buffer
#### Parameters
nil
#### Returns
nil
#### Example
```Lua
max7219.clear()
```

### fill()
#### Description
Fill buffer to on all leds
#### Parameters
nil
#### Returns
nil
#### Example
```Lua
max7219.fill()
```

### turn_off()
#### Description
Turn off led panel, but save state leds.
#### Parameters
nil
#### Returns
nil
#### Example
```Lua
max7219.turn_off()
```

### turn_on()
#### Description
Turn on led panel. Setup call this function
#### Parameters
nil
#### Returns
nil
#### Example
```Lua
max7219.turn_on()
```

### draw_sprite(x, y, bytes, rotate)
#### Description
Draw one sprite 8x8 in buffer
#### Parameters
* x - horizontal coordinate
* y - vertical coordinate (now not work, reserved)
* bytes - table of 8 bytes
* rotate - not required parameter, can overwrite global settings
#### Returns
nil
#### Example
```Lua
a = { 0x20, 0x74, 0x54, 0x54, 0x3C, 0x78, 0x40, 0x00 }
b = { 0x41, 0x7F, 0x3F, 0x48, 0x48, 0x78, 0x30, 0x00 }
c = { 0x38, 0x7C, 0x44, 0x44, 0x6C, 0x28, 0x00, 0x00 }
d = { 0x30, 0x78, 0x48, 0x49, 0x3F, 0x7F, 0x40, 0x00 }

max7219.draw_sprite(0, 0, a)
max7219.draw_sprite(8, 0, b)
max7219.draw_sprite(16, 0, c)
max7219.draw_sprite(24, 0, d)
```

### set_pixel(x, y, value)
#### Description
Set pixel on or off
#### Parameters
* x - horizontal coordinate
* y - vertical coordinate
* value - integer variable. Use 0 if you want off pixel, or any other value if you want on pixel
#### Returns
nil
#### Example
```Lua
max7219.set_pixel(0, 0, 1) -- on
max7219.set_pixel(0, 0, 0) -- off
```
### set_intensity(value)
#### Description
Set bright of panel
#### Parameters
* value - bright value (1 - 15)
#### Returns
nil
#### Example
```Lua
max7219.set_intensity(5)
```

### update()
#### Description
Send image from buffer to led matrix
#### Parameters
nil
#### Returns
nil
#### Example
```Lua
max7219.update()
```

## Example of tipical usage
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
