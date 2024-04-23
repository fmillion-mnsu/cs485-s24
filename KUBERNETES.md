# Kubernetes - A "Shallow" Dive

Kubernetes is the "next step" in containerization. Once you've gotten used to using Docker itself to both develop within containers and also to deploy and run public applications using containers, the next step is a container *orchestrator* with more capabilities and which applies to more scenarios.

Plain Docker on its own is great for an individual or for a small production server. You've seen by now that you can install it on a standard computer and that you can use it to host websites on your computer as well as create predictable, reproducible development environments. But any application that gets a lot of use is going to need more than one single instance - and for an application that has high availability demands, more than one instance is almost a requirement, not a preference.

There are many container orchestrators beyond Docker. Among them are Kubernetes Marathon, Nomad, Docker Swarm, podman and others. We'll focus on Kubernetes since it is probably the one most developers have at least heard of in passing. (If you've heard of Docker, it's almost certain that you've at least heard someone struggling to figure out how to pronounce Kubernetes. Hint: It's "Coo-burn-net-tease".)

## What It Is

**Kubernetes** is known as an *orchestrator*, a term I've already used a bit but haven't yet defined clearly. In containerization, an *orchestrator* is a piece of software that manages containers. Much like an orchestra conductor manages a large number of musicians, a container orchestrator manages many containers. 

Docker can be argued to be a container orchestrator, since it provides you with an interface (the command line or the Docker Desktop UI) to manage containers. However, you have probably noticed by now that at this level, much of the work to manage containers is manual. Sure, you don't have to run complex install scripts and worry about cryptic incompatibilities in different libraries, but you still have to memorize the commands and/or actions to deploy a container. While this makes perfect sense for developing and testing software, it won't scale well to very large clusters of computers. Kubernetes is essentially the next layer on top of a containerization engine that further automates the management of containers.

## What It Can Do 

Of course Kubernetes isn't "hands-off" - you still have to configure it and set up your container stacks - but once you've "taught" it about your infrastructure and applications, Kubernetes will start to seem like a magic IT person that just *does the work for you*:

* Is your site getting busy and starting to lag? Kubernetes can detect this and tap into available resources to deploy more processing nodes for your app. 
* Need to update an application that's installed on thousands of servers with zero downtime? Kubernetes can automate the process of stopping a server, removing it from the round-robin, updating the container, testing the result, and then finally re-inserting it into the round-robin. 
* Launching a new product that you expect to produce an unusually large amount of traffic to your site? You can schedule a predictive scale-up to prepare more resources *just-in-time*, minimizing hosting and maintenance costs. (Hello, Valve? Might you consider checking into this before the next Steam Deck launch? Please?)

Kubernetes can also be configured to handle running of short-term jobs in containers - sort of like a *job queue* system optimized specifically for running containerized workloads. As one simple example, you could build a pod that contains an `ffmpeg` container, and then let Kubernetes handle running that container across many nodes to encode a series of video files. To do this you would need the video files stored in such a way that any node in the cluster can access them (see below sections for a bit more detail on this aspect), but you can use Kubernetes to handle queueing and running the containers for you. (Kubernetes isn't necessarily a full-on replacement for a custom job handler; on its own it won't handle things like per-user job limits or payment-per-job. However, with the right tooling in front of Kubernetes, it could be used as a backend for running the jobs.)

## What It Can't Do

Kubernetes might seem like magic once it's all configured, but there are still many things that Kubernetes *on its own* is not capable of doing. For example, Kubernetes can run multiple copies of an application across multiple servers; on its own, however, it does *not* handle interoperatibility and synchronization between those instances. So if you design an application in such a way that it's not able to handle multiple instances on multiple servers, Kubernetes won't magically make that happen for you. 

Alongside Kubernetes, many other tools often come into play. For databases, there are many designs and products for *distributed databases*, which include the code and architecture to run across multiple nodes and keep data synchronized and available across those nodes. Kubernetes *can* help you run such a database system, but Kubernetes can't magically make a single-node MySQL server "distributed", at least not without serious intervention on your part.

Similarly, Kubernetes does offer the capability to handle *distributed storage* - but again, on its own, it won't *implement* that storage for you. Storage systems like S3 as well as filesystems focused on distributed deployments are available, and again can be *managed* and *scaled* with Kubernetes, but Kubernetes doesn't offer its *own* distributed storage system. (It does, however, offer plugins for many storage platforms that can be interacted with inside a Kubernetes cluster.)

## Some Terminology

* **Pod**: A *pod* is a set of one or more containers that comprise a service. A pod might consist of a single container containing a static Web application, it could be a single node in a distributed database or filesystem, or it could be a group of containers that, combined, make up one node of a distributed application. Pods are always treated atomically - i.e. if a pod contains multiple containers and not all containers start successfully, the pod as a whole is considered to have failed startup. 
* **Node**: A *node* is a physical or virtual machine that has Kubernetes installed and is participating in a cluster. Nodes can be located within a single network, or they can be distributed across wide area networks. 
* **Cluster**: A *cluster* is a collection of nodes that all operate in cooperation to provide distributed availablilty of applications. Nodes can arrive and leave as necessary or as "things happen" - i.e. a node can go offline for updates and other nodes can take up the slack in the meantime. 
* **Deployment**: A *deployment* is the definition of how one or more Pods will be *deployed* to the *Nodes* in the *Cluster*. A deployment specifies which pods to run, their configuration and how to handle scaling the deployment. For example, a deployment can specify a minimum of 3 copies of the application running on 3 distinct nodes, and then can specify that if any one node has greater than 80% of CPU usage constantly, automatically find and deploy to another node, and so on.
* **Service**: A *service* is one of Kubernetes' unique abstraction features. It allows a deployment, such as a backend or database service, to be given a *virtual IP address* that other deployments can access. The key is that a service abstracts away all of the distributed nature of the deployment behind the service - from the perspective of the cluster, only a single IP address is used to access the deployment regardless of what nodes it may be running on, or how many nodes for that matter. **This is essentially the Kubernetes version of "how is it that I can visit google.com anywhere and it works and is fast?"!**

# Setting it up

In-class activity: work through <https://kubernetes.io/docs/tutorials/hello-minikube/> to 1) ensure Kubernetes is configured correctly on your machine and 2) that you can interact properly with it.

# "Doing Stuff" with Kubernetes

In Kubernetes, you can deploy objects into the infrastructure with a YAML file. This is similar to a Docker Compose file, but it's still quite distinct - the YAML fields are completely different. But more importantly, with a Kubernetes YAML object file, you simply "submit" it to the cluster and the cluster takes care of allocation and deployment of all of the resources you specified. Kubernetes is basically the super-intelligent IT person sitting in the datacenter, and your YAML file is a support ticket.

What makes Kubernetes "awesome" is that you can simply *ask for something* and the cluster will do everything in its power to *give you what you asked for*. Want three replicas of a service but only have two nodes? It'll push two replicas onto a single node (and with the right setup, it'll even select the node with more available resources to put two replicas on). 

The other half of the magic is that *all* nodes in the cluster (by default) are "proxies" into the services running in the cluster. So if you have four nodes, each with their own IP address, a client can visit *any* of the four nodes, and Kubernetes will direct the request to the correct container somewhere in the cluster. If you connect to node 3 but the container is on node 0, Kubernetes will route the connection to node 0 for you. If you connect to node 3 but there are only three replicas of the container you want running on nodes 0, 1, and 2, Kubernetes will direct the connection to one of the nodes for you. 

## Kubernetes vs. Traefik as the distributed proxy

In this way, Kubernetes serves a role a bit similar to Traefik with its round-robin routing, but it's not exactly the same. Kubernetes is not a *web server* proxy; it's just a *connection* proxy. The advantage is that it means Kubernetes can route *any* kind of connection - database servers, Minecraft servers, whatever - but the disadvantage is it means Kubernetes can't do things like handle SSL certificates, manipulate HTTP connection headers and so on. 

The solution to this is to use Traefik inside Kubernetes as a service - you can have as many Traefiks as you need to handle the load your servers expect to experience. But even if you run only a single Traefik on a cluster with many nodes, that's fine, because Kubernetes will route connections from any node to the node running Traefik.

This solution isn't the *most efficient* one, as it means Kubernetes is going to be proxying connections to Traefik most of the time, but it does work. However, a more efficient setup would be to utilize multiple Traefik instances running in your cluster and pin the instances to the nodes, so that each node has its own Traefik to manage the HTTP portion of the connection. Traefik can then utilize the same mechanism to "ask" Kubernetes to route the requests it's getting across the nodes in the cluster.

Effectively, Traefik is no longer the *round-robin* proxy; Kubernetes is. We instead have a Traefik running on *each* node in the cluster, and from each Traefik's perspective, it's simply routing traffic from some public Internet client to some internal Docker container, just like we've seen so far. Kubernetes changes things in two ways: it manages the multiple Traefik instances (letting you do things like rolling upgrades) and it also provides the round-robin routing to the individual containers on the nodes.

> It should be noted that Traefik itself can also act as a "connection" proxy via its TCP and UDP proxying functionality. With these modes, Traefik can do round-robin proxying of any server, like a database server. However, since Traefik is strictly a proxy, it doesn't offer any of the clustering, orchestration and management functionalities that Kubernetes does. 
>
> What we are in effect doing is using *both* Traefik and Kubernetes and letting each do what it does best. Traefik is excellent as an HTTP proxy as it can handle things like SSL certificates, HTTP header manipulation, path-based routing and so on. Kubernetes, on the other hand, excels at maintaining a network of nodes running containers and routing incoming connections to those containers. By using the two together, we get the benefits of both!

# How do we deploy something to Kubernetes?

Let's start with the simplest example - deploying a single container to a Kubernetes cluster that contains a single node. In this config, we aren't really getting to see some of the *beautiful* capabilities of Kubernetes, but it's a way to get started (and most of those capabilities are simply expansions of this basic deployment.)

The core utility that we use to interact with a Kubernetes cluster is `kubectl`. (This is distinct from `minikube`, which is a tool that creates a single-node Kubernetes cluster for you; `kubectl` works on a Minikube cluster, but it also will work, mostly the same, on a cluster of 10,000 nodes running in a massive datacenter and costing your company $5,000 per hour to run). `kubectl` can be seen as roughly analogous to a mash-up of `docker` and `docker compose` in that it offers us many commands to control the containers running in our cluster.

The simplest way to deploy a container into the cluster is to simply specify its parameters on the command line - very much like manually starting a container using `docker run`. Here is an example that will start up a Hello World web server container in your cluster:

    kubectl run welcome-pod --image=docker/welcome-to-docker

This command is analogous to Docker's `docker run` command - it creates a **pod** within your cluster. Remember that a pod represents the smallest unit of your application - it can be (and often is) a single container, but it could also be a stack of multiple containers that all work together and must all exist together. 

We now have a pod running, but we have no way to access it. That's because, like with Docker, containers running in Kubernetes do not expose any services to the Internet (or to your computer itself) by default. In Docker, you use the `-p` switch on the command line, or you use the `ports:` section in a Compose file. Where Kubernetes differs here is that you can expose the service *without* needing to re-create the container - Kubernetes can dynamically provide access to running containers, and can also dynamically *remove* that access without needing to stop the containers.

> You can imagine where this might be useful. Suppose you discover a service is misbehaving. With Docker, you would have to simply stop the service and hope that the logs for the container show something useful (and also hope you didn't start the container with `--rm`). However, with Kubernetes, you can simply remove the public *access* to the container but leave the container running, allowing you to access it and analyze it while it is running.

You can expose your new pod for access by using this command:

    kubectl expose pod welcome-pod --type=LoadBalancer --port=80

Your pod is now listening on port 80 of... what? If you try going to `http://localhost:80`, you'll find it doesn't work.  Why?

When we use `minikube` to run a cluster on our local computer, we're actually starting Kubernetes *inside a Docker container*. It sounds weird, but that's basically how it works! So there's a couple ways we could fix it: 

* We could restart `minikube` and specify some specific ports that we want forwarded, or
* We can use `minikube`'s `tunnel` feature to dynamically forward connections into the container from our computer.

The `tunnel` option is a bit less "clean" in the sense that you need to leave the terminal window open while you're using the service (the tunnel program is a "foreground" program, so as soon as you close it, the tunnel goes away), but this disadvantage is offset by the simplicity it offers for getting connections into a service in Kubernetes.

Simply run the command `minikube tunnel` to start the proxy server. 

After you've done this (and assuming you've been following along!) you should now be able to open `http://localhost` in your browser and see your container!

Press `Ctrl+C` in the terminal window you're running the tunnel in to stop the tunnel. The pod will stay running but you will no longer be able to access it. (Technically the service is still running too, exposing the pod, but we can't access it because we terminated the tunnel.)

# Scaling

At this point, all we've really accomplished is the same thing we've done with Docker, only a lot more complex. (And we're even doing it within Docker.) Now, let's start to explore what makes Kubernetes different.

The first significant change we're going to make is to *scale up our service*. This unfortunately won't have a lot of actual "visible effect" other than seeing it happen with Kubernetes maintenance commands, but it's the first step towards the task in Individual Assignment 3.

If you still have the previous deployment running, we first need to stop it and remove it. Why? Because in the last section we created a pod directly, bypassing Kubernetes' internal management functions. This worked well to get a service running, but we can't really *manage* it very much. So let's first get rid of our existing service and pod:

    kubectl delete service welcome-pod
    kubectl delete pod welcome-pod

We now are back to where we started - an empty cluster with no containers running.

Now we're going to bring our container back up, but this time we're going to introduce a **deployment**. A deployment, as described above, is a description of, well, a deployment of one or more pods. 

Here's the command:

    kubectl create deployment welcome-deploy --image=docker/welcome-to-docker

> Did you notice that these commands all are similar? Many Kubernetes commands executed with `kubectl` take the form of `kubectl <operation> <object_type> <object_name> <parameters>`. In this example, we `create` a `deployment` called `my-deployment` with the parameter `--image=docker/welcome-to-docker`.
>
> You'll see this pattern a lot when you work with `kubectl` - for example, `create`, `delete`, `get`, and `edit` (among others) are all operations, while `node`, `pod`, `deployment`, and `service` (among others) are all object types. 

After this command, we again have a pod running the `docker/welcome-to-docker` image. (Try running `kubectl get pod` to see the list of pods.) 

We also need a service, like before. Creating a deployment creates the pod(s) for you, but doesn't create the service:

    kubectl expose deployment welcome-deploy --type=LoadBalancer --port=80

This looks very much like the previous command we used, but note that we are exposing the *deployment* and not the *pod*. At this point, run `minikube tunnel` and check that you can access the site in your browser.

Now, let's do the magic. Let's assume we want three copies of this website running. We can simply ask Kubernetes to *scale up* our service to three instances:

    kubectl scale deployment welcome-deploy --replicas=3

You can still access the site in your browser. But try executing `kubectl get pod` - note that there are now *three pods* in the cluster. Kubernetes scaled up the service to three replicas, and it magically handles load balancing across them using `LoadBalancer`. 

> For this basic exercise we are manually scaling the service, but Kubernetes is able to perform this operation automatically. You can configure this in all sorts of ways - for example, if more than a certain amount of traffic, or more than a certain amount of system resources, are being used, you can have Kubernetes automatically scale up the deployment for you - and you can also have it scale down as well when enough replicas are idle. In an environment where you pay for server resources based on usage, this can have *tremendous* cost saving advantages!

Let's scale the service back a bit:

    kubectl scale deployment welcome-deploy --replicas=2

Now, `kubectl get pod` will only show two replicas running. One of the replicas was terminated by Kubernetes and its resources were released. However, *users of the application are none the wiser!*

# YAML configuration

Creating objects using the command line is *fun*\*, but it's not very maintainable. Sure, you could commit awkward shell scripts into a Git repository, but that's note likely to be easy for another sysadmin to deal with. Instead, we can use Kubernetes' YAML format to define and submit objects for creation or modification. Think of it as similar to a Docker Compose file, just with a *lot* more functionality.

Let's replicate the above configuration, with three replicas, but as a YAML config file:

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: welcome-deploy
    spec:
      replicas: 3e
      template:
        metadata:
          labels:
            app: welcome
        spec:
          containers:
          - name: welcome-container
            image: docker/welcome-to-docker:latest
            ports:
            - containerPort: 80

Ok, this looks more complicated than the simple command line. However, you can easily see all of the command line options we provided within this YAML file. In particular, note the deployment name and the container image. 

And here's the YAML for the LoadBalancer service:

    apiVersion: v1
    kind: Service
    metadata:
      name: welcome-service
    spec:
      ports:
      - port: 80

We can actually combine these two items into a single YAML file using the YAML separator `---` (three hyphens):

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: welcome-deploy # this is the name of the deployment that you'd specify on the kubectl create deploy command
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: welcome-deploy # This must match the app label below in the template
      template:
        metadata:
          labels:
            app: welcome-deploy # This must match the matchLabels app label above
        spec:
          containers:
          - name: welcome-pod
            image: docker/welcome-to-docker:latest
            ports:
            - containerPort: 80 # Specify the port the container is listening on.
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: welcome-service
    spec:
      type: LoadBalancer
      ports:
      - port: 80
      selector:
        app: welcome-deploy # this needs to be the name of your deployment

Take all of the above and put it in a file with a `.yml` or `.yaml` extension. The file name doesn't matter (unlike with Docker Compose). Asusming you wrote the data to a file called `demo.yaml`, you can now push these objects into your cluster with this simple command:

    kubectl apply -f demo.yaml

And just like magic, the app is deployed into your cluster!

You can also edit the YAML file and run the `apply` command again - Kubernetes will *update* the resources to match the state of the YAML file. It will match existing objects on their type and name, and will update the object's configuration if needed.

> **Hint:** You can quickly delete all deployments and services with this handy command:
>
>     kubectl delete deploy,service --all
>
> This also points out that you can actually specify multiple object types in certain commands.

# Checking on things in Kubernetes

The `kubectl get` command is your best friend for checking on what's happening in the cluster. For example:

    kubectl get pod

will show you a list of all pods running in the cluster. If you have a deployment with many replicas, there will be one pod per replica.

    kubectl get deploy

will show you the deployments you've pushed to the cluster, and will give you a short status report on each, such as how many replicas are up and running.

Finally,

    kubectl get service

shows you the services - e.g. load balancers - that you have created.

You now have the basic knowledge you need to do [Individual Assignment 3](I_ASSIGN3.md) - enjoy!
