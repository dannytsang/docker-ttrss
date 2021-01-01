# TTRSS #
Containts application server to run Tiny Tiny RSS. I am not affiliated with the project. More details can be found [here](https://tt-rss.org/)

## Pre-Requisites ##
A database running MySQL with associated schema and access.

Directories containing the TTRSS configuration is required as well as the following Docker volumes:
* `config` should contain the TTRSS config.php
* `var/www/html/feed-icons` optional for storing favicons for feeds. These are refreshed every so often but if it's mapped then it will appear instantly
* `var/log` log directory to write log files

# Docker Run #
1. Copy and edit the file `config\config.php` to configure the database connection and any other TinyTiny RSS configuration changes. The example below assumes you have copied it to your home directory e.g when you go to `cd ~` in a folder called "ttrss".
2. The below command will create and store a feed-icon directory. This is useful whenever you rebuild the container so that all your feed icons are preserved rather than waiting for the sync to download them everytime. This is completely optional.
3. Build the dockerFile and run it e.g `sudo docker run --restart=always -d -p 80:80 -p 443:443 -P -t -i -v ~/ttrss/config:/config:ro -v ~/ttrss/feed-icons:/usr/share/nginx/html/feed-icons -v /var/log:/var/log --name ttrss ttrss`

# Docker-Compose #
See [docker-compose.yml](https://github.com/dannytsang/docker-ttrss/blob/master/docker-compose.yml) file for example of how to use it with docker-compose. It uses the same example in the docker run example above. The difference is it expects your shell to have an environment variable called $HOME. This is usually already set by default in Debian / Ubuntu.
