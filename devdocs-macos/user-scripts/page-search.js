var DATA_TEXTCONTENT = 'data-dd-original-textcontent';

var hasSearchTerm = function(string, term) {
    return string.indexOf(term) > -1;
};

var highlightTermInNode = function(node, term) {
    return function() {
        let content = node.textContent;
        if (node.hasAttribute(DATA_TEXTCONTENT)) {
            content = node.getAttribute(DATA_TEXTCONTENT)
        } else {
            // Make backup of original textContent.
            node.setAttribute(DATA_TEXTCONTENT, content);
        }
    };
};

var restoreNodeTextContent = function(node) {
    return function() {
        if (node.hasAttribute(DATA_TEXTCONTENT)) {
            node.textContent = node.getAttribute(DATA_TEXTCONTENT);
            node.removeAttribute(DATA_TEXTCONTENT);
        }
    };
};

var reset = function() {
    var mainNode = document.querySelector('main[role="main"]');
    var treeWalker = document.createTreeWalker(mainNode, NodeFilter.SHOW_ELEMENT, {
        acceptNode: function(node) {
            if (node.hasAttribute(DATA_TEXTCONTENT)) {
                return NodeFilter.FILTER_ACCEPT;
            }
            return NodeFilter.FILTER_SKIP;
        },
    });
    var domMutations = [];
    while (treeWalker.nextNode()) {
        domMutations.push(restoreNodeTextContent(treeWalker.currentNode));
    }
    requestAnimationFrame(function() {
        domMutations.forEach(function(mut) {
            mut();
        });
    });
};

var search = function(term) {
    var mainNode = document.querySelector('main[role="main"]');
    var treeWalker = document.createTreeWalker(mainNode, NodeFilter.SHOW_TEXT, {
        acceptNode: function(node) {
            var parent = node.parentNode;
            // TODO switching docs doesn't invalidate the nodes.
            // MutationObserver to track?
            if (parent.tagName === 'MARK') {
                return NodeFilter.FILTER_REJECT;
            }
            let content = node.textContent;
            if (parent.hasAttribute(DATA_TEXTCONTENT)) {
                content = parent.getAttribute(DATA_TEXTCONTENT);
            }
            if (hasSearchTerm(content, term)) {
                return NodeFilter.FILTER_ACCEPT;
            }
            return NodeFilter.FILTER_SKIP;
        },
    });
    var domMutations = [];
    while (treeWalker.nextNode()) {
        domMutations.push(highlightTermInNode(treeWalker.currentNode.parentNode));
    }
    requestAnimationFrame(function() {
        domMutations.forEach(function(mut) {
            mut();
        });
    });
};
