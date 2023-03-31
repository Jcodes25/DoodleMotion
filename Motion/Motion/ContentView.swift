//
//  ContentView.swift
//  Motion
//
//  Created by Jordan Barconey on 10/6/22.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    @State private var particleSystem = ParticleSystem()
    @State private var motionHandler = MotionManager()
    @State private var engine:  CHHapticEngine?

    
    let options: [(flipX: Bool, flipY: Bool)] = [
        (false,false),
        (true, false),
        (false, true),
        (true, true)
    ]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                particleSystem.update(date: timelineDate)
                
                context.blendMode = .plusLighter
                
                particleSystem.center = UnitPoint(x: 0.5 + motionHandler.roll, y: 0.5 + motionHandler.pitch)
                
                for particle in particleSystem.particles {
                    var contextCopy = context
                    contextCopy.addFilter(.colorMultiply(Color(hue: particle.hue, saturation: 1, brightness: 1)))
                    contextCopy.opacity = 1 - (timelineDate - particle.creationDate)
                    
                    for option in options {
                        
                        var xPos = particle.x * size.width
                        var yPos = particle.y * size.height
                        
                        if option.flipX {
                            xPos = size.width - xPos
                        }
                        if option.flipY {
                            yPos = size.height - yPos
                        }
                        
                        contextCopy.draw(particleSystem.image, at: CGPoint(x: xPos, y: yPos))
                    }
                }
            }
        }
            .gesture(
                DragGesture(minimumDistance: 0)
                    
                    .onChanged { drag in
                        prepareHaptics()
                        complexSuccess()
                        
                        particleSystem.center.x = drag.location.x / UIScreen.main.bounds.width
                        particleSystem.center.y = drag.location.y / UIScreen.main.bounds.height
                            
                    }
            )
            .ignoresSafeArea()
            .background(.black)
        }
        func prepareHaptics() {
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            
            do {
                engine = try CHHapticEngine()
                try engine?.start()
            } catch{
                print("There was an error creating the engine: \(error.localizedDescription)")
            }
            
        }
        func complexSuccess() {
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            
            var events = [CHHapticEvent]()
            
            for i in stride(from: 0, through: 1, by: 0.1) {
                
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0 + i)
                events.append(event)
            }

//
            for i in stride(from: 0, through: 1, by: 0.1) {

                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0 + i)
                events.append(event)
            }
            
            
            
            
            do {
                let pattern = try CHHapticPattern(events: events, parameters:[])
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                print("Failed to play pattern \(error.localizedDescription)")
            }
        }

    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

