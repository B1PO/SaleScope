import SwiftUI
import Foundation
import Charts

struct ForecastDataResponse: Decodable {
    var ventas_predichas: [String: Double]
}

enum SalesDataType {
    case nov, dic
}

struct HistoricalRecord: Identifiable {
    let id = UUID()
    let date: Date
    let sales: Double
    let type: SalesDataType
}

struct PredictedRecord: Identifiable {
    let id = UUID()
    let date: Date
    let sales: Double
    let type: SalesDataType
}

func adjustDate(_ date: Date) -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.month, .day], from: date)
    components.year = 2018
    return calendar.date(from: components)!
}

func retrieveHistoricalData() -> [Int: [HistoricalRecord]] {
    guard let filePath = Bundle.main.path(forResource: "time_series", ofType: "csv") else {
        print("CSV file not found.")
        return [:]
    }

    let url = URL(fileURLWithPath: filePath)
    var data: [Int: [HistoricalRecord]] = [:]
    var salesRecords = [HistoricalRecord]()

    do {
        let fileContents = try String(contentsOf: url, encoding: .utf8)
        let rows = fileContents.components(separatedBy: "\n")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count > 1, let date = dateFormatter.date(from: columns[0]), let sales = Double(columns[1]) {
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                if year == 2018 && calendar.component(.month, from: date) == 11 && calendar.component(.day, from: date) > 23 {
                    let adjustedDate = adjustDate(date)
                    let record = HistoricalRecord(date: adjustedDate, sales: sales, type: .nov)
                    salesRecords.append(record)
                    data[year, default: []].append(record)
                } else if year == 2018 && calendar.component(.month, from: date) == 12 {
                    let adjustedDate = adjustDate(date)
                    let record = HistoricalRecord(date: adjustedDate, sales: sales, type: .dic)
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

func fetchPredictedSales(completion: @escaping ([PredictedRecord]) -> Void) {
    guard let url = URL(string: "http://192.168.1.74:5008/dic") else {
        print("Invalid URL")
        return
    }

    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Fetch failed: \(error.localizedDescription)")
            return
        }

        guard let data = data else {
            print("No data received")
            return
        }

        do {
            let decodedResponse = try JSONDecoder().decode(ForecastDataResponse.self, from: data)
            print("Received data: \(decodedResponse)")
            var records: [PredictedRecord] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            for (dateString, sales) in decodedResponse.ventas_predichas {
                if let date = dateFormatter.date(from: dateString) {
                    let adjustedDate = adjustDate(date)
                    let record = PredictedRecord(date: adjustedDate, sales: sales, type: .dic) // Assuming this is for December (dic)
                    records.append(record)
                }
            }

            DispatchQueue.main.async {
                completion(records.sorted { $0.date < $1.date })
            }
        } catch {
            print("Decoding failed: \(error)")
        }
    }.resume()
}

struct DecemberView: View {
    @State private var historicalDataByYear: [Int: [HistoricalRecord]] = [:]
    @State private var predictedData: [PredictedRecord] = []
    
    @State var isDataLoaded: Bool = false

    var UISW: CGFloat = UIScreen.main.bounds.width
    var UISH: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            
            ZStack{
                Text("December Forecaster")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.black)
            }
                .position(x: UISW * 0.25, y: UISH * 0.13)
            
            Circle()
                .foregroundColor(Color(UIColor(red: 0.37, green: 0.29, blue: 0.65, alpha: 1.00)))
                .frame(width: UISW * 1.3, height: UISH * 1.3)
                .position(x: UISW, y: UISH)
            
            Circle()
                .foregroundColor(.white.opacity(0.1))
                .frame(width: UISW * 1.1, height: UISH * 1.1)
                .position(x: UISW, y: UISH)
            
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.white)
                    .frame(width: UISW * 0.65, height: UISH * 0.65)
                    .shadow(color: .gray.opacity(0.2), radius: 10, x: -8, y: 8)
                
                Chart {
                    if !historicalDataByYear.isEmpty {
                        lineGroup(for: historicalDataByYear[2018] ?? [], isPrediction: false)
                    }
                    if !predictedData.isEmpty {
                        lineGroup(for: predictedData, isPrediction: true)
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned, position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned, position: .leading)
                }
                .frame(width: UISW * 0.6, height: UISH * 0.6)
                .onAppear {
                    loadData()
                }
            }.position(x: UISW * 0.5, y: UISH * 0.56)
            
        }.ignoresSafeArea()
    }
    
    private func lineGroup<Data: Identifiable & HasDateAndSales2>(for data: [Data], isPrediction: Bool) -> some ChartContent {
        ForEach(data) { record in
            LineMark(
                x: .value("Date", record.date, unit: .day),
                y: .value("Sales", record.sales)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(isPrediction ? .red : .red)
        }
    }
    
    func loadData() {
        historicalDataByYear = retrieveHistoricalData()
        fetchPredictedSales { predictions in
            predictedData = predictions
        }
    }
}

protocol HasDateAndSales2: Identifiable {
    var date: Date { get }
    var sales: Double { get }
}

extension HistoricalRecord: HasDateAndSales2 {}
extension PredictedRecord: HasDateAndSales2 {}

#Preview {
    DecemberView()
}
