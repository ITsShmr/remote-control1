import Foundation
import UIKit

public final class TouchSimulator {
    public static let shared = TouchSimulator()
    public var isEnabled = true

    private var activeTouch: UITouch?
    private var activeEvent: UIEvent?
    private let touchClass: AnyClass? = NSClassFromString("UITouch")
    private let eventClass: AnyClass? = NSClassFromString("UIEvent")

    public func performTap(at point: CGPoint) {
        guard isEnabled else { return }
        let window = keyWindow() ?? UIApplication.shared.windows.first
        guard let window = window else { return }

        guard let touch = createTouch(at: point, in: window) else { return }
        guard let event = createTouchEvent(touches: [touch],
                                           window: window) else { return }

        sendTouchPhase(.began, touch: touch, event: event, window: window)
        usleep(50000)
        sendTouchPhase(.ended, touch: touch, event: event, window: window)
    }

    public func performDrag(from: CGPoint, to: CGPoint, duration: TimeInterval = 0.3) {
        guard isEnabled else { return }
        let window = keyWindow() ?? UIApplication.shared.windows.first
        guard let window = window else { return }

        guard let touch = createTouch(at: from, in: window) else { return }
        guard let event = createTouchEvent(touches: [touch],
                                           window: window) else { return }

        sendTouchPhase(.began, touch: touch, event: event, window: window)

        let steps = 10
        let stepInterval = duration / Double(steps)
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let current = CGPoint(x: from.x + (to.x - from.x) * t,
                                 y: from.y + (to.y - from.y) * t)
            updateTouchLocation(touch, point: current, in: window)
            sendTouchPhase(.moved, touch: touch, event: event, window: window)
            usleep(useconds_t(stepInterval * 1_000_000))
        }

        sendTouchPhase(.ended, touch: touch, event: event, window: window)
    }

    public func performTouchDown(at point: CGPoint) {
        guard isEnabled else { return }
        let window = keyWindow() ?? UIApplication.shared.windows.first
        guard let window = window else { return }
        guard let touch = createTouch(at: point, in: window) else { return }
        guard let event = createTouchEvent(touches: [touch],
                                           window: window) else { return }
        activeTouch = touch
        activeEvent = event
        sendTouchPhase(.began, touch: touch, event: event, window: window)
    }

    public func performTouchMove(to point: CGPoint) {
        guard isEnabled, let touch = activeTouch else { return }
        let window = keyWindow() ?? UIApplication.shared.windows.first
        guard let window = window else { return }
        updateTouchLocation(touch, point: point, in: window)
        sendTouchPhase(.moved, touch: touch,
                      event: activeEvent ?? createDummyEvent(),
                      window: window)
    }

    public func performTouchUp(at point: CGPoint? = nil) {
        guard isEnabled, let touch = activeTouch else { return }
        let window = keyWindow() ?? UIApplication.shared.windows.first
        if let point = point {
            updateTouchLocation(touch, point: point, in: window)
        }
        sendTouchPhase(.ended, touch: touch,
                      event: activeEvent ?? createDummyEvent(),
                      window: window)
        activeTouch = nil
        activeEvent = nil
    }

    private func createTouch(at point: CGPoint, in window: UIWindow) -> UITouch? {
        guard let cls = touchClass else { return nil }
        let touch = cls.alloc()
        touch.setValue(window, forKey: "window")
        touch.setValue(NSNumber(value: 0), forKey: "tapCount")
        touch.setValue(NSValue(cgPoint: point), forKey: "locationInWindow")
        touch.setValue(NSValue(cgPoint: point), forKey: "previousLocationInWindow")
        touch.setValue(Date(), forKey: "timestamp")
        touch.setValue(UITouch.Phase.began.rawValue as NSNumber,
                      forKey: "phase")
        return touch as? UITouch
    }

    private func updateTouchLocation(_ touch: UITouch,
                                     point: CGPoint,
                                     in window: UIWindow) {
        touch.setValue(NSValue(cgPoint: touch.location(in: window)),
                      forKey: "previousLocationInWindow")
        touch.setValue(NSValue(cgPoint: point), forKey: "locationInWindow")
        touch.setValue(Date(), forKey: "timestamp")
    }

    private func createTouchEvent(touches: Set<UITouch>,
                                  window: UIWindow) -> UIEvent? {
        guard let cls = eventClass else { return nil }
        let event = cls.alloc()
        event.setValue(touches, forKey: "allTouches")
        event.setValue(Date(), forKey: "timestamp")
        event.setValue(window, forKey: "window")
        return event as? UIEvent
    }

    private func createDummyEvent() -> UIEvent {
        let cls = eventClass ?? UIEvent.self
        let event = cls.alloc()
        event.setValue(Set<UITouch>(), forKey: "allTouches")
        event.setValue(Date(), forKey: "timestamp")
        return event as! UIEvent
    }

    private func sendTouchPhase(_ phase: UITouch.Phase,
                                touch: UITouch,
                                event: UIEvent,
                                window: UIWindow) {
        touch.setValue(phase.rawValue as NSNumber, forKey: "phase")
        touch.setValue(Date(), forKey: "timestamp")
        UIApplication.shared.sendEvent(event)
    }

    private func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    }
}
