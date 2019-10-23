[Русская версия](/README_RU.md)

# iondv-app
IONDV. Framework application installer from the code repository.

It installs, build and run the app from the git repository, from the zip archive (including downloaded from the visual constructor
[IONDV. Studio] (https://studio.iondv.com)) or from a folder with application files (the folder is copied, the files in the folder do not change).

### Environment requirements
By default, the build method in the docker container is used. Description of system preparation is given below in the 
[Prepare environment](#Prepare-environment) section.

The Mongo DB must be running for the system to work. In the docker container, you can run it with the command:
```
docker run --name mongodb -v mongodb_data:/data/db -p 27017:27017 -d mongo
```

### Installing, building, and running the application with one command in the docker container:
The assembly examples below imply that the DBMS is running in a container named mongodb.

The simpliest example is [nutrition-tickets](https://github.com/iondv/nutrition-tickets), the team downloads the installer
from the github repository, which collects and runs the application in the docker container in the current directory.

* from the git repository
```
bash <(curl -sL https://raw.githubusercontent.com/iondv/iondv-app/master/iondv-app) \
      -t docker -q -i -l mongodb develop-and-test
```
* from zip archive, for example received from github
`curl -L https://github.com/iondv/nutrition-tickets/archive/master.zip > ./nutrition-tickets.zip` or created in 
[IONDV. Studio](https://studio.iondv.com). Please note that in `package.json` of the created app in the
`"ionModulesDependencies"` attribute you need to specify a module to display data - usually it's `"registry"`.
```
bash <(curl -sL https://raw.githubusercontent.com/iondv/iondv-app/master/iondv-app) \
      -t docker -q -i -l mongodb ./nutrition-tickets.zip
```
* from a folder, while the original application folder is not modified. Please note that the name of the folder must correspond to the application namespace (if the folder is unpacked from the github archive, then the branch code is usually added in the name - you need to rename it).
```
bash <(curl -sL https://raw.githubusercontent.com/iondv/iondv-app/master/iondv-app) \
      -t docker -q -i -l mongodb ./nutrition-tickets
```

Default assembled application address is http://localhost:8888, user - `demo`, password `ion-demo`.

### Installing, building, and running the application on the local file system:
The assembly examples below imply that the DBMS is running locally and is available at localhost:27017.

Installation in the local file system allows you to get the application ready for modification and revision by the developer’s tools,
for example, in the IDE - just open the application folder. The application folder is created in the launch folder, or in the specified folder by the parameter `-p`.

* from the git repository in the `/workspace` folder
```
bash <(curl -sL https://raw.githubusercontent.com/iondv/iondv-app/master/iondv-app) \
  -t git -p /workspace -m localhost:27017 https://github.com/iondv/nutrition-tickets.git
```
* from zip archive, for example received from github 
`curl -L https://github.com/iondv/nutrition-tickets/archive/master.zip > ./nutrition-tickets.zip` or created in  
[IONDV. Studio](https://studio.iondv.com). Please note that in `package.json` of the created app in the
`"ionModulesDependencies"` attribute you need to specify a module to display data - usually it's `"registry"`

```
bash <(curl -sL https://raw.githubusercontent.com/iondv/iondv-app/master/iondv-app) \
  -t git -p /workspace -m localhost:27017 ./nutrition-tickets.zip
```

* from a folder, while the original application folder is not modified. Please note that the name of the folder must correspond to the application namespace (if the folder is unpacked from the github archive, then the branch code is usually added in the name - you need to rename it).
```
bash <(curl -sL https://raw.githubusercontent.com/iondv/iondv-app/master/iondv-app) \
      -t git -q -i -m localhost:27017 ./nutrition-tickets
```

## Run parameters
```
iondv-app [OPTION]... IONDV_APP_NAME|IONDV_APP_NAME@VERSION|GIT_URL|IONDV_APP_ZIP|IONDV_APP_PATH
   
Parameters:
   Application build type:
    -t [value]                   git: cloning repositories to the file system (requires git installed)
                                 docker:  assembly in docker containers, installation of the environment on the host machine is not required. Universal parameters for different types
     -c [value]                  launching the application as a cluster with the number of instances [value]
     -m [value]                  uri for Mongo DB, examples: mongodb:27017. localhost:27017 - by default (when building in
                                 in docker it will give an error connecting to the database (!). For docker use the -l parameter
     -r                          check and delete the folder with the application name in the assembly directory
     -i                          data import during application initialization
     -a                          Import roles and user accounts during application initialization
     -y                          apply all default values (yes to all)
     -q                          silent mode. Only basic information, warnings and errors are shown.
     -l [value]                  MongoDB container name for linking to the assembled container (docker assembly type
                                 or the -d option for git build type) also forms a configuration specifying
                                 mongo uri values as [value]: 27017
     -p [value]                  path to the directory where the folder with the name of the application will be created and
                                 assembled
     -s [value]                  full path to the script run in the application folder after assembly, but before the deploy of the
                                 application. It can be used for additional processing of application files.
     -n [value]                  parameters determining the change the application's namespace to a new one, before the                                          deploy
     -h                          skip switching to version of application dependencies, installation on latest versions
   Method Parameters for git:
     -d                          prepare a docker container based on the assembled version. Also stop and
                                 remove container, image with that name
     -k                          skip environment check
   Method Parameters for docker:'
     -v                          save intermediate versions of containers - allows to speed up subsequent assemblies. But
                                 caching is not worked if there is a flag to ignore dependency versions
   Environment variables:
   IONDVUrlGitFramework          URL to the repository with the framework, by default https://github.com/iondv/framework.git
                                 You can set the login and password for your version in a private repository. For example:
                                 https://login:password@git.company-name.com/iondv/framework.git
  IONDVUrlGitModules             URL to modules, by default https://github.com/iondv
  IONDVUrlGitApp                 URL to applications - used if only the application name is specified for the assembly,
                                 by default https://github.com/iondv
  IONDVUrlGitExtApp              URL to application-extension , by default https://github.com/iondv
```

## Prepare environment
### Docker installation

It is recommended not to do under root.

* Install latest version of docker for CentOS:
```
sudo yum -y install docker-ce docker-ce-cli containerd.io
```

* Install latest version of for Ubuntu:
```
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Add the current user to the docker group:
```
sudo groupadd docker
sudo usermod -aG docker $USER
```

You can check - `docker run hello-world`.

### Run Mongo in Docker

Run with mapping on the local port:
```
docker run --name mongodb -v mongodb_data:/data/db -p 27017:27017 -d mongo
```

### Node installation

To speed up the assembly, it is recommended that you locally download the docker image node:10, because it's 900Mb.

```
docker pull node:10
```

You can check - `docker images | grep node` - a list of local node images will be displayed
