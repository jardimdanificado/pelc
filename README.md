## plec - Command-line Commands

- `plec` : Starts the plec
- `plec -gl43` : Sets openGL version to specified version, in this example 4.3. Avaliable: 11, 21, 33, 43 and es2 (default is OpenGL1.1)

## plec - Session Temp values

- `session.temp.exit` : responsible for exiting repl or keep in loop
- `session.temp.keep` : prevent the session.temp begin cleared, auto-disable
- `session.temp.break`: cancel current list processing
- `session.temp.skip` : prevent next command from running

## plec - Session Data values

- `session.data.preload` : prevent the preload from automaticaly run
- `session.data.setup` : prevent the setup from automaticaly run

## plec - Core Library commands(lib.core)

- `run scriptname` : run the _filename_ script
- `set name anything` : set a variable inside plec's session, you can also use this to set references
- `def lua-code-here` : create a command from inside plec
- `undef cmd-name` : delete a cmd from data
- `> lua-code` : solve a lua code

## plec - Core Library pipes(lib.core)

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

## plec - compiler Library(compile)

- `compile luajitpath Ccompiler -V -Cgcc -I/include/folder/ -L/library/folder` : compile command, it runs automaticaly if you do not disable setup, -V activate vitrine
- `session.data.compile.vitrine` : demonstration mode, this copy the examples in the compilation
- `session.data.compile.ccompiler` : allow you to set a C compiler
- `session.data.compile.lib` : allow you to set a the lib path to your libraries
- `session.data.compile.include` : allow you to set a the include path to your headers

## plec - raylib Library pipes(lib.raylib)

- `startdraw`: Begins drawing the frame. Call this before any drawing operation.
- `start3d`: Begins 3D mode with the camera associated with the current scene.
- `clearbg`: Clears the background with the color defined in the current scene.
- `end3d`: Ends 3D mode and returns to 2D mode.
- `drawtxt`: Draws all the texts defined in the current scene using the properties specified for each text.
- `drawcube`: Draws all the cubes defined in the current scene using the properties specified for each cube.
- `enddraw`: Ends drawing and swaps buffers, displaying the rendered frame on the screen.

## plec - Syntax

- `@variable` : is replaced by the _variable_ value
- `wl!wl2!wl3` : this set the current command to run on _wl_ _wl2_ _wl3_ pipelines
- `([command])` : run _command_ on plec layer
- `;` : separate commands, finish the command and start a new one

## NOTES

- because of the full rework done in plec0.6.0 this README is W.I.P. for undetermined time, stay tuned for new updates.
- remember that plec will ALWAYS start from its folder, no matter what you do, no matter where you are it will always start in the plec executable folder