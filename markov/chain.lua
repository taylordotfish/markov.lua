-- Copyright (C) 2021 taylor.fish <contact@taylor.fish>
--
-- This file is part of markov.lua.
--
-- markov.lua is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- markov.lua is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with markov.lua. If not, see <https://www.gnu.org/licenses/>.

local pkg = (...):match(".+%.")
local Sentinel = require(pkg .. "sentinel")
local serialize = require(pkg .. "serialize")

local NIL = Sentinel:new("NIL")
local TOTAL = Sentinel:new("TOTAL")



local Chain = {}
Chain.__index = Chain

-- Class method: invoke as Chain:new(...)
function Chain:new(depth)
	return setmetatable({
		depth = depth or 1,
		data = {},
	}, self)
end

function Chain:add(words)
	local start = 1 - self.depth
	local stop = #words - self.depth + 1
	for i = start, stop do
		self:_add_chunk(words, i)
	end
end

function Chain:generate()
	local words = {}
	self:_extend(words, 1 - self.depth)
	return words
end

function Chain:serialize(file)
	serialize.int.write(file, self.depth)
	self:_serialize(file, self.data)
end

-- Class method: invoke as Chain:deserialize(...)
function Chain:deserialize(file)
	local depth = serialize.int.read(file)
	local obj = self:new(depth)
	obj:_deserialize(file, obj.data, 0)
	return obj
end



function Chain:_add_chunk(words, start)
	start = start or 1
	local stop = start + self.depth
	local map = self.data
	local word = words[start] or NIL

	for i = start, stop - 1 do
		word = words[i] or NIL
		map[word] = map[word] or {}
		map = map[word]
	end

	word = words[stop] or NIL
	map[word] = (map[word] or 0) + 1
	map[TOTAL] = (map[TOTAL] or 0) + 1
end

function Chain:_pick(words, start)
	local start = start or 1
	local map = self.data
	for i = start, start + self.depth - 1 do
		local word = words[i] or NIL
		map = map[word]
		if map == nil then
			return nil
		end
	end

	local i = math.random(map[TOTAL])
	for word, freq in pairs(map) do repeat
		if word == NIL then
			word = nil
		elseif getmetatable(word) == Sentinel then
			break
		end

		if i <= freq then
			return word
		end
		i = i - freq
	until true end
end

function Chain:_extend(words, start)
	while true do
		local word = self:_pick(words, start)
		if word == nil then
			return
		end
		table.insert(words, word)
		start = start + 1
	end
end



local Prefix = {
	value = 0,
	null = 1,
	exit = 2,
}

function Chain:_serialize_word(file, word)
	if word == NIL then
		serialize.int.write(file, Prefix.null)
	elseif getmetatable(word) ~= Sentinel then
		serialize.int.write(file, Prefix.value)
		serialize.string.write(file, word)
	else
		return false
	end
	return true
end

function Chain:_serialize_leaf(file, map)
	for word, freq in pairs(map) do
		if self:_serialize_word(file, word) then
			serialize.int.write(file, freq)
		end
	end
	serialize.int.write(file, Prefix.exit)
end

function Chain:_serialize(file, map)
	if map[TOTAL] ~= nil then
		self:_serialize_leaf(file, map)
		return
	end
	for word, submap in pairs(map) do
		if self:_serialize_word(file, word) then
			self:_serialize(file, submap)
		end
	end
	serialize.int.write(file, Prefix.exit)
end

function Chain:_deserialize_word(file)
	local pre = serialize.int.read(file)
	if pre == Prefix.null then
		return NIL
	elseif pre == Prefix.value then
		return serialize.string.read(file)
	end
	return nil
end

function Chain:_deserialize_leaf(file, map)
	map[TOTAL] = 0
	while true do
		local word = self:_deserialize_word(file)
		if word == nil then
			break
		end
		map[word] = serialize.int.read(file)
		map[TOTAL] = map[TOTAL] + map[word]
	end
end

function Chain:_deserialize(file, map, level)
	if level == self.depth then
		self:_deserialize_leaf(file, map)
		return
	end
	while true do
		local word = self:_deserialize_word(file)
		if word == nil then
			break
		end
		map[word] = {}
		self:_deserialize(file, map[word], level + 1)
	end
end

return Chain
