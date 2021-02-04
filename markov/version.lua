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

local version

local function generate()
	version = {_VERSION:match("(%d+)%.(%d+)$")}
	for i = 1, #version do
		version[i] = tonumber(version[i]) or 0
	end
	return version
end

local function get()
	if version == nil then
		generate()
	end
	return version
end

local function test(...)
	local real_vs = get()
	local test_vs = {...}
	for i = 1, #test_vs do
		local r = real_vs[i] or 0
		local t = test_vs[i]
		if r < t then
			return -1
		end
		if r > t then
			return 1
		end
	end
	return 0
end

return {
	get = get,
	test = test,
}
