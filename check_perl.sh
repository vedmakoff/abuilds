#!/bin/sh

FILES=$(perl -MFile::Find=find -MFile::Spec::Functions -Tlwe \
    'find { wanted => sub { print canonpath $_ if /\.pm\z/ }, no_chdir => 1 }, @INC')

PFILES=()
NONPACKAGES=()
REBUILD=()
BROKEN=()
declare -A PACKAGES

for file in $FILES; do
    out=$(mpkg-which $file);
    if $(echo $out | grep -q "найден"); then
        name=$(echo $out | sed -e "s/.*:\s*\([^\d]*\)-[0-9]*/\1/" | sed -e "s/\(.*\)-[0-9.]*/\1/")
        PFILES+=($file)
        PACKAGES["$file"]=$name
    else
        NONPACKAGES+=($file)
    fi
done

echo "Files in packages - "${#PFILES[@]}
echo "Files not in packages - "${#NONPACKAGES[@]}
if [ ${#NONPACKAGES[@]} -gt 0 ]; then
    printf -- '%s\n' "${NONPACKAGES[@]}"
    read -p "Do you wish to remove these files? [y/n]
" yn
    while true; do
        case $yn in
            [Yy]* ) rm -f ${NONPACKAGES[@]}; break;;
            [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
        esac
    done
fi

for file in ${PFILES[@]}; do
    module_name=$(echo $file | \
                  sed -e 's|.*/perl5/[a-z]*_perl/\(.*\)|\1|' | \
                  sed -e 's|/|::|g' | sed -e 's|\(.*\).pm|\1|')
    error=$(perl -M$module_name -Tlwe 'exit(0)' 2>&1)
    status=$?
    error=`echo $error | sed "/will be removed/d"`
    if [ $status -gt 0 ]; then
        if $(echo $error | grep -q "Perl API version"); then
            if [ ${PACKAGES["$file"]} == "perl" ]; then
                BROKEN+=($file)
            else
                REBUILD+=(${PACKAGES["$file"]})
                echo $file
            fi
        fi
    fi
done

if [ ${#BROKEN[@]} -gt 0 ]; then
    echo "It seems, some files from core perl broken:"
    echo "${BROKEN[@]}" | tr ' ' '\n'
fi

if [ ${#REBUILD[@]} -gt 0 ]; then
    eval REBUILD=($(printf "%q\n" "${REBUILD[@]}" | sort -u))
    echo "Next packages require rebuild:"
    echo ${REBUILD[@]}
    agibuild -a ${REBUILD[@]}
else
    echo "All OK"
fi
