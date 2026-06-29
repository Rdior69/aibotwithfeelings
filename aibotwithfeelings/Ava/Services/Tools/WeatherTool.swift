import Foundation

/// Open-Meteo geocoding + weather — free, no API key.
struct WeatherTool: ExternalTool {
    let kind: AvaToolKind = .weather

    func isRelevant(to message: String) -> Bool {
        IntentAnalyzer().analyze(message).tools.contains(.weather)
    }

    func gather(message: String, context: ToolSelection) async throws -> ExternalIntel? {
        let location = context.locationHint ?? "San Francisco"
        guard let encoded = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        let geoURL = "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=1"
        guard let geoURLObj = URL(string: geoURL) else { return nil }

        let (geoData, _) = try await URLSession.shared.data(from: geoURLObj)
        guard let geoJSON = try JSONSerialization.jsonObject(with: geoData) as? [String: Any],
              let results = geoJSON["results"] as? [[String: Any]],
              let first = results.first,
              let lat = first["latitude"] as? Double,
              let lon = first["longitude"] as? Double,
              let name = first["name"] as? String else { return nil }

        let weatherURL = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&temperature_unit=fahrenheit"
        guard let weatherURLObj = URL(string: weatherURL) else { return nil }

        let (weatherData, _) = try await URLSession.shared.data(from: weatherURLObj)
        guard let weatherJSON = try JSONSerialization.jsonObject(with: weatherData) as? [String: Any],
              let current = weatherJSON["current"] as? [String: Any],
              let temp = current["temperature_2m"] as? Double,
              let humidity = current["relative_humidity_2m"] as? Double,
              let code = current["weather_code"] as? Int else { return nil }

        let condition = weatherDescription(for: code)
        let summary = "\(name): \(Int(temp))°F, \(condition). Humidity \(Int(humidity))%."

        return ExternalIntel(
            tool: kind,
            summary: summary,
            source: "Open-Meteo"
        )
    }

    private func weatherDescription(for code: Int) -> String {
        switch code {
        case 0: return "clear sky"
        case 1, 2, 3: return "partly cloudy"
        case 45, 48: return "foggy"
        case 51, 53, 55: return "drizzle"
        case 61, 63, 65: return "rain"
        case 71, 73, 75: return "snow"
        case 80, 81, 82: return "rain showers"
        case 95, 96, 99: return "thunderstorm"
        default: return "variable conditions"
        }
    }
}
