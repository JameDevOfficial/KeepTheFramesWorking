local M = {}

M.DEBUG = true

M.player = {}
M.player.size = { w = 50, h = 50 }
M.player.color = { 1, 1, 1 }
M.player.screenPadding = 25
M.player.projectileSpeed = 100 -- in pixels, when to make it teleport
M.player.startLives = 3
M.player.safeTime = 3          -- s

M.enemy = {}
M.enemy.spawnChance = 20 -- in %
M.enemy.spawnDelay = 1 -- in s  
M.enemy.speed = 100

M.centerFrame = {}
M.centerFrame.size = { w = 40, h = 40 }

M.fonts = {}
M.fonts.quirkyRobot = "assets/fonts/QuirkyRobot.ttf"
M.fonts.semiCoder = "assets/fonts/SemiCoder.otf"
M.fonts.courierPrimeCode = "assets/fonts/CourierPrimeCode/Courier Prime Code.ttf"
M.collision = {}
M.collision.enemy = 2
M.collision.projectile = 4
return M;
