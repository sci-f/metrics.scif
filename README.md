# Metrics FTW

This is an example for a container that serves to make it easy to run
various metrics over an analysis of interest (the container's main runscript).
Each installed app can be thought of as a particular context to evoke the
container's main runscript, and arguably the apps are relatively agnostic to
the runscript. Importantly, the main image function (runscript) is not impacted
by these supporting tools. Watch an example here:

[![asciicast](https://asciinema.org/a/137434.png)](https://asciinema.org/a/137434?speed=3)

or continue reading for step by step explanation.


## Building the image
Let's first build the container. You can use the Makefile to build the image:

```
make

# Does make clean followed by make build
```

or manually:

```
singularity create metrics.img
sudo singularity bootstrap metrics.img Singularity
```

## Running the Image

And now run it. This should perform the container's main function, calling it's runscript:

```
singularity run metrics.img 
Hello-World!
```

Works great! But then what if we wanted to know what tools (SCI-F apps) come with the
container? That's easy to do:

```
 singularity apps metrics.img 

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
each one with the equivalent command to the container. Importantly, since each
evaluation metric is a modular app, the container still serves its intended purposes. 
As an example, here is a simple app to return a table of system traces for the
runscript:

```
%apprun strace
    unset SINGULARITY_APPNAME
    exec strace -c -t /.singularity.d/actions/run
```

In the above example, since the main run command for the container looks for the
`SINGULARITY_APPNAME`, we need to unset it first. We then run strace and return
a table for the runscript:

```
 singularity run --app strace metrics.img 
Hello-World!
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
  0.00    0.000000           0        15           read
  0.00    0.000000           0         1           write
  0.00    0.000000           0        35        24 open
  0.00    0.000000           0        17           close
  0.00    0.000000           0        25        12 stat
  0.00    0.000000           0         4           fstat
  0.00    0.000000           0        14           mmap
  0.00    0.000000           0         8           mprotect
  0.00    0.000000           0         2           munmap
  0.00    0.000000           0         6           brk
  0.00    0.000000           0        14           rt_sigaction
  0.00    0.000000           0         6         6 access
  0.00    0.000000           0         2           getpid
  0.00    0.000000           0         2           execve
  0.00    0.000000           0        14           fcntl
  0.00    0.000000           0         2           getdents
  0.00    0.000000           0         3           geteuid
  0.00    0.000000           0         2           getppid
  0.00    0.000000           0         2           arch_prctl
  0.00    0.000000           0         1           openat
  0.00    0.000000           0         1           faccessat
------ ----------- ----------- --------- --------- ----------------
100.00    0.000000                   176        42 total

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
singularity run --app custom metrics.img
The difference between the right word and the almost right word is the
difference between lightning and the lightning bug.
		-- Mark Twain
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
A SCI-F app can obviously meet the needs to serve as a linter over a set of files,
or general tests. We advise the researcher to still use the `%test` section for
the analysis related tests, and SCI-F apps for general tests that are generalizable
to other containers. The example is provided here with the "linter"

```
singularity run --app linter metrics.img
```

And obviously, if the linter app accepted a command line argument to a file or
folder, it could lint content outside of the container. For this example, the 
broken script we were linting did terribly:'

```
singularity run --app linter metrics.img 

In /scif/apps/linter/lintme.sh line 2:
for f in  do;
^-- SC2034: f appears unused. Verify it or export it.
          ^-- SC1063: You need a line feed or semicolon before the 'do'.
            ^-- SC1059: No semicolons directly after 'do'.


In /scif/apps/linter/lintme.sh line 3:
grep -qi hq.*mp3  && echo -e 'Foo  bar'; done
         ^-- SC2062: Quote the grep pattern so the shell won't interpret it.
                          ^-- SC2039: #!/bin/sh was specified, but echo flags are not standard.

```

You could also imagine an entire container serving as a tester, or a converter,
or some kind of tool where it is natural for things to be packaged in modules
or sections.

## Use Case 4: Runtime Evaluation
In that a metric can call a runscript, it could be easy to evaluate running the
main analysis under various levels or conditions. As a simple proof of concept,
here we are creating an app to execute the same exact script in parallel.

```
%apprun parallel
    COMMAND="/.singularity.d/actions/run; "
    (printf "%0.s$COMMAND" {1..4}) | parallel

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
for app in $(singularity apps metrics.img)
   do
      singularity run --app $app metrics.img
done
```
