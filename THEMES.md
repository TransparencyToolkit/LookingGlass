Themes
======

LookingGlass supports creating custom themes of the app. For an examples, look at the following examples:

- `default` - [ICWATCH](https://icwatch.transparencytoolkit.org)
- `snowden` - [Snowden Doc Search](https://search.edwardsnowden.com)
- `pi` - [Surveillance Industry Index](https://sii.transparencytoolkit.org)
- `couragewl` - [USA vs. WikiLeaks](https://usavwl.couragefound.org)
- `neondata` - [DataPolitics](https://datapolitics.transparencytoolkit.org)
- `webfoundation` - matches [webfoundation.org](https://webfoundation.org)

Both of these instances are using the LookingGlass application, they look similar but also different. This is achieved using LookingGlass' theming functionality!

## The LookingGlass "Default" Theme

All of the files needed for styling LookingGlass live in the directory `public/scss/` and `public/fonts/` and the files needed for each theme exist in the `public/themes/` directory. LookingGlass ships with the **default** theme, whos files are located in `public/themes/default/` and the contents of that are:

- `default/bootstrap-variables.scss` - all the basic variables used by Bootstrap for customization
- `default/fonts.scss` - defines names of font families loaded by the theme (put additional fonts in your theme)
- `default/looking-glass-variables.scss` - variables specifically for LookingGlass app
- `default/theme.scss` - is the file you actually build the CSS from, custom as neeeded
- `default/tt-favicon.png` - favicon for your theme
- `default/tt-logo-32.png` - logo files and other theme specific images

The actual files that *style* your instance of LookingGlass and are thus needed to make a new theme are `theme.scss` and `bootstrap-variables.scss` and `looking-glass-variables.scss` everything else is optional. There is also an optional HTML files you can include such as:

- `_sidebar.html.erb` - which will inject some HTML below the search facets on the sidebar

## Create A Custom Theme

To make your own theme, follow these steps:

1. Make a copy of directory `default` to name of your theme, e.g. `public/themes/nice-theme/`
2. Edit variables and oaths from the `default` files you copied in `nice-theme` directory
5. Add fonts, images, and whatever files you need in your directory to `nice-theme`
7. Add & edit whatever CSS / SASS properties you desire in your theme files
8. Edit the following values in [config
   files](https://github.com/TransparencyToolkit/DocManager/blob/master/dataspec_files/projects/archive_test_config.json)
in DocManager repo

```
{
  "display_details": {
    "title": "Hosted Archives Test",
    "theme": "default",
    "favicon": "tt-favicon.ico",
    "logo": "tt-logo.png",
    ...
```

To values like:

```
{
  "display_details": {
    "title": "Nice Project",
    "theme": "nice-theme",
    "favicon": "nice-favicon.png",
    "logo": "nice-logo.png",
    ...
```

Then restart DocManager

## Building Your CSS Assets

To generate the actual CSS that LookingGlass uses, you need to install and run
the [SASS](http://sass-lang.com) compiler in another terminal by doing one of
the following:

To build all LookingGlass themes

```
./themes.sh -b
```

To make SASS `--watch` as you develop recompile whenever you change a file

```
./themes.sh -w theme-name
```

Note: how the name `nice-theme` is used when running the `sass` command. The name of the theme is needed (and it needs to match the instance-config.json) for LookingGlass to properly include in. If you do this incorrectly, your CSS won't get loaded by LookingGlass

*If you have ideas or suggestions how to improve it or add new features let us know and [file an issue](https://github.com/TransparencyToolkit/LookingGlass/issues/new)*
