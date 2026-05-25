import Foundation
import UIKit

public final class CursorController {
    public static let shared = CursorController()
    public var isVisible = false
    public var cursorColor: UIColor = .systemBlue

    private var cursorWindow: UIWindow?
    private var cursorView: UIView?
    private let cursorSize: CGFloat = 24.0

    public func showCursor(at point: CGPoint) {
        ensureCursorWindow()
        cursorView?.center = point
        if !isVisible {
            cursorView?.isHidden = false
            isVisible = true
        }
    }

    public func moveCursor(to point: CGPoint) {
        cursorView?.center = point
    }

    public func hideCursor() {
        cursorView?.isHidden = true
        isVisible = false
    }

    public func updateCursorColor(_ color: UIColor) {
        cursorColor = color
        cursorView?.layer.borderColor = color.cgColor
        cursorView?.layer.shadowColor = color.withAlphaComponent(0.5).cgColor
    }

    private func ensureCursorWindow() {
        guard cursorWindow == nil else { return }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 100
        window.isUserInteractionEnabled = false
        window.backgroundColor = .clear

        let size = CGSize(width: cursorSize, height: cursorSize)
        let view = UIView(frame: CGRect(origin: .zero, size: size))
        view.layer.cornerRadius = cursorSize / 2
        view.layer.borderWidth = 2.5
        view.layer.borderColor = cursorColor.cgColor
        view.layer.shadowColor = cursorColor.withAlphaComponent(0.5).cgColor
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = .zero
        view.backgroundColor = cursorColor.withAlphaComponent(0.15)
        view.isHidden = true

        let dot = UIView(frame: CGRect(x: cursorSize/2 - 2, y: cursorSize/2 - 2,
                                      width: 4, height: 4))
        dot.layer.cornerRadius = 2
        dot.backgroundColor = cursorColor
        view.addSubview(dot)

        window.addSubview(view)
        window.frame = scene.screen.bounds
        window.makeKeyAndVisible()
        cursorWindow = window
        cursorView = view
    }
}
