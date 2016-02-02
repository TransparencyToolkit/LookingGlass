Themes
======

LookingGlass supports creating custom themes of the app. For an examples, look at the following examples:

 - [ICWATCH](https://icwatch.transparencytoolkit.org)
 - [Snowden Doc Search](https://search.edwardsnowden.com)

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

1. Make a copy of directory `default` to name of your theme, e.g. `public/themes/nicetheme/`
2. Edit variables and oaths from the `default` files you copied in `nice-theme` directory
5. Add fonts, images, and whatever files you need in your directory to `nice-theme`
7. Add & edit whatever CSS / SASS properties you desire in your theme files
8. Edit the value `Theme` in `app/dataspec/instances/your-config.json` to `nice-theme`
9. Voila, viewing LookingGlass in your browser should show your "nice" theme :)

*This is a work-in-progress if you have ideas or suggestions how to improve it or add new features let us know and [file an issue](https://github.com/TransparencyToolkit/LookingGlass/issues/new)*
