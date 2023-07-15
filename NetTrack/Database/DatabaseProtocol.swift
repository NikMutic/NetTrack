//
//  DatabaseProtocol.swift
//  NetTrack
//
//  Created by Nikola Mutic on 24/4/2023.
//

import Foundation

enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType {
    case prefix
    case prefixType
    case vlan
    case IPAddress
    
    case manufacturer
    case deviceType
    case site
    case location
    case rack
    case device
    
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType { get set }
    
    func onManufacturersChange(change: DatabaseChange, manufacturers: [Manufacturer])
    func onDeviceTypeChange(change: DatabaseChange, deviceTypes: [DeviceType])
    func onSiteChange(change: DatabaseChange, sites: [Site])
    func onLocationChange(change: DatabaseChange, locations: [Location])
    func onRackChange(change: DatabaseChange, racks: [Rack])
    func onDeviceChange(change: DatabaseChange, devices: [Device])
    
    func onPrefixChange(change: DatabaseChange, prefixes: [Prefix])
    func onPrefixTypesChange(change: DatabaseChange, prefixTypes: [PrefixType])
    func onVlanChange(change: DatabaseChange, vlans: [Vlan])
    func onIPAddressChange(change: DatabaseChange, ipAddresses: [IPAddress])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addManufacturer(name: String) -> Manufacturer
    func deleteManufacturer(_ manufacturer: Manufacturer)
    func getManufacturerById(_ manufacturerId: String?) -> Manufacturer
    
    func addDeviceType(manufacturerId: String, model: String) -> DeviceType
    func deleteDeviceType(_ deviceType: DeviceType)
    func getDeviceTypeById(_ deviceTypeId: String?) -> DeviceType
    
    func addSite(name: String, address: String) -> Site
    func deleteSite(_ site: Site)
    func getSiteById(_ siteId: String?) -> Site
    
    func addLocation(siteId: String, name: String, notes: String) -> Location
    func deleteLocation(_ location: Location)
    func getLocationById(_ locationId: String?) -> Location
    func getAllLocationsFromSiteId(_ siteId: String?) -> [Location]
    
    func addRack(name: String, locationId: String, siteId: String) -> Rack
    func deleteRack(_ rack: Rack)
    func getRackById(_ rackId: String?) -> Rack
    func getAllRacksFromLocationId(_ locationId: String?) -> [Rack]
    
    func addDevice(name: String, serialNumber: String, mac: String, notes: String, deviceTypeId: String, siteId: String, locationId: String, rackId: String, inStorage: Bool) -> Device
    func deleteDevice(_ device: Device)
    
    func login(email: String, password: String)
    func signup(email: String, password: String)
}


extension DatabaseListener {
    func onManufacturersChange(change: DatabaseChange, manufacturers: [Manufacturer]) {
        
    }
    func onDeviceTypeChange(change: DatabaseChange, deviceTypes: [DeviceType]) {
        
    }
    func onSiteChange(change: DatabaseChange, sites: [Site]) {
        
    }
    func onLocationChange(change: DatabaseChange, locations: [Location]) {
        
    }
    func onRackChange(change: DatabaseChange, racks: [Rack]) {
        
    }
    func onDeviceChange(change: DatabaseChange, devices: [Device]) {
        
    }
    
    func onPrefixChange(change: DatabaseChange, prefixes: [Prefix]) {
        
    }
    func onPrefixTypesChange(change: DatabaseChange, prefixTypes: [PrefixType]) {
        
    }
    func onVlanChange(change: DatabaseChange, vlans: [Vlan]) {
        
    }
    func onIPAddressChange(change: DatabaseChange, ipAddresses: [IPAddress]) {
        
    }
    
}
