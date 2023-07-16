## plec - Command-line Commands

- `plec` : Starts the plec
- `plec (file)` : Starts the repl with the specified script(.plec)
- `plec -lstd` : Starts the repl with the specified preloaded lib(require), in this case _lib.std_
- `plec -l lib/std.lua` : Starts the repl with the specified not-preloaded lib(import), in this case _./lib/std.lua_

## plec - Built-In Commands

- `require modname` : require a preloaded lib named _modname_
- `import filepath` : load via _dofile_ pointed by _filepath_

## plec - Built-In Libraries

- `lib.core` : core are the essential to get a working console session, it is automatically loaded into plec from main.lua, only need to worry about loading it if running a custom/modified plec
- `lib.std` : standard is a extension of core, mostly composed by utils
- `lib.time` : creates session.data.time and automaticly set a timepass worker on top of others
- `lib.worker` : allow workers to be modified from inside a plec script or repl

## plec - Session Temp Values

- `session.temp.exit` : responsible for exiting repl or keep in loop
- `session.temp.keep` : prevent the session.temp begin cleared, auto-disable
- `session.temp.wskip` : skip remaining workers
- `session.temp.cskip` : prevent command from running but run all workers
- `session.temp.skip` : skip both remaining workers and command

## plec - Core Library Commands(lib.core)

- `run scriptname` : run the _filename_ script
- `set name anything` : set a variable inside plec's session, you can also use this to set references
- `unset var-name` : unset a variable
- `def lua-code-here` : create a command from inside plec
- `undef cmd-name` : delete a cmd from data
- `autodef lua-code-here` : create a command from inside plec and automaticly load it
- `load` : load a existing cmd to session.
- `unload` : unload a loaded cmd from session.
- `> lua-code` : solve a lua code

## plec - Core Library workers(lib.core)

- `=` : turn _varname_ = _any1_ into set _varname_ _any1_
- `=>` : turn _functioname_ => _any1_ into def _functioname_ _any1_
- `unref` : turn _@any_ into its setted value, or replace by '' if no value set
- `unwrapcmd` : turn _([any])_ into session:run('any') result
- `spacendclean` : remove all spaces on start and end of command
- `timepass` : increments session.time
- `sigfault` : verify if the asked command is avaliable

## plec - Standard Library(lib.std)

- `help` : list all existing commands
- `lhelp` : list all loaded commands
- `clear` : clear terminal
- `pause` : send the user to api.run()
- `echo string` : print text and return it
- `--- string` : return comment
- `$ cmd` : direct access to OS terminal
- `exit` : quit, but complete the current loop
- `terminate` : force quit, terminate the process

## plec - worker Library Commands(lib.worker)

- `worker.add id position newid` : workeradd a loaded worker, only _id_ is obligatory
- `worker.rm index/id` : remove worker at _index_ or by its _id_
- `worker.help` : list all workeradded workers
- `worker.lhelp` : list all loaded workers

## plec - worker Library(lib.worker)

- `worker.add id position newid` : workeradd a loaded worker, only _id_ is obligatory
- `worker.rm p` : remove worker ate _p_ position
- `worker.help` : list all workeradded workers
- `worker.lhelp` : list all loaded workers

## plec - Syntax

- `@variable` : is replaced by the _variable_ value
- `!wl` : this set the current command to run on _wl_ workerlist
- `([command])` : run _command_ on plec layer
- `;` : separate commands, finish the command and start a new one
