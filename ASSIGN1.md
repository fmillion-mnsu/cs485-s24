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

Now we'll take it up yet another notch and work with an application that needs more than one server running - in this case, a database server. Many web applications need a database, and many are also two-piece applications with both a separate frontend and backend. Additionally, some applications might need even more services in testing or development modes, such as an S3 file server.

We're going to start with a simple Python web application that renders its own web pages - no frontend/backend here. This will illustrate how to setup a container that can run multiple services at once.

1. **After copying the Dockerfile you made in Part 2 elsewhere for submission** (call it `Dockerfile.a1-p2`), run `git reset --hard` followed by `git clean -fdx` in your repository to clean out anything you've done. **This deletes ALL files that have changed since you checked out the repository, so again, FIRST COPY THE DOCKERFILE unless you really are interested in doing Part 2 all over again!**

2. Checkout the `part3` branch (`git checkout part3`).

3. For Python, there is no "compiling" to do, so this won't be a multi-stage build like last time. We'll just start with a Python container.

    > **Tip:** From here on out, you won't be getting the exact Dockerfile commands, except for when they're new ones you haven't seen yet!

4. Add a Dockerfile step to copy in the source files to the `/src/` directory in the container. Remember to set your WORKing DIRectory afterwards!

5. It is a Python convention to store the list of program library requirements in a file called `requirements.txt`. To install these packages into the container, you run the command `pip install -r requirements.txt`. Add a step to run this command.

6. Now, we need to install a piece of software into our container so that we can run multiple programs at once. Normally, a container starts up and runs a single program - so we need a program that starts up other programs.

    In UNIX world (including Linux and MacOS), nearly all systems have some sort of an `init` process that is responsible for starting up system services. The first thing your computer does after booting the operating system kernel is to start the `init` process, which takes over and handles everything else from there. The `init` process will start up all of the services needed on your system - networking, display drivers, etc. - and will also do things like check drives for errors if needed, startup background services like the GUI engine, and so on.

    A container is similar. It starts up some sort of "`init`-like" process - but in many cases, that process is simply the program that you want to run, like a Python script (part 1) or a web server (part 2). However, what if we had a sort of "mini-`init`" that could do *some* of the things that our big-daddy `init` does within a container?

    Such a program does exist, and it's known as `supervisor`. (There are others, like `s6-rc`, but `supervisor` is simpler and more straightforward so it's the one we'll use.) You may notice that in the project repository, there is a file called `supervisord.conf` - this is a configuration file that will run two things: the MySQL database server, and the Python web application. You configure your container to run the `supervisor` program, and it takes care of running all of the other programs it's configured to run.

    > **Tip:** Within program orchestrators like `supervisor`, as well as larger system-wide `init` programs like `systemd` or `OpenRC`, there is a concept of a "service", which simply means "a program you want to run". Each service can specify things about itself - like if it depends on other services working to work, or if it is a program that should be executed a single time before another program. In this setup, the database server will start, and only once the database server starts successfully will the Python web application start. 
    
    To be able to use `supervisor` we need to install it. The image we are using for `python` is actually based on Debian Linux. Here are the commands you need to add to your Dockerfile to install the `supervisor` program:

        ENV DEBIAN_FRONTEND=noninteractive
        RUN apt update && apt -y install supervisor

    > **Tip:** The first new command here, `ENV`, sets an **environment variable** in the container (and all future container build steps and, indeed in the finished container as well.) We will discuss environment variables more in Part 4.
    >
    > The `apt update` command first downloads the software package database from Debian's servers. The Docker image does not contain this database to save space, so we manually download it here. 
    >
    > The `&&` is a shell script function that says "if the previous command succeeds, run the next command; if the previous command fails, don't run the next command." 
    >
    > The `apt -y install` command actually instructs the Debian image to install the `supervisor` program. The `-y` switch tells `apt` not to prompt us for confirmation - normally, the `apt` program shows you all of the packages that will be installed and their size, and waits for you to confirm the operation. In an automated build process we do not want anything pausing to wait for user interaction, so `-y` tells `apt` to assume we accept the changes.

7. Now we have `supervisor` installed, but we also need a MySQL database server. We will install the modern variant of MySQL known as `mariadb`. 

    > **Tip:** There is a long history of contention with the MySQL database engine, its licensing and its ownership by Oracle, makers of the popular Oracle database. MariaDB is a "fork" of the last non-Oracle MySQL distribution which has been maintained and updated since then; since Oracle now owns the name "MySQL" this fork needed to change its name. However, MariaDB is completely compatible with MySQL at both a protocol and command level, so we can use it for our project.

    Insert an appropriate `apt -y install` command into your Dockerfile that installs `mariadb-server`.

8. Now we need to add a step to actually execute the database seed script. Add these two RUN commands:

        RUN chmod +x /src/*.sh
        RUN /src/dbsetup.sh

    > **Tip:** The first `RUN` command uses the `chmod` command to ensure that the `dbsetup.sh` script (and the other script, `mysqld.sh`, which handles starting up MySQL) has permission to execute. If you're on a Mac, this should not be a problem, but since Windows uses a different permission model than Linux, it's possible that your clone of the repository doesn't have its permissions set right. Running this command inside the container ensures that the script in the container can execute. 
    >
    > The second `RUN` step simply runs the script.

9. We're almost there! Now, we need to tell Docker that we want to start `supervisor` when the container starts. Add a final step in your Dockerfile that instructs the container to run the command `supervisord -c /src/supervisord.conf`. 

    The `supervisord.conf` file has been set up for you so that both the MySQL database and the Python web server will start up for you. 

10. Go ahead and try building your container! Call it `a1-p3` for convenience.

11. If all goes well, try running the container. The web server is listening on port **5000** (not port 80 as before). Run a command similar to the one you used in Part 2 to try running the web server, and then access the server with a connection to localhost in your browser.

    If you see the listing on the webpage, you have successfully completed Part 3! Copy your Dockerfile to your submission folder and get ready for the final exercise, where we will introduce how to use environment variables to configure containers and how *you* can implement this in your own container!

12. Remember to stop your container!

### Part 4: Configuring Containers and Multi-Service Containers

We know how to build container images and how to run multiple services inside of one container. Now, we'll take one final step for this exercise and introduce configurable containers. 

The most common method for offering configurable options in a container is to use environment variables. Environment variables are a simple key-value store that is associated with every running program on your system. Programs typically inherit the environment of the program that started them - if you run a program in your terminal, the program that you run has the same environment as the shell itself. 

Containers are a bit of an exception. Since containers run within their own **namespace** (this is what allows them to provide the isolation capability they have), the environment does not automatically carry over from your terminal when you start a container. However, the flipside of this is that we can actually use the environment variable key-value store ourselves to feed external data into the container!

#### Part 4a: Environment Variables

In part 4a, we'll just build a very simple container that prints out its environment, and then we'll look at how you can set environment variables when you run a container. We'll also introduce Docker Compose in a bit more detail, in particular how you can use it to specify nearly all of the options you normally specify on the Docker command line (such as the ports, container name and so on). Docker Compose lets us store the container's settings as a configuration file - this file can be shared with your project or provided to end users to help them get started!

For part 4a:

1. Checkout the `part4a` branch. This branch contains just a single shell script calld `env.sh`. This script does one thing - it prints out the entire environment variable key-value store. 

    > **Tip:** Environment variable names are, by convention, all uppercase - for example, `SERVER_PORT` or `USERNAME`. 

2. Create a Dockerfile that simply copies the script into the container and runs it when the container starts. 
 
    > **Tip:** You can copy the script to anywhere you want. Just make sure that when you run the script in your `CMD` instruction that you use the full path of the script.
    >
    > You can keep things simple by just copying the script to `/` and then running it with `/env.sh`.

    > **Tip:** If the script fails to run, one thing to try is adding a `chmod` command like we did in Part 3 for the script.

1. Build your container - for your sanity, just call it `a1-p4a`.

2. Run the container. This is a foreground process, so use `-it` instead of `-d` so you can view the output. 

3. Compare this with your typical environment variable store:

    * **Windows, if using PowerShell** (you'll see a `PS` at the beginning of your command prompt): `Get-ChildItem env:`
    * **Windows, if you're using the classic command shell (`cmd.exe`)**: `set`
    * **Mac or Linux**: `env`
  
    Your host system likely has a *lot* more environment variables set than your container does!

4. Now, try running the container again, but this time we'll set an environment variable in the container. Use the same command, but after the `-it`, add this: `-e USERNAME=<your_first_name>`. 

    You should see a new variable in the output with the value you provided!

    You can provide as many `-e` options to Docker as you want. Some complex applications may need dozens of these to be fully configured.

    > **Tip:** A common design pattern is to have a script inside the container that reads the environment variables and prepares an appropriate configuration file or makes modifications to an existing one in-place. Environment variables are typically used when a handful of settings need to be modifiable by the user.
    >
    > For very complex configuration scenarios, it's more common to simply *mount* a configuration file into the container. Mounting directories and files into a container is something we're also going to look at shortly.

You do not have to submit your Dockerfile for this step.

### Part 4b: The Super Mega Ultimate Ultra Big Project

Let's bring it all together! We're going to build a container that:

* runs *three* services at once - a database, a Python *backend*, and an Nginx frontend.
* allows you to configure things about the container - some of which you *must* do in order to make it work
* allows you to *persist* the container's data outside the container - so even if you delete and re-create the container, the data will remain intact
* paves the way for our next topic of Dev Containers!

***Ready?*** Ok, let's go.

1. (Remember to FIRST copy out your Dockerfile from Part 4a.) Clean the repository with `git reset --hard` and `git clean -fdx`. Then checkout the `part4b` branch. This branch is built off of the `part3` branch but adds a lot of other stuff. 

2. Using the knowledge you gained in part 2, create a build stage and build the Node frontend application. It's located in the `frontend` directory.

    > **Hint:** You can accomplish this in a few ways. As just one example, you can copy the entire source tree in as usual, but then use `/src/frontend` as your working directory for both building and later copying the application out of the build container.

3. Using the knowledge you gained in part 3, create another build stage called `runtime`. For this application, we'll use a `python` image as our base. We will manually install a database server, a web server and `supervisor` into the container in a moment.

    Copy the Python backend source code into the `/app` directory. Copy **only** the Python application in `backend/` into the container. **Do NOT copy the frontend source code into the container!** It is *very* important that you copy the backend application directly into `/app` - not into `/app/backend` or `/src` or anywhere else. Fail to heed this warning and the other scripts in this container won't work!

    > **Tip:** If you specify a directory to copy and a destination directory on the `COPY` command, the *files* in the directory on the host are copied into the directory in the container. Note that this is different from copying the *directory* into the container!
    >
    > For example: `COPY application/ /app/` will copy all of the *files* in the `application` directory into `/app/` within the container. If there is a file in the source tree called `application/config.json`, that file will appear in the container at `/app/config.json`. 
    >
    > Of critical note is that the file does *not* end up at `/app/application/config.json`!
    >
    > If you do have a need for the files to end up at `/app/application` in this example, simply include `application` in the target: `COPY application/ /app/application/`.


4. After setting an appropriate working directory, add a step to run `pip install -r requirements` to install the backend server requirements.

5. Add a step to set the environment variable `DEBIAN_FRONTEND=noninteractive`. You can copy it from your part 3 Dockerfile.

1. Add a step that uses the `apt` command to install the following packages. You can install all of the packages at once by including them all on the same `install` command:

    * `mariadb-server`
    * `nginx`
    * `supervisor`

    > **Hint:** Remember to run `apt -y update` first to make sure all of the package databases are downloaded to the container.

6. Add a step to copy the file `nginx.conf` into the container to the exact path `/etc/nginx/nginx.conf`. Use a `COPY` command.

    > This `nginx.conf` config file is complete and is designed to cause the web server to listen on port 80 and to serve files from `/usr/share/nginx/html`, just like in part 2. 
   
7. Copy the `build` folder from the frontend build container to the path `/usr/share/nginx/html` in the runtime container. Look back to part 2 for hints!

8. Copy the `mysqld.sh` script and the `script.sql` file to the directory `/app/` on the server. Add a `chmod` command to make sure the `mysqld.sh` script has permissions to execute. (Refer to part 3 for hints!)

9.  There is a Python script called `setupEnv.py` in the project root. Add a step to copy this file to `/app/` inside the container.

    This command will create a JavaScript source file that contains all of the environment variables at the time in a format usable by Web applications. 

    You need to put the `setupEnv.py` in `/app/` because some of the other built-in scripts expect the script to be there.

10. Add a step to copy the file `supervisord.conf` into the `/app/` directory.

11. We are going to add one more `RUN` command which I will give you: `RUN mkdir /data`.

    The reason for running this command is to ensure that a directory called `/data` exists inside the container.

    The `supervisor` program's configuration file indicates that it should write log files for all of the services into the `/data` directory. If this directory doesn't exist, the supervisor program will fail to start, and the container won't work.

    You'll see why we're doing this shortly.

12. Finally, add a `CMD` command to run the `supervisor` program:

        CMD /usr/bin/supervisord -c /app/supervisord.conf

13. That's it! Now, try to build your container. Name it `a1-p4b`. 

14. If you've made it this far with no errors - congratulations! This Dockerfile is actually quite complex and uses many of the most common functions used in Dockerfiles. 

Now, we're going to explore how we *run* this container. It's a bit different than before.

First of all, remember that this container is exposing *two* services that need to be accessible from the outside - the frontend Web application, and the backend API. 

> **Important!**
>
> The backend API listens on port `5000` inside the container.
>
> The frontend Web application (`nginx`) listens on port `80` inside the container.

You therefore need to expose *two* ports using the `-p` option when you run the container. You can specify multiple `-p` options to map multiple ports. 

For example, we could run the container this way (DON'T actually do this yet - we have more to cover!):

    docker run -d --name a1 -p 8000:80 -p 8001:3000 a1-p4b

This example would run the container with the main Web frontend listening on your host's port 8000, and the API listening on port 8001.

There's a problem though. Anytime a frontend application needs to communicate with a backend API, it needs to know how to contact that API. The API could be *anywhere*! 

Luckily, we can use Environment Variables to allow the path to be configured with the container itself. The major advantage we have here is that the container can be re-used anywhere, and all that needs to change is the API access path!

To make this work, we need to set an environment variable. Recall how we do this from part 4a using the `-e` switch. We need to set *one* environment variable, like this:

    -e REACT_APP_API_URL=http://localhost:8001/api/v1/

**Now before you go and just copy/paste that line, read this!** This example assumes that **you have made 8001 the port that the API is mapped to on your host** - i.e. `-p 8001:5000`. If you chose a different host port, you need to *change* the `8001` in that URL to the correct port!!

Finally we arrive at our final command line. For example:

    docker run -d --name a1 -p 8000:80 -p 8001:5000 -e REACT_APP_API_URL=http://localhost:8001/api/v1/ a1-p4b

Run this command and then access <http://localhost:8000> in your browser. If everything worked, you should not only see the same type of index you saw in part 3, but you should *also* now be able to interact with it in several ways. Experiment and play around with the app!

As part of your submission, please add *three* "projects" to the website and scroll to the bottom to show your projects, and take a **screenshot** of this. 

For Part 4b, you need your completed Dockerfile. Copy it off to your submission. You also need the screenshot just mentioned above.

### Part 4c: Persisting Data and Compose Files

This container can be kinda fun, but what happens if we restart it? What if we need to remove it (say that the original container got updated)? Remember that anything happening inside a container...stays inside the container. *With one major exception*: mapped volumes.

Docker has two strategies for *persisting* data across container runs. With persistent volumes, you can cause a directory on your host computer to appear inside the container (at any directory you choose - it doesn't have to be the same path!). Many containers will document exactly where the application running in the container stores its data - this is so that you can choose to map a persistent volume to that path. Once you've done that, you can delete, update, rebuild and otherwise mess with the container all you want - as long as you map that same persistent volume to the same path, the data your application generates will remain safe on disk even when the container is deleted.

One of Docker's two strategies is to use **named volumes** - these are directories managed by Docker and given a simple name, very much like containers or images themselves. Another strategy is to simply map a given literal directory on your host to a path inside the container. We'll use the second strategy for this exercise to keep things simple.

Let's imagine you are reading the documentation for your super awesome container and you see:

> This container puts the database in the path `/var/lib/mysql` and log files in the path `/data`.

Great! Now we know *where* to put the directories. But what directories should we put there? That's the best part - it can be *any* directory on the host (with some obvious limitations)! 

For the sake of convenience, I've designed the path `user/` in the source tree as ignored, so neither Docker Build nor Git will touch it. You can therefore use this directory - and any directories within it - for this exercise.

I'm going to give you the command to do this at the command prompt - but we're not going to actually use this strategy for at least one good reason. Here is how you might do it:

    docker run -it --rm -v "C:\users\fmillion\Documents\projects\CS485\user\database\:/var/lib/mysql" -v "C:\users\fmillion\Documents\projects\CS485\user\logs\:/data" ...

Does that look like fun? I didn't think so. So this is also a great time for you to build a brand new Docker Compose file for your app!

Docker Compose files are written in the YAML format. YAML as a format is beyond the scope of this immediate discussion, so you can just follow along with the template here.

Copy and paste the following into a file called `compose.yml` in your source code tree's root:

    version: '3'

    services:
      a1:
        build:
          context: .
        environment:
          - "REACT_APP_API_URL=http://localhost:8001/api/v1/"
        volumes:
          - ./user/database:/var/lib/mysql
          - ./user/logs:/data
        ports:
          - 8000:80
          - 8001:5000
        container_name: a1
        
If you look at this file carefully, you'll see a lot of things you've already seen at the command prompt - but now they're stored in a configuration file. I've set up this compose file to match the example from the end of part 4b.

Once you have this file in the source tree, the command `docker compose up -d` should start up your container. Notice how you didn't have to specify any of those ugly command line switches from before!

**For part 4c, you will** ***change*** **the port number for the API,** ***and*** **update the URL in the environment variable accordingly.** Pick a four-digit port number and make the appropriate change in the `compose.yml` file. Then use `docker compose up -d` again to restart the container and see if your change was successful - i.e. the app still functions correctly.

Your *overall* submission for part 4C will include:

* the `compose.yml` file you have with the modified port, *and*
* a zipped copy of the `user` directory after starting the container. You should see two directories within - `database` and `logs` (if you used the example) - zip up the entire `user` folder including the two directories.

## Final Submission Checklist

Whew! We accomplished a *lot* in this activity! Here is the final list of what you must submit for your final submission for Activity 1:

* Your `hello.py` file from part 1
* The Dockerfile you made in part 1 - name it `Dockerfile.a1-p1`.
* The Dockerfile you made in part 2 - name it `Dockerfile.a1-p2`.
* The Dockerfile you made in part 3 - name it `Dockerfile.a1-p3`.
* The Dockerfile you made in part 4b - name it `Dockerfile.a1-p4b`.
* One screenshot showing three new CS "projects" added to the list in the web application. (This proves you got the app working properly!)
* The `compose.yml` file you made in part 4c, after changing the port number for the API as necessary. You can leave the file named `compose.yml`.
* A zip file (preferably called `user.zip`) which is a copy of the contents of the `user/` folder within the project after running the example `compose` file but *after* changing the port number. 

Please collect all of the above and **zip the files together into a single file for submission** (yes, even the zip file - a zip in a zip is fine!). Submit your final work to the D2L dropbox for Group Activity 1.

## Questions?

If you have questions or are completely stuck, please feel free to reach out to me. However, before you do, I strongly encourage you to use the various documentation available to you for building and maintaining Dockerfiles and Compose files. While some of the documentation may seem a bit daunting and over-complex, remember that much of the reference documentation attempts to document *every* option available, not just the "easy" ones. Feel free to search around the Internet to find advice on how to accomplish tasks like the ones in this activity. 

**I have tried my best to include any information that is specific to this unique project**. However, I'm only human and I may have made an error. If you discover a glaring bug in these instructions, reach out to me with a well-written "bug report" explaining the issue and any solution(s) you may have identified. This may earn you some extra credit!
