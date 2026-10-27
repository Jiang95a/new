"""校园轻活动 AI DIY 工坊 —— 智能体服务。

分层（不要随便跨层调用）：
    routers/     HTTP 接口，只做参数校验和错误翻译
    services/    业务逻辑：模型、工具、记忆、智能体图
    core/        全局配置与提示词
    schemas/     请求/响应模型
    db/          SQLite 连接与建表
"""

__version__ = "0.1.0"
