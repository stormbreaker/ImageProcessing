-- LuaIP image processing routines
require "ip"   -- this loads the packed distributable
local viz = require "visual"
local il = require "il"
local ourProcesses = require "pointprocess"

imageMenu("Test",
  {{"Resize", ourProcesses.grayscale},
   {"Negate", ourProcesses.negate},
   {"Brightness", ourProcesses.brightness, {{name = "Brightness level", type = "number", displaytype = "spin", default = 128, min = 0, max = 255}}}
 }
 )



imageMenu("Help",
  {
    { "Help", viz.imageMessage( "Help", "To process an image:\n 1. File -> Open to select an image to process\n2. Click different menu options to perform computations\n" ..
        "3. File-> Save if you desire to save to a file") },
    { "About", viz.imageMessage( "CSC 442 Assignment 1", "Authors: Benjamin Kaiser and Taylor Doell\nClass: CSC442/542 Digital Image Processing\nDate: Spring 2017" ) },
  }
)

start()