const Dotenv = require('dotenv-webpack')
const path = require('path')

module.exports = {
  mode: 'production',
  entry: {
    app: './src/index.js'
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'public')
  },

  module: {
    rules: [
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader:  'elm-webpack-loader',
        options: {
          verbose: true,
          warn: true
        }
      },
    ],

    noParse: /\.elm$/,
  },
  plugins: [
    new Dotenv()
  ]
};