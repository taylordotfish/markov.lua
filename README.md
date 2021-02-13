markov.lua
==========

markov.lua is a Markov chain text generation library written in Lua. It works
with Lua 5.1 and later.

Example
-------

See [example/](example) for an example. Inside that directory, you can run
`./example.lua` or `lua example.lua` to run the example.

Installation
------------

### From LuaRocks

```bash
luarocks install markov-text
```

This must be run as root (e.g., with sudo) unless the package is installed
locally by adding the `--local` option.

### From the Git repository

```bash
git clone https://github.com/taylordotfish/markov.lua
cd markov.lua
luarocks make
```

`luarocks make` must be run as root (e.g., with `sudo`) unless the package is
installed locally by adding the `--local` option.

### Use without installing

You can also use markov.lua without installing it by setting `package.path`
or `LUA_PATH` explicitly; see [example.lua](example/example.lua) for an example
of the former.

License
-------

markov.lua is licensed under version 3 or later of the GNU General Public
License. See [LICENSE](LICENSE).
