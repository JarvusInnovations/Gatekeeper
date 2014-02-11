a{extends "designs/site.tpl"}

{block "title"}Ban deleted &mdash; {$dwoo.parent}{/block}

{block "content"}
    {$Ban = $data}
	
	<p class="lead">Ban on {if $Ban->IP}IP Address: <strong>{$Ban->IP|long2ip}</strong>{else}Key: <a href="/keys/{$Ban->Key->Key}">{$Ban->Key->OwnerName|escape} <small>{$Ban->Key->Key}</small></a>{/if} deleted.</p>

	<p><a href="/bans">Browse all bans</a></p>
{/block}