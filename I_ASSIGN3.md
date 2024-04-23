# Individual Activity 3 - Kubernetes

In this activity, you'll replicate Individual Activity 2, but using Kubernetes. You  will also learn how to dynamically scale the service up and down.

Before you begin, read through the [Kubernetes shallow-dive](KUBERNETES.md) to understand the absolute basics of Kubernetes and how to deploy YAML-based configurations into your cluster.

## Instructions

1. Make a directory for your assignment.

1. Grab the two files in the directory [I_ASSIGN3](i_assign3/) and put them in that folder. Make sure you download them as raw files, not as GitHub "HTML" pages.

    > **Hint:** You can either copy and paste the contents of the two files manually, you can open each file on the GitHub website and use the Download icon to download it, or you can clone the repository and grab the files that way.

1. In your WSL environment, build the container image using `docker build`. Give the container a memorable name - for example `docker build -t i-like-the-cs-program .`.

    The container image is the same one we used in class to demonstrate how to use an environment variable to change the contents of the web page that is displayed. 

1. Test the container. Run this:

        docker run -it --rm -e HOSTNAME=<something> -p 8080:80 <whatever-you-named-the-container-image>

    and open your browser to `localhost:8080`. Make sure the name you gave in the `-e` option appears.

    Exit the container with `Ctrl+C`.

1. Upload the container image you built into your Kubernetes cluster:

        minikube image load <whatever-you-named-your-container-image>

    > This is a `minikube` command, meaning it doesn't work on "live" Kubernetes clusters, like the one you'll be using in the group assignment. More details on how to load images into a live cluster will be explained in that assignment.

1. Now, using the YAML template given in the [Kubernetes shallow-dive](KUBERNETES.md), deploy and provide a service for your container with three replicas. 
  
    > **Hint:** The example YAML already is set for three replicas. The only thing you should need to change is the `image` option under the deployment section - set it to the name of your container image.

2. In the YAML section that introduces the deployment, look at the `spec` section. Note the dictionary that identifies the `name` of the container and the `image` (you should have changed that field earlier). Add another key at the same level that contains the following:

        imagePullPolicy: Never
        env:
        - name: HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name

    You can probably tell from looking at this code that what this will do is introduce an environment variable into the container, and the value for that variable will be pulled from `metadata.name`. The field `metadata.name` is the name of the *pod* - if you've tried `kubectl get pod` with a deployment running, you'll notice the pod is named something like `welcome-deploy-7bd878855d-jwh9b`.

    The `imagePullPolicy` directive tells Kubernetes not to try to update the image before running. Since your image is not actually live on Docker Hub, pulling will fail, and Kubernetes will refuse to start the container since, in its mind, it can't verify that the container image is up to date. Specifying this option tells Kubernetes to stop caring about this and just run whatever image is available.

1. Bring up your deployment with `kubectl apply -f`. 

1. Instead of running `minikube tunnel`, this time let's try another approach: run `minikube service <your-service-name>` (the service name is whatever you have set in the YAML for the service under `metadata` -> `name`.) This is similar to `tunnel` but it will assign a random port so you don't have to worry about needing admin rights or conflicting services on ports.

1. Finally, access the given URL in your browser and note the hostname in the header!

At this point you're probably thinking you can do force-refresh and see the hostname change. However, Kubernetes works a bit differently! The load balancer in Kubernetes doesn't simply throw requests at the pods in random or round-robin order. Instead, it tracks IP addresses accessing the service and directs different *IP addresses* to different pods.

Since you're only going to be connecting from one IP, what you can do to see the effect is to wait for about one minute, *then* do a force refresh - that's long enough for you to "fall off" the cache, and then you'll (hopefully) get assigned to a different pod when you load again!

If you don't actually see a different hostname even after *waiting at least one minute between requests*, don't worry - it's likely you just got assigned to the same pod again. However, with luck, you'll be on a different pod and you'll see a different hostname!

## Submission

Your submission should include:

* Your YAML file.

This assignment will be due Friday May 3rd at 11:59 PM.
