(function($, undefined) {
  function OrgChartStatus() {
    this._websocketsConnectionEstablished = false;
    this.updateChartOnChanges();
  };

  window.OrgChartStatus = OrgChartStatus;

  var proto = OrgChartStatus.prototype;

  proto.onErrorConnection = function(response, codeId, status) {
    if (response.status===403) {
      this.onForbidden(response, status);
    }
  };

  proto.onForbidden = function(response, status) {
    alert(status+": "+response.responseJSON.message);
  };

   proto.updateChartOnChanges = function() {
    this.websocketsUpdateStart();
  };

  proto.onReceiveWebSocketsMessage = function(response) {
    if (response.treeData) {
      this.setTreeData(JSON.parse(response.treeData));
    }
  };

  proto.onConnectWebSocket = function() {
    this.closeAllModals();
    this.toggleMask(false);
    if (this._reconnectInterval) {
      clearInterval(this._reconnectInterval)
    }
    this._treeIsDown = false;
  };

  proto.websocketsConnect = function() {
    var consumer=ActionCable.createConsumer();

    return consumer.subscriptions.create({ channel: "TreeStatusChannel" }, {
      connected: $.proxy(this.onConnectWebSocket, this),
      disconnected: $.proxy(this.disableTree, this),
      received: $.proxy(this.onReceiveWebSocketsMessage, this)
    });
  };

  proto.websocketsUpdateStart = function() {
    if (!this._websocketsConnectionEstablished) {
      this._websocketsConnectionEstablished = this.websocketsConnect();
    }
    return this._websocketsConnectionEstablished;
  };

  proto.toggleMask = function(state) {
    if (state !== this._maskStatus) {
      this._maskStatus = state;
      $('#tree-hierarchy .orgchart').lmask(state ? 'show' : 'hide');
    }
  };

  proto.disableTree = function() {
    if (!this._treeIsDown) {
      this.toggleMask(true);
      $('#tree-hierarchy').prepend('<div class="alert alert-danger">Sorry, Aker Projects is currently unavailable.</div>');
    }
    this._treeIsDown = true;
    this._reconnectInterval = setInterval(function() { this.websocketsConnect() }.bind(this), 3000)
  };

  proto.closeAllModals = function() {
    $('.modal').modal('hide');
  };

  proto.enableTree = function() {
    this.toggleMask(false);
  };

}(jQuery));