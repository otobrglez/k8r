.DEAFAULT_GOAL := build
.PHONY: clean

build:
	mkdir -p ./{steps,screens}	
	./kmeans.rb > data.dat && ./viz.sh

record: build
	./record.sh

clean:
	rm -rf ./{steps,screens} *.mp4 *.dat

data.dat:
	./kmeans.rb > data.dat

screens: data.dat
	./record.sh

