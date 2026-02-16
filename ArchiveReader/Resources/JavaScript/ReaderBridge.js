(function() {
    'use strict';

    if (window.__readerBridgeInitialized) return;
    window.__readerBridgeInitialized = true;

    window.ReaderBridge = {
        extractContent: function() {
            try {
                var documentClone = document.cloneNode(true);
                var reader = new Readability(documentClone, {
                    charThreshold: 100,
                    keepClasses: false
                });
                var article = reader.parse();

                if (!article) {
                    window.webkit.messageHandlers.readerMode.postMessage({
                        type: 'extractionError',
                        error: 'Could not parse article content'
                    });
                    return;
                }

                var cleanContent = DOMPurify.sanitize(article.content, {
                    ALLOWED_TAGS: [
                        'p','h1','h2','h3','h4','h5','h6',
                        'blockquote','ul','ol','li','a','img',
                        'strong','em','b','i','code','pre','br','hr',
                        'figure','figcaption','table','thead',
                        'tbody','tr','th','td','span','div',
                        'sup','sub','mark','del','ins'
                    ],
                    ALLOWED_ATTR: ['href','src','alt','title','class']
                });

                window.webkit.messageHandlers.readerMode.postMessage({
                    type: 'contentExtracted',
                    title: article.title || '',
                    byline: article.byline || '',
                    content: cleanContent,
                    excerpt: article.excerpt || '',
                    siteName: article.siteName || '',
                    length: article.length || 0
                });
            } catch (error) {
                window.webkit.messageHandlers.readerMode.postMessage({
                    type: 'extractionError',
                    error: error.message || 'Unknown extraction error'
                });
            }
        },

        checkReadability: function() {
            try {
                var isReadable = isProbablyReaderable(document);
                window.webkit.messageHandlers.readerMode.postMessage({
                    type: 'readabilityCheck',
                    isReadable: isReadable
                });
            } catch (error) {
                window.webkit.messageHandlers.readerMode.postMessage({
                    type: 'readabilityCheck',
                    isReadable: false
                });
            }
        }
    };

    window.webkit.messageHandlers.readerMode.postMessage({
        type: 'bridgeReady'
    });
})();
