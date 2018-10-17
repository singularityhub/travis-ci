# Singularity Builders Travis-CI

![.travis/sregistry-travis.png](.travis/sregistry-travis.png)

[![Build Status](https://travis-ci.org/singularityhub/travis-ci.svg?branch=master)](https://travis-ci.org/singularityhub/travis-ci)

This is a simple example of how you can achieve:

 - version control of your recipes
 - versioning to include image hash *and* commit id
 - build of associated container and
 - push to a storage endpoint

for a reproducible build workflow.

**Why should this be managed via Github?**

Github, by way of easy integration with continuous integration, is an easy way
to have a workflow set up where multiple people can collaborate on a container recipe,
the recipe can be tested (with whatever testing you need), discussed in pull requests,
and then finally pushed to the registry. Importantly, you don't need to give your
entire team manager permissions to the registry. An encrypted credential that only
is accessible to administrators can do the push upon merge of a discussed change.

**Why should I use this instead of a service?**

You could use a remote builder, but if you do the build in a continuous integration
service you get complete control over it. This means everything from the version of
Singularity to use, to the tests that you run for your container. You have a lot more
freedom in the rate of building, and organization of your repository, because it's you
that writes the configuration.

## Quick Start

Add your Singularity recipes to this repository, and edit the build commands in
the [build.sh](.travis/build.sh) file. This is where you can specify endpoints 
(Singularity Registry, Dropbox, Google Storage, AWS) along with container names
(the uri) and tag. You can build as many recipes as you like, just add another line!

```yaml
                               # recipe relative to repository base
  - /bin/bash .travis/build.sh Singularity
  - /bin/bash .travis/build.sh --uri collection/container --tag tacos --cli google-storage Singularity
  - /bin/bash .travis/build.sh --uri collection/container --cli google-drive Singularity
  - /bin/bash .travis/build.sh --uri collection/container --cli globus Singularity
  - /bin/bash .travis/build.sh --uri collection/container --cli registry Singularity
```

For each client that you use, required environment variables (e.g., credentials to push,
or interact with the API) must be defined in the (encrypted) Travis environment. To
know what variables to define, along with usage for the various clients, see
the [client specific pages](https://singularityhub.github.io/sregistry-cli/clients)

## Detailed Started

### 0. Fork this repository

You can clone and tweak, but it's easiest likely to get started with our example
files and edit them as you need.

### 1. Get to Know Travis

We will be working with [Travis CI](https://www.travis-ci.org). You can see 
example builds for this [repository here](https://travis-ci.org/singularityhub/travis/builds).

 - Travis offers [cron jobs](https://docs.travis-ci.com/user/cron-jobs/) so you could schedule builds at some frequency.
 - Travis also offers [GPU Builders](https://circleci.com/docs/2.0/gpu/) if you want/need that sort of thing.
 - If you don't want to use the [sregistry](https://singularityhub.github.io/sregistry-cli) to push to Google Storage, Drive, Globus, Dropbox, or your personal Singularity Registry, travis will upload your artifacts directly to your [Amazon S3 bucket](https://docs.travis-ci.com/user/uploading-artifacts/).
 
### 2. Add your Recipe(s)

For the example here, we have a single recipe named "Singularity" that is provided 
as an input argument to the [build script](.travis/build.sh). You could add another 
recipe, and then of course call the build to happen more than once. 
The build script will name the image based on the recipe, and you of course
can change this up.

### 3. Configure Singularity

The basic steps to [setup](.travis/setup.sh) the build are the following:

 - Install Singularity from master branch. You could of course change the lines in [setup.sh](.travis/setup.sh) to use a specific tagged release, an older version, or development version.
 - Install the sregistry client, if needed. The [sregistry client](https://singularityhub.github.io/sregistry-cli) allows you to issue a command like "sregistry push ..." to upload a finished image to one of your cloud / storage endpoints. By default, this won't happen, and you will just build an image using the CI.

### 4. Configure the Build

The basic steps for the [build](.travis/build.sh) are the following:

 - Running build.sh with no inputs will default to a recipe called "Singularity" in the base of the repository. You can provide an argument to point to a different recipe path, always relative to the base of your repository.
 - If you want to define a particular unique resource identifier for a finished container (to be uploaded to your storage endpoint) you can do that with `--uri collection/container`. If you don't define one, a robot name will be generated.
 - You can add `--uri` to specify a custom name, and this can include the tag, OR you can specify `--tag` to go along with a name without one. It depends on which is easier for you.
 - If you add `--cli` then this is telling the build script that you have defined the [needed environment variables](https://docs.travis-ci.com/user/environment-variables/#Defining-Variables-in-Repository-Settings) for your [client of choice](https://singularityhub.github.io/sregistry-cli/clients) and you want successful builds to be pushed to your storage endpoint. Valid clients include:
    - google-storage
    - google-drive
    - dropbox
    - globus
    - registry (Singularity Registry)

See the [.travis.yml](.travis.yml) for examples of this build.sh command (commented out). If there is some cloud service that you'd like that is not provided, please [open an issue](https://www.github.com/singularityhub/sregistry-cli/issues).

### 5. Connect to CI

If you go to your [Travis Profile](https://travis-ci.org/profile) you can usually select a Github organization (or user) and then the repository, and then click the toggle button to activate it to build on commit --> push.

That's it for the basic setup! At this point, you will have a continuous integration service that will build your container from a recipe each time that you push. The next step is figuring out where you want to put the finished image(s), and we will walk through this in more detail.


## Storage!

Once the image is built, where can you put it? An easy answer is to use the 
[Singularity Global Client](https://singularityhub.github.io/sregistry-cli) and
 choose [one of the many clients](https://singularityhub.github.io/sregistry-cli/clients) 
to add a final step to push the image. You then use the same client to pull the
container from your host. Once you've decided which endpoints you want to push to,
you will need to:

 1. Save the credentials / other environment variables that your client needs (see the client settings page linked in the sregistry docs above) to your [repository settings](https://docs.travis-ci.com/user/environment-variables/#Defining-Variables-in-Repository-Settings) where they will be encrypted and in the environment.
 2. Add a line to your [.travis.yml](.travis.yml) to do an sregistry push action to the endpoint(s) of choice. We have provided some (commented out) examples to get you started. 

## Travis Provided Uploads
You don't even need to use sregistry to upload a container (or an artifact / result produced from running one via a cron job maybe?) to an endpoint of choice! There are [many](https://docs.travis-ci.com/user/deployment) places you can deploy to. If you can think of it, it's on this list. Here are a sampling of some that I've tried (and generally like):

 - [Surge.sh](https://docs.travis-ci.com/user/deployment/surge/) gives you a little web address for free to upload content. This means that if your container runs an analysis and generates a web report, you can push it here. Each time you run it, you can push again and update your webby thing. Cool! Here is an [old example](http://containers-ftw.surge.sh/) of how I did this - the table you see was produced by a container and then the generated report uploaded to surge.
 - [Amazon S3](https://docs.travis-ci.com/user/deployment/s3/) bread and butter of object storage. sregistry doesn't have a client for it (bad dinosaur!) so I'll direct you to Travis to help :)
 - [Github Pages](https://docs.travis-ci.com/user/deployment/pages/) I want to point you to github pages in the case that your container has documentation that should be pushed when built afresh.


## Advanced

Guess what, this setup is totally changeable by you, it's your build! This means you can do any of the following "advanced" options:

 - This setup can work as an analysis node as well! Try setting up a [cron job](https://docs.travis-ci.com/user/cron-jobs/) to build a container that processes some information feed, and you have a regularly scheduled task.
 - try out one of the [GPU builders](https://circleci.com/docs/2.0/gpu/)
 - run builds in parallel and test different building environments. You could try building the "same" container across different machine types and see if you really do get the same thing :)
 - You can also do other sanity checks like testing if the container runs as you would expect, etc.
