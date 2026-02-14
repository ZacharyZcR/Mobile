import ExpoModulesCore
import UIKit

public class HardwareKeyboardModule: Module {
  static weak var instance: HardwareKeyboardModule?
  private static var swizzled = false

  public func definition() -> ModuleDefinition {
    Name("HardwareKeyboard")

    Events("onKeyCommand")

    OnStartObserving {
      HardwareKeyboardModule.instance = self
      HardwareKeyboardModule.swizzleIfNeeded()
    }

    OnStopObserving {
      HardwareKeyboardModule.instance = nil
    }
  }

  static func swizzleIfNeeded() {
    guard !swizzled else { return }
    swizzled = true

    guard
      let original = class_getInstanceMethod(
        UIViewController.self,
        #selector(getter: UIViewController.keyCommands)
      ),
      let replacement = class_getInstanceMethod(
        UIViewController.self,
        #selector(UIViewController.hk_keyCommands)
      )
    else { return }

    method_exchangeImplementations(original, replacement)
  }

  func emit(_ input: String, shift: Bool) {
    sendEvent("onKeyCommand", [
      "input": input,
      "shift": shift,
    ])
  }
}

extension UIViewController {
  @objc func hk_keyCommands() -> [UIKeyCommand]? {
    var commands = self.hk_keyCommands() ?? []

    let shiftTab = UIKeyCommand(
      input: "\t",
      modifierFlags: .shift,
      action: #selector(hk_handleShiftTab)
    )
    shiftTab.wantsPriorityOverSystemBehavior = true
    commands.append(shiftTab)

    return commands
  }

  @objc func hk_handleShiftTab() {
    HardwareKeyboardModule.instance?.emit("\t", shift: true)
  }
}
