import Foundation

struct TrackingInformationResponse: Codable {
    let shipments: [Shipment]?
}

struct Shipment: Codable {
    let shipmentId: String?
    let items: [Item]?
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



class APIManager {
    static func fetchShipmentDetails(for id: String, locale: String, completion: @escaping (Result<[Event], Error>) -> Void) {
        let apiKey = "b5dbbd1173510f2d9cad0f9f280ab330" // Replace with your actual API key
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
                    completion(.success(events))
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
