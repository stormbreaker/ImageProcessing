--[[
  Author: Benjamin Kaiser and Taylor Doell
  Class: CSC 442 - Digital Image Processing
  Assignment 2 - Neighborhood Processes
  Description:  This file is the main file.  It creates the GUI for the
  application and adds all of the menu items onto the GUI along with
  their associated callback functions.  This is based on lip.lua which
  was created by Dr. Weiss and Alex Iverson
  
  Extra Credit attempts: Reflection
]]

-- LuaIP image processing routines
require "ip"
local viz = require"visual"
local il = require "il"
local filt = require "filter"
local edge = require "edges"
local noise = require "noise"

local cmarg2 = {name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "yuv", "ihs"}, default = "yiq"}

--Creates all of the menu items for convenience functions
imageMenu("Convenience Functions", 
{
  {"Grayscale", il.grayscaleYIQ, hotkey = "C-M"},
  {"Display Histogram", il.showHistogram,
       {{name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "rgb"}, default = "yiq"}}},
  {"Contrast Stretch", il.stretch, {cmarg2}},
  {"Histogram Equalize", il.equalize,
       {{name = "color model", type = "string", displaytype = "combo", choices = {"ihs", "yiq", "yuv", "rgb"}, default = "yiq"}}},
  {"Binary Threshold", il.threshold,
      {{name = "threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
  {"Gaussian noise", il.gaussianNoise,
      {{name = "sigma", type = "number", displaytype = "textbox", default = "16.0"}}},
  {"Impulse Noise", il.impulseNoise,
      {{name = "probability", type = "number", displaytype = "slider", default = 64, min = 0, max = 1000}}}
})

-- Creates all of the edge detection menu items
imageMenu("Edge Detection", 
{
  {"Kirsch Magnitude / Direction", edge.kirschMagDir},
  {"Sobel Magnitude / Direction", edge.sobelEdge},
  {"Laplacian", edge.laplacian}
})

-- Creates all of the noise cleaning menu items
imageMenu("Noise Cleaning", 
{
  {"Out of Range Clean", noise.outofrange, {{name = "Threshold", type = "number", displaytype = "slider", default = 64, min = 0, max = 255}}},
  {"Median Filter", noise.median, {{name = "Median n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Median+", noise.medianplus}
})

-- Creates all of the general neighborhood process menu items
imageMenu("Filter Processes", 
{
  {"3x3 Smoothing", filt.smoothing},
  {"3x3 Sharpen", filt.sharpen},
  {"Mean", filt.mean, {{name = "Mean n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Min", filt.min, {{name = "Min n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Max", filt.max, {{name = "Max n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Range", filt.range, {{name = "Range n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Std Dev", filt.stdDev, {{name = "Std Dev n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Emboss", filt.emboss}
})

start()