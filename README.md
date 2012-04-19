# Engine Yard Configuration

Ruby interface to additional services for customers of Engine Yard.

## Synopsis

    EY::Config.get(:shared_db_r_us, "db_hostname")

This will read the value for the `db_hostname` variable, as provided by the `shared_db_r_us` service.

In local development mode, you won't have access to the service, so you'll want to use `ey_config_local` command-line tool to write out a file at "config/ey_services_config_local.yml".
It's OK to commit this file to your repository.  It will be used as a fallback in production in case you haven't activated the `shared_db_r_us` for a given environment.

See the **Code Snippet** documentation for individual services to see what variables they provide, and common usages.

## How it works

When you deploy your app on Engine Yard cloud, the deployment system (https://github.com/engineyard/engineyard-serverside) will write out the file "config/ey_services_config_deploy.yml".
This file contains all the variables provided to your app, grouped by the Add-ons you have activated.

`EY::Config.get` will read variables from this file, or fallback to "config/ey_services_config_local.yml", which you should create for running your app in development mode.

That's it!

## Contributing to EY::Config
 
* Check out the latest revision from the master branch
* Check out the [issue tracker](https://github.com/engineyard/ey_config/issues) to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Send a pull request for your branch
* Please add tests for any new code

## Releasing

    gem install gem-release
    gem bump --tag
    gem release


## Copyright

Copyright (c) 2011, 2012 Engine Yard, Inc. See LICENSE.txt for
further details.

