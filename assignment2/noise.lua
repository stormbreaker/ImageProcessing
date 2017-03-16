require "ip"

local il = require "il"
local math = require "math"
local help = require "helper"

--[[
Author: Benjamin Kaiser
Description: 
]]
local function outOfRange(img, threshold)
  local rows, columns = img.height, img.width
  local rowCount, columnCount
  local mask = {{1, 1, 1}, {1, 0, 1}, {1, 1, 1}}
  
  local cloneImg = img:clone()
  
  local reflectedRow = 0
  local reflectedColumn = 0
  
  local compareWithThreshold = 0
  local avgOfNeighbors = 0
  
  local sum = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  for row = 0, rows - 1 do
    for column = 0, columns -1 do
      
      sum = 0
      
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
Description: 
]]
local function plusMedianFilter(img)
  local rows, columns = img.height, img.width
  
  local cloneImg = img:clone()
  local rowCount, colCount
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  local mask = {{0, 1, 0}, {1, 1, 1}, {0, 1, 0}}
  
  local reflectedRow = 0
  local reflectedCol = 0
  
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
      local copyList = {}
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
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
      
      median = copyList[2]
      
      cloneImg:at(row, column).y = median
      
    end 
  end
  return il.YIQ2RGB(cloneImg)

end

--[[
Author: Benjamin Kaiser
Description: 
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
  
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      local copyList = {}
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          reflectedColumn, reflectedRow = help.reflection(col - colFilter, row - rowFilter, columns - 1, rows - 1)
          table.insert(copyList, img:at(reflectedRow, reflectedColumn).y)
        end
      end
      
      table.sort(copyList)
      
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

return
{
  outofrange = outOfRange,
  medianplus = plusMedianFilter,
  median = medianFilter
}