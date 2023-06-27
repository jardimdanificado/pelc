## plec - Portable Lua Extensible Console

The reference _Portable Lua Extensible Console_ implementation.

## plec - Command-line Commands

- `plec` : Starts the plec
- `plec (file)` : Starts the repl with the specified script(.plec)
- `plec -lstd` : Starts the repl with the specified preloaded lib(require), in this case _lib.std_
- `plec -l lib/std.lua` : Starts the repl with the specified not-preloaded lib(import), in this case _./lib/std.lua_

## plec - Built-In Commands

- `require modname` : require a preloaded lib named _modname_
- `import filepath` : load via _dofile_ pointed by _filepath_
- `run scriptname` : run the _filename_ script

## plec - Standard Library(lib.std)

- `help` : list all loaded commands
- `solve` : solve a lua code
- `clear` : clear terminal
- `pause` : send the user to api.run()
- `echo string` : print text and proceed
- `> cmd` : direct access to lua layer
- `$ cmd` : direct access to OS terminal
- `fn lua-code-here` : create a command from inside plec
- `exit` : quit, but complete the current loop
- `terminate` : force quit, terminate the process

## plec - Syntax

- `&varaible` : is replaced by the _vatiable_ value
- `$(command)` : run _command_ on OS layer, is replaced by its terminal output
- `>(command)` : run _command_ on lua layer, otg version of > operator
- `!(command)` : run _command_ on plec layer, otg version of solve
- ` ; ` : separate finish the command and start another