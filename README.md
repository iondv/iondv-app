# iondv-app
IONDV. Framework apps installer

Install in one command:

```
bash <(curl -sL https://raw.githubusercontent.com/iondv/iondv-app/master/iondv-app) \
      -q -i -m localhost:27017 develop-and-test
```

Where the parameters for the iondv-app are the following: `localhost: 27017` is the MongoDB address, and `develop-and-test` is the app name.

Usage:
```
iondv-app [OPTION]... IONDV_APP_NAME|IONDV_APP_NAME@VERSION|GIT_URL
   Install IONDV. Framework application to current dirrectory and create docker image.
   Options:
   Build app method options:
    -t [value]                   git: use git clone (by default)
                                 docker:  without specific software on host mashine, only docker image
   Universal options
     -c [value]                  start cluster with [value] count
?     -m [value]                  mongo uri, for example: mongodb:27017. localhost:27017 - by default
     -r                          remove app workspace folder, if it exists
     -i                          data import
     -a                          acl (role and user) import
     -y                          yes to all
     -q                          quiet mode. Show only major information and warnings
     -l [value]                  mongodb docker name to link the app with docker container
                                 (with -d option or docker method)
                                 also set mongo uri value to [value]:27017
     -p [value]                  workspace path, where will create app's folder or will create app's dockerfile
     -s [value]                  full path to the script, run after installing and before building the app
     -n [value]                  new app namespace and name
     -h                          skip checkout to version in tag. Use default (last) version
   Options for git, zip, npm method:
     -d                          stop, remove runnig app docker container and image,
                                 build for local deploy (git build method)
     -k                          skip environment check
   Options for docker method (ci):'
     -v                          save provisional docker image as a template version, for example registry:3.0.0
                                 (to create cached version of components
   Environment:
   IONDVUrlGitFramework          URL to get framework by default is https://github.com/iondv/framework.git
                                 You can also set login and password to use in private repositry, for example
                                 https://login:password@git.company-name.com/iondv/framework.git
  IONDVUrlGitModules             Base of URL to get modules, by default https://github.com/iondv
  IONDVUrlGitApp                 Base of URL to get app, by default https://github.com/iondv
  IONDVUrlGitExtApp              Base of URL to get app extension, by default https://github.com/iondv
```

Example build app `develop-and-test` only in docker and start with docker mongodb link
```
./iondv-app -t docker -l mongodb -y -i  develop-and-test
```

Example: Install app with link to git and mongo uri'
```
./iondv-app -m localhost:27017 https://github.com/akumidv/svyaz-info.git
```
