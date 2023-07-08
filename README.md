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

## plec - Built-In steps

- `=` : turn _varname_ = _any1_ into set _varname_ _any1_
- `=>` : turn _functioname_ => _any1_ into def _functioname_ _any1_
- `@` : turn _@ref_ into _&ref_
- `unref` : turn _&any_ into its setted value, or replace by '' if no value set
- `unwrapcmd` : turn _!(any)!_ into session:run('any') result
- `spacendclean` : remove all spaces on start and end of command
- `timepass` : increments session.time
- `sigfault` : verify if the asked command is avaliable

## plec - Session Temp Values

- `session.temp.exit` : responsible for exiting repl or keep in loop
- `session.temp.keep` : prevent the session.temp begin cleared, auto-disable
- `session.temp.wskip` : skip remaining steps
- `session.temp.cskip` : prevent command from running but run all steps
- `session.temp.skip` : skip both remaining steps and command

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

## plec - step library(lib.step)

- `step.add id position newid` : sadd a loaded step, only _id_ is obligatory
- `step.rm p` : remove step ate _p_ position
- `step.help` : list all sadded steps
- `step.lhelp` : list all loaded steps

## plec - Syntax

- `&variable` : is replaced by the _variable_ value
- `!(command)!` : run _command_ on plec layer
- `;` : separate commands, finish the command and start a new one
