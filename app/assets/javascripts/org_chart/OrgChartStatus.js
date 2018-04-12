(function($, undefined) {
  function OrgChartStatus() {
    this.updateChartOnChanges();
  };

  window.OrgChartStatus = OrgChartStatus;

  var proto = OrgChartStatus.prototype;

  proto.onErrorConnection = function(response, codeId, status) {
    if (response.status===403) {
      this.onForbidden(response, status);
    }
    this.resetTree();
  };

  proto.onForbidden = function(response, status) {
    alert(status+": "+response.responseJSON.message);
  };

   proto.updateChartOnChanges = function() {
    this.websocketsUpdateStart();
    return;
  };

  proto.ajaxUpdateStart = function() {
    this.intervalId = setInterval($.proxy(this.keepTreeUpdate, this), 10000);
  };

  proto.onReceiveWebSocketsMessage = function(response) {
    if (response.notifyChanges === true) {
      this.keepTreeUpdate();
    }
  };

  proto.onConnectWebSocket = function() {
    this.closeAllModals();
    this.resetTree();
  };

  proto.websocketsConnect = function() {
    return App.cable.subscriptions.create({ channel: "TreeStatusChannel" }, {
      connected: $.proxy(this.onConnectWebSocket, this),
      received: $.proxy(this.onReceiveWebSocketsMessage, this)
    });
  };

  proto.websocketsUpdateStart = function() {
    if (!this._websocketsConnectionStablished) {
      this._websocketsConnectionStablished = this.websocketsConnect();
    }
    return this._websocketsConnectionStablished;
  };


  proto.stopUpdating = function() {
    clearInterval(this.intervalId);
  }

  proto.toggleMask = function(state) {
    if (state !== this._maskStatus) {
      this._maskStatus = state;
      $('#tree-hierarchy .orgchart').lmask(state ? 'show' : 'hide');
    }
  };

  proto.disableTree = function() {
    if (!this._treeIsDown) {
      this.toggleMask(true);
      $('#tree-hierarchy').prepend('<button id="reconnect" class="button btn btn-default">Reconnect?</button>');
      $('#tree-hierarchy').prepend('<div class="alert alert-danger">Sorry, there was a problem while updating the server</div>');
      $('#reconnect').on('click', $.proxy(this.resetTree, this));
    }
    this._treeIsDown=true;
  };

  proto.closeAllModals = function() {
    $('.modal').modal('hide');
  };

  proto.enableTree = function() {
    this.toggleMask(false);
  };

  proto.resetTree = function() {
    this.toggleMask(true);
    $(this).trigger('orgchart.resetTree');
    return this.loadTree().then($.proxy(this.enableTree, this), $.proxy(this.disableTree, this));
  };

  proto.equalAttributes = function(node1, node2) {
    var nodeWithMetadata = (typeof node1.name === 'undefined') ? node2 : node1;
    var name = $('.title', $('#'+nodeWithMetadata.id)).text();
    var costCode = $('.content', $('#'+nodeWithMetadata.id)).text() || null;

    return ((node1.id == node2.id) &&
      (name == nodeWithMetadata.name) &&
      (costCode == nodeWithMetadata.cost_code)
      )
  };

  proto.equalHierarchy = function(tree1, tree2) {
    if ((!tree1 || !tree2) || !(this.equalAttributes(tree1, tree2))) {
      return false;
    } else {
      if (tree1.children && (tree1.children.length>0)) {
        if (!((tree2.children) && (tree2.children.length>0))) {
          return false;
        }
        return tree1.children.every($.proxy(function(child) {
          var child2 = tree2.children.filter($.proxy(function(child2) {
            return (this.equalAttributes(child2, child));
          }, this))[0];
          return (this.equalHierarchy(child, child2));
        }, this));
      }
      return true;
    }
  };

  proto.keepTreeUpdate = function() {
    var defer = $.Deferred();
    return $.get(Routes.api_v1_nodes_path({'include': 'nodes.parent'}), $.proxy(function(response, status, promise) {
      if (this._treeIsDown) {
        return this.resetTree().then($.proxy(function() {
          this._treeIsDown = false;
          defer.resolve(true);
        },this));
      }
      var localTree = $('#tree-hierarchy').orgchart('getHierarchy');
      var remoteTree = TreeBuilder.createFrom(response.data, true)[0];
      if (!this.equalHierarchy(localTree, remoteTree) || !this.equalHierarchy(remoteTree, localTree)) {
        return this.resetTree().then(function() {
          defer.resolve(true);
        });
      }
      defer.resolve(true);
    }, this)).fail($.proxy(this.onErrorConnection, this));
    return promise;
  };

}(jQuery));