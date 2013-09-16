#!/bin/sh
ABUILDS_FILE=noabuilds.html
ERROR_FILE=errorabuilds.html
OUT_FILES="${ABUILDS_FILE} ${ERROR_FILE}"

for filename in ${OUT_FILES}; do
    cat >$filename << END
<html>
<head>
    <title>Packages without abuilds</title>
</head>
<body>
END
done

for path in *; do
    if [ ! -d $path ]; then continue; fi
    if [ -f $path/ABUILD ]; then
        (   errors=""
            . $path/ABUILD 2>>${ERROR_FILE}
            if [[ ! -z $errors ]]; then
                echo "<p>${errors}</p>"
            fi
            if [[ -z "${build_deps}" ]]; then
                bname=$(basename $path)
                echo "<p>${bname}</p>" >> ${ABUILDS_FILE}
            fi
        )
    fi
done

for filename in ${OUT_FILES}; do
    echo "</body></html>" >> $filename
done
