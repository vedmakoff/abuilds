#!/bin/sh
ABUILDS_FILE=noabuilds.html
ERROR_FILE=errorabuilds.html
OUT_FILES="${ABUILDS_FILE} ${ERROR_FILE}"
ABUILDS_FOLDER=${1:-.}/
if [ ! -z ${BUILD_LIST} ]; then
    ABUILD_PATHS=`cat ${BUILD_LIST} | sed "/#/d; /^\s*$/d; s|^|$ABUILDS_FOLDER|"`
else
    ABUILD_PATHS=${ABUILDS_FOLDER}*
fi

for filename in ${OUT_FILES}; do
    cat >$filename << END
<html>
<head>
    <title>Packages without abuilds</title>
</head>
<body>
<h3>Total: </h3>
END
done

for path in ${ABUILD_PATHS}; do
    if [ ! -d $path ]; then continue; fi
    if [ -f $path/ABUILD ]; then
        (
            . $path/ABUILD 2>>${ERROR_FILE}
            if [[ -z "${build_deps}" ]]; then
                bname=$(basename $path)
                echo "${bname}<br/>" >> ${ABUILDS_FILE}
            fi
        )
    fi
done

for filename in ${OUT_FILES}; do
    echo "</body></html>" >> $filename
done

for filename in ${OUT_FILES}; do
    COUNT=$(cat ${filename} | sed '/^\s*</d' | wc -l)
    sed -i "s/\(Total: \)[^<]*/\1${COUNT}/" ${filename}
done

sed -i '/^\s*</! s|$|<br/>|g' ${ERROR_FILE}
