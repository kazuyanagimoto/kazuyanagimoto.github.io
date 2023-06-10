FROM rocker/rstudio

RUN apt update && apt install -y openssh-client \
    python3 python3-pip \
    # install Quarto
    curl gdebi-core \
    && curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb \
    && gdebi --non-interactive quarto-linux-amd64.deb

# Julia
ENV JULIA_MINOR_VERSION=1.9
ENV JULIA_PATCH_VERSION=0

RUN wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_MINOR_VERSION}/julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    tar xvf julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    rm julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    ln -s $(pwd)/julia-$JULIA_MINOR_VERSION.$JULIA_PATCH_VERSION/bin/julia /usr/bin/julia

# R Packages
RUN R -e "install.packages(c('renv', 'here', 'markdown'))"

# Rstudio Global Options
COPY --chown=rstudio:rstudio .config/rstudio/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json

# Python Application Path
ENV PATH $PATH:~/.pip/bin