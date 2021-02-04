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
local version = require(pkg .. "version")

local function rshift8(x)
	return math.floor(x / 256)
end

local function lshift8(x)
	return x * 256
end

local function low8(x)
	return x % 256
end

if version.test(5, 3) >= 0 then
	rshift8 = load("return function(x) \
		return x >> 8 \
	end")()

	lshift8 = load("return function(x) \
		return x << 8 \
	end")()

	low8 = load("return function(x) \
		return x % 256 \
	end")()
end

return {
	rshift8 = rshift8,
	lshift8 = lshift8,
	low8 = low8,
}
