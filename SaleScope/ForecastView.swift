import SwiftUI
import Foundation
import Charts

struct PredictionResponse: Decodable {
    var ventas_predichas: [String: Double]
}

struct PredictionRecord: Identifiable {
    let id = UUID()
    let date: Date
    let sales: Double
}

struct SaleRecord: Identifiable {
    let id = UUID()
    let date: Date
    let sales: Double
}

// Función para normalizar la fecha a un año base
func normalizeDate(_ date: Date) -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.month, .day], from: date)
    components.year = 2019  // Año base para todas las fechas
    return calendar.date(from: components)!
}

// Ajusta la implementación para la carga y normalización de datos de ventas
func loadSalesDataGroupedByYear() -> [Int: [SaleRecord]] {
    guard let filePath = Bundle.main.path(forResource: "time_series", ofType: "csv") else {
        print("CSV file not found.")
        return [:]
    }

    let url = URL(fileURLWithPath: filePath)
    var data: [Int: [SaleRecord]] = [:]
    var salesRecords = [SaleRecord]()

    do {
        let fileContents = try String(contentsOf: url, encoding: .utf8)
        let rows = fileContents.components(separatedBy: "\n")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count > 1, let date = dateFormatter.date(from: columns[0]), let sales = Double(columns[1]) {
                let calendar = Calendar.current
                let month = calendar.component(.month, from: date)
                if month >= 6 && month <= 8 {  // Solo incluir junio, julio y agosto
                    let normalizedDate = normalizeDate(date)  // Normalizar la fecha
                    let record = SaleRecord(date: normalizedDate, sales: sales)
                    let year = calendar.component(.year, from: date)  // Mantener el año original para el tipo
                    salesRecords.append(record)
                    data[year, default: []].append(record)
                }
            }
        }
    } catch {
        print("Error reading the CSV file: \(error)")
        return [:]
    }
    
    return data
}

// Ajusta también la carga de datos predichos para usar la fecha normalizada
func loadPredictedSalesData(completion: @escaping ([PredictionRecord]) -> Void) {
    guard let url = URL(string: "http://192.168.1.74:5008/predict") else {
        print("Invalid URL")
        return
    }
    
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            do {
                let decodedResponse = try JSONDecoder().decode(PredictionResponse.self, from: data)
                var records: [PredictionRecord] = []
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                for (dateString, sales) in decodedResponse.ventas_predichas {
                    if let date = dateFormatter.date(from: dateString) {
                        let normalizedDate = normalizeDate(date)  // Normalizar la fecha
                        let record = PredictionRecord(date: normalizedDate, sales: sales)
                        records.append(record)
                    }
                }
                
                let sortedRecords = records.sorted { $0.date < $1.date }
                DispatchQueue.main.async {
                    completion(sortedRecords)
                }
            } catch {
                print("Decoding failed: \(error)")
            }
        } else {
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }
    }.resume()
}

struct AxisLabelColorModifier: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .foregroundStyle(color)  // Aplicar el color a todas las subvistas
    }
}

struct ForecastView: View {
    @State private var salesDataByYear: [Int: [SaleRecord]] = [:]
    @State private var predictionsDataByYear: [Int: [PredictionRecord]] = [:]
    
    @State var isTapAll: Bool = true
    @State var isTap2017: Bool = false
    @State var isTap2018: Bool = false
    @State var isTap2019: Bool = false
    
    @State var isDataLoaded: Bool = false

    var UISW: CGFloat = UIScreen.main.bounds.width
    var UISH: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack{
            
            ZStack{
                Text("Summer Sales (")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.black)
                + Text(isTapAll ? "2017" : isTap2017 ? "2017" : "")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.orange)
                + Text(isTapAll ? ", " : "")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.black)
                + Text(isTapAll ? "2018" : isTap2018 ? "2018" : "")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.blue)
                + Text(isTapAll ? " and " : "")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.black)
                + Text(isTapAll ? "2019" : isTap2019 ? "2019" : "")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.purple)
                + Text(")")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.black)
            }
                .position(x: UISW * 0.31, y: UISH * 0.13)
            
            Circle()
                .foregroundColor(Color(UIColor(red: 0.37, green: 0.29, blue: 0.65, alpha: 1.00)))
                .frame(width: UISW * 1.3, height: UISH * 1.3)
                .position(x: 0, y: UISH)
            
            Circle()
                .foregroundColor(.white.opacity(0.1))
                .frame(width: UISW * 1.1, height: UISH * 1.1)
                .position(x: 0, y: UISH)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
                    .frame(width: UISW * 0.65, height: UISH * 0.65)
                    .shadow(color: .gray.opacity(0.2), radius: 10, x: 8, y: 8)
                if #available(iOS 16.0, *) {
                    Chart {
                        if isTapAll {
                            linesForAllYears()
                        }
                        if isTap2017 {
                            lineForYear(2017)
                        }
                        if isTap2018 {
                            lineForYear(2018)
                        }
                        if isTap2019 {
                            lineForYear(2019)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(preset: .aligned, position: .bottom)
                    }
                    .chartYAxis {
                        AxisMarks(preset: .aligned, position: .leading)
                    }
                    .frame(width: UISW * 0.6, height: UISH * 0.6)
                } else {
                    Text("iOS 16.0 or newer is required to use this feature.")
                }
            }.position(x: UISW * 0.36, y: UISH * 0.63)
            .onAppear {
                loadAllData()
            }
            
            Button {
                withAnimation (.easeInOut(duration: 0.5)){
                    isTapAll = true
                    isTap2017 = false
                    isTap2018 = false
                    isTap2019 = false
                }
            } label: {
                HStack{
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    Text("See all")
                        .font(.custom("Arial", size: 20))
                }.foregroundColor(Color(UIColor(red: 0.88, green: 0.36, blue: 0.45, alpha: 1.00)))
                    .padding()
            }.background(.white)
                .cornerRadius(10)
                .shadow(color: (Color(UIColor(red: 0.88, green: 0.36, blue: 0.45, alpha: 1.00))).opacity(isTapAll ? 0.9 : 0), radius: 10, x: 0, y: 0)
                .position(x: UISW * 0.85, y: UISH * 0.42)
            
            Button {
                withAnimation (.easeInOut(duration: 0.5)){
                    isTapAll = false
                    isTap2017 = true
                    isTap2018 = false
                    isTap2019 = false
                }
            } label: {
                HStack{
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    Text("See 2017")
                        .font(.custom("Arial", size: 20))
                }.foregroundColor(.orange)
                    .padding()
            }.background(.white)
                .cornerRadius(10)
                .shadow(color: .orange.opacity(isTap2017 ? 0.9 : 0), radius: 10, x: 0, y: 0)
                .position(x: UISW * 0.85, y: UISH * 0.52)
            
            Button {
                withAnimation (.easeInOut(duration: 0.5)){
                    isTapAll = false
                    isTap2017 = false
                    isTap2018 = true
                    isTap2019 = false
                }
            } label: {
                HStack{
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    Text("See 2018")
                        .font(.custom("Arial", size: 20))
                }.foregroundColor(.blue)
                    .padding()
            }.background(.white)
                .cornerRadius(10)
                .shadow(color: .blue.opacity(isTap2018 ? 0.9 : 0), radius: 10, x: 0, y: 0)
                .position(x: UISW * 0.85, y: UISH * 0.62)
            
            Button {
                withAnimation (.easeInOut(duration: 0.5)){
                    isTapAll = false
                    isTap2017 = false
                    isTap2018 = false
                    isTap2019 = true
                }
            } label: {
                HStack{
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    Text("See 2019")
                        .font(.custom("Arial", size: 20))
                }.foregroundColor(.purple)
                    .padding()
            }.background(.white)
                .cornerRadius(10)
                .shadow(color: .purple.opacity(isTap2019 ? 0.9 : 0), radius: 10, x: 0, y: 0)
                .position(x: UISW * 0.85, y: UISH * 0.72)
            
        }.ignoresSafeArea()
    }

    private func linesForAllYears() -> some ChartContent {
        let allYears = Set(salesDataByYear.keys).union(predictionsDataByYear.keys).sorted()
        return ForEach(allYears, id: \.self) { year in
            if let records = salesDataByYear[year], !records.isEmpty {
                lineMarkGroup(for: records, year: year, isPrediction: false)
            }
            if let predictions = predictionsDataByYear[year], !predictions.isEmpty {
                lineMarkGroup(for: predictions, year: year, isPrediction: true)
            }
        }
    }


    private func lineForYear(_ year: Int) -> some ChartContent {
        ForEach([false, true], id: \.self) { isPrediction in
            if isPrediction, let predictions = predictionsDataByYear[year] {
                lineMarkGroup(for: predictions, year: year, isPrediction: true)
            } else if let records = salesDataByYear[year] {
                lineMarkGroup(for: records, year: year, isPrediction: false)
            }
        }
    }

    private func lineMarkGroup<Data: HasDateAndSales>(for data: [Data], year: Int, isPrediction: Bool) -> some ChartContent {
        ForEach(data, id: \.id) { record in
            LineMark(
                x: .value("Date", record.date, unit: .day),
                y: .value("Sales", record.sales)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(colorForYear(year: year, isPrediction: isPrediction))
            .symbol(by: .value("Year", String(year))) // Using a symbol based on the year
        }
    }

    func loadAllData() {
        let group = DispatchGroup()
        
        // Cargar datos de ventas locales
        salesDataByYear = loadSalesDataGroupedByYear()

        // Cargar datos de predicciones de la API
        group.enter()
        loadPredictedSalesData { predictions in
            for prediction in predictions {
                let year = Calendar.current.component(.year, from: prediction.date)
                predictionsDataByYear[year, default: []].append(prediction)
            }
            group.leave()
        }

        // Callback cuando todos los datos están cargados
        group.notify(queue: .main) {
            self.refreshChartData()
        }
    }

    func refreshChartData() {
        // Forzar una actualización de la vista para reflejar los datos cargados
        withAnimation {
            // Puedes utilizar un estado adicional para forzar la actualización, si es necesario
            self.isDataLoaded.toggle() // Suponiendo que `isDataLoaded` es una variable @State
        }
    }


    func colorForYear(year: Int, isPrediction: Bool) -> Color {
        switch (year, isPrediction) {
        case (2017, false), (2018, false): return year == 2017 ? .orange : .blue
        case (2019, true): return .purple // Color for predictions
        default: return .gray
        }
    }
}

protocol HasDateAndSales: Identifiable {
    var date: Date { get }
    var sales: Double { get }
}

extension SaleRecord: HasDateAndSales {}
extension PredictionRecord: HasDateAndSales {}

// Implementa tu estructura de vista previa si la necesitas
#Preview {
    ForecastView()
}

