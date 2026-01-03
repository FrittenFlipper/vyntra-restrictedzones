Config = {}

-- Command Configuration
-- The command used to open the restricted zone management menu.
Config.CommandName = "restrictedzone"

-- Authorized Jobs
-- A list of jobs that are granted permission to access and manage restricted zones.
-- Format: ["job_name"] = true
Config.AllowedJobs = {
    ["police"] = true,
    ["fib"] = true,
}

-- Radius Constraints
-- Defines the minimum and maximum radius allowed for a restricted zone.
-- Users cannot create zones outside of these bounds.
Config.Radius = {
    min = 1,
    max = 500
}

-- Blip Configuration
-- Settings for the visual representation of the restricted zone on the map (Blip).
-- Refer to the FiveM documentation for Blip IDs and Colors.
Config.Blip = {
    sprite = 60,      -- Blip ID 60: Standard "Restricted Zone" symbol (Circle with a slash).
    color = 1,        -- Color ID 1: Red.
    alpha = 128,      -- Opacity level of the blip (0-255).
    scale = 1.0,      -- Size scale of the blip.
    display = 4,      -- Display behavior ID 4: Visible on both the main map and minimap.
    shortRange = true -- If set to true, the blip is only visible on the minimap when near the location.
}

-- Notification Settings
-- The texture dictionary name for the notification icon (e.g., CHAR_CALL911 for police/emergency).
Config.NotificationIcon = "CHAR_CALL911"

-- Localization / Text Labels
-- Strings used for UI elements, menus, and notifications.
-- You can translate these into your preferred language.
Config.Labels = {
    menu_title = "Restricted Zone Menu",
    create_zone = "Create Restricted Zone",
    view_zones = "View Restricted Zones",
    yes = "Yes",
    no = "No",
    no_active_zones = "No active restricted zones",
    get_back = "Back",

    -- Input Dialogs
    enter_title = "Enter Title",
    enter_desc = "Enter Description",
    enter_radius = "Enter Radius (%d-%d)",

    -- Validation Messages
    valid_radius = "You must specify a valid number for the radius!",
    radius_range = "Radius must be between %d and %d!",
    radius_whole = "Radius must be a whole number!",
    missing_title = "You must specify a title!",
    missing_desc = "You must specify a description!",

    -- Actions
    delete_confirm = "Delete Restricted Zone?",
    zone_deleted = "Restricted Zone deleted.",

    -- Notifications
    no_perms = "You do not have permission to access the menu!",
    notification_title = "Restricted Zone",
    notification_subtitle = "Attention",
    notification_body = "%s. The restricted zone is located at ~y~%s~w~."
}
