-- LuaIP image processing routines
require "ip"   -- this loads the packed distributable
local viz = require "visual"
local il = require "il"
local ourProcesses = require "pointprocess"

imageMenu("Our Processes",
{
  {"Grayscale", ourProcesses.grayscale},
  {"Pseudocolor", ourProcesses.discretePseudocolor},
  {"Continuous", ourProcesses.continuousPseudocolor},
  {"Negate", ourProcesses.negate},
  {"Brightness", ourProcesses.brightness, {{name = "Brightness level", type = "number", displaytype = "spin", default = 128, min = 0, max = 255}}},
  {"Binary Threshold", ourProcesses.binaryThreshold, {{name = "threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
  {"Posterize", ourProcesses.posterize, {{name = "levels", type = "number", displaytype = "slider", default = 8, min = 0, max = 255}}},
  {"Contrast", ourProcesses.contrast, {{name = "endpoint1", type = "number", displaytype = "slider", default = 0, min = 0, max = 255},
                                       {name = "endpoint2", type = "number", displaytype = "slider", default = 255, min = 0, max = 255}}},
  {"Gamma", ourProcesses.gamma, {{name = "Gamma", type = "number", displaytype = "textbox"}}},
  {"Automatic Contrast Stretch", ourProcesses.automaticContrastStretch},
  {"Modified Contrast Stretch", ourProcesses.modifiedContrastStretch, {{name = "Dark Percent", type = "number", displaytype = "slider", default = 0, min = 0, max = 100},
  {name = "Light Percent", type = "number", displaytype = "slider", default = 0, min = 0, max = 100}}},
  {"Bitplane Slice", ourProcesses.bitSlice, {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}},
  {"Ben Auto Stretch", ourProcesses.autoStretch}
})

imageMenu("Our Histogram",
{
  {"Intensity Histogram", ourProcesses.intensityHistogram},
  {"RGB Histogram", ourProcesses.rgbHistogram}
})

imageMenu("Help",
  {
    { "Help", viz.imageMessage( "Help", "To process an image:\n 1. File -> Open to select an image to process\n2. Click different menu options to perform computations\n" ..
        "3. File-> Save if you desire to save to a file") },
    { "About", viz.imageMessage( "CSC 442 Assignment 1", "Authors: Benjamin Kaiser and Taylor Doell\nClass: CSC442/542 Digital Image Processing\nDate: Spring 2017" ) },
  }
)

start()
