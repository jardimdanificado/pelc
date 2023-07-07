## plec - Command-line Commands

- `plec` : Starts the plec
- `plec (file)` : Starts the repl with the specified script(.plec)
- `plec -lstd` : Starts the repl with the specified preloaded lib(require), in this case _lib.std_
- `plec -l lib/std.lua` : Starts the repl with the specified not-preloaded lib(import), in this case _./lib/std.lua_

## plec - Built-In Commands

- `require modname` : require a preloaded lib named _modname_
- `import filepath` : load via _dofile_ pointed by _filepath_
- `run scriptname` : run the _filename_ script
- `set name anything` : set a variable inside plec's session, you can also use this to set references
- `def lua-code-here` : create a command from inside plec
- `autodef lua-code-here` : create a command from inside plec and automaticly load it
- `load` : load a existing cmd to session.
- `> lua-code` : solve a lua code

## plec - Built-In Workers

- `=` : turn _varname_ = _any1_ to set _varname_ _any1_
- `=>` : turn _functioname_ => _any1_ to def _functioname_ _any1_
- `unref` : turn _&any_ into its setted value, or replace by '' if no value set
- `unwrapcmd` : turn _!(any)!_ into session:run('any') result
- `spacendclean` : remove all spaces on start and end of command
- `timepass` : increments session.time
- `sigfault` : verify if the asked command is avaliable

## plec - Session Temp Values

- `session.temp.exit` : responsible for exiting repl or keep in loop
- `session.temp.keep` : prevent the session.temp begin cleared, auto-disable
- `session.temp.wskip` : skip remaining workers
- `session.temp.cskip` : prevent command from running but run all workers
- `session.temp.skip` : skip both remaining workers and command

## plec - Standard Library(lib.std)

- `help` : list all existing commands
- `lhelp` : list all loaded commands
- `clear` : clear terminal
- `pause` : send the user to api.run()
- `echo string` : print text and return it
- `--- string` : return comment
- `solve lua-code` : same as solve
- `$ cmd` : direct access to OS terminal
- `exit` : quit, but complete the current loop
- `terminate` : force quit, terminate the process

## plec - Worker library(lib.worker)

- `worker.spawn id position newid` : spawn a loaded worker, only _id_ is obligatory
- `worker.help` : list all spawned workers
- `worker.lhelp` : list all loaded workers

## plec - Syntax

- `&variable` : is replaced by the _variable_ value
- `!(command)!` : run _command_ on plec layer
- `;` : separate finish the command and start another
