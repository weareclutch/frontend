const path = require('path')
const Dotenv = require('dotenv-webpack')
const env = new Dotenv()
const apiUrl = JSON.parse(env.definitions['process.env.API_URL'])

module.exports = {
  mode: 'development',
  entry: {
    app: [
      '@webcomponents/custom-elements',
      './src/index.js'
    ]
  },

  output: {
    filename: '[name].js'
  },

  module: {
    rules: [
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader:  'elm-webpack-loader',
        options: {
          verbose: true,
        }
      },
    ],

    noParse: /\.elm$/,
  },
  plugins: [
    new Dotenv()
  ],
  devServer: {
    inline: true,
    stats: { colors: true },
    contentBase: path.join(__dirname, 'public'),
    historyApiFallback: true,
    proxy: [{
      context: ['/media/images', '/media/documents'],
      target: apiUrl,
      changeOrigin: true
    }]
  }
};
