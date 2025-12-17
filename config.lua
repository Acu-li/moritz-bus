Config = {}

Config.Locale = "en"
Config.ESXShared = "esx:getSharedObject"

-- Branding (added)
Config.BrandPreset = Config.BrandPreset or "NBV"
Config.Branding = Config.Branding or {
    NBV = { Short = "NBV", Long = "Neuberg Verkehrsbund" },
}

Config.NPC = "a_m_o_genstreet_01"
Config.Vehicle = "bus"
Config.Speed = 20.0

Config.BlipSprite = 513
Config.BlipScale = 0.7 -- Important, in float numbers. (1.0, 1.2, 0.8, 2.0)
Config.BlipColour = 18


Config.DiscordWebhookName = "NBV Bus Logs"
Config.DiscordWebhook = "https://discord.com/api/webhooks/1450906530168832070/EpTXHvPSaXHqzgztppsEasDNv29eSL4nuUKoiyhRGglYXN3P7yYcB2eL-TNfHPPyb3d5"

Config.DiscordWebhookAvatar = "https://raw.githubusercontent.com/Acu-li/NBRP-Posters/refs/heads/main/Design%20ohne%20Titel%20(2).png" -- optional


-- Marker (added) - replaces 3D text schedule prompt
Config.Marker = Config.Marker or {
    Type = 2, -- small sphere
    Size = vec3(0.35, 0.35, 0.35),
    DrawDistance = 15.0,
    InteractDistance = 1.6
}

Config.Locations = {
    Station = {
        Name = "Bus station",
        Schedule = vector3(432.768, -657.847, 28.773),
        Departure = vector3(429.975, -640.151, 28.497),
        DepHead = 179.831,
        Arrival = vector3(458.296, -640.686, 28.459),
        Price = 50
    },
    CityHall = {
        Name = "City Hall",
        Schedule = vector3(-524.656, -264.015, 35.457),
        Departure = vector3(-523.237, -266.523, 35.298),
        DepHead = 114.326,
        Arrival = vector3(-492.301, -254.162, 35.638),
        Price = 50
    },
    Strawberry = {
        Name = "Strawberry",
        Schedule = vector3(252.341, -1199.939, 29.291),
        Departure = vector3(261.415, -1186.831, 29.485),
        DepHead = 92.497,
        Arrival = vector3(265.709, -1217.492, 29.412),
        Price = 50
    },
    Pier = {
        Name = "Pier",
        Schedule = vector3(-1606.135, -943.36, 13.307),
        Departure = vector3(-1612.139, -973.232, 13.013),
        DepHead = 319.012,
        Arrival = vector3(-1629.558, -974.232, 13.013),
        Price = 50
    },
    Sandy = {
        Name = "Sandy Shores",
        Schedule = vector3(1697.20, 3595.75, 35.60),
        Departure = vector3(1736.46, 3588.81, 34.75),
        DepHead = 302.39,
        Arrival = vector3(1714.46, 3598.20, 34.75),
        Price = 200
    },
    Paleto = {
        Name = "Paleto Bay",
        Schedule = vector3(-217.67, 6176.23, 31.20),
        Departure = vector3(-197.899, 6192.67, 31.06),
        DepHead = 133.02,
        Arrival = vector3(-192.45, 6224.068, 31.06),
        Price = 250
    }
}
