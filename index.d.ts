declare module 'react-native-hubspot-chat' {
  type ChatProperty = { name: string; value: string };
  const HubspotChat: {
    init(): Promise<void>;
    open(tag: string): Promise<void>;
    identify(identityToken: string, email?: string): Promise<void>;
    setProperties(props: ChatProperty[] | Record<string, string>): Promise<void>;
    endSession(): Promise<void>;
  };
  export default HubspotChat;
}