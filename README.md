# Flipbook early builds

Flipbook is a Mac menu-bar app. Hold or double-tap Right ⌘, reproduce a bug, and drag the card it gives you into Claude Code, Cursor, or ChatGPT: one screenshot per step, each captioned with what you did.

These are early builds for friends who are trying it out. This repo holds the app and its installer only; there's no source code here.

## Install or update

Paste this into Terminal:

```
curl -fsSL https://raw.githubusercontent.com/fayzan123/flipbook-releases/main/install.sh | sh
```

It downloads the latest build, checks its signature, puts Flipbook in your Applications folder, and opens it. Run the same line again to update; your permissions carry over.

Flipbook needs an Apple silicon Mac (M1 or later) with macOS 15 or later.

## First run

Flipbook asks for three permissions. After you grant Screen Recording and Input Monitoring, it offers Quit & Reopen, because macOS applies those two only after a relaunch.

- **Screen Recording** lets it record.
- **Input Monitoring** lets it notice Right ⌘, clicks, and keys while you record. It never records what you type.
- **Accessibility** lets it name the buttons you click, and keep ⌘ out of your clicks while you hold the key.

Then double-tap Right ⌘, click through something, and double-tap again. A card appears at the bottom right of your screen; drag it into a chat. Holding Right ⌘ works too, for quick ones, and Right ⌘ + Esc cancels.

## Privacy

This build never connects to the internet. Recordings stay on your Mac in `~/Pictures/Flipbook`, and move to the Trash after 30 days.

## Feedback

Tell Fayzan what happened. If something broke, send the log too: `open -R ~/Library/Logs/Flipbook.log` shows it in Finder. The log never contains button names, window titles, or keys.

## Uninstall

Quit Flipbook from its menu-bar icon and delete it from Applications. To remove its permissions as well, run `tccutil reset All com.fayzanmalik.flipbook`.
