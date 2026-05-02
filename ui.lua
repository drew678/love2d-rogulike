local Ui = {}

loveli = require("LOVELi")

function Ui.test()
    local stacklayout = loveli.StackLayout:new{ orientation = "vertical", spacing = 5, width = "*", height = "*", margin = loveli.Thickness.parse(10) } 
    :with(loveli.Button:new{ text = "Button 1", horizontaltextalignment = "start", verticaltextalignment = "center", width = 75, height = 23, horizontaloptions = "start" } )
    :with(loveli.Button:new{ text = "Button 2", horizontaltextalignment = "center", verticaltextalignment = "center", width = 75, height = "*", horizontaloptions = "center" } )
    :with(loveli.Button:new{ text = "Button 3", horizontaltextalignment = "end", verticaltextalignment = "center", width = 75, height = 23, horizontaloptions = "end" } )		
    local rootcontrol = stacklayout
     layoutmanager = loveli.LayoutManager:new{}
        :with(rootcontrol)
end
return Ui