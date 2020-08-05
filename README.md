# Docker in Docker

A Docker in Docker image that can be used to start a Docker daemon.

## What is Docker?

> Docker is a set of platform as a service (PaaS) products that uses OS-level virtualization to deliver software in packages called containers.

*from* [wikipedia.org](https://en.wikipedia.org/wiki/Docker_%28software%29)

## Usage

### Start the Docker Daemon

Starting the docker daemon can be done with the following command:

```
docker container run --detach --publish 2375:2375/tcp --privileged tarbase/docker
```

The Docker option `--privileged` are required for the container to be able to
start.

### Docker Status

The Docker daemon status can be check by looking at the server output using
the following docker command:

```
docker container logs CONTAINER_ID
```

## Authors

See the list of [contributors](https://github.com/tarbase/docker/contributors)
who participated in this project.
