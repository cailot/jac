import htmlPlugin from "eslint-plugin-html";

/** @type {import('eslint').Linter.Config} */
export default {
  files: ["**/*.js", "**/*.jsp"], // Include JavaScript and JSP files
  plugins: {
    html: htmlPlugin, // Register the HTML plugin
  },
  processor: "html/html", // Use the HTML processor
  rules: {
    "no-template-curly-in-string": "off", // Turn off specific rule
    semi: "off", // Turn off semi-colon requirement
  },
};