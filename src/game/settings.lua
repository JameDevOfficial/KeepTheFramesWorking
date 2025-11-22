local M = {}

M.DEBUG = true

M.player = {}
M.player.size = { w = 50, h = 50 }
M.player.color = { 1, 1, 1 }
M.player.screenPadding = 25
M.player.projectileSpeed = 100000 -- in pixels, when to make it teleport
M.player.startLives = 3
M.player.safeTime = 3             -- s

M.fonts = {}
M.fonts.quirkyRobot = "assets/fonts/QuirkyRobot.ttf"
M.fonts.semiCoder = "assets/fonts/SemiCoder.otf"

M.collision = {}
M.collision.player = 1
M.collision.enemy = 2
M.collision.projectile = 4
return M;
