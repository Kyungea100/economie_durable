/* global artifacts */

const Migrations = artifacts.require("Voting");

module.exports = function (deployer) {
    deployer.deploy(Migrations, 2);
};