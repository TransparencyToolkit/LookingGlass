# NSA Doc Search

Search, filter, and browse all the NSA documents. Includes full documents and
extracted text and search interface with **elasticsearch** backend. Work in
progress.

### Installing

- Make sure you have elasticsearch and rails 4 installed
	- On Mac OS do the following
		- Go install [Elasticsearch](https://www.elastic.co/downloads/elasticsearch) using homebrew `brew install elasticsearch`
		- Install [RubyOnRails](http://rubyonrails.org/download/) by typing `gem install rails`
	- On debian / ubuntu
		- Install Elasticsearch `sudo apt-get install elasticsearch` 
		- ...to be added by shidash...
- Clone repo `git clone git@github.com:TransparencyToolkit/NSADoc-Search.git`
- Then cd into directory `cd NSADoc-Search`
- Install dependencies `bundle install`
- Then start up elasticsearch
	- On debian type `/etc/init.d/elasticsearch start`
- Then type `rails runner 'IndexManager.import_from_json(force: true)'`
- If running production, compile assets `rake assets:precompile`

### Run App

1. Start up the app `rails server`
2. Then access [http://localhost:5000](http://localhost:)

### Using App

This search should work for any dataset. If you want to use a different
dataset with this search, see the app/dataspec folder for the necessary files-

1. `nsadata.json` A data spec with the name of each field and details about how
it is used/where it should show up.
2. `nsadata_url.json` The URL to download the raw data.
3. `hidecolumns.json` The indices of the columns to hide by default in the table.
