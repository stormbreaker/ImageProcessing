 --[[
 Authors: Benjamin Kaiser and Taylor Doell
 This file contains all of the functions required to fill the point process menu items.  
]]

require "ip"
local il = require "il"
local math = require "math"
local bit = require "bit"
local hist = require "histogram"

--[[
    Author: Benjamin Kaiser
    Description:  This function converts an image into grayscale by taking 30% of the red, 59% of the green and 11% of the blue
    components and assigns this value to each of the same components for that pixel.  This is calculated for each pixel and
    doesn't use a look up table.  
]]
local function convertToGrayScale(img)
  local rows, columns = img.height, img.width
  
  local sum
  for row = 0, rows-1 do
    for column = 0, columns-1 do
        -- compute the weighted sum
        sum = .3 * img:at(row, column).r + .59 * img:at(row, column).g + .11 * img:at(row, column).b
        img:at(row, column).r = sum
        img:at(row, column).g = sum
        img:at(row, column).b = sum
      end
    end
 return img
end

--[[
    Author: Taylor Doell
    Description: This function uses a lambda function to pass
      to mapPixels to compute the image negative. This lambda
      function was written by Dr. Weiss.
]]
local function negate(img)
  return img:mapPixels( function( r, g, b )
      return 255 - r, 255 - g, 255 - b
    end
  )
end

--[[
    Author: Benjamin Kaiser
    Description: This function takes in an image and a value between 0 and 255 inclusive.  It then loops through the entire image
    and then checks to see if the intensity value of the image converted to YIQ is greater then or equal to that threshold or less
    than that threshold.  If it is above the threshold, then the intensity is set to 255 and if it is below, then the intensity is
    set to 0.  
]]
local function binaryThreshold(img, threshold)
  local rows, columns = img.height, img.width
  
  -- necessary to retrive a black and white image at the end without weird colorings
  img = convertToGrayScale(img)
  
  --process image
  img = il.RGB2YIQ(img)
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      -- check to see if pixel intensity is above or below the required threshold
      if img:at(row, column).y >= threshold then
        img:at(row, column).y = 255
      elseif img:at(row, column).y < threshold then
        img:at(row, column).y = 0
      end
    end
  end
  return il.YIQ2RGB(img)
end

--[[
    Author: Benjamin Kaiser
    Description:  This function takes an image and the number of levels that the images needs to
    be posterized into.  In other words, the discrete number of intensity levels that need to be displayed
    on this picture.  These levels are computed and stored into a lookup table which saves on calculations.
    When looping through the picture, then the values are loaded directly from the look up table.  
    We perform clipping so that if a computed value is above 255, we set the value to 255 exactly.  
]]
local function posterize(img, numberOfLevels)
  local rows, columns = img.height, img.width
  
  local incrementValue = math.floor(256/(numberOfLevels - 1))
  local numberEachLevel = math.floor(256/numberOfLevels + .5)
  local currentLevel = 0
  local counter = 0
  
  local lookUpTable = {}
  --compute lookup table
  for index = 0, 255 do
    if counter == numberEachLevel - 1 then
      counter = 0
      currentLevel = currentLevel + incrementValue
      --clipping
      if currentLevel > 255 then
        currentLevel = 255
      end
    end
    counter = counter + 1
    lookUpTable[index] = currentLevel
  end
  
  img = il.RGB2YIQ(img)
  
  --loop through image
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      local pixel = img:at(row, column).y
      pixel = lookUpTable[pixel]
      img:at(row, column).y = pixel
    end
  end
  
  return il.YIQ2RGB(img)
end

--[[
    Author: Taylor Doell
    Description: This function modifies each pixels intensity
      value by adding the brightness amount to the intensity.
      To prevent overflowing our pixel value, we store the modified
      value in a local variable and then clip that value if it
      is above or below the max and min value that an intensity
      value can be.
]]
local function brightness(img, amount)
  local rows, columns = img.height, img.width

  img = il.RGB2YIQ(img) -- Convert image to YIQ to modify intensities

  -- Loop through all pixels to modify brightness
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      local pixel = img:at(row, col).y
      
      pixel = pixel + amount

      -- Clip the pixel intensity to prevent overflow
      if pixel > 255 then
        pixel = 255
      elseif pixel < 0 then
        pixel = 0
      end
      
      img:at(row, col).y = pixel
    end
  end

  -- Return as RGB to show properly
  return il.YIQ2RGB(img)
end

--[[
    Author: Taylor Doell
    Description: This function calculates the slope of the line between
      the startpoint and the endpoint to use in the y=mx + b when creating
      the lookup table. Then the function uses the LUT to set the new
      intensity value for that pixel.
]]
local function contrast(img, startPoint, endPoint)
  local rows, columns = img.height, img.width
  local slope = 255 / (endPoint - startPoint) -- Calculate slope of line
  local intercept = -startPoint * slope -- Calculate intercept of line
  local table = {}
  
  img = il.RGB2YIQ(img)
  
  -- Loop through all intensities to compute LUT
  for i = 0, 255 do
    if i <= startPoint then
      table[i] = 0
    elseif i >= endPoint then
      table[i] = 255
    else
      -- Computer y = mx + b to get new intensity value at the current intensity
      table[i] = slope * i + intercept
    end
  end
    
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      -- Use LUT to map the old intensity value to the new intensity value
      img:at(row, col).y = table[img:at(row, col).y];
    end
  end
  
  return il.YIQ2RGB(img) -- Return RGB image to properly display modified image
end

--[[
    Author: Taylor Doell
    Description: This function uses 255 * (intensity / 255) ^ gamma to calculate
      a new intensity value for the pixel.
]]
local function gamma(img, gamma)
  local rows, columns = img.height, img.width
  local intensity = 0
  
  img = il.RGB2YIQ(img) -- Convert image to YIQ model
  
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      intensity = img:at(row, col).y
      
      -- Use equation 255 * (intensity / 255) ^ gamma  to calculate the gamma value
      img:at(row, col).y = 255 * math.pow(intensity / 255, gamma);
    end
  end
  
  return il.YIQ2RGB(img) -- Return RGB image to show properly
end

--[[
    Author: Benjamin Kaiser
    Description:  This function takes an image and then simply averages the RGB
    components for a given pixel together and assigns that value
    to each of the components so that the grayscale is computed
    with the components as an average of them all.  
]]
local function avgGrayscale(img)
  local rows, columns = img.height, img.width
  
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      --compute the sum
      local sum = img:at(row, column).r + img:at(row, column).g + img:at(row, column).b
      img:at(row, column).r = sum/3
      img:at(row, column).g = sum/3
      img:at(row, column).b = sum/3
    end
  end
  return img
end

--[[
    Author: Benjamin Kaiser
    Description:  This function takes an image and converts the image
    to a grayscale image.  We then build up a lookup table with hardcoded discrete
    pseudocode values.  
]]
local function discretePseudocolor(img)
  local rows, columns = img.height, img.width
  
  local lookUpTable ={}
  
  img = avgGrayscale(img)

  local coordinates = {}

  -- create the lookup table
  for i = 0, 31 do
    coordinates = {}
    coordinates['red'] = 255
    coordinates['green'] = 0
    coordinates['blue'] = 0
    lookUpTable[i] = coordinates
  end
  for i = 32, 63 do
    coordinates = {}
    coordinates['red'] = 0
    coordinates['green'] = 255
    coordinates['blue'] = 0
    lookUpTable[i] = coordinates
  end
  for i = 64, 95 do
    coordinates = {}
    coordinates['red'] = 0
    coordinates['green'] = 0
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  for i = 96, 127 do
    coordinates = {}
    coordinates['red'] = 0
    coordinates['green'] = 255
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  for i = 128, 159 do
    coordinates = {}
    coordinates['red'] = 0
    coordinates['green'] = 128
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  for i = 160, 191 do
    coordinates = {}
    coordinates['red'] = 255
    coordinates['green'] = 0
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  for i = 192, 223 do
    coordinates = {}
    coordinates['red'] = 32
    coordinates['green'] = 64
    coordinates['blue'] = 128
    lookUpTable[i] = coordinates
  end
  for i = 224, 255 do
    coordinates = {}
    coordinates['red'] = 255
    coordinates['green'] = 255
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  
  --process the image
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      local pixel = img:at(row, column)
      img:at(row, column).r = lookUpTable[pixel.r]['red']
      img:at(row, column).g = lookUpTable[pixel.g]['green']
      img:at(row, column).b = lookUpTable[pixel.b]['blue']
    end
  end
  
  return img
end

--[[
    Author: Benjamin Kaiser
    Description:  This function takes an image and then creates a continuous pseudocolor pattern.
    It creates a lookup table before doing any processing on the actual image to save on calculations
    and then when the image is being processed, the values are pulled from the lookup table.  
    The pattern used is that the red values will increase linearlly with a slope of 1 while the 
    green values are the exact inverse.  These decrease with a slope of -1.  The green values
    increase with a slope of 1 from 0 to 127 and then from 128 to 255 they decrease with a slope
    of -1
]]
local function continuousPseudocolor(img)
  local rows, columns = img.height, img.width
  
  local lookUpTable ={}
  local coordinates = {}
  
  img = avgGrayscale(img)
  
  --compute lookup table
  for i = 0, 255 do 
    coordinates = {}
    coordinates['red'] = i
    coordinates['blue'] = 255 - i
    if i < 128 then
      coordinates['green'] = i
    elseif i >= 128 then
      coordinates['green'] = 255 - i
    end
    lookUpTable[i] = coordinates
  end
  
  --process image
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      local pixel = img:at(row, column)
      img:at(row, column).r = lookUpTable[pixel.r]['red']
      img:at(row, column).g = lookUpTable[pixel.g]['green']
      img:at(row, column).b = lookUpTable[pixel.b]['blue']
    end
  end
  
  return img
end

--[[
    Author: Benjamin Kaiser
    Description:  This function takes an image and then calls Dr. Weiss's show histogram function
    to display a regular histogram of intensities.
]]

local function histogramDisplay(img)
  return il.showHistogram(img)
end

--[[
    Author: Benjamin Kaiser
    Description: This function takes an image and then calls Dr. Weiss's show RGB component
    histogram function to display a histogram for each of these components.  
]]
local function histogramDisplayRGB(img)
  return il.showHistogramRGB(img)
end

--[[
    Author: Benjamin Kaiser
    Description:  This function takes an image and a number between 0 and 7 which represents
    the index of the bit for each component that needs checked for a bit-plane slicing.  
    Depedning on what this value is, the mask variable is set accordingly so that the proper
    bit pattern is made.  After that, the pixel value is ANDed for each componenet and shifted
    down so that the outcome is either 0 or 1.  If it is 1, the intensity for that component is
    set to 255 and if it is 0, then the intensity for that componenet is set to 0.
]]

local function sliceBitPlane(img, plane)
  
  local rows, columns = img.height, img.width
  
  local mask = 1 -- 00000001
  
  if plane == 1 then
    mask = 2 -- 00000010
  elseif plane == 2 then
    mask = 4 -- 00000100
  elseif plane == 3 then
    mask = 8 -- 00001000
  elseif plane == 4 then
    mask = 16 -- 00010000
  elseif plane == 5 then
    mask = 32 -- 00100000
  elseif plane == 6 then
    mask = 64 -- 01000000
  elseif plane == 7 then
    mask = 128 -- 10000000
  end
  
  img = avgGrayscale(img)
  
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      local pixel = img:at(row, column)
      if bit.rshift(bit.band(mask, pixel.r), plane) == 1 then
        pixel.r = 255
      elseif bit.rshift(bit.band(mask, pixel.r), plane) == 0 then
        pixel.r = 0
      end
      if bit.rshift(bit.band(mask, pixel.g), plane) == 1 then
        pixel.g = 255
      elseif bit.rshift(bit.band(mask, pixel.g), plane) == 0 then
        pixel.g = 0
      end
      if bit.rshift(bit.band(mask, pixel.b), plane) == 1 then
        pixel.b = 255
      elseif bit.rshift(bit.band(mask, pixel.g), plane) == 0 then
        pixel.b = 0
      end
      
      img:at(row, column).r = pixel.r
      img:at(row, column).g = pixel.g
      img:at(row, column).b = pixel.b
    end
  end
  
  return img
end

--[[
    Author: Benjamin Kaiser
    Description:  This function takes an image and for each pixel value it compresses the range of the
    pixel intensities using the base 10 log function built into Lua.  The equation came directly from the
    book along with some research done online to determine that c = 255/math.log(256).  
]]
local function compressDynamicRange(img)
  local rows, columns = img.height, img.width
  
  img = il.RGB2YIQ(img)
  --process image
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      img:at(row, col).y =  255/math.log(256) * math.log(1 + img:at(row, col).y);
    end
  end
  
  return il.YIQ2RGB(img)
end

--[[
    Author: Taylor Doell
    Description: This function works closely to
      how the negate function works, but only
      modifies the pixel values if they are less
      than the threshold value.
]]
local function solarization(img, threshold)
  local rows, columns = img.height, img.width
  
  -- Loop through all pixels
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      -- For each color component, modify if value is less
      -- then the threshold value given by user
      
      if img:at(row, col).r <= threshold then
        img:at(row, col).r = 255-img:at(row, col).r
      end
      
      if img:at(row, col).g <= threshold then
        img:at(row, col).g = 255-img:at(row, col).g
      end
      
      if img:at(row, col).b <= threshold then
        img:at(row, col).b = 255-img:at(row, col).b
      end
    end
  end
  
  return img
end

--[[
  This return statement exposes the local functions to any
  other file that 'requires' this file into their program.
]]
return
{
  grayscale = convertToGrayScale,
  negate = negate,
  brightness = brightness,
  binaryThreshold = binaryThreshold,
  posterize = posterize,
  contrast = contrast,
  gamma = gamma,
  discretePseudocolor = discretePseudocolor,
  continuousPseudocolor = continuousPseudocolor,
  bitSlice = sliceBitPlane,
  logCompress = compressDynamicRange,
  solarization = solarization
}