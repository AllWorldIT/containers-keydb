[![pipeline status](https://gitlab.conarx.tech/containers/keydb/badges/main/pipeline.svg)](https://gitlab.conarx.tech/containers/keydb/-/commits/main)

# Container Information

[Container Source](https://gitlab.conarx.tech/containers/keydb) - [GitHub Mirror](https://github.com/AllWorldIT/containers-keydb)

This is the Conarx Containers KeyDB image, it provides the KeyDB server.



# Mirrors

|  Provider  |  Repository                            |
|------------|----------------------------------------|
| DockerHub  | allworldit/keydb                      |
| Conarx     | registry.conarx.tech/containers/keydb |



# Conarx Containers

All our Docker images are part of our Conarx Containers product line. Images are generally based on Alpine Linux and track the
Alpine Linux major and minor version in the format of `vXX.YY`.

Images built from source track both the Alpine Linux major and minor versions in addition to the main software component being
built in the format of `vXX.YY-AA.BB`, where `AA.BB` is the main software component version.

Our images are built using our Flexible Docker Containers framework which includes the below features...

- Flexible container initialization and startup
- Integrated unit testing
- Advanced multi-service health checks
- Native IPv6 support for all containers
- Debugging options



# Community Support

Please use the project [Issue Tracker](https://gitlab.conarx.tech/containers/keydb/-/issues).



# Commercial Support

Commercial support for all our Docker images is available from [Conarx](https://conarx.tech).

We also provide consulting services to create and maintain Docker images to meet your exact needs.



# Environment Variables

Additional environment variables are available from...
* [Conarx Containers Alpine image](https://gitlab.conarx.tech/containers/alpine).


## KEYDB_PASSWORD (also supports: REDIS_PASSWORD)

Set a password for KeyDB. By default there is no password.



# Volumes


## /var/lib/keydb

KeyDB data directory.



# Exposed Ports

KeyDB port 6379 is exposed.



# Configuration

Configuration files of note can be found below...

| Path                    | Description              |
|-------------------------|--------------------------|
| /etc/keydb/keydb.conf   | Main KeyDB configuration |
| /etc/keydb/keydb/conf.d | Custom configuration     |
| /etc/keydb/users.acl    | KeyDB ACL configuration  |
