"""内置工具：时间、四则运算。

工具写法的规矩：
1. 函数名 = 工具名（模型看到的就是它），所以用英文、动词开头。
2. docstring = 给模型看的说明书，必须写"什么时候该用"。
3. 永远返回字符串，永远不抛异常（异常要变成人能读懂的一句话）。
"""

from __future__ import annotations

import ast
import operator
from datetime import datetime

from langchain_core.tools import tool

_BIN_OPS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.Mod: operator.mod,
    ast.Pow: operator.pow,
}
_UNARY_OPS = {ast.UAdd: operator.pos, ast.USub: operator.neg}
_MAX_ABS = 1e12


def _eval_node(node: ast.AST) -> float:
    """只允许数字、四则运算和括号。绝不使用 eval —— 那等于把服务器交出去。"""
    if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return float(node.value)
    if isinstance(node, ast.BinOp) and type(node.op) in _BIN_OPS:
        left = _eval_node(node.left)
        right = _eval_node(node.right)
        value = _BIN_OPS[type(node.op)](left, right)
        if abs(value) > _MAX_ABS:
            raise ValueError("结果太大")
        return value
    if isinstance(node, ast.UnaryOp) and type(node.op) in _UNARY_OPS:
        return _UNARY_OPS[type(node.op)](_eval_node(node.operand))
    raise ValueError("只支持数字和 + - * / % 与括号")


@tool
def get_current_time() -> str:
    """获取当前本地日期和时间。用户问"现在几点""今天几号""这周还剩几天"时调用。"""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


@tool
def calculate(expression: str) -> str:
    """计算一个算术表达式，例如 (3+5)*2 或 120/4。只支持加减乘除、取余、乘方和括号。"""
    try:
        value = _eval_node(ast.parse(expression, mode="eval").body)
    except Exception as exc:  # noqa: BLE001
        return f"计算失败：{exc}"
    return f"{expression} = {value:g}"
