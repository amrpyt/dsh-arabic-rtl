# DSH Arabic RTL + full Tajawal

Arabic/Hebrew bidi and full Tajawal typography for the **DeepSeek Harness Web GUI**.

It decides direction by **prose word dominance**, not by the first strong character, so a line like
`Hello كيف حالك` or `Error: فشل الاتصال` reads right-to-left instead of leaving Arabic stranded on the
wrong side. Code, paths, URLs, versions and terminals stay LTR and isolated. The whole UI — Arabic and
English, headings, chat/session names, composer, menus, tables and code — uses **Tajawal** embedded in
the client (no external font files, no dist rewrite).

Tested against DSH `0.2.2-rc.1` (Web, profile `web`). Client-only: no host rows, no server restart.

## Demo / what it fixes

| Before | After |
| --- | --- |
| `Hello كيف حالك` starts LTR (first-strong) | starts RTL, `Hello` at the right |
| list markers left, text right in mixed RTL lists | markers and text agree |
| Arabic report tables forced monospace / left-aligned | Tajawal, RTL columns, `text-align:start` |
| Arabic inside `code` uses a system fallback | Tajawal for Arabic, monospace for Latin code |
| English UI still Latin-only font | full Tajawal everywhere |

## Requirements

- DeepSeek Harness Web `0.2.2-rc.1` (the layer is loaded as a browser client bundle).
- The `dsh-hebrew-rtl` plugin slot installed in the target profile. This project **replaces that slot's
  `lib/client.js`** with the Arabic/Hebrew engine, so the profile graph and plugin id do not change.
  Install the slot first if needed:

  ```sh
  dsh plugin --profile web add github:kfirsch/dsh-hebrew-rtl
  ```

- `node` in `PATH` (used for the pre-flight `--check`).

## Install

```sh
git clone https://github.com/amrpyt/dsh-arabic-rtl.git
cd dsh-arabic-rtl

# Normal user profile:
./install.sh

# Or point it at another profile / slot:
DSH_HOME=/home/dsh/.dsh DSH_PROFILE=web DSH_RTL_SLOT=dsh-hebrew-rtl ./install.sh
```

If the profile is owned by another user, run the installer as root with `DSH_HOME` set (the script
writes the plugin file with mode `644`).

Then refresh the DSH Web page. No process restart is needed; the browser client registry re-reads the
bundle on refresh.

## Surviving DSH / plugin updates

- The font is **base64-embedded in `arabic-rtl.client.js`**, so a DSH update cannot delete the font from
  `dist/assets/fonts`.
- An update may replace the profile's plugin client. Re-run `./install.sh` afterwards; it backs up the
  new original once and swaps in the layer again.
- It never edits `@deepseek-ai/dsh-web-frontend` CSS or any other file under the DSH install.
- If the profile itself is recreated, reinstall the `dsh-hebrew-rtl` slot and run the installer again.

## Rollback

The first install backs up the original slot client to:

```
$DSH_HOME/profiles/$DSH_PROFILE/.dsh-arabic-rtl-backup/client.js.orig
```

Restore it and refresh:

```sh
cp ~/.dsh/profiles/web/.dsh-arabic-rtl-backup/client.js.orig \
   ~/.dsh/profiles/web/node_modules/dsh-hebrew-rtl/lib/client.js
```

Set `DSH_HOME`/`DSH_PROFILE` as appropriate. The backup is never overwritten by later runs.

## What it does

- Word-dominance classifier over whitespace tokens; code-like tokens do not vote (URLs, paths,
  `@scope/pkg`, versions, ratios, SHAs, hex).
- `unicode-bidi:isolate` + `direction:rtl` written inline with `!important`, so pre-existing
  `unicode-bidi:plaintext` CSS cannot win.
- `pre`, `code`, `kbd`, `samp`, terminals and tables keep their own LTR/isolated direction.
- Lists and tables judged as containers; in a Latin-dominant table, an Arabic-only cell is marked
  individually without reordering the columns.
- Table header verdict: a mostly-Latin table with an Arabic header row is treated as RTL so report
  columns keep the Arabic reading order.
- Composer/Lexical paragraphs, text inputs and textareas get per-line direction; caret Left/Right
  handling is preserved for RTL lines.
- Chrome/controls (toolbars, option rows, dialogs) keep their LTR geometry; text cells inside them can
  still be RTL.
- Full Tajawal (400/500/700, OFL) applied to `html, body, body *` and code/pre/kbd/samp.

## Tests

No dependencies:

```sh
node tests/golden.mjs
```

The suite runs the real injected client against 45 golden direction cases (including known limits) and
must print `45/45 golden cases passed`.

## Known limits

- Shell chrome (sidebar, top bar, menus, search results) stays LTR by design; Arabic titles have correct
  internal RTL order but keep chrome alignment. Mirroring the shell is a much larger layout change.
- `xterm`/terminal output cannot shape Arabic; terminals stay LTR.
- A bare Latin command sequence with no Arabic prose does not flip (`شغّل git status` stays LTR); this
  is the upstream engine's documented trade-off, not a regression.
- The installer targets the `dsh-hebrew-rtl` slot; a standalone `dsh-arabic-rtl` plugin package is not
  shipped yet.

## Credits

- Bidi engine: [dsh-arabic](https://github.com/SMSMy/dsh-arabic) 0.4.6 by SMSMy (MIT), commit
  `2a88efe41fe7f1fcb1dede1220843155bab8881c`.
- Plugin slot: [dsh-hebrew-rtl](https://github.com/kfirsch/dsh-hebrew-rtl) by Kfir Schneider (MIT).
- Font: [Tajawal](https://github.com/google/fonts/tree/main/ofl/tajawal), SIL Open Font License 1.1.
- Local integration, full-Tajawal layer, table/list/code fixes and installer: amrpyt.

## License

MIT for this project's code. The vendored bidi engine and plugin slot are MIT (see
`THIRD_PARTY_NOTICES.md`). Tajawal is OFL-1.1; see `fonts/TajawalFull-OFL.txt`.
