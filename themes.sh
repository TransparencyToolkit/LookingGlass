#! /bin/bash
#
# Build existing or watch LookingGlass themes as you develop with SASS
#
# Dependencies:
# - sudo gem install sass

function build() {
    build_path="$(pwd)/public/"
    cd $build_path
    themes_path="themes/"
    for theme in "${themes_path[@]}"*; do
        theme_name="$(echo $theme | sed 's/themes\///')"
        printf "\nBuilding theme: ${theme_name}\n"
        printf "sass ${theme}/theme.scss:css/${theme_name}.css\n"
        sass ${theme}/theme.scss:css/${theme_name}.css
        sleep 1
    done
    printf "\nDone building themes\n"
}

function watch() {
    echo public/themes/$OPTARG
    if [[ -d public/themes/$OPTARG ]]; then
        sass --watch public/themes/${OPTARG}/theme.scss:public/css/${OPTARG}.css
    else
        printf "\nThere is no theme named: $OPTARG\n\n"
    fi
}

usage() {
    prog="${0##*/}"
    printf "Usage: %s [-b|-w]\n" "$prog"
    printf "\n"
    printf "Options:\n\n"
    printf "  -b\t Build all LookingGlass themes with SASS\n"
    printf "  -w <theme-name> \t Watch a given LookingGlass theme for changes\n"
    printf "\n"
}

if [[ "$#" == "0" ]] ; then
    usage;
else
    while getopts "bw:" opt; do
        case $opt in
            b)
                echo "Using SASS to build LookingGlass themes";
                build;;
            w)
                echo "Watch theme: ${OPTARG} with sass\n" >&2;
                watch;;
            h)  usage;;
        esac
    done
fi
