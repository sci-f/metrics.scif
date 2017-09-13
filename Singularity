BootStrap: docker
From: ubuntu:14.04

#
# singularity create container.ftw
# sudo singularity bootstrap container.ftw Singularity
#

%help

This is an example for a container that serves to make it easy to run
various metrics over an analysis of interest (the container's main runscript).
Each installed app can be thought of as a particular context to evoke the
container's main runscript.

# List all apps
singularity apps <container>

# Run a specific app
singularity run --app <app> <container>

# Loop over all apps
for app in $(singularity apps metrics.img); do
    singularity run --app $app metrics.img
done


%runscript
    echo "Hello World!"

%post
    locale-gen "en_US.UTF-8"
    apt-get update

%labels
CONTAINERSFTW_TEMPLATE scif-apps
CONTAINERSFTW_HOST containersftw
CONTAINERSFTW_NAME metrics-ftw
MAINTAINER Vanessasaur

%environment
# Global variables
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

%appinstall custom
    apt-get install -y lolcat fortune
%apprun custom
    /usr/games/fortune | /usr/games/lolcat
    apt-get moo

%appinstall strace
    apt-get install -y strace
%apprun strace
    unset SINGULARITY_APPNAME
    exec strace -c -t /.singularity.d/actions/run

%appinstall linter
    apt-get install -y shellcheck &&
    echo "#!/bin/sh" > lintme.sh &&
    echo "for f in $(ls *.m3u) do;" >> lintme.sh &&
    echo "grep -qi hq.*mp3 $f && echo -e 'Foo $f bar'; done" >> lintme.sh 

%apprun linter
    exec shellcheck ${SINGULARITY_APPBASE}/lintme.sh

%appinstall parallel
    apt-get install -y parallel
%apprun parallel
    unset SINGULARITY_APPNAME
    (/.singularity.d/actions/run; /.singularity.d/actions/run) | parallel


%appinstall time
    apt-get install -y time
%apprun time
    TIME="%C    %E    %K    %I    %M    %O    %P    %U    %W    %X    %e    %k    %p    %r    %s    %t    %w"
    unset SINGULARITY_APPNAME
    export TIME
    echo "COMMAND    ELAPSED_TIME_HMS    AVERAGE_MEM    FS_INPUTS    MAX_RES_SIZE_KB    FS_OUTPUTS    PERC_CPU_ALLOCATED    CPU_SECONDS_USED    W_TIMES_SWAPPED    SHARED_TEXT_KB    ELAPSED_TIME_SECONDS    NUMBER_SIGNALS_DELIVERED    AVG_UNSHARED_STACK_SIZE    SOCKET_MSG_RECEIVED    SOCKET_MSG_SENT    AVG_RESIDENT_SET_SIZE    CONTEXT_SWITCHES"
    exec /usr/bin/time /.singularity.d/actions/run
