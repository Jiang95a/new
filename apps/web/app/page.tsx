import Link from "next/link";

export default function HomePage() {
  return (
    <main style={{ padding: 48, maxWidth: 720, margin: "0 auto" }}>
      <h1>校园轻活动 AI DIY 工坊</h1>
      <p>第一步：前端工程骨架已经建立，接下来会在这里接入工作台、编辑器和公开活动页。</p>
      <ul>
        <li>
          <Link href="/projects">进入项目工作台（占位）</Link>
        </li>
        <li>
          <Link href="/p/demo">查看公开活动页（占位）</Link>
        </li>
      </ul>
    </main>
  );
}

