const path = require('path')
const Dotenv = require('dotenv-webpack')

module.exports = {
  entry: {
    app: [
      './src/index.js'
    ]
  },

  output: {
    filename: '[name].js'
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
  ],
  devServer: {
    inline: true,
    stats: { colors: true },
    contentBase: path.join(__dirname, 'public'),
    historyApiFallback: true
  }
};
