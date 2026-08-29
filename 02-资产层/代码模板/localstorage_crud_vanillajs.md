# 配方卡：localStorage 单页应用 CRUD 骨架（原生 JS）

- 场景：不需要服务器/构建工具的个人本地工具——单 HTML 文件，数据存 localStorage，支持增、删、改后刷新、导出备份、导入合并
- 依赖：无（纯原生 JS，双击 file:// 打开即用）
- 验证：已在「个人工作台 V1.0」（2026-08-29 交付）全量跑通，约 1100 行生产代码的核心即此骨架
- 来源：`01-项目库/个人工作台/`（练手项目提炼）

## 完整可跑代码

```html
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>localStorage CRUD 骨架</title></head>
<body>
  <input id="newItem" placeholder="输入内容，回车添加">
  <ul id="list"></ul>
  <script>
    var STORE_KEY = 'demoData'; // localStorage 键名，换应用就换它

    // 读：拿不到给默认结构（首次使用不炸）
    function loadData() {
      try {
        var d = JSON.parse(localStorage.getItem(STORE_KEY));
        if (d && Array.isArray(d.items)) return d;
      } catch (e) { /* 坏数据当没有 */ }
      return { items: [] };
    }

    // 存：任何改动后必须走这里，否则刷新即丢
    function saveData(d) {
      localStorage.setItem(STORE_KEY, JSON.stringify(d));
    }

    // 增（三连招：load → push → save）
    function addItem() {
      var text = document.getElementById('newItem').value;
      if (!text) return; // 空判断：读值后第一件事
      var data = loadData();
      data.items.push({ id: Date.now(), content: text }); // id=身份证，删除靠它
      saveData(data);
      render();
      document.getElementById('newItem').value = ''; // 清空输入框
    }

    // 删（filter 是"留下"的条件，与 concat 增互为反向）
    function removeItem(id) {
      if (!confirm('确定删除？')) return; // 防手滑
      var data = loadData();
      data.items = data.items.filter(function (it) { return it.id !== id; });
      saveData(data);
      render();
    }

    // 刷：每次数据变化后全量重画（小数据量下最省心的策略）
    function render() {
      var data = loadData();
      document.getElementById('list').innerHTML = data.items.map(function (it) {
        return '<li>' + it.content
          + ' <button onclick="removeItem(' + it.id + ')">✕</button></li>';
      }).join('');
    }

    document.getElementById('newItem').addEventListener('keydown', function (e) {
      if (e.key === 'Enter') addItem();
    });
    render(); // 首次进页面画一遍
  </script>
</body>
</html>
```

## 扩展件（同一骨架上加）

- **导出备份**：`JSON.stringify(loadData())` → `new Blob([json])` → `URL.createObjectURL` → 建 `<a>` 点击下载，文件名带日期
- **导入合并**：`FileReader` 异步读 → `JSON.parse`（套 try/catch 防坏文件）→ `data.items = data.items.concat(imported.items)` 并入不覆盖
- **搜索/筛选**：render 时在 map 前加一层 `filter(t => 条件)`

## 注意事项

1. **id 用 `Date.now()`**：纯本地单用户下够用；多条同 id 的唯一来源是「把备份导回原浏览器」（concat 原样复制），去重要靠导入前 filter
2. **数据结构带版本感**：loadData 里 `Array.isArray` 校验是防「localStorage 里有旧格式/坏数据」——首次使用和坏数据都落到默认结构
3. **动态生成的按钮用行内 onclick 传 id**：卡片是 innerHTML 字符串拼的，绑定事件最简单的形态就是 onclick 里带参调全局函数
4. **环境隔离坑**：AI 助手预览面板和 file:// 双击打开是两套 localStorage，日常使用固定用后者（见踩坑手册 #8）
5. **容量边界**：localStorage 约 5MB，只适合纯文本；图片/大文件等要上 V2（Electron 落磁盘）再考虑
