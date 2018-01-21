BootStrap: docker
From: continuumio/miniconda3

#
# sudo singularity build metrics Singularity
#

%help

This is an example for a container that serves to make it easy to run
various metrics over an analysis of interest (the container's main runscript).
Each installed app can be thought of as a particular context to evoke the
container's main runscript.

    # List all apps
    ./metrics apps

    # Run a specific app
    ./metrics run <app>

    # Execute primary runscript
    ./metrics

    # Loop over all apps
    for app in $(./metrics apps); do
        ./metrics run $app
    done


%runscript
    if [ $# -eq 0 ]
        then
        exec /opt/conda/bin/scif --quiet run main
    else
        exec /opt/conda/bin/scif "$@"
    fi

%files
    metrics.scif
    
%post
    apt-get update

    /opt/conda/bin/pip install scif
    /opt/conda/bin/scif install /metrics.scif


%environment
    DEBIAN_FRONTEND=noninteractive
    PURPLE="\033[95m"
    YELLOW="\033[93m"
    RED="\033[91m"
    DARKRED="\033[31m"
    CYAN="\033[36m"
    OFF="\033[0m"
    export PURPLE YELLOW RED DARKRED CYAN OFF DEBIAN_FRONTEND
