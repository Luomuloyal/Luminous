module.exports = {
  rules: {
    "type-enum": [
      2,
      "always",
      [
        "feat", // ✨ 新功能
        "fix", // 🐛 Bug 修复
        "docs", // 📚 文档
        "style", // 💄 代码格式
        "refactor", // ♻️ 重构
        "perf", // ⚡ 性能优化
        "test", // ✅ 测试
        "build", // 📦 构建系统
        "ci", // 🔧 CI 配置
        "chore", // 🔨 杂项
        "revert", // ⏪ 回滚
      ],
    ],
    "type-case": [2, "always", "lower-case"],
    "type-empty": [2, "never"],
    "scope-enum": [
      1,
      "always",
      [
        "auth",
        "home",
        "record",
        "drug",
        "mine",
        "more",
        "api",
        "ui",
        "core",
        "router",
        "today",
        "shell",
        "settings",
        "notification",
        "data",
        "theme",
        "navigation",
        "service",
        "model",
        "widget",
        "util",
        "config",
        "test",
        "ci",
        "release",
      ],
    ],
    "scope-case": [2, "always", "lower-case"],
    "subject-empty": [2, "never"],
    "subject-case": [
      2,
      "never",
      ["sentence-case", "start-case", "pascal-case", "upper-case"],
    ],
    "subject-full-stop": [2, "never", "."],
    "subject-max-length": [2, "always", 100],
    "header-max-length": [2, "always", 200],
    "body-leading-blank": [1, "always"],
    "body-max-line-length": [2, "always", 200],
    "footer-leading-blank": [1, "always"],
    "footer-max-line-length": [2, "always", 200],
  },
};
