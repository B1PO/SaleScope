import SwiftUI
import Charts

struct AverageWFiltersView: View {
    @State var isForecast: Bool = false
    @State var isDecember: Bool = false
    
    @State var isPopup: Bool = false
    
    @State private var salesRecords: [SalesRecord] = []
    @State private var selectedYear: String = ""
    @State private var showAllYears: Bool = true
    @State private var showAverageLine: Bool = false
    @State private var stackYears: Bool = false  // Nuevo estado para controlar el agrupamiento
    @State private var showStandardDeviationLine: Bool = false
    @State private var selectedButton: String = "year"  // 'year' está seleccionado por defecto
    @State private var selectedGridButton: String? = "grid1" // Almacena el botón de grid seleccionado

    var salesData: [SalesData]
    var totalSales: Int
    var totalRecords: Int
    init() {
        let rawData = readCSV(from: "time_series")  // Asumiendo que esta función está definida para leer datos
        self.salesData = rawData.map { SalesData(date: $0.date, sales: $0.sales) }
        self.totalSales = salesData.reduce(0) { $0 + $1.sales }
        self.totalRecords = salesData.count
    }
    
    var UISW: CGFloat = UIScreen.main.bounds.width
    var UISH: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack{
            VStack {
                // Header similar al de OverView
                ZStack {
                    HStack {
                        ZStack {
                            Image("sha")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150, alignment: .trailing)
                                .offset(x: -20, y: 0)
                            Button(action: {
                                // Acción para el botón back
                            }) {
                                Image("back")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                        }
                        }
                        Spacer()
                        Image("overviewcenter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, alignment: .center)
                            .ignoresSafeArea()
                            .offset(x: -80)
                        Spacer()
                    }
                    .padding()
                    .background(Color(red: 119 / 255, green: 95 / 255, blue: 209 / 255)) // Color de fondo del header

                    Image("textder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, alignment: .trailing)
                        .ignoresSafeArea()
                        .offset(x: 500, y: 5)
                }
                .padding(.bottom, 0)

                ScrollView {
                    // Botones de OverView incorporados en AverageWFiltersView
                    VStack {
                        HStack {
                            Section {
                                if selectedYear != "" && selectedYear != "All Years" {
                                    Text("Total Sales for \(selectedYear): \(totalSalesForSelectedYear())")
                                        .bold()
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding()
                                    Spacer()
                                    
                                }else{
                                    Spacer()
                                }
                            }
                            HStack {
                                Spacer()
                                // Botones centrales
                                Button("Total Records: \(totalRecords)") {
                                    // Acción para el botón central 1
                                }
                                .buttonStyle(.automatic)
                                .foregroundColor(.white)
                                .bold()
                                .padding(20)
                                .background(Color(red: 119 / 255, green: 95 / 255, blue: 209 / 255))
                                .cornerRadius(10)
                                
                                Button("Total Sales: \(totalSales)") {
                                    // Acción para el botón central 2
                                }
                                .buttonStyle(.automatic)
                                .foregroundColor(.white)
                                .bold()
                                .padding(20)
                                .background(Color(red: 119 / 255, green: 95 / 255, blue: 209 / 255))
                                .cornerRadius(10)
                                Spacer()
                            }
                            Text(" General Standard Deviation: \(calculateStandardDeviation(records: salesRecords), specifier: "%.2f")")
                                .bold()
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding()
                        }
                        .padding(.bottom, 20)
                        .padding(.bottom, -40)
                        HStack {
                            Group {
                                Button(action: {
                                    self.selectedButton = "year"
                                }) {
                                    Image(selectedButton == "year" ? "yearon" : "yearoff")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                }
                                Button(action: {
                                    self.selectedButton = "month"
                                }) {
                                    Image(selectedButton == "month" ? "monthon" : "monthoff")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 90, height: 90)
                                }
                                
                            }
                            
                            Spacer()
                            
                            Group {
                                
                                Button(action: {
                                    selectedGridButton = selectedGridButton == "grid1" ? nil : "grid1"
                                    stackYears = false
                                    selectedYear = "" // Ajustar a "All Years"
                                }) {
                                    Image(selectedGridButton == "grid1" ? "grid1on" : "grid1off")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                }

                                // Botón grid2: Activa stackYears, desactiva las líneas y establece el año a "All Years"
//                                Button(action: {
//                                    selectedGridButton = selectedGridButton == "grid2" ? nil : "grid2"
//                                    stackYears = selectedGridButton == "grid2"
//                                    if stackYears {
//                                        showStandardDeviationLine = false
//                                        showAverageLine = false
//                                    }
//                                    selectedYear = "" // Ajustar a "All Years"
//                                }) {
//                                    Image(selectedGridButton == "grid2" ? "grid2on" : "grid2off")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 60, height: 60)
//                                }

                                // Botón grid3: Solo interactivo si grid2 no está activo y basa su estado en las líneas de promedio y desviación estándar
                                Button(action: {
                                    guard selectedGridButton != "grid2" else { return }  // Deshabilita la interacción si grid2 está activo
                                    showStandardDeviationLine.toggle()
                                    showAverageLine.toggle()
                                }) {
                                    Image((showStandardDeviationLine && showAverageLine && selectedGridButton != "grid2") ? "grid3on" : "grid3off")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                }
                                .disabled(selectedGridButton == "grid2")  // Deshabilita el botón si grid2 está activo

                            }


                        }
                        
                        

                    }

                    Section("") {
                        Picker("Select Year", selection: $selectedYear) {
                            Text("All Years").tag("").disabled(selectedButton == "month" && monthOffIsActive())
                            ForEach(uniqueYears, id: \.self) { year in
                                Text(year).tag(year)
                            }
                        }
                        .pickerStyle(.segmented)

                        
                    }
                    
                    Section("") {
                        if selectedButton == "year" {
                            if !allRecords.isEmpty {
                                barChartView(records: calculateMonthlyAverages(records: allRecords), showAverageLine: showAverageLine)
                                    .frame(height: 350)
                            } else {
                                Text("No data available for selected year.")
                            }
                        } else if selectedButton == "month" {
                            let recordsToDisplay = selectedYear.isEmpty ? monthRecordsForAllYears() : monthRecords
                            if !monthRecordsForAllYears().isEmpty {
                                monthChartView(records: monthRecordsForAllYears())
                                    .frame(height: 350)
                            } else {
                                Text("Month off is active or no data available for June and July.")
                            }
                        }
                    }

                                        
                }
                .padding(.horizontal,40)
                .onAppear(perform: loadData)
            }
            .offset(y:-30)
            
            Button {
                withAnimation (.easeInOut(duration: 0.5)){
                    isPopup = true
                    isForecast = false
                    isDecember = false
                }
            } label: {
                Text("Top Sales")
                    .font(.custom("Arial", size: 20)).bold()
                    .foregroundStyle(Color(UIColor(red: 0.37, green: 0.29, blue: 0.65, alpha: 1.00)))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
            }.background(.white)
                .cornerRadius(10)
            .position(x: UISW * 0.5, y: UISH * 0.14)
            
            Button {
                llamarEndpoint(method: "POST", endpoint: "generar_csv")
                
            } label: {
                Text("Generate CSV")
                    .font(.custom("Arial", size: 20)).bold()
                    .foregroundStyle(Color(UIColor(red: 0.37, green: 0.29, blue: 0.65, alpha: 1.00)))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
            }.background(.white)
                .cornerRadius(10)
            .position(x: UISW * 0.65, y: UISH * 0.14)
            
            Button {
                withAnimation (.easeInOut(duration: 0.5)){
                    isForecast = true
                    isDecember = false
                }
            } label: {
                Text("Summer")
                    .font(.custom("Arial", size: 20)).bold()
                    .foregroundStyle(Color(UIColor(red: 0.37, green: 0.29, blue: 0.65, alpha: 1.00)))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
            }.background(.white)
                .cornerRadius(10)
            .position(x: UISW * 0.795, y: UISH * 0.14)
            
            Button {
                withAnimation (.easeInOut(duration: 0.5)){
                    isDecember = true
                    isForecast = false
                }
            } label: {
                Text("December")
                    .font(.custom("Arial", size: 20)).bold()
                    .foregroundStyle(Color(UIColor(red: 0.37, green: 0.29, blue: 0.65, alpha: 1.00)))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
            }.background(.white)
                .cornerRadius(10)
            .position(x: UISW * 0.92, y: UISH * 0.14)
            
            Rectangle()
                .edgesIgnoringSafeArea(.all)
                .foregroundColor(.black.opacity(isPopup ? 0.8 : 0))
                
            if isPopup {
                PopUp_GeneralView(isPopUp: $isPopup)
                    .offset(y: isPopup ? 0 : UISH * 2)
            }
            
        }
        
        if isForecast {
            ForecastView(isForecast: $isForecast)
                .offset(y: isForecast ? -UISH * 0.5 : UISH * 2)
        }
        if isDecember {
            DecemberView(isDecember: $isDecember)
                .offset(y: isDecember ? -UISH * 0.5 : UISH * 2)
        }
    }

    private var uniqueYears: [String] {
        Set(salesRecords.map { $0.year }).sorted()
    }
    
    private var allRecords: [SalesRecord] {
        selectedYear.isEmpty ? salesRecords : salesRecords.filter { $0.year == selectedYear }
    }
    
    private var filteredRecords: [SalesRecord] {
        salesRecords.filter { $0.year == selectedYear }
    }
    
    func llamarEndpoint(method: String, endpoint: String) {
            guard let url = URL(string: "http://10.31.140.204:5008/\(endpoint)") else {
                print("URL inválida")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print("Error: \(error!)")
                    return
                }
                
                if let data = data {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Respuesta del servidor: \(jsonString)")
                    }
                }
            }.resume()
        }

    private func calculateMonthlyAverages(records: [SalesRecord]) -> [SalesRecord] {
        let years = Set(records.map { $0.year })
        var results: [SalesRecord] = []
        
        for year in years {
            let filteredByYear = records.filter { $0.year == year }
            let groupedByMonth = Dictionary(grouping: filteredByYear, by: { $0.month })
            let allMonths = Set(1...12).map { String(format: "%02d", $0) }
            
            for month in allMonths {
                let recordsInMonth = groupedByMonth[month] ?? []
                let totalSales = recordsInMonth.reduce(0) { $0 + $1.sales }
                let averageSales = recordsInMonth.isEmpty ? 0 : totalSales / recordsInMonth.count
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: "\(year)-\(month)-01") {
                    results.append(SalesRecord(date: date, sales: averageSales, month: month, year: year))
                }
            }
        }
        
        return results.sorted(by: { $0.date < $1.date })
    }
    private func calculateStandardDeviation(records: [SalesRecord]) -> Double {
            let filteredRecords = records.filter { $0.sales > 0 }
            guard !filteredRecords.isEmpty else { return 0.0 }

            let mean = filteredRecords.reduce(0.0) { $0 + Double($1.sales) } / Double(filteredRecords.count)
            let sumOfSquaredDiffs = filteredRecords.reduce(0.0) { $0 + (Double($1.sales) - mean) * (Double($1.sales) - mean) }

            return sqrt(sumOfSquaredDiffs / Double(filteredRecords.count - 1))
        }

    private func barChartView(records: [SalesRecord], showAverageLine: Bool) -> some View {
        let overallAverage = records.map { Double($0.sales) }.reduce(0, +) / Double(records.count)
        let standardDeviation = calculateStandardDeviation(records: records)

        return Chart {
            ForEach(records, id: \.id) { record in
                BarMark(
                    x: .value("Month", stackYears ? record.month : "\(record.month)-\(record.year)"),
                    y: .value("Sales", Double(record.sales))
                )
                .foregroundStyle(record.year == uniqueYears.first ? Color(red: 119 / 255, green: 95 / 255, blue: 209 / 255) : Color.green)
                .annotation(position: .top) {
                    Text("\(record.sales)")
                        .bold()
                        .foregroundColor(record.year == uniqueYears.first ? Color(red: 119 / 255, green: 95 / 255, blue: 209 / 255) : Color.green)
                }
                .clipShape(RoundedRectangle(cornerRadius: 15)) // Intento de redondear esquinas
            }
            if showAverageLine {
                RuleMark(
                    y: .value("Average Sales", overallAverage)
                )
                .opacity(0.7)
                .foregroundStyle(.gray)
                .annotation(position: .top, alignment: .trailing) {
                    Text("Avg: \(Int(overallAverage))")
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(5)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(Color.white))
                        .overlay(
                            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                                .stroke(Color.gray, lineWidth: 2.5)
                        )
                }
            }

            if showStandardDeviationLine {
                RuleMark(
                    y: .value("Standard Deviation", standardDeviation)
                        
                )
                .opacity(0.5)
                .foregroundStyle(.gray)
                .annotation(position: .top, alignment: .trailing) {
                    Text("Std Dev: \(Int(standardDeviation))")
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(5)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(Color.white))
                        .overlay(
                            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                                .stroke(Color.gray, lineWidth: 2.5))
                    
                }
            }
        }
    }
    
    private func monthOffIsActive() -> Bool {
        // Aquí asumo que hay una manera de determinar si "monthoff" está activo. Ajusta según tu implementación.
        // Podría ser un estado o una verificación de algún valor.
        return !showAllYears
    }




    private var monthRecords: [SalesRecord] {
        guard selectedButton == "month" else { return [] }
        return salesRecords.filter { ($0.month == "06" || $0.month == "07") && $0.year == selectedYear }
    }
    
    private func monthChartView(records: [SalesRecord]) -> some View {
        let filteredRecords = selectedYear == "" ? monthRecordsForAllYears() : monthRecords
        return Chart {
            ForEach(filteredRecords, id: \.id) { record in
                LineMark(
                    x: .value("Date", record.date),
                    y: .value("Sales", Double(record.sales))
                )
                .foregroundStyle(record.year == "2018" ? Color(red: 119 / 255, green: 95 / 255, blue: 209 / 255) : Color.green)
                .symbol(Circle())
            }
        }
    }

    private func monthRecordsForAllYears() -> [SalesRecord] {
           salesRecords.filter { $0.month == "06" || $0.month == "07" }
       }
    
    private func totalSalesForSelectedYear() -> Int {
        guard selectedYear != "", selectedYear != "All Years" else { return 0 }
        return salesRecords.filter { $0.year == selectedYear }.reduce(0) { $0 + $1.sales }
    }


    private func loadData() {
        DispatchQueue.global(qos: .userInteractive).async {
            let records = readCSV(from: "time_series").map { (date, sales) in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                let year = dateFormatter.string(from: date)
                dateFormatter.dateFormat = "MM"
                let month = dateFormatter.string(from: date)
                
                return SalesRecord(date: date, sales: sales, month: month, year: year)
            }
            DispatchQueue.main.async {
                self.salesRecords = records
                self.selectedYear = self.uniqueYears.first ?? ""
            }
        }
    }


}
#Preview {
    AverageWFiltersView()
}
