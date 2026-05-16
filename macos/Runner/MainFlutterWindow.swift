import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let trafficLightVerticalOffset: CGFloat = 18.0

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    LocalNotifierOverride.register(with: flutterViewController.registrar(forPlugin: "LocalNotifierOverride"))

    super.awakeFromNib()
  }

  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    repositionTrafficLights()
  }

  override func makeKeyAndOrderFront(_ sender: Any?) {
    super.makeKeyAndOrderFront(sender)
    repositionTrafficLights()
  }

  private func repositionTrafficLights() {
    guard let closeButton = standardWindowButton(.closeButton),
          let miniaturizeButton = standardWindowButton(.miniaturizeButton),
          let zoomButton = standardWindowButton(.zoomButton) else { return }

    for button in [closeButton, miniaturizeButton, zoomButton] {
      var frame = button.frame
      frame.origin.y = button.superview!.frame.height - frame.height - trafficLightVerticalOffset
      button.setFrameOrigin(frame.origin)
    }
  }
}
