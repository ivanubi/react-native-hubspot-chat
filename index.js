import { NativeModules } from 'react-native';

const { HubspotModule } = NativeModules;

if (!HubspotModule) {
  throw new Error(
    '[react-native-hubspot-chat] Native module not found. Make sure the native code is linked correctly and pods are installed.'
  );
}

const HubspotChat = {
  init: () => HubspotModule.initSDK(),
  open: (chatflowTag) => HubspotModule.openChat(chatflowTag),
  identify: (email, name) => HubspotModule.identifyVisitor(email, name),
};

export default HubspotChat;