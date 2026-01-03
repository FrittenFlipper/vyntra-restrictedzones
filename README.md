# vyntra-restrictedzones

A lightweight and optimized resource for FiveM that handles restricted zones and prohibited areas. This script allows players to, complete with database integration.

## Features

-   **Zone Management:** Define multiple restricted areas with custom coordinates and radius.
-   **Database Integration:** Loads zone data or permissions directly from the database.
-   **Job Permissions:** Whitelist specific jobs (e.g., Police, EMS) to bypass restrictions.
-   **Optimized Performance:** Low CPU usage (0.00ms idle).

## Requirements

Before installing, ensure you have the following resources installed:

-   oxmysql (or mysql-async)
-   [ESX Legacy]

## Installation

Follow these steps to install the resource on your server:

1.  **Download and Extract:**
    Download the repository and extract the `vyntra-restrictedzones` folder to your server's `resources` directory.

2.  **Database Setup:**
    Import the provided SQL file into your database to create the necessary tables.

    -   File: `restrictedzones.sql`

3.  **Configuration:**
    Open `cl_main.lua` and `sv_main.lua` to adjust specific settings if necessary (e.g., notification texts, zone radius, or authorized jobs).

4.  **Server Config:**
    Add the resource to your `server.cfg` file. Ensure it is started after your database resource.
    ```cfg
    ensure vyntra-restrictedzones
    ```

## Usage

Once the script is running, the restricted zones defined in the code or database will be active. Players entering these zones without the required job/permission will receive a notification or face the configured consequences.

## Troubleshooting

-   **Zones not appearing?** Check your server console (F8) for any SQL errors. Ensure the table from `restrictedzones.sql` exists in your database.
-   **Script errors:** Make sure you are using the correct framework version (ESX).

## Disclaimer

This software is provided for entertainment purposes only. The authors are not responsible for any damage caused to your server or data. Use at your own risk. By using this resource, you agree to these terms.
