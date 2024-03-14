# Group Activity 1

In this activity you will learn about creating your own Dockerfile for an application.

Creating Dockerfiles can range from very straightforward to very complex. Some Dockerfiles simply consist of copying the application into a container and setting the container to run that application. Others involve complex setup, compilation, configuration and maintenance tasks.

The first question to ask yourself when building a Dockerfile is "what do I need to do to get this program to run on a fresh, new system?" If you have **developer documentation** for how to get the environment for the program prepared, that's a great place to start!

## Requirements

In this exercise, you will start out with building a simple "Hello World" Dockerfile, and work up to building a multi-stage Dockerfile that runs multiple services. You will then separate out services into individual containers using Docker Compose and run the application as a "stack". You will learn about writing a simple Docker entrypoint script and how to do tasks like "seeding" a database with an SQL script and adjusting configuration within a container through environment variables.

### Part 1: Hello World Dockerfile

For this step, you will simply learn how to create a Dockerfile for your own very simple application - you will basically replicate the `hello-world` container we demonstrated on the first day of class. You can do this in any language you choose - this example will use Python.

1. Create a Python script that simply prints "Hello [your-team-members-names]." For example, `Hello Flint, Jonathan, Mansi, Rushit, Peg and Becky`. Name the script something obvious like `hello.py`. I strongly suggest creating a directory for this file as you'll be adding other files to the project going forward.

2. Search for Python on [Docker Hub](https://hub.docker.com/). You will discover that the main image for running Python programs is called `python` (duh). For this very simple exercise, any Python version will work, even the latest one. However, be aware that you can use *tags* to choose specific versions - for the Python image, you could use `python:3.11` to get version 3.11, `python:3.10` for 3.10 and so on. 

    > Tip: Tag values are decided by the author of the image - there is no standard, and tags can be any string not including spaces. It is common for the tag to include the version number, but might also include different build configurations or versions of the application. For example, the Python image has tags like `3.11-bookworm` and `3.11-bullseye`, which represent Python 3.11 but running on different versions of the Debian Linux operating system. There's also `3.11-alpine` which is running on a completely different type of Linux distribution known as Alpine Linux.
    >
    > There are many reasons why container developers might want to build different versions like this. You should always consult the documentation for any Docker image you are using before working with it - it should explain all of the available tags and what they mean, as well as other important information we'll be exploring later.

3. Now that you have your Python container image name and tag, you can start building your Dockerfile. Start with this very basic skeleton:

    `FROM python`

    > **Tip:** If you do not specify a tag, the tag `latest` is assumed - it is the default. `latest` almost always refers to the most recent stable release of the application on a default configuration. 

4. Save this file as `Dockerfile` (no extension) in the same directory you have your Python script.

5. Try building the Dockerfile at the command prompt by first using `cd` to get to the correct directory then typing `docker build -t a1-p1 .`

    > **Tip:** The `-t` switch tells Docker what you want to name your container image. In this case I named it `a1-p1` to represent "assignment 1, part 1". You can name the image anything you like.

6. If there were no errors, you just built a Docker image. Try running it!:

    `docker run -it --rm a1-p1`

    > **Hint:** The `-it` command line switch is actually two switches - `-i` which tells Docker you want to run this container interactively (as in you want to run it like a local terminal application) and `-t` means to allocate a virtual terminal. Virtual terminals are a bit outside the scope of this exercise but the simple explanation is that it "connects" your terminal to the terminal running in the container. If you don't do this, certain kinds of applications will either fail to run or will exhibit odd behavior.
    >
    > As a reminder, the `--rm` switch means to delete the container automatically after it's finished running. This saves you from having to name your container and delete it manually and is perfect for testing purposes like this.

    You'll find that you get dropped into a Python interpreter. Great work! However, this is a pretty redundant image because it's literally just a copy of the Python image! Let's add some files to it.

    (Type `exit()` to close the Python interpreter and stop the container.)

7. Add the following to the Dockerfile

    `COPY hello.py /script/`

    (Replace `hello.py` with whatever you named your Python script file.)

    Now rebuild the container using the same command.

8. Try to run your Docker container again using the command from step 6. You should get the same results. But now, you should be able to get your script to run. Try typing this at the Python command prompt:

    `exec(open("/script/hello.py").read())`

    You should see your code run. Type `exit()` to close the session.

    This is great, but who wants to type that out every time the container starts?

9. Add the following to the Dockerfile:

    `CMD ["python","/script/hello.py"]`

    Now rebuild and run your Dockerfile.

    That's better! Now the container automatically runs our script and exits.

Save this Dockerfile under the name `Dockerfile.part1` for your submission.

### Part 2: Doing Stuff During the Build Process

Simply copying in a script is great, but most applications need a lot more work to configure and get working. We're going to very quickly step it up a few notches!

1. Clone the repository at <https://github.com/fmillion-mnsu/cs485-a1>. 

2. This repository contains a very simple Hello World React web application. In the root of the repository folder, we're going to create a Dockerfile that builds the application and then *copies* it to another container to host it. We'll do this using a technique known as [multi-stage builds](https://docs.docker.com/build/building/multi-stage/).

    > Without going into too much detail, React applications are compiled to static JavaScript files that can be dropped onto any standard Web server, like `nginx` or `apache`. We'll be using `nginx` in this exercise because it's straightforward and easy to get things running.

3. React is built upon NodeJS, so we need a container that we can use to build NodeJS applications. We can simply use the container image `node` to do this.

    > **Tip:** A key point in multi-stage builds is that you use one container to build the application, then you copy the compiled application into *another* container to run it. This means that your final container does not need to contain the application source code, build tools, or any temporary files created during the build process. The final container needs only the application itself and any software it needs to run. This strategy keeps your final container image nice and clean!

    Let's get started:

    `FROM node AS build`

    The new addition to the `FROM` command - `AS <something>` - names this stage of the build process. We'll use this name later to copy the finished artifacts out of the container into the runtime container.

4. The first thing we need to do is copy the entire project into the container:

    `COPY . /src/`

    This will copy the entire program into the directory `/src` inside our build container.

5. Now we'll introduce a new command:

    `WORKDIR /src`

    The `WORKDIR` command is sort of like the `cd` command in your terminal - it sets the *working directory* for all future commands in the Dockerfile (or at least until another `WORKDIR` command is found). 

    > **Tip:** In Docker builds, each step runs within its own temporary container - yes, Docker uses containers itself to build containers! (In other words, it eats its own dog food. 🐕)
    >
    > The side effect of this is that we can't just run the `cd` command inside of a build container and have that new directory remain the current directory going forward in the build process. The default working directory for all build container steps is `/` (the root directory), so using `WORKDIR` tells Docker to first set the new directory as the current directory before each step going forward.

6. This application was built using the `yarn` package manager. You don't need to worry about learning React and `yarn` and NodeJS for this course, so here is the command you need to install all of the build dependencies:

    `RUN yarn install`

    This is the first time we've seen the `RUN` command - its job is to, well, run some command inside the build environment. 

7. Once the packages are installed, the next step is to actually build the React application. The command for that is `yarn build`. Add another `RUN` line to your Dockerfile to run this command.

8. React puts the finished build inside a directory called `build` within the source tree. This is the directory we want for our final image.

9. At this point, we've finished building our application. Now we need to setup another container to host it. This is where the beauty of multi-stage builds starts to come into play.

    Add this line to your Dockerfile:

    `FROM nginx:alpine AS runtime`

    Now we are in a new build context. Anything we do from here on out will occur in a fresh new container image based on the `nginx:alpine` image.

    > **Tip:** The `alpine` image for `nginx` is an optimized version running on Alpine Linux. The entire Alpine server, along with all of the components from Alpine Linux that it needs to run, is only around 8MB in size!

10. We now need to bring in the built application from our build container. We also need to know where to put it in the new container. If we read the [documentation for the nginx container image](https://hub.docker.com/_/nginx) on Docker Hub, we find that the image expects files for the application to be hosted to be placed in the path `/usr/share/nginx/html/`. So, let's do that - let's copy the files from the build container to the `nginx` container in the correct place.

    `COPY --from=build /src/build/ /usr/share/nginx/html/`

    This will copy all files in `/src/build/` in the `node` container to `/usr/share/nginx/html/` in the `nginx` container. Neat, huh? 

11. Since the `nginx` container already is configured in the other ways necessary, we are actually finished - save your Dockerfile and try building it! Make sure there are no obvious errors during the build process. Use the image name `a1-p2`.

12. Now, to run this image, we need to modify our `docker run` command a little. Since this image is running a network application, we need to map a *port* from our computer to a port inside the container.

    > **Tip:** This is one of the great things about Docker. Many applications are coded to listen on a specific port, and in some cases this can't even be changed through configuration. But by running an application in Docker, we have full control over which ports the application listens on. It means we can even run multiple instances of an application that only listens on on port, and force each instance of that application to listen on a different port.

    First, we need to know which port `nginx` listens on. Since `nginx` is a web server, this happens to be port `80`, the standard HTTP port. (`443` is even more common as it is the HTTPS secure port, but for this application we won't worry about that. More on this later in the course!)

    We also need to decide what port we want to actually listen on, for real. While you could just use port 80, this is actually not a good idea for local testing for many reasons. You can choose just about any port number greater than 1024 and less than 65534 (port numbers are 16-bit integers, and ports under 1024 by convention are reserved for system servers that require administrative access). However, some ports may present challenges for a wide variety of reasons (for example, Macs have a service listening on port 6000 while Windows does not - only one service can listen on one real port at a time). A relatively safe bet is port 3500, so you can try that one.

    To specify the port to listen on, and which port to map it to within the container, we use the `-p` option like this:

    `docker run --name a1-p2 -d --rm -p 3500:80 a1-p2`

    On the *left* side of the colon in the `-p` option, we provide the port we actually want to listen on for real. On the *right* side, we tell Docker which port *inside* the container the port we gave should map to. The final effect of this is that anyone connecting to port 3500 on our machine will be directed to something running in this container on port 80.

    > **Tip:** We also changed a few other things in this command. First, we swapped out `-it` for `-d`, which means *daemonize* the container - in other words, run it in the background. Most service containers run in this mode. Since we are running in the background, we also set a name for the container using `--name` so that we know the exact name of the container so we can manipulate it later. Otherwise, we'd have to look at `docker ps` to see the name that Docker auto-generated. 

    Run the above command.

13. Finally, visit <http://localhost:3500> to see if it all worked!

14. Stop your container with `docker stop a1-p2`. Since we specified `--rm`, the container will automatically delete once it's stopped.

Great work! 

### Part 3: Multiple Servers

**Note** The rest of this assignment will be available by *Friday, March 15th* at 11:59 PM. You will have until *Sunday, March 24th at 11:59 PM* to complete this in your groups.
