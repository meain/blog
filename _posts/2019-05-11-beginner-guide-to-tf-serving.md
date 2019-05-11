---
layout: post
title: "Beginners guide to tensorflow serving"
description: "Deploying a simple tensorflow or keras model using tf-serving"
comments: true
keywords: "tensorflow, keras, tf-serving, serving, deployment"
---

`tf-serving` if you don't know is a tool that Google has built to serve model built using `tensorflow`.
Even `keras` models with a `tensorflow` backend should do just fine.

Even thought there are a lot of guides on how to use `tf-serving`, I could not find anything coherent and simple.
So I decided to write one, mostly so that next time I have to do this I would have something to refer to.


## Why `tf-serving`

You could just put your model behind a simple flask API and that will work pretty fine for small use cases.

`tf-serving` mostly comes in handy you have heavy load. It is also pretty useful when you have to version you models and
have something like a CI - CD pipeline. This [video](https://www.youtube.com/watch?v=q_IkJcPyNl0) explains it pretty well.

## How `tf-serving`

OK, now let us get to the part why you might be reading this blog for.
We will be using the `tensorflow/serving` docker container to run the whole thing. This makes things a whole lot
simpler. Also later when you have to put the whole thing behind `kubernetes` acting like a load balancer you will end
up using it anyway.

### Folder structure

`tf-serving` needs the model files to be in a specific structure. It should look something like this.

```
models                                             # base folder for all the models
└── mymodel                                        # model name
    └── 1                                          # model version
        ├── saved_model.pb
        └── variables
            ├── variables.data-00000-of-00001
            └── variables.index
```

We will have a base folder called `models` (you could name it anything, but we will have to pass on the same name to
`tf-serving`).

Inside the base folder we will have different models. The name of the model that I am using here is `mymodel`, so we
have that as the folder name here.

Inside that we will have folders with names `1`, `2`, `3` ... etc. These will be different version. It is set up like
this so that when you have a new version, you can just add a new folder and `tf-serving` will automatically switch to
the new model without restarting. Plus you get some form of versioning.

### What goes inside them

OK, now that we know where to put the files, let us see what to put in there.

`tf-serving` will need the files to be in a format what it calls `SavedModel`.
You can find more about it [here](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/python/saved_model/README.md).

We have utils inside of `tensorflow` which will let us convert our models into SavedModel.
Here I will show how to do it for a keras model.

```python
signature = tf.saved_model.signature_def_utils.predict_signature_def(
    inputs={"image": model.input}, outputs={"scores": model.output}
)

builder = tf.saved_model.builder.SavedModelBuilder("./models/mymodel/1")
builder.add_meta_graph_and_variables(
    sess=keras.backend.get_session(),
    tags=[tf.saved_model.tag_constants.SERVING],
    signature_def_map={
        tf.saved_model.signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY: signature
    },
)
builder.save()
```

You could add the code right at the end of something like below and
you should have a model in the path `./models/mymodel/1` with the above specified dir structure.

```python
import tensorflow as tf
from tensorflow import keras
import numpy as np

fashion_mnist = keras.datasets.fashion_mnist
(train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

train_images = train_images / 255.0
test_images = test_images / 255.0

model = keras.Sequential(
    [
        keras.layers.Flatten(input_shape=(28, 28)),
        keras.layers.Dense(128, activation=tf.nn.relu),
        keras.layers.Dense(10, activation=tf.nn.softmax),
    ]
)

model.compile(
    optimizer="adam", loss="sparse_categorical_crossentropy", metrics=["accuracy"]
)

model.fit(train_images, train_labels, epochs=5)
test_loss, test_acc = model.evaluate(test_images, test_labels)

predictions = model.predict(test_images)
res = np.argmax(predictions[0])
print("res:", res)
```

### Running using `docker`

Well, i assume you know what docker is. Well if you don't let us think of it as a super lightweight VM (I couldn't be more
wrong when I say lightweight VM, but it is a good analogy). Just install docker from [here](https://www.docker.com/).

> Btw, if you don't know docker, look into it. It is pretty awesome.

Now you can run something like this.

```sh
docker run -t --rm -p 8501:8501 \
   -v "$(pwd)/models:/models" \
   -e MODEL_NAME=mymodel \
   tensorflow/serving
```

OK, what we do here is we use the image `tensorflow/serving` from [Docker Hub](https://hub.docker.com/).
It is a preconfigured `tensorflow` serving setup.

The `-p` option says that we map the `8501` port of docker to `8501` port in our local. This is the default `REST` port
in `tf-serving`. For `gRPC` it is `8500`.

With `-v` we mount `$(pwd)/models` to `/models` inside the container as that is where `tf-serving` will look for the
files.

Also we specify the `MODEL_NAME` as `mymodel` so that `tf-serving` will run that model.

### Simple client

```python
import json
import requests
import numpy as np
from tensorflow import keras

fashion_mnist = keras.datasets.fashion_mnist
(train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()
test_images = test_images / 255.0

url = 'http://localhost:8501/v1/models/mymodel:predict'
headers = {"content-type": "application/json"}
data = json.dumps({"instances": test_images.tolist()})

resp = requests.post(url, data=data, headers=headers)
if resp.status_code == 200:
    predictions = resp.json()['predictions']
    res = np.argmax(predictions[0])
    print("res:", res)
```


Not a whole lot of changes from simple prediction.
We pretty much replace the line

```python
predictions = model.predict(test_images)
```

with the lines

```python
resp = requests.post(url, data=data, headers=headers)
predictions = resp.json()['predictions']
```

Well, that is pretty much it for running `tf-serving`.
Now put load balancing on top of it and you got a pretty solid production deployment.
