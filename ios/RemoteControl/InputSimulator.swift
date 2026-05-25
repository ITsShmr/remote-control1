import Foundation
import UIKit

final class InputSimulator {
    static let shared = InputSimulator()
    private var activeTouch: NSObject?
    private var activeEvent: UIEvent?
    private var previousLocation: CGPoint = .zero
    private var currentLocation: CGPoint = .zero

    private var touchClass: AnyClass? { NSClassFromString("UITouch") }
    private var eventClass: AnyClass? { NSClassFromString("UIEvent") }

    func handleMouseDown(x: Float, y: Float, button: UInt8) {
        guard button == 0 else { return }
        let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
        guard let window = keyWindow() else { return }
        guard let touch = makeTouch(at: point, in: window, phase: .began) else { return }
        guard let event = makeEvent(touches: [touch]) else { return }
        activeTouch = touch
        activeEvent = event
        currentLocation = point
        previousLocation = point
        UIApplication.shared.sendEvent(event)
    }

    func handleMouseUp() {
        guard let touch = activeTouch, let event = activeEvent else { return }
        touch.setValue(UITouch.Phase.ended.rawValue as NSNumber, forKey: "phase")
        touch.setValue(Date(), forKey: "timestamp")
        UIApplication.shared.sendEvent(event)
        activeTouch = nil
        activeEvent = nil
    }

    func handleMouseMove(x: Float, y: Float) {
        guard let touch = activeTouch, let event = activeEvent else { return }
        let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
        previousLocation = currentLocation
        currentLocation = point
        touch.setValue(NSValue(cgPoint: previousLocation), forKey: "previousLocationInWindow")
        touch.setValue(NSValue(cgPoint: currentLocation), forKey: "locationInWindow")
        touch.setValue(UITouch.Phase.moved.rawValue as NSNumber, forKey: "phase")
        touch.setValue(Date(), forKey: "timestamp")
        UIApplication.shared.sendEvent(event)
    }

    private func makeTouch(at point: CGPoint, in window: UIWindow, phase: UITouch.Phase) -> NSObject? {
        guard let cls = touchClass else { return nil }
        let touch = cls.alloc() as! NSObject
        touch.setValue(window, forKey: "window")
        touch.setValue(NSNumber(value: 0), forKey: "tapCount")
        touch.setValue(NSValue(cgPoint: point), forKey: "locationInWindow")
        touch.setValue(NSValue(cgPoint: point), forKey: "previousLocationInWindow")
        touch.setValue(Date(), forKey: "timestamp")
        touch.setValue(phase.rawValue as NSNumber, forKey: "phase")
        return touch
    }

    private func makeEvent(touches: Set<NSObject>) -> UIEvent? {
        guard let cls = eventClass else { return nil }
        let event = cls.alloc() as! UIEvent
        event.setValue(touches, forKey: "allTouches")
        event.setValue(Date(), forKey: "timestamp")
        return event
    }

    private func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    }
}
