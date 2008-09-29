local format = string.format
local broker = LibStub("LibDataBroker-1.1")

local SysMon = {}
LibStub("AceTimer-3.0"):Embed(SysMon)

local icon = "Interface\\AddOns\\Broker_SysMon\\icon"

local FPS = broker:NewDataObject("Broker_FPS", {icon = icon, suffix = "fps", label = "Framerate"})
local Lag = broker:NewDataObject("Broker_Latency", {icon = icon, suffix = "ms", label = "Latency"})
local MemUse = broker:NewDataObject("Broker_MemUse", {icon = icon, suffix = "MiB", label = "Memory Usage", OnClick = function() collectgarbage('collect') end})
local IncreasingRate = broker:NewDataObject("Broker_IncreasingRate", {icon = icon, suffix = "KiB/s", label = "Increasing Rate"})

local initialMemory, currentMemory, mem1, mem2, mem3, mem4, mem5, mem6, mem7, mem8, mem9, mem10
local timeSinceLastUpdate, justEntered

function SysMon:OnUpdate()
	if not timeSinceLastUpdate then
		timeSinceLastUpdate = 0
	end
	timeSinceLastUpdate = timeSinceLastUpdate + 1

	if not (justEntered) then
		if timeSinceLastUpdate >= 10 then
			initialMemory = collectgarbage('count')
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
		currentMemory = collectgarbage('count')
	end
	if timeSinceLastUpdate >= 10 then
		timeSinceLastUpdate = nil
	end
	MemUse:Update()
	IncreasingRate:Update()
	Lag:Update()
	FPS:Update()
end

function FPS:Update()
	local framerate = floor(GetFramerate() + 0.5)
	
	self.value = framerate
	self.text = format("%s %s", framerate, self.suffix)
end

function Lag:Update()
	local latency = select(3, GetNetStats())
	
	self.value = latency
	self.text = format("%s %s", latency, self.suffix)
end

function MemUse:Update()
	local mem = format("%.1f", currentMemory / 1024)
	self.value = mem
	self.text = format("%s %s", mem, self.suffix)
end

function IncreasingRate:Update()
	if not mem10 then
		mem10 = currentMemory
	end
	local currentRate = format("%.1f",((currentMemory - mem10) / 10))
	self.value = currentRate
	self.text = format("%s %s", currentRate, self.suffix)
end

SysMon:ScheduleRepeatingTimer("OnUpdate", 1)
collectgarbage('collect')