# Shell 脚本基础与高级技巧

这个专题从主手册迁移 Shell 脚本基础、控制流、函数、参数、错误处理和高级 Bash 技巧。

## 脚本基础

```bash
#!/bin/bash

NAME="World"
NUMBER=42
ARRAY=(1 2 3 4 5)

echo "Hello, $NAME!"
echo "Number: $NUMBER"
echo "First array element: ${ARRAY[0]}"

CURRENT_DIR=$(pwd)
echo "Current directory: $CURRENT_DIR"

RESULT=$((3 + 4 * 2))
echo "Result: $RESULT"
```

## 条件与文件测试

```bash
if [ "$NUMBER" -gt 40 ]; then
    echo "Number is greater than 40"
elif [ "$NUMBER" -eq 40 ]; then
    echo "Number is exactly 40"
else
    echo "Number is less than 40"
fi

if [ -f "file.txt" ]; then
    echo "file.txt exists"
fi

if [ -d "dir" ]; then
    echo "dir exists"
fi
```

常用测试:

- `-f`: 普通文件
- `-d`: 目录
- `-e`: 存在
- `-r`: 可读
- `-w`: 可写
- `-x`: 可执行
- `-s`: 大小大于 0

## 循环与 case

```bash
for i in 1 2 3 4 5; do
    echo "Iteration $i"
done

for file in *.txt; do
    echo "File: $file"
done

for ((i=0; i<5; i++)); do
    echo "Iteration $i"
done

i=0
while [ "$i" -lt 5 ]; do
    echo "Iteration $i"
    i=$((i + 1))
done

case "$NUMBER" in
    42) echo "The answer!" ;;
    40) echo "Exactly 40" ;;
    *) echo "Something else" ;;
esac
```

## 函数与参数

```bash
greet() {
    local name="$1"
    echo "Hello, $name!"
}

add() {
    local a=$1
    local b=$2
    echo $((a + b))
}

greet "World"
result=$(add 3 4)
echo "Result: $result"

echo "Script name: $0"
echo "First argument: $1"
echo "All arguments: $@"
echo "Number of arguments: $#"
```

## 脚本选项与错误处理

```bash
set -e
set -u
set -x

if ! command_that_may_fail; then
    echo "Command failed"
    exit 1
fi

trap 'echo "Script interrupted"; exit 1' INT
```

## 高级 Bash 技巧

```bash
# 快速备份和还原
cp file.txt{,.bak}
cp file.txt{.bak,}

# 花括号展开
touch file{1..5}.txt
mkdir -p project/{src,docs,tests,bin}

# 字符串操作
str="Hello World"
echo ${str:0:5}
echo ${str/World/Universe}
echo ${#str}

# 数组
array=(apple banana cherry)
echo ${array[0]}
echo ${array[@]}
echo ${#array[@]}

# 关联数组
declare -A assoc
assoc["name"]="John"
echo ${assoc["name"]}

# 进程替换
diff <(sort file1.txt) <(sort file2.txt)

# 并行执行
task1 &
task2 &
wait

# xargs 并行
find . -name "*.txt" | xargs -P 4 -I {} process {}
```
