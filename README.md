[![Logo Image](https://github.com/user-attachments/assets/cd0dadaa-3b55-4f00-8e98-82a554c51712)](https://reviactyl.dev)

# Reviactyl Development
This repository provides a `docker-compose` based environment for handling local development of Reviactyl.

**This is not meant for production use! This is a local development environment only.**

> This environment was forked from [Pterodactyl's Development Repository](https://github.com/pterodactyl/development), which was made by [`@DaneEveritt`](https://github.com/DaneEveritt) and is used by them for Pterodactyl Development. This should work on both macOS and most Linux Machines. For Windows, you are on your own.

### Getting Started
You'll need the following dependencies installed on your machine.

* [Orbstack](https://orbstack.dev) **macOS only**
* [mkcert](https://github.com/FiloSottile/mkcert)

### Setup
To begin clone this repository to your system, and then run `./setup.sh` which will configure the additional git repositories, and setup your local certificates and host file routing. If you do not have permission to write to the original repositories and want to contribute, please edit `setup.sh` to clone your forked repository instead to be able to commit your changes and submit a Pull Request in the future.

```sh
git clone https://github.com/reviactyl/development.git
cd development
./setup.sh
```

#### What is Created
* Traefik Container
* Panel & Wings Containers
* MySQL & Redis Containers
* Minio Container for S3 emulation

### Accessing the Environment
Once you've setup the environment, simply run `./beak build` and then `./beak up -d` to start the environment.
`beak` aliases some common Docker compose commands, but everything else will pass through to `docker compose`.

Once the environment is running, `./beak app` and `./beak wings` will allow SSH access to the Panel and
Wings environments respectively. Your Panel is accessible at `https://reviactyl.test`. You'll need to
run through the normal setup process for the Panel if you do not have a database and environment setup
already. This can be done by SSH'ing into the Panel environment and running `setup-reviactyl`, followed by configuring your .env file with either `php artisan` commands or editing the .env file manually to connect your database and redis services.

The code for the setup can be found in `build/panel/setup-reviactyl`. Ensure you run `yarn serve` or
`yarn build` before accessing the Panel. You can run `yarn` inside the container, or just in the `code/panel`
directory on your host machine, assuming you have `node >= 22`.

### Running Wings
You'll need to create a location and a node in the Panel instance before you can configure Wings. Set up the
node _as being "Behind Proxy"_ and set the `Daemon Port` value to 443. Copy over the resulting `config.yml`
file to `/home/root/wings/config.yml` on the Wings dev container.

When you write that file, update the `port` value in the file to be `8080` since traffic is being proxied for the environment with Traefik. Make sure that you use `wings.reviactyl.test` as the FQDN, otherwise you could run into issues.

You should then be able to run `make debug` which will start the Wings daemon in debug mode.

Be aware that future changes to the Node configuration could update the file.