---
title: Templating things in Airflow DAG
description: Templating things in Airflow DAG
keywords: airflow, dag, tempalte, python, kubernetes
date: 2021-05-12
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
---

Just another, TIL type entry. It is about Airflow. I have been working with Airflow for quite a while. I don't really like it to be frank, but I am stuck with it for now.
With all that said, you can do everything that you want to do in Airflow. There is always some way to do everything. If you try really hard, you will be able to find even a way to capture Mewtwo. I am not saying this is something as important as that, but it took me a while to figure it out and I thought I should document it somewhere.

What I want to go over in this blog is ways in which we can get different variables into a dag which has KubernetesPodOperator.


# Method 1 - From airflow config

One easy place where we can pull a config from is the `airflow.cfg` file. This can be done with something like below:

``` python
from airflow.configuration import conf

with DAG(
    dag_id="my-little-pony", schedule_interval=None, start_date=YESTERDAY
) as dag:
    head = KubernetesPodOperator(
        image_pull_secrets=conf.get("kubernetes", "image_pull_secrets"),
        image_pull_policy="Always",
        name="build-head",
        cmds=["python"],
        arguments=["build-head"],
        ...
    )
```

If you see the example above, you can see how the `image_pull_secrets` value is fetched form the config. This works great if we just want to reuse things from the airflow config. I mainly use this for `image_pull_secrets` and `namespace` as they were same as the airflow webserver in my case.

# Method 2 - Airflow Variables

Next item is `Variables`. These are values that can be set from the Airflow UI. It is also possible to set them via env variables if we prefix the env var with `AIRFLOW_VAR_`. Relevant [Airflow documentation](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#variables).

In the UI, it is available under `Admin>Variables`. There you can create edit and delete and env var.

Once set, you can use an airflow variable like below:

``` python
with DAG(
    dag_id="my-little-pony", schedule_interval=None, start_date=YESTERDAY
) as dag:
    head = KubernetesPodOperator(
        ...
        cmds=["python"],
        image=Variable.get("pony_builder_image_name"),  # accessing variable
        ...
    )

```


# Method 3 - Templating and macros

Airflow actually uses Jinja templates for some stuff. It is kinda restricted, but it does provide some nice conveniences.

You can read more about it in the Airflow reference for [Jinja Templating](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#jinja-templating) and [macros](https://airflow.apache.org/docs/apache-airflow/stable/macros-ref.html).

I use this primary for values that are specific to the runtime of a airflow job. Things like `run_id` or `ds`(datetime stamp). You can also use this for two other things. You can use this to template out things from the `config` that gets passed in when you trigger a job from the UI or using the API. The config will be the json object and you can drill down any levels deep with just the `.`. You can also use this to template variables that I have mentioned earlier using `var`.

Here is a small example of where I use it.

```python
with DAG(
    dag_id="my-little-pony", schedule_interval=None, start_date=YESTERDAY
) as dag:
    head = KubernetesPodOperator(
        ...
        cmds=["python"],
        arguments=[
            "{% raw %}{{ run_id }}{% endraw %}",  # use of run_id
            "{% raw %}{{ dag_run.conf.name }}{% endraw %}",  # use of value from config
            "{% raw %}{{ dag_run.conf.head.type }}{% endraw %}",  # use of nested config value
        ],
        ...
    )
```

# Method 4 - From env variables

This is the main reason why I wanted to write this. This is mostly what I wanted to be able to do with my dag. The main reason why I got into this hunt in the first place is that I wanted to template the value of `runAsUser` etc from a kubernetes secret. I didn't ask for much man, but this lead to me to a relatively long hunt. Either my googling(ducking) skills are not so good or I was just not looking for the right thing. But anyways, I am here and I finally have solution.

This is what I wanted the code to end up looking like.

``` python
with DAG(
    dag_id="my-little-pony", schedule_interval=None, start_date=YESTERDAY
) as dag:
    head = KubernetesPodOperator(
        ...
        cmds=["python"],
        arguments=[
            "{% raw %}{{ run_id }}{% endraw %}",  # use of run_id
            "{% raw %}{{ dag_run.conf.name }}{% endraw %}",  # use of value from config
            "{% raw %}{{ dag_run.conf.head.type }}{% endraw %}",  # use of nested config value
        ],
        security_context={
            "runAsUser": int(os.environ["PONY_RUN_AS_USER"]),
            "runAsGroup": int(os.environ["PONY_RUN_AS_GROUP"]),
        },
        ...
    )
```

So, if you see, things are relatively simple. I just load the env var from `PONY_RUN_AS_USER` and just use it. I have to convert it to int, but other than that, I just want to load it.

Quick first logical step would be to modify the airflow deployment yaml file to include these things when creating the image. This is mostly taken out of the yaml file that I was using. If you see, I am pulling the secrets from `pony-secrets` secret in my kube cluster and setting them as env variables.

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: airflow
  namespace: pony-builder
spec:
  replicas: 1
  selector:
    matchLabels:
      name: airflow
  template:
    metadata:
      labels:
        name: airflow
    spec:
      serviceAccountName: airflow
      initContainers:
      - name: "init"
        image: pony-artifactory:latest
        imagePullPolicy: Always
        volumeMounts:
        - name: airflow-configmap
          mountPath: /root/airflow/airflow.cfg
          subPath: airflow.cfg
        env: &envvars
        - name: PONY_RUN_AS_USER
          valueFrom:
            secretKeyRef:
              name: pony-secrets
              key: run_as_user
        - name: PONY_RUN_AS_GROUP
          valueFrom:
            secretKeyRef:
              name: pony-secrets
              key: run_as_group
        command:
          - "bash"
        args:
          - "-cx"
          - "/root/airflow-test-env-init.sh"
      containers:
      - name: webserver
        image: pony-artifactory:latest
        imagePullPolicy: Always
        ports:
        - name: webserver
          containerPort: 80
        args: ["webserver"]
        envFrom:
        - secretRef:
            name: airflow
        env: *envvars
        volumeMounts:
        - name: airflow-configmap
          mountPath: /root/airflow/airflow.cfg
          subPath: airflow.cfg
      - name: scheduler
        image: pony-artifactory:latest
        imagePullPolicy: Always
        envFrom:
        - secretRef:
            name: airflow
        args: ["scheduler"]
        env: *envvars
        volumeMounts:
        - name: airflow-configmap
          mountPath: /root/airflow/airflow.cfg
          subPath: airflow.cfg
      volumes:
      - name: airflow-configmap
        configMap:
          name: airflow-configmap
```

But, the issue with this is that these variables will not be available in the worker pods. I am not mentioning the final pods that gets launched, but when you launch the dag that I mentioned earlier, Airflow launches another pod which is the one that manages the actual pod. This intermediately pod does not have access to these env variables. Not sure what kind of a decision that was. I don't know if I am missing some kind of a flag or something that would enable this, but this was not available by default.

The job of this intermediate pod is to just evaluate the dag and then create a proper pod. So, if I have to evaluate the pod, I need access to these variables. 

What happened here is that the `webserver` and the `scheduler` properly parsed the dags, but when this intermediate container that I mentioned tries to parse this dag config it fails saying that these env variables are not available.

What I ended up doing here is to add there to the `kubernetes_secrets` section in the configmap that gets mounted.

```properties
[kubernetes_secrets]
PONY_RUN_AS_USER = pony-secrets=run_as_user
PONY_RUN_AS_GROUP = pony-secrets=run_as_group
```

Now with this, I can actually get it in the intermediate pod. And we can actually get the dag running. All good, finally. We can now finally make ponies.

> Btw, this is how we make ponies. It was a well hidden secret, but now you know. It is all powered by Airflow and Kubernetes. The cuteness of  gopher should have tipped you off that something was going on.

# Bonus

There is only other option. This is actually pretty well documented. If you don't really need the secret values to be used in the dag, but just want to have pass them as env variables, we can just use `airflow.contrib.kubernetes.secret`. Here is a sample code:

``` python
from airflow.contrib.kubernetes import secret

pony_secrets = [
    secret.Secret(
        deploy_type="env",
        deploy_target="PONY_COLOR_MIX",
        secret="pony-secrets",
        key="color_mix",
    ),
    secret.Secret(
        deploy_type="env",
        deploy_target="PONY_TAIL_CURVE_RADIUS",
        secret="pony-secrets",
        key="tail_curve_radius",
    ),
]

with DAG(
    dag_id="my-little-pony", schedule_interval=None, start_date=YESTERDAY
) as dag:
    head = KubernetesPodOperator(
        ...
        cmds=["python"],
        arguments=["build-head"],
        secrets=pony_secrets,  # use of secrets
        ...
    )
```

With that, I have most of what I had in my TIL bucket. Hope that was useful to someone.
