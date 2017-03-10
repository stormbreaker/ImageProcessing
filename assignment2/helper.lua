require "ip"

local il = require "il"
local math = require "math"

local function reflection(x, y, maxX, maxY)
  
  while ((x < 0 or x > maxX) or (y < 0 or y > maxY)) do
    
    if x < 0 then
      x = 0 - x - 1
    elseif x > maxX then
      x = 2 * maxX - x + 1
    end
    
    if y < 0 then
      y = 0 - y - 1
    elseif y > maxY then
      y = 2 * maxY - y + 1
    end
  end
  
  return x, y
end
  
--print(reflection(1, 1, 5, 5))

return 
{
  reflection = reflection
}  