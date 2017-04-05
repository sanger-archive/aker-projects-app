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
    setInterval($.proxy(this.keepTreeUpdate, this), 10000);
  };

  proto.disableTree = function() {
    this._treeIsDown=true;
    $('#tree-hierarchy').html('<div class="alert alert-danger">Sorry, there was a problem while updating the server</div>');
    $('#tree-hierarchy').append('<button id="reconnect" class="button btn btn-default">Reconnect?</button>');
    $('#reconnect').on('click', $.proxy(this.resetTree, this));
  };

  proto.resetTree = function() {
    $('#tree-hierarchy').html('');
    return this.loadTree().fail($.proxy(this.disableTree, this));
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