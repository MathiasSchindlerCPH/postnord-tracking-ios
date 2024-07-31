import Foundation

struct TrackingInformationResponse: Codable {
    let shipments: [Shipment]?
}

struct Shipment: Codable {
    let shipmentId: String?
    let status: String?
    let items: [Item]?
    let statusText: StatusText?
    let consignor: Consignor?
    let consignee: Consignee?
    let service: Service?
    let totalWeight: TotalWeight?
}

struct Item: Codable {
    let itemId: String?
    let events: [Event]?
}

struct Event: Codable {
    let eventTime: String?
    let eventCode: String?
    let status: String?
    let eventDescription: String?
    let location: Location?
}

struct Location: Codable {
    let displayName: String?
    let name: String?
    let countryCode: String?
    let country: String?
    let postcode: String?
    let city: String?
    let locationType: String?
}

struct Consignor: Codable {
    let name: String?
}

struct Consignee: Codable {
    let address: Address?
}

struct Address: Codable {
    let city: String?
    let postCode: String?
    let country: String?
}

struct StatusText: Codable {
    let header: String?
}

struct Service: Codable {
    let name: String?
}

struct TotalWeight: Codable {
    let value: String?
    let unit: String?
}

struct ShipmentEvent: Identifiable {
    let id = UUID()
    let eventTime: String
    let eventDescription: String
    let locationName: String
    let locationCountry: String
    
    init(eventTime: String, eventDescription: String, locationName: String, locationCountry: String) {
        self.eventTime = ShipmentEvent.formatEventTime(eventTime)
        self.eventDescription = eventDescription
        self.locationName = locationName
        self.locationCountry = locationCountry
    }
    
    static func formatEventTime(_ eventTime: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: eventTime) {
            formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
            return formatter.string(from: date)
        } else {
            return "Unknown time"
        }
    }
}


class APIManager {
    static func fetchShipmentDetails(for id: String, locale: String, completion: @escaping (Result<(statusSummary: String, statusShort: String, shipmentWeight: String, senderName: String, receiverAddress: String, collectionMethod: String, events: [ShipmentEvent]), Error>) -> Void) {
        let apiKey = "b5dbbd1173510f2d9cad0f9f280ab330"
        let baseURL = "https://api2.postnord.com/rest/shipment/v5/trackandtrace/findByIdentifier.json"
        
        guard let url = URL(string: "\(baseURL)?apikey=\(apiKey)&id=\(id)&locale=\(locale)") else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 1, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode([String: TrackingInformationResponse].self, from: data)
                if let trackingResponse = response["TrackingInformationResponse"],
                   let shipment = trackingResponse.shipments?.first,
                   let item = shipment.items?.first,
                   let events = item.events {
                    
                    let statusSummary = shipment.statusText?.header ?? "Unknown status"
                    let statusShort = shipment.status ?? "Unknown status"
                    let senderName = shipment.consignor?.name ?? "Unknown sender"
                    let collectionMethod = shipment.service?.name ?? "Unknown collection method"
                    let receiverCity = shipment.consignee?.address?.city ?? "Unknown city"
                    let receiverPostCode = shipment.consignee?.address?.postCode ?? "Unknown postcode"
                    let receiverCountry = shipment.consignee?.address?.country ?? "Unknown country"
                    let weightValue = shipment.totalWeight?.value ?? "Unknown value"
                    let weightUnit = shipment.totalWeight?.unit ?? "Unknown unit"
                    
                    let receiverAddress: String
                    if receiverCity != "Unknown city" && receiverPostCode != "Unknown postcode" && receiverCountry != "Unknown country" {
                        receiverAddress = "\(receiverPostCode) \(receiverCity), \(receiverCountry)"
                    } else {
                        receiverAddress = "Unknown receiver adress"
                    }
                    
                    let shipmentWeight: String
                    if weightValue != "Unknown value" && weightUnit != "Unknown unit" {
                        shipmentWeight = "\(weightValue) \(weightUnit)"
                    } else {
                        shipmentWeight = "Unknown weight"
                    }
                    
                    var shipmentEvents = events.map { event in
                        ShipmentEvent(
                            eventTime: event.eventTime ?? "Unknown time",
                            eventDescription: event.eventDescription ?? "Unknown description",
                            locationName: event.location?.name ?? "Unknown location",
                            locationCountry: event.location?.country ?? "Unknown country"
                        )
                    }
                    shipmentEvents.reverse()
                    
                    completion(.success((statusSummary: statusSummary, statusShort: statusShort, shipmentWeight: shipmentWeight, senderName: senderName, receiverAddress: receiverAddress, collectionMethod: collectionMethod, events: shipmentEvents)))
                } else {
                    completion(.failure(NSError(domain: "No shipments found", code: 1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
