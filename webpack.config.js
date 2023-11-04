const path = require('path');

module.exports = {
  entry: './path/to/your/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
  },
  mode: 'development' // 'production' for production build
};
