Ext.define("Site.page.Portal",{singleton:true,constructor:function(){var a=this;a.endpoints=new Ext.util.Collection();Ext.onReady(a.onDocReady,a)},onDocReady:function(){var c=this,a=c.endpoints,b="Search APIs\u2026",d=c.searchInputEl=Ext.getBody().down(".api-search-input");Ext.select(".endpoint-list-item",true).each(function(h){var e=h.down(".endpoint-path"),f=h.down(".endpoint-title"),g=h.down(".endpoint-description");a.add({id:parseInt(h.getAttribute("data-endpoint-id"),10),endpointEl:h,pathEl:e,pathText:e.dom.textContent,titleEl:f,titleText:f.dom.textContent,descriptionEl:g,descriptionText:g.dom.textContent})});if(d){d.set({placeholder:b});d.on({focus:function(){d.set({placeholder:""})},blur:function(){d.set({placeholder:b})},keyup:{buffer:100,fn:function(){c.filterEndpoints(Ext.String.trim(d.getValue()))}}})}},filterEndpoints:function(c){var b=this,a=c&&new RegExp("("+Ext.String.escapeRegex(c)+")","i");if(b.currentQuery==c){return}b.currentQuery=c;b.endpoints.each(function(e){var d=false;Jarvus.util.Highlighter.removeHighlights(e.endpointEl);if(c){if(a.test(e.pathText)){d=true;e.pathEl.update(e.pathText.replace(a,"<mark>$1</mark>"))}if(a.test(e.titleText)){d=true;e.titleEl.update(e.titleText.replace(a,"<mark>$1</mark>"))}if(a.test(e.descriptionText)){d=true;Jarvus.util.Highlighter.highlight(e.descriptionEl,c)}}else{d=true}e.endpointEl.setStyle("display",d?"":"none")})}});