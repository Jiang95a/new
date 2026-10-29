export type Theme = {
  primaryColor: string;
  backgroundColor: string;
  textColor: string;
  radius: number;
  fontScale: number;
};

export type PageComponent = {
  id: string;
  type: string;
  props: Record<string, unknown>;
};

export type Page = {
  id: string;
  title: string;
  path: string;
  components: PageComponent[];
};

export type PageDocument = {
  schemaVersion: "1.0";
  title: string;
  homePageId: string;
  theme: Theme;
  pages: Page[];
};

