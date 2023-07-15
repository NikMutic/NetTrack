//
//  DetailDeviceViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 8/5/2023.
//

import UIKit

class DetailDeviceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var device: Device?
    
    let SECTION_DETAIL = 0
    let SECTION_LOCATION = 1
    let SECTION_API = 2
    
    let CELL_DETAIL = "detailCell"
    let CELL_LOCATION = "locationCell"
    let CELL_API = "apiCell"
    
    weak var firebaseController: FirebaseController?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = device else {
            return
        }
        
        nameLabel.text = device.name
        
        tableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController as? FirebaseController

    }
    
    
    // MARK: Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case SECTION_DETAIL:
            return 5
        case SECTION_LOCATION:
            return 3
        case SECTION_API:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_DETAIL {
            // show a cell for serial number, mac address, notes, device type
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DETAIL, for: indexPath) as! DetailTableViewCell
                cell.attributeLabel.text = "Serial Number"
                
                guard let serial = device?.serialNumber else {
                    return cell
                }
                
                cell.attributeValue.text = "\(serial)"
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DETAIL, for: indexPath) as! DetailTableViewCell
                cell.attributeLabel.text = "MAC Address"
                
                guard let mac = device?.mac else {
                    return cell
                }
                
                cell.attributeValue.text = "\(mac)"
                return cell
            }
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DETAIL, for: indexPath) as! DetailTableViewCell
                cell.attributeLabel.text = "Device Type"
                
                let deviceType = firebaseController?.getDeviceTypeById(device?.deviceTypeId)
                guard let deviceType = deviceType else {
                    return cell
                }
                
                cell.attributeValue.text = "\(deviceType.model!)"
                return cell
            }
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DETAIL, for: indexPath) as! DetailTableViewCell
                cell.attributeLabel.text = "Manufacturer"
                
                let deviceType = firebaseController?.getDeviceTypeById(device?.deviceTypeId)
                guard let deviceType = deviceType else {
                    return cell
                }
                
                let manufacturer = firebaseController?.getManufacturerById(deviceType.manufacturerId)
                
                guard let manufacturer = manufacturer else {
                    return cell
                }
                
                cell.attributeValue.text = "\(manufacturer.name!)"
                return cell
            }
            if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DETAIL, for: indexPath) as! DetailTableViewCell
                cell.attributeLabel.text = "Notes"

                guard let notes = device?.notes else {
                    return cell
                }
                
                cell.attributeValue.text = "\(notes)"
                return cell
            }
        }
        if indexPath.section == SECTION_LOCATION {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath) as! DetailTableViewCell
                cell.attributeLabel.text = "Site"
                
                let site = firebaseController?.getSiteById(device?.siteId)
                guard let site = site else {
                    return cell
                }
                
                cell.attributeValue.text = "\(site.name!)"
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath) as! DetailTableViewCell
                cell.attributeLabel.text = "Location"
                
                let location = firebaseController?.getLocationById(device?.locationId)

                guard let location = location else {
                    return cell
                }
                
                cell.attributeValue.text = "\(location.name!)"
                return cell
            }
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath) as! DetailTableViewCell
                guard let inStorage = device?.inStorage else {
                    return cell
                }
                if inStorage {
                    cell.attributeLabel.text = "In Storage"
                    cell.attributeValue.text = "\(inStorage)"
                    return cell
                } else {
                    cell.attributeLabel.text = "Rack"
                    
                    let rack = firebaseController?.getRackById(device?.rackId)
                    
                    guard let rack = rack else {
                        return cell
                    }
                    
                    cell.attributeValue.text = "\(rack.name!)"
                    return cell
                }
            }
        }
        if indexPath.section == SECTION_API {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_API, for: indexPath) as! DetailTableViewCell
                cell.attributeLabel.text = "Vendor"
//                cell.attributeValue.text = ""
                
                // API LOOKUP
                Task {
                    do {
                        // Create the URL for the request
                        let requestUrl = "https://www.macvendorlookup.com/api/v2/"
                        let param = device?.mac
                        guard let url = URL(string: requestUrl + (param ?? "")) else {
                            print("invalid URL")
//                            cell.attributeValue.text = "Invalid MAC address"
                            return
                        }
                        let urlRequest = URLRequest(url: url)
                        do {
                            let (data, response) = try await URLSession.shared.data(for: urlRequest)
                            if let httpResponse = response as? HTTPURLResponse {
                                if httpResponse.statusCode == 200 {
                                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                                    if let company = json.first?["company"] as? String {
                                        cell.attributeValue.text = company
                                    }
                                } else {
                                    print("API request failed with status code \(httpResponse.statusCode)")
//                                    cell.attributeValue.text = "Invalid MAC address"
                                }
                            } else {
                                print("API request failed with invalid response")
//                                cell.attributeValue.text = "Invalid MAC address"
                            }
                        }
                        catch let error {
                            print(error)
                        }
                    }
                }
                
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_API, for: indexPath) as! DetailTableViewCell
                cell.attributeLabel.text = "Country"
//                cell.attributeValue.text = ""
                
                // API LOOKUP
                // TODO: Fix bug where attribute value is empty when on info page multiple times
                Task {
                    do {
                        // Create the URL for the request
                        let requestUrl = "https://www.macvendorlookup.com/api/v2/"
                        let param = device?.mac
                        guard let url = URL(string: requestUrl + (param ?? "")) else {
                            print("invalid URL")
//                            cell.attributeValue.text = "Invalid MAC address"
                            return
                        }
                        let urlRequest = URLRequest(url: url)
                        do {
                            let (data, response) = try await URLSession.shared.data(for: urlRequest)
                            if let httpResponse = response as? HTTPURLResponse {
                                if httpResponse.statusCode == 200 {
                                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                                    if let country = json.first?["country"] as? String {
                                        cell.attributeValue.text = country
                                    }
                                } else {
                                    print("API request failed with status code \(httpResponse.statusCode)")
//                                    cell.attributeValue.text = "Invalid MAC address"
                                }
                            } else {
                                print("API request failed with invalid response")
//                                cell.attributeValue.text = "Invalid MAC address"
                            }
                        }
                        catch let error {
                            print(error)
                        }
                    }
                }
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_DETAIL {
            return "Details"
        }
        if section == SECTION_LOCATION {
            return "Location"
        }
        if section == SECTION_API {
            return "MAC Address vendor lookup"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
