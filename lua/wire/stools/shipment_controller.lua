--[[

	bbbbbbbb                                                                                                          
	b::::::b                   iiii       lllllll      lllllll                                             ))))))     
	b::::::b                  i::::i      l:::::l      l:::::l                                            )::::::))   
	b::::::b                   iiii       l:::::l      l:::::l                                             ):::::::)) 
	 b:::::b                              l:::::l      l:::::l                                              )):::::::)
	 b:::::bbbbbbbbb         iiiiiii       l::::l       l::::l      yyyyyyy           yyyyyyy                 )::::::)
	 b::::::::::::::bb       i:::::i       l::::l       l::::l       y:::::y         y:::::y       ::::::      ):::::)
	 b::::::::::::::::b       i::::i       l::::l       l::::l        y:::::y       y:::::y        ::::::      ):::::)
	 b:::::bbbbb:::::::b      i::::i       l::::l       l::::l         y:::::y     y:::::y         ::::::      ):::::)
	 b:::::b    b::::::b      i::::i       l::::l       l::::l          y:::::y   y:::::y                      ):::::)
	 b:::::b     b:::::b      i::::i       l::::l       l::::l           y:::::y y:::::y                       ):::::)
	 b:::::b     b:::::b      i::::i       l::::l       l::::l            y:::::y:::::y                        ):::::)
	 b:::::b     b:::::b      i::::i       l::::l       l::::l             y:::::::::y             ::::::     )::::::)
	 b:::::bbbbbb::::::b     i::::::i     l::::::l     l::::::l             y:::::::y              ::::::   )):::::::)
	 b::::::::::::::::b      i::::::i     l::::::l     l::::::l              y:::::y               ::::::  ):::::::)) 
	 b:::::::::::::::b       i::::::i     l::::::l     l::::::l             y:::::y                       )::::::)    
	 bbbbbbbbbbbbbbbb        iiiiiiii     llllllll     llllllll            y:::::y                         ))))))     
	                                                                      y:::::y                                     
	                                                                     y:::::y                                      
	                                                                    y:::::y                                       
	                                                                   y:::::y                                        
	                                                                  yyyyyyy                                         
	
	© 2020 William Venner

	https://github.com/WilliamVenner/wire_shipment_controller
	http://steamcommunity.com/sharedfiles/filedetails/?id=2260357802

]]

WireToolSetup.setCategory("DarkRP")
WireToolSetup.open("shipment_controller", "Shipment Controller", "gmod_wire_shipment_controller", nil, "Shipment Controllers")

if CLIENT then
	language.Add("tool.wire_shipment_controller.name", "Shipment Controller Tool (Wire)")
	language.Add("tool.wire_shipment_controller.desc", "Spawns a shipment controller which creates a DarkRP shipments interface for the wire system.")
	language.Add("tool.wire_shipment_controller.range", "Max Range:")

	language.Add("tool.wire_shipment_controller.inputs", "Inputs")
	language.Add("tool.wire_shipment_controller.outputs", "Outputs")
	language.Add("tool.wire_shipment_controller.inputs.dispense", "[BOOLEAN 1/0] Dispenses 1 item from the shipment")
	language.Add("tool.wire_shipment_controller.inputs.pricemarkup", "[NUMBER] Adds extra money to the price output")
	language.Add("tool.wire_shipment_controller.inputs.seperatepricemarkup", "[NUMBER] Adds extra money to the seperate price output")
	language.Add("tool.wire_shipment_controller.inputs.currency", "[STRING] Set the currency symbol")
	language.Add("tool.wire_shipment_controller.inputs.outofstockmessage", "[STRING] The message to output when no shipment is detected")
	language.Add("tool.wire_shipment_controller.outputs.quantity", "[NUMBER] Amount of items left in the shipment")
	language.Add("tool.wire_shipment_controller.outputs.size", "[NUMBER] Amount of items the shipment originally held")
	language.Add("tool.wire_shipment_controller.outputs.price", "[NUMBER] Price of shipment")
	language.Add("tool.wire_shipment_controller.outputs.name", "[STRING] Name of shipment")
	language.Add("tool.wire_shipment_controller.outputs.category", "[STRING] Category of shipment in F4 menu")
	language.Add("tool.wire_shipment_controller.outputs.type", "[STRING] Class name of shipment item entity")
	language.Add("tool.wire_shipment_controller.outputs.model", "[STRING] Model path of item")
	language.Add("tool.wire_shipment_controller.outputs.separate", "[BOOLEAN 1/0] Whether the shipment is also sold separately")
	language.Add("tool.wire_shipment_controller.outputs.separateprice", "[NUMBER] Price of item when sold separately, if not seperate the output will default to price / size")
	language.Add("tool.wire_shipment_controller.outputs.nameandprice", "[STRING] Combination of name and price")
	language.Add("tool.wire_shipment_controller.outputs.nameandprice", "[NUMBER] Combination of name and seperate price")
	language.Add("tool.wire_shipment_controller.outputs.shipment", "[ENTITY] The shipment itself")

	TOOL.Information = { { name = "left", text = "Create/Update " .. TOOL.Name } }
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax(20) 

TOOL.ClientConVar = {
	model = "models/jaanus/wiretool/wiretool_siren.mdl",
	range = 200,
}

if SERVER then
	function TOOL:GetConVars() return self:GetClientNumber("range") end
else
	local inputs = { "Dispense", "Price Markup", "Seperate Price Markup", "Currency", "Out Of Stock Message" }
	local outputs = { "Quantity", "Size", "Price", "Name", "Category", "Type", "Model", "Separate", "Separate Price", "Name And Price", "Name And Seperate Price", "Shipment" }

	function TOOL.BuildCPanel(CPanel)
		local link = CPanel:Help("https://github.com/WilliamVenner/wire_shipment_controller")
		link:DockPadding(0, 0, 0, 0)
		link:SetAlpha(255 * .75)
		link:SetCursor("hand")
		link:SetMouseInputEnabled(true)
		link.DoClick = function()
			gui.OpenURL("https://github.com/WilliamVenner/wire_shipment_controller")
		end

		ModelPlug_AddToCPanel(CPanel, "Laser_Tools", "wire_shipment_controller", true)

		CPanel:NumSlider("#tool.wire_shipment_controller.range", "wire_shipment_controller_range", 1, 1000, 1)

		CPanel.Inputs = vgui.Create("DForm", CPanel)
		CPanel.Inputs:SetLabel("#tool.wire_shipment_controller.inputs")
		CPanel.Inputs:SetExpanded(true)

		CPanel.Outputs = vgui.Create("DForm", CPanel)
		CPanel.Outputs:SetLabel("#tool.wire_shipment_controller.outputs")
		CPanel.Outputs:SetExpanded(true)

		for i, input in ipairs(inputs) do
			CPanel.Inputs:ControlHelp(input):DockMargin(0, 10, 0, 5)
			CPanel.Inputs:Help("#tool.wire_shipment_controller.inputs." .. (input:lower():gsub("%s", ""))):DockPadding(0, 0, 0, 0)
		end
		for i, output in ipairs(outputs) do
			CPanel.Outputs:ControlHelp(output):DockMargin(0, 10, 0, 5)
			CPanel.Outputs:Help("#tool.wire_shipment_controller.outputs." .. (output:lower():gsub("%s", ""))):DockPadding(0, 0, 0, 0)
		end

		CPanel:AddItem(CPanel.Inputs)
		CPanel:AddItem(CPanel.Outputs)
	end
end
