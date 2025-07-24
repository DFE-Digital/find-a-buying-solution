import js from "@eslint/js";
import globals from "globals";

export default [
  {
    ignores: [
      "app/assets/builds/**",
      "node_modules/**", 
      "vendor/**"
    ]
  },
  js.configs.recommended,
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.browser,
        Stimulus: "readonly"
      }
    },
    rules: {
      "quotes": ["error", "single"],
      "semi": ["error", "never"],
      "space-before-function-paren": ["error", "always"],
      "comma-dangle": ["error", "never"],
      "indent": ["error", 2],
      "no-trailing-spaces": "error",
      "padded-blocks": ["error", "never"],
      "space-before-blocks": "error",
      "keyword-spacing": "error",
      "space-infix-ops": "error",
      "comma-spacing": "error",
      "key-spacing": "error",
      "brace-style": ["error", "1tbs", { allowSingleLine: true }],
      "curly": ["error", "multi-line"],
      "no-multiple-empty-lines": ["error", { max: 1, maxEOF: 0 }],
      "no-var": "error",
      "prefer-const": "error",
      "eqeqeq": ["error", "always", { null: "ignore" }],
      "no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "camelcase": ["error", { properties: "never" }]
    }
  }
];
