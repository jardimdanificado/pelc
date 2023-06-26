## pelc - Plugin Extensible Lua Console

The reference _Plugin Extensible Lua Console_ implementation.

## pelc - Command-line Commands

- `pelc` : Starts the pelc
- `pelc (file)` : Starts the repl with the specified script(.pelc)
- `pelc -lstd` : Starts the repl with the specified preloaded lib(require), in this case _lib.std_
- `pelc -l lib/std.lua` : Starts the repl with the specified not-preloaded lib(import), in this case _./lib/std.lua_

## pelc - Built-In Commands

- `require (modname)` : require a preloaded lib named (_modname_)
- `import (filepath)` : load via _dofile_ pointed by (_filepath_)

## pelc - Standard Library(lib.std)

- `help` : list all loaded commands
- `clear` : clear terminal
- `run (scriptname)` : run the (_filename_) script
- `pause` : send the user to api.run()
- `echo (string)` : print text and proceed
- `> (cmd)` : direct access to lua layer
- `$ (cmd)` : direct access to OS terminal
- `exit` : quit, but complete the current loop
- `terminate` : force quit, terminate the process
