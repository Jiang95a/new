import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "校园轻活动 AI DIY 工坊",
  description: "面向校园社团的活动页面生成与发布工具",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  );
}

