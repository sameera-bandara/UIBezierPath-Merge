# UIBezierPath-Merge

This extension is useful for scenarios when you have individual UIBezierPath objects which are logically connected (i.e. end point of the previous path is equal to the start point of the next path). With this extension you can merge them together as they would behave like they are a single bezier path.

#### Difference to append(_:) method
- Swift already has this method, but the appended paths behave as individual paths. For an example, let's say we have 3 paths which are logically connected and form a closed path. If we append them together and call fill(), the closed path would not get filled. However, if we merge them and call fill(), entire closed shape will be filled as it is a single UIBezierPath. 
Please note that when merging, you have to merge them in-order so that, the end point of the last path is equal to the start point of the current path. If these points are different, then the merge result is equivalent to the result of append(_:)


Example in Swift Playground

```swift
import UIKit
import PlaygroundSupport

let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 400, height: 600)))
let topView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 300))
let bottomView = UIView(frame: CGRect(x: 0, y: 300, width: 400, height: 300))

//construct bezier paths which are logically construct a closed path
let p1 = UIBezierPath()
p1.move(to: CGPoint(x: 200, y: 150))
p1.addLine(to: CGPoint(x: 300, y: 200))

let p2 = UIBezierPath()
p2.move(to: CGPoint(x: 300, y: 200))
p2.addLine(to: CGPoint(x: 200, y: 250))

let p3 = UIBezierPath(arcCenter: CGPoint(x: 200, y: 200), radius: 50, startAngle: .pi/2, endAngle: .pi * 3/2, clockwise: true)

//append the constructed paths together
let appendedPath = UIBezierPath()
appendedPath.append(p1)
appendedPath.append(p2)
appendedPath.append(p3)

//merge the contstructed paths together
let mergedPath = UIBezierPath()
mergedPath.merge(with: p1)
mergedPath.merge(with: p2)
mergedPath.merge(with: p3)

let topShapeLayer = CAShapeLayer()
topShapeLayer.path = appendedPath.cgPath
topShapeLayer.fillColor = UIColor.green.cgColor
topShapeLayer.strokeColor = UIColor.blue.cgColor

let bottomShapeLayer = CAShapeLayer()
bottomShapeLayer.path = mergedPath.cgPath
bottomShapeLayer.fillColor = UIColor.green.cgColor
bottomShapeLayer.strokeColor = UIColor.blue.cgColor

topView.layer.addSublayer(topShapeLayer)
bottomView.layer.addSublayer(bottomShapeLayer)

containerView.addSubview(topView)
containerView.addSubview(bottomView)

PlaygroundPage.current.liveView = containerView


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
```
