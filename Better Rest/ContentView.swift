//
//  ContentView.swift
//  Better Rest
//
//  Created by Sai Nikhil Varada on 5/30/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    static var defaultWakeTime : Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form{
                VStack(alignment: .leading){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Select the date", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading){
                    Text("Enter the desired amount of sleep.")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading){
                    Text("Enter the number of cups of coffee you have consumed today.")
                        .font(.headline)

                    
                    Stepper("\(coffeeAmount == 1 ? "\(coffeeAmount) Cup" : "\(coffeeAmount) Cups" )", value: $coffeeAmount, in: 0...8)
                }
                
                
            }
            .navigationTitle("Better Rest")
            .toolbar{
                Button("Calculate", action: calculateBedTime)
            }
        }
        .alert(alertTitle, isPresented: $showingAlert){
            Button("OK"){}
        }message: {
            Text(alertMessage)
        }
    }
    
    func calculateBedTime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hoursInSeconds = (components.hour ?? 0) * 60 * 60
            let minutesInSeconds = (components.minute ?? 0) * 60
            
            let totalSeconds = Double(hoursInSeconds + minutesInSeconds)
            
            let prediction = try model.prediction(wake: totalSeconds, estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "You ideal bedtime is.."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
