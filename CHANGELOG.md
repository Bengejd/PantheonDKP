# PDKP Change Log

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

To compare the difference this makes in the size of the database file, previously, a file with 890 entries would be 1,021 KB in size, where as the encoded database has a size of just 238 KB

#### Entry Decoding
Decoding entries is a very memory-intensive task. To combat this, only the entries that have occurred in the last 4 weeks are decoded from the start for history viewing purposes. This does not affect the sync hashing algorithm.
