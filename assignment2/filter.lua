--[[
  Authors: Benjamin Kaiser and Taylor Doell
  Description:  This function handles all of the functions for general neighborhood processes.  
]]
require "ip"

local il = require "il"
local math = require "math"
local help = require "helper"

--[[
Author: Benjamin Kaiser
Description: This function takes an image and smooths it.  To do this,
it loops through the entire image using reflection to handle borders.  
For each pixel in the image, a mask is looped through and convolved
with the image.  This means that for each filter, we multiply the value in
the filter with the intensity of the pixel that it overlays.
These are all added together and the average of these values is then 
set into the pixel which is being worked on currently.  
]]
local function smoothing(img)
  local rows, columns = img.height, img.width
  local rowCount, colCount
  
  local cloneImg = img:clone()
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  --smoothing mask
  local mask = {{1, 2, 1}, {2, 4, 2}, {1, 2, 1}}
  
  --reflection coordinates
  local reflectedRow  = 0
  local reflectedColumn = 0
  
  local sum
  
  --process image
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
     
      sum = 0
   
      --loop filter
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
          --compute reflected coordinates
          reflectedColumn, reflectedRow = help.reflection(colCount, rowCount, columns - 1, rows - 1)
          sum = sum + mask[i][j] * img:at(reflectedRow, reflectedColumn).y
          colCount = colCount + 1
        end
        rowCount = rowCount + 1
      end
      
      cloneImg:at(row, column).y = math.floor(sum/16)
    
    end 
  end
  return il.YIQ2RGB(cloneImg)
  
end

--[[
Author: Benjamin Kaiser
Description: This function takes an image and sharpens it.  To do this,
it loops through the entire image using reflection to handle borders.  
For each pixel in the image, a mask is looped through and convolved
with the image.  This means that for each filter, we multiply the value in
the filter with the intensity of the pixel that it overlays.
These are all added together and then the resulting value is clipped to the 0 to 255 range 
]]
local function sharpen(img)
  local rows, columns = img.height, img.width
  
  local cloneImg = img:clone()
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  --sharpening mask
  local mask = {{0, -1, 0}, {-1, 5, -1}, {0, -1, 0}}
  
  --variables to handle reflection
  local rowCount, colCount
  local reflectedRow, reflectedColumn
  
  local sum
  
  --process image
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
      
      
      sum = 0
      --loop filter
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
          --compute reflected coordiantes
          reflectedColumn, reflectedRow = help.reflection(colCount, rowCount, columns - 1, rows - 1)
          sum = sum + mask[i][j] * img:at(reflectedRow, reflectedColumn).y
          colCount = colCount + 1
        end
        rowCount = rowCount + 1
      end
      
      --clip
      if sum > 255 then
        sum = 255
      elseif sum < 0 then
        sum = 0
      end
      
      cloneImg:at(row, column).y = sum
      
    end 
  end
  
  return il.YIQ2RGB(cloneImg)
end

--[[
Author: Taylor Doell
Description: This function calculates the mean of the pixels around the
  center pixel and replaces the center pixels intensity with that average
  value. The size of the filter to calculate the mean from is given to us
  from the user and passed into this function.
]]
local function meanFilter(img, n)
  local rows, columns = img.height, img.width
  local cloneImg = img:clone()
  local filterOffset = math.floor(n / 2) -- Get the filter offset for how many filter columns are above and below 0
  local sqr = n * n
  local sum = 0
  
  local rowMask = 0
  local colMask = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  -- Loop through rows and columns of image to modify the image
  for row = 0, rows - 1 do
    for col = 0, columns - 1  do
      sum = 0
      
      -- Loop through the mask adding pixel values together
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          -- Get reflected values to handle the edges
          colMask, rowMask = help.reflection(col - colFilter, row - rowFilter, columns - 1, rows - 1)
          
          sum = sum + img:at(rowMask, colMask).y -- Increment the sum for calculating the average
        end
      end
      
      cloneImg:at(row, col).y = sum / sqr -- Calculate mean and store in the clone image
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

--[[
Author: Taylor Doell
Description: This function uses the n size of the filter to use to
  loop through all of the values under the filter and find the min
  or max value under that filter. The min and max filter functions
  call this function passing in whether they are the max or min function.
  The values are stored into the cloned image as to not effect the results.
]]
local function minMaxFilter(img, n, isMin)
  local rows, columns = img.height, img.width
  local cloneImg = img:clone()
  local filterOffset = math.floor(n / 2) -- Get the filter offset for how many filter columns are above and below 0
  local value = 0
  local intensity = 0
  local initial = 255
  local rowMask = 0
  local colMask = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  -- Loop through pixels in image to find the max or min value under the filter
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      value = img:at(row, col).y -- Store intensity value to compare results
      
      for rowFilter = -1 * filterOffset, filterOffset do 
        for colFilter = -1 * filterOffset, filterOffset do
          -- Use the reflector method to handle the edges of the image
          colMask, rowMask = help.reflection(col - colFilter, row - rowFilter, columns - 1, rows - 1)
          intensity = img:at(rowMask, colMask).y
          
          -- Compare the min or max value with the current intensity under the filter
          if isMin and value > intensity then
            value = intensity
          elseif not isMin and value < intensity then
            value = intensity
          end
        end
      end
      
      cloneImg:at(row, col).y = value -- Store min or max in the clone image
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

--[[
Author: Taylor Doell
Description: This functions calls the above min max filter function
  to calculate the appropriate value.
]]
local function maxFilter(img, n)
  return minMaxFilter(img, n, false)
end

--[[
Author: Taylor Doell
Description: This functions calls the above min max filter function
  to calculate the appropriate value.
]]
local function minFilter(img, n)
  return minMaxFilter(img, n, true)
end

--[[
Author: Taylor Doell
Description: This function computes the range between the max and min
  pixel intensities that are located under the filter for each pixel.
  It takes the max minus the min to calculate the range between them
  and then stores those values into the clone image as not to effect
  the original image.
]]
local function rangeFilter(img, n)
  local rows, columns = img.height, img.width
  local cloneImg = img:clone()
  local filterOffset = math.floor(n / 2) -- Get the filter offset for how many filter columns are above and below 0
  local intensity = 0
  local min = 0
  local max = 0
  
  local rowMask = 0
  local colMask = 0
  
  img = il.RGB2YIQ(il.grayscaleYIQ(img))
  cloneImg = il.RGB2YIQ(il.grayscaleYIQ(cloneImg))
  
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      -- Store initial values before going through filter
      min = img:at(row, col).y
      max = min
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          -- Use the reflection method to handle the edges of the image
          colMask, rowMask = help.reflection(col - colFilter, row - rowFilter, columns - 1, rows - 1)
          intensity = img:at(rowMask, colMask).y
          
          -- Compare max and min intensities and change if necessary
          if min > intensity then
            min = intensity
          elseif max < intensity then
            max = intensity
          end
        end
      end
      
      cloneImg:at(row, col).y = max - min -- Store the range in the clone image
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

--[[
Author: Taylor Doell
Description: This function computes the standard deviation under a nxn filter.
  For each pixel in the image, this function adds up all of the intensities and
  the computes the average of those pixels. Next it takes the pixel intensities
  under the filter and substracts the average off of the intensity, squares that
  value and then adds that back into a value to be taken a square root of to
  complete the calculation.The value from that is then stored into the clone image
  as to not effect the original image.
]]
local function standardDeviationFilter(img, n)
  local rows, columns = img.height, img.width
  local cloneImg = img:clone()
  local filterOffset = math.floor(n / 2) -- Get the filter offset for how many filter columns are above and below 0
  local sqr = n * n
  local sum = 0
  local avg = 0
  local std = 0
  local intensity = 0
  
  local reflectedRow = 0
  local reflectedColumn = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  -- Loop through all the pixels to calculate the standard deviation of the values underneath the filter
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      intensity = img:at(row, col).y -- Store original pixel intensity
      sum = 0
      
      -- Loop through filter
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          -- Use the reflection method to handle the edges
          reflectedColumn, reflectedRow = help.reflection(col + colFilter, row + rowFilter, columns - 1, rows - 1)
          
          sum = sum + img:at(reflectedRow, reflectedColumn).y -- Add up the values under the filter to help calc the mean
        end
      end
      
      avg = sum / sqr -- Compute the mean of the filter
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          -- Use the reflection method to handle the edges
          reflectedColumn, reflectedRow = help.reflection(col + colFilter, row + rowFilter, columns - 1, rows - 1)
          
          -- Calculate the sum of the squares
          sum = sum + math.pow(img:at(reflectedRow, reflectedColumn).y - avg, 2)
        end
      end
      
      std = math.sqrt(sum / sqr) -- Take the square root of the sum of the squares
      
      cloneImg:at(row, col).y = std -- Store pixel intensity into clone image
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end



--[[
Author: Benjamin Kaiser
Description: This function takes an image and does an
embossing effect.  It loops through the image pixel by pixel.
On each pixel it convolves a mask which is defined in the function
The sum is computed of this convolution and this is then set to the pixel
that is currently being worked on after it is offset and brightened by 128
]]
local function emboss(img)
  local rows, columns = img.height, img.width
  local rowCount, colCount
  
  local cloneImg = img:clone()
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  --emboss mask
  local mask = {{0, 0, 0}, {0, 1, 0}, {0, 0, -1}}
  
  --variables to handle reflection
  local reflectedRow = 0
  local reflectedColumn = 0
  
  local sum
 
  -- process image
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
      sum = 0
   
      --loop filter
      rowCount = row - 1
      
      for i = 1, 3 do
        colCount = column - 1
        
        for j = 1, 3 do
          --compute reflected coordinates
          reflectedColumn, reflectedRow = help.reflection(colCount, rowCount, columns - 1, rows - 1)
          
          sum = sum + mask[i][j] * img:at(reflectedRow, reflectedColumn).y
          
          colCount = colCount + 1
        end
        
        rowCount = rowCount + 1
      end
      
      --offset and clip
      sum = sum + 128
      
      if sum > 255 then
        sum = 255
      elseif sum < 0 then
        sum = 0
      end
      
      cloneImg:at(row, column).y = sum
    end 
  end
  
  return il.YIQ2RGB(cloneImg)
end

-- Expose methods in order to call from main.lua
return
{
  smoothing = smoothing,
  sharpen = sharpen,
  mean = meanFilter,
  min = minFilter,
  max = maxFilter,
  range = rangeFilter,
  stdDev = standardDeviationFilter,
  emboss = emboss
}