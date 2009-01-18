local format = string.format
local broker = LibStub("LibDataBroker-1.1")
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_SysMon")

local FPS = broker:NewDataObject(L["Broker_FPS"], {suffix = L["fps"], label = L["Framerate"]})
local Lag = broker:NewDataObject(L["Broker_Latency"], {suffix = L["ms"], label = L["Latency"]})
local MemUse = broker:NewDataObject(L["Broker_MemUse"], {suffix = L["MiB"], label = L["Memory Usage"], OnClick = function() collectgarbage("collect") end})
local IncreasingRate = broker:NewDataObject(L["Broker_IncreasingRate"], {suffix = L["KiB/s"], label = L["Increasing Rate"]})

local initialMemory, currentMemory, mem1, mem2, mem3, mem4, mem5, mem6, mem7, mem8, mem9, mem10
local timeSinceLastUpdate, justEntered

local brokers = {
    [FPS] = function() return floor(GetFramerate() + 0.5) end,
    [Lag] = function() return select(3, GetNetStats()) end,
    [MemUse] = function() return format("%.1f", currentMemory / 1024) end,
    [IncreasingRate] = function() return format("%.1f",((currentMemory - mem10) / 10)) end,
}

local icon = "Interface\\AddOns\\Broker_SysMon\\icon"
for k, v in pairs(brokers) do
	k.OnTooltipShow = function(tt)
		tt:AddLine(k.label)
		tt:AddLine(format("%s %s", v(), k.suffix))
	end
	k.icon = icon
	k.type = "data source"
end

local f = CreateFrame("Frame")
local total = 0
f:SetScript("OnUpdate", function(self, elapsed)
	total = total + elapsed
	if total < 1 then return end
	total = 0
	if not timeSinceLastUpdate then
		timeSinceLastUpdate = 0
	end
	timeSinceLastUpdate = timeSinceLastUpdate + 1

	if not (justEntered) then
		if timeSinceLastUpdate >= 10 then
			initialMemory = collectgarbage("count")
			currentMemory = initialMemory
			mem1 = currentMemory
			mem2 = currentMemory
			mem3 = currentMemory
			mem4 = currentMemory
			mem5 = currentMemory
			mem6 = currentMemory
			mem7 = currentMemory
			mem8 = currentMemory
			mem9 = currentMemory
			mem10 = currentMemory
			justEntered = true
		else
			currentMemory = 0
			initialMemory = 0
		end
	else
		mem1, mem2, mem3, mem4, mem5, mem6, mem7, mem8, mem9, mem10 =
			currentMemory, mem1, mem2, mem3, mem4, mem5, mem6, mem7, mem8, mem9
		currentMemory = collectgarbage("count")
	end
	if timeSinceLastUpdate >= 10 then
		timeSinceLastUpdate = nil
	end
	if not mem10 then
		mem10 = currentMemory
	end
	for k, v in pairs(brokers) do
		local value = v()
	    k.value = value
	    k.text = format("%s %s", value, k.suffix)
	end
end)
f:Show()

collectgarbage("collect")

