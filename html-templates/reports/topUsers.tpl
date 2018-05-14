{extends designs/site.tpl}

{block title}Top Users &mdash; {$dwoo.parent}{/block}

{block content}
    <header class="page-header">
        <h2 class="page-title">Top Users {if $Endpoint}for {endpoint $Endpoint}{/if}</h2>
        <div class="page-buttons">
            <small class="muted">Download:&nbsp;</small>
            <a class="button" href="?{refill_query format=json}">JSON</a>
            <a class="button" href="?{refill_query format=csv}">CSV</a>
        </div>
    </header>

    <form method="GET">
        <h3 class="section-title">Filters</h3>
        <fieldset class="inline-fields">

            {field inputName=time-max label='Time (max)' fieldClass="small" default='now'}
            {field inputName=time-min label='Time (min)' fieldClass="small" default='1 week ago'}

            {capture assign=endpointSelectHtml}
                <select name="endpoint" class="field-control">
                    <option value="">All endpoints</option>
                    {foreach item=AvailableEndpoint from=Gatekeeper\Endpoints\Endpoint::getAll()}
                        <option value="{$AvailableEndpoint->Handle}" {refill field=endpoint selected=$AvailableEndpoint->Handle default=$Endpoint->Handle}>{$AvailableEndpoint->getTitle()|escape}</option>
                    {/foreach}
                </select>
        	{/capture}
        	
        	{labeledField html=$endpointSelectHtml type=select label='Endpoint'}

            {field inputName=limit type=number label='Limit' default='20' attribs='min="0"' fieldClass="tiny"}

            <div class="submit-area"><input type="submit" value="Apply Filters"></div>
        </fieldset>
    </form>

    <table>
        <thead>
                <th class="col-user">User</th>
                <th class="col-timestamp">Total Requests</th>
                <th class="col-request-earliest">Earliest <small class="inline">Request</small></th>
                <th class="col-request-latest">Latest <small class="inline">Request</small></th>
            </tr>
        </thead>

        <tbody>
        {foreach item=result from=$data}
            <tr>
                <td class="col-user">
                    {if $result.UserType == 'ip'}
                        IP Address: <strong><a href="/transactions?ip={$result.UserIdentifier|escape:url}">{$result.UserIdentifier}</a></strong>
                    {else}
                        Key: <strong>{apiKey $result.UserIdentifier}</strong>
                    {/if}
                </td>
                <td class="col-timestamp">{$result.TotalRequests|number_format}</td>
                <td class="col-request-earliest">{$result.EarliestRequest}</td>
                <td class="col-request-latest">{$result.LatestRequest}</td>
            </tr>
        {foreachelse}
            <tr>
                <td colspan="4" class="col-empty-text">No users found.</td>
            </tr>
        {/foreach}
        </tbody>
    </table>
{/block}
