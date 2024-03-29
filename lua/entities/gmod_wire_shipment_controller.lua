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

AddCSLuaFile()
DEFINE_BASECLASS("base_wire_entity")

ENT.PrintName     = "Shipment Controller"
ENT.Author        = "Billy (STEAM_0:1:40314158)"
ENT.Contact       = "http://steamcommunity.com/sharedfiles/filedetails/?id=2260357802"

ENT.RenderGroup   = RENDERGROUP_BOTH
ENT.WireDebugName = ENT.PrintName

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "BeamLength")
end

if CLIENT then return end

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self.Inputs = WireLib.CreateInputs(self, {"Dispense", "Price Markup", "Separate Price Markup", "Currency", "Out Of Stock Message"})
	WireLib.AdjustSpecialInputs(self,
		{"Dispense", "Price Markup", "Separate Price Markup", "Currency", "Out Of Stock Message"},
		{"NORMAL", "NORMAL", "NORMAL", "STRING", "STRING"}
	)
	self.Outputs = WireLib.CreateOutputs(self, {"Quantity", "Size", "Price", "Name", "Category", "Type", "Model", "Separate", "Separate Price", "Name And Price", "Name And Separate Price", "Shipment"})
	WireLib.AdjustSpecialOutputs(self,
		{"Quantity", "Size", "Price", "Name", "Category", "Type", "Model", "Separate", "Separate Price", "Name And Price", "Name And Separate Price", "Shipment"},
		{"NORMAL", "NORMAL", "NORMAL", "STRING", "STRING", "STRING", "STRING", "NORMAL", "NORMAL", "STRING", "STRING", "ENTITY"}
	)

	self:Setup(2048)
end

function ENT:Setup(range)
	if range then self:SetBeamLength(range) end
	
	self.m_PriceMarkup = 0
	self.m_SeparatePriceMarkup = 0
	self.m_Currency = "$"
	self.m_OutOfStockMsg = ""
	
	self:ResetOutputs()
end

do
	local trStruct = { filter = {} }
	function ENT:BeamTrace()
		trStruct.start = self:GetPos()
		trStruct.endpos = self:GetPos() + (self:GetUp() * self:GetBeamLength())
		trStruct.filter[1] = self
		return util.TraceLine(trStruct)
	end
end

local function IsShipment(ent)
	return IsValid(ent) and ent:GetClass() == "spawned_shipment"
end

local function GetShipmentItemModel(ent, contents)
	if contents.model then
		return contents.model
	elseif IsValid(ent:GetgunModel()) then
		return ent:GetgunModel():GetModel()
	else
		return "models/Items/item_item_crate.mdl"
	end
end

function ENT:UpdateInputs(shipment, forceUpdate)
	local contents = IsShipment(shipment) and CustomShipments[shipment:Getcontents() or ""]

	if contents then
		WireLib.TriggerOutput(self, "Quantity", shipment:Getcount())

		if shipment ~= self.m_ActiveShipment or not IsValid(self.m_ActiveShipment) or forceUpdate then
			local markedUpPrice = contents.price + self.m_PriceMarkup
			local markedUpSeparatePrice = (contents.pricesep or contents.price / contents.amount) + self.m_SeparatePriceMarkup
		
			WireLib.TriggerOutput(self, "Size", contents.amount)
			WireLib.TriggerOutput(self, "Price", markedUpPrice)
			WireLib.TriggerOutput(self, "Name", contents.name)
			WireLib.TriggerOutput(self, "Category", contents.category or "Other")
			WireLib.TriggerOutput(self, "Type", contents.entity)
			WireLib.TriggerOutput(self, "Model", GetShipmentItemModel(shipment, contents))
			WireLib.TriggerOutput(self, "Separate", contents.separate == true and 1 or 0)
			WireLib.TriggerOutput(self, "Separate Price", markedUpSeparatePrice)
			WireLib.TriggerOutput(self, "Name And Price", contents.name .. " " .. self.m_Currency .. markedUpPrice)
			WireLib.TriggerOutput(self, "Name And Separate Price", contents.name .. " " .. self.m_Currency .. markedUpSeparatePrice)
			WireLib.TriggerOutput(self, "Shipment", shipment)
		end
		
		self.m_ActiveShipment = shipment

		return
	end

	if self.m_ActiveShipment then
		self:ResetOutputs()
		self.m_ActiveShipment = nil
	end
end

function ENT:Think()
	local trace = self:BeamTrace()

	self:UpdateInputs(trace.Entity)
end

function ENT:ResetOutputs()
	WireLib.TriggerOutput(self, "Quantity", 0)
	WireLib.TriggerOutput(self, "Size", 0)
	WireLib.TriggerOutput(self, "Price", 0)
	WireLib.TriggerOutput(self, "Name", "")
	WireLib.TriggerOutput(self, "Category", "")
	WireLib.TriggerOutput(self, "Type", "")
	WireLib.TriggerOutput(self, "Model", "")
	WireLib.TriggerOutput(self, "Separate", 0)
	WireLib.TriggerOutput(self, "Separate Price", 0)
	WireLib.TriggerOutput(self, "Name And Price", self.m_OutOfStockMsg)
	WireLib.TriggerOutput(self, "Name And Separate Price", self.m_OutOfStockMsg)
	WireLib.TriggerOutput(self, "Shipment", NULL)
end

function ENT:TriggerInput(iName, value)
	if iName == "Dispense" and value ~= 0 then
		local trace = self:BeamTrace()

		if not IsShipment(trace.Entity) then return false end

		local ply = self:GetPlayer()
		if not IsValid(ply) then ply = self end

		if not hook.Run("PlayerUse", ply, trace.Entity) then return false end
		trace.Entity:Use(ply, ply, USE_ON, 0)
	elseif iName == "Price Markup" and value > -1 then
		self.m_PriceMarkup = value
		
		if self.m_ActiveShipment then
			self:UpdateInputs(self.m_ActiveShipment, true)
		end
	elseif iName == "Separate Price Markup" and value > -1 then
		self.m_SeparatePriceMarkup = value
		
		if self.m_ActiveShipment then
			self:UpdateInputs(self.m_ActiveShipment, true)
		end
	elseif iName == "Currency" then
		self.m_Currency = (value != "" and value or "$")
		if self.m_ActiveShipment then
			self:UpdateInputs(self.m_ActiveShipment, true)
		end
	elseif iName == "Out Of Stock Message" then
		self.m_OutOfStockMsg = (value != "" and value or "")
		
		if not self.m_ActiveShipment then
			self:ResetOutputs()
		end
	end
end

duplicator.RegisterEntityClass("gmod_shipment_controller", WireLib.MakeWireEnt, "Data", "Range")
