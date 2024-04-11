# Individual Activity 2 - Round Robin Containers

In this activity you'll use Traefik to build a set of containers which are accessed in a *round-robin* fashion. 

> In this context, **round-robin** means that each request to the website will be directed to one of the containers in a *sequential* order, not a random order.

## Instructions

1. Make a directory for your assignment.

2. Download and use the `traefik.yaml` file in the [i_assign2](i_assign2/) directory in this repo as your Traefik configuration file. Start a `compose.yaml` file that includes a Traefik container with the `traefik.yaml` file as the configuration.

> **Hint:** Refer to previous assignments or group projects. You need to map the `traefik.yaml` file into the container at a known location, then set a `command:` option in your service with the string `--configFile=<path_of_traefikyaml_inside_the_container>` (replacing the text in the `<` and `>` appropriately).
>
> The `traefik.yaml` file is set to store logs at `/data/logs`. If you want to put things somewhere else make sure you also edit the `traefik.yaml` file.

3. Create *at least* three very simple HTML files in your project directory. You can call them anything you like. For example, `server0.html, server1.html, ...`, `harrypotter.html, hermionegranger.html, ...`, `j1.html, j2.html, ...` are all OK, or you can come up with your own names. You may also make more than three files if you wish, but three is the requirement.

> **Hint:** The HTML files do not need to be complex at all - they're just going to be used to indicate which server you're actually accessing. Here's a template for a very simple file. However, you're free to have fun with design if you like.
>
>     <html>
>       <head>
>         <title>Server 0</title>
>       </head>
>       <body>
>         <h1>Hi, I'm server0!</h1>
>       </body>
>     </html>

4. For each HTML file you created, **add an `nginx` service to your `compose.yaml` file**. You need only to map each HTML file to the static location `/usr/share/nginx/html/index.html` inside each service container. For example:

        server0:
          ...
          volumes:
            - ./server0.html:/usr/share/nginx/html/index.html:ro
          ...

    For each container, also add the appropriate Traefik rules as follows:

        ...
        labels:
          - traefik.http.routers.assign2.rule=Host(`assign2.localtest.me`)
          - traefik.http.services.assign2.loadbalancer.server.port=80
        ...
    
    > **Hint:** Remember that using labels this way actually sets Traefik configuration values associated with the container. 

    > *Theory*
    >
    > Every service that Traefik is going to make available needs to have both a *router* and a *service*. 
    >
    > In Traefik, a *router* is used to determine *which* incoming Web requests should be directed to a given service. A router's configuration, at a minimum, consists of a rule and a destination service.
    >
    > A *service* represents an actual web server that requests can be directed to. If you were to manually configure a service (as we did when we demonstrated accessing the MSU Website via a reverse proxy with Traefik), you would manually specify the destination URL for the service. However, Traefik is able to automatically fill in the correct internal Docker URL for each service on its own thanks to its Docker integration.
    >
    > Traefik has a sort of "magic fill-in-the-blanks" strategy where any missing values needed are inferred from the values given. There are two ways this is important for us:
    >
    > * If you do not provide any configuration for either router or service, Traefik will infer a router and service for your container - but it probably won't work, since there will be no rule attached to the router. Each router needs to have a name; by specifying any router rule (like the one above) you not only add that configuration option to the container but you also simultaneously assign a name to the router. In this case, `assign2` now becomes the name of the router, and all other router configurations for this service that Traefik infers are applied to the same router. The same applies to services.
    > * If multiple service containers exist that all define the same router and service (with the same names) with the same rules, Traefik infers a round-robin load balancer. This means that all you need to do to load-balance multiple services is make sure each Docker container has the same router rules!

5. Start up your container stack and visit <http://assign2.localtest.me> in your browser. 

6. Do a force reload (Shift+F5 or hold down Shift while clicking Refresh). If you have set things up correctly, you should now see a *different* one of your web pages.

> **Hint:** A simple reload will likely not work due to browser and server side caching.

## Submission

Your submission should include:

* Your `compose.yaml` file.
* Your three (or more) HTML files.

This assignment will be due Thursday April 18th at 3:59 PM (right before class).
