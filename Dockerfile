FROM tensorflow/tensorflow:latest-gpu-py3

LABEL maintainer="schlegel@dbvis.inf.uni-konstanz.de"

USER root

# Add README
COPY README.md /
COPY README.ipynb /

# Dependencies
RUN apt-get update && apt-get install -y \
		build-essential \
		wget \
		sudo \
		cmake \
		curl \
		g++ \
		gfortran \
		git \
		pkg-config \
		software-properties-common \
		python3-dev \
		r-base \
		libzmq3-dev \
		libcurl4-gnutls-dev \
		libssl-dev \
		graphviz \
		libgraphviz-dev \
		&& \
	apt-get clean && \
	apt-get autoremove && \
	rm -rf /var/lib/apt/lists/*

# Install IRKernel
RUN R -e "install.packages(c('crayon', 'pbdZMQ', 'devtools', 'IRdisplay'), repos='https://ftp.fau.de/cran/')"
RUN R -e "devtools::install_github(paste0('IRkernel/', c('repr', 'IRdisplay', 'IRkernel')))"

# Install KERAS + SCIKIT + Data Science Libs
RUN pip install -U \
		cython \
		scipy \
		numpy \
		keras \
		scikit-learn \
		psycopg2 \
		sqlalchemy \
		bokeh \
		matplotlib \
		pandas \
		nltk \
		pydot \
		seaborn \
		graphviz \
		xgboost \
		catboost \
		opencv-python \
                bash_kernel \
		tqdm \
                bert-serving-server \
                bert-serving-client

RUN pip install tslearn

# Install OpenCV + HDF5
RUN apt-get update && apt-get install -y \
		libboost-all-dev \
		libgflags-dev \
		libgoogle-glog-dev \
		libhdf5-serial-dev \
		libleveldb-dev \
		liblmdb-dev \
		libopencv-dev \
		libprotobuf-dev \
		libsnappy-dev \
		protobuf-compiler \
		libopenblas-dev \
		&& \
	apt-get clean && \
	apt-get autoremove && \
	rm -rf /var/lib/apt/lists/*

# Install PYTORCH
RUN pip install http://download.pytorch.org/whl/cu90/torch-0.4.0-cp35-cp35m-linux_x86_64.whl && \
    pip install torchvision

# Install networkX
RUN pip install networkx python-louvain

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

# Init jupyterhub and include r
RUN pip install -U jupyter jupyterhub && \
    R -e "IRkernel::installspec(user = FALSE)"

RUN python3 -m bash_kernel.install


# Add additional Jupyterhub extensions
RUN pip install jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --system && \
    jupyter nbextensions_configurator enable --system
RUN pip install nbzip && \
    jupyter serverextension enable --py nbzip --sys-prefix
RUN pip install jupyter-tensorboard && \
    jupyter tensorboard enable --system
RUN pip install rise && \
    jupyter-nbextension install rise --py --sys-prefix

# JH Settings and new pseudo user
# NB_GID to jupyterhubuser group id for Kubernetes node 
# ENV JUPYTERHUB_API_TOKEN=DBVIS
ENV JUPYTERHUB_API_TOKEN=DBVIS \
    NB_USER=dbvis \
    NB_GID=1010

RUN useradd -m $NB_USER
RUN groupmod -g $NB_GID $NB_USER

COPY singleuser.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/singleuser.sh

CMD ["singleuser.sh"]

# Install and enable nbextensions
RUN jupyter contrib nbextension install --user && \
    jupyter nbextensions_configurator enable --user && \
    jupyter tensorboard enable --user && \
    jupyter nbextension enable --py nbzip && \
    jupyter nbextension enable --py rise

USER $NB_USER

echo "alias virtualenv='virtualenv --system-site-packages'" >> ~/.bashrc

# Install and enable nbextensions
RUN jupyter contrib nbextension install --user && \
    jupyter nbextensions_configurator enable --user && \
    jupyter tensorboard enable --user && \
    jupyter nbextension enable --py nbzip && \
    jupyter nbextension enable --py rise

# Install anaconda

curl -O https://repo.anaconda.com/archive/Anaconda2-2019.03-Linux-x86_64.sh
bash Anaconda2-2019.03-Linux-x86_64.sh -b

conda install nb_conda
