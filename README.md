# debweb

Simple Web Interface for [Aptly](http://www.aptly.info/) written in Rails.

## How does it work

This web interface abstracts the Debian repository model into Projects (read: distribution) and Branches (read: repository).  A project would constitute the main project like **vivid** or **mycoolapp**.  Then that Project can be split into branches such as **stable**, **testing**, **restricted**, **contrib** etc.  Then you can add packages to the branch.

The Debian packages are kept in a central 'library' folder.  From the web interface you can select packages to add to individual branches.  Then when you push build on a project, it will build out the structure in Aptly, idempotently, so you can run build over and over without causing errors.  You can even delete the whole Aptly folder and rebuild it without losing any data.

Then you need to serve it using another web server like Apache or Nginx.  This is probably better for security than serving it from the same application that manages the repository.

Once serving you can add the source to your apt sources file like so:

```
deb http://debian.example.com project branch1 branch2
deb http://debian.example.com mycoolapp stable testing
deb http://debian.example.com vivid restricted contrib
```

## Requirements

[Aptly](http://www.aptly.info/) is required, this can be installed from the Debian repositories.

```sh
apt-get install aptly
```

It will probably only work on a Debian based distro but as long as the OS meets the aptly requirements and provides access to the `dpkg-deb` executable it should run.

## Installation

Assuming you already have Ruby 2.2 or higher:

Clone it:

    $ git clone https://github.com/AutogrowSystems/debweb.git

Bundle it:

    $ bundle

Build the database:

    $ rake db:migrate

Add your first user (there will be a default user soon):

    $ rails c
    irb> u = User.new(email: "you@example.com", password: "12345678")
    irb> u.token = ApiToken.generate
    irb> u.save!

Create an `~/.aptly.conf` file:

```json
{
  "rootDir": "/home/you/.aptly",
  "downloadConcurrency": 4,
  "downloadSpeedLimit": 0,
  "architectures": ["all", "amd64", "i386", "i686", "armhf", "armel"],
  "dependencyFollowSuggests": false,
  "dependencyFollowRecommends": false,
  "dependencyFollowAllVariants": false,
  "dependencyFollowSource": false,
  "gpgDisableSign": false,
  "gpgDisableVerify": false,
  "downloadSourcePackages": false,
  "ppaDistributorID": "ubuntu",
  "ppaCodename": "",
  "S3PublishEndpoints": {}
}
```

Run it:

    $ rails s

Manage it at [http://localhost:3000](http://localhost:3000).

Serve the repository with apache, nginx or similar (default location is `/home/you/.aptly/public`).

```nginx
# nginx config
server {
  listen 80;
  server_name "";
  
  location / {
    root /home/you/.aptly/public;
    autoindex on;
  }
}
```

### Uploading packages

You can upload a package from a script:

    $ curl -i -F debfile=@mycooldeb.deb http://localhost:3000/api/v1/debfiles/upload/YOUR_TOKEN_HERE
   
Currently it will only return two status codes; 200 for all good, or 400 for invalid file or file exists.  There is a log located at `log/uploads.log` for troubleshooting.

## Todo

- [x] user authentication
- [ ] event logging (e.g. 'tom added package x to wheezy stable')
- [ ] drag and drop package upload
- [x] HTTP package upload using API key (for use with CI)
- [ ] *maybe* debian repository serving (not sure if the management interface should also serve packages RE security)
- [x] Debian filename normalization (`package_version_architecture.deb`)
- [ ] GPG key signing
- [ ] file deduplication through hardlinking
- [ ] **RSPEC TESTS** (currently this is a hack job I put together in 5 hours)
- [ ] repository verification - making sure your projects/branches/packages are published
- [ ] kill turbolinks right in the face
- [ ] auto adding of updated packages

## Acknowledgements

* [Aptly](http://www.aptly.info/) - pretty awesome and fast Debian repository manager
* [@ryanuber](https://github.com/ryanuber)'s awesome [ruby-aptly](https://github.com/ryanuber/ruby-aptly) library
