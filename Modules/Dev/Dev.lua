local _, PDKP = ...

local LOG = PDKP.LOG
local MODULES = PDKP.MODULES

--@do-not-package@

local Dev = {}
Dev.DEV_NAMES = { ['Neekio'] = true, ['Lariese'] = true }


-- Publish API
MODULES.Dev = Dev
--@end-do-not-package@