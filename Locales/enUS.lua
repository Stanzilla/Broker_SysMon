
local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Broker_SysMon", "enUS", true)
if not L then return end

-- Broker_FPS
L["fps"] = true
L["Framerate"] = true
-- Broker_Latency
L["ms"] = true
L["Latency"] = true
-- Broker_MemUse
L["mb"] = true
L["Memory usage"] = true
L["List above shows the top %d addons with regards to memory usage."] = true
-- Broker_IncreasingRate
L["kbs"] = true
L["Increasing rate"] = true

