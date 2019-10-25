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
RUN R -e "install.packages(c('crayon', 'pbdZMQ', 'devtools', 'IRdisplay'), repos='http://cran.us.r-project.org')"
RUN R -e "devtools::install_github(paste0('IRkernel/', c('repr', 'IRdisplay', 'IRkernel')))"

RUN pip install --upgrade pip

# Install virtualenv to let users install more libs
RUN pip install -U virtualenv

RUN pip install -U cython

# Install KERAS + SCIKIT + Data Science Libs
RUN pip install -U \
		scipy \
		numpy \
		keras \
		scikit-learn \
		psycopg2-binary \
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
		tqdm \
		tslearn \
        bert-serving-server \
        bert-serving-client \
        handout

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
RUN pip install torch===1.3.0 torchvision===0.4.1 -f https://download.pytorch.org/whl/torch_stable.html

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

# Init jupyterhub and include r
RUN pip install -U jupyter jupyterhub && \
    R -e "IRkernel::installspec(user = FALSE)"

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
ENV JUPYTERHUB_API_TOKEN=DBVIS \
    NB_USER=dbvis

RUN useradd -m $NB_USER

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

# add alias to include system site packages into virtualenvs
RUN echo "alias virtualenv='virtualenv --system-site-packages'" >> ~/.bashrc

# Install and enable nbextensions
RUN jupyter contrib nbextension install --user && \
    jupyter nbextensions_configurator enable --user && \
    jupyter tensorboard enable --user && \
    jupyter nbextension enable --py nbzip && \
    jupyter nbextension enable --py rise


# Install anaconda

## TODO fix this

#USER root

#RUN curl -O https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh
#RUN bash Anaconda3-2019.03-Linux-x86_64.sh -b -p "/home/$NB_USER/anaconda3"

#RUN chown -R $NB_USER:dbvis /home/$NB_USER/anaconda3

#USER $NB_USER

#RUN echo "export PATH=~/anaconda3/bin:$PATH" >> ~/.bashrc
#RUN /bin/bash -c "source ~/.bashrc"

#RUN export PATH=~/anaconda3/bin:$PATH

#RUN /bin/bash -c "conda install -c anaconda cython"
