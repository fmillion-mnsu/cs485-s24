# Kubernetes

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
