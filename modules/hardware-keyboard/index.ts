import { requireNativeModule } from "expo-modules-core";
import type { EventSubscription } from "expo-modules-core";

interface KeyCommandEvent {
  input: string;
  shift: boolean;
}

interface HardwareKeyboardModule {
  addListener(
    eventName: "onKeyCommand",
    listener: (event: KeyCommandEvent) => void,
  ): EventSubscription;
}

const HardwareKeyboard =
  requireNativeModule<HardwareKeyboardModule>("HardwareKeyboard");

export function addKeyCommandListener(
  listener: (event: KeyCommandEvent) => void,
): EventSubscription {
  return HardwareKeyboard.addListener("onKeyCommand", listener);
}
