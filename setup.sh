# 完全自動セットアップスクリプト
cat > ~/full-auto-setup.sh << 'FULL_EOF'
#!/bin/bash

# 上記のスクリプト内容 + 以下を追加

# awesome設定ファイル自動生成
cat > ~/.config/awesome/rc.lua << 'RC_EOF'
-- 基本設定（デフォルトから必要部分を抜粋・カスタマイズ）
pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- エラーハンドリング
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- テーマ
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- 変数定義
terminal = "alacritty"
editor = "kate"
modkey = "Mod4"

-- レイアウト
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
}

-- メニュー
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

-- Wibar
mytextclock = wibox.widget.textclock()
mytaglist = {}
mytasklist = {}

-- スクリーン設定
awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    
    mytaglist[s] = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
    }
    
    mytasklist[s] = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
    }
    
    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            mytaglist[s],
        },
        mytasklist[s],
        {
            layout = wibox.layout.fixed.horizontal,
            mytextclock,
        },
    }
end)

-- キーバインド
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- アプリケーション起動
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey }, "e", function () awful.spawn("kate") end,
              {description = "open editor", group = "launcher"}),
    awful.key({ modkey }, "f", function () awful.spawn("alacritty -e ranger") end,
              {description = "open file manager", group = "launcher"}),
    awful.key({ modkey }, "w", function () awful.spawn("firefox") end,
              {description = "open web browser", group = "launcher"}),
    awful.key({ modkey }, "q", function () awful.spawn("bash " .. os.getenv("HOME") .. "/start-cq-editor.sh") end,
              {description = "open CQ-editor", group = "launcher"}),

    -- Alt+F4でアプリケーション終了
    awful.key({ "Mod1" }, "F4", function () 
        if client.focus then
            client.focus:kill()
        end
    end, {description = "close application", group = "client"}),

    -- 音量調整
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
    end, {description = "volume up", group = "media"}),
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
    end, {description = "volume down", group = "media"}),
    awful.key({}, "XF86AudioMute", function()
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    end, {description = "mute", group = "media"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey,           }, "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"})
)

-- タグ用キーバインド
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
    )
end

root.keys(globalkeys)

-- クライアント設定
clientkeys = gears.table.join(
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"})
)

awful.rules.rules = {
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },
}

-- 自動起動
awful.spawn.with_shell("~/.config/awesome/autostart.sh")
RC_EOF

echo "=== 完全自動セットアップ完了！ ==="
echo "再起動してください: sudo reboot"
FULL_EOF

chmod +x ~/full-auto-setup.sh
