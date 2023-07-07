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
- `clear` : clear terminal
- `pause` : send the user to api.run()
- `echo string` : print text and return it
- `--- string` : return comment
- `solve lua-code` : solve a lua code
- `> lua-code` : same as solve
- `$ cmd` : direct access to OS terminal
- `set name anything` : set a variable inside plec's session
- `def lua-code-here` : create a command from inside plec
- `exit` : quit, but complete the current loop
- `terminate` : force quit, terminate the process

## plec - Syntax

- `&variable` : is replaced by the _variable_ value
- `!(command)!` : run _command_ on plec layer
- `;` : separate finish the command and start another
