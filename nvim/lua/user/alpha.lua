local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
  return
end

local dashboard = require "alpha.themes.dashboard"
local headerText = {}
headerText.rip = {
[[                                  ]],
[[ ██████╗ ██╗██████╗     ██╗████████╗ ]],
[[ ██╔══██╗██║██╔══██╗    ██║╚══██╔══╝ ]],
[[ ██████╔╝██║██████╔╝    ██║   ██║    ]],
[[ ██╔══██╗██║██╔═══╝     ██║   ██║    ]],
[[ ██║  ██║██║██║         ██║   ██║    ]],
[[ ╚═╝  ╚═╝╚═╝╚═╝         ╚═╝   ╚═╝    ]],
[[                                    ]]
}

headerText.dont = {
    [[  ]],
[[ █████╗  ██████╗ ███╗   ██╗████████╗    ███████╗██╗   ██╗ ██████╗██╗  ██╗    ██╗   ██╗██████╗     ]],
[[ █╔══██╗██╔═══██╗████╗  ██║╚══██╔══╝    ██╔════╝██║   ██║██╔════╝██║ ██╔╝    ██║   ██║██╔══██╗    ]],
[[ █║  ██║██║   ██║██╔██╗ ██║   ██║       █████╗  ██║   ██║██║     █████╔╝     ██║   ██║██████╔╝    ]],
[[ █║  ██║██║   ██║██║╚██╗██║   ██║       ██╔══╝  ██║   ██║██║     ██╔═██╗     ██║   ██║██╔═══╝     ]],
[[ █████╔╝╚██████╔╝██║ ╚████║   ██║       ██║     ╚██████╔╝╚██████╗██║  ██╗    ╚██████╔╝██║         ]],
[[ ═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝       ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝     ╚═════╝ ╚═╝         ]],
    [[]],
  }

headerText.code = {
  [[]],
[[ ██╗     ██████╗ ██████╗ ██████╗ ███████╗     ██████╗ ██╗   ██╗██████╗ ]],
[[ ██║    ██╔════╝██╔═══██╗██╔══██╗██╔════╝    ██╔════╝ ██║   ██║██╔══██╗]],
[[ ██║    ██║     ██║   ██║██║  ██║█████╗      ██║  ███╗██║   ██║██║  ██║]],
[[ ██║    ██║     ██║   ██║██║  ██║██╔══╝      ██║   ██║██║   ██║██║  ██║]],
[[ ██║    ╚██████╗╚██████╔╝██████╔╝███████╗    ╚██████╔╝╚██████╔╝██████╔╝]],
[[ ╚═╝     ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝     ╚═════╝  ╚═════╝ ╚═════╝ ]],
  [[]],
}

local greeting = {"rip", "code", "dont"}
dashboard.section.header.val = headerText[greeting[math.random(#greeting)]]
dashboard.section.buttons.val = {
}

local function footer()
  return "chaz rules 4eva"
end

dashboard.section.footer.val = footer()

dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

dashboard.opts.opts.noautocmd = true
alpha.setup(dashboard.opts)
