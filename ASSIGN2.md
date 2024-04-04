# Group Activity 2

This exercise will give you a chance to explore reverse proxies and how you can use them to offer multiple services at one endpoint.

This exercise is more open-ended and you have a few options for how to setup your environment. I will give you some hints on using Traefik here, but you can also use another reverse proxy (such as haproxy, nginx, or caddy) if you choose. This exercise will require you to do some of your own research on how to setup the services!

## Part 1: Getting one service working

The first step is simply to get a Web application of some sort working on your environment. There are a wide variety of options at [linuxserver.io](https://fleet.linuxserver.io/) to choose from, and there are also many other hundreds or even thousands of Web applications built using Docker available. (Hint: you can even use your CS project if it's a web application that you can or have Dockerized!)

You can use applications that are simple and self-contained - for example, [librespeed](https://hub.docker.com/r/linuxserver/librespeed) does not require any database - you *can* use one if you wish but you do not *have* to. However, since many mainstream applications, and indeed many applications you develop, *will* require some access to a database, I *strongly* recommend you consider at least one application with a database, such as a WordPress blog. See the appendix in this document for a bit of background info on how to set up a database server in your Compose stack - it's not hard!

A few other examples of applications that can run without a separate database container are [Drupal](https://hub.docker.com/_/drupal), [FileBrowser](https://filebrowser.org/installation#docker) or [Gitea](https://docs.gitea.com/installation/install-with-docker).

1. Use a `compose` file to get your application working. Use whatever default ports the application expects you to expose.

    For example, *Gitea* exposes its web interface on port 3000, and the example Compose files do the same. Don't change the default ports for now.

    > **Hint:** Be careful when using example Compose files. Some Compose files are written for older versions of Compose and thus may present some compatibility issues.
    >
    > In particular, it is not recommended to use the `container_name` option anymore. This option lets you specify an explicit name for the container, rather than letting Compose generate a name for you based on the directory and the service name. However this could potentially create a naming conflict later down the road!

    Make sure you *verify* and, if necessary, *edit* any example compose files you encounter. Or even better, write your own based on the documentation!

1. Test and make sure your application runs (e.g. `docker compose up -d`). Open a browser and access the application at localhost on the correct port for the application you chose.

1. Stop your application. (`docker compose down`)

## Part 2: Adding a second service to the same Compose file

1. In the *same* Compose file, add the configuration for a *second* Web application. (Basically, repeat step 1, but add your new service to the *same* Compose file.)

    > **Hint:** Remember that the section name in the YAML file is the service name. For example:
    >
    >     services:
    >       nginx:
    >         ...
    >       filebrowser:
    >         ...
    >
    > represents two services: one named `nginx` and one named `filebrowser`.

1. Test your second service by starting it *explicitly*. For example, if your second service is named `filebrowser`: `docker compose up -d filebrowser`

    > **Hint:** Specifying one or more service names on the `docker compose up` command line will start up only those services.
    >
    > You can also do the same with `docker compose down` to stop only certain services.

1. Stop your container stack again with `docker compose down`.

## Part 3: Running *both* applications simultaneously using a Reverse Proxy

1. Select a reverse proxy of your choice. Each one will have unique strategies for configuration.

    > **Hint:** Both `traefik` and `caddy` are "Docker-native", meaning they were designed with Docker and containerization in mind. While you definitely can set up a reverse proxy in Docker using `haproxy` or even plain `nginx` or `apache`, those proxies will require a lot more manual configuration on your part.
    >
    > For this assignment it is not crucial which reverse proxy you use, however my personal recommendation is to use `traefik`.

1. Add a third service to your Docker Compose file that runs your reverse proxy. Set up a port forward (hint: `ports:`) to forward some port on your machine to port 80 of the reverse proxy.

1. *Remove* any `ports` sections from your other two web applications. This will set up the applications so that they *cannot* be accessed directly - access must occur through the reverse proxy. This is also required to run multiple services on a single TCP port!

1. Perform appropriate configuration for your reverse proxy - this will likely include passing in a config file and giving the reverse proxy access to Docker so it can monitor the containers you are running.

    > **Traefik**
    >
    > [This directory in the repository](assign2/) contains a configuration file for Traefik. To use it, you must map the configuration file into the container and then add a command to the container that reads `--configFile=/path/to/config/file/INSIDE_THE_CONTAINER/`
    >
    > The configuration file does the following:
    >
    > * Configures Traefik to listen on port 80, with no HTTPS. (For this exercise, do not worry about SSL/TLS certificates.)
    > * Instructs Traefik to write debug logs to the path `/data/logs`. Map a directory on your system to that path in the container if you want to collect and be able to view logs.
    > * Instructs Traefik to provide access to the dashboard on `traefik.localtest.me`.
    > * Sets up a routing rule that lets you use a *label* to create subdomains on the fly per service. More on this in a moment.
    > * Configures Traefik to *not* forward containers by default, unless the label `traefik.enable=true` is set on the container.
    >
    > For Traefik (and for other proxies that are Docker-aware), you need to provide access to the Docker *socket* to the proxy. Add this volume to your proxy container:
    >
    >     traefik:
    >       ...
    >       volumes:
    >         ...
    >         - "/var/run/docker.sock:/var/run/docker.sock"
    >
    > The configuration provided lets you define the subdomain for each service in your container stack using a label called `host`. So, for example if you were running a WordPress blog, you can easily map it to your Traefik proxy by adding this label:
    >
    >     wordpress:
    >       ...
    >       labels:
    >         - "host=wordpress"
    >
    > This will make the `wordpress` container available at `wordpress.localtest.me`.
    >
    > If your service does not work, you may need to explicitly specify the port that the service listens on. You can do this by using the following label within that service in Traefik:
    >
    >     - "traefik.http.services.<name_of_your_service>.loadbalancer.server.port=<port>"
    >
    > For example, if you chose Gitea for one of your services, and you named the service `git,` you'd use the following label:
    >
    >     services:
    >       git:
    >         ...
    >         labels:
    >           ...
    >           "traefik.http.services.git.loadbalancer.server.port=3000"

1. Bring up your *entire* Compose stack with `docker compose up -d`. (or leave off the `-d` if you want to see all of the logs in real time)

1. Finally, try accessing *both* of your services, as well as the dashboard, in a browser by using the *correct local domain names*.

## Submission

Your submission for this project must contain the following:

* Your Docker Compose file.
* Any configuration files (e.g. `traefik.yaml` or others) that you use to configure your reverse proxy.
* One screen shot each showing your two services and the dashboard being accessible from a browser at the correct domain names.

This is a *group activity* and thus only *one* submission per group is required.

I am giving you less specifics for this project so that you're encouraged to explore, experiment, research and design your own stack of containers! I'll answer questions that you have about specific problems or concepts you are struggling to understand, but please try to solve issues on your own first! (Also, feel free to ask your group members to help, and you can even ask other groups for *advice* as long as you're not getting copies of other groups' code!)

> **Appendix: Using a database container in your stack**
>
> One of the neat aspects of using Docker Compose is that containers within a "stack" (all of the containers or services defined in one Compose file) are able to communicate with each other, even if the containers have no ports forwarded to the outside. One major advantage of this is that you can run a database server, like MySQL or Microsoft SQL Server, and you can provide access to the DBMS to the containers, but *not* to the Internet (or to the network overall). This offers a great deal of security - any vulnerabilities in the database that involve directly connecting to it are much harder to exploit, as it would require an attacker to induce another container to act on its behalf. When you combine this with a reverse proxy, an attacker would have to fight their way through *two* layers of abstraction - the reverse proxy and the Web application itself - to reach the database.
>
> The trick to accessing one container from another is simply to use the service name as a "domain name". For example, if you had this Compose file:
>
>     services:
>       mysql:
>         image: mysql
>         volumes:
>           - ./database:/var/lib/mysql
>         environment:
>           - MYSQL_ROOT_PASSWORD=I_write_good_c@de
>
>       webapp:
>         image: some-web-application
>         labels:
>           - host=webapp
>
>       traefik:
>         image: traefik
>         ports:
>           - 80:80
>
> ...now you can simply tell your web app that the MySQL server's address is "mysql".
>
> When connecting from one container to another, you do *not* need to specify a `ports:` section. However, you must use the "native" port - i.e. if MySQL listens on port 3306 (its default), and you need to specify a port for the database, you have to use 3306 - using a `ports` section won't let you change the port number. This isn't a big deal however, since each container behaves sort of like a separate computer, and all of the computers are connected to a "virtual switch". (This is actually how it's implemented in software too - a software-based network switch is created for your container stack, and each container's virtual Ethernet interface is virtually attached to that switch.)
>
> Note that this method of connecting containers together still works even if you do expose services using `ports:` values. In other words, you can expose your MySQL server so that you're able to access it using a tool like MySQL Workbench, and you can even expose it on a different port, and other containers in the stack can still access MySQL directly using its native port number.
> 
> *Challenge:* Try building a WordPress blog container, using MySQL as your database. If you configure it similar to this example, you can simply tell WordPress that the database server's address is "mysql".
>
> Final note: This is not limited to database containers - it works with *any* service running in your Compose stack. For example, if you run an S3 server in a container in your stack, you can access that S3 server from other containers using its name, for example `http://s3server`. 
