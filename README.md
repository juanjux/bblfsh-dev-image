# bblfsh-dev-image
Base Dockerfile and example setup script for creating a Babelfish dev and testing image.

## Creating the image
`cd` into the repository dir and then do:
```bash
docker build -t bblfshdev .
```

## Running the image with a setup script

```bash
docker run -v $(pwd):/scripts --privileged -it --rm bblfshdev bash /scripts/run.sh
```

This would map the current directory inside the docker image as `/scripts` and run the `run.sh` script (that obviously should be
in the current directory). An example script for a specific issue test has been provided. If you need to run or test other stuff,
change the run.sh script or add other scripts and run them instead but remember that you must start the Docker service and `make build` 
the drivers you need in that script, just like in the example provided.
