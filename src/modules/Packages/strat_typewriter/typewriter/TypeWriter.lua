--!nocheck

local RS = game:GetService("RunService")

local Signal = require(script.Parent.Parent["red-blox_signal"].signal)

local TypeWriter = {}
TypeWriter.__index = TypeWriter

local RichTextTags = {
	["<b>"] = "</b>",
	["<i>"] = "</i>",
	["<u>"] = "</u>",
	["<s>"] = "</s>",
	["<smallcaps>"] = "</smallcaps>",
	["<sc>"] = "</sc>",

	['<font color=".-">'] = "</font>",
	['<font size=".-">'] = "</font>",
	['<font face=".-">'] = "</font>",

	["<!--.--->"] = false,
	["<br />"] = false,

	["&lt;"] = true,
	["&gt;"] = true,
	["&quot;"] = true,
	["&apos;"] = true,
	["&amp;"] = true,
}

--[[
	Construct a new typewriter
]]
function TypeWriter.new()
	local self = setmetatable({}, TypeWriter)

	self.onTextUpdated = Signal()
	self.onTyperFinished = Signal()

	self.stopped = false
	self.paused = false
	self.running = false
	self.speed = 0.01

	return self
end

local checkTag
do
	function checkTag(text)
		if not text then
			return nil
		end

		local tag = RichTextTags[text]
		if not tag then
			for i, v in RichTextTags do
				if not string.find(text, i) then
					continue
				end

				tag = v
				break
			end
		end

		return tag
	end
end

--[[
	Queue a task to type text
]]
function TypeWriter:TypeText(text: string)
	self:stop()
	self.stopped = false
	self.running = true

	local richTagsTable = {}
	local richTags = 0
	local cText = ""

	local index = 1
	while (index <= #text) and not self.stopped do
		--- Pause
		if self.paused then
			self.running = false
			while self.paused do
				RS.Heartbeat:Wait()
			end

			self.running = true
		end

		--- Normally
		local cChar = string.sub(text, index, index)
		if cChar == " " then --- blank space
			cText ..= cChar
			index += 1

			continue

		elseif cChar == "<" then
			local possibleTag = string.match(text, "<.->", index)
			local found = table.find(richTagsTable, possibleTag)

			if found then
				table.remove(richTagsTable, found)
				richTags -= 1

				cText ..= possibleTag
				index += #possibleTag -- jumps to content after tag

				continue
			end

			local endTag = checkTag(possibleTag)
			if endTag then
				table.insert(richTagsTable, 1, endTag)
				richTags += 1

				cText ..= possibleTag
				self.onTextUpdated:Fire(cText)

				index += #possibleTag
				continue

			elseif endTag == false then --- if the tag is <br> or something else
				cText ..= possibleTag
				index += #possibleTag
				continue
			end
		elseif cChar == "&" then
			local possibleTag = string.match(text, "&.-;", index)

			if checkTag(possibleTag) then
				cText ..= possibleTag
				index += #possibleTag

				--- Show Original Text, with tags
				local actualText = cText
				for i = 1, richTags do
					actualText ..= richTagsTable[i]
				end
				self.onTextUpdated:Fire(actualText)

				task.wait(self.speed)
				continue
			end
		end

		--- Almost done, show original text, with tags
		cText ..= string.sub(text, index, index)

		local actualText = cText
		for i = 1, richTags do
			actualText ..= richTagsTable[i]
		end
		self.onTextUpdated:Fire(actualText)

		index += 1
		task.wait(self.speed)
	end

	--- End Typing
	self.running = false
	self.onTyperFinished:Fire()
end

--[[
	Stop the task of typing text
]]
function TypeWriter:Stop()
	self.paused = false
	self.stopped = true

	while self.running do
		RS.Heartbeat:Wait()
	end
end

--[[
	Adjust the speed of the typewriter
]]
function TypeWriter:AdjustSpeed(newSpeed: number)
	self.speed = newSpeed
end

--[[
	Pause the current typewriter task
]]
function TypeWriter:Pause()
	self.paused = true
	while self.running do
		RS.Heartbeat:Wait()
	end
end

--[[
	Resume the current typewriter task
]]
function TypeWriter:Resume()
	self.paused = false
	while not self.running do
		RS.Heartbeat:Wait()
	end
end

--[[
	Check if the typewriter is typing text
]]
function TypeWriter:IsTyping()
	return self.running
end

--[[
	Destroy the typewriter, let it be garbadge collected
]]
function TypeWriter:Destroy()
	self.paused = false
	self.stopped = true
	self.onTextUpdated:DisconnectAll()
	self.onTyperFinished:DisconnectAll()

	while self.running do
		RS.Heartbeat:Wait()
	end

	self = nil
end

return TypeWriter
