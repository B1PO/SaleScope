import Foundation

// Función para leer datos desde un archivo CSV
func readCSV(from fileName: String) -> [(date: Date, sales: Int)] {
    guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("CSV file not found")
        return []
    }
    
    do {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let rows = data.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Ajusta este formato a lo que uses en el CSV
        
        var results: [(Date, Int)] = []
        
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if let date = dateFormatter.date(from: columns[0]), let sales = Int(columns[1]) {
                results.append((date, sales))
            }
        }
        
        return results
    } catch {
        print("Error reading CSV file: \(error)")
        return []
    }
}

