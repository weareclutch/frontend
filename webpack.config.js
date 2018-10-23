const path = require('path')

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

  devServer: {
    inline: true,
    stats: { colors: true },
    contentBase: path.join(__dirname, 'public'),
    historyApiFallback: {
      index: './public/index.html'
    }
  }
};
