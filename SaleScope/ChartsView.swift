//MARK:   IGNORAR, ESTE ES CÓDIGO DE EJEMPLO DE CHARTS ANIMADAS PERO NO JALA BIEN LOS DATOS

//import SwiftUI
//import Charts
//
//struct ChartsView: View {
//    @State private var salesRecords: [SalesRecord] = []
//    @State private var isAnimated: Bool = false
//    @State private var chartType: ChartType = .bar
//    
//    var body: some View {
//        NavigationStack {
//            List {
//                Section("Chart Type") {
//                    Picker("", selection: $chartType) {
//                        ForEach(ChartType.allCases, id: \.rawValue) { type in
//                            Text(type.rawValue).tag(type)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                }
//                
//                Section("Sales Data") {
//                    chartView
//                        .frame(height: 350)
//                }
//            }
//            .navigationTitle("Sales Chart")
//            .onAppear(perform: loadData)
//        }
//    }
//
//    private var chartView: some View {
//        Chart {
//            ForEach(salesRecords) { record in
//                switch chartType {
//                case .bar:
//                    barMark(record)
//                case .line:
//                    lineMark(record)
//                case .pie:
//                    sectorMark(record)
//                }
//            }
//        }
//        .chartYScale(domain: 0...maxSalesValue + 1000) // Use dynamic maximum here
//        .onAppear {
//            self.animateChart()
//        }
//    }
//
//    private var maxSalesValue: Double {
//        salesRecords.map { Double($0.sales) }.max() ?? 0
//    }
//
//    private func barMark(_ record: SalesRecord) -> some ChartContent {
//        BarMark(
//            x: .value("Month", record.month),
//            y: .value("Sales", Double(record.sales))
//        )
//        .foregroundStyle(by: .value("Month", record.month))
//        .opacity(record.isAnimated ? 1 : 0)
//    }
//
//    private func lineMark(_ record: SalesRecord) -> some ChartContent {
//        LineMark(
//            x: .value("Month", record.month),
//            y: .value("Sales", Double(record.sales))
//        )
//        .interpolationMethod(.catmullRom)
//        .opacity(record.isAnimated ? 1 : 0)
//    }
//
//    private func sectorMark(_ record: SalesRecord) -> some ChartContent {
//        SectorMark(
//            angle: .value("Sales", Double(record.sales)),
//            innerRadius: .fixed(61),
//            angularInset: 1
//        )
//        .foregroundStyle(by: .value("Month", record.month))
//        .opacity(record.isAnimated ? 1 : 0)
//    }
//
//    private func loadData() {
//        DispatchQueue.global(qos: .userInteractive).async {
//            let records = readCSV(from: "time_series").map { (date, sales) in
//                SalesRecord(date: date, sales: sales)
//            }
//            DispatchQueue.main.async {
//                self.salesRecords = records
//                self.animateChart()
//            }
//        }
//    }
//
//    private func animateChart() {
//        for i in salesRecords.indices {
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.015) {
//                withAnimation(.easeInOut(duration: 0.5)) {
//                    self.salesRecords[i].isAnimated = true
//                }
//            }
//        }
//    }
//
//    enum ChartType: String, CaseIterable {
//        case bar = "Bar"
//        case line = "Line"
//        case pie = "Pie"
//    }
//}
//
//#Preview {
//    ChartsView()
//}
//
