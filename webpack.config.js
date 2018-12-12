const path = require('path')
const Dotenv = require('dotenv-webpack')
const env = new Dotenv()
const apiUrl = JSON.parse(env.definitions['process.env.API_URL'])

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
    historyApiFallback: true,
    proxy: [{
      context: ['/media/images'],
      target: apiUrl,
      changeOrigin: true
    }]
  }
};
