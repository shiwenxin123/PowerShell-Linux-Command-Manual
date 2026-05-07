# Bash 文本处理速查

Linux 排障和日志分析经常依赖文本处理。`grep`、`awk`、`sed` 是最常见的三类工具。

## grep 搜索

```bash
# 搜索关键字
grep "error" app.log

# 忽略大小写
grep -i "error" app.log

# 显示行号
grep -n "error" app.log

# 递归搜索
grep -R "error" /var/log

# 使用扩展正则
grep -E "error|failed|timeout" app.log
```

## awk 列处理

```bash
# 打印第一列
awk '{print $1}' access.log

# 按状态码统计
awk '{print $9}' access.log | sort | uniq -c | sort -nr

# 筛选大于 1000 的值
awk '$10 > 1000 {print $0}' access.log
```

## sed 替换

```bash
# 预览替换结果
sed 's/old/new/g' file.txt

# 原地替换
sed -i 's/old/new/g' file.txt

# 删除空行
sed '/^$/d' file.txt
```

## 常见组合

```bash
# 查看错误最多的 IP
grep "500" access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head

# 查看最近 100 行中的错误
tail -n 100 app.log | grep -i "error"

# 从日志中提取时间和错误信息
grep -i "error" app.log | awk '{print $1, $2, $0}'
```

## 使用建议

- 生产日志很大时，优先用 `tail`、`head`、时间范围或更精确的关键词缩小范围。
- 批量替换前先不加 `-i` 预览结果。
- 命令较复杂时保存为脚本，方便复用和审查。
