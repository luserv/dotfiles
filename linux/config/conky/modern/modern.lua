-- Modern conky panel (Nord palette), drawn entirely with Cairo.
-- Layout: header, workspace dots, CPU/RAM/disk rings, network, top processes.

require 'cairo'
pcall(require, 'cairo_xlib')

-- Global scale. Keep conky.conf minimum_width/height in sync:
--   minimum_width = 360 * SCALE, minimum_height = 794 * SCALE
local SCALE = 1.15
local W, H = 360, 794
local PAD = 20
local FONT = 'DejaVu Sans'
local MONO = 'DejaVu Sans Mono'

local COLORS = {
  bg     = 0x0b0f14,
  accent = 0x88c0d0,
  text   = 0xd8dee9,
  dim    = 0x4c566a,
  warn   = 0xebcb8b,
  crit   = 0xbf616a,
}

local extents = nil

local function set_color(cr, hex, alpha)
  local r = ((hex >> 16) & 0xff) / 255
  local g = ((hex >> 8) & 0xff) / 255
  local b = (hex & 0xff) / 255
  cairo_set_source_rgba(cr, r, g, b, alpha or 1)
end

local function parse(expr)
  local out = conky_parse(expr) or ''
  return (out:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function num(expr)
  return tonumber(parse(expr)) or 0
end

local function level_color(pct)
  if pct >= 80 then return COLORS.crit end
  if pct >= 60 then return COLORS.warn end
  return COLORS.accent
end

-- Draw text. align: 'l' (default), 'c' or 'r' relative to x.
local function text(cr, str, x, y, size, color, alpha, align, opts)
  opts = opts or {}
  local weight = opts.bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL
  cairo_select_font_face(cr, opts.font or FONT, CAIRO_FONT_SLANT_NORMAL, weight)
  cairo_set_font_size(cr, size)
  local dx = 0
  if align == 'c' or align == 'r' then
    if not extents then extents = cairo_text_extents_t:create() end
    cairo_text_extents(cr, str, extents)
    dx = (align == 'c') and (extents.x_advance / 2) or extents.x_advance
  end
  set_color(cr, color, alpha)
  cairo_move_to(cr, x - dx, y)
  cairo_show_text(cr, str)
end

local function rounded_rect(cr, x, y, w, h, r)
  cairo_new_sub_path(cr)
  cairo_arc(cr, x + w - r, y + r, r, -math.pi / 2, 0)
  cairo_arc(cr, x + w - r, y + h - r, r, 0, math.pi / 2)
  cairo_arc(cr, x + r, y + h - r, r, math.pi / 2, math.pi)
  cairo_arc(cr, x + r, y + r, r, math.pi, 3 * math.pi / 2)
  cairo_close_path(cr)
end

local function separator(cr, y)
  set_color(cr, COLORS.dim, 0.5)
  cairo_set_line_width(cr, 1)
  cairo_move_to(cr, PAD, y)
  cairo_line_to(cr, W - PAD, y)
  cairo_stroke(cr)
end

local function section_label(cr, str, y)
  text(cr, str, PAD, y, 11, COLORS.accent, 0.9, 'l', { bold = true })
end

-- Ring gauge starting at 12 o'clock, clockwise.
local function ring(cr, cx, cy, radius, thickness, pct)
  local start = -math.pi / 2
  cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
  cairo_set_line_width(cr, thickness)

  set_color(cr, COLORS.dim, 0.35)
  cairo_arc(cr, cx, cy, radius, 0, 2 * math.pi)
  cairo_stroke(cr)

  local clamped = math.max(0, math.min(100, pct))
  if clamped > 0 then
    set_color(cr, level_color(clamped), 1)
    cairo_arc(cr, cx, cy, radius, start, start + (clamped / 100) * 2 * math.pi)
    cairo_stroke(cr)
  end
end

local function gauge(cr, cx, cy, pct, label, sub)
  ring(cr, cx, cy, 40, 8, pct)
  text(cr, string.format('%d%%', pct), cx, cy + 7, 19, COLORS.text, 1, 'c', { bold = true })
  text(cr, label, cx, cy + 66, 12, COLORS.accent, 1, 'c', { bold = true })
  text(cr, sub, cx, cy + 83, 10, COLORS.text, 0.7, 'c', { font = MONO })
end

local function draw_background(cr)
  rounded_rect(cr, 0.5, 0.5, W - 1, H - 1, 18)
  set_color(cr, COLORS.bg, 0.62)
  cairo_fill_preserve(cr)
  set_color(cr, COLORS.accent, 0.25)
  cairo_set_line_width(cr, 1)
  cairo_stroke(cr)
end

local BATTERY = '/sys/class/power_supply/BAT0'
local AC_ONLINE = '/sys/class/power_supply/AC/online'

local function read_line(path)
  local f = io.open(path, 'r')
  if not f then return nil end
  local content = f:read('*l')
  f:close()
  return content
end

-- Battery icon plus "<pct>% · <state>", right-aligned. Skipped when no battery.
local function draw_battery(cr, y)
  local capacity = tonumber(read_line(BATTERY .. '/capacity') or '')
  if not capacity then return end
  local status = read_line(BATTERY .. '/status') or 'Unknown'
  local plugged = read_line(AC_ONLINE) == '1'

  local label = status
  if status == 'Not charging' or status == 'Full' then
    label = plugged and 'Plugged' or status
  end

  local color = COLORS.accent
  if status == 'Discharging' then
    if capacity <= 15 then
      color = COLORS.crit
    elseif capacity <= 30 then
      color = COLORS.warn
    end
  end

  local body_w, body_h = 26, 12
  local bx, by = W - PAD - body_w - 3, y - 10

  -- Outline and terminal nub.
  rounded_rect(cr, bx, by, body_w, body_h, 3)
  set_color(cr, COLORS.text, 0.8)
  cairo_set_line_width(cr, 1.2)
  cairo_stroke(cr)
  rounded_rect(cr, bx + body_w + 1, by + 3.5, 2.5, body_h - 7, 1)
  set_color(cr, COLORS.text, 0.8)
  cairo_fill(cr)

  -- Charge level.
  local fill_w = (body_w - 4) * math.max(0, math.min(100, capacity)) / 100
  if fill_w > 0 then
    rounded_rect(cr, bx + 2, by + 2, fill_w, body_h - 4, 1.5)
    set_color(cr, color, 1)
    cairo_fill(cr)
  end

  text(cr, string.format('%d%% · %s', capacity, label), bx - 8, y, 12, COLORS.text, 0.7, 'r', { font = MONO })
end

-- True while xfce-idle-toggle has its systemd inhibitor running.
local function keep_awake_active()
  local runtime = os.getenv('XDG_RUNTIME_DIR') or '/tmp'
  local pid = read_line(runtime .. '/xfce-idle-inhibit.pid')
  if not pid or not pid:match('^%d+$') then return false end
  local proc = io.open('/proc/' .. pid .. '/cmdline', 'r')
  if not proc then return false end
  proc:close()
  return true
end

local function draw_keep_awake(cr, y)
  if not keep_awake_active() then return end
  set_color(cr, COLORS.accent, 1)
  cairo_arc(cr, PAD + 4, y - 4, 3.5, 0, 2 * math.pi)
  cairo_fill(cr)
  text(cr, 'Keep awake', PAD + 14, y, 11, COLORS.accent, 1, 'l', { bold = true })
end

local function draw_header(cr)
  text(cr, parse('${time %H:%M}'), PAD, 66, 52, COLORS.text, 1, 'l', { bold = true })
  text(cr, parse('${time %A %d %b}'), PAD + 2, 92, 14, COLORS.accent, 1, 'l')
  text(cr, 'up ' .. parse('${uptime_short}'), W - PAD, 56, 12, COLORS.text, 0.7, 'r', { font = MONO })
  text(cr, parse('${addr wlan0}'), W - PAD, 76, 12, COLORS.text, 0.7, 'r', { font = MONO })
  draw_battery(cr, 98)
  draw_keep_awake(cr, 112)
end

local function draw_workspaces(cr, y)
  local state = parse('${execi 1 ~/.config/conky/modern/ws-state.sh}')
  local count = #state
  if count == 0 then return end
  local span = W - 2 * PAD
  local step = span / count
  for i = 1, count do
    local cx = PAD + step * (i - 0.5)
    local kind = state:sub(i, i)
    if kind == 'A' then
      set_color(cr, COLORS.accent, 1)
      cairo_arc(cr, cx, y, 7, 0, 2 * math.pi)
      cairo_fill(cr)
    elseif kind == 'O' then
      set_color(cr, COLORS.text, 0.75)
      cairo_arc(cr, cx, y, 4.5, 0, 2 * math.pi)
      cairo_fill(cr)
    else
      set_color(cr, COLORS.dim, 0.8)
      cairo_set_line_width(cr, 1.2)
      cairo_arc(cr, cx, y, 4, 0, 2 * math.pi)
      cairo_stroke(cr)
    end
  end
end

local function draw_gauges(cr, cy)
  local cpu = num('${cpu}')
  local temp = parse('${hwmon coretemp temp 1}')
  local freq = parse('${freq_g 1}')
  gauge(cr, 60, cy, cpu, 'CPU', string.format('%s°C · %sGHz', temp, freq))

  local mem = num('${memperc}')
  gauge(cr, 180, cy, mem, 'RAM', parse('${mem}') .. ' / ' .. parse('${memmax}'))

  local disk = num('${fs_used_perc /}')
  gauge(cr, 300, cy, disk, 'DISK', parse('${fs_used /}') .. ' / ' .. parse('${fs_size /}'))
end

-- One vertical bar per CPU thread, bottom-aligned, with its index below.
local function draw_threads(cr, y)
  local count = tonumber(parse('${execi 3600 nproc}')) or 0
  count = math.min(count, 16)
  if count == 0 then return end

  section_label(cr, 'THREADS', y)

  local top, bar_h = y + 12, 50
  local step = (W - 2 * PAD) / count
  local bar_w = math.min(18, step - 6)

  for i = 1, count do
    local pct = num(string.format('${cpu cpu%d}', i))
    local x = PAD + step * (i - 1) + (step - bar_w) / 2

    rounded_rect(cr, x, top, bar_w, bar_h, 3)
    set_color(cr, COLORS.dim, 0.35)
    cairo_fill(cr)

    local fill = bar_h * math.max(0, math.min(100, pct)) / 100
    if fill > 0 then
      cairo_save(cr)
      rounded_rect(cr, x, top, bar_w, bar_h, 3)
      cairo_clip(cr)
      cairo_rectangle(cr, x, top + bar_h - fill, bar_w, fill)
      set_color(cr, level_color(pct), 1)
      cairo_fill(cr)
      cairo_restore(cr)
    end

    text(cr, tostring(i), x + bar_w / 2, top + bar_h + 14, 9, COLORS.text, 0.6, 'c', { font = MONO })
  end
end

local function draw_network(cr, y)
  text(cr, '↓', PAD, y, 14, COLORS.accent, 1, 'l', { bold = true })
  text(cr, parse('${downspeed wlan0}'), PAD + 18, y, 13, COLORS.text, 1, 'l', { font = MONO })
  text(cr, parse('${upspeed wlan0}'), W - PAD - 18, y, 13, COLORS.text, 1, 'r', { font = MONO })
  text(cr, '↑', W - PAD, y, 14, COLORS.accent, 1, 'r', { bold = true })
end

-- Shorten a UTF-8 string to max_chars characters, adding an ellipsis.
local function truncate(str, max_chars)
  if (utf8.len(str) or #str) <= max_chars then return str end
  local cut = utf8.offset(str, max_chars) or (max_chars + 1)
  return str:sub(1, cut - 1) .. '…'
end

local function split_fields(line)
  local app, ws, title = line:match('^([^|]*)|([^|]*)|(.*)$')
  return app, ws, title
end

-- Volume bar plus the streams that are playing right now and their workspace.
local function draw_audio(cr, y)
  section_label(cr, 'AUDIO', y)

  local out = conky_parse('${execi 2 ~/.config/conky/modern/audio-state.sh}') or ''
  local lines = {}
  for line in out:gmatch('[^\r\n]+') do lines[#lines + 1] = line end
  if #lines == 0 then return end

  local vol, muted = lines[1]:match('^(%d+)|(%d)$')
  vol = tonumber(vol) or 0
  muted = muted == '1'

  -- Volume bar.
  local bar_x, bar_w, bar_h = PAD + 64, W - 2 * PAD - 64 - 56, 6
  local bar_y = y + 18
  text(cr, 'Volume', PAD, bar_y + 6, 12, COLORS.text, 0.8, 'l')
  rounded_rect(cr, bar_x, bar_y, bar_w, bar_h, 3)
  set_color(cr, COLORS.dim, 0.35)
  cairo_fill(cr)
  local fill = bar_w * math.min(vol, 100) / 100
  if fill > 0 then
    rounded_rect(cr, bar_x, bar_y, fill, bar_h, 3)
    set_color(cr, muted and COLORS.dim or COLORS.accent, 1)
    cairo_fill(cr)
  end
  local label = muted and 'Muted' or string.format('%d%%', vol)
  text(cr, label, W - PAD, bar_y + 7, 12, muted and COLORS.warn or COLORS.text, 0.9, 'r', { font = MONO })

  -- Playing streams (max 2) with the workspace that owns the window.
  local shown = 0
  for i = 2, #lines do
    if shown >= 2 then break end
    local app, ws, title = split_fields(lines[i])
    if app then
      local row = y + 44 + shown * 20
      text(cr, 'WS ' .. ws, PAD, row, 12, COLORS.accent, 1, 'l', { bold = true, font = MONO })
      local what = (title ~= '' and title) or app
      text(cr, truncate(app .. ' · ' .. what, 31), PAD + 52, row, 12, COLORS.text, 0.85, 'l')
      shown = shown + 1
    end
  end
  if shown == 0 then
    text(cr, 'Nothing playing', PAD, y + 44, 12, COLORS.text, 0.5, 'l')
  end
end

local function draw_top(cr, y, title, name_expr, value_fn)
  section_label(cr, title, y)
  for i = 1, 3 do
    local row = y + 8 + i * 20
    local name = parse(string.format(name_expr, i))
    if #name > 18 then name = name:sub(1, 17) .. '…' end
    text(cr, name, PAD, row, 12, COLORS.text, 0.9, 'l')
    text(cr, value_fn(i), W - PAD, row, 12, COLORS.text, 0.7, 'r', { font = MONO })
  end
end

function conky_main()
  local surface
  local owns_surface = false
  if conky_surface then
    -- Newer conky: the surface is provided and owned by conky.
    surface = conky_surface()
  else
    if conky_window == nil then return end
    surface = cairo_xlib_surface_create(
      conky_window.display, conky_window.drawable, conky_window.visual,
      conky_window.width, conky_window.height)
    owns_surface = true
  end
  if surface == nil then return end
  local cr = cairo_create(surface)
  cairo_scale(cr, SCALE, SCALE)

  draw_background(cr)
  draw_header(cr)
  draw_workspaces(cr, 128)
  separator(cr, 150)
  draw_gauges(cr, 205)
  separator(cr, 320)
  draw_threads(cr, 344)
  separator(cr, 432)
  draw_network(cr, 458)
  separator(cr, 476)
  draw_audio(cr, 500)
  separator(cr, 580)

  draw_top(cr, 604, 'TOP CPU', '${top name %d}', function(i)
    return parse(string.format('${top cpu %d}', i)) .. '%'
  end)
  draw_top(cr, 700, 'TOP RAM', '${top_mem name %d}', function(i)
    return parse(string.format('${top_mem mem_res %d}', i)) .. '  '
      .. parse(string.format('${top_mem mem %d}', i)) .. '%'
  end)

  cairo_destroy(cr)
  if owns_surface then cairo_surface_destroy(surface) end
end
