clean:
        rm -f metrics.img

build: clean
        singularity create metrics.img
        sudo singularity bootstrap metrics.img Singularity
