//
//  PopUp-GeneralView.swift
//  SaleScope
//
//  Created by Chema Padilla Fdez on 06/05/24.
//

import SwiftUI
import Charts
import Foundation


struct PopUp_GeneralView: View {
    
    @Binding var isPopUp: Bool
        
    var UISW: CGFloat = UIScreen.main.bounds.width
    var UISH: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack{
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)
                .frame(width: UISW * 0.8, height: UISH * 0.8)
            
            //Aca el Chart
            
            Text("Your month with the highest sales was: ")
                .font(.custom("Arial", size: 26))
                .bold()
                .foregroundStyle(.black)
                .frame(width: 450)
                .position(x: UISW * 0.28, y: UISH * 0.34)
            
            Text("August 2017")
                .font(.custom("Arial", size: 40))
                .bold()
                .foregroundColor(Color(UIColor(red: 0.37, green: 0.29, blue: 0.65, alpha: 1.00)))
                .position(x: UISW * 0.237, y: UISH * 0.43)
            
            Text("9615 sales")
                .font(.custom("Arial", size: 40))
                .foregroundColor(.blue)
                .position(x: UISW * 0.237, y: UISH * 0.5)

            
            Image("chart")
                .resizable()
                .scaledToFit()
                .colorMultiply(.orange)
                .frame(width: 200)
                .position(x: UISW * 0.26, y: UISH * 0.7)
            
            Image("PieChart")
                .resizable()
                .scaledToFit()
                .frame(width: 600)
                .position(x: UISW * 0.63, y: UISH * 0.5)
            
            Button{
                withAnimation (.easeInOut(duration: 0.5)){
                    isPopUp = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .foregroundColor(Color(UIColor(red: 0.37, green: 0.29, blue: 0.65, alpha: 1.00)))
            }.position(x: UISW * 0.14, y: UISH * 0.16)
            
        }
    }
    
}


struct PopUp_General_Previews: PreviewProvider {
    static var previews: some View {
        let popup = State(initialValue: false)
        return PopUp_GeneralView(isPopUp: popup.projectedValue)
    }
}
