LookingGlass
============

Search, filter, and browse any set of documents. LookingGlass includes full
text search, category filters, and date queries all through a nice search
interface with an **Elasticsearch** backend. LookingGlass also supports
customizable
[themes](https://github.com/TransparencyToolkit/LookingGlass/blob/master/THEMES.md)
and flexible document view pages for browsing and embedding a variety of
document types.

LookingGlass requires
[DocManager](https://github.com/TransparencyToolkit/DocManager) so that it can
interact with Elasticsearch. LookingGlass can be used in combination with
[Harvester](https://github.com/TransparencyToolkit/Harvester) for crawling,
parsing, and loading documents and automatically turning them into a
searchable archive. However, it also works well as a standalone archiving
tool.


# Installation

## Dependencies

* [DocManager](https://github.com/TransparencyToolkit/DocManager) and all of
  its dependencies
* ruby 2.4.1
* rails 5
* (optionally) [Harvester](https://github.com/TransparencyToolkit/Harvester)
* libmagic-dev

## Setup Instructions

1. Install the dependencies

* Download elasticsearch (https://www.elastic.co/downloads/elasticsearch)
* Download rvm (https://rvm.io/rvm/install)
* Install Ruby: Run `rvm install 2.4.1` and `rvm use 2.4.1`
* Install Rails: `gem install rails`
* Follow the installation instructions for [DocManager](https://github.com/TransparencyToolkit/DocManager)

2. Get LookingGlass

* Clone repo: `git clone --recursive git@github.com:TransparencyToolkit/LookingGlass.git`
* Go into the LookingGlass directory: `cd LookingGlass`
* Install the Rubygems LookingGlass uses: `bundle install`
* Generate simple form data: `rails generate simple_form:install --bootstrap`
* Precompile assets: `rake assets:precompile`

3. Run LookingGlass

* Start DocManager: Follow the instructions on the
  [DocManager](https://github.com/TransparencyToolkit/DocManager) repo
* Configure Project: Edit the file in `config/initializers/project_config` so
  that the PROJECT_INDEX value is the name of the index in the
  [DocManager](https://github.com/TransparencyToolkit/DocManager) project
  config LookingGlass should use
* Start LookingGlass: Run `rails server -p 3001`
* Use LookingGlass: Go to [http://0.0.0.0:3001](http://0.0.0.0:3001) in your
  browser
 

# Features

LookingGlass is a frontend for searchable document archives. Previously, it
also included the backend that interacted with Elasticsearch, but this has
since been split out into
[DocManager](https://github.com/TransparencyToolkit/DocManager). The key
features are described below.

## Display of Document Sets

LookingGlass shows document sets from multiple data sources. It displays a
list of documents on the main page. The fields displayed for each document on
the index page and the order the documents are displayed in (sorted by date or
another numerical field) are customizable in
[DocManager](https://github.com/TransparencyToolkit/DocManager)'s data source
config files.

Each individual document set is then displayed on its own page for easy
reading. The document page includes a sidebar with the document's categorical
field and a customizable set of tabs that can display the document text, embed
the document itself (which is stored remotely, locally, or on document cloud),
offer document downloads, or load links.

## Search

LookingGlass allows full text of document sets using the Elasticsearch
backend. It can be used to search documents in most languages. LookingGlass
supports searching all fields or individual fields, and a variety of non-text
fields like dates. Results are sorted by relevance with text matching the
query highlighted.

## Categorical Filters

Many document sets have categorical fields that are common across documents,
either in the original data or that can be extracted with a tool like
[Catalyst](https://github.com/transparencytoolkit/catalyst). For example,
countries mentioned in a document, file format, hashtags, and topic-specific
keywords are common types of categories. LookingGlass allows filtering
document sets by one or more categories by clicking links on the sidebar to
get, say, all the documents that are about a particular country.

The category sidebar also displays the number of documents for each value in
each category that matches the current query. This is great for getting an
overview of the content in the document set.

## Document View Templates

On both the search results/document index and individual document pages, the
way the document is displayed is highly customizable. It is possible to add
new templates to display different types of data sources however you want and
even thread together multiple documents when needed (in email datasets, for
example).

These view templates are defined in app/views/docs/show/tabs/panes (for the
document view page) and app/views/docs/index/results/result_templates (for the
index/result view). The fields to use as a thread ID and view templates to
used are specified per-source in the
[DocManager](https://github.com/TransparencyToolkit/DocManager) data source
config files.

## Version Tracking

LookingGlass can be used to track which documents change over time and
how. Documents that are changed are specified in categories on the sidebar and
the document view page has a tool that allows users to view the exact
difference between two documents over time.

The fields used to check if a document has changed are specified per-source in
the [DocManager](https://github.com/TransparencyToolkit/DocManager) data
source config files.

## Custom Themes

LookingGlass supports custom theming. The color scheme, fonts, logo, text, and
links are all entirely customizable.

Some of these settings, like the theme used, project title, and logo are defined in the
[DocManager](https://github.com/TransparencyToolkit/DocManager) project config
file. The colors and fonts can then be set by [creating a
theme](https://github.com/TransparencyToolkit/LookingGlass/blob/master/THEMES.md).
