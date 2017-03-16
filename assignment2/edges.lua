--[[
  Authors: Benjamin Kaiser and Taylor Doell
  Description:  This file handles all of the edge detection functions for our program.  
]]

require "ip"

local il = require "il"
local math = require "math"
local help = require "helper"


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

--[[
  Author: Benjamin Kaiser
  Description: This function takes an image and a boolean flag which tells it whether to
  compute the magnitude of the edge or the direction of the edge.
  Either way, the function loops through the image pixel by pixel and for
  each pixel it computes the x and y gradient components by applying the
  x and y masks.  Then depending on whether or not the flag is set it
  sets the new intensity values to either magnitude or direction representations.  
  Magnitude is done by taking the square root of the sum of the squares of the components
  Direction is done by taking the arctan of the y component divided by the x component.  
  If the value is negative, 2 * pi is added to do an offset.  
  The value is then mapped from this value into the 0 to 255 range.  
  After this is done, clipping occurs and the value is returned. 
]]
local function sobelEdge(img, isMagnitude)
  local rows, columns = img.height, img.width
  
  local cloneImg = img:clone()
  
  --sobel masks
  local yMask = {{1, 2, 1}, {0 , 0, 0}, {-1, -2, -1}}
  local xMask = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}}
  
  --variables for my gradient components
  local G_x, G_y
  
  --variables for reflected rows
  local reflectedRow = 0
  local reflectedColumn = 0
  
  local rowCount = 0
  local columnCount = 0
  local result = 0
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  --process the image
  for row = 0, rows - 1 do
    for column = 0, columns - 1 do
      
     G_x = 0
     G_y = 0
     
     --loop filter and compute Gx and Gy
      rowCount = row - 1
      for i = 1, 3 do
        columnCount = column - 1
        for j = 1, 3 do
          --find reflection
          reflectedColumn, reflectedRow = help.reflection(columnCount, rowCount, columns - 1, rows - 1)
          
          G_x = G_x + xMask[i][j] * img:at(reflectedRow, reflectedColumn).y
          G_y = G_y + yMask[i][j] * img:at(reflectedRow, reflectedColumn).y
          
          columnCount = columnCount + 1
        end
        rowCount = rowCount + 1
      end
      
      --compute magnitude
      if isMagnitude then
        result = math.sqrt((G_x * G_x) + (G_y * G_y))
      --compute direction
      else
        result = math.atan2(G_y,G_x)
        --do recentering
        if result < 0 then
          result = result + 2 * math.pi
        end
        --scale
        result = math.floor(256 * (result)/(2*math.pi))
      end
      
      --clip
      if result > 255 then
        result = 255
      elseif result < 0 then
        result = 0
      end
      
      cloneImg:at(row, column).r = result
      --grayscale stuff
      cloneImg:at(row, column).g = 128
      cloneImg:at(row, column).b = 128
      
    end
  end
  
  return il.YIQ2RGB(cloneImg)
end

--[[
Author: Benjamin Kaiser
Description: This function is just a wrapper function for the sobelEdge function
and it passes the image that it received along with a true flag indicating that the
sobel edge function should return the magnitude.
]]
local function sobelMag(img)
  return sobelEdge(img, true)
end

 --[[
Author: Benjamin Kaiser
Description: This function is just a wrapper function for the sobelEdge function
and it passes the image that it received along with a false flag indicating that the
sobel edge function should return the direction
]]
local function sobelDirection(img)
   return sobelEdge(img, false)
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

return
{
  laplacian = laplacian,
  sobelMag = sobelMag,
  sobelDir = sobelDirection,
  kirschMagDir = kirschMagnitudeDirection
}