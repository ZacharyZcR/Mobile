const { withInfoPlist } = require('@expo/config-plugins');

const withIOSNetworkSecurity = (config) => {
  return withInfoPlist(config, (config) => {
    const infoPlist = config.modResults;

    infoPlist.NSAppTransportSecurity = {
      NSAllowsArbitraryLoads: true,

      NSAllowsLocalNetworking: true,

      NSAllowsArbitraryLoadsInWebContent: true,

      NSAllowsArbitraryLoadsForMedia: true,
    };

    return config;
  });
};

module.exports = withIOSNetworkSecurity;