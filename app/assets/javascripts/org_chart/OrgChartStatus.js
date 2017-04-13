(function($, undefined) {
  function OrgChartStatus() {
    this.updateChartOnChanges();
  };

  window.OrgChartStatus = OrgChartStatus;

  var proto = OrgChartStatus.prototype;

  proto.onErrorConnection = function() {
    this.resetTree();
  };

  proto.updateChartOnChanges = function() {
    this.intervalId = setInterval($.proxy(this.keepTreeUpdate, this), 10000);
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

  proto.enableTree = function() {
    this.toggleMask(false);
  };

  proto.resetTree = function() {
    this.toggleMask(true);
    return this.loadTree().then($.proxy(this.enableTree, this), $.proxy(this.disableTree, this));
  };

  proto.equalHierarchy = function(tree1, tree2) {
    if ((!tree1 || !tree2) || (tree1.id !== tree2.id)) {
      return false;
    } else {
      if (tree1.children && (tree1.children.length>0)) {
        if (!((tree2.children) && (tree2.children.length>0))) {
          return false;
        }
        return tree1.children.every($.proxy(function(child) {
          var child2 = tree2.children.filter(function(child2) {
            return (child2.id == child.id);
          })[0];
          return (this.equalHierarchy(child, child2));
        }, this));
      }
      return true;
    }
  };

  proto.keepTreeUpdate = function() {
    var defer = $.Deferred();
    return $.get('/api/v1/nodes?include=nodes.parent', $.proxy(function(response, status, promise) {
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