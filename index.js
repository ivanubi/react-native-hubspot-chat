import { NativeModules, Platform, NativeEventEmitter } from 'react-native';

const { HubspotModule } = NativeModules;
const hubspotEmitter = new NativeEventEmitter(HubspotModule);

function setProperties(props) {
  if (Platform.OS === 'ios') {
    if (!Array.isArray(props)) {
      throw new Error('iOS requires an array of {name, value} objects');
    }
    return HubspotModule.setChatProperties(props);
  } else {
    if (Array.isArray(props)) {
      const map = {};
      props.forEach(({ name, value }) => {
        map[name] = value;
      });
      return HubspotModule.setChatProperties(map);
    }
    return HubspotModule.setChatProperties(props);
  }
}

export default {
  init: () => HubspotModule.initSDK(),
  open: (tag) => HubspotModule.openChat(tag),
  identify: (identityToken, email) => HubspotModule.identifyVisitor(identityToken, email),
  setProperties,
  endSession: () => HubspotModule.endSession(),
  // Push notifications
  configurePushMessaging: ({ prompt = false, allowProvisional = true } = {}) =>
    Platform.OS === 'ios'
      ? HubspotModule.configurePushMessaging(Boolean(prompt), Boolean(allowProvisional))
      : Promise.resolve(),
  setPushToken: (token) => HubspotModule.setPushToken(token),
  addNewMessageListener: (handler) => hubspotEmitter.addListener('HubspotNewMessage', handler),
};