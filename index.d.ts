declare module 'react-native-hubspot-chat' {
  type ChatProperty = { name: string; value: string };
  type PushMessage = {
    portalId?: string;
    chatflowId?: string;
    threadId?: string;
    chatflow?: string;
  };
  const HubspotChat: {
    init(): Promise<void>;
    open(tag: string): Promise<void>;
    identify(identityToken: string, email?: string): Promise<void>;
    setProperties(props: ChatProperty[] | Record<string, string>): Promise<void>;
    endSession(): Promise<void>;
    // Push notifications
    configurePushMessaging(options?: { prompt?: boolean; allowProvisional?: boolean }): Promise<void>;
    setPushToken(token: string): Promise<void>;
    addNewMessageListener(handler: (data: PushMessage) => void): { remove: () => void };
  };
  export default HubspotChat;
}