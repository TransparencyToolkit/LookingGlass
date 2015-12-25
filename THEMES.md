Themes
======

LookingGlass supports creating custom themes of the app. For an examples, look at how [ICWATCH](https://icwatch.transparencytoolkit.org) looks different from the [Snowden Doc Search](https://search.edwardsnowden.com), both of these are using LookingGlass underneath.

## LookingGlass Files

All of the files needed for styling LookingGlas live in the directory `app/assets/stylesheets/`

- `application.scss` - loads all styles files and gems to compile
- `application.css` - also needed to load all styles files and gems to compile
- `bootstrap-custom.scss` - defines Bootstrap specific files (and others) to include from Gem or custom
- `looking-glass.scss` - contains custom CSS / SASS code for the LookingGlass application

However, the actual files that *style* your instance of LookingGlass live in a folder prefixed with `theme-` for ordering and sense such as `theme-default`

- `theme-default/bootstrap-variables.scss` -
- `theme-default/fonts/` - a directory of custom fonts for your theme
- `theme-default/fonts.scss` - defines names of font families loaded by the theme
- `theme-default/tt-logo-32.png` - logo files and other theme specific images

## Creating Your Custom Theme

To make your own custom theme, follow these steps:

1. Make a directory called whatever you want, e.g. `theme-awesomesauce`
2. Copy file `theme-default/bootstrap-variables.scss` to your directory
3. Copy file `theme-default/fonts.scss` to your directory
4. Edit all references to `theme-default` in the files you copied to `theme-awesomesauce`
5. Add your fonts & images to your `theme-awesomesauce` folder as you need
6. Edit paths in your `fonts.scss` file to match your fonts names
7. Edit whatever CSS / SASS properties you desire in your theme files
8. Edit the `Theme` in `app/dataspec/instances/config.json` file to `theme-awesomesauce`
9. Voila, viewing LookingGlass in your browser should show

*This is a work-in-progress if you have ideas or suggestions how to improve it, make it more simple, or add new features let us know*
