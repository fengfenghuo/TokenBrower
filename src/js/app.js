App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    var Web3 = require('web3');
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    // web3 = new Web3(App.web3Provider);

    web3 = new Web3();
    web3.setProvider(App.web3Provider);

    //检查是否连接成功
    var connected = web3.isConnected();
    if(!connected){
      console.log("node not connected!");
    }else{
      console.log("node connected");
    }

    return App.initContract();
  },

  initContract: function() {
    // 加载VBToken.json，保存了Adoption的ABI（接口说明）信息及部署后的网络(地址)信息，它在编译合约的时候生成ABI，在部署的时候追加网络信息
    $.getJSON('VBToken.json', function (data) {
      // 用VBToken.json数据创建一个可交互的TruffleContract合约实例。
      var Artifact = data;
      App.contracts.Token = TruffleContract(Artifact);

      // Set the provider for our contract
      App.contracts.Token.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      var token_name = "";
      var token_decimals;
      var contract_address = "";//0x46a90a33aea94f48a399792d9477c0e5db75e498
      var token_instance;

      App.contracts.Token.deployed().then(function (instance) {
        token_instance = instance;
        contract_address = token_instance.address;

        // 调用合约用call读取信息不用消耗gas
        return token_instance.symbol.call();
        //token_decimals = token_instance.decimals();
      }).then(function (name) {
        token_name = name;
        return token_instance.decimals.call();
      }).then(function(decimals){
        token_decimals = decimals;
        return App.getTransactions(token_name, token_decimals, contract_address);
      }).catch(function (err) {
        console.log(err.message);
      });
    });

    return App.bindEvents();
  },

  //时间戳转日期格式  
  formatDateTime: function(time){  
    var t = new Date(time);  
    var tf = function(i){return (i < 10 ? '0' : '') + i};

    return format.replace(/yyyy|MM|dd|HH|mm|ss/g, function(a){
        switch(a){  
            case 'yyyy':  
                return tf(t.getFullYear());  
                break;  
            case 'MM':  
                return tf(t.getMonth() + 1);  
                break;  
            case 'mm':  
                return tf(t.getMinutes());  
                break;  
            case 'dd':  
                return tf(t.getDate());  
                break;  
            case 'HH':  
                return tf(t.getHours());  
                break;  
            case 'ss':  
                return tf(t.getSeconds());  
                break;  
        }
      });
  },

  isContract: function(address){
    return web3.eth.getCode(address) !== '0x';
  },

  getMethod: function(method){
    if(method === sha3_256("transfer(address,uint256")){
      return 'transfer';
    }
    //TODO: other method
    return null;
  },

  getTransactions: function(token_name, token_decimals, contract_address){
    var contract_hash = "0xc33941f2510fb8f23825f745706403464eddcbc53c0c84c8ee994fd746d13907";
    var result = web3.eth.getTransaction(contract_hash);

    var cur_block = web3.eth.defaultBlock;
    var end_num = web3.eth.blockNumber;
    console.log("cur block num " + end_num);

    var begin_num = result.blockNumber;
    console.log("begin block num " + begin_num);

    var user_data = '';

    for(var i = begin_num + 1; i <= end_num; i++){
      var blockInfo = web3.eth.getBlock(i);
      var transactionCount = web3.eth.getBlockTransactionCount(i);

      for(var j = 0; j < transactionCount; j++){
        var transactionDetail = web3.eth.getTransaction(blockInfo.transactions[j]);
        if(!App.isContract(transactionDetail.to)) continue;
        
        if(transactionDetail.to != contract_address) continue;

        if(web3.eth.getCode(transactionDetail.to) !== '0x'){
          console.log("is contract");
        }

        var transactionData={
          time : blockInfo.timestamp,
          from: transactionDetail.from,
          to: transactionDetail.to,
          hash: transactionDetail.hash,
          blockHash: transactionDetail.blockHash,
          input: transactionDetail.input
        };

        var format_time = new Date(transactionData.time * 1000);
        var to = transactionData.input.substr(10,64).replace(/\b(0+)/gi, "");
        var amount = parseInt(transactionDetail.input.substring(75), 16) / Math.pow(10, token_decimals);

        console.log("token amount " + amount);

        user_data += '<tr class="one">';
        user_data += '<td>'+ format_time.toLocaleString() +'</td>';
        user_data += '<td>form: '+transactionData.from+'</td>';
        user_data += '<td>to: 0x'+ to +'</td>';
        user_data += '<td>'+ amount + ' '+ token_name + '</td>';
        user_data += '</tr>';
      }
    }
    console.log(user_data);
    $('#user_table').append(user_data);
  },

  closeBox: function(){
    $('.box2').hide();
  },

  bindEvents: function() {
    $(document).on('click', '.one', App.handlePoints);
  },

  handlePoints: function() {
    
  },

  givePoints: function(id, amount) {
    /*
     * Replace me...
     */
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});