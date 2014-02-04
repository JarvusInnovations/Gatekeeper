{extends designs/site.tpl}

{block title}Bans &mdash; {$dwoo.parent}{/block}

{block content}

	<h2>Bans</h2>

	<form method="GET">
		<a class="button pull-right" href="/bans/create">Create Ban</a>
		<label>
			Sort by
			<select name="sort" onchange="this.form.submit()">
				<option value="">No sort</option>
				<option value="created" {refill field=sort selected=created}>Created date</option>
				<option value="expiration" {refill field=sort selected=expiration}>Expiration date</option>
			</select>
		</label>
	</form>
	
	<section class="bans">

		{foreach item=Ban from=$data}
			<article class="ban">
			    <div class="details">
    				<header>
    					<h3 class="title">
    						{if $Ban->IP}
    							IP Address: <strong>{$Ban->IP|long2ip}</strong>
    						{else}
    							Key: <strong>{key $Ban->Key}</strong>
    						{/if}
    					</h3>
    
    					<div class="ban-term">Banned {if $Ban->ExpirationDate}until {$Ban->ExpirationDate|date_format}{else}indefinitely{/if}.</div>
    				</header>
    				{if $Ban->Notes}
    					<pre class="ban-notes">{$Ban->Notes|escape}</pre>
    				{/if}
			    </div>
				<footer>
					<a class="button" href="/bans/{$Ban->ID}/edit">Edit</a>
					<a class="button" href="#remove">Remove</a>
				</footer>
			</article>
		{/foreach}

	</section>

{/block}