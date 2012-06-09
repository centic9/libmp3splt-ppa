#!/bin/sh

cd $(readlink -f $(dirname $(readlink -f $0))/..)
if [ -n "$1" ]; then
    APPEND="$1"
else
    APPEND=$(sh ./debian/soname)
fi
UPSTREAM_VERSION=$(dpkg-parsechangelog | awk '/^Version:/{sub("-.+$", "", $2); print $2}')
# this is a better version, but it requires gawk:
# NEXT_UPSTREAM=$(echo ${UPSTREAM_VERSION} | gawk '{split($0, a, "."); sub(a[length(a)] "$",  a[length(a)] + 1, $0); print}')
NEXT_UPSTREAM=$(echo ${UPSTREAM_VERSION} | cut -d . -f 1-2).$(( $(echo ${UPSTREAM_VERSION} | cut -d . -f 3 | tr -d '[a-z]') + 1 ))
MINIMUM_DEP=$UPSTREAM_VERSION
if [ -n "$OVERRIDE_MINIMUM_VERSION" ]; then
    if dpkg --compare-versions "$OVERRIDE_MINIMUM_VERSION" "gt" "$MINIMUM_DEP"; then
        MINIMUM_DEP=$OVERRIDE_MINIMUM_VERSION
    fi
fi
if [ -n "$INTERNAL_OVERRIDE_MINIMUM_VERSION" ]; then
    if dpkg --compare-versions "$INTERNAL_OVERRIDE_MINIMUM_VERSION" "gt" "$MINIMUM_DEP"; then
        MINIMUM_DEP="$INTERNAL_OVERRIDE_MINIMUM_VERSION"
    fi
fi
echo "libmp3splt$APPEND (>= ${MINIMUM_DEP}~), libmp3splt$APPEND (<< ${NEXT_UPSTREAM}~)"
