# genshin-wish-link-linux

Get your Genshin Impact wish history link on Linux so you can import it into [paimon.moe](https://paimon.moe/wish/import) (or any other wish tracker).

It does the same thing as the official Windows PowerShell script, but for the game running through Steam/Proton, Wine, Lutris, or Heroic.

## Usage

1. Start the game, open **Wish → History**, and wait for the page to load.
2. Run:

   ```sh
   curl -sL https://raw.githubusercontent.com/faizalindra/genshin-wish-link-linux/main/getlink.sh | bash
   ```

   Or download it and run it:

   ```sh
   chmod +x getlink.sh
   ./getlink.sh
   ```

3. The link is copied to your clipboard. Paste it into paimon.moe.

If the game's `output_log.txt` is outside your home folder, pass its path:

```sh
./getlink.sh "/path/to/pfx/drive_c/users/steamuser/AppData/LocalLow/miHoYo/Genshin Impact/output_log.txt"
```

## Requirements

`bash`, `curl`, GNU `grep` (with `-P`), GNU `find`, and one of `wl-copy`, `xclip`, or `xsel` for the clipboard. If none of those is installed, the link is printed instead.

## How it works

1. Finds the newest `miHoYo/Genshin Impact/output_log.txt` inside a Wine/Proton prefix under `$HOME`.
2. Reads the game folder's Windows path from the log and turns it into a Linux path through the prefix's `dosdevices` links.
3. Opens the newest `GenshinImpact_Data/webCaches/*/Cache/Cache_Data/data_2` and takes the last `getGachaLog` URL in it.
4. Checks that the link still works with Hoyoverse's API, then copies it to the clipboard.

The script only reads files. It doesn't change anything in the game folder or the prefix.

## Notes

- Only the global (Hoyoverse) client is supported. The China client (`YuanShen`) isn't.
- The link contains an `authkey` that gives read access to your wish history until it expires, usually within about a day. Don't post it publicly.

## Credits

Based on [MadeBaruna's PowerShell script](https://gist.github.com/MadeBaruna/1d75c1d37d19eca71591ec8a31178235) for [paimon.moe](https://paimon.moe).

## License

MIT
