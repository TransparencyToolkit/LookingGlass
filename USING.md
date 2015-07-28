Using Looking Glass
===================

## Example Files

git@github.com:TransparencyToolkit/dataspec-template.git

---

## Glossary

The following are all the files that are needed to run a unique dataset / instance of LookingGlass.

### field_details.json

A list of fields in the dataset with their data
type, human readable name, order they should show up in, icon for the
field, and mapping details (for search).

### display_prefs.json

Lists of what fields show up where. For example,
which are categories on the side, which show up in the search results,
which show up on the page for an individual document.

### dataset_details.json

Has URL, file, or directory path to the data. Data
must be in JSON form at the moment, but that's doable (and I have some
scripts for converting the cables between different formats lying around
somewhere).

### attach_config.json

Has info on PDFs or other files to show along with
the data (and any field in which the url to them is listed in the
dataset).

### import_config.json

Specifies what field(s) to use as an ID in the URLs
for individual documents, which fields to ignore when deduplicating
documents, and other things used on data import.

### site_config.json

Customization of text and styling on the search interface.
