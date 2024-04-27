# Group Activity 3

This is it! Your last assignment for the semester!

In this exercise you and your group will deploy a container to a live Kubernetes cluster. I have prepared and deployed a Kubernetes cluster consisting of three nodes and have setup access for you to use it via the cloud.

1. Visit the D2L Content section and retrieve the file named `config` from the Group Assignment 3 folder. **This file contains the secret keys needed to access the cluster. Do not share it with anyone outside of the course!**

    While there, also view `group_members.txt` and `credentials.txt` to learn your group number as well as your credentials for accessing the container registry that you will use in Step 7.

2. (If you are on Windows) Copy the configuration file into your WSL environment. Remember that you can access WSL from File Explorer. Navigate to your Ubuntu instance, then to `home`, then to the folder for your username. Inside that folder, **create a new directory** called `.kube`. Open that directory and place the `config` file inside.

    This step reconfigures `kubectl` to interact with the live production cluster.

    (If you are on Mac) Simply make a folder named `.kube` in your home directory and place the `config` file inside it.

    > **Important Note:** You will already find a `config` file in the directory if you've installed Minikube. You likely want to keep this file around so you can continue to use Minikube in the future, so **rename** the file to sometihng like `config.minikube` rather than deleting it. Then place the downloaded `config` file into the directory.

    If you cannot get WSL working or have other issues, you can also install `kubectl` as a Windows executable by following [these instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/). In this case, you also make a folder named `.kube` in your home directory and place the `config` file within - on Windows, your home directory is probably `C:\Users\<your_username>\`. You can then run many of these commands from Windows itself (except for the Docker commands).

3. Test that your copy of `kubectl` can now access the live production cluster. Run `kubectl version` and check that `Server Version` is `v1.29.3+k3s1`. (In particular, the server version should end with `k3s1`, indicating this is a cluster installed by [K3s](https://docs.k3s.io/) rather than a local single-node Minikube cluster.)

4. Clone the repository or otherwise download the three files in the `assign3` folder in this repository. (Note that while these are similar to the files in `i_assign3`, they are **not the same**.)

5. **Add a file** to the `assign3` directory. The file must be named `group.txt`, all lowercase. (In Linux/UNIX, filenames are case sensitive!) In the file, include your group number and the names of your group members - one per line.

    Example `group.txt` file:

        Group 1
        Harry Potter
        Hermione Granger
        Ron Weasley

6. Build the container, just as you did in Individual Assignment 3. However, this time, **use the following tag for your container**:

    `cr.kube.campus-quest.com/group<num>/assign3`

    Replace `<num>` with your group number. **See the `Group Numbers` file in D2L to learn your group number**.

    For example: `docker build -t cr.kube.campus-quest.com/group1/assign3`

    > **Important:** **DO NOT** use the wrong group number or abuse the servers! *You may overwrite another group's work!* I am counting on everyone to be honest and respectful of others work, however do note that accesses to the cluster are logged and if I identify malicious or inappropriate conduct I will need to have some serious discussions with you!

    In this case, the `cr.kube.campus-quest.com` refers to a **Docker container registry** that I have made available for you to use for the project. This syntax allows you to host Docker images on any Web server that has been configured properly.

7. After you've built the image, you must add credentials to your copy of Docker so that you have permissions to use the registry. **You only need to do this once.**

    `docker login cr.kube.campus-quest.com`

    You will find the credentials in the `credentials.txt` file in the D2L content folder for Assignment 3.

    Provide the credentials when prompted. If the login is successful, you may proceed.

8. **Push** the image to the container registry:

    `docker push cr.kube.campus-quest.com/group<num>/assign3`

    > **Info:** The reason we have to push the image to a container registry instead of using something like `minikube image load` is because, by design, Kubernetes doesn't support direct injection of a container image - it always expects to retrieve images from a container registry.
    >
    > When we run `minikube` locally, we can "abuse" the system by directly injecting container images into the image cache on the cluster by manipulating the files that make up the cluster. For local testing, learning and development, this works fine because it's on your own local PC and doesn't (shouldn't!) get exposed to the public Internet. However, you can probably imagine the potential issues if a user could simply inject random container images into a production cluster without any auditing or oversight! While in theory we *could* potentially do the same thing to our live cluster, allowing that would make the problem even worse. At that point, even someone without direct access to the cluster's API could theoretically poison some of its container images.
    >
    > To mitigate this, Kubernetes always loads images from a container registry. The good news for us is that it's very easy to setup a container registry using Let's Encrypt certificates and Traefik (yes, again!) as the proxy server for the registry. When you run your own container registry, you are limited only by the amount of storage you have available on the server to store container images in. 

9. Now it's time to deploy your image into Kubernetes! There are a few new steps to this.

    First, we will create a **namespace** to put all your work into. Kubernetes **namespaces** are simply separate spaces in which to deploy Kubernetes objects. You can configure many things based on namespaces, but for our purposes it will simply serve as a way to ensure that your containers run independently of others in the class. 

    > Your namespace should be called `gX` with `X` being your group number - so `g1` for group 1, `g2` for group 2 and so on.
    > 
    > <p style="font-size: 200%">If you do not put your containers into the correct namespace <strong>you will lose points on the assignment</strong>!!</p>
    >
    > Not to mention, you may interfere with another group's work, causing them frustration and confusion.
    >
    > Please use the right namespace!!

    Here's the command. Remember to replace `X` with your group number!

        kubectl create namespace gX

10. Now, we need to create a **secret** in our namespace. This secret contains the login information needed for Kubernetes to retrieve the container image from our registry. 

    To create a **secret** in your group's **namespace**, use this command, replacing the items in angle brackets (`<` and `>`) as appropriate:

        kubectl create secret -n <namespace> docker-registry dockercredential --docker-server=cr.kube.campus-quest.com --docker-username=group<groupnum> --docker-password=<your_groups_password> --docker-email=anonymous@example.com

    The username and password should be the same as the ones you used on the `docker login` command, and the namespace is `g1`, `g2`, etc. as appropriate.

11. Great - you're now ready to deploy your image into the Kubernetes cluster! Start by creating a YAML file to store the configuration for your objects.

    Here is a Kubernetes **deployment** YAML file you can use to get started:

        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: groupX-a3-deploy
        spec:
          replicas: 3
          selector:
            matchLabels:
              app: groupX-a3
          template:
            metadata:
              labels:
                app: groupX-a3
            spec:
              containers:
              - name: groupX-a3
                image: cr.kube.campus-quest.com/groupX/assign3
                imagePullPolicy: Always
              imagePullSecrets:
              - name: dockercredential

    Make sure you change `groupX` to match your group number! (replace `X` with your group num)

12. For Traefik to see the deployment, we need a Service, just as we did before. However, in this case we don't have to give the Service a *type*, since Traefik in Kubernetes detects containers via Kubernetes *service* definitions. 
  
    Here is the code for the service. Add it to your YAML file. Remember that you must separate individual objects in the YAML file by using three hyphens (`---`) on a line by themselves.

        apiVersion: v1
        kind: Service
        metadata:
          name: groupX-service
        spec:
          selector:
            app: groupX-a3
          ports:
            - protocol: TCP
              port: 80
              targetPort: 80  

13. Finally, we need a new type of object vknown as an `Ingress`. An *Ingress* object simply defines an entry point into the cluster. Traefik will see the service, match it with an Ingress, and automatically configure itself much like it did with Docker Compose.

    Add a third object section to your YAML file, remembering to separate the objects using three hyphens alone on a line between the two sections.

        apiVersion: networking.k8s.io/v1
        kind: Ingress
        metadata:
          name: groupX-ingress
          annotations:
            traefik.ingress.kubernetes.io/router.entrypoints: websecure
        spec:
          tls:
          - hosts:
            - groupX.kube.campus-quest.com
          rules:
          - host: groupX.kube.campus-quest.com
            http:
              paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: groupX-service
                    port:
                      number: 80

14. Save your YAML file with a reasonable file name.
  
15. Now is the moment - it's time to deploy your configuration into the cluster! 

        kubectl apply -n gX -f <yourYamlFile>

    Remember to replace `gX` with `g` followed by your group number, and use the correct YAML file.

16. Finally, try to access your new site at `https://group<num>.kube.campus-quest.com`.

If you are successful, then congratulations - you've just deployed a live public web page to a real-life Kubernetes cluster! ... *And you are DONE with the course!*

# Deliverables

For this final assignment, please submit:

* The YAML file you created for deployments
* Screenshot of at least two different hostnames showing your group's content.

You *should* be able to do a force-refresh, as you did with the Docker Compose version of this, since Traefik is back in the picture now. However, if you're not seeing two different hostnames, try using a private browsing window.

This is basically the same as the individual assignment! However, note that **I'll also be checking the Kubernetes server itself!** So, do NOT delete anything you deploy from the server!

This assignment is due **Friday, May 3rd** at **11:59 PM**. This is a group assignment - only *one* submission per group is required.

# Deep Dive

Let's explore the entire YAML structure and explain each line.

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      # This line specifies a name for the deployment.
      name: groupX-a3-deploy
    spec:
      # You can change this if you want to make more replicas of your service. Go ahead, try it - just be
      # reasonable, setting it too high may crash the server! Do not deploy more than 20 replicas.
      replicas: 3
      selector:
        matchLabels:
          # The deployment will consist of pods that match this app name...
          app: groupX-a3
      template:
        metadata:
          labels:
            # ...and the app name is defined here, in the template.
            app: groupX-a3
        spec: # All pods will be created with these settings
          containers:
          - name: groupX-a3
            image: cr.kube.campus-quest.com/groupX/assign3
            imagePullPolicy: Always
          imagePullSecrets:
          # The name of the credential you created to store the Docker login information
          - name: dockercredential
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: groupX-service
    spec:
      selector:
        # Same as the deployment. The service will route to all pods with this app name.
        app: groupX-a3
      ports:
        # this is basically the equivalent of a -p option in Docker.
        # the "port" is the value before the colon, and the "targetPort" is the value after it.
        # So in this case, it's like saying "-p 80:80".
        # It's fine that we're setting this to port 80, because Traefik will connect via port 80, and
        #   put the traffic into an SSL connection for us. (And Traefik also manages the Lets Encrypt cert.)
        - protocol: TCP
          port: 80
          targetPort: 80  
    ---
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: groupX-ingress
      annotations:
        # This is a Traefik-specific setting. It tells Traefik which *entrypoint* to listen for
        #   connections to this service on. In the Traefik configuration, there is an entrypoint
        #   defined called "websecure", which listens on port 443 (https) and also is configured
        #   to manage a Lets Encrypt certificate.
        traefik.ingress.kubernetes.io/router.entrypoints: websecure
    spec:
      tls:
      - hosts:
        # This is the hostname that Traefik will listen on.
        # For this project, any hostname underneath "kube.campus-quest.com" directs to all three
        #   of the Kubernetes nodes, in a round-robin fashion. 
        # Thus, by setting this, you control which domain name will route to your pods.
        - groupX.kube.campus-quest.com
      rules:
      # A repeat of the above. The above specifies hosts for the SSL certificate matcher,
      #   while this one specifies hosts for the actual connection itself.
      # Don't worry too much about the distinction between the two for now.
      - host: groupX.kube.campus-quest.com
        http:
          paths:
          # Specifies that everything should be routed to the pod.
          # You could instead only route requests under a certain directory to the pods,
          #   for example if you have an API and a frontend in different pods.
          # Don't do this for this project since there is only one web page on your container anyway.
          - path: /
            pathType: Prefix
            backend:
              service:
                # This specifies which Kubernetes service Traefik should push connections to.
                # Kubernetes will handle round-robin-ing the connections.
                name: groupX-service
                port:
                  # Which port to connect to the service on. This is why we left the service listenong
                  #   on "external" port 80 - in this case, Traefik is the "external" thing connecting
                  #   to that port.
                  number: 80

# Final Word

This course has only touched on the very basics of Kubernetes - I wish I had a **lot** more time to share with you all of its great features and capabilities. However, definitely do check out [Kubernetes' documentation](https://kubernetes.io/docs/home/), as well as the following resources:

* [Minikube](https://minikube.sigs.k8s.io/docs/start/), which you've used already in this class
* [K3s](https://docs.k3s.io/), an easy to use deployment tool for live Kubernetes clusters - it's actually what the cluster I made available to you uses!
* [Rook](https://rook.io/), a tool that provides and manages *distributed storage* for your cluster in the form of the [Ceph distributed filesystem](https://docs.ceph.com/en/reef/)
* And, of course, ChatGPT knows a lot about Kubernetes - ask it questions and it'll even help you with generating example configurations you can work from!

**Best of luck to everyone!!!** For those of you who are returning in the fall, I hope to see you in one of my future elcetive courses. For those of you graduating, **keep in touch!!** I would *love* to hear your success stories and keep up with you. Remember that you are always welcome in the CS community at Minnesota State Mankato!

**HAVE A GREAT SUMMER!!!**
