-- ============================================
--   Nathan's Autofarm | main.lua (Loader)
--   Jalankan file ini dari executor
-- ============================================

-- Ganti USERNAME dan REPO sesuai milik kamu
local BASE = "https://raw.githubusercontent.com/USERNAME/REPO/main/"

loadstring(game:HttpGet(BASE .. "GUI.lua"))()
task.wait(1) -- tunggu GUI & _G.AF_GUI siap
loadstring(game:HttpGet(BASE .. "Logic.lua"))()
