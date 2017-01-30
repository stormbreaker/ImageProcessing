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
  local rows, columns = img.height, img.width
  local gammaCorrection = 1 / gamma
  
  img = il.RGB2YIQ(img)
  
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      img:at(row, col).y = 255 * math.pow((img:at(row, col).y / 255), gammaCorrection);
    end
  end
  
  return il.YIQ2RGB(img)
end

local function dynamicRange(img)
  return img
end

local function avgGrayscale(img)
  local rows, columns = img.height, img.width
  
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      sum = img:at(row, column).r + img:at(row, column).g + img:at(row, column).b
      img:at(row, column).r = sum/3
      img:at(row, column).g = sum/3
      img:at(row, column).b = sum/3
    end
  end
  return img
end

local function discretePseudocolor(img)
  local rows, columns = img.height, img.width
  
  lookUpTable ={}
  
  img = avgGrayscale(img)

  for i = 0, 31 do
    coordinates = {}
    coordinates['red'] = 255
    coordinates['green'] = 0
    coordinates['blue'] = 0
    lookUpTable[i] = coordinates
  end
  for i = 32, 63 do
    coordinates = {}
    coordinates['red'] = 0
    coordinates['green'] = 255
    coordinates['blue'] = 0
    lookUpTable[i] = coordinates
  end
  for i = 64, 95 do
    coordinates = {}
    coordinates['red'] = 0
    coordinates['green'] = 0
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  for i = 96, 127 do
    coordinates = {}
    coordinates['red'] = 0
    coordinates['green'] = 255
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  for i = 128, 159 do
    coordinates = {}
    coordinates['red'] = 0
    coordinates['green'] = 128
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  for i = 160, 191 do
    coordinates = {}
    coordinates['red'] = 255
    coordinates['green'] = 0
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  for i = 192, 223 do
    coordinates = {}
    coordinates['red'] = 32
    coordinates['green'] = 64
    coordinates['blue'] = 128
    lookUpTable[i] = coordinates
  end
  for i = 224, 255 do
    coordinates = {}
    coordinates['red'] = 255
    coordinates['green'] = 255
    coordinates['blue'] = 255
    lookUpTable[i] = coordinates
  end
  
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      pixel = img:at(row, column)
      img:at(row, column).r = lookUpTable[pixel.r]['red']
      img:at(row, column).g = lookUpTable[pixel.g]['green']
      img:at(row, column).b = lookUpTable[pixel.b]['blue']
    end
  end
  
  return img
end

local function continuousPseudocolor(img)
  local rows, columns = img.height, img.width
  
  lookUpTable ={}
  
  img = avgGrayscale(img)
  
  for i = 0, 255 do 
    coordinates = {}
    coordinates['red'] = i
    coordinates['blue'] = 255 - i
    if i < 128 then
      coordinates['green'] = i
    elseif i >= 128 then
      coordinates['green'] = 255 - i
    end
    lookUpTable[i] = coordinates
  end
  
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      pixel = img:at(row, column)
      img:at(row, column).r = lookUpTable[pixel.r]['red']
      img:at(row, column).g = lookUpTable[pixel.g]['green']
      img:at(row, column).b = lookUpTable[pixel.b]['blue']
    end
  end
  
  return img
end

local function modifiedContrastStretch(img, darkPercent, lightPercent)
  local rows, columns = img.height, img.width
  local pixelCount = rows * columns
  local histogram = {}
  local max = 0
  local min = 0
  local intensity = 0
  local darkCount = (darkPercent / 100) * pixelCount
  local lightCount = (lightPercent / 100) * pixelCount
  
  img = il.RGB2YIQ(img)
  
  for i = 0, 255 do
    histogram[i] = 0
  end
  
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      intensity = img:at(row, col).y
      
      histogram[intensity] = histogram[intensity] + 1
      
      if histogram[max] < histogram[intensity] then
        max = intensity
      end
      
      if histogram[min] > histogram[intensity] then
        min = intensity
      end
    end
  end
  
  local i = 0
  local count = 0
  
  for i = 0, 255 do
    count = count + histogram[i]
    
    if count > darkCount then
      min = i
      break
    end
  end
  
  for i = 255, 0, -1 do
    count = count + histogram[i]
    
    if count > lightCount then
      max = i
      break
    end
  end
  
  print("Max = " .. max)
  print("Min = " .. min)
  
  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      img:at(row, col).y = (255 / (max - min)) * (img:at(row, col).y - min)
    end
  end
  
  --img = il.showHistogram(il.YIQ2RGB(img))
  
  return il.YIQ2RGB(img)
end

local function automaticContrastStretch(img)
  return modifiedContrastStretch(img, 0, 0)
end

local function histogramDisplay(img)
  img = il.showHistogram(il.YIQ2RGB(img))
  return img
end

local function histogramDisplayRGB(img)
  img = il.showHistogramRGB(img)
  return img
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
  contrast = contrast,
  gamma = gamma,
  automaticContrastStretch = automaticContrastStretch,
  modifiedContrastStretch = modifiedContrastStretch,
  discretePseudocolor = discretePseudocolor,
  continuousPseudocolor = continuousPseudocolor,
  intensityHistogram = histogramDisplay,
  rgbHistogram = histogramDisplayRGB
}