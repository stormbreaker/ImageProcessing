--[[
  Author: Benjamin Kaiser and Taylor Doell
  Class: CSC 442 - Digital Image Processing
  Assignment 1 - Point Processes
  Description:  This file is the main file it creates the GUI for the application
  and adds all of the menu items on along with their associated callback functions.
  This is based on lip.lua which was created by Dr. Weiss and Alex Iverson
]]

-- LuaIP image processing routines
require "ip"   -- this loads the packed distributable
local viz = require "visual"
local il = require "il"
local point = require "pointprocess"
local hist = require "histogram"

--[[Creates all of the point process menu items]]
imageMenu("Point Processes",
{
  {"Grayscale", point.grayscale},
  {"Pseudocolor", point.discretePseudocolor},
  {"Continuous", point.continuousPseudocolor},
  {"Negate", point.negate},
  {"Brightness", point.brightness, {{name = "Brightness level", type = "number", displaytype = "slider", default = 0, min = -255, max = 255}}},
  {"Binary Threshold", point.binaryThreshold, {{name = "threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
  {"Posterize", point.posterize, {{name = "levels", type = "number", displaytype = "slider", default = 8, min = 0, max = 255}}},
  {"Contrast", point.contrast, {{name = "endpoint1", type = "number", displaytype = "slider", default = 0, min = 0, max = 255},
                                       {name = "endpoint2", type = "number", displaytype = "slider", default = 255, min = 0, max = 255}}},
  {"Gamma", point.gamma, {{name = "Gamma", type = "number", displaytype = "textbox"}}},
  {"Log", point.logCompress},
  {"Bitplane Slice", point.bitSlice, {{name = "plane", type = "number", displaytype = "spin", default = 7, min = 0, max = 7}}},
  {"Solarization (Added Process)", point.solarization, {{name = "solarization", type = "number", displaytype = "spin", default = 255, min = 0, max = 255}}},
})

--[[Creates the histogram process menu items]]
imageMenu("Histogram Methods",
{
  {"Intensity Histogram", hist.intensityHistogram},
  {"RGB Histogram", hist.rgbHistogram},
  {"Histogram Equalization", hist.equalize},
  {"Histogram Equalize with Clipping", hist.equalizeClip, {{name = "Clip %", type = "number", displaytype = "textbox", default = "1.0"}}},
  {"Automatic Contrast Stretch", hist.automaticContrastStretch},
  {"Modified Contrast Stretch", hist.modifiedContrastStretch, {{name = "Dark Percent", type = "number", displaytype = "slider", default = 0, min = 0, max = 100},
  {name = "Light Percent", type = "number", displaytype = "slider", default = 0, min = 0, max = 100}}},
})

--[[Creates the help and abbout menu item]]
imageMenu("Help",
  {
    { "Help", viz.imageMessage( "Help", "To process an image:\n 1. File -> Open to select an image to process\n2. Click different menu options to perform computations\n" ..
        "3. File-> Save if you desire to save to a file") },
    { "About", viz.imageMessage( "CSC 442 Assignment 1", "Authors: Benjamin Kaiser and Taylor Doell\nGUI:  Dr. Weiss and Alex Iverson\nClass: CSC442/542 Digital Image Processing\nDate: Spring 2017" ) },
  }
)

start()
