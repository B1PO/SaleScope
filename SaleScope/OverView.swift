import SwiftUI

struct OverView: View {
    var salesData: [SalesData]
    var totalSales: Int
    var totalRecords: Int
    
    @State private var selectedButton: String = "year"  // 'year' está seleccionado por defecto
    @State private var selectedGridButton: String? = "grid1" // Almacena el botón de grid seleccionado
    
    init() {
        let rawData = readCSV(from: "time_series")  // Asumiendo que esta función está definida para leer datos
        self.salesData = rawData.map { SalesData(date: $0.date, sales: $0.sales) }
        self.totalSales = salesData.reduce(0) { $0 + $1.sales }
        self.totalRecords = salesData.count
    }
    
    var body: some View {
        VStack {
            // Header
            ZStack {
                HStack {
                    Button(action: {
                        // Acción para el botón back
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image("overviewcenter")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, alignment: .center)
                        .ignoresSafeArea()
                    Spacer()
                }
                .padding()
                .background(Color(red: 119 / 255, green: 95 / 255, blue: 209 / 255)) // Color de fondo del header

                Image("textder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, alignment: .trailing)
                    .ignoresSafeArea()
                    .offset(x: 450, y: 20)
            }
            
            // Scroll View
            ScrollView {
                VStack {
                    HStack {
                        // Grupo de botones izquierda
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
                            Button(action: {
                                self.selectedButton = "day"
                            }) {
                                Image(selectedButton == "day" ? "dayon" : "dayoff")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                            }
                        }
                        
                        Spacer()
                        
                        // Grupo de botones derecha
                        Group {
                            Button(action: {
                                self.selectedGridButton = "grid1"
                            }) {
                                Image(selectedGridButton == "grid1" ? "grid1on" : "grid1off")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                            }
                            Button(action: {
                                self.selectedGridButton = "grid2"
                            }) {
                                Image(selectedGridButton == "grid2" ? "grid2on" : "grid2off")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                            }
                            Button(action: {
                                self.selectedGridButton = "grid3"
                            }) {
                                Image(selectedGridButton == "grid3" ? "grid3on" : "grid3off")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                            }
                        }
                    }
                    .padding()

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
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
        }
        .offset(y: -80)
    }
}

struct OverView_Previews: PreviewProvider {
    static var previews: some View {
        OverView()
    }
}

