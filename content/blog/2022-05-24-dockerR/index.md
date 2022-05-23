---
title: "My Docker Template for R"
subtitle: "A portable research environment with Docker, VSCode, and DVC"
excerpt: "This template provides a Docker environment for research with R. Since it uses VSCode's Remote-Container extension, all you need to do is open it by VSCode."
date: 2022-05-24
author: Kazuharu Yanagimoto
draft: true
# layout options: single, single-sidebar
layout: single
categories:
- R
- Docker
---

Docker is one of the best environments for **reproductivity** of the research.
I use Docker for basically all my projects, but it took me about 2 years to get to a satisfactory environment setup. I would like to share it here as a template.

## Quick Start
1. Clone [this repository](https://github.com/nicetak/dockerR)
1. Open it in VSCode and add Remote-Containers Extension
1. From command pallete, choose "open folder in container"
1. Open `localhost:8787` in a browser
1. Create a project for this projet directory (by default, choose `/home/rstudio/work`)
1. RUN `renv::init()` in the R console
1. Set up a [DVC](https://dvc.org/) environment
    1. Prepare a folder in Google Drive (and copy the folder code)
    1. Init DVC
        ```{bash}
        dvc init
        dvc remote add --default myremote gdrive://GDRIVE_FOLDER_CODE
        ```


## Brief Explanations
In this section, I briefly comment on each files. I assume you are familiar with

- R, Rstudio & `renv`
- [Docker](https://www.docker.com/)
- [VSCode](https://code.visualstudio.com/) and its [Remote-Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension

I manage data files by [DVC](https://dvc.org/).
But if you have another strategy for the data management, ignore these parts.


### `Dockerfile`
```{bash}
FROM rocker/verse

RUN apt update && apt install -y gnupg openssh-client libpoppler-cpp-dev

# DVC
RUN wget \
       https://dvc.org/deb/dvc.list \
       -O /etc/apt/sources.list.d/dvc.list && \
    wget -qO - https://dvc.org/deb/iterative.asc | apt-key add - && \
    apt update && \
    apt install -y dvc 

# R Packages
RUN R -e "install.packages(c('languageserver', 'renv'))"

# Rstudio Global Options
COPY --chown=rstudio:rstudio .config/rstudio/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
```

#### R image
If you don't have any preferences, I recommend you to use one of the rocker image series
of [rocker-org](https://github.com/rocker-org/rocker):

- rocker/rstudio
- rocker/tidyverse
- rocker/verse
- rocker/geospatial

Because I currently write a paper by Rmarkdown,
I usually use `rocker/verse` and use `rocker/geospatial` for spatial analysis.

#### DVC
I have just follow the official guide for [Install from repository](https://dvc.org/doc/install/linux#from-repo-on-debian-ubuntu).
If your environment includes python, it is easier to install it via `pip`.

#### R packages
I use `renv` for dependency management.
`languageserver` allows us to run a code in VSCode, but I don't usually use it.

#### Rstudio Global Options
When Rstudio launches, it loads the `~/.config/rstudio/rstudio-prefs.json` file for general settings. So I prepare `/.config/rstudio/rstudio-prefs.json`,
and it allows me to use Rstudio with my favorites settings.

If you want to use your own settings, I recommend you

1. Open Rstudio 
1. Set up by GUI (Tools -> Global Options)
1. Copy `~/.config/rstudio/rstudio-prefs.json` (in container)
1. Paste it on `/.config/rstudio/rstudio-prefs.json` (in host)


### `docker-compose.yml`
```{json}
version: '3'
services:
    rstudio:
        build:
            context: .
        environment:
            - TZ=Europe/Madrid
            - DISABLE_AUTH=true
            - RENV_PATHS_CACHE=/home/rstudio/.renv/cache
        volumes:
            - .:/home/rstudio/work
            - $HOME/.renv:/home/rstudio/.renv/cache
```

#### DISABLE_AUTH=true
You don't need to type a password for each new session.

#### Cache for `renv`
By setting the `RENV_PATH_CACHE` and mount the directory,
you don't need to re-install packages.
In other words, you can share packages with other (docker) projects and
don't have to re-install all the packages when you rebuild a container.



Have fun!










