const path = require('path');
const webpack = require('webpack');

const isDevelopment = process.env.NODE_ENV === 'development';
const isProduction = process.env.NODE_ENV === 'production';

// Helper to generate bundle name based on environment
const bundleName = (name) => isDevelopment ? `dev-${name}` : name;

module.exports = {
  mode: isProduction ? 'production' : 'development',
  
  // Enable source maps in development
  devtool: isDevelopment ? 'source-map' : false,
  
  // Entry points matching the browserify setup
  entry: {
    'bundle': './app/javascript/application.js',
    'bundle-embedded-view': './app/javascript/embedded-view.js',
    'bundle-react-server-side': './app/javascript/react-server-side.js',
    'bundle-integration-testbed': './app/javascript/integration-testbed.js',
  },
  
  // Output to public/assets/bundles/ to match Rails expectations
  output: {
    path: path.resolve(__dirname, 'public/assets/bundles'),
    filename: (pathData) => {
      // Apply dev- prefix in development mode
      return isDevelopment ? `dev-${pathData.chunk.name}.js` : `${pathData.chunk.name}.js`;
    },
    clean: false, // Don't clean the directory to preserve other builds
  },
  
  resolve: {
    extensions: ['.js', '.jsx', '.json'],
    // Ensure node_modules are resolved
    modules: ['node_modules'],
  },
  
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              ['@babel/preset-env', {
                targets: {
                  browsers: ['last 2 versions', 'ie >= 11']
                },
                modules: false // Let webpack handle modules
              }],
              '@babel/preset-react'
            ],
            plugins: [
              '@babel/plugin-transform-runtime'
            ]
          }
        }
      },
      {
        // Handle CSV files - import them as raw text
        test: /\.csv$/,
        type: 'asset/source'
      }
    ]
  },
  
  plugins: [
    // Define global variables (matching browserify behavior)
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
    }),
    
    // Provide jQuery globally (matching browserify setup)
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
    }),
    
    // Show build progress
    new webpack.ProgressPlugin(),
  ],
  
  // Node polyfills (browserify provides these by default)
  resolve: {
    extensions: ['.js', '.jsx', '.json'],
    fallback: {
      // Ignore crypto as per browserify config
      'crypto': false,
      'path': require.resolve('path-browserify'),
      'url': require.resolve('url/'),
      'fs': false, // brfs handles fs.readFileSync at build time
    }
  },
  
  // Performance hints
  performance: {
    hints: isProduction ? 'warning' : false,
    maxEntrypointSize: 10000000, // 10MB (existing bundles are large)
    maxAssetSize: 10000000,
  },
  
  // Stats configuration for cleaner output
  stats: {
    colors: true,
    modules: false,
    children: false,
    chunks: false,
    chunkModules: false
  },
};
