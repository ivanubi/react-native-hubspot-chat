declare module 'react-native-hubspot-chat' {
  const HubspotChat: {
    init: () => Promise<void>;
    open: (tag: string) => Promise<void>;
    identify: (email: string, name: string) => Promise<void>;
  };
  export default HubspotChat;
}