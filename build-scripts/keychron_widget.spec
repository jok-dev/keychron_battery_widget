# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec for building the Windows .exe.
# Invoke from the repo root:  pyinstaller build-scripts/keychron_widget.spec

import os

repo_root = os.path.abspath(os.getcwd())
src_dir = os.path.join(repo_root, 'src')

# Bundle every image asset next to the entry script so the frozen binary
# can resolve them via sys._MEIPASS at runtime.
datas = [
    (os.path.join(src_dir, name), '.')
    for name in os.listdir(src_dir)
    if name.lower().endswith('.png')
]

block_cipher = None

a = Analysis(
    [os.path.join(src_dir, 'keychron_widget.py')],
    pathex=[repo_root],
    binaries=[],
    datas=datas,
    hiddenimports=['hid'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='KeychronBatteryWidget',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=os.path.join(repo_root, 'widget_logo.png'),
)
