# Start

Hi User,

this ReadMe should prepare you to work with the DBVIS GPU Server.  
It is conceived as a guide to using every possibility of the server.

# Usage

There are two major options to use the server:
 - Jupyter Notebooks
 - Terminal Access

## Jupyter Notebooks

Jupyter Notebooks are built as a running Python or R terminal emulation.
It enables an easier access to build small programs faster and more efficient.
You can create a new one by pressing the New button and select a new Python or R kernel.
It is advised to use them as you can test your Python or R code more easily with them and if your development stage is over you can export them as Python or R scripts.

## Terminal Access

Another option is the built-in terminal and editor of Jupyterhub.
You can open nearly every text file with the editor provided by Jupyterhub. This works like a normal desktop environment by either clicking on the file or by creating a new one.
Opening a terminal works with New button and then the terminal button.
Afterward, you can navigate to your script and run it with the command line.

# Advises

## Tensorflow 2.0.0 alpha

If you are using Tensorflow or a framework, which runs Tensorflow in the background, it is advised to use:
```
import tensorflow as tf
from tensorflow.keras import backend as K

config = tf.compat.v1.ConfigProto()
config.gpu_options.allow_growth = True
K.set_session(tf.compat.v1.Session(config=config))
```
To limit the amount of GPU memory Tensorflow uses.
Else Tensorflow will use all available GPU memory, which blocks other users and leads to your process being killed.

## Tensorflow

If you are using Tensorflow or a framework, which runs Tensorflow in the background, it is advised to use:
```
import tensorflow as tf
config = tf.ConfigProto()
config.gpu_options.allow_growth = True
session = tf.Session(config=config, ...)
```
or
```
from keras import backend as K
config = K.tf.ConfigProto()
config.gpu_options.allow_growth = True
K.set_session(K.tf.Session(config=config))
```
To limit the amount of GPU memory Tensorflow uses.
Else Tensorflow will use all available GPU memory, which blocks other users and leads to your process being killed.


# Don'ts

- Do not use more space than you need. This means if your data is too large, use the database server to store it. There are enough options to use Python and a database server efficiently.
- Do not block all of the available space of the different GPUs. Either block one GPU completely or try to use the allow growth option of tensorflow.
