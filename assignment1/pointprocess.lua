local function convertToGrayScale(img)
  return img
end

local function negate(img)
  return img:mapPixels( function( r, g, b )
      return 255 - r, 255 - g, 255 - b
    end
  )
end

local function binaryThreshold(img, threshold)
  return img
end

local function posterize(img, numberOfLevels)
  return img
end

local function brightness(img, amount)
  local rows, columns = img.height, img.width

  img = il.RGB2YIQ(img)

  for row = 0, rows - 1 do
    for col = 0, columns - 1 do
      img:at(row, col).y = img:at(row, col).y + amount

      if img:at(row, col).y > 255 then
        img:at(row, col).y = 255
      end
    end
  end

  return img.YIQ2RGB(img)
end

local function contrast(img, startPoint, endPoint)
  return img
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
  brightness = brightness
}