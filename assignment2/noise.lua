--[[
  Authors: Benjamin Kaiser and Taylor Doell
  This file contains all of the functions which handle noise cleaning for our program.  
]]
require "ip"

local il = require "il"
local math = require "math"
local help = require "helper"

--[[
  Author: Benjamin Kaiser
  Description: This function takes an image and a threshold and performs an out of range
  cleaning operation on it.  This is good for cleaning salt and pepper
  noise.  It takes an image and a threshold with which to compare when
  the average is computed.  
  For each pixel in the image, a filter is looped through which
  contains a ring of 1's on the outside.  This is then used to compute
  the sum of the surrounding pixels.  The average of this is then taken
  The average is then compared with the intensity of the pixel in
  question via a difference.  If the absolute value of the difference
  is less than the threshold which was given then the intensity
  stays the same.  Otherwise, it becomes the average of the intensities.
  This function also utilizes reflection to handle borders.
]]
local function outOfRange(img, threshold)
  local rows, columns = img.height, img.width
  
  --variables for handling filter traversal in image coordinates
  local rowCount, columnCount
  
  -- mask to get neighborhood average
  local mask = {{1, 1, 1}, {1, 0, 1}, {1, 1, 1}}
  
  local cloneImg = img:clone()
  
  local reflectedRow = 0
  local reflectedColumn = 0
  
  local compareWithThreshold = 0
  local avgOfNeighbors = 0
  
  local sum = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  -- process the image
  for row = 0, rows - 1 do
    for column = 0, columns -1 do
      
      sum = 0
      
      -- traverse the filter
      rowCount = row - 1
      for i = 1, 3 do
        columnCount = column - 1
        for j = 1, 3 do
          reflectedColumn, reflectedRow = help.reflection(columnCount, rowCount, columns - 1, rows - 1)
          sum = sum + mask[i][j] * img:at(reflectedRow, reflectedColumn).y
          columnCount = columnCount + 1
        end
        rowCount = rowCount + 1
      end
      
      avgOfNeighbors = sum/8
      
      compareWithThreshold = math.abs(img:at(row, column).y - avgOfNeighbors)
      
      --set proper value
      if compareWithThreshold < threshold then
        cloneImg:at(row, column).y = img:at(row, column).y
      elseif compareWithThreshold >= threshold then
        cloneImg:at(row, column).y = avgOfNeighbors
      end
    end
  end
  
  return il.YIQ2RGB(cloneImg)
  
end

--[[
  Author: Benjamin Kaiser
  Description: This function handles the median filter in a plus shape.
  It takes in an image.  
  For each pixel in the image, a 3x3 filter is looped through to compute
  the value for the currently considered pixel.  Since this is a rank
  order filter, the value in the filters are not multiplied but rather
  that number of copies are taken and put into a table.  This table
  is sorted and the middle value is taken.  Since we know this
  will always be 5 values (plus shape) we always take value at index 3
  after sorting the table this will be the middle value.  
]]
local function plusMedianFilter(img)
  local rows, columns = img.height, img.width
  
  local cloneImg = img:clone()
  local rowCount, colCount
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  -- rank order mask
  local mask = {{0, 1, 0}, {1, 1, 1}, {0, 1, 0}}
  
  -- variables to handle reflected coordinates
  local reflectedRow = 0
  local reflectedCol = 0
  
  --process the image
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
      --our temporary copylist
      local copyList = {}
      --loop filter
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
          --compute reflections
          reflectedCol, reflectedRow = help.reflection(colCount, rowCount, columns - 1, rows - 1)
          local copyCount = 1
          while copyCount <= mask[i][j] do
            table.insert(copyList, img:at(reflectedRow, reflectedCol).y)
            copyCount = copyCount + 1
          end
          colCount = colCount + 1
        end
        rowCount = rowCount + 1
      end
      
      table.sort(copyList)
      
      local median = 0
      
      local length = table.getn(copyList)
      
      -- get middle value
      median = copyList[3]
      
      cloneImg:at(row, column).y = median
      
    end 
  end
  return il.YIQ2RGB(cloneImg)

end

--[[
  Author: Benjamin Kaiser
  Description: This function handles the median filter in an n x n neighborhood.
  It takes in an image and a size for one dimension of the filter..  
  For each pixel in the image, the filter is looped through to compute
  the value for the currently considered pixel.  Since this is a rank
  order filter, the value in the filters are not multiplied but rather
  that number of copies are taken and put into a table.  This table
  is sorted and the middle value is taken.  We find this middle value 
  by checking to see if the square of n is even or odd.  If it is even,
  we find the middle two values and get their average.  Otherwise, we simply
  get the middle value.  
]]
local function medianFilter(img, n)
  local rows, columns = img.height, img.width
  local cloneImg = img:clone()
  local filterOffset = math.floor(n/2)
  local reflectedRow = 0;
  local reflectedColumn = 0
  local totalCount = n * n
  local median = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  --process image
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      local copyList = {}
      
      --loop filter
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          --get reflected coordinates
          reflectedColumn, reflectedRow = help.reflection(col - colFilter, row - rowFilter, columns - 1, rows - 1)
          table.insert(copyList, img:at(reflectedRow, reflectedColumn).y)
        end
      end
      
      table.sort(copyList)
      
      --find middle
      if totalCount % 2 == 0 then
        median = (copyList[totalCount/2] + copyList[totalCount/2 + 1])/2
      elseif totalCount % 2 == 1 then
        median = copyList[math.floor(totalCount/2)]
      end
      
      cloneImg:at(row, col).y = median
      
    end
  end
  return il.YIQ2RGB(cloneImg)
end

-- expose functions to call in main.lua
return
{
  outofrange = outOfRange,
  medianplus = plusMedianFilter,
  median = medianFilter
}