 --[[
 Authors:  Benjamin Kaiser and Taylor Doell
  This file handles all of the histogram functions for the histogram menu in our program.  
]]

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
    Description:  This function takes an image and a percent and then the percentage is used
    to determine the clip level for the pixels.  When we're looping through the histogram,
    if the number in the "bucket" is greater than the clip level we subtract the difference
    of the clip level and the total amount in the bucket from the total number of pixels in
    the image which is then used to compute the proper cumulative distribution function.  
]]
local function histogramEqualize(img, percent)
  local rows, columns = img.height, img.width
  local numberOfPixels = (rows * columns)
  -- determine the intensity that we 
  local clipLevel = math.floor(numberOfPixels * percent/100)
  
  if percent > 100 then
    return img
  end
  
  local min, max = 256, 0
  
  img = il.RGB2YIQ(img)
  
  local histogram = computeHistogram(img)
  
  for i = 0, 255 do
    if histogram[i] > clipLevel then
      local difference = histogram[i] - clipLevel
      numberOfPixels = numberOfPixels - difference
      histogram[i] = clipLevel
    end
  end
  
  local lookUpTable = {}
  
  local sum = 0
  
  -- compute lookup table
  for i = 0, 255 do
    sum = 0
    for j = 0, i do
      sum = sum + (histogram[j] / numberOfPixels)
    end    
    lookUpTable[i] = math.floor(sum * 255)
  end
  
  -- process the image
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
    Description:  This function calls the the histogram equalization function
    with the default of 100%.  
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