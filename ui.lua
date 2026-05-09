local Ui = {}

loveli = require("LOVELi")

function Ui.test(screenWidth, screenHeight)
    local stacklayout = loveli.StackLayout:new{ orientation = "vertical", spacing = 5, width = "*", height = "*", margin = loveli.Thickness.parse(10) } 
    :with(loveli.Button:new{ text = "Start", horizontaltextalignment = "center", verticaltextalignment = "center", width = 75, height = 23, horizontaloptions = "center", verticaloptions = "center" } )
    :with(loveli.Button:new{ text = "Load Game", horizontaltextalignment = "center", verticaltextalignment = "center", width = 75, height = 23, horizontaloptions = "center", verticaloptions = "center" } )
    :with(loveli.Button:new{ text = "Options", horizontaltextalignment = "center", verticaltextalignment = "center", width = 75, height = 23, horizontaloptions = "center", verticaloptions = "center" } )
    :with(loveli.Button:new{ text = "Exit", horizontaltextalignment = "center", verticaltextalignment = "center", width = 75, height = 23, horizontaloptions = "center", verticaloptions = "center" } )		
    local rootcontrol = stacklayout
     layoutmanager = loveli.LayoutManager:new{}
        :with(rootcontrol)
end
return Ui