//
//  MotionManager.swift
//  Motion
//
//  Created by Jordan Barconey on 10/17/22.
//

import CoreMotion

class MotionManager {             //CMHeadphoneMotionManager() |  with airpods
    private var motionManager = CMMotionManager()
    var pitch = 0.0
    var roll = 0.0
    var yaw = 0.0
    
    init() {
        motionManager.startDeviceMotionUpdates(to: OperationQueue()) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            self.pitch = motion.attitude.pitch
            self.roll = motion.attitude.roll
            self.yaw = motion.attitude.yaw
            
        }
    }
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
