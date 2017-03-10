require "ip"

local il = require "il"
local math = require "math"


local function smoothing(img)
  local rows, columns = img.height, img.width
  local rowCount, colCount
  
  local cloneImg = img:clone()
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  local mask = {{1, 2, 1}, {2, 4, 2}, {1, 2, 1}}
  
  local sum
  
  for row = 1, rows - 2 do
    --print("row"..row)
    for column = 1, columns - 2 do
      --print("col"..column)
      
      
      sum = 0
      
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
          sum = sum + mask[i][j] * img:at(rowCount, colCount).y
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
  
  local sum
  
  for row = 1, rows - 2 do
    for column = 1, columns - 2 do
      print("col"..column)
      
      
      sum = 0
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
          sum = sum + mask[i][j] * img:at(rowCount, colCount).y
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
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  local mask = {{0, 1, 0}, {1, 1, 1}, {0, 1, 0}}
  
  local copyList = {}
  
  for row = 1, rows - 2 do
    for column = 1, columns - 2 do
      print("col"..column)
      
      
      sum = 0
      rowCount = row - 1
      for i = 1, 3 do
        colCount = column - 1
        for j = 1, 3 do
          local copyCount = 1
          while copyCount <= mask[i][j] do
            table.insert(copyList, img:at(rowCount, colCount).y)
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
      
      --[[if length % 2 == 1 then
        median = copyList[math.ceil(length/2)]
      else
        median = math.ceil((copyList[length/2] + copyList[length/2 + 1])/2)
      end]]
      
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
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  for row = n, rows - n - 1 do
    for col = n, columns - n - 1 do
      sum = 0
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          sum = sum + img:at(row + rowFilter, col + colFilter).y
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
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  for row = n, rows - n - 1 do
    for col = n, columns - n - 1 do
      value = img:at(row, col).y
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          intensity = img:at(row - rowFilter, col - colFilter).y
          
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
  
  img = il.RGB2YIQ(il.grayscaleYIQ(img))
  cloneImg = il.RGB2YIQ(il.grayscaleYIQ(cloneImg))
  
  for row = n, rows - n - 1 do
    for col = n, columns - n - 1 do
      min = img:at(row, col).y
      max = min
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          intensity = img:at(row - rowFilter, col - colFilter).y
          
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
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  for row = n, rows - n - 1 do
    for col = n, columns - n - 1 do
      intensity = img:at(row, col).y
      sum = 0
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          sum = sum + img:at(row + rowFilter, col + colFilter).y
        end
      end
      
      avg = sum / sqr
      
      for rowFilter = -1 * filterOffset, filterOffset do
        for colFilter = -1 * filterOffset, filterOffset do
          sum = sum + math.pow(img:at(row + rowFilter, col + colFilter).y - avg, 2)
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
  kirschMag = kirschMagnitude
}