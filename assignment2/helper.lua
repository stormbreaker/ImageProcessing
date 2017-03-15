require "ip"

local il = require "il"
local math = require "math"

local tempFilter = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}

--[[
Author: Benjamin Kaiser
Description: 
]]
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

--[[
Author: Taylor Doell
Description: 
]]
local function rotate45(filter)
  tempFilter[2][1] = filter[1][1]
  tempFilter[3][1] = filter[2][1]
  tempFilter[3][2] = filter[3][1]
  tempFilter[3][3] = filter[3][2]
  tempFilter[2][3] = filter[3][3]
  tempFilter[1][3] = filter[2][3]
  tempFilter[1][2] = filter[1][3]
  tempFilter[1][1] = filter[1][2]
  --tempFilter[2][2] = filter[2][2]
  
  for rowCopy = 1, 3 do
    for colCopy = 1, 3 do
      filter[rowCopy][colCopy] = tempFilter[rowCopy][colCopy]
    end
  end
  
  return filter
end


return 
{
  reflection = reflection,
  rotate45 = rotate45
}  