/*jslint browser: true, undef: true *//*global Ext*/
Ext.define('Site.widget.model.Endpoint', {
    extend: 'Site.widget.model.AbstractModel',
    singleton: true,
    alias: [
        'modelwidget.Gatekeeper\\Endpoints\\Endpoint'
    ],

    collectionTitleTpl: 'Endpoints',

    tpl: [
        '<a href="/endpoints/{Handle}" class="link-model link-endpoint">',
            '<strong class="result-title">{Title:htmlEncode}</strong> ',
            '<span class="result-info">/api/{Path}</strong>',
        '</a>'
    ]
});