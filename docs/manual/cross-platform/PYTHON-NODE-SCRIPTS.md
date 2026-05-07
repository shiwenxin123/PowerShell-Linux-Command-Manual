# Python 与 Node.js 跨平台脚本

这个专题从主手册迁移 Python 和 Node.js 跨平台脚本示例，用于系统信息收集、文件遍历和跨平台路径处理。

## Python 系统信息收集

```python
#!/usr/bin/env python3
import json
import os
import platform
import subprocess
import sys
from datetime import datetime

def get_system_info():
    return {
        "timestamp": datetime.now().isoformat(),
        "system": {
            "os": platform.system(),
            "os_version": platform.version(),
            "architecture": platform.architecture(),
            "machine": platform.machine(),
            "processor": platform.processor(),
            "hostname": platform.node(),
        },
        "python": {
            "version": sys.version,
            "implementation": platform.python_implementation(),
            "compiler": platform.python_compiler(),
            "executable": sys.executable,
        },
        "environment": dict(os.environ),
    }

def run_command(cmd, shell=True):
    try:
        result = subprocess.run(
            cmd,
            shell=shell,
            capture_output=True,
            text=True,
            timeout=30,
        )
        return {
            "success": result.returncode == 0,
            "returncode": result.returncode,
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip(),
        }
    except Exception as exc:
        return {"success": False, "error": str(exc)}

def main():
    info = get_system_info()
    print(f"OS: {info['system']['os']} {info['system']['os_version']}")
    print(f"Hostname: {info['system']['hostname']}")
    print(f"Architecture: {info['system']['architecture'][0]}")
    print(f"Python: {info['python']['version'].split()[0]}")

    with open("system_info.json", "w", encoding="utf-8") as file:
        json.dump(info, file, indent=2, ensure_ascii=False)

    print("Saved to system_info.json")
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

安全提醒: 环境变量可能包含敏感信息，公开报告前需要脱敏。

## Node.js 文件扫描

```javascript
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

function formatBytes(bytes) {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${Math.round((bytes / Math.pow(k, i)) * 100) / 100} ${sizes[i]}`;
}

function walkDir(dir, callback) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      walkDir(fullPath, callback);
    } else {
      callback(fullPath, stat);
    }
  }
}

console.log('System information:');
console.log(`  OS: ${os.type()} ${os.release()}`);
console.log(`  Arch: ${os.arch()}`);
console.log(`  Hostname: ${os.hostname()}`);
console.log(`  CPU cores: ${os.cpus().length}`);
console.log(`  Memory: ${formatBytes(os.totalmem())}`);

const currentDir = process.cwd();
const largeFiles = [];

walkDir(currentDir, (filePath, stat) => {
  if (stat.size > 1024 * 1024) {
    largeFiles.push({
      path: filePath,
      size: stat.size,
      sizeFormatted: formatBytes(stat.size),
    });
  }
});

largeFiles.sort((a, b) => b.size - a.size);
largeFiles.slice(0, 10).forEach((file, index) => {
  console.log(`${index + 1}. ${file.sizeFormatted} - ${path.relative(currentDir, file.path)}`);
});
```

## 跨平台路径建议

- Python 使用 `pathlib.Path`。
- Node.js 使用 `path.join`。
- PowerShell 使用 `Join-Path`。
- 不要在脚本里硬编码 `/` 或 `\`。

## 常用工具推荐

| 工具 | 描述 | Windows | Linux | macOS |
| --- | --- | --- | --- | --- |
| Git | 版本控制 | Yes | Yes | Yes |
| VS Code | 代码编辑器 | Yes | Yes | Yes |
| Docker | 容器化 | Yes | Yes | Yes |
| Node.js | JavaScript 运行时 | Yes | Yes | Yes |
| Python | 编程语言 | Yes | Yes | Yes |
| curl | HTTP 客户端 | Yes | Yes | Yes |
| jq | JSON 处理 | Yes | Yes | Yes |
| fzf | 模糊查找 | Yes | Yes | Yes |
| ripgrep | 快速搜索 | Yes | Yes | Yes |
| fd | 快速文件查找 | Yes | Yes | Yes |
