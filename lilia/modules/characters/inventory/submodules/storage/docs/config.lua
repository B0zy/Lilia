--- Configuration for Storage Module.
-- @configurationmodule Storage

--- This table defines the default settings for the Storage Module.
-- @realm shared
-- @table Configuration
-- @field SaveStorage Enable or disable the saving of storage data | **bool**
-- @field PasswordDelay Set the delay (in seconds) until password retries are allowed | **integer**
-- @field StorageOpenTime Set the duration (in seconds) for how long a storage container takes to open | **number**
-- @field TrunkOpenTime Set the duration (in seconds) for how long a trunk takes to open | **number**
-- @field TrunkOpenDistance Set the distance a trunk must be to be opened | **integer**
-- @field StorageDefinitions List of props that will become storaged when spawned | **table**
-- @field VehicleTrunk List of settings for car trunks | **table**
