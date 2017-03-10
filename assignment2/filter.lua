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

local function kirschMagnitude(img)
  local rows, columns = img.height, img.width
  local filter = {{-3, -3, -3}, {-3, 0, -3}, {5, 5, 5}}
  local tempFilter = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
  local calc = 0
  local maxMag = 0
  local intensity = 0
  local imgClone = img:clone()
  local magnitudes = {}
  
  img = il.RGB2YIQ(il.grayscaleYIQ(img))
  imgClone = il.RGB2YIQ(il.grayscaleYIQ(imgClone))
  
  for row = 1, rows - 2 do
    for col = 1, columns - 2 do
      maxMag = 0
      
      for rotation = 1, 8 do
        calc = 0
        
        for colFilter = -1, 1 do
          for rowFilter = -1, 1 do
            calc = calc + filter[colFilter + 2][rowFilter + 2] * img:at(row + rowFilter, col + colFilter).y
          end
        end
        
        magnitudes[rotation] = calc
        
        tempFilter[2][1] = filter[1][1]
        tempFilter[3][1] = filter[2][1]
        tempFilter[3][2] = filter[3][1]
        tempFilter[3][3] = filter[3][2]
        tempFilter[2][3] = filter[3][3]
        tempFilter[1][3] = filter[2][3]
        tempFilter[1][2] = filter[1][3]
        tempFilter[1][1] = filter[1][2]
        tempFilter[2][2] = 0
        
        for colCopy = 1, 3 do
          for rowCopy = 1, 3 do
            filter[colCopy][rowCopy] = tempFilter[colCopy][rowCopy]
          end
        end
      end
      
      for i = 1, 8 do
        maxMag = maxMag + math.pow(magnitudes[i], 2)
      end
      
      maxMag = math.sqrt(maxMag)
      maxMag = maxMag / 8
      
      if maxMag > 255 then
        maxMag = 255
      end
      
      imgClone:at(row, col).y = maxMag
    end
  end
  
  return il.YIQ2RGB(imgClone)
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

local function sobelEdge(img, isMagnitude)
  local rows, columns = img.height, img.width
  
  local cloneImg = img:clone()
  
  local yMask = {{1, 2, 1}, {0 , 0, 0}, {-1, -2, -1}}
  local xMask = {{1, 0, -1}, {2, 0, -2}, {1, 0, -1}}
  
  local G_x, G_y
  
  local reflectedRow = 0
  local reflectedColumn = 0
  
  local rowCount = 0
  local columnCount = 0
  local result = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
      
     G_x = 0
     G_y = 0
      rowCount = row - 1
      for i = 1, 3 do
        columnCount = column - 1
        for j = 1, 3 do
          reflectedColumn, reflectedRow = help.reflection(columnCount, rowCount, columns - 1, rows - 1)
          G_x = G_x + xMask[i][j] * img:at(reflectedRow, reflectedColumn).y
          G_y = G_y + yMask[i][j] * img:at(reflectedRow, reflectedColumn).y
          columnCount = columnCount + 1
        end
        rowCount = rowCount + 1
      end
      
      if isMagnitude then
        result = math.sqrt(math.pow(G_x, 2) + math.pow(G_y, 2))
        result = math.floor(255/360.624458405 * result)
      else
        result = math.atan2(G_y,G_x)
        if result < 0 then
          result = result + 2 * math.pi
        end
        result = math.floor(255/(2*math.pi) * (result))
      end
      
      cloneImg:at(row, column).y = result
      
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

local function sobelMag(img)
  return sobelEdge(img, true)
end
 
local function sobelDirection(img)
   return sobelEdge(img, false)
end

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
      
      compareWithThreshold = img:at(row, column).y - avgOfNeighbors
      
      if compareWithThreshold < threshold then
        cloneImg:at(row, column).y = img:at(row, column).y
      elseif compareWithThreshold >= threshold then
        cloneImg:at(row, column).y = avgOfNeighbors
      end
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
  kirschMag = kirschMagnitude,
  emboss = emboss,
  median = medianFilter,
  outofrange = outOfRange,
  sobelMag = sobelMag,
  sobelDir = sobelDirection
}