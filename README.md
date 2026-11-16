# medusa_rest_client

[![Ruby](https://github.com/misasa/medusa_rest_client/actions/workflows/ruby.yml/badge.svg)](https://github.com/misasa/medusa_rest_client/actions/workflows/ruby.yml)

A Ruby client for the [Medusa](https://github.com/misasa/medusa) REST API.
It uses [ActiveResource](https://github.com/rails/activeresource) to access
records, manage associations, and upload files and images.

This gem is used by
[sisyphus-for-medusa](https://github.com/misasa/sisyphus-for-medusa) and
[pmlatex](https://github.com/misasa/pmlatex).

## Requirements

Ruby 2.5 or later. GitHub Actions tests Ruby 2.5.9, 2.6.10, 2.7.8, 3.2,
3.3, 3.4, and 4.0. Use a maintained Ruby version for new installations.
Bundler selects a compatible released version of ActiveResource for each Ruby.

## Installation

Install from the laboratory's gem server:

```sh
gem install medusa_rest_client --source https://dream.misasa.okayama-u.ac.jp/rubygems/
```

To build from this repository:

```sh
git clone https://github.com/misasa/medusa_rest_client.git
cd medusa_rest_client
bundle install
bundle exec rake verify
gem install pkg/medusa_rest_client-*.gem
```

Once a release is published, you can also download its `.gem` archive and
SHA-256 checksum from [GitHub Releases](https://github.com/misasa/medusa_rest_client/releases).
The download helper checks the checksum and refuses to overwrite existing files:

```sh
bash script/download_release.sh --output-dir downloads
# Or select a published version:
bash script/download_release.sh --version VERSION --output-dir downloads
gem install downloads/medusa_rest_client-VERSION.gem
```

Replace `VERSION` with the release version, without the `v` prefix.
Downloading a public release does not require a GitHub token. Installing the
archive also installs its runtime dependencies from your configured gem sources.

## Configuration

Create `~/.orochirc` with your Medusa URL and credentials:

```yaml
uri: https://your-medusa.example/stone/
user: your-username
password: your-password
```

Include the API path in `uri`. A `.orochirc` file in the current directory
takes precedence over the file in your home directory. Keep credentials out
of version control and restrict access to the file:

```sh
chmod 600 ~/.orochirc
```

## Command-line usage

| Command | Description |
| --- | --- |
| `medusa console` | Open an interactive Ruby console with the client loaded. |
| `medusa console -e 'puts Specimen.find(:first).name'` | Run a Ruby expression. |
| `medusa upload image.jpg` | Upload a file to Medusa. |
| `medusa remove GLOBAL_ID` | Delete the record identified by its global ID. |
| `medusa --help` | Show command-line help. |
| `medusa --version` | Show the client and Ruby versions. |

`upload` and `remove` accept multiple arguments. Use `medusa COMMAND --help`
for help with a specific command. The `remove` command deletes server records;
use it only for records you intend to delete.

## Ruby API

```ruby
require 'medusa_rest_client'

specimens = MedusaRestClient::Specimen.find(:all)
attachment = MedusaRestClient::AttachmentFile.upload('image.jpg')
puts attachment.global_id
```

See the [specs](spec/medusa_rest_client) for more examples of the Ruby API.

## Development

```sh
bundle install
bundle exec rake spec    # Run the tests without a Medusa server.
bundle exec rake verify  # Test, build, and verify the installed gem.
```

Tests use WebMock to disable real HTTP connections and use temporary credentials.
The legacy live-server examples in `with_net_connect_spec.rb` remain disabled.
Package verification installs the built archive into a temporary gem home and
checks the library and CLI using only declared runtime dependencies.

`Gemfile.lock` is intentionally not tracked: each CI Ruby resolves compatible
dependencies. When switching Ruby versions locally, regenerate the lockfile.
For Ruby 2.5, use Bundler 2.3.26; for Ruby 2.6 and 2.7, use Bundler 2.4.22.

## GitHub builds and releases

Pull requests and pushes to `master` run the test and package checks. A successful
run provides the `medusa_rest_client-gem` artifact on its Actions page.

To prepare a release, increment `MedusaRestClient::VERSION` in
`lib/medusa_rest_client/version.rb`, merge the change into `master`, and push a
matching `vVERSION` tag. Choose a new version: existing tags and releases must
not be reused, including older tags without the `v` prefix.

The release job runs only after every Ruby test and the package job pass. It
checks the tag, gem version, and `master` ancestry, then uploads the gem and its
SHA-256 checksum to a draft release. It downloads and compares both assets before
publishing the release. Failed uploads leave a draft for inspection.

This workflow publishes to GitHub Releases. It does not publish to RubyGems.org
or the laboratory's gem server.

## License

GNU General Public License, version 3 or later. See [LICENSE.txt](LICENSE.txt).
