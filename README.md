# Metrics Scientific Filesystem

This is an example for a container that serves to make it easy to run
various metrics over an analysis of interest (the container's main runscript).
Each installed app can be thought of as a particular context to evoke the
container's main runscript, and arguably the apps are relatively agnostic to
the runscript. Continue reading for step by step explanation.

## Building the image
Let's first build the container. You can use the Makefile to build the image:

```
make

# Does make clean followed by make build
```

or manually:

```
sudo singularity build metrics Singularity
```

## Running the Image

And now run it. This should perform the container's main function, calling it's runscript:

```
./metrics
Hello-World!
```

Works great! But then what if we wanted to know what tools (SCIF apps) come with the
container? That's easy to do:

```
./metrics apps

custom
linter
parallel
strace
time
```

Each of these is suited for a particular use case, discussed next.

## Use Case 1: Evaluate software across different metrics
A system admin or researcher concerned about evaluation of different software
could add relevant metrics apps to the software containers, and then easily evaluate
each one with the equivalent command to the container. As an example, here is a 
simple app to return a table of system traces for some main SCIF app, or a user
specific name runscript:

```
%apprun strace
    if [ $# -eq 0 ]
        then
        exec strace -c -t scif run main
    else
        exec strace -c -t scif run "$@"
    fi
```

The table returned shows the traces:

```
$ ./metrics run strace
[strace] executing /bin/bash /scif/apps/strace/scif/runscript
[main] executing /bin/bash /scif/apps/main/scif/runscript
Hello World!
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
100.00    0.000008           0        40           munmap
  0.00    0.000000           0       707           read
  0.00    0.000000           0         1           write
  0.00    0.000000           0       426        42 open
  0.00    0.000000           0       447           close
...
```

or a set of metrics from "time"

```
./metrics run time
[time] executing /bin/bash /scif/apps/time/scif/runscript
COMMAND    ELAPSED_TIME_HMS    AVERAGE_MEM    FS_INPUTS    MAX_RES_SIZE_KB    FS_OUTPUTS    PERC_CPU_ALLOCATED    CPU_SECONDS_USED    W_TIMES_SWAPPED    SHARED_TEXT_KB    ELAPSED_TIME_SECONDS    NUMBER_SIGNALS_DELIVERED    AVG_UNSHARED_STACK_SIZE    SOCKET_MSG_RECEIVED    SOCKET_MSG_SENT    AVG_RESIDENT_SET_SIZE    CONTEXT_SWITCHES
scif run main    0:00.22    0    74    28120    0    100%    0.21    0    0    0.22    0    0    0    0    0    29
```

The user can also specify a name of another app in the container to run a system trace
for it instead (truncated):

```
./metrics run strace custom
[strace] executing /bin/bash /scif/apps/strace/scif/runscript custom
[custom] executing /bin/bash /scif/apps/custom/scif/runscript
Beware of a dark-haired man with a loud tie.
                 (__) 
                 (oo) 
           /------\/ 
          / |    ||   
         *  /\---/\ 
            ~~   ~~   
..."Have you mooed today?"...
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 58.33    0.000014           4         4           wait4
 41.67    0.000010           0       426        42 open
  0.00    0.000000           0       710           read
  0.00    0.000000           0         1           write
  0.00    0.000000           0       447           close
...
```

Regardless of what your runscript does, this app will provide a consistent way 
to produce this metric. Who knew there were so many open and read calls to
just echo-ing a line to the console!


## Use Case 2: Custom Functions and Metrics
When a container is intended to only perform one function, this use case maps 
nicely to having a single runscript. As the number of possible functions increase,
however, the user is forced to either:

 - have a runscript that can take command line options to call different executables
 - use the `exec` command with some known path (to the user)

SCI-F apps allow for an easy way to define custom helper metrics or functions for
the container. For example, let's say I created some custom,
special metric. Or in this case, it's more of a container easter egg.

```
%apprun custom
    apt-get moo
```

and then the resulting output

```
./metrics run custom
"I wonder", he said to himself, "what's in a book while it's closed.  Oh, I
know it's full of letters printed on paper, but all the same, something must
be happening, because as soon as I open it, there's a whole story with people
I don't know yet and all kinds of adventures and battles."
		-- Bastian B. Bux
                 (__) 
                 (oo) 
           /------\/ 
          / |    ||   
         *  /\---/\ 
            ~~   ~~   
..."Have you mooed today?"...
```

This simple ability to create general, modular applications for containers means
that we can move toward the possibility that some researchers can specialize in
the development of the metrics, and others the analyses.

## Use Case 3: Code Quality and Linting
A SCIF app can be used for general tests that are generalizable
to other containers. The example is provided here with the "linter"

```
./metrics run linter <file>
```

The app can perform a linting of some default script provided by the container, or a user specified file.


```
$ ./metrics run linter
[linter] executing /bin/bash /scif/apps/linter/scif/runscript
No config file found, using default configuration
************* Module runscript
E:  1, 0: invalid syntax (<string>, line 1) (syntax-error)
\end{lstlisting}
```
```
$ ./metrics run linter script.py
```

## Use Case 4: Runtime Evaluation
In that a metric can call a runscript, it could be easy to evaluate running the
main analysis under various levels or conditions. As a simple proof of concept,
here we are creating an app to execute the same exact script in parallel.

```
%apprun parallel
    parallel /bin/bash ::: $SCIF_APPRUN_main $SCIF_APPRUN_main $SCIF_APPRUN_main

./metrics run parallel
[parallel] executing /bin/bash /scif/apps/parallel/scif/runscript
Hello World!
Hello World!
Hello World!
```

And you might imagine a similar loop to run an analysis, and modify a runtime
or system variable for each loop, and save the output (or print to console).

# Run them all!
And we don't need to know anything in advance (paths to hidden executables, how
paths or environment should be handled) to run all the container applications,
if we wanted to do that.  We can use a loop

```
for app in $(./metrics apps)
   do
      ./metrics run $app
done
```
