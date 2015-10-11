Dataset Specification
=====================

Each `dataset` you import to an instance of LookingGlass can come from a different type of dataset (local documents, LinkedIn.com, or Indeed.com).

## Create a Dataspec Package

First step is to clone this `dataspec-template` repo into the `app/dataspec/` directory in your LookingGlass instance

```
git clone https://github.com/TransparencyToolkit/dataspec-template.git
```

The first thing you need to do is customize the dataspec JSON files contained in the template you just downloaded. The configuration files are broken down as following

- [Attach Config](#attach_config.json)
- [Dataset Details](#dataset_details.json)
- [Display Preferences](#display_prefs.json)
- [Field Details](#field_details.json)
- [Import Config](#import_config.json)

---

## Dataspec Package Details

The following are all the files that are needed to run a unique dataset / instance of LookingGlass. These files map the data attributes in your JSON to elements in the interface and provide various searching and filtering abilities.

*Making this easy to use and modify is a work in progress. If you have questions, feel free to open a [GitHub issue](https://github.com/TransparencyToolkit/LookingGlass/issues), [email us](mailto:info@transparencytoolkit.org), ping us [on Twitter](https://twitter.com/TransparencyKit) or find us on IRC #transparencytoolkit on irc.oftc.net*

### attach_config.json

Has info on PDFs or other files to show along with the data (and any field in which the url to them is listed in the
dataset).

### dataset_details.json

Has URL, file, or directory path to the data. Data must be in JSON form at the moment, but that's doable (and I have some
scripts for converting the cables between different formats lying around somewhere).

### display_prefs.json

Lists of what fields show up where. For example, which are categories on the side, which show up in the search results,
which show up on the page for an individual document.

### field_details.json

A list of fields in the dataset with their data type, human readable name, order they should show up in, icon for the
field, and mapping details (for search).

#### The "Display Type" field

One of the more important fields in the dataspec is the `Display Type` field. This field informs the interface of where and how to display certain UI attributes used for ordering and filtering the datasets. The following are the **types** available.

- **Title** - The main title on the search terms and the show page. Probably some shorter bit of text. Might be the link to the show page (though not sure if we should also have a more obvious link or not).
- **Description** - Description has a special role like the title where it is shown at the top of the show page (but this might not appear in every dataset). Should be searchable.
- **Short Text** - One line or name length text that isn't a category. It should be possible to sort by Short and titles.
- **Medium Text** - Like the description, but treated like a normal searchable field. Medium-length text should not be truncated.
- **Long Text** - For even longer versions of text such as document. This is truncated in the search results/
- **Category** - Facets. These appear on the sidebar in the results and show view and are links in the results.
- **Date** - Dates. It's possible to filter by these and should be possible to sort by these. These might show up towards the top of search results.
- **Numerical** - For various number fields that are *not* date values (population, money, etc...). Date fields are sortable.
- **Picture** - A small picture. This probably shows up towards the top of
search results and show pages.
- **Link** - A link to document itself?

### import_config.json

Specifies what field(s) to use as an ID in the URLs for individual documents, which fields to ignore when deduplicating
documents, and other things used on data import.
