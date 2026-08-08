export type RequestUser = {
  id: string;
  email?: string | null;
  displayName: string;
  timezone: string;
  currencyCode: string;
  authMode: 'development' | 'production';
};
