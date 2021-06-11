# PDKP Database Structure

## Databases
- [guildDB] - Individual member data
- [dkpDB] - DKP History
- [pugDB] - Pug Member Data
- [settingsDB] - Addon Settings
- [testDB] - Development DB

## GuildDB
The guild DB contains information regarding the individual members in the guild, things that can't be quickly queried via blizzard API.
### Member
````
['guildDB'] = { -- table
    ['members'] = { -- table
        ['Neekio'] = { -- table
            ['total'] = 30 -- int, dkp total
            ['deleted'] = { -- table
            }
            ['entries'] = { -- table
            
            }
            ['lockouts'] = { -- table
                ['Magtheridon'] = { -- table
                    ['id']: 651 -- int, boss id
                    ['lastCredit'] = 157 -- int, day of the year
                    ['availableOn'] = 
                }
            }
        },
        ...
    },
    ['numOfMembers'] = 418 -- int
}

##


    PDKP.dbDefaults = {
        ['global'] = {
            ['db'] = {
                ['guildDB'] = {
                    ['members'] = {},
                    ['numOfMembers'] = 0
                },
                ['pugDB'] = {},
                ['officersDB'] = {},
                ['dkpDB'] = {
                    ['lastEdit'] = 0,
                    ['history'] = {},
                    ['old_entries']= {},
                },
                ['settingsDB'] = {
                    ['minimapPos'] = 207,
                    ['debug'] = false,
                    ['ignore_from']={},
                    ['minimap']={},
                    ['sync'] = {
                    ['pvp'] = true,
                    ['raids'] = true,
                    ['dungeons'] = true
                    },
                    ['notifications'] = true,
                    ['debug'] = false,
                },
                ['testDB']={},
            }
        }
    }

