# dccontrol - Datacenter Control
This Python construct provides an initial set of functions to manage Hardware in multiple Datacenters, and keep track of the switch settings.

## Datacenterlyout
* Datacenter
* may have multiple rooms
* may have multiple rows
* may have multiple racks
* have multiple slots

Every Slot can have a hardware (might be spread over mutliple slots, then the id is set multiple times)

Hardware is eighter a Switch, a Server or a Storage. Each of them have Networkports of a typ.
A networkconnection is only possible between an incoming and an outgoing port.
The Switchports (usually the only incoming onces) have vlan, with are global for the switches at the moment.
