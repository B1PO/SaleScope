import SwiftUI
import Foundation  // Necessary for sqrt

struct ContentView: View {
    var salesData: [SalesData]
    var totalSales: Int
    var totalRecords: Int
    var averageSales: Double
    var standardDeviation: Double
    var salesByYear: [Int: Int]
    var averageSalesByYear: [Int: Double]
    var monthlySales: [String: Int]
    var sortedAverageMonthlySales: [(String, Double)]  // Tuple to store sorted monthly averages

    init() {
        let rawData = readCSV(from: "time_series")
        self.salesData = rawData.map { SalesData(date: $0.date, sales: $0.sales) }
        self.totalSales = salesData.reduce(0) { $0 + $1.sales }
        self.totalRecords = salesData.count
        self.averageSales = self.totalRecords > 0 ? Double(self.totalSales) / Double(self.totalRecords) : 0

        // MARK: Calculate sales and average by year
        self.salesByYear = [:]
        var countByYear: [Int: Int] = [:]
        let calendar = Calendar.current
        for sale in salesData {
            let year = calendar.component(.year, from: sale.date)
            salesByYear[year, default: 0] += sale.sales
            countByYear[year, default: 0] += 1
        }
        self.averageSalesByYear = [:]
        for (year, totalSales) in salesByYear {
            let count = countByYear[year] ?? 0
            averageSalesByYear[year] = count > 0 ? Double(totalSales) / Double(count) : 0
        }

        // MARK: Calculate monthly sales and averages
        self.monthlySales = [:]
        var countByMonth: [String: Int] = [:]
        for sale in salesData {
            let yearMonth = "\(calendar.component(.year, from: sale.date))-\(String(format: "%02d", calendar.component(.month, from: sale.date)))"
            monthlySales[yearMonth, default: 0] += sale.sales
            countByMonth[yearMonth, default: 0] += 1
        }

        // MARK: Sort monthly sales averages for use in charts
        var averageMonthlySales = [String: Double]()
        for (month, totalSales) in monthlySales {
            let count = countByMonth[month] ?? 0
            averageMonthlySales[month] = count > 0 ? Double(totalSales) / Double(count) : 0
        }
        self.sortedAverageMonthlySales = averageMonthlySales.sorted { $0.key < $1.key }
        
        // MARK: Calculate standard deviation
        var sumOfSquaredDiffs = 0.0
        for sale in salesData {
            let diff = Double(sale.sales) - self.averageSales
            sumOfSquaredDiffs += diff * diff
        }
        self.standardDeviation = sqrt(sumOfSquaredDiffs / Double(self.totalRecords - 1))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                
                Text("Total Sales: \(totalSales)")
                Text("Total Records: \(totalRecords)")
                Text("Average Sales: \(averageSales, specifier: "%.2f")")
                Text("Standard Deviation: \(standardDeviation, specifier: "%.2f")")
                ForEach(salesByYear.sorted(by: { $0.key < $1.key }), id: \.key) { year, total in
                    Text("Sales in \(year): \(total)")
                    Text("Average Sales in \(year): \(averageSalesByYear[year] ?? 0, specifier: "%.2f")")
                }
                ForEach(sortedAverageMonthlySales, id: \.0) { month, average in
                    Text("Average Sales in \(month): \(average, specifier: "%.2f")")
                }
                List(salesData, id: \.id) { data in
                    Text("\(data.date.formatted()): \(data.sales)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
