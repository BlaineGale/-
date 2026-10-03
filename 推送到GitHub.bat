@echo off
chcp 65001 > nul
setlocal

REM ============================================================
REM  纹脉（wenmai）一键推送到个人 GitHub
REM  目标仓库：git@github.com:BlaineGale/wenmai-patterns.git
REM  推送分支：main + wenmai-v3
REM  注意：源仓库必须是完整历史克隆，不能用 --depth 1
REM ============================================================

set REPO=git@github.com:BlaineGale/wenmai-patterns.git
set SRC=%TEMP%\wenmai_full

echo ==========================================
echo    纹脉 wenmai 推送工具
echo ==========================================
echo.

REM --- 检查源仓库 ---
if not exist "%SRC%\.git" (
    echo [错误] 找不到源仓库：%SRC%
    echo.
    echo 请修改本脚本中的 SRC 路径指向你的本地仓库。
    echo 注意：必须是完整历史克隆，不能是 --depth 1 浅克隆，
    echo       否则推送会报 did not receive expected object。
    pause
    exit /b 1
)

cd /d "%SRC%"

REM --- 检查是否为浅克隆 ---
git rev-parse --is-shallow-repository | findstr /C:"true" > nul
if not errorlevel 1 (
    echo [错误] 检测到浅克隆仓库，无法推送。
    echo.
    echo 请改用完整克隆：
    echo     git clone https://github.com/oreno123/wenmai.git wenmai_full
    echo.
    pause
    exit /b 1
)

echo [1/4] 源仓库：%SRC%
for /f %%c in ('git rev-list --count HEAD') do echo       提交数：%%c
echo.

REM --- 检查 SSH ---
echo [2/4] 检查 GitHub SSH 连接...
ssh -T git@github.com 2>&1 | findstr /C:"successfully authenticated" > nul
if errorlevel 1 (
    echo [错误] SSH 未认证，请先运行：ssh -T git@github.com
    pause
    exit /b 1
)
echo       SSH 正常，账号：BlaineGale
echo.

REM --- 确认远端仓库存在 ---
echo [3/4] 确认远端仓库...
git ls-remote --heads %REPO% > nul 2>&1
if errorlevel 1 (
    echo.
    echo ==========================================
    echo    远端仓库不存在，需要先创建
    echo ==========================================
    echo.
    echo 请在浏览器打开：https://github.com/new
    echo.
    echo   填写内容：
    echo     Repository name : wenmai-patterns
    echo     Description     : 中国传统纹样抽卡与创作 Web 应用
    echo     Visibility      : Public
    echo     下面三个初始化选项全部不要勾
    echo.
    echo 建好后回到本窗口按任意键继续推送。
    echo.
    pause
)

REM --- 推送 ---
echo [4/4] 开始推送（约 645MB，需 5-15 分钟）...
echo.
echo       推送 main ...
git push -u %REPO% main
if errorlevel 1 (
    echo [错误] main 推送失败
    pause
    exit /b 1
)

echo       推送 wenmai-v3 ...
git push -u %REPO% wenmai-v3
if errorlevel 1 (
    echo [警告] wenmai-v3 推送失败，不影响 main
)

echo.
echo ==========================================
echo    推送完成
echo ==========================================
echo.
echo 仓库地址：https://github.com/BlaineGale/wenmai-patterns
echo.
pause
