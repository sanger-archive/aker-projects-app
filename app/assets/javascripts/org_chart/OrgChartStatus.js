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

  proto.websocketsUpdateStart = function() {
    if (!this._websocketsConnectionEstablished) {
      this._websocketsConnectionEstablished = this.websocketsConnect();
    }
    return this._websocketsConnectionEstablished;
  };

  proto.websocketsConnect = function() {
    return App.cable.subscriptions.create({ channel: "TreeStatusChannel" }, {
      // Called when the subscription is ready for use on the server
      connected: $.proxy(this.onConnectWebSocket, this),
      // Called when the subscription has been terminated by the server
      disconnected: $.proxy(this.disableTree, this),
      received: $.proxy(this.onReceiveWebSocketsMessage, this)
    });
  };

  proto.onConnectWebSocket = function() {
    $('.alert.alert-danger').remove();
    this.closeAllModals();
    this.toggleMask(false);
    if (this.alertTimeout) {
      clearTimeout(this.alertTimeout);
      this.alertTimeout = null;
    }
  };

  proto.toggleMask = function(state) {
    if (state !== this._maskStatus) {
      this._maskStatus = state;
      $('#tree-hierarchy .orgchart').lmask(state ? 'show' : 'hide');
    }
  };

  proto.disableTree = function() {
    this.alertTimeout = setTimeout(function() {
      this.alert('Sorry, Aker Projects is currently unavailable.');
    }.bind(this), 5000);
  };

  proto.onReceiveWebSocketsMessage = function(response) {
    if (response.treeData) {
      $.getJSON(Routes.nodes_path() + '.json').then(
        this.setTreeData.bind(this),
        this.disableTree.bind(this)
      );
    }
  };

  proto.closeAllModals = function() {
    $('.modal').modal('hide');
  };

  proto.enableTree = function() {
    this.toggleMask(false);
  };

}(jQuery));
