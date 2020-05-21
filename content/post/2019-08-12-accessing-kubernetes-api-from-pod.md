---
comments: true
date: "2019-08-12T00:00:00Z"
description: How to create Jobs, etc from a Pod inside Kubernetes
keywords: kubernets, job, kuerbentes api, pod, rbac
title: Accessing Kubernetes API from a Pod (RBAC)
---

This article describes in general how to set up permission for a Pod so that it will have access to Kubernetes API.

My exact use case was that, I wanted to run a Pod which will watch a redis queue and then start a job whenever there is
a new item in the queue. I will only be explaining how to set up the permissions and I think the rest of the tasks has
been well explained by a lot of people.

![gif](/images/job.gif)

So, I have a simple python file that I would like to run to create a `Job` and then delete it later.
It will look something like this:

```python
from kubernetes import client, config

JOB_NAME = "pi"


def create_job_object():
    # Configureate Pod template container
    container = client.V1Container(
        name="pi",
        image="perl",
        command=["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"])
    # Create and configurate a spec section
    template = client.V1PodTemplateSpec(
        metadata=client.V1ObjectMeta(labels={"app": "pi"}),
        spec=client.V1PodSpec(restart_policy="Never", containers=[container]))
    # Create the specification of deployment
    spec = client.V1JobSpec(
        template=template,
        backoff_limit=4)
    # Instantiate the job object
    job = client.V1Job(
        api_version="batch/v1",
        kind="Job",
        metadata=client.V1ObjectMeta(name=JOB_NAME),
        spec=spec)

    return job


def create_job(api_instance, job):
    # Create job
    api_response = api_instance.create_namespaced_job(
        body=job,
        namespace="default")
    print("Job created. status='%s'" % str(api_response.status))


def update_job(api_instance, job):
    # Update container image
    job.spec.template.spec.containers[0].image = "perl"
    # Update the job
    api_response = api_instance.patch_namespaced_job(
        name=JOB_NAME,
        namespace="default",
        body=job)
    print("Job updated. status='%s'" % str(api_response.status))


def delete_job(api_instance):
    # Delete job
    api_response = api_instance.delete_namespaced_job(
        name=JOB_NAME,
        namespace="default",
        body=client.V1DeleteOptions(
            propagation_policy='Foreground',
            grace_period_seconds=5))
    print("Job deleted. status='%s'" % str(api_response.status))


def main():
    # Configs can be set in Configuration class directly or using helper
    # utility. If no argument provided, the config will be loaded from
    # default location.

    # config.load_kube_config()
    config.load_incluster_config()
    batch_v1 = client.BatchV1Api()

    # Create a job object with client-python API. The job we
    job = create_job_object()

    create_job(batch_v1, job)
    jobs = batch_v1.list_namespaced_job('default')
    jobs.items[0].status

    update_job(batch_v1, job)

    delete_job(batch_v1)


if __name__ == '__main__':
    main()
```

Here is the gist of the architecture.
We have a `Pod` running in the `default` namespace. 
We will be creating and later deleting a `Job` from within this namespace.


So, what we will have to do is to allow the `Pod` access to the Kubernetes API so that it can do the various tasks.
If you were to run without giving the needed permissions you will end up getting a error message like: 

```
kubernetes.client.rest.ApiException: (403)
Reason: Forbidden
HTTP response headers: HTTPHeaderDict({'Audit-Id': 'e518f584-364d-40b7-a6d1-d4528062298d', 'Content-Type': 'application/json', 'X-Content-Type-Options': 'nosniff', 'Date': 'Mon, 12 Aug 2019 08:11:29 GMT', 'Content-Length': '313'})
HTTP response body: {"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"jobs.batch is forbidden: User \"system:serviceaccount:default:job-robot\" cannot create resource \"jobs\" in API group \"batch\" in the namespace \"default\"","reason":"Forbidden","details":{"group":"batch","kind":"jobs"},"code":403}
```

## Architecture

- Create a new `ServiceAccount` object.
  We will later create a`Pod` which we assign to this `ServiceAccount`

- Create a new `Role`. A `Role` is instructions on what a `ServiceAccount` will have access to.
  It will not say which `ServiceAccount` will have access.

- We can say that specific `ServiceAccount` will have the `Role` rules by using a `RoleBinding`.

- Now you create a `Pod` which will be assigned to the created `ServiceAccount`.


> The difference between `Role{,Binding}` and `ClusterRole{,Binding}` is that in the latter, you apply it for all
> namespaces.


## Code

Below is some sample yaml file that you could use for reference.

#### ServiceAccount

This can be technically considered like a group(don't confuse with the `Group` concept), and `things` belonging to this group can be assigned specific rules.
Here we create a `ServiceAccount` with the name `job-robot`.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: job-robot
```

#### Role

Here we create a `Role` with the name `job-robot` (does not have to the same as the service-account).
We let the `Role` to have access to get,list and watch pods.
Also to get,list,watch,create,update,patch and delete jobs

We will later assign this to the `ServiceAccount`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: job-robot
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch", "extensions"]
  resources: ["jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

#### RoleBinding

Now we have to bind the `Role` to that `ServiceAccount`.
Here we create a `RoleBinding` with the name `job-robot` (again, does not have to be the same).
Doing this will bind your `Role` to the `ServiceAccount`.

You define you `Role` in the `roleRef` section and your `ServiceAccount` in the `subjects` section.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: job-robot
  namespace: default
subjects:
- kind: ServiceAccount
  name: job-robot # Name of the ServiceAccount
  namespace: default
roleRef:
  kind: Role # This must be Role or ClusterRole
  name: job-robot # This must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```

#### Deployment/Pod

Well, the final step is to put your deployment on to your cluster.
There is one thing that you will have to do.

In your `Pod` spec, you will have have to add an extra key `serviceAccountName` with the name of the `ServiceAccount` you
created.

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
    name: ubu
spec:
    selector:
        matchLabels:
            app: ubu
    replicas: 1
    template:
        metadata:
            labels:
                app: ubu
        spec:
            containers: 
            - name: ubu
              image: "<image-name>"
            serviceAccountName: job-robot  # Name of the ServiceAccount, duh.
```

And with that, you can not create a `Job` from within a `Pod` in your cluster.
