//
//  FirebaseController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 24/4/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
   
    var listeners = MulticastDelegate<DatabaseListener>()
    
    // firebase stuff
    var authController: Auth
    var database: Firestore
    var currentUser: FirebaseAuth.User?
    var userRef: CollectionReference? // reference to top level 'users' collection
    
    // model stuff
    var manufacturerList: [Manufacturer]
    var manufacturerRef: CollectionReference?
    
    var deviceTypeList: [DeviceType]
    var deviceTypeRef: CollectionReference?
    
    var siteList: [Site]
    var sitesRef: CollectionReference?
    
    var locationList: [Location]
    var locationsRef: CollectionReference?
    
    var racksList: [Rack]
    var racksRef: CollectionReference?
    
    var deviceList: [Device]
    var deviceRef: CollectionReference?
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        
        manufacturerList = [Manufacturer]()
        deviceTypeList = [DeviceType]()
        siteList = [Site]()
        locationList = [Location]()
        racksList = [Rack]()
        deviceList = [Device]()
        
        super.init()
        authController.addStateDidChangeListener { [self] (auth, user) in
            // the auth state has changed. User is either logged in or logged out
            if let user = user {
                currentUser = user
                userRef = database.collection("users")
                self.setupListeners()
            } else {
                print("User is not signed in")
                self.cleanup()
            }
        }
    }
    
    func cleanup() {
        manufacturerList = []
        deviceTypeList = []
        siteList = []
        locationList = []
        racksList = []
        deviceList = []
    }
    
    // MARK: - Listeners
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if (listener.listenerType == .manufacturer || listener.listenerType == .all) {
            listener.onManufacturersChange(change: .update, manufacturers: manufacturerList)
        }
        if (listener.listenerType == .deviceType || listener.listenerType == .all) {
            listener.onDeviceTypeChange(change: .update, deviceTypes: deviceTypeList)
        }
        if (listener.listenerType == .site || listener.listenerType == .all) {
            listener.onSiteChange(change: .update, sites: siteList)
        }
        if (listener.listenerType == .location || listener.listenerType == .all) {
            listener.onLocationChange(change: .update, locations: locationList)
        }
        if (listener.listenerType == .rack || listener.listenerType == .all ) {
            listener.onRackChange(change: .update, racks: racksList)
        }
        if (listener.listenerType == .device || listener.listenerType == .all) {
            listener.onDeviceChange(change: .update, devices: deviceList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // update this for each listener
    func setupListeners() {
        self.setupManufacturerListener()
        self.setupDeviceTypeListener()
        self.setupSiteListener()
        self.setupLocationListener()
        self.setupRackListener()
        self.setupDeviceListener()
    }
    
    // MARK: - Manufacturer stuff
    func parseManufacturerSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            var parsedManufacturer: Manufacturer?
            do {
                parsedManufacturer = try change.document.data(as: Manufacturer.self)
            } catch {
                print("Unable to decode manufacturer")
                return
            }
            guard let manufacturer = parsedManufacturer else {
                print("Document does not exist")
                return
            }
            if change.type == .added {
                manufacturerList.insert(manufacturer, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                manufacturerList[Int(change.oldIndex)] = manufacturer
            }
            else if change.type == .removed {
                manufacturerList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke{
                (listener) in
                if listener.listenerType == ListenerType.manufacturer || listener.listenerType == ListenerType.all {
                    listener.onManufacturersChange(change: .update, manufacturers: manufacturerList)
                }
            }
        }
    }
    
    func addManufacturer(name: String) -> Manufacturer {
        let manufacturer = Manufacturer()
        manufacturer.name = name
        
        guard let userId = currentUser?.uid else {
            // TODO: Handle the case where there is no current user logged in
            return manufacturer
        }
        
        let userManufacturerRef = userRef?.document(userId).collection("manufacturers")
        if let manufacturerRef = userManufacturerRef?.addDocument(data: ["name": name]) {
            manufacturer.id = manufacturerRef.documentID
            manufacturer.name = name
        }
        return manufacturer
    }
    
    func deleteManufacturer(_ manufacturer: Manufacturer) {
        guard let currentUser = currentUser else {
            print("No user is currently logged in")
            return
        }
        
        guard let manufacturerId = manufacturer.id else {
            print("Manufacturer does not have a valid ID")
            return
        }
        
        userRef?.document(currentUser.uid).collection("manufacturers").document(manufacturerId).delete() { err in
            if let error = err {
                print("Error deleting manufacturer: \(error)")
            } else {
                print("Manufacturer deleted successfully")
            }
        }
    }
    
    func getManufacturerById(_ manufacturerId: String?) -> Manufacturer {
        for manufacturer in manufacturerList {
            if manufacturer.id == manufacturerId {
                return manufacturer
            }
        }
        // hopefully we never get here lol
        return Manufacturer()
    }
    
    func setupManufacturerListener() {
        guard let userId = currentUser?.uid else {
            print("Current user not found")
            return
        }
        userRef?.document(userId).collection("manufacturers").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching manufacturers: \(error)")
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch manufacturers with error: \(String(describing: error))")
                return
            }
            self.parseManufacturerSnapshot(snapshot: querySnapshot)
        }
    }
    
    
    // MARK: - DeviceType stuff
    func addDeviceType(manufacturerId: String, model: String) -> DeviceType {
        let deviceType = DeviceType()
        
        guard let userId = currentUser?.uid else {
            // TODO: Handle the case where there is no current user logged in
            return deviceType
        }
        
        let userDeviceTypeRef = userRef?.document(userId).collection("deviceTypes")
        if let deviceTypeRef = userDeviceTypeRef?.addDocument(data: ["manufacturerId": manufacturerId, "model": model]) {
            deviceType.id = deviceTypeRef.documentID
            deviceType.model = model
            deviceType.manufacturerId = manufacturerId
        }
        
        return deviceType
    }
    
    func deleteDeviceType(_ deviceType: DeviceType) {
        guard let currentUser = currentUser else {
            print("No user is currently logged in")
            return
        }
        
        guard let deviceId = deviceType.id else {
            print("DeviceType does not have a valid ID")
            return
        }
        
        userRef?.document(currentUser.uid).collection("deviceTypes").document(deviceId).delete() { err in
            if let error = err {
                print("Error deleting deviceType: \(error)")
            } else {
                print("DeviceType deleted successfully")
            }
        }
    }
    
    func setupDeviceTypeListener() {
        guard let userId = currentUser?.uid else {
            print("Current user not found")
            return
        }
        userRef?.document(userId).collection("deviceTypes").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching deviceTypes: \(error)")
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch deviceTypes with error: \(String(describing: error))")
                return
            }
            self.parseDeviceTypeSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseDeviceTypeSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            var parsedDeviceType: DeviceType?
            do {
                parsedDeviceType = try change.document.data(as: DeviceType.self)
            } catch {
                print("Unable to decode deviceType")
                return
            }
            guard let deviceType = parsedDeviceType else {
                print("Document does not exist")
                return
            }
            // TODO: Fix manufacturerId not being parsed properly. Maybe codingKeys?
            if change.type == .added {
                deviceTypeList.insert(deviceType, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                deviceTypeList[Int(change.oldIndex)] = deviceType
            }
            else if change.type == .removed {
                deviceTypeList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke{
                (listener) in
                if listener.listenerType == ListenerType.deviceType || listener.listenerType == ListenerType.all {
                    listener.onDeviceTypeChange(change: .update, deviceTypes: deviceTypeList)
                }
            }
        }
    }
    func getDeviceTypeById(_ deviceTypeId: String?) -> DeviceType {
        for deviceType in deviceTypeList {
            if deviceType.id == deviceTypeId {
                return deviceType
            }
        }
        return DeviceType()
    }
    
    
    // MARK: - Site stuff
    func addSite(name: String, address: String) -> Site {
        let site = Site()
        
        guard let userId = currentUser?.uid else {
            // TODO: Handle the case where there is no current user logged in
            return site
        }
        
        let userSiteRef = userRef?.document(userId).collection("sites")
        if let sitesRef = userSiteRef?.addDocument(data: ["name": name, "address": address]) {
            site.id = sitesRef.documentID
            site.name = name
            site.address = address
        }
        
        return site
    }
    
    func deleteSite(_ site: Site) {
        guard let currentUser = currentUser else {
            print("No user is currently logged in")
            return
        }
        
        guard let siteId = site.id else {
            print("Site does not have a valid ID")
            return
        }
        
        userRef?.document(currentUser.uid).collection("sites").document(siteId).delete() { err in
            if let error = err {
                print("Error deleting Site: \(error)")
            } else {
                print("Site deleted successfully")
            }
        }
    }
    
    func setupSiteListener() {
        guard let userId = currentUser?.uid else {
            print("Current user not found")
            return
        }
        userRef?.document(userId).collection("sites").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching sites: \(error)")
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch sites with error: \(String(describing: error))")
                return
            }
            self.parseSitesSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseSitesSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            var parsedSite: Site?
            do {
                parsedSite = try change.document.data(as: Site.self)
            } catch {
                print("Unable to decode site")
                return
            }
            guard let site = parsedSite else {
                print("Document does not exist")
                return
            }
            // TODO: Fix manufacturerId not being parsed properly. Maybe codingKeys?
            if change.type == .added {
                siteList.insert(site, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                siteList[Int(change.oldIndex)] = site
            }
            else if change.type == .removed {
                siteList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke{
                (listener) in
                if listener.listenerType == ListenerType.site || listener.listenerType == ListenerType.all {
                    listener.onSiteChange(change: .update, sites: siteList)
                }
            }
        }
    }
    
    func getSiteById(_ siteId: String?) -> Site {
        for site in siteList {
            if site.id == siteId {
                return site
            }
        }
        // dunno what to do here lol
        return Site()
    }
    
    
    // MARK: - Location stuff
    
    func addLocation(siteId: String, name: String, notes: String) -> Location {
        let location = Location()
        
        guard let userId = currentUser?.uid else {
            // TODO: Handle the case where there is no current user logged in
            return location
        }
        
        let userLocationRef = userRef?.document(userId).collection("locations")
        
        if let locationsRef = userLocationRef?.addDocument(data: ["siteId": siteId, "name": name, "notes": notes]) {
            location.id = locationsRef.documentID
            location.name = name
            location.notes = notes
            location.siteId = siteId
        }
        
        return location
    }
    
    func deleteLocation(_ location: Location) {
        guard let currentUser = currentUser else {
            print("No user is currently logged in")
            return
        }
        
        guard let locationId = location.id else {
            print("Location does not have a valid ID")
            return
        }
        
        userRef?.document(currentUser.uid).collection("locations").document(locationId).delete() { err in
            if let error = err {
                print("Error deleting Location: \(error)")
            } else {
                print("Location deleted successfully")
            }
        }
    }
    
    func setupLocationListener() {
        guard let userId = currentUser?.uid else {
            print("Current user not found")
            return
        }
        userRef?.document(userId).collection("locations").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching locations: \(error)")
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch locations with error: \(String(describing: error))")
                return
            }
            self.parseLocationsSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseLocationsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            var parsedLocation: Location?
            do {
                parsedLocation = try change.document.data(as: Location.self)
            } catch {
                print("Unable to decode location")
                return
            }
            guard let location = parsedLocation else {
                print("Document does not exist")
                return
            }
            if change.type == .added {
                locationList.insert(location, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                locationList[Int(change.oldIndex)] = location
            }
            else if change.type == .removed {
                locationList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke{
                (listener) in
                if listener.listenerType == ListenerType.location || listener.listenerType == ListenerType.all {
                    listener.onLocationChange(change: .update, locations: locationList)
                }
            }
        }
    }
    
    func getLocationById(_ locationId: String?) -> Location {
        for location in locationList {
            if location.id == locationId {
                return location
            }
        }
        return Location()
    }
    
    func getAllLocationsFromSiteId(_ siteId: String?) -> [Location] {
        var result: [Location] = []
        for location in locationList {
            if location.siteId == siteId {
                result.append(location)
            }
        }
        return result
    }
    
    
    // MARK: - Rack stuff
    
    func addRack(name: String, locationId: String, siteId: String) -> Rack {
        var rack = Rack()
        
        guard let userId = currentUser?.uid else {
            // TODO: Handle the case where there is no current user logged in
            return rack
        }
        
        let userRackRef = userRef?.document(userId).collection("racks")
        
        if let racksRef = userRackRef?.addDocument(data: ["name": name, "locationId": locationId, "siteId": siteId]) {
            rack.id = racksRef.documentID
            rack.name = name
            rack.siteId = siteId
            rack.locationId = locationId
        }
        
        return rack
    }
    
    func deleteRack(_ rack: Rack) {
        guard let currentUser = currentUser else {
            print("No user is currently logged in")
            return
        }
        
        guard let rackId = rack.id else {
            print("Rack does not have a valid ID")
            return
        }
        
        userRef?.document(currentUser.uid).collection("racks").document(rackId).delete() { err in
            if let error = err {
                print("Error deleting Rack: \(error)")
            } else {
                print("Rack deleted successfully")
            }
        }
    }
    
    func setupRackListener() {
        guard let userId = currentUser?.uid else {
            print("Current user not found")
            return
        }
        userRef?.document(userId).collection("racks").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching racks: \(error)")
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch racks with error: \(String(describing: error))")
                return
            }
            self.parseRacksSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseRacksSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            var parsedRack: Rack?
            do {
                parsedRack = try change.document.data(as: Rack.self)
            } catch {
                print("Unable to decode rack")
                return
            }
            guard let rack = parsedRack else {
                print("Document does not exist")
                return
            }
            if change.type == .added {
                racksList.insert(rack, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                racksList[Int(change.oldIndex)] = rack
            }
            else if change.type == .removed {
                racksList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke{
                (listener) in
                if listener.listenerType == ListenerType.rack || listener.listenerType == ListenerType.all {
                    listener.onRackChange(change: .update, racks: racksList)
                }
            }
        }
    }
    
    func getAllRacksFromLocationId(_ locationId: String?) -> [Rack] {
        var result: [Rack] = []
        for rack in racksList {
            if rack.locationId == locationId {
                result.append(rack)
            }
        }
        return result
    }
    
    func getRackById(_ rackId: String?) -> Rack {
        for rack in racksList {
            if rack.id == rackId {
                return rack
            }
        }
        return Rack()
    }
    
    
    // MARK: - Device stuff
    func addDevice(name: String, serialNumber: String, mac: String, notes: String, deviceTypeId: String, siteId: String, locationId: String, rackId: String, inStorage: Bool) -> Device {
        var device = Device()
        
        guard let userId = currentUser?.uid else {
            // TODO: Handle the case where there is no current user logged in
            return device
        }
        
        let userDeviceRef = userRef?.document(userId).collection("devices")
        
        if let deviceRef = userDeviceRef?.addDocument(data: ["name": name, "serialNumber": serialNumber, "mac": mac, "notes": notes, "deviceTypeId": deviceTypeId, "siteId": siteId, "locationId": locationId, "rackId": rackId, "inStorage": inStorage]) {
            device.id = deviceRef.documentID
            device.name = name
            device.serialNumber = serialNumber
            device.mac = mac
            device.notes = notes
            device.deviceTypeId = deviceTypeId
            device.siteId = siteId
            device.locationId = locationId
            device.rackId = rackId
            device.inStorage = inStorage
        }
        
        return device
    }
    
    func deleteDevice(_ device: Device) {
        guard let currentUser = currentUser else {
            print("No user is currently logged in")
            return
        }
        
        guard let deviceId = device.id else {
            print("Device does not have a valid ID")
            return
        }
        
        userRef?.document(currentUser.uid).collection("devices").document(deviceId).delete() { err in
            if let error = err {
                print("Error deleting device: \(error)")
            } else {
                print("Device deleted successfully")
            }
        }
    }
    
    func setupDeviceListener() {
        guard let userId = currentUser?.uid else {
            print("Current user not found")
            return
        }
        userRef?.document(userId).collection("devices").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching devices: \(error)")
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch devices with error: \(String(describing: error))")
                return
            }
            self.parseDeviceSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseDeviceSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            var parsedDevice: Device?
            do {
                parsedDevice = try change.document.data(as: Device.self)
            } catch {
                print("Unable to decode device")
                return
            }
            guard let device = parsedDevice else {
                print("Document does not exist")
                return
            }
            if change.type == .added {
                deviceList.insert(device, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                deviceList[Int(change.oldIndex)] = device
            }
            else if change.type == .removed {
                deviceList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke{
                (listener) in
                if listener.listenerType == ListenerType.device || listener.listenerType == ListenerType.all {
                    listener.onDeviceChange(change: .update, devices: deviceList)
                }
            }
        }
    }
    
    // MARK: - Firebase Auth stuff
    
    func login(email: String, password: String) {
        Task {
            do {
                let _ = try await authController.signIn(withEmail: email, password: password)
                // TODO: Do something with authResult
                // user was logged in, do something
                // setup listeners or something
            } catch {
                print("Error logging in: \(String(describing: error))")
            }
        }
    }
    
    func signup(email: String, password: String) {
        Task {
            do {
                let _ = try await authController.createUser(withEmail: email, password: password)
                // TODO: Do something with authResult
                // user was logged in, do something
                // setup listeners or something
                self.setupListeners()
            } catch {
                print("Error creating user: \(String(describing: error))")
            }
        }
    }
    
    
}
