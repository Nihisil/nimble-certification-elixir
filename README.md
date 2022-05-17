[![Tests](https://github.com/Nihisil/nimble-certification-elixir/actions/workflows/test.yml/badge.svg)](https://github.com/Nihisil/nimble-certification-elixir/actions/workflows/test.yml)

## Introduction

This is web application for extracting large amounts of data from the Google search results page.

## Project Setup

### Erlang & Elixir

- Erlang 24.2.2

- Elixir 1.13.4

- Recommended version manager.

  - [asdf](https://github.com/asdf-vm/asdf)
  - [asdf-erlang](https://github.com/asdf-vm/asdf-erlang)
  - [asdf-elixir](https://github.com/asdf-vm/asdf-elixir)

### Development

- Install [Docker for Mac](https://docs.docker.com/docker-for-mac/install/)

- Setup and boot the Docker containers:

  ```sh
  make docker_setup
  ```

- Install Elixir dependencies:

  ```sh
  mix deps.get
  ```

- Install Node dependencies:

  ```sh
  npm install --prefix assets
  ```

- Setup the databases:

  ```sh
  mix ecto.setup
  ```

- Start the Phoenix app

  ```sh
  iex -S mix phx.server
  ```

- Run all tests:

  ```sh
  mix test 
  ```

- Run all lint:

  ```sh
  mix codebase 
  ```
  
- Fix all lint:

  ```sh
  mix codebase.fix 
  ```
  
- Test coverage:

  ```sh
  mix coverage 
  ```

- Stop docker:

  ```sh
  docker-compose down 
  ```
  
### Production

- Build Docker image

  ```sh
  docker-compose build
  ```

### CI/CD
The project relies entirely on [Github Actions](https://github.com/features/actions) for CI/CD via multiple workflows located under the [`.github/workflows/`](.github/workflows) directory.
Please check out the [`.github/workflows/README.md`](.github/workflows/README.md) file for further instructions.
