function findNode(json, name) {
  return json[0].data.filter(function(n) {
    return (n.attributes.name == name);
  })[0];
}

describe("TreeBuilder", function() {
  it('creates a tree from a node json', function() {
    var json = fixture.load("tree.json");
    expect(function() {
      var tree = TreeBuilder.createFrom(json[0].data, true);
      expect(tree).to.not.be.undefined;
    }).to.not.throwException();
  });
  it('keeps the order of children in the resulting tree depending on created-at', function() {
    var json = fixture.load("tree.json")
    var node1 = findNode(json, "Node1");
    var node2 = findNode(json, "Node2");
    var node3 = findNode(json, "Node3");

    node2.attributes['created-at'] = "2018-03-02T11:43:44.829Z";
    node3.attributes['created-at'] = "2018-03-02T11:44:44.829Z";
    node1.attributes['created-at'] = "2018-03-02T11:45:44.829Z";

    node1.attributes['updated-at'] = "2018-03-02T11:43:44.829Z";
    node2.attributes['updated-at'] = "2018-03-02T11:44:44.829Z";
    node3.attributes['updated-at'] = "2018-03-02T11:45:44.829Z";

    var tree = TreeBuilder.createFrom(json[0].data, true);
    var list = tree[0].children[0].children.map(function(node) { return node.id; });
    var list2 = [node2, node3, node1].map(function(node) { return node.id; });
    expect(list).to.eql(list2);
  })
})