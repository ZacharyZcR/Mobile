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

  func emit(_ input: String, shift: Bool, ctrl: Bool = false, alt: Bool = false) {
    sendEvent("onKeyCommand", [
      "input": input,
      "shift": shift,
      "ctrl": ctrl,
      "alt": alt,
    ])
  }
}

extension UIViewController {
  @objc func hk_keyCommands() -> [UIKeyCommand]? {
    var commands = self.hk_keyCommands() ?? []

    // Shift+Tab
    let shiftTab = UIKeyCommand(
      input: "\t",
      modifierFlags: .shift,
      action: #selector(hk_handleShiftTab)
    )
    shiftTab.wantsPriorityOverSystemBehavior = true
    commands.append(shiftTab)

    // Arrow keys (no modifier) — registered individually so we can use distinct selectors
    let upCmd = UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(hk_handleArrowUp))
    upCmd.wantsPriorityOverSystemBehavior = true
    commands.append(upCmd)

    let downCmd = UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(hk_handleArrowDown))
    downCmd.wantsPriorityOverSystemBehavior = true
    commands.append(downCmd)

    let leftCmd = UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(hk_handleArrowLeft))
    leftCmd.wantsPriorityOverSystemBehavior = true
    commands.append(leftCmd)

    let rightCmd = UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(hk_handleArrowRight))
    rightCmd.wantsPriorityOverSystemBehavior = true
    commands.append(rightCmd)

    // Escape
    let esc = UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(hk_handleEscape))
    esc.wantsPriorityOverSystemBehavior = true
    commands.append(esc)

    // Ctrl key combinations
    let ctrlInputs = [
      "a","b","c","d","e","f","g","h","k","l","n","p","q","r","s","t","u","v","w","x","y","z",
      "[","]","\\",
    ]
    for input in ctrlInputs {
      let cmd = UIKeyCommand(
        input: input,
        modifierFlags: .control,
        action: #selector(hk_handleCtrlKey(_:))
      )
      cmd.wantsPriorityOverSystemBehavior = true
      commands.append(cmd)
    }

    return commands
  }

  @objc func hk_handleShiftTab() {
    HardwareKeyboardModule.instance?.emit("\t", shift: true)
  }

  @objc func hk_handleArrowUp()    { HardwareKeyboardModule.instance?.emit("ArrowUp",    shift: false) }
  @objc func hk_handleArrowDown()  { HardwareKeyboardModule.instance?.emit("ArrowDown",  shift: false) }
  @objc func hk_handleArrowLeft()  { HardwareKeyboardModule.instance?.emit("ArrowLeft",  shift: false) }
  @objc func hk_handleArrowRight() { HardwareKeyboardModule.instance?.emit("ArrowRight", shift: false) }

  @objc func hk_handleEscape() {
    HardwareKeyboardModule.instance?.emit("Escape", shift: false)
  }

  @objc func hk_handleCtrlKey(_ sender: UIKeyCommand) {
    guard let input = sender.input else { return }
    HardwareKeyboardModule.instance?.emit(input, shift: false, ctrl: true)
  }
}
