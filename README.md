# Start

Dear user,

this ReadMe should prepare you to work with the DBVIS GPU Server.  
It is conceived as a guide to using every possibility of the server.

# Usage

There are two major options to use the server:
 - Jupyter Notebooks
 - Terminal Access

## Jupyter Notebooks

Jupyter Notebooks are built as a Python or R terminal emulation.
It enables easier access to build small programs faster and more efficient.
You can create a new one by pressing the New button and select a new Python or R kernel.
It is advised to use them as you can test your Python or R code more easily with them and if your development stage is over, you can export them as Python or R scripts.

## Terminal Access

Another option is the built-in terminal and editor of Jupyterhub.
You can open nearly every text file with the editor provided by Jupyterhub. This works like a typical desktop environment by either clicking on the file or by creating a new one.
Opening a terminal works with New button and then the terminal button.
Afterward, you can navigate to your script and run it with the command line.
Default the terminal is started with shell, but with `bash` you can change that.

# Advises

## Virtual Environment

The server is equipped with the many python frameworks and libraries. In case you need additional libraries you can create a virtual environment to add them and start Jupyter notebook via the new virtual environment. Use the following snippet to create a new virtual environment:

1. Open a terminal:  
  ```
  ## CREATE A NEW VIRTUAL ENVIRONMENT ##
  bash         # start a bash
  cd           # navigate to the home directory
  name='venv'  # specify the name of your virtual environment
  virtualenv --system-site-packages $name  # create the virtual environment + add all already installed packages
  source $name/bin/activate  # activate the virtual environment
  pip install --upgrade pip  # upgrade pip
  ipython kernel install --user --name=$name   # install in user space
  sed -i -e 's|/usr/bin/python3|'${HOME}'/'$name'/bin/python|g' $HOME'/.local/share/jupyter/kernels/'$name'/kernel.json' # replace python binary of the new kernel with the kernel of the new virtual environment
  ```
2. Via the following snippets you can add new packages to the virtual environment:  
  ```
  ## ADD PACKAGES TO A VIRTUAL ENVIRONMENT ##
  bash
  cd
  name='venv'
  source $name/bin/activate
  pip install <package>
  ```

3. Now you can create new Jupyter notebooks using the virtual environment from the *New* tab in the jupyter home directory.

## GPU Status

You can see the available GPUs as well as the available VRAM by typing `nvidia-smi` in a terminal.

## GPU Usage

Please make sure to just use **only one** GPU at the same time. After checking for an available GPU, you can specify the GPU inside your Jupyter notebooks using the following snippet:

```
import os
os.environ["CUDA_DEVICE_ORDER"]="PCI_BUS_ID"   # order GPUs by a steady ordering (like nvidia-smi)
os.environ["CUDA_VISIBLE_DEVICES"]="0"         # the ID of the GPU (view via nvidia-smi)
```

**After finishing using the GPUs, please explicitly stop your Juypter notebooks, since otherwise the VRAM occupied might not be freed.**

## Tensorflow

If you are using Tensorflow or a framework (Keras), which runs Tensorflow in the background, it is advised to use:
```
import tensorflow as tf
config = tf.ConfigProto()
config.gpu_options.allow_growth = True
session = tf.Session(config=config, ...)
```
or Keras explicitly
```
from keras import backend as K
config = K.tf.ConfigProto()
config.gpu_options.allow_growth = True
K.set_session(K.tf.Session(config=config))
```

To limit the amount of GPU memory Tensorflow uses.
Else Tensorflow will use all available GPU memory, which blocks other users and leads to your process being killed.


# Dont's

- Do not use more space than you need. 
This means if your data is too large, use the database server to store it. 
There are enough options to use Python and a database server efficiently.
- Do not block all of the available space of the different GPUs. 
Either block one GPU entirely or try to use the allow growth option of tensorflow.