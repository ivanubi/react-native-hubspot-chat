import { NativeModules, Platform } from 'react-native';

const { HubspotModule } = NativeModules;

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
};