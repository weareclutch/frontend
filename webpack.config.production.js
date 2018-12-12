const Dotenv = require('dotenv-webpack')

module.exports = {
  mode: 'production',
  entry: {
    app: [
      './src/index.js'
    ]
  },

  output: {
    filename: './public/[name].js',
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