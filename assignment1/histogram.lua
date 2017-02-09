 --[[]]

require "ip"
local il = require "il"
local math = require "math"
local bit = require "bit"

--[[
    Author: Taylor Doell
    Description: This function computes the histogram for an image
      and returns it to the caller.
]]
local function computeHistogram(img)
  local rows, columns = img.height, img.width
  local histogram = {}
  
  -- Init histogram to all zero values
  for i = 0, 255 do
    histogram[i] = 0
  end
  
  -- Compute the histogram
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      intensity = img:at(row, col).y
      
      histogram[intensity] = histogram[intensity] + 1
    end
  end
  
  return histogram
end

--[[
    Author: Taylor Doell
    Description: This function calls the il lua library
      showHistogram method to display the histogram for
      the intensity channel.
]]
local function histogramDisplay(img)
  return il.showHistogram(img)
end

--[[
    Author: Benjamin Kaiser
    Description: his function calls the il lua library
      showHistogramRGB method to display the histogram
      for the red, blue and green channels.
]]
local function histogramDisplayRGB(img)
  return il.showHistogramRGB(img)
end

--[[
    Author: Benjamin Kaiser
    Description:
]]
local function histogramEqualize(img, percent)
  local rows, columns = img.height, img.width
  local numberOfPixels = (rows * columns)
  local clipLevel = math.floor(numberOfPixels * percent/100)
  
  if percent > 100 then
    return img
  end
  
  local min, max = 256, 0
  
  img = il.RGB2YIQ(img)
  
  local histogram = {}
  
  for i = 0, 255 do
    histogram[i] = 0
  end
  
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      local intensity = img:at(row, col).y
      
      histogram[intensity] = histogram[intensity] + 1
      
      if histogram[intensity] > clipLevel then
        local difference = histogram[intensity] - clipLevel
        
        numberOfPixels = numberOfPixels - difference

        histogram[intensity] = clipLevel
      end
    end
  end
  
  local lookUpTable = {}
  
  local sum = 0
  
  for i = 0, 255 do
    sum = 0
    for j = 0, i do
      sum = sum + (histogram[j] / numberOfPixels)
    end
    
    lookUpTable[i] = math.floor(sum * 255)
  end
  
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      local pixelIntensity = img:at(row, col).y
      img:at(row, col).y =  lookUpTable[pixelIntensity]
    end
  end
  
  return il.YIQ2RGB(img)
end

--[[
    Author: Benjamin Kaiser
    Description:
]]
local function histogramEqualizeAuto(img)
  return histogramEqualize(img, 100)
end

--[[
  This return statement exposes the local functions to any
  other file that 'requires' this file into their program.
]]
return 
{
  intensityHistogram = histogramDisplay,
  rgbHistogram = histogramDisplayRGB,
  equalize = histogramEqualizeAuto,
  equalizeClip = histogramEqualize,
  computeHistogram = computeHistogram
}