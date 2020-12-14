# gem package -- medusa_rest_client

A series of Ruby interfaces to Medusa.

# Description

A series of Ruby interfaces to Medusa.  This gem is a client for
interacting with [rails project -- medusa](https://github.com/misasa/medusa) by REST.  [Medusa REST API](http://dream.misasa.okayama-u.ac.jp/documentation/MedusaRestAPI) follows
the Rails's RESTful conventions, so this gem uses [ActiveResource](https://github.com/rails/activeresource)
to interact with the Medusa REST API.  This gem allows Ruby developers
to programmatically  access the API and provides some useful functions
to manage records on the Medusa programmatically.

This package is referred by [gem package -- sisyphus-for-medusa](https://github.com/misasa/sisyphus-for-medusa)
and [gem package -- pmlatex](https://github.com/misasa/pmlatex).

# Requirements

Ruby 2.5, 2.6, and 2.7.

# Installation

Install the package by yourself as:

    $ gem sources -a http://devel.misasa.okayama-u.ac.jp/gems/
    $ gem install medusa_rest_client

# Commands

No command is installed by this gem but one for debug.

Commands are summarized as:

| command   | description                                          | note  |
|-----------|------------------------------------------------------|-------|
| medusa    | Provide debug console during interaction with Medusa |       |


# Usage

See specfile how to call Ruby API.

Or see online document:

    $ medusa --help
