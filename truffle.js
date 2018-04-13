// Allows us to use ES6 in our migrations and tests.
//require('babel-register')
//require('babel-polyfill')
module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*' // Match any network id
    },
    kovan: {
      network_id: '*',
      host: 'localhost',
      port: 8545,
      from: '0x3d4079b588630918f8966460cdb0908d71a551a3'
    },
  }
}
