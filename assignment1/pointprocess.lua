local function convertToGrayScale(img)
 return img
end

local function negate(img)
  return img
end

local function binaryThreshold(img, threshold)
  return img
end

local function posterize(img, numberOfLevels)
  return img
end

local function brightness(img, amount)
  return img
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
  negate = negate
}