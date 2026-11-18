FROM quay.io/jupyter/base-notebook:python-3.12

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl wget unzip nano vim-tiny zip ca-certificates build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}
WORKDIR /home/jovyan

# Useful Python tooling for notebooks
RUN python -m pip install --no-cache-dir --upgrade pip && \
    python -m pip install --no-cache-dir \
      jupyterlab ipykernel pandas numpy matplotlib seaborn requests \
      beautifulsoup4 pillow scipy scikit-learn

COPY --chown=${NB_UID}:${NB_GID} jupyter_server_config.py /home/jovyan/.jupyter/jupyter_server_config.py
COPY --chown=${NB_UID}:${NB_GID} welcome.md /home/jovyan/work/README-EVILSAAD.md
COPY --chown=${NB_UID}:${NB_GID} start.sh /usr/local/bin/evilsaad-start

RUN chmod +x /usr/local/bin/evilsaad-start && \
    mkdir -p /home/jovyan/work && \
    printf '\n# EVILSAAD JUPYTER\nprintf "\\033[1;35mEVILSAAD JUPYTER\\033[0m\\nPython workspace ready.\\n"\n' >> /home/jovyan/.bashrc

EXPOSE 10000
ENTRYPOINT ["/usr/local/bin/evilsaad-start"]
