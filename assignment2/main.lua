require "ip"
local viz = require"visual"
local il = require "il"
local filt = require "filter"

local cmarg2 = {name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "yuv", "ihs"}, default = "yiq"}

imageMenu("Convienence Functions", 
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

imageMenu("Edge Detection", {})

imageMenu("Noise", {})

imageMenu("Filter", 
{
  {"3x3 Smoothing", filt.smoothing},
  {"3x3 Sharpen", filt.sharpen},
  {"Median+", filt.medianplus},
  {"Mean", filt.mean, {{name = "Mean n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Min", filt.min, {{name = "Min n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Max", filt.max, {{name = "Max n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Range", filt.range, {{name = "Range n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Std Dev", filt.stdDev, {{name = "Std Dev n x n", type = "number", displaytype = "spin", default = 3, min = 3, max = 255}}},
  {"Kirsch Magnitude", filt.kirschMag},
})

start()