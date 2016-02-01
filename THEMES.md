Themes
======

LookingGlass supports creating custom themes of the app. For an examples, look at the following examples:

 - [ICWATCH](https://icwatch.transparencytoolkit.org)
 - [Snowden Doc Search](https://search.edwardsnowden.com)

Both of these instanaces are using the LookingGlass application underneath, but both look different. This achieved using LookingGlass' theming functionality!

## LookingGlass Core Files

All of the files needed for styling LookingGlass live in the directory `app/assets/stylesheets/` however, some of the files are "core" files that pertain to the overall application. You shouldn't need to modify these to achieve a custom "look & feel" for your instance!

- `application.scss` - loads all styles files and gems to compile
- `application.css` - also needed to load all styles files and gems to compile
- `bootstrap-custom.scss` - defines Bootstrap specific files (and others) to include from Gem or custom
- `looking-glass.scss` - contains custom CSS / SASS code for the LookingGlass application

The actual files that *style* your instance of LookingGlass live in a folder prefixed with `theme-` for organizational purposes. The default **Transparency Toolkit's** design is found in `theme-default` and as you can see, it contains SCSS, fonts, and image files such as:

- `theme-default/bootstrap-variables.scss` -
- `theme-default/fonts/` - a directory of custom fonts for your theme
- `theme-default/fonts.scss` - defines names of font families loaded by the theme
- `theme-default/tt-logo-32.png` - logo files and other theme specific images

## Creating Your Custom Theme

To make your own custom theme, follow these steps:

1. Make a directory called whatever you want, e.g. `theme-awesome`
2. Copy file `theme-default/bootstrap-variables.scss` to your theme `theme-awesome/bootstrap-variables.scss`
3. Copy file `theme-default/fonts.scss` to your theme `theme-awesome/fonts.scss`
4. Edit all references to `theme-default` in the files you copied to `theme-awesome`
5. Add your fonts to `theme-awesome/fonts/` and images to `theme-awesome/images/` as you needed
6. Edit paths in your `fonts.scss` file to match your fonts names
7. Edit whatever CSS / SASS properties you desire in your theme files
8. Edit the `Theme` in `app/dataspec/instances/config.json` file to `theme-awesome`
9. Voila, viewing LookingGlass in your browser should show your "awesome" theme :)

*This is a work-in-progress if you have ideas or suggestions how to improve it, make it more simple, or add new features let us know and please [file an issue](https://github.com/TransparencyToolkit/LookingGlass/issues/new)*
