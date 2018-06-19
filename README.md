# gatekeeper-phila

This repository contains Gatekeeper with Philadelphia customizations applied, refactored for build and runtime automation with [habitat](https://www.habitat.sh/).

Eventually it will be split up further such that the Gatekeeper base and Philadelphia customizations are kept separate and combined during a build process. Currently the `/site/` tree is extracted already-composited from a legacy site instance with the [`emergence-source-http-legacy pull`](http://forum.emr.ge/t/pull-any-site-into-a-git-repo/111) command.

## Table of Contents

- [gatekeeper-phila](#gatekeeper-phila)
- [Table of Contents](#table-of-contents)
- [Quick Start](#quick-start)
- [Running via Docker](#running-via-docker)
  - [Helpful Docker Commands](#helpful-docker-commands)
- [Housekeeping](#housekeeping): Temporary scratch area, to be erased for first release
  - [TODO](#todo)
  - [Journal](#journal)

## Quick Start

1. **Install Docker**

    On Mac and Windows workstations, Docker must be installed to use habitat. On Linux, Docker is optional.

    - [Download *Docker for Mac*](https://store.docker.com/editions/community/docker-ce-desktop-mac)
    - [Download *Docker for Windows*](https://store.docker.com/editions/community/docker-ce-desktop-windows)

1. **Install habitat on your system**

    Habitat is a tool for automating all the build and runtime workflows for applications, in a way that behaves consistently across time and environments. An application automated with habitat can be run on any operating system, connected to other applications running locally or remotely, and deployed to either a container, virtual machine, or bare-metal system.

    Installing habitat only adds one binary to your system, `hab`, and initializes the `/hab` tree.

    This command must be run once per workstation:

    ```bash
    curl -s https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
    hab --version # should report 0.56.0
    ```

1. **Configure the `hab` client for your user**

    Setting up habitat will interactively ask questions to initialize `~/.hab`.

    This command must be run once per user that will use `hab`:

    ```bash
    hab setup
    ```

    *Entering a __default origin__ will generate a build key and determine what vendor name all the packages you build will be prefixed with. It should correspond to the organization you would publish internally or externally as. __This is recommended__.*

    *Authenticating with GitHub is only necessary for publishing builds to the public artifact depot, [bldr.habitat.sh](https://bldr.habitat.sh/). You can skip this for now and re-run `hab setup` later.*

1. **Clone this repository and change into it**

    ```bash
    git clone \
       --recursive \
       -b phila-develop \
       git@github.com:JarvusInnovations/Gatekeeper.git \
       ./gatekeeper-phila

    cd ./gatekeeper-phila
    ```

1. **Enter studio**

    A  studio is disposable environment generated by habitat for building and testing applications. Studios are associated with the working directory they are launched from, and in some cases are resumable by launching again from the same working directory.

    Studios are transparently created and disposed of during `hab pkg build`, but an *interactive* studio can also be *entered* to get a shell for quickly repeating builds, debugging builds, and testing applications in an isolated environment:

    ```bash
    HAB_DOCKER_OPTS="-p 7080:7080" hab studio enter
    ```

    On Mac and Windows workstations, studios are always launched within a Docker container and are destroyed upon exit. On Linux, a lighter-weight `chroot` jail is used instead by default and can be resumed after exit. Use of a Docker container can be forced on Linux by running `hab studio -D enter` instead.

    The `HAB_DOCKER_OPTS` environment variable can supply arbitrary configuration for the studio's Docker container. In the command above port `7080` is forwarded from the container to the workstation. This is variable ignored for Linux `chroot` studios, where all listening ports are exposed on the workstation directly.

1. **Review available studio commands**

    After habitat finishes generating the studio, the [`.studiorc`](./.studiorc) script provided in the root of this repository is detected and executed to provide project-specific initialization of the interactive shell.

    By convention, this script will install packages and define commands that are useful to working on the project, printing documentation along the way. Look for this documentation just above your shell prompt once it finally appears.

1. **Build `gatekeeper-app` package**

    This shortcut is defined by [`.studiorc`](./.studiorc):

    ```bash
    build-app
    ```

1. **Launch all services**

    This shortcut is defined by [`.studiorc`](./.studiorc), it starts `${HAB_ORIGIN}/gatekeeper-app`, `emergence/nginx`, and `core/mysql` as services with needed bindings between them:

    ```bash
    start-all-local
    ```

    Any problems? Use `hab sup status` and `sup-log` to investigate.

1. **Use the application**

    You should now be able to open http://localhost:7080/ on your workstation and use the application.

    Create a user account for yourself using the online register form. Then run `shell-mysql-local` to enter an interactive MySQL shell and run this SQL statement to upgrade the access level for all registered users:

    ```sql
    UPDATE gatekeeper.people SET AccountLevel = "Developer";
    ```

1. **Exit studio**

    When you're finished using a studio, just exit the shell. Docker-powered studios will be erased automatically by default.

    ```bash
    exit
    ```

    Linux `chroot` studios will remain on disk by default until this command is run from the same directory it was launched in:

    ```bash
    hab studio rm
    ```

## Running via Docker

1. Launch studio:

    ```bash
    hab studio enter
    ```

1. Build app service and export docker container

    ```bash
    build-app
    hab pkg export docker $(ls -1t /src/results/${HAB_ORIGIN}-gatekeeper-app-*.hart | head -n 1)
    ```

    Due to [issue habitat#5218](https://github.com/habitat-sh/habitat/issues/5218), we must provide the path to the newest `.hart` build artifact instead of just a package identifier.

1. Export http service docker container

    ```bash
    hab pkg export docker emergence/nginx
    ```

1. Export docker container for mysql

    - Local mysql:

      ```bash
      hab pkg export docker core/mysql
      ```

    - Remote mysql:

      ```bash
      hab pkg export docker jarvus/mysql-remote
      ```

1. Exit studio

    ```bash
    exit
    ```

1. Launch containers with docker-compose

    - Local mysql:

      ```bash
      docker-compose -f docker-compose.mysql-local.yml up
      ```

    - Remote mysql:

      ```bash
      docker-compose -f docker-compose.mysql-remote.yml up
      ```

### Helpful Docker Commands

- Launch interactive bash shell for any service container defined in `docker-compose.*.yml`:

    ```bash
    SERVICE_NAME=app # db/app/http
    MYSQL_MODE=local # local/remote

    docker-compose \
      -f docker-compose.mysql-${MYSQL_MODE}.yml \
      exec ${SERVICE_NAME} \
        hab sup bash
    ```

- Access interactive mysql shell:

  - Local mysql:

    ```bash
    docker-compose \
      -f docker-compose.mysql-local.yml \
      exec db \
        mysql \
          --defaults-extra-file=/hab/svc/mysql/config/client.cnf \
          gatekeeper
      ```

  - Remote mysql:

    ```bash
    docker-compose \
      -f docker-compose.mysql-remote.yml \
      exec db \
        hab pkg exec core/mysql-client mysql \
          --defaults-extra-file=/hab/svc/mysql-remote/config/client.cnf \
          gatekeeper
    ```

- Promote access level for registered user:

  - Local mysql:

    ```bash
    docker-compose \
      -f docker-compose.mysql-local.yml \
      exec db \
        mysql \
          --defaults-extra-file=/hab/svc/mysql/config/client.cnf \
          gatekeeper \
          -e 'UPDATE people SET AccountLevel = "Developer" WHERE Username = "chris"'
    ```

  - Remote mysql:

    ```bash
    docker-compose \
      -f docker-compose.mysql-remote.yml \
      exec db \
        hab pkg exec core/mysql-client mysql \
          --defaults-extra-file=/hab/svc/mysql-remote/config/client.cnf \
          gatekeeper \
          -e 'UPDATE people
                 SET AccountLevel = "Developer"
               WHERE Username = "chris"
             '
    ```

## Housekeeping

### TODO

- [X] Create services/http
  - [X] Provide guide/command to run in studio
- [X] Rename services/php5 to services/app
  - [X] Use emergence/php5 as runtime dep instead of duplicating build plan
- [X] Generate web.php with config
- [ ] Get app working with minimal php-bootstrap changes
- [X] Create composite service
  - [X] Explore binding app and http services
- [X] Create composer package for core lib
  - [ ] Include PSR logger interface
  - [X] Include whoops
  - [X] Include VarDumper
- [X] Clear ext frameworks from build
- [X] Update README for 0.56.0 supervisor and emergence/nginx
- [X] Add "quick start" to readme
- [ ] Test and restore composite with local and remote mysql bind
- [ ] Document habitat concepts:
  - [X] studio
  - [X] .studiorc
  - [ ] services
  - [ ] supervisors
  - [ ] bindings
  - [ ] relationship to docker
- [ ] Add postfix service
- [ ] Add fcgi health check for status url if available
- [ ] Add cron job for app heartbeat event

### Journal

- Create http plan
  - Use existing plan as runtime dep
  - Copy configs from existing plan during build and skip build/install
  - Set paths in templated conf
  - nginx dieing with `open() "/dev/stdout" failed (13: Permission denied)`
    - add config for log paths
  - Test process
    - Build custom nginx
    - Install custom nginx in app studio
    - Build app http plan
    - Stop/start service
    - -- config-from useful when testing just changes to app nginx config, but build needed to update nginx version after install
  - set port at `/hab/user/gatekeeper-http/config/user.toml`
- Create app plan
  - Use existing plan as runtime dep
- Connect with binding
- Create composite plan
  - Add binding
- Create mysql plan
- Write `/hab/user` via `.studiorc`
- Configure composer and psysh for studio
- Create package for libfcgi and use with ping for FPM application health_check
- Try to build docker image for composite
  - Not supported yet
  - Export docker images for http and app
  - `php-fpm: error while loading shared libraries: libreadline.so.6: cannot open shared object file: No such file or directory`
    - fix by moving readline dep from build to runtime
