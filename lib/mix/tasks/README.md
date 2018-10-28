# Tasks

# Moonbase

This is our application management app. The main components are:
## Distillery
This will package our phoenix appilication into a standalone runtime.
## Docker
Generate a docker file with requirements for our runtime.
## GCloud
A number of services are used, kubernetes, cloud build and storage of our prebuilt images of linux + erlang + deps
## Kubernetes
This will run hive in all enviroments.
## Build
Compile hive down to something we can use, ready for a use either in development, staging or production.
## Server
Watch app and compile on change, and perform tasks.

# Tucson
This is our vue intergration tooling. The main components are:
## Build
Compile our vue app down to something we can use.
## Server
Watch client app and compile on change.