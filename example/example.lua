#!/usr/bin/env lua
-- To the extent possible under law, the author(s) have dedicated all
-- copyright and neighboring rights to this software to the public domain
-- worldwide. This software is distributed without any warranty. See
-- <http://creativecommons.org/publicdomain/zero/1.0/> for a copy of the
-- CC0 Public Domain Dedication.
--
-- Note that the above copyright notice applies only to the code in this
-- file: markov.lua, which this code depends on, is licensed under version
-- 3 or later of the GNU General Public License. Thus, any version of this
-- code that links to or is otherwise a derived work of markov.lua may be
-- distributed only in accordance with markov.lua's license.

-- This line isn't needed if markov.lua has been installed (e.g., from
-- LuaRocks, where it is available under the name "markov-text").
package.path = "../?.lua;../?/init.lua;" .. package.path

local markov = require("markov")
local SCRIPT_DIR = string.gsub(arg[0], "[^/\\]*$", "")
local CORPUS_PATH = SCRIPT_DIR .. "corpus.txt"
local CHAIN_PATH = SCRIPT_DIR .. "cached-chain"

local function generate_chain()
	-- Use a depth of 2, meaning each pair of words is mapped to a set of
	-- possible next words.
	local chain = markov.Chain:new(2)
	local file = assert(io.open(CORPUS_PATH))
	local words = {}
	while true do
		local line = file:read("*l")
		if line == nil then
			break
		end
		for word in string.gmatch(line, "[^%s]+") do
			table.insert(words, word)
		end
		if line == "" then
			chain:add(words)
			words = {}
		end
	end
	chain:serialize(assert(io.open(CHAIN_PATH, "wb")))
	return chain
end

local function main()
	local chain
	local file = io.open(CHAIN_PATH, "rb")
	if file == nil then
		chain = generate_chain()
	else
		chain = markov.Chain:deserialize(file)
	end
	print(table.concat(chain:generate(), " "))
end

main()
