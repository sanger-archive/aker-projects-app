(function($,undefined) {
  function OrgTree(options) {
    this.currentUser = options.currentUser;
    this.setTreeData(options.treeData);

    MODULES.forEach($.proxy(function(module) {
      module.apply(this, arguments);
    }, this));

    this.attachHandlers();
  }

  window.OrgTree = OrgTree;

  var MODULES = [
    OrgChartTree
  ];

  OrgTree.prototype = $.extend.call(this, OrgTree.prototype, OrgChartTree.prototype);

  var proto = OrgTree.prototype;

  var dismissButton = '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>';

  proto.alert = function(msg) {
    $('.alert.alert-danger').remove();
    $('#tree').prepend('<div class="alert alert-danger alert-dismissible">'+dismissButton+msg+'</div>');
  }

  proto.info = function(msg) {
    $('.alert.alert-info').remove();
    $('#tree').prepend('<div class="alert alert-info alert-dismissible">'+dismissButton+msg+'</div>');
  }

  proto.attachHandlers = function() {
    this.attachMenuHandlers();

    // Reset the modal to a loading icon after it's been closed
    $('#editNodeModal').on('hidden.bs.modal', function (e) {
      $('div.modal-header', this).html('');
      $('div.modal-body', this)
        .html('<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i>')
        .addClass('text-center')
    })
  };

  // Set the data that should be loaded into the OrgChart
  // Will by default load the tree
  // Returns the treeData
  proto.setTreeData = function(treeData, shouldLoadTree) {
    if (typeof shouldLoadTree == "undefined") shouldLoadTree = true;
    this.treeData = addClassNames(treeData, this.currentUser);
    if (shouldLoadTree) this.reloadTree();
    return this.treeData;
  }

  proto.reloadTree = function() {
    this.loadTree(this.treeData);
  }

  // Adds some styling for different permissions
  function addClassNames(treeData, currentUser) {
    treeData.className = "";
    treeData.writable = false;

    if (treeData.owner == currentUser.email) {
      treeData.className = 'owned-by-current-user';
      treeData.writable = true;
    } else if (checkPermission(treeData.writers, currentUser)) {
      treeData.className = 'editable-by-current-user'
      treeData.writable = true;
    }

    if (checkPermission(treeData.spenders, currentUser) && treeData.node_type == 'sub-project') {
      treeData.className += ' spendable-by-current-user'
    }

    if (treeData.children.length > 0) {
      treeData.children = treeData.children.map(function(child) {
        return addClassNames(child, currentUser)
      });
    }

    return treeData;
  }

  // Returns a true or false on whether any of the currentUser's groups or email is
  // in the permitted list
  function checkPermission(permitted, currentUser) {
    var emailAndGroups = currentUser.groups.concat([currentUser.email]);
    return !emailAndGroups.every(function(emailOrGroup) {
      return permitted.indexOf(emailOrGroup) == -1
    })
  }

}(jQuery))