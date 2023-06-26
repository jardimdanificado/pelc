## pxlConsole - Plugin eXtensible Lua Console

The reference _Plugin eXtensible Lua Console_ implementation.

## pxlConsole - Command-line Commands

- `pxl` : Starts the pxlConsole
- `pxl (file)` : Starts the repl with the specified script(.pxl)
- `pxl -lstd` : Starts the repl with the specified preloaded lib(require), in this case _lib.std_
- `pxl -l lib/std.lua` : Starts the repl with the specified not-preloaded lib(import), in this case _./lib/std.lua_

## pxlConsole - Built-In Commands

- `require (modname)` : require a preloaded lib named (_modname_)
- `import (filepath)` : load via _dofile_ pointed by (_filepath_)

## pxlConsole - Standard Library(lib.std)

- `help` : list all loaded commands
- `clear` : clear terminal
- `run (scriptname)` : run the (_filename_) script
- `pause` : send the user to api.run()
- `echo (string)` : print text and proceed
- `print (string)` : print text and wait for another command
- `> (cmd)` : access lua layer
- `$ (cmd)` : direcly access OS layer( os.execute((_cmd_)) )
- `exit` : quit, but complete the current loop
- `end` : force quit, terminate the process
