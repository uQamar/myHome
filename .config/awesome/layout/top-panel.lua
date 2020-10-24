local filesystem = require('gears.filesystem')
local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local TaskList = require('widget.task-list')
local TagList = require('widget.tag-list')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')
local mat_icon_button = require('widget.material.icon-button')
local mat_icon = require('widget.material.icon')
local vicious = require('vicious')
local calendar_widget = require("widget.calendar-widget.calendar")
local cpuwidget = require("widget.cpu-widget.cpu-widget")

vicious.cache(wtype)

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')

local add_button = mat_icon_button(mat_icon(icons.plus, dpi(24)))
add_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn(
          awful.screen.focused().selected_tag.defaultApp,
          {
            tag = _G.mouse.screen.selected_tag,
            placement = awful.placement.bottom_right
          }
        )
      end
    )
  )
)

-- Create an imagebox widget which will contains an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
  local layoutBox = clickable_container(awful.widget.layoutbox(s))
  layoutBox:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        3,
        function()
          awful.layout.inc(-1)
        end
      ),
      awful.button(
        {},
        4,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        5,
        function()
          awful.layout.inc(-1)
        end
      )
    )
  )
  return layoutBox
end


  -- Clock / Calendar 24h format
  -- local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 11">%H:%M</span>')

  -- Clock / Calendar 12AM/PM fornat
  local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 9">%d %b </span> <span font="Roboto Mono bold 12">%a</span> <span font="Roboto Mono bold 12">%I:%M</span> <span font="Roboto Mono bold 9">%p</span>')
  -- textclock.forced_height = 56

  local clock_widget = wibox.container.margin(textclock, dpi(0), dpi(0), dpi(0), dpi(0))

  local cw = calendar_widget()
  textclock:connect_signal("button::press",
                           function(_, _, _, button)
                            if button == 1 then cw.toggle() end
                          end)
  
  
  
  --NetworkSpeed
  netwidget = wibox.widget {
    scale = true,
    step_width = 2,
    step_spacing = 1,
    widget = wibox.widget.graph,
    border_color = "#7DECB7",
    background_color = "#618FB2",
    color = "#e5ff0d"
    } 
  vicious.register(netwidget, vicious.widgets.net,"${wlp5s0 down_kb}",1)
      
  local widget_net = clickable_container(wibox.container.margin(netwidget, dpi(0), dpi(0), 10,10))
  
  nettext = wibox.widget.textbox()
  nettext:set_align("left")
  nettext:set_font("Roboto Mono bold 9")
  vicious.register(nettext, vicious.widgets.net, "  ${wlp5s0 down_kb} kb  ", 1)
  
  neticon = wibox.widget {
    image  = filesystem.get_configuration_dir() .. "/theme/icons/net.png",
    resize = true,
    widget = wibox.widget.imagebox
  }
  
  local neticon_resized = clickable_container(wibox.container.margin(neticon, dpi(0), dpi(0), 10,10))
  
  --CPUSpeed  
  cpuicon = wibox.widget {
    image  = filesystem.get_configuration_dir() .. "/theme/icons/cpu.png",
    resize = true,
    widget = wibox.widget.imagebox
  }
  
  local cpuicon_resized = clickable_container(wibox.container.margin(cpuicon, dpi(0), dpi(0), 10,10))
  
  
  --SPACER
  widgetSpacer = wibox.widget.textbox()
  widgetSpacer:set_text("  |  ")
  blankSpacer = wibox.widget.textbox()
  blankSpacer:set_text("  ")
    

local TopPanel = function(s, offset)
  local offsetx = 0
  if offset == true then
    offsetx = dpi(0)
  end
  local panel =
    wibox(
    {
      ontop = true,
      screen = s,
      height = dpi(48),
      width = s.geometry.width - offsetx,
      x = s.geometry.x + offsetx,
      y = s.geometry.y,
      stretch = false,
      bg = beautiful.background.hue_800,
      fg = beautiful.fg_normal,
      struts = {
        top = dpi(48)
      }
    }
  )

  panel:struts(
    {
      top = dpi(48)
    }
  )

  panel:setup {
    layout = wibox.layout.stack,
    {
        layout = wibox.layout.align.horizontal,
        {--Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- Create a taglist widget
            LayoutBox(s),
            TagList(s),
            TaskList(s),
            add_button
        },
        nil,
        {-- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- Layout box
            widgetSpacer,
            cpuicon_resized,
            blankSpacer,
            cpuwidget(),
            widgetSpacer,
            neticon_resized,
            --nettext,
            blankSpacer,
            widget_net,
            widgetSpacer,
            require('widget.wifi'),
            require('widget.battery'),
            --LayoutBox(s)
        },
     },
     {
        clock_widget,
        valign = "center",
        halign = "center",
        layout = wibox.container.place
      }
  }

  return panel
end

return TopPanel
