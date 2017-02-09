// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .

$(function() {

 $.get('/api/v1/nodes?include=nodes.parent', function(response) {

    var programs = TreeBuilder.parentNodes(response.data);
    var program_node_ids = programs[0].relationships.nodes.data.map(function(a) {return (a.id);});

    $('#side_menu_tree').treeview({
      data: TreeBuilder.createFrom(response.data, false),
      enableLinks: true,
      collapseIcon: 'fa fa-minus',
      expandIcon: 'fa fa-plus',
      emptyIcon: 'fa',
      levels: 1
    })

    $('#tree-hierarchy').orgchart({
      'data' : TreeBuilder.createFrom(response.data, true)[0],
      'depth': response.data.length,
      'nodeContent': 'href',
      'nodeID': 'id',
      'draggable' : false,

      'dropCriteria': function($draggedNode, $dragZone, $dropZone) {
        var dropNodeID = $dropZone.children('.content').text().split("/")[2];
        var draggedNodeID = $draggedNode.children('.content').text().split("/")[2];

        // adds drag and drop restrictions
        // indexOf returns -1 if the node is not a 'program'
        // dropNodeID == 1 is the root node
        if (program_node_ids.indexOf(draggedNodeID) > -1 || dropNodeID == 1) {
          return false;
        }
        return true;
      }

    })
    .children('.orgchart').on('nodedropped.orgchart', function(event) {
      console.log("On drop update database");
    });

  });

  $('#project-search').on('keyup', debounce(function(e) {
    var value = $(this).val();

    if (value) {
      $('#side_menu_tree').treeview('search', [ value, {
        ignoreCase: true,
        exactMatch: false,
        revealResults: true,
      }]);
    } else {
      $('#side_menu_tree').treeview('clearSearch');
    }
  }, 300))
})
