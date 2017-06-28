# bblfsh-dev-image

Base Dockerfile and example setup script for creating a Babelfish dev and testing
image.

## Creating the image
`cd` into the repository dir and then do:
```bash
docker build -t bblfshdev .
```

## Running the image with a setup script

```bash
docker run -v $(pwd):/scripts --privileged -it --rm bblfshdev bash -l /scripts/run.server_issue34.sh
```

This would map the current directory inside the docker image as `/scripts` and run
the `run.sh` script (that obviously should be in the current directory). An
example script for a specific issue test has been provided. If you need to run or
test other stuff, change the run.sh script or add other scripts and run them
instead but remember that you must start the Docker service and `make build` the
drivers you need in that script, just like in the example provided, so the driver
docker images are created. This has to be done on the script provided to the
`docker run` command because [current versions of Docker doesn't allow to run 
privileged commands](https://github.com/moby/moby/issues/1916) so the building of Docker
images (the Python drivers) inside Docker has to be done on the run script.
