import html from 'eslint-plugin-html';

export default [
  {
    files: ['**/*.jsp'],
    plugins: {
      html
    },
    // Remove the processor configuration if it's causing issues
    // processor: html.processors['.html']
  }
];
