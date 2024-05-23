function bump {
    local mode="$1"
    local old="$2"
    local parts=(${old//./ })
    case "$1" in
    major)
        local bv=$((parts[0] + 1))
        NEW_VERSION="${bv}.0.0"
        ;;
    minor)
        local bv=$((parts[1] + 1))
        NEW_VERSION="${parts[0]}.${bv}.0"
        ;;
    patch)
        local bv=$((parts[2] + 1))
        NEW_VERSION="${parts[0]}.${parts[1]}.${bv}"
        ;;
    esac
}

BUMP_MODE="patch"

if [ -n "$1" ]; then
  BUMP_MODE=$1
fi

OLD_VERSION=$(<VERSION)
NEW_VERSION="-"

bump $BUMP_MODE $OLD_VERSION
echo "version will be bumped from" $OLD_VERSION "to" $NEW_VERSION

#save outputs
echo "OLD_VERSION=${OLD_VERSION}" >> $GITHUB_OUTPUT
echo "NEW_VERSION=${NEW_VERSION}" >> $GITHUB_OUTPUT