# LookingGlass

Search, filter, and browse any JSON data. Includes full text, categorical data,  and search interface with **elasticsearch** backend. Work in progress.

## Installing

- Make sure you have elasticsearch and rails 4 installed
	- On Mac OS do the following
		- Go install [Elasticsearch](https://www.elastic.co/downloads/elasticsearch) using homebrew `brew install elasticsearch`
		- Install [RubyOnRails](http://rubyonrails.org/download/) by typing `gem install rails`
	- On Debian / Ubuntu
		- Install Elasticsearch `sudo apt-get install elasticsearch` 
	- On Fedora
	- 	- Install Elasticsearch via the [Fedora Yum instructions](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html)
	- 	- Install dependencies  `sudo yum install make automake gcc gcc-c++ kernel-devel ruby-devel rubygem-railties`
- Clone repo `git clone git@github.com:TransparencyToolkit/LookingGlass.git`
- Then cd into directory `cd LookingGlass`
- Install dependencies `bundle install`
- Generate simple form data `rails generate simple_form:install` 
- Browse to dataspec directory `cd app/dataspec/`
- Copy importer for example data `cp example_importers/lidata_importer.json importer.json`

**For Running In Production**
- Compile your assets `rake assets:precompile`

## Running App

- Then start up ElasticSearch
	- On Mac Os type `elasticsearch`
	- On Debian / Ubuntu type `/etc/init.d/elasticsearch start`
	- On Fedora type `sudo systemctl start elasticsearch.service`
- Then type `rails runner 'IndexManager.import_data(force: true)'` when importing / updating datasets
- Start up the app `rails server`
- Then access [http://0.0.0.0:3000](http://0.0.0.0:3000) in your browser

## Adding Datasets

This search should work for any dataset. If you want to use a different dataset with this search, see the app/dataspec folder for the necessary files. You will need to create your own `dataspec` sheet such as this current file:

1. `lidata.json` A data spec with the name of each field and details about how
it is used/where it should show up.
2. `importer.json` A JSON with various import settings
3. `hidecolumns.json` The indices of the columns to hide by default in the table.


### Example DataSpec File


```
{
  "Field Name": "title",
  "Human Readable Name": "Title",
  "Type": "String",
  "Display Type": "Title",
  "Mapping": "english",
  "Facet?": "No",
  "In Table?": "Yes",
  "Show by default in table?": "Yes",
  "Searchable?": "Yes",
  "In doc?": "Yes",
  "Form Params": "title",
  "Size": "1000",
  "Location": "0",
  "Link": "single",
  "Item_Field": "No",
  "Icon": ""
},{
  "Field Name": "description",
  "Human Readable Name": "Description",
  "Type": "String",
  "Display Type": "Short Text",
  "Mapping": "english",
  "Facet?": "No",
  "In Table?": "Yes",
  "Show by default in table?": "Yes",
  "Searchable?": "Yes",
  "In doc?": "Yes",
  "Form Params": "description",
  "Size": "1000",
  "Location": "1",
  "Item_Field": "No",
  "Icon": ""
},{
  "Field Name": "document_date",
  "Human Readable Name": "Document Date",
  "Type": "Date",
  "Display Type": "date",
  "Mapping": "not_analyzed",
  "Facet?": "No",
  "In Table?": "Yes",
  "Show by default in table?": "No",
  "Searchable?": "Yes",
  "In doc?": "Yes",
  "Form Params": [
    "document_date",
    "end_document_date"
  ],
  "Size": "1000",
  "Location": "5",
  "Item_Field": "No",
  "Icon": ""
}
```

#### The "Display Type" field

One of the more important fields in the dataspec is the `Display Type` field. This field informs the interface of where and how to display certain UI attributes used for ordering and filtering the datasets. The following are the **types** available.

```
* Title
* Description
* Short Text
* Medium Text
* Long Text
* Category
* Date
* Numerical
* Picture
* Link
```

**Title** - The main title on the search terms and the show page. Probably some shorter bit of text. Might be the link to the show page (though not sure if we should also have a more obvious link or not).

**Description** - Description has a special role like the title where it is shown at the top of the show page (but this might not appear in every dataset). Should be searchable.

**Short Text** - One line or name length text that isn't a category. It should be possible to sort by Short and titles.

**Medium Text** - Like the description, but treated like a normal searchable field. Medium-length text should not be truncated.

**Long Text** - For even longer versions of text such as document. This is truncated in the search results/

**Category** - Facets. These appear on the sidebar in the results and show view and are links in the results.

**Date** - Dates. It's possible to filter by these and should be possible to sort by these. These might show up towards the top of search results.

**Numerical** - For various number fields that are *not* date values (population, money, etc...). Date fields are sortable.

**Picture** - A small picture. This probably shows up towards the top of
search results and show pages.

**Link** - A link to document itself?
