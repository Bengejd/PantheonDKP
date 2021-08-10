### Benched Logic
Players can set themselves as being "benched" in game, this requires them to login onto their main character, and mark themselves as "benched".
They can then, play any other character on their account that has the PDKP addon enabled, and is in the guild. They must be online within +- 5 minutes of a boss kill in order to receive DKP for that kill.
Officers can request that they join the raid group via a "request" button. The benched list will be accessible via the raid-tools frame.
---
### TODO:

#### Nice To haves:
- [ ] Enable marking one's self as "benched".

## TODO:

##### Comms
- [ ] Disable Comms while in non-guild party, raid or battleground.
- [ ] Unregister DKP WhoIsDKP after it has been set, but re-register when joining group.

#### Auctioning
- [ ] Tooltip hover on Bid item.
- [ ] Add ability to remove "faulty" bids.
- [ ] Add ability to re-calculate who was the winner.
- [ ] Add Bid Headers to the bidders window. Name | Bid | Cost
- [ ] Calculate cost based on the winner's principle.
- [ ] Tooltip when hovering over items if AuctionManager:CanChangeAuction()
- [ ] Fix Overwrite, so that you don't have to /reload anymore after it processes.
- [ ] Allow for different Decay Amounts.
- [ ] Add Lockouts Tab
- [ ] Add Options Tab

#### DKP Overhaul
- [x] Fix DKP submissions giving the incorrect DKP totals.
- [x] Deleting a decay entry & merging does not appear to send the new entry until after /reload?
  - [x] Entry totals are incorrect after re-calibrating as well, for the receiver.
- [x] Fix Decay Deletion previousTotal BUG
  - [x] Probably need to use recalibrate after the decay deletion.

#### Complete Todo Items
- [x] Add 10 seconds to bid button.
- [x] Sort the bids by amount after the bidding has ended.
- [x] Bid Windows not clearing old bids (visual artifact).
- [x] Allow for the Sync Timer to be movable.
- [x] Sync Timer not going away for Merge/Overwrite after completion.
- [x] Add "bid" chat message filters to auto-add people who didn't use addon.
  - [x] !bid # - Bid a certain amount in whispers.
  - [x] !bid cancel - Cancel a bid after it has been submitted.
  - [x] !dkp - Send the msg author's DKP total.
  - [x] !cap - Send the Guild DKP Cap and the Raid DKP Cap.
---



TBC UPDATES:
    
    TODO: One Singular DKP sheet, for all raids.
    TODO: DKP will only apply to 25 mans.
    TODO: No on-time bonus (remove button).
    
    TODO: Minimum Bid is 1
    TODO: If no other bids, bid is minimum.
    TODO: 10 DKP per boss kill.
    TODO: Everyone will have 30 DKP automatically in the TBC Update Including Alts, and new guild members.
    TODO: Benched DKP is full DKP.

    TODO: Decay is set at 10% per week, on Tuesdays, rounded down.
    TODO: Manual DKP decay of 50% at the start of a new raid tier.
    TODO: Bids will be hidden until the countdown is finalized. This can be manually overridden by the DKP master, Master looter or Raid Leader.
    TODO: Bids of 9 or less will not carry any loot priority.

    TODO: Alt-standby list
    TODO: Alt associations
    TODO: Sync library: https://github.com/SamMousa/lua-eventsourcing
    TODO: No longer allow deletes to occur in the database, mark them as deleted and add a new sync entry?
    TODO: "Deleted" entries should be moved to a "deleted" DB that is load-on-demand?
    TODO: Update PDKP GUI to be more "sexy" and slimming.


TBC UPDATES DONE:
    
    - Added boss/raid ID's
    - Added Shaman Class
    - Fixed Class Checkbox layout to be 3x3 instead of 4x2


TRY TO FIX:
    
    TODO: Throttle the shrouding window updates, so that people don't get lost / overwritten.
    TODO: Allow edits of entries.

NICE TO HAVES:
    
    TODO: Whisper command !pdkp that will send back the player's DKP totals.
    TODO: Add an edit box in the settings window, that takes you to the issue tracker.
    TODO: Roster list in addon screen.

MAKING IT MORE PUBLIC:
    
    TODO: Enable PUGS
    TODO: Make PDKP More Generic, so that other guilds can use it.
    TODO: Allow name change
    TODO: Allow logo change
    TODO: Change who the bank alt is
    TODO: Setup screen for new guilds.
    TODO: Change command to bring it up (GM ONLY)
    TODO: Show Pugs in table filters
    TODO: On time bonus DKP: 10 (int or %)
    TODO: Signup bonus DKP: 10(int or %)
    TODO: Boss kill DKP 10(int or %)
    TODO: Benched DKP: (int or %)
    TODO: Item Win: 10% (int or %)
    TODO: Shroud: 50% (int or %)
    TODO: No call / No show: 20% (int or %)
    TODO: Absence (Excuse): 15%
    TODO: Options table for changing Raid DKP amounts.

NEAT ADDON IDEAS:
    
    RAID ASSIGNMENTS:
       Allows you to assign particular people to healing (MainTank, RaidHealers, etc...)
       Interface of what healers are in the raid (Paladins, Priests, Druids)
       Recommended healers based on what their class is / how many healers are already assigned.
       RaidWarning when certain healers are dead ("MainTank Healer XYX is down")
       Allows healing assignments to change per fight / boss
       Allow assignments for dispels, decurses, deposions.
       Allow assignments for sheep / hibernates.
       Auto mark targets based on name and mouse-overs (Hibernates / Sheeps based on target name).

       - Go to Other, If you put the amount before you put the text in, So it doesn't lock up.
