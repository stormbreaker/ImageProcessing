--[[
  Authors: Benjamin Kaiser and Taylor Doell
  This file contains helper functions that may be called by our other functions.  These functions include reflection of image borders and rotation of filters.  
]]

require "ip"

local il = require "il"
local math = require "math"

-- This table is here for performance reasons in the rotate function
local tempFilter = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}

--[[
  Author: Benjamin Kaiser
  Description: This function takes in an x and y coordinates as well as
  the max x and y coordinates to perform reflection of image borders.
  If the item trying to be processed is much larger than the size of
  the image, it bounces back and forth until it settles on a pixel which
  is actually part of the image.  
]]
local function reflection(x, y, maxX, maxY)
  
  -- Loop until we found a pixel inside of the image
  while ((x < 0 or x > maxX) or (y < 0 or y > maxY)) do
    -- pixel falls out on the left side
    if x < 0 then
      x = 0 - x - 1
    -- pixel falls out on the right side
    elseif x > maxX then
      x = 2 * maxX - x + 1
    end
    
    --pixel falls out above
    if y < 0 then
      y = 0 - y - 1
    -- pixel falls out below
    elseif y > maxY then
      y = 2 * maxY - y + 1
    end
  end
  
  return x, y
end

--[[
Author: Taylor Doell
Description: This function uses a local table that is only global
  to this file and uses it to rotate the filter 45 degrees. At the
  end we copy the filter values back into the filter passed in to
  prevent using the same reference and ruining the filter. Once the
  table is copied, it is returned to the caller.
]]
local function rotate45(filter)
  -- Rotate filter by hand
  tempFilter[2][1] = filter[1][1]
  tempFilter[3][1] = filter[2][1]
  tempFilter[3][2] = filter[3][1]
  tempFilter[3][3] = filter[3][2]
  tempFilter[2][3] = filter[3][3]
  tempFilter[1][3] = filter[2][3]
  tempFilter[1][2] = filter[1][3]
  tempFilter[1][1] = filter[1][2]
  
  -- Copy filter to prevent using the same reference
  for rowCopy = 1, 3 do
    for colCopy = 1, 3 do
      filter[rowCopy][colCopy] = tempFilter[rowCopy][colCopy]
    end
  end
  
  return filter
end

-- Expose methods in order to call from other files
return 
{
  reflection = reflection,
  rotate45 = rotate45
}  