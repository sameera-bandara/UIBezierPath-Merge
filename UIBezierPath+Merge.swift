//
//  UIBezierPath+Merge.swift
//
//  Created by Sameera Bandara on 8/19/21.
//  Copyright ©Sameera Bandara. All rights reserved.
//
import UIKit

extension UIBezierPath {
    func merge(with path: UIBezierPath) {
        let currentPath = self.cgPath.mutableCopy()!
        let lastPoint = self.lastPoint()
        let firstPoint = path.firstPoint()
        
        var index = -1
        path.cgPath.applyWithBlock { block in
            index += 1
            let element = block.pointee
            
            switch (element.type) {
            case .moveToPoint:
                if index != 0 && lastPoint != firstPoint || lastPoint == nil {
                    currentPath.move(to: element.points[0])
                }
            case .addLineToPoint:
                currentPath.addLine(to: element.points[0])
            case .addQuadCurveToPoint:
                currentPath.addQuadCurve(to: element.points[1], control: element.points[0])
            case .addCurveToPoint:
                currentPath.addCurve(to: element.points[2], control1: element.points[0], control2: element.points[1])
            case .closeSubpath:
                currentPath.closeSubpath()
            @unknown default:
                fatalError()
            }
        }
        
        self.cgPath = currentPath
    }
    
    func firstPoint() -> CGPoint? {
        var firstPoint: CGPoint? = nil
        
        var index = -1
        self.cgPath.applyWithBlock { block in
            index += 1
            let element = block.pointee
            
            if index == 0 {
                if element.type == .moveToPoint || element.type == .addLineToPoint {
                    firstPoint = element.points[0]
                } else if element.type == .addQuadCurveToPoint {
                    firstPoint = element.points[1]
                } else if element.type == .addCurveToPoint {
                    firstPoint = element.points[2]
                }
            }
        }
        
        return firstPoint
    }
    
    func lastPoint() -> CGPoint? {
        var lastPoint: CGPoint? = nil
        
        var index = -1
        self.reversing().cgPath.applyWithBlock { block in
            index += 1
            let element = block.pointee
            
            if index == 0 {
                if element.type == .moveToPoint || element.type == .addLineToPoint {
                    lastPoint = element.points[0]
                } else if element.type == .addQuadCurveToPoint {
                    lastPoint = element.points[1]
                } else if element.type == .addCurveToPoint {
                    lastPoint = element.points[2]
                }
            }
        }
        
        return lastPoint
    }
}

