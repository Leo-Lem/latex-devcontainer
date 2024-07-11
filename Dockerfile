FROM mcr.microsoft.com/devcontainers/base:debian AS assemble



# -------------------------
# Install required packages
# ------------------------------
RUN apt-get update -y &&\
    apt-get install -y --no-install-recommends ca-certificates perl wget perl-modules libfontconfig1 fontconfig sudo
RUN rm -rf /var/lib/apt/lists/*



# ---------------
# Install texlive
# ---------------
USER $USER
ARG SCHEME
ARG MIRROR="https://mirror.ctan.org/systems/texlive/tlnet/"
WORKDIR /tmp
RUN wget "${MIRROR}/install-tl-unx.tar.gz" && \
    tar -xzf install-tl-unx.tar.gz
RUN sudo perl install-tl-*/install-tl --no-interaction --scheme=$SCHEME --location $MIRROR &&\
    sudo chown -R vscode:vscode /usr/local/texlive
RUN sudo rm -rf /tmp/*

# add texlive to PATH
ARG YEAR="2024"
ARG ARCH="aarch64-linux"
ENV PATH="${PATH}:/usr/local/texlive/${YEAR}/bin/${ARCH}"



# -------------------------
# Install latex and latexmk
# -------------------------
RUN tlmgr install latex latex-bin latexmk



# --------------------
# Install latexindent
# --------------------
USER root
RUN cpan -i App::cpanminus
RUN cpanm YAML::Tiny File::HomeDir Unicode::GCString Log::Log4perl Log::Dispatch::File

USER $USER
RUN tlmgr install latexindent



# ------------------------------
# Install specified tex packages
# ------------------------------
ARG TEX_PACKAGES
RUN tlmgr install ${TEX_PACKAGES}



# ---------------------
# get ready
# ---------------------
USER $USER
CMD bin/bash