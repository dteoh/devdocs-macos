(function() {
    const DATA_TEXTCONTENT = 'data-dd-original-textcontent';

    // From:
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
    const escapeRegExp = function(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
    }

    const mutateDOM = function(mutations) {
        return new Promise(function(resolve, _reject) {
            requestAnimationFrame(function() {
                mutations.forEach(function(mut) {
                    mut();
                });
                resolve(true);
            });
        });
    };

    const hasSearchTerm = function(string, term) {
        return new RegExp(escapeRegExp(term), 'i').test(string);
    };

    const highlightTermInNode = function(node, term) {
        return function() {
            let content = node.textContent;
            if (node.hasAttribute(DATA_TEXTCONTENT)) {
                content = node.getAttribute(DATA_TEXTCONTENT)
            } else {
                // Make backup of original textContent.
                node.setAttribute(DATA_TEXTCONTENT, content);
            }
            const newContent = content.replace(
                new RegExp(escapeRegExp(term), 'gi'),
                (match) => `<mark>${match}</mark>`
            );
            node.innerHTML = newContent;
        };
    };

    const restoreNodeTextContent = function(node) {
        return function() {
            if (node.hasAttribute(DATA_TEXTCONTENT)) {
                node.textContent = node.getAttribute(DATA_TEXTCONTENT);
                node.removeAttribute(DATA_TEXTCONTENT);
            }
        };
    };

    const reset = function() {
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
        return mutateDOM(domMutations);
    };

    const search = function(term) {
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
            domMutations.push(highlightTermInNode(treeWalker.currentNode.parentNode, term));
        }
        return mutateDOM(domMutations);
    };

    window.search = function(term) {
        if (term === '' || typeof term !== 'string') {
            return;
        }
        return reset().then(() => search(term));
    };

    window.resetSearch = function() {
        return reset();
    };
})();

