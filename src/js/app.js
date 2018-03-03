App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load pets.
    /*$.getJSON('../pets.json', function(data) {
      var petsRow = $('#petsRow');
      var petTemplate = $('#petTemplate');

      for (i = 0; i < data.length; i ++) {
        petTemplate.find('.panel-title').text(data[i].name);
        petTemplate.find('img').attr('src', data[i].picture);
        petTemplate.find('.pet-breed').text(data[i].breed);
        petTemplate.find('.pet-age').text(data[i].age);
        petTemplate.find('.pet-location').text(data[i].location);
        petTemplate.find('.btn-adopt').attr('data-id', data[i].id);

        petsRow.append(petTemplate.html());
      }
    });*/

    return App.initWeb3();
  },

  initWeb3: function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Grade.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var GradeArtifact = data;
      App.contracts.Grade = TruffleContract(GradeArtifact);
    
      // Set the provider for our contract
      App.contracts.Grade.setProvider(App.web3Provider);
    
      // Use our contract to retrieve and mark the adopted pets
      return App.markGrade();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-reg', App.handleRegister);
  },

  markGrade: function(marks, account) {
    var gradeInstance;

    App.contracts.Grade.deployed().then(function(instance) {
      gradeInstance = instance;
    
      return gradeInstance.getMark();
    }).then(function(marks) {
      for (i = 0; i < marks.length; i++) {
        if (marks[i] !== '0x0000000000000000000000000000000000000000') {
          $('.panel-pet').eq(i).find('button').text('Success').attr('disabled', true);
        }
      }
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  handleRegister: function(event) {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));

    var gradeInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
    
      var account = accounts[0];
    
      App.contracts.Grade.deployed().then(function(instance) {
        gradeInstance = instance;
    
        // Execute adopt as a transaction by sending account
        return gradeInstance.addRegistrarToCenter("0xf17f52151ebef6c7334fad080c5704d77216b732", "UCMIII");
      }).then(function(result) {
        return App.markGrade();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
