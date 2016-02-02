LookingGlass
============

Search, filter, and browse any JSON data. Includes full text, categorical data,  and search interface with **elasticsearch** backend. Work in progress.

## Installing

- Make sure you have elasticsearch and rails 4 installed
	- On Mac OS do the following
		- Go install [Elasticsearch](https://www.elastic.co/downloads/elasticsearch) using homebrew `brew install elasticsearch`
		- Install [RubyOnRails](http://rubyonrails.org/download/) by typing `gem install rails`
	- On Debian / Ubuntu
		- Install dependencies `sudo apt-get install ruby-full`
		- Install ElasticSearch using package manager or [1.5.2 docs](https://www.elastic.co/guide/en/elasticsearch/reference/1.5/_installation.html)
	- On Fedora
	- 	- Install Elasticsearch via the [Fedora Yum instructions](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html)
	- 	- Install dependencies  `sudo yum install make automake gcc gcc-c++ kernel-devel ruby-devel rubygem-railties`
- Clone repo `git clone --recursive git@github.com:TransparencyToolkit/LookingGlass.git`
- Then cd into directory `cd LookingGlass`
- Install Ruby dependencies `bundle install`
- Generate simple form data `rails generate simple_form:install`

## Configuring

- Browse to the dataspec directory `cd app/dataspec/`
- Copy the example config file `instances/example-config.json` to `instances/your-config.json`
- Add any additional dataspec files to `your-config.json` file by adding to `Dataset Config` array
- Edit `importer.json` attribute `Instance Config` to your config `app/dataspec/instances/your-config.json`

You might want do add custom data related things to your instance as well. LookingGlass use [datapackages](https://data.okfn.org) for this goal such as `month-names` for internationalization!

- Add any additional data packages to the `data_packages` directory
    - `cd data_packages`
    - git clone https://github.com/you/datapackage.git

## Adding Datasets

This search should work for any JSON based dataset. If you want to add a dataset, see the `app/dataspec/` folder in your app. You will need to create your own `dataspec-template` package. Here are some steps to get you going:

- [ ] Clone our [datapec-template](https://github.com/TransparencyToolkit/dataspec-template) into that directory
- [ ] Prepare and save your data somewhere on your machine
- [ ] Edit the values in your `datapec-template` files
- [ ] Modify your `instance-config.json` file to include additional datasets

You can learn more about the values in these files mean in our [Dataset Specification](DATASET-SPECIFICATION.md).

## Running LookingGlass

- Then start up ElasticSearch
	- On Mac Os type `elasticsearch`
	- On Debian / Ubuntu installed via packages type `/etc/init.d/elasticsearch start` o
	- On Debian installed 1.5.2 go to `elasticsearch-1.5.2/bin/` and type `./elasticsearch`
	- On Fedora type `sudo systemctl start elasticsearch.service`
- Then type `rails runner 'IndexManager.import_data(force: true)'` when importing / updating datasets
- Start up the app `rails server`
- Then access [http://0.0.0.0:3000](http://0.0.0.0:3000) in your browser

**For Running In Production**
- Compile your assets `rake assets:precompile`


## Theming

LookingGlass ships and uses the theme called `default` but we've also made two custom themes which you can select from:

- `default` - matches TransparencyToolkit's branding
- `snowden` - matches Courage Foundations branding
- `pi` - matches Privacy Internationals branding

Select your "theme" by editing the value `"Theme": "default"` to reflect your preferred theme. You can also make your own theme [by following these instructions](THEMES.md).

---

## Developing

We would love your help and contributions improving upon LookingGlass. You can also customize how LookingGlass looks with a custom theme. To do either, first get a working instance setup on your development machine, then check out the following:

- [Themes](THEMES.md) - documentation for making custom look and feel
- [Dataset Specification](DATASET-SPECIFICATION.md) - details about the values in the various dataspec files
- [Developer Documentation](http://www.rubydoc.info/github/TransparencyToolkit/LookingGlass/master) - references of codebase
