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


local function rotate45(filter)
  local tempFilter = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
  tempFilter[2][1] = filter[1][1]
  tempFilter[3][1] = filter[2][1]
  tempFilter[3][2] = filter[3][1]
  tempFilter[3][3] = filter[3][2]
  tempFilter[2][3] = filter[3][3]
  tempFilter[1][3] = filter[2][3]
  tempFilter[1][2] = filter[1][3]
  tempFilter[1][1] = filter[1][2]
  --tempFilter[2][2] = filter[2][2]
  
  --[[for colCopy = 1, 3 do
    for rowCopy = 1, 3 do
      filter[colCopy][rowCopy] = tempFilter[colCopy][rowCopy]
    end
  end]]
  
  return tempFilter
end

function rotate_kirsch( rot )
  if rot == 0 then --East
    return {
      {-3,-3, 5},
      {-3, 0, 5},
      {-3,-3, 5}
    }
  elseif rot == 1 then --North East
    return {
      {-3, 5, 5},
      {-3, 0, 5},
      {-3,-3,-3}
    }
  elseif rot == 2 then --North
    return {
      { 5, 5, 5},
      {-3, 0,-3},
      {-3,-3,-3}
    }
  elseif rot == 3 then --North West
    return {
      { 5, 5,-3},
      { 5, 0,-3},
      {-3,-3,-3}
    }
  elseif rot == 4 then  --West
    return {
      {5,-3,-3},
      {5, 0,-3},
      {5,-3,-3}
    }
  elseif rot == 5 then --South West
    return {
      {-3,-3,-3},
      { 5, 0,-3},
      { 5, 5,-3}
    }
  elseif rot == 6 then --South
    return {
      {-3,-3,-3},
      {-3, 0,-3},
      { 5, 5, 5}
    }
  else              --South East
    return {
      {-3,-3,-3},
      {-3, 0, 5},
      {-3, 5, 5}
    }
  end
end

return 
{
  reflection = reflection,
  rotate45 = rotate45,
  rot = rotate_kirsch
}  