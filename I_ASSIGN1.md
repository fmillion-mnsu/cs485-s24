# Individual Activity 1 - Making a Dev Container

This activity will give you the chance to create your own Dev Container.

## Steps:

1. Inside of **WSL**, make a new directory for your project. You can call it whatever you like, but a name with no spaces and only alpanumeric characters and the `_` character is advisable.

    If you are using MacOS, then you can do this directly on your system, but *please do use the command line as directed in these instructions*.

    > **Hint:** The Linux command for creating directories is `mkdir`.

2. `cd` into your new directory, then run `code` to open it in Visual Studio Code. VS Code should open up on your desktop.

3. Use `Ctrl+Shift+P` to bring up the Command Palette, and type `dev con` which should be enough to show you the Dev Containers options. Choose "Add Dev Container Config Files".

4. Make appropriate selections for developing a NodeJS application. Select to store the container files in the *workspace* so that you are able to see the `.devcontainer/devcontainer.json` file in your source tree.

    Don't worry about adding any features - unless you want to add `cowsay` for a little fun. 

5. Now, use the command palette to run the "Reopen in Container" option. 
   
    > **Hint:** You don't need to choose Rebuild and Reopen at this stage since you have not yet built the container to begin with. Later, you can use Rebuild and Reopen to force Docker to rebuild your container image after you make changes to the dev container files.

6. If all went well you should now be inside your dev container. Use `` Shift+Ctrl+\` `` to open a new terminal in VS Code.

    > **Hint:** You can't just open a standard terminal and expect things to work now. Tooling has been installed into the *container*, but not into WSL itself or into your host system. 

6. Use the command `yarn create react-app <your-name-lowercased>` to create a React application. You won't need to actually do any React coding, but this will give you an application you can run for experimentation purposes.

7. `cd` into the directory with your name, and try running the React application:

        yarn start

    > **Hint:** You  can also choose to use `npm` if you prefer. It's OK either way.

8. Assuming all went well, you should now be able to access the application by opening a browser on your *host* system and accessing `http://localhost:3000` - in fact, in certain cases it might even have opened the browser for you!

    But we're not quite done. We're going to make a few optimizations to the dev container now.

9. Let's create a post-start script that runs an `yarn install` to ensure that the container automatically makes sure the application dev environment is ready. At the *root* of the project (not inside the folder with the React application), create a file named `poststart.sh`. You can create the file with VS Code.

10. In the file, add the following script:

        #!/bin/bash
        
        cd $WORKSPACE/<your-name-lowercased>
        
        yarn install

11. After saving the file, from your **command prompt**, run this command:

        chmod +x poststart.sh

    You've seen this before now - it makes sure that the command itself can be executed by the container!

12. We now need to *edit* the file `.devcontainer/devcontainer.json`. This file is in the JSON format, which is similar to (but *not exactly like*) Python dictionaries and lists in syntax. One notable difference is that strings are *always* surrounded by double quotes, whereas Python allows single quotes if you prefer. (Some JSON parsers will allow single-quotes, but it is not standard.)

    Take a look in the `devcontainer.json` file. You should see a commented-out line starting with `"postCreate Command"`. First, *uncomment* this line, then *change* `postCreateCommand` to `postStartCommand`.

    > **Hint:** A post *create* command runs only one time - when the container is built. A post *start* command runs *every time* you start the container - i.e. every time you restart VS Code.

    Change the value of this key to be `./poststart.sh`.

13. Before proceeding, let's make sure this actually works. Fully delete the `node_modules` folder inside of your React project folder (the one with your name).

14. Now we will *rebuild* the container - using the command palette, issue the Rebuild container command. 

15. Once the container comes back up, try bringing up a terminal, `cd`'ing into your React project and starting it. See if you can still access the project.

    If so, great work!

## Submission

Submit your `devcontainer.json` and your `poststart.sh` files to the D2L dropbox. You can submit them individually or you can zip the two files up - your choice.

Assignment is due Tuesday April 2nd at 3:59 PM (right before class).
