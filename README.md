# Treasure Magnet Vacuum

**Version 1.0.0 — ROXASBrandon**

Turn Treasure Magnet into a powerful vacuum for dropped items, HP/MP orbs, and
munny. Its **500x pickup radius** is intended to cover normal rooms, so you can
fight and explore instead of chasing drops.

## Features

- Patches both dropped-item and separate HP/MP/munny orb collection paths.
- Uses a radius of 100,000 game units with one equipped magnet and 200,000
  with two or more, compared with the original 200/400.
- Affects party members using the same native collection paths.
- Does not grant abilities, change AP costs, or change AP capacity.
- Preserves shared game constants and checks signatures before patching.

**Own and equip Treasure Magnet first.** Use Treasure Magnet Starter alongside
this mod if you also want an early unlock and zero AP cost.

Native pickup animation, delays, and non-distance restrictions still apply.
This does not open chests, create drops, or collect across unloaded rooms. One
orb pickup mode reuses the same range register and receives the expanded
radius even without Treasure Magnet equipped.

## Requirements

- Kingdom Hearts Final Mix from **Steam**, **Global/WW version 1.0.0.2**.
- LuaBackend installed and working. OpenKH Mods Manager is recommended.
- This release has not been ported to Epic Games, Steam JP, PS2, or other builds.
  The script checks the executable and refuses unsupported versions.
- No extra Lua library or companion script is required.

## Installation

Choose **one** method:

1. **OpenKH / GitHub:** select Kingdom Hearts 1 in Mods Manager, open **Mods >
   Install new mods**, and enter `ROXASBrandon/KH1FM-Treasure-Magnet-Vacuum` in the GitHub field.
   Click **Install**, enable the mod, then **Mod Loader > Build and Run**.
   You can also import the release ZIP or standalone Lua through the archive
   option instead. For updates, use **Settings > Check Mods for Updates** and
   rebuild your KH1 mod list.
2. **Manual LuaBackend:** copy the script from this archive's `scripts` folder to
   `Documents\My Games\KINGDOM HEARTS HD 1.5+2.5 ReMIX\scripts\kh1`.
   Your LuaBackend configuration must load that folder. Restart KH1.

Press **F2** for LuaBackend confirmation messages. Install a given script only
once; do not use the OpenKH and manual methods simultaneously.

If upgrading from the earlier combined script, remove/disable
`kh1_early_treasure_magnet.lua` first. These two standalone mods can be used
individually or together. Do not also enable another mod editing the same
Treasure Magnet behavior; changed signatures can make the patch skip.

## Confirmation and removal

F2 should show **VACUUM active for items AND HP/MP/munny orbs**. A signature
mismatch message means another build or conflicting patch was detected; this
script will skip its range patch.

Close KH1 and remove/disable the script to restore normal range on the next
launch. The range patch exists only in memory; it does not change saves or
patch game archives on disk.

## Verification

The original combined implementation was confirmed working in gameplay on
Steam Global 1.0.0.2, including the huge collection radius. The separate script
passed byte-accurate Lua 5.4 checks for both range paths, signed displacements,
repeat loads, mismatched signatures, and independence from the Starter mod.
The separate package has not yet received a fresh gameplay verification after
extraction.

See `CREDITS.md` for reference credits and `CHANGELOG.md` for release notes.

## Companion repository

https://github.com/ROXASBrandon/KH1FM-Treasure-Magnet-Starter
