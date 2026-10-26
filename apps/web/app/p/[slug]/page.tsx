type PublicActivityPageProps = {
  params: Promise<{ slug: string }>;
};

export default async function PublicActivityPage({
  params,
}: PublicActivityPageProps) {
  const { slug } = await params;

  return (
    <main style={{ padding: 32 }}>
      <h1>公开活动页</h1>
      <p>当前 slug：{slug}</p>
      <p>这里后续会渲染发布版本的活动页面结构。</p>
    </main>
  );
}

