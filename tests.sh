#!/bin/bash

set -e -o pipefail

readonly PACKAGE_DIR="spasm"

function each_iname {
    local iname=${1}; shift

    find * -type f -iname "${iname}" | while read filename; do
        "$@" "${filename}"
    done
}

function static_analysis {
    each_iname "*.rst" rst2html.py --exit-status=2 > /dev/null
    python setup.py check --strict --restructuredtext --metadata
    flake8 setup.py "${PACKAGE_DIR}"
    pyflakes setup.py "${PACKAGE_DIR}"
    pylint --rcfile=.pylintrc "${PACKAGE_DIR}"
}

function unit_test {
    nosetests \
        --with-doctest \
        --doctest-options="+NORMALIZE_WHITESPACE" \
        --with-coverage \
        --cover-tests \
        --cover-inclusive \
        --cover-package="${PACKAGE_DIR}" \
        "${PACKAGE_DIR}"
}

function main {
    if [ "${1}" == "--static-analysis" ]; then
        static_analysis
    fi
    unit_test
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
