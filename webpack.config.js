const path = require('path');

module.exports = {
  entry: {
    main: './src/index.js' // エントリーポイントとなるJavaScriptファイルのパス
  },
  output: {
    path: path.resolve(__dirname, 'dist'), // バンドルされたファイルの出力先ディレクトリ
    filename: 'bundle.js', // バンドルされたファイルの名前
  },
  mode: 'development' // ビルドモード（'development'または'production'）
};
