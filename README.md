# MiniMart

MiniMart is a RubyGem that makes it simple to build a repository of Chef cookbooks using only static files.u

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

## Contributing

1. Fork it ( https://github.com/electric-it/minimart/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
