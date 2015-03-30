<<<<<<< HEAD
# MiniMart

MiniMart is a RubyGem that makes it simple to build a repository of Chef cookbooks using only static files.

Minimart is made up of two main components:

* A mirroring tool that will download any cookbooks described in an inventory file.

* A web tool that will generate a Berkshelf compatible index of the cookbooks in your inventory, and a user friendly web interface for browsing cookbooks.

## Installing Minimart

Add this line to your application's Gemfile:

```ruby
gem 'minimart'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minimart

## Basic Usage

### Getting Started

After installing the `minimart` gem, you can start a new MiniMart by running the following command:

    $ minimart init

### Mirroring Cookbooks

The `init` command will generate a sample `inventory.yml` file for you to use as a reference when building your own inventory. A real inventory may look like the following:

    sources:
      - "https://supermarket.chef.io"
    cookbooks:
      apache2:
        versions:
          - '= 3.0.0'
          - '= 2.0.0'
      nginx:
        version: "~> 2.7.0"
        git:
          location: "https://github.com/miketheman/nginx.git"
          tags:
            - 'v2.6.0'
            - 'v2.5.0'

This file allows you to specify multiple sources to fetch cookbooks from (in order of precedence). You can also specify multiple versions of the same cookbook, either from one of the sources, using Git, or a local path. All of the `version` style commands allow for plural, and singular YAML keys (version, versions, branch, branches, etc...).

Once you are done modifying the `inventory.yml` file, you can run the `mirror` command to download any cookbooks to your local inventory.

    $ minimart mirror

The above inventory file would download multiple versions of the `apache2`, and `nginx` cookbooks. The inventory directory would have the following structure:

    inventory
    ├── apache2-2.0.0
    │   ├── README.md
    │   ├── metadata.rb
    │   ├── ... (all of the other cookbook files)
    ├── ... (directories and files for other cookbooks)

### Generating a MiniMart Endpoint

Once you are satisfied with the cookbooks in your inventory, you can use the `web` command to generate the MiniMart index file, archived cookbook directories, and static HTML for browsing any mirrored cookbooks. This directory structure will be built in your local directory (wherever you are running `minimart`), and can be synced to your web server, s3, etc...

The `web` command requires the user to specify a `host` to build a proper index file. The `host` should be the domain name, or IP you plan to use to host Minimart. To generate a MiniMart that would be hosted on `example.com` you would run:

    $ minimart web --host=http://example.com

`web` will run through any of the cookbooks in the inventory, and generate the following:

    web
    ├── assets
    │   ├── ... (CSS, JS, etc...)
    ├── cookbook_files
    │   ├── apache2
    │   │   └── 2_0_0
    │   │       └── apache2-2.0.0.tar.gz
    │   ├── nginx
    │   │   └── ... (additional .tar.gz cookbooks)
    ├── cookbooks
    │   ├── apache2
    │   │   └── 2.0.0.html
    │
    ├── index.html
    ├── universe

It is important to note the creation of the `universe` file. This is the JSON index file that is necessary for MiniMart to work with Berkshelf. It contains a listing of all cookbook versions, and where they can be found (hence the need for the `host`).

### Deploying MiniMart

Deploying MiniMart *should* be as easy as syncing the contents of your `web` directory to a web server that will serve static files.

The caveat is that you **must configure your server to serve the `universe` file with a content-type of `application/json`**.

##### Amazon S3
You must set the 'Content-Type' Metadata of `universe` to `application/json` with the tool you are using to sync files to S3.

##### nginx
In your nginx.conf:

    location /universe {
      default_type application/json;
    }

##### Apache
In your apache2.conf:

    <Location "/universe">
    ForceType application/json
    </Location>

### Additional Configuration
If you are using berkshelf-api, you can add chef, and github configuration options to your `inventory.yml` file to properly download cookbooks from those sources.

    sources:
      - "api.berkshelf.com"
    configuration:
      verify_ssl: true # This defaults to true!
      chef:
        client_name: 'berkshelf'
        client_key: '/path/to.pem'
      github:
        organization: "org-name"
        api_endpoint: "https://api.github.com/"
        web_endpoint: "https://api.github.com/"


### Example Jenkins Script
This is an example of a script that can be used by Jenkins to sync the
cookbooks to the S3 bucket. This script can be placed in the same
directory as the `inventory.yml` file created by `minimart init`. This
can be pulled down from a repository and then ran by Jenkins.

    #!/bin/bash

    # Exit 1 if any command fails
    set -e

    # Name of the repository bucket
    BUCKET_NAME=your.s3.bucket.name

    echo Changing to special RVM and gemset...
    rvm 2.1.2

    echo Updating required gems...
    bundle install

    echo Mirroring cookbooks...
    minimart mirror

    echo Generating market...
    minimart web --host=$BUCKET_NAME

    echo Syncing web site up to s3://$BUCKET_NAME
    aws s3 sync web s3://$BUCKET_NAME --acl public-read --exclude
    "web/universe"
    aws s3 cp web/universe s3://$BUCKET_NAME --acl public-read

    echo cleaning up Jenkins...
    rm -rf ./inventory


## Contributing

1. Fork it ( https://github.com/electric-it/minimart/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## License

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing,
        software
        distributed under the License is distributed on an "AS IS"
        BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
        implied.
        See the License for the specific language governing permissions
        and
        limitations under the License.
```
=======
Minimart Site
============

## Development

    bundle install
    bundle exec jekyll serve --watch

The server will then be running at [http://localhost:4000](http://localhost:4000).
>>>>>>> 5074966a24c60cd49934189568cd65ff0407603e
