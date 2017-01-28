require "ip"
local il = require "il"
math = require "math"


local function convertToGrayScale(img)
  local rows, columns = img.height, img.width
  
  --img = il.RGB2YIQ(img)
  local sum
  for row = 0, rows-1 do
    for column = 0, columns-1 do
        sum = .3 * img:at(row, column).r + .59 * img:at(row, column).g + .11 * img:at(row, column).b
        img:at(row, column).r = sum
        img:at(row, column).g = sum
        img:at(row, column).b = sum
      end
    end
 return img --il.YIQ2RGB(img)
end

local function negate(img)
  return img:mapPixels( function( r, g, b )
      return 255 - r, 255 - g, 255 - b
    end
  )
end

local function binaryThreshold(img, threshold)
  local rows, columns = img.height, img.width
  
  img = convertToGrayScale(img)
  
  img = il.RGB2YIQ(img)
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      if img:at(row, column).y >= threshold then
        img:at(row, column).y = 255
      elseif img:at(row, column).y < threshold then
        img:at(row, column).y = 0
      end
    end
  end
  return il.YIQ2RGB(img)
end

local function posterize(img, numberOfLevels)
  local rows, columns = img.height, img.width
  
  incrementValue = math.floor(256/(numberOfLevels - 1))
  numberEachLevel = math.floor(256/numberOfLevels + .5)
  currentLevel = 0
  counter = 0
  
  lookUpTable = {}
  
  for index = 0, 255 do
    if counter == numberEachLevel - 1 then
      counter = 0
      currentLevel = currentLevel + incrementValue
      if currentLevel > 255 then
        currentLevel = 255
      end
    end
    counter = counter + 1
    lookUpTable[index] = currentLevel
  end
  
  img = il.RGB2YIQ(img)
  
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      pixel = img:at(row, column).y
      pixel = lookUpTable[pixel]
      img:at(row, column).y = pixel
    end
  end
  
  return il.YIQ2RGB(img)
end

local function brightness(img, amount)
  local rows, columns = img.height, img.width

  img = il.RGB2YIQ(img)

  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      local pixel = img:at(row, col).y
      
      pixel = pixel + amount

      if pixel > 255 then
        pixel = 255
      elseif pixel < 0 then
        pixel = 0
      end
      
      img:at(row, col).y = pixel
    end
  end

  return il.YIQ2RGB(img)
end

local function contrast(img, startPoint, endPoint)
  local rows, columns = img.height, img.width
  local slope = 255 / (endPoint - startPoint)
  local intercept = -startPoint * slope
  local table = {}
  
  for i = 0, 255 do
    if i <= startPoint then
      table[i] = 0
    elseif i >= endPoint then
      table[i] = 255
    else
      table[i] = slope * i + intercept
    end
  end
  
  img = il.RGB2YIQ(img)
    
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      img:at(row, col).y = table[img:at(row, col).y];
    end
  end
  
  return il.YIQ2RGB(img)
end

local function gamma(img, gamma)
  return img
end

local function dynamicRange(img)
  return img
end

local function discretePseudocolor(img)
  return img
end

local function continuousPseudocolor(img)
  return img
end

local function automaticContrastStretch(img)
  return img
end

local function modifiedContrastStretch(img, darkPercent, lightPercent)
  return img
end

local function histogramDisplay(img)
end

local function sliceBitPlane(img, plane)
  return img
end

return 
{
  grayscale = convertToGrayScale,
  negate = negate,
  brightness = brightness,
  binaryThreshold = binaryThreshold,
  posterize = posterize,
  contrast = contrast
}