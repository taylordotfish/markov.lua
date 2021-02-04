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
local bits = require(pkg .. "bits")

local MAX_BYTES = 4
local MAX_SMALL_INT = 255 - MAX_BYTES
local unpack = table.unpack or unpack



local int = {};

function int.read(file)
	local str = file:read(1)
	if str == nil then
		return nil
	end

	local byte = str:byte(1)
	if byte <= MAX_SMALL_INT then
		return byte
	end

	local x = 0
	for i = 1, 256 - byte do
		x = lshift8(x) + file:read(1):byte(1)
	end
	return x
end

function int.write(file, x)
	if x <= MAX_SMALL_INT then
		file:write(string.char(x))
		return
	end

	local bytes = {}
	for i = 1, MAX_BYTES do
		bytes[i] = bits.low8(x)
		x = bits.rshift8(x)
		if x == 0 then
			break
		end
	end

	file:write(string.char(256 - #bytes))
	file:write(string.char(unpack(bytes)):reverse())
end



local string = {};

function string.read(file)
	local len = int.read(file)
	if len == nil then
		return nil
	end
	return file:read(len)
end

function string.write(file, str)
	int.write(file, #str)
	file:write(str)
end

return {
	int = int,
	string = string,
}
