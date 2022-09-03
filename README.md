# Trading Journal

## Overview

* maintain a trading journal with manual trades input or Interactive Brokers import
* maintain trading alerts
* maintain watch lists

## Run tests

`bin/rails test`

## Roadmap

see todo.txt

## Run locally

* `git checkout -b local-setup`
* `bin/rails s` . This will start a web server and will start running a few tasks periodically (see `scheduler.rb`)
* `bin/rake jobs:work` in a separate tab
* setup mail settings in `development.rb`