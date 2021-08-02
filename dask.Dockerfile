ARG CUDA_VER=11.2
ARG LINUX_VER=ubuntu18.04

FROM gpuci/miniconda-cuda:$CUDA_VER-devel-$LINUX_VER

ARG CUDA_VER=11.2
ARG PYTHON_VER=3.8
ARG RAPIDS_VER=21.08
ARG UCX_PY_VER=0.21


ADD https://raw.githubusercontent.com/dask/dask/main/continuous_integration/environment-$PYTHON_VER.yaml /dask_environment.yaml

RUN conda config --set ssl_verify false

RUN conda install -c gpuci gpuci-tools

RUN gpuci_conda_retry install -c conda-forge mamba

RUN gpuci_mamba_retry env create -n dask --file /dask_environment.yaml

RUN gpuci_mamba_retry install -y -n dask -c rapidsai -c rapidsai-nightly -c nvidia -c conda-forge \
    cudatoolkit=$CUDA_VER \
    cudf=$RAPIDS_VER \
    dask-cudf=$RAPIDS_VER \
    cupy \
    pynvml \
    "ucx-proc=*=gpu" \
    ucx-py=$UCX_PY_VER

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]