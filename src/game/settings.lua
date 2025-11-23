local M = {}

M.DEBUG = true

M.player = {}
M.player.size = { w = 50, h = 50 }
M.player.color = { 1, 1, 1 }
M.player.projectileSpeed = 100 -- in pixels, when to make it teleport
M.player.safeTime = 3          -- in s

M.enemy = {}
M.enemy.spawnChance = 20 -- in %
M.enemy.spawnDelay = 1   -- in s
M.enemy.speed = 100
M.enemy.speedOffset = 50
M.enemy.harderDelay = 30 -- in s

M.centerFrame = {}
M.centerFrame.size = { w = 40, h = 40 }

M.fonts = {}
M.fonts.quirkyRobot = "assets/fonts/QuirkyRobot.ttf"
M.fonts.semiCoder = "assets/fonts/SemiCoder.otf"
M.fonts.courierPrimeCode = "assets/fonts/CourierPrimeCode/Courier Prime Code.ttf"
M.collision = {}
M.collision.enemy = 2
M.collision.projectile = 4
M.collision.centerFrame = 8
return M;
