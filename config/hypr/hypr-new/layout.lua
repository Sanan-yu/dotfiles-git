-- 1. Автоматическая генерация 25 персистентных воркспейсов
for i = 1, 25 do
	hl.workspace_rule({ workspace = tostring(i), persistent = true, monitor = "DP-3" })
end

-- Центрирование при старте (для сетки 5х5 центр — это 13)
hl.on("hyprland.start", function()
	hl.dispatch(hl.dsp.focus({ workspace = "13" }))
end)

local CSH = "CTRL + SHIFT"

-- Функция для смены анимации (чтобы не дублировать код)
local function set_animation(style)
	hl.animation({
		leaf = "workspacesIn",
		enabled = true,
		speed = 2.71,
		bezier = "almostLinear",
		style = "slidefade " .. style,
	})
	hl.animation({
		leaf = "workspacesOut",
		enabled = true,
		speed = 1.94,
		bezier = "almostLinear",
		style = "slidefade " .. style,
	})
end

-- Функция для сброса анимации в дефолт (заменяет hl-popin.sh)
-- Впишите сюда дефолтный стиль анимации ваших воркспейсов, например "popin" или "fade"
local function reset_animation()
	hl.animation({ leaf = "workspacesIn", enabled = true, style = "popin" })
	hl.animation({ leaf = "workspacesOut", enabled = true, style = "popin" })
end

-- ВПРАВО (+1)
hl.bind(CSH .. " + right", function()
	local ws = hl.get_active_workspace().id
	-- Если не правый край (не делится на 5 без остатка)
	if ws % 5 ~= 0 and ws < 25 then
		set_animation("right")
		hl.dispatch(hl.dsp.focus({ workspace = tostring(ws + 1) }))
		reset_animation()
	end
end)

-- ВЛЕВО (-1)
hl.bind(CSH .. " + left", function()
	local ws = hl.get_active_workspace().id
	-- Если не левый край (остаток от деления на 5 не равен 1)
	if ws % 5 ~= 1 and ws > 1 then
		set_animation("left")
		hl.dispatch(hl.dsp.focus({ workspace = tostring(ws - 1) }))
		reset_animation()
	end
end)

-- ВНИЗ (+5)
hl.bind(CSH .. " + down", function()
	local ws = hl.get_active_workspace().id
	-- Если не самая нижняя строка (id меньше или равен 20)
	if ws <= 20 then
		set_animation("bottom")
		hl.dispatch(hl.dsp.focus({ workspace = tostring(ws + 5) }))
		reset_animation()
	end
end)

-- ВВЕРХ (-5)
hl.bind(CSH .. " + up", function()
	local ws = hl.get_active_workspace().id
	-- Если не самая верхняя строка (id больше 5)
	if ws > 5 then
		set_animation("top")
		hl.dispatch(hl.dsp.focus({ workspace = tostring(ws - 5) }))
		reset_animation()
	end
end)
