require "ip"

local il = require "il"
local math = require "math"


local function smoothing(img)
  local rows, columns = img.height, img.width
  
  local cloneImg = img:clone()
  
  img = il.RGB2YIQ(img)
  cloneImg = il.RGB2YIQ(cloneImg)
  
  local mask = {{1, 2, 1}, {2, 4, 2}, {1, 2, 1}}
  
  local sum
  
  for row = 1, rows - 2 do
    print("row"..row)
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
      
      cloneImg:at(row, column).y = math.floor(sum/16)
    
      
    end 
  end
  return il.YIQ2RGB(cloneImg)
  
end

return
{
  smoothing = smoothing
}