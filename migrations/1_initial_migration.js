var Migrations = artifacts.require("Migrations");

module.exports = function(deployer) {
  // Deploy the Migrations contract as our only task
  deployer.deploy(Migrations);
};

var Grade = artifacts.require("Grade");

module.exports = function(deployer) {
  // Deploy the Migrations contract as our only task
  deployer.deploy(Grade);
};