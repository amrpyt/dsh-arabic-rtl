#!/bin/sh
# Install / re-apply the DSH Arabic RTL client into the existing browser plugin slot.
# Safe to re-run after a DSH or plugin update: validates first, then swaps the file.
set -eu

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
src="$here/arabic-rtl.client.js"
[ -f "$src" ] || { echo "missing $src" >&2; exit 1; }

profile_name=${DSH_PROFILE:-web}
slot=${DSH_RTL_SLOT:-dsh-hebrew-rtl}

home=${DSH_HOME:-${HOME:?HOME is not set}/.dsh}

profile="$home/profiles/$profile_name"
dest="$profile/node_modules/$slot/lib/client.js"
[ -f "$dest" ] || {
  echo "missing $dest" >&2
  echo "Install the '$slot' plugin in profile '$profile_name' first." >&2
  exit 1
}
command -v node >/dev/null 2>&1 || { echo "node not found in PATH" >&2; exit 1; }

backup_dir="$profile/.dsh-arabic-rtl-backup"
mkdir -p "$backup_dir"
if [ ! -f "$backup_dir/client.js.orig" ]; then
  cp -p "$dest" "$backup_dir/client.js.orig"
  echo "backed up original client to $backup_dir/client.js.orig"
fi

tmp="$dest.new.$$.js"
cp "$src" "$tmp"
node --check "$tmp" >/dev/null
chmod 644 "$tmp"
mv "$tmp" "$dest"

echo "installed Arabic RTL + Tajawal client into $dest"
echo "refresh the DSH Web page (no process restart needed)."
