const Dotenv = require('dotenv-webpack')

module.exports = {
  entry: {
    app: [
      './src/index.js'
    ]
  },

  output: {
    filename: './public/[name].js',
  },

  module: {
    loaders: [
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader:  'elm-webpack-loader?verbose=true&warn=true',
      },
    ],

    noParse: /\.elm$/,
  },
  plugins: [
    new Dotenv()
  ]
};