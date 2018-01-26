#!/bin/bash

if [ $# -eq 0 ]
    then
    exec /opt/conda/bin/scif --quiet run main
else
    exec /opt/conda/bin/scif "$@"
fi
