#!/bin/bash
# Validates that cmake/VCSVersion.cmake is still present and wired into the build,
# then appends a FORCE override of PROJECTM_VCS_VERSION so cmake uses the given hash
# instead of detecting the HEAD of the temporary patch branch.
#
# Usage: patch-vcs-version.sh <upstream-hash>
# Must be run from the root of the projectm source tree.
set -euo pipefail

UPSTREAM_HASH="$1"

# Gate: verify VCSVersion.cmake still exists and defines PROJECTM_VCS_VERSION.
if [ ! -f cmake/VCSVersion.cmake ]; then
  echo "ERROR: cmake/VCSVersion.cmake no longer exists in the upstream source."
  echo "       The PROJECTM_VCS_VERSION override cannot be applied. Aborting."
  exit 1
fi
if ! grep -q "PROJECTM_VCS_VERSION" cmake/VCSVersion.cmake; then
  echo "ERROR: PROJECTM_VCS_VERSION is no longer defined in cmake/VCSVersion.cmake."
  echo "       The variable may have been renamed upstream. Aborting."
  exit 1
fi
# Gate: verify VCSVersion.cmake is still included by the build system.
# If the include() was dropped, our override would be a silent no-op.
if ! grep -rq "VCSVersion" --include="CMakeLists.txt" --include="*.cmake" \
       --exclude="VCSVersion.cmake" .; then
  echo "ERROR: cmake/VCSVersion.cmake is no longer included by the build system."
  echo "       The PROJECTM_VCS_VERSION override will have no effect. Aborting."
  exit 1
fi

# Append a FORCE override to bake in the upstream commit hash.
# Appending (>>) preserves any other variables that may exist in the file.
# The FORCE ensures our value wins even after cmake's own git detection runs.
printf '\nset(PROJECTM_VCS_VERSION "%s" CACHE STRING "" FORCE)\n' "$UPSTREAM_HASH" >> cmake/VCSVersion.cmake
