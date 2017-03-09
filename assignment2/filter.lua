require "ip"

local il = require "il"
local math = require "math"
local help = require "helper"


local function smoothing(img)
  local rows, columns = img.height, img.width
  local rowCount, colCount
  
  local cloneImg = img:clone()
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  local mask = {{1, 2, 1}, {2, 4, 2}, {1, 2, 1}}
  
  local reflectedRow  = 0
  local reflectedColumn = 0
  
  local sum
  
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
     
      sum = 0
   
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
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

local function sharpen(img)
  local rows, columns = img.height, img.width
  
  local cloneImg = img:clone()
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  local mask = {{0, -1, 0}, {-1, 5, -1}, {0, -1, 0}}
  
  local rowCount, colCount
  local reflectedRow, reflectedColumn
  
  local sum
  
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
      
      
      sum = 0
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
          reflectedColumn, reflectedRow = help.reflection(colCount, rowCount, columns - 1, rows - 1)
          sum = sum + mask[i][j] * img:at(reflectedRow, reflectedColumn).y
          colCount = colCount + 1
        end
        rowCount = rowCount + 1
      end
      
      
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

local function plusMedianFilter(img)
  local rows, columns = img.height, img.width
  
  local cloneImg = img:clone()
  local rowCount, colCount
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  local mask = {{0, 1, 0}, {1, 1, 1}, {0, 1, 0}}
  
  local reflectedRow = 0
  local reflectedCol = 0
  

  
  for row = 1, rows - 2 do
    for column = 1, columns - 2 do
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

local function meanFilter(img, n)
  local rows, columns = img.height, img.width
  local cloneImg = img:clone()
  local filterOffset = math.floor(n / 2)
  local sqr = n * n
  local sum = 0
  
  local rowMask = 0
  local colMask = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  for row = 0, rows - 1 do --n, rows - n - 1 do
    for col = 0, columns - 1  do --n, columns - n - 1 do
      sum = 0
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          
          colMask, rowMask = help.reflection(col - colFilter, row - rowFilter, columns - 1, rows - 1)
          
          sum = sum + img:at(rowMask, colMask).y
        end
      end
      
      cloneImg:at(row, col).y = sum / sqr
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

local function minMaxFilter(img, n, isMin)
  local rows, columns = img.height, img.width
  local cloneImg = img:clone()
  local filterOffset = math.floor(n / 2)
  local value = 0
  local intensity = 0
  local initial = 255
  local rowMask = 0
  local colMask = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  for row = 0, rows - 1 do-- n, rows - n - 1 do -- pixel start
    for col = 0, columns - 1 do -- n, columns - n - 1 do -- pixel start
      value = img:at(row, col).y
      
      for rowFilter = -1 * filterOffset, filterOffset do 
        for colFilter = -1 * filterOffset, filterOffset do
          colMask, rowMask = help.reflection(col - colFilter, row - rowFilter, columns - 1, rows - 1)
          intensity = img:at(rowMask, colMask).y
          
          if isMin and value > intensity then
            value = intensity
          elseif not isMin and value < intensity then
            value = intensity
          end
        end
      end
      
      cloneImg:at(row, col).y = value
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

local function maxFilter(img, n)
  return minMaxFilter(img, n, false)
end

local function minFilter(img, n)
  return minMaxFilter(img, n, true)
end

local function rangeFilter(img, n)
  local rows, columns = img.height, img.width
  local cloneImg = img:clone()
  local filterOffset = math.floor(n / 2)
  local intensity = 0
  local min = 0
  local max = 0
  
  local rowMask = 0
  local colMask = 0
  
  img = il.RGB2YIQ(il.grayscaleYIQ(img))
  cloneImg = il.RGB2YIQ(il.grayscaleYIQ(cloneImg))
  
  for row = 0, rows - 1 do --n, rows - n - 1 do
    for col = 0, columns - 1 do --n, columns - n - 1 do
      min = img:at(row, col).y
      max = min
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          colMask, rowMask = help.reflection(col - colFilter, row - rowFilter, columns - 1, rows - 1)
          intensity = img:at(rowMask, colMask).y
          
          if min > intensity then
            min = intensity
          elseif max < intensity then
            max = intensity
          end
        end
      end
      
      cloneImg:at(row, col).y = max - min
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

local function standardDeviationFilter(img, n)
  local rows, columns = img.height, img.width
  local cloneImg = img:clone()
  local filterOffset = math.floor(n / 2)
  local sqr = n * n
  local sum = 0
  local avg = 0
  local std = 0
  local intensity = 0
  
  local reflectedRow = 0
  local reflectedColumn = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  for row = 0, rows - 1 do --n, rows - n - 1 do
    for col = 0, columns - 1 do --n, columns - n - 1 do
      intensity = img:at(row, col).y
      sum = 0
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          reflectedColumn, reflectedRow = help.reflection(col + colFilter, row + rowFilter, columns - 1, rows - 1)
          sum = sum + img:at(reflectedRow, reflectedColumn).y
        end
      end
      
      avg = sum / sqr
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          reflectedColumn, reflectedRow = help.reflection(col + colFilter, row + rowFilter, columns - 1, rows - 1)
          sum = sum + math.pow(img:at(reflectedRow, reflectedColumn).y - avg, 2)
        end
      end
      
      std = math.sqrt(sum / sqr)
      
      cloneImg:at(row, col).y = std
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

local function emboss(img)
  local rows, columns = img.height, img.width
  local rowCount, colCount
  
  local cloneImg = img:clone()
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  local mask = {{0, 0, 0}, {0, 1, 0}, {0, 0, -1}}
  
  local reflectedRow  = 0
  local reflectedColumn = 0
  
  local sum
  
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
     
      sum = 0
   
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
          reflectedColumn, reflectedRow = help.reflection(colCount, rowCount, columns - 1, rows - 1)
          sum = sum + mask[i][j] * img:at(reflectedRow, reflectedColumn).y
          colCount = colCount + 1
        end
        rowCount = rowCount + 1
      end
      sum = sum + 128
      if sum > 255 then
        sum = 255
      elseif sum < 0 then
        sum = 0
      end
      cloneImg:at(row, column).y = math.floor(sum)
    
      
    end 
  end
  return il.YIQ2RGB(cloneImg)
  
end

return
{
  smoothing = smoothing,
  sharpen = sharpen,
  medianplus = plusMedianFilter,
  mean = meanFilter,
  min = minFilter,
  max = maxFilter,
  range = rangeFilter,
  stdDev = standardDeviationFilter,
  emboss = emboss
}