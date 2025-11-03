const { withInfoPlist } = require("@expo/config-plugins");

const withIOSNetworkSecurity = (config) => {
  return withInfoPlist(config, (config) => {
    const existingPlist = config.modResults;

    const transportSecurity = existingPlist.NSAppTransportSecurity || {};

    transportSecurity.NSAllowsArbitraryLoads = true;

    transportSecurity.NSAllowsLocalNetworking = true;

    transportSecurity.NSAllowsArbitraryLoadsInWebContent = true;
    transportSecurity.NSAllowsArbitraryLoadsForMedia = true;

    existingPlist.NSAppTransportSecurity = transportSecurity;

    existingPlist.NSLocalNetworkUsageDescription =
      "Termix needs to connect to servers on your local network for SSH and other services.";

    existingPlist.NSBonjourServices = ["_ssh._tcp", "_sftp-ssh._tcp"];

    return config;
  });
};

module.exports = withIOSNetworkSecurity;