require "ip"
local viz = require"visual"
local il = require "il"

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

start()