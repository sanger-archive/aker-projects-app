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
      $.getJSON(Routes.nodes_path() + '.json').then(
        this.setTreeData.bind(this),
        this.disableTree.bind(this)
      );
    }
  };

  proto.onConnectWebSocket = function() {
    this.closeAllModals();
    this.toggleMask(false);
    this._treeIsDown = false;
  };

  proto.websocketsConnect = function() {
    return App.cable.subscriptions.create({ channel: "TreeStatusChannel" }, {
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
      this.alert('Sorry, Aker Projects is currently unavailable.');
    }
    this._treeIsDown = true;
  };

  proto.closeAllModals = function() {
    $('.modal').modal('hide');
  };

  proto.enableTree = function() {
    this.toggleMask(false);
  };

}(jQuery));