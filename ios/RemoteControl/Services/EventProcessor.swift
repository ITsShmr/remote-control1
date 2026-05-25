import Foundation
import UIKit

public final class EventProcessor {
    public static let shared = EventProcessor()
    public var screenSize: CGSize {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.screen.bounds.size ?? .zero
    }

    private var cursorPosition = CGPoint.zero

    public func processMouseMove(x: Float, y: Float) -> CGPoint {
        let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
        cursorPosition = point
        return point
    }

    public func processMouseDown(x: Float, y: Float, button: UInt8) {
        let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
        Task { @MainActor in
            if button == 0 {
                TouchSimulator.shared.performTap(at: point)
            }
        }
    }

    public func processMouseDrag(from: CGPoint, to: CGPoint) {
        Task { @MainActor in
            TouchSimulator.shared.performDrag(from: from, to: to)
        }
    }

    public func processScroll(deltaX: Float, deltaY: Float) {
        let scale: CGFloat = 20.0
        let offset = CGPoint(x: CGFloat(deltaX) * scale,
                            y: CGFloat(deltaY) * scale)
        let newPos = CGPoint(x: cursorPosition.x + offset.x,
                            y: cursorPosition.y + offset.y)
        cursorPosition = CGPoint(x: max(0, min(screenSize.width, newPos.x)),
                                y: max(0, min(screenSize.height, newPos.y)))
        Task { @MainActor in
            TouchSimulator.shared.performDrag(from: cursorPosition,
                                             to: cursorPosition)
        }
    }

    public func processKeyboard(keyCode: UInt16, keyDown: Bool) {
        Task { @MainActor in
            let selector = keyDown
                ? NSSelectorFromString("_keyDown:")
                : NSSelectorFromString("_keyUp:")
            UIApplication.shared.perform(selector,
                                        with: NSNumber(value: keyCode))
        }
    }
}
