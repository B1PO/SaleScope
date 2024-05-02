import Foundation

struct SalesData: Identifiable {
    let id = UUID()
    var date: Date
    var sales: Int
}

struct SalesRecord: Identifiable {
    var id = UUID()
    var date: Date
    var sales: Int
    var month: String
    var year: String
    
    init(date: Date, sales: Int, month: String, year: String) {
        self.date = date
        self.sales = sales
        self.month = month
        self.year = year
    }
}
