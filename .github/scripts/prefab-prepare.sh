#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
SRC_ROOT="${1:-artifacts}"                 # source tree with ABI subdirs
DST_ROOT="${2:-projectm-android/src}"        # destination root (writes main/ and debug/)
ABIS=(arm64-v8a armeabi-v7a x86_64)
MODULES=(projectM-4 projectM-4-playlist)

# Prefab metadata
PREFAB_PACKAGE_NAME="${PREFAB_PACKAGE_NAME:-projectm-android}"
PREFAB_SCHEMA_VERSION="${PREFAB_SCHEMA_VERSION:-2}"

ABI_API="${ABI_API:-21}"
ABI_NDK="${ABI_NDK:-27}"
ABI_STL="${ABI_STL:-c++_shared}"   # c++_shared | c++_static | none
ABI_STATIC="${ABI_STATIC:-false}"  # false for .so

# --- HELPERS ---
die() { echo "Error: $*" >&2; exit 1; }

have_any_abi() {
  for abi in "${ABIS[@]}"; do
    [[ -d "$SRC_ROOT/$abi" ]] && return 0
  done
  return 1
}

# Find one ABI that has headers at include/projectM-4/ (shared for both modules)
pick_headers_abi() {
  for prefer in arm64-v8a "${ABIS[@]}"; do
    [[ -d "$SRC_ROOT/$prefer/include/projectM-4" ]] && { echo "$prefer"; return 0; }
  done
  return 1
}

json_escape() { sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

write_prefab_json() {
  local dst_prefab_root="$1"
  mkdir -p "$dst_prefab_root"
  cat > "$dst_prefab_root/prefab.json" <<EOF
{
  "name": "$(printf %s "$PREFAB_PACKAGE_NAME" | json_escape)",
  "schema_version": $PREFAB_SCHEMA_VERSION,
  "dependencies": []
}
EOF
}

write_module_json() {
  local module_dir="$1"
  mkdir -p "$module_dir"
  cat > "$module_dir/module.json" <<'EOF'
{
  "export_libraries": [],
  "android": {}
}
EOF
}

write_abi_json() {
  local abi_dir="$1" # .../libs/android.<abi>
  local abi="$2"
  mkdir -p "$abi_dir"
  cat > "$abi_dir/abi.json" <<EOF
{
  "abi": "$(printf %s "$abi" | json_escape)",
  "api": $ABI_API,
  "ndk": $ABI_NDK,
  "stl": "$(printf %s "$ABI_STL" | json_escape)",
  "static": $ABI_STATIC
}
EOF
}

# Copy shared headers from include/projectM-4/* into BOTH module include dirs
copy_shared_headers() {
  local hdr_abi="$1"
  local src_inc="$SRC_ROOT/$hdr_abi/include"
  [[ -d "$src_inc" ]] || die "Shared headers not found at '$src_inc'"

  for variant in main debug; do
    for m in "${MODULES[@]}"; do
      local dst_inc="$DST_ROOT/$variant/prefab/modules/$m/include"
      mkdir -p "$dst_inc"
      rsync -a --delete --include='*.h' --include='*/' --exclude='*' "$src_inc/" "$dst_inc/"
    done
  done
}

copy_libs_for_abi() {
  local module="$1"   # projectM-4 | projectM-4-playlist
  local abi="$2"
  local src_lib_dir="$SRC_ROOT/$abi/lib"
  [[ -d "$src_lib_dir" ]] || { echo "Warn: skip ABI '$abi' (no '$src_lib_dir')"; return 0; }

  # Release
  local rel_src="$src_lib_dir/lib${module}.so"
  local rel_dst_dir="$DST_ROOT/main/prefab/modules/$module/libs/android.$abi"
  mkdir -p "$rel_dst_dir"
  if [[ -f "$rel_src" ]]; then
    cp -f "$rel_src" "$rel_dst_dir/lib${module}.so"
    write_abi_json "$rel_dst_dir" "$abi"
  else
    echo "Warn: release lib missing for $module ($abi): $rel_src"
  fi

  # Debug (rename *d.so -> .so)
  local dbg_src="$src_lib_dir/lib${module}d.so"
  local dbg_dst_dir="$DST_ROOT/debug/prefab/modules/$module/libs/android.$abi"
  mkdir -p "$dbg_dst_dir"
  if [[ -f "$dbg_src" ]]; then
    cp -f "$dbg_src" "$dbg_dst_dir/lib${module}.so"
    write_abi_json "$dbg_dst_dir" "$abi"
  else
    echo "Warn: debug lib missing for $module ($abi): $dbg_src"
  fi
}

# --- MAIN ---
[[ -d "$SRC_ROOT" ]] || die "Source root '$SRC_ROOT' does not exist"
have_any_abi || die "No ABI folders found under '$SRC_ROOT'"

# Clean previously generated trees and dummy files
for m in "${MODULES[@]}"; do
  rm -rf "$DST_ROOT/main/prefab/$m" "$DST_ROOT/debug/prefab/$m"
done
rm -f "$DST_ROOT/main/prefab/prefab.json" "$DST_ROOT/debug/prefab/prefab.json"

# prefab.json (main + debug)
write_prefab_json "$DST_ROOT/main/prefab"
write_prefab_json "$DST_ROOT/debug/prefab"

# module.json per module (main + debug)
for m in "${MODULES[@]}"; do
  write_module_json "$DST_ROOT/main/prefab/modules/$m"
  write_module_json "$DST_ROOT/debug/prefab/modules/$m"
done

# Shared headers → both modules/variants
hdr_abi="$(pick_headers_abi)" || die "Could not find shared headers under any ABI (…/include/projectM-4)"
echo "Using shared headers from ABI '$hdr_abi'"
copy_shared_headers "$hdr_abi"

# Libs per ABI/module (+ abi.json)
for abi in "${ABIS[@]}"; do
  for m in "${MODULES[@]}"; do
    copy_libs_for_abi "$m" "$abi"
  done
done

echo "Done."
echo "Release prefab: $DST_ROOT/main/prefab"
echo "Debug prefab:   $DST_ROOT/debug/prefab"
