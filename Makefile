run: clean build

clean:
	rm -f metrics

build: clean
	sudo singularity build metrics Singularity
