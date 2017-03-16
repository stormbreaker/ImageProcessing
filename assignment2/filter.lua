require "ip"

local il = require "il"
local math = require "math"
local help = require "helper"

--[[
Author: Benjamin Kaiser
Description: 
]]
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

--[[
Author: Benjamin Kaiser
Description: 
]]
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
Author: Taylor Doell
Description: This function calculates the Kirsch magnitude and
  direction by using the filter located in the function. It takes
  the filter value and multiplies it accordingly to the corresponding
  pixel under the filter. As each value is calculated the max
  magnitude and the direction of that point. Each point has the filter
  rotated around it 8 times by a 45 degree angle. The max magnitude
  and direction is stored in the appropriate cloned image and then
  the original image, the magnitude image, and then the direction image
  is returned to show all results.
]]
local function kirschMagnitudeDirection(img)
  local rows, columns = img.height, img.width
  local filter = {{-3, -3, 5}, {-3,  0, 5}, {-3, -3, 5}}
  local maxMag = 0
  local intensity = 0
  local imgClone = img:clone()
  local imgDir = img:clone()
  local magnitudes = {}
  local directionalIntensity
  
  imgClone = il.RGB2YIQ(imgClone)
  imgDir = il.RGB2YIQ(imgDir)
  img = il.RGB2YIQ(img)
  
  -- Loop through all the pixel values in the image
  for row = 1, rows - 2 do
    for col = 1, columns - 2 do
      -- Set initial values for the calculations
      maxMag = -1
      directionalIntensity = 0
  
      -- Rotate the filter 8 times by 45 degrees each rotation
      for rotation = 0, 7 do
        calc = 0

        -- Calculate the magnitude of the current filter position
        for rowFilter = 1, 3 do
          for colFilter = 1, 3 do
            calc = calc + filter[rowFilter][colFilter] * img:at(row + rowFilter-2, col + colFilter-2).y
          end
        end
        
        -- Adjust max magnitude and the directional intensity if
        -- the new calculation is greater than the max magnitude
        if calc > maxMag then
          maxMag = calc
          directionalIntensity = math.floor((rotation)/8 * 255)
        end
        
        -- Rotate filter 45 degrees
        filter = help.rotate45(filter)
      end
      
      -- Divide by three per specification in program document
      maxMag = maxMag/3
      
      -- Clip values to prevent overflow
      if maxMag > 255 then
        maxMag = 255
      elseif maxMag < 0 then
        maxMag = 0
      end
      
      -- Clip directional intensity to prevent overflow
      if directionalIntensity > 255 then
        directionalIntensity = 255
      elseif directionalIntensity < 0 then
        directionalIntensity = 0
      end
      
      
      -- Set value in appropriate image
      imgDir:at(row, col).y = directionalIntensity
      imgDir:at(row, col).g = 128
      imgDir:at(row, col).b = 128
      
      imgClone:at(row, col).y = maxMag
      imgClone:at(row, col).g = 128
      imgClone:at(row, col).b = 128
    end
  end
  
  -- Return all images to show all changes
  return il.YIQ2RGB(img), il.YIQ2RGB(imgClone), il.YIQ2RGB(imgDir)
end

--[[
Author: Benjamin Kaiser
Description: 
]]
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

--[[
Author: Benjamin Kaiser
Description: 
]]
local function sobelEdge(img, isMagnitude)
  local rows, columns = img.height, img.width
  
  local cloneImg = img:clone()
  
  local yMask = {{1, 2, 1}, {0 , 0, 0}, {-1, -2, -1}}
  local xMask = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}}
  
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
        result = math.floor(256 * (result)/(2*math.pi))
      end
      
      cloneImg:at(row, column).r = result
      cloneImg:at(row, column).g = 128
      cloneImg:at(row, column).b = 128
      
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

--[[
Author: Benjamin Kaiser
Description: 
]]
local function sobelMag(img)
  return sobelEdge(img, true)
end

 --[[
Author: Benjamin Kaiser
Description: 
]]
local function sobelDirection(img)
   return sobelEdge(img, false)
end

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

--[[
Author: Taylor Doell
Description: This function calculates the Laplacian filter. The
  process includes applying the positive Laplacian filter and
  applies that filter to each pixel. Each calculation is offset
  128 per document specifications and then also clipped to prevent
  overflow. The new intensity is then stored into the clone image
  in order to keep the original image unmodified.
]]
local function laplacian(img)
  local rows, columns = img.height, img.width
  local filter = {{0, -1, 0}, {-1, 4, -1}, {0, -1, 0}} -- Filter used to calculate the Laplacian
  local imgClone = img:clone()
  local sum = 0
  
  img = il.RGB2YIQ(img)
  imgClone = il.RGB2YIQ(imgClone)
  
  -- Loop through all pixels in the image and apply the filter
  for row = 2, rows - 2 do
    for col = 2, columns - 2 do
      sum = 0
      
      for colFilter = -1, 1 do
        for rowFilter = -1, 1 do
          -- Sum and offset by 128
          sum = sum + filter[colFilter + 2][rowFilter + 2] * (img:at(row + rowFilter, col + colFilter).y + 128)
        end
      end
      
      -- Clip value to prevent overflow
      if sum > 255 then
        sum = 255
      elseif sum < 0 then
        sum = 0
      end
      
      imgClone:at(row, col).y = sum -- Set value intensity into the cloned image
    end
  end
  
  return il.YIQ2RGB(imgClone)
end

-- Expose methods in order to call from main.lua
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
  kirschMagDir = kirschMagnitudeDirection,
  laplacian = laplacian,
  emboss = emboss,
  median = medianFilter,
  outofrange = outOfRange,
  sobelMag = sobelMag,
  sobelDir = sobelDirection
}