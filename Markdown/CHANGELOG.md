# PDKP Change Log
## v4.4.2
### Features
- Turned on 90% Max DKP Bid restriction (See discord for more info).

### Bug Fixes
- Fixed "Promote Leadership" button.

## v4.4.1
### Features
- Turned on Phase 2 bosses
- Turned on Phase Decay (50%) adjustment reason
- Expose chat commands for /pdkp help

### Bug Fixes
- Decay entries will not decay members who have less than 31 DKP.
- The "Load More" button now visually loads the entries correctly.
- PUG invite messages won't be filtered out by default anymore.
- Swapping the entry reason from Decay to Item Win will no longer cause a visual freak out (negative zero)
- Fixed some "Interface failed because of addon" issues... even though it's blizzard's fault, not addons...
- Incremented the Interface #

## v4.3.3
### Features
- Added Github hook to notify discord of new PDKP updates!

### Bug Fixes

- Fixed a bug where you could not start auctions from the boss loot bag while having ElvUI enabled.
- Fixed a bug where promoting leadership in the raid, would promote a bunch of people (most likely a guild permissions issue, not the addon).
- Fixed a bug where some users would receive an error when receiving a whisper due to invite_commands not being populated.

## v4.3.2

### Features (NEW)
**Whisper Commands**: You can now whisper the DKP Officer a few different commands, such as:
- `!bid 20` - To bid 20 DKP for the current item being bidded on.
- `!bid max` - To bid your **MAX** DKP on an item
- `!bid cancel` - To cancel a previous bid you've sent in.
- `!cap` - To find out what the Guild DKP Cap is, as well as the raid DKP cap.
- `!dkp` - To find out what the DKP Officer has your dkp as.

These whispers will be filtered out from their chat log, so they will never see the amount of DKP that you bid.

**Add Auction Time**: You can now add 10 seconds to an auction if you have a designated role within the raid (DKP officer, raid leader or loot master).

**Movable Sync Timer**: You can now move around the sync-timer, so it's no longer stuck at the top of the screen.

**Auto Invite Chat Filter**: Auto-invite whispers will be automatically filtered out of the receivers window.

### Bug Fixes
- Fixed a bug where syncing deleted decays were not happening correctly.
- Fixed a bug in Ace3:Serializer where table serialization was not happening the same across clients, resulting in the comparison hashes to be off, even when identical.
- Fixed a bug where the boss-kill popup was not occurring for the DKP Officer in raids where it should have been.
- Fixed a bug where the Bid window would appear when on a low-level alt.
- Fixed a visual bug where old-bids were still showing up on non-officer bid windows after a new bid was started.
- Fixed a visual bug where bids weren't being sorted from highest to lowest after bidding window finished.
- Fixed a bug where auto-invites would break occasionally when you deleted your saved variables file.
- Fixed a bug where auto-invites would not hide the "accept" window, after you were already invited to the party.
- Fixed a bug where deleting a decay entry would sometimes give people the wrong DKP amount back, lowering their previous DKP by 1 (math is dumb) in certain edge-cases.
- Fixed a bug where deleting an entry would cause those who did not have the entry to ignore the deleted entry, but accept the "corrected" version of it, resulting in a net-positive DKP-gain on their totals instead of a zero-sum difference.
- Fixed a bug where your client would lock up for 10 or so seconds when receiving a DKP `merge`, this may still occur but at a much quicker rate.
- Fixed a bug where deleting a boss kill entry would not allow you to re-apply that boss kill for members in that raid group within the same week.

### Disabled (RIP)
Auto-syncing - Auto Sync is currently disabled until lag spike issues can be resolved.

---
## v4.0.0

#### PUGS
Pugs are now able to be added to entries, and receive DKP in the database. They will not have a displayed class unfortunately, due to limitations of the WoW API for requesting this data when they are not in the group.

PUG names will be prefixed with a (P). Example: (P) Pantheonbank

This also means that members who are no longer in the guild, will also be considered PUGS in terms of the database, and will be displayed as such.

#### Members Filters
- Shaman Class Filter Added
- PUG filter added

#### History Tab
- History tab now will only display entries that are either boss kills, or other misc entries.
- Collapsed text format goes as follows:
    - Officer Name | Raid Name (if applicable) | Boss Name (if applicable) or Reason text.
- Entries that have occurred within the last 4 weeks will be displayed to mitigate lag upon logging in. You can click "Load More" to load older entries.

#### Loot Tab
- Loot tab now will only display entries that are related to item wins.
- Collapsed text format goes as follows:
    - Officer Name | Winner Name | Item Link
- Entries with linked items, can be clicked just like any other item link in game.

#### Item Bidding
When an Officer starts a new auction, you will be presented with the Bidding Window, similar to the shrouding window. This window will display your total DKP, for ease of use.

In this window, you can submit your bid, update your bid, cancel your bid, and view who the other bidders are and how much DKP they currently have, but not what their bid is.

Alternatively, if you've accidentally closed the window you can re-open the window via: `/pdkp bid`

Additionally, you can submit a bid via chat by typing `!bid yourBidAmount`. This can either be sent via a whisper, or just put in raid-chat.
These messages will automatically be filtered out of chat, so no one else will see your bid, but the addon will capture it and register it none the less. `/say` and `/yell` will not filter the message, but it will be registered.

### Officer Notes:

These are things mostly relevant for Officers, but you can read it if you want.

#### Entry Preview
- When creating new DKP entries, you'll have a realtime preview of its details.
- The preview will also let you know if the entry is valid or not, and try to help you find out why.

#### Entry Adjustments
- Adjustment Reasons
    - Boss Kill: Disables the amount input box, and sets the amount to 10, automatically.
        - Populates a nested dropdown where level 1 is the raid name, and level 2 is the boss name. Much simpler than previous iterations.
    - Item Win: Automatically makes the amount to a negative (Can't earn DKP from spending it, eh?)
        - Also populates an input box for the item name. This will automatically be populated with the item link that is currently up for auction, but can be empty or just the name of the item.
    - Other: Nothing new here. You can submit with or without a description. Preferably with though.
    
#### Raid Tools
- Ignore PUGS checkbox:
    - Checking this will ignore invite requests from people who are not in the guild. Enabled by default.
- Reformatted the icons positioning
- Added in DKP Officer icon.
- Added in Shaman class icon.

#### Item Auctioning
Item bidding can be started via the following methods:
- Holding Alt while Left clicking an item either in your bags, or in the loot bag.
- Typing `/pdkp bid ItemLink` (super reliable)
- Typing `/pdkp bid ItemName` (this one is less reliable, unless the name is exact)

Auctions will last for 10 seconds, during which time a timer will be displayed on the screen. If you are the master looter, and the DKP Officer, a popup will appear at the end of the timer, asking if you would like to loot the item to the winner.
This will also create and submit a new item-win entry for said winner. Otherwise, you'll have to loot it & then create the entry manually.

You can also manually end the bidding early, by clicking the button on the bottom of the Bidding Window.

#### DKP Decay

### Nerd Stuff
This section is mostly just for people who want to learn more about the inner workings of PDKP. If you don't care, you can just stop reading now.

#### Multiple Guilds
The database is now compatible with other guilds, factions and servers. This is done by a uniqueID database with the format of `server_faction_guild`. For example, ours is `Blaumeux_Alliance_Pantheon`.

#### Syncing
Syncing is always a tricky issue to handle without having an external master database. 

To overcome the state-management issue, on a weekly basis (starting on Tuesdays) entries from the previous week are used to create a unique hash. Instead of broadcasting all of your entry ID's, you will instead broadcast the last four weeks worth of weekly hashes. 

When another officer broadcasts their last four weeks worth of hashes, your addon will compare theirs to what you have. If your hashes do not match up, both of you will begin diving into that week's entries to find out where the discrepancy is. Once the discrepancy(s) is found, you will both broadcast whatever data the other is missing. This data will be consumed by all guildies that are currently online, to ensure that their database is also up to date.

I also made the decision to take out the deletion of entries. Entries are now marked as deleted, and will no longer show up in the database, but everyone will keep that record in their database.

#### Entry Encoding
DKP databases grow quite large when in an active raiding guild. You receive an entry for every boss kill, and every item won, every single raid.
This quickly becomes a problem because the larger your SavedVariables (database) file is, the longer your load screens will be. This is mostly due to how LUA handles memory management, but that's neither here nor there.

To overcome this issue, all entries in the database will automatically be encoded and compressed when they are created. 

To compare the difference this makes in the size of the database file, previously, a non-encoded file with 890 entries would be `1,021 KB` in size, where as the encoded entries have a size of just 238 KB.

#### Entry Decoding
Decoding entries is a very memory-intensive task. To combat this, only the entries that have occurred in the last 4 weeks are decoded from the start for history viewing purposes. This does not affect the sync hashing algorithm.
