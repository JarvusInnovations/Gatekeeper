{extends "designs/site.tpl"}

{block "title"}Key saved &mdash; {$dwoo.parent}{/block}

{block "content"}
    {$Key = $data}

    <p class="lead">API key {apiKey $Key->Key} {tif $Key->isNew ? created : saved} for {$Key->OwnerName|escape}.</p>

    <p>
        <a href="/keys/{$Key->Key}">&larr;&nbsp;Back to {$Key->OwnerName}</a><br>
        <a href="/keys">&larr;&nbsp;Browse all keys</a>
    </p>
{/block}