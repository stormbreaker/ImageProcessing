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
    Author: Taylor Doell
    Description: This function uses a darkPercent of pixels and a lightPercent
      of pixels to ignore when computing the contrast stretch. It calls our
      histogram function to retrieve a histogram for the input image. Using
      that histogram we find the minimun and maximum intensity value and only
      swap them if they cross each other. Next we use the min and max values in
      an equation in order to find the next pixel value. Like a few other
      functions, we clip the pixel value to prevent overflow.
]]
local function modifiedContrastStretch(img, darkPercent, lightPercent)
  local rows, columns = img.height, img.width
  local pixelCount = rows * columns
  local i = 0
  local max = 0
  local min = 0
  local count = 0
  local intensity = 0
  local darkCount = (darkPercent / 100) * pixelCount
  local lightCount = (lightPercent / 100) * pixelCount
  
  -- Get histogram for image
  local histogram = computeHistogram(img)
  
  img = il.RGB2YIQ(img)
  
  -- Loop through histogram to find the min value for the endpoint
  for i = 0, 255 do
    count = count + histogram[i]
    
    if count >= darkCount then
      min = i
      break
    end
  end
  
  -- Loop through histogram to find the max value for the startpoint
  for i = 255, 0, -1 do
    count = count + histogram[i]
    
    if count >= lightCount then
      max = i
      break
    end
  end
  
  -- Swap values in case of crossing
  if min > max then
    max, min = min, max
  end
  
  -- Loop and compute calculation to each pixel
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      -- Compute new pixel value
      local pixVal = math.floor((255 / (max - min)) * (img:at(row, col).y - min))
      
      -- Clip value prevent overflow
      if pixVal > 255 then
        pixVal = 255
      elseif pixVal < 0 then
        pixVal = 0
      end
      
      -- Set new pixel value as the intensity
      img:at(row, col).y = pixVal
    end
  end
  
  return il.YIQ2RGB(img) -- Return RGB to show properly
end

--[[
    Author: Taylor Doell
    Description: This function calls the modified contrast
      stretch with two default values which skip the first
      and last 5% of the pixels.
]]
local function automaticContrastStretch(img)
  return modifiedContrastStretch(img, 5, 5)
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
  automaticContrastStretch = automaticContrastStretch,
  modifiedContrastStretch = modifiedContrastStretch,
  equalize = histogramEqualizeAuto,
  equalizeClip = histogramEqualize,
  computeHistogram = computeHistogram
}