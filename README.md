[![Workshop](https://i.imgur.com/laN3Sgo.png)](https://steamcommunity.com/sharedfiles/filedetails/?id=2260357802)
<p align="center">
	<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=2260357802">https://steamcommunity.com/sharedfiles/filedetails/?id=2260357802</a>
</p>

# Wiremod Shipment Controller

The Wiremod Shipment Controller is a simple Wiremod component that creates an interface of crucial inputs and outputs for use with DarkRP shipments, allowing you to make extremely advanced automatic gun shops without the need for E2 or Users, both of which may be restricted or blocked completely on some servers.

## Recommended Extras

[Moneypot](https://steamcommunity.com/sharedfiles/filedetails/?id=109905241)

[TylerB's moneyRequest E2 Functions (v1)](https://steamcommunity.com/sharedfiles/filedetails/?id=259174593)

[TylerB's Shipment E2 Functions (v1)](https://steamcommunity.com/sharedfiles/filedetails/?id=217722743)

## Inputs

| **Input** | **Type**      | **Description**                                  |
|-----------|---------------|--------------------------------------------------|
| Dispense  | Boolean `1/0` | Dispenses 1 item from the shipment               |

## Outputs

| **Output**     | **Type**      | **Description**                              |
|----------------|---------------|----------------------------------------------|
| Quantity       | Number        | Amount of items left in the shipment         |
| Size           | Number        | Amount of items the shipment originally held |
| Price          | Number        | Price of shipment                            |
| Name           | String        | Name of shipment                             |
| Category       | String        | Category of shipment in F4 menu              |
| Type           | String        | Class name of shipment item entity           |
| Model          | String        | Model path of item                           |
| Separate       | Boolean `1/0` | Whether the shipment is also sold separately |
| Separate Price | Number        | Price of item when sold separately           |
| Shipment       | Entity        | The shipment itself                          |

## Technical Information

##### Entity
`gmod_wire_shipment_controller`

##### STool
`wire_shipment_controller`