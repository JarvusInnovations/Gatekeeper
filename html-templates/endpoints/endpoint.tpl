{extends designs/site.tpl}

{block title}{$data->Title|escape} &mdash; Endpoints &mdash; {$dwoo.parent}{/block}

{block "js-bottom"}
    {$dwoo.parent}

    {if !$.get.jsdebug}
        <script src="{Site::getVersionedRootUrl('js/pages/EndpointDetails.js')}"></script>
    {/if}

    <script>
        Ext.require('Site.page.EndpointDetails');
    </script>
{/block}

{block content}
    {$Endpoint = $data}

    <header class="page-header">
        <h2 class="header-title">Endpoint: {endpoint $Endpoint}</h2>
        <div class="header-buttons">
            <a class="button" href="mailto:endpoint-subscribers+{$Endpoint->Handle}@{Site::getConfig(primary_hostname)}">Email Subscribers</a>
            <a class="button" href="{$Endpoint->getURL('/edit')}">Edit Endpoint</a>
        </div>
    </header>

    <section class="page-section" id="endpoint-docs">
        <h3>Documentation</h3>

        {$SwaggerFileNode = $Endpoint->getSwaggerFileNode()}
        {if $SwaggerFileNode}
            <p class="notify">
                <a href="/develop#/{$SwaggerFileNode->FullPath}">{$SwaggerFileNode->FullPath}</a>
                (<samp>{$SwaggerFileNode->SHA1|substr:0:5}&hellip;</samp>)
                was last updated by {personLink $SwaggerFileNode->Author}
                on {$SwaggerFileNode->Timestamp|date_format:'%Y-%m-%d %H:%M:%S'}
            </p>
        {else}
            <p>
                No swagger docs have been uploaded yet, only basic information will be displayed in the developer portal.
            </p>
        {/if}

        {if $.Session->hasAccountLevel('Developer')}
            <form class="swagger-uploader" action="/develop/{$Endpoint->getSwaggerFilePath()}">
                <p>
                    Upload a <a href="https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md">Swagger 2.0 YAML</a>
                    file to <kbd>{$Endpoint->getSwaggerFilePath()}</kbd> to provide in-depth API documentation and a test console (or just <strong>drop one here.</strong>)
                </p>
            </form>
        {/if}

        <div class="buttons">
            <a class="button" href="/api-docs/{$Endpoint->Path}">View Docs</a>
        </div>
    </section>

    <form class="page-section" id="endpoint-rewrites" action="{$Endpoint->getURL('/rewrites')}" method="POST">
        <table>
            <caption>
                <h3>Rewrite Rules</h3>
            </caption>
            <thead>
                <tr>
                    <th class="col-priority">Priority</th>
                    <th class="col-pattern">Pattern</th>
                    <th class="col-replace">Replace</th>
                    <th class="col-last">Last?</th>
                </tr>
            </thead>

            <tbody>
                {foreach item=Rewrite from=$Endpoint->Rewrites}
                    <tr>
                        <td class="col-priority">{field inputName="rewrites[$Rewrite->ID][Priority]" default=$Rewrite->Priority}</td>
                        <td class="col-pattern">{field inputName="rewrites[$Rewrite->ID][Pattern]" default=$Rewrite->Pattern}</td>
                        <td class="col-replace">{field inputName="rewrites[$Rewrite->ID][Replace]" default=$Rewrite->Replace}</td>
                        <td class="col-last">{checkbox inputName="rewrites[$Rewrite->ID][Last]" value=1 unsetValue=0 default=$Rewrite->Last}</td>
                    </tr>
                {/foreach}
                <tr>
                    <td class="col-priority">{field inputName="rewrites[new][Priority]" placeholder=Gatekeeper\Endpoints\EndpointRewrite::getFieldOptions(Priority, default)}</td>
                    <td class="col-pattern">{field inputName="rewrites[new][Pattern]" placeholder="|^/routes/([^/]+)|i"}</td>
                    <td class="col-replace">{field inputName="rewrites[new][Replace]" placeholder="/?route=\$1"}</td>
                    <td class="col-last">{checkbox inputName="rewrites[new][Last]" value=1 unsetValue=0}</td>
                </tr>
            </tbody>
        </table>
        <input type="submit" value="Save Rewrites">
    </form>

    {if $Endpoint->CachingEnabled}
    <section class="page-section" id="endpoint-cache">
        <table>
            <caption>
                <h3>Cached Responses <small>(Top and most recent 15)</small></h3>
            </caption>
            <thead>
                <tr>
                    <th class="col-request">Request</th>
                    <th class="col-created">Created</th>
                    <th class="col-hits">Hits</th>
                    <th class="col-last-hit">Last Hit</th>
                    <th class="col-expiration">Expiration</th>
                </tr>
            </thead>

            <tbody>
                {foreach item=response from=$Endpoint->getCachedResponses(15)}
                    <tr>
                        <td class="col-request">GET <small>{$response.value.path|escape|default:'/'}{tif $response.value.query ? "?$response.value.query"|query_string}</small></td>
                        <td class="col-created">{$response.creation_time|date_format:'%Y-%m-%d %H:%M:%S'}</td>
                        <td class="col-hits">{$response.num_hits}</td>
                        <td class="col-last-hit">{$response.access_time|date_format:'%Y-%m-%d %H:%M:%S'}</td>
                        <td class="col-expiration">{$response.value.expires|date_format:'%Y-%m-%d %H:%M:%S'}</td>
                    </tr>
                {foreachelse}
                    <tr>
                        <td colspan="5" class="col-empty-text">No responses cached right now.</td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
        <a class="button" href="/cached-responses?endpoint={$Endpoint->Handle}">View All Cached Responses &rarr;</a>
    </section>
    {/if}

    <section class="page-section" id="endpoint-log">
        <table>
            <caption>
                <h3>Request Log <small>(Last 15)</small></h3>
            </caption>
            <thead>
                <tr>
                    <th class="col-request">
                        Request
                        <ul class="col-options">
                            <li class="col-option query-inline selected" title="Show Query Params Inline">Inline</li>
                            <li class="col-option query-list" title="Show Query Params as List">List</li>
                        </ul>
                    </th>
                    <th class="col-timestamp">Timestamp</th>
                    <th class="col-response-code"><small>Response</small> Code</th>
                    <th class="col-response-time"><small>Response</small> Time</th>
                    <th class="col-response-size"><small>Response</small> Size</th>
                    <th class="col-client-ip">Client IP</th>
                    <th class="col-key">Key</th>
                </tr>
            </thead>

            <tbody>
            {foreach item=Transaction from=Gatekeeper\Transactions\Transaction::getAllByField('EndpointID', $Endpoint->ID, array(order="ID DESC", limit=15))}
                <tr>
                    <td class="col-request">{$Transaction->Method} <small>{$Transaction->Path|escape|default:/}{tif $Request->Query ? "?$Transaction->Query"|query_string}</small></td>
                    <td class="col-timestamp">{$Transaction->Created|date_format:'%Y-%m-%d %H:%M:%S'}</td>
                    <td class="col-response-code">{$Transaction->ResponseCode}</td>
                    <td class="col-response-time">{$Transaction->ResponseTime|number_format}&nbsp;ms</td>
                    <td class="col-response-size">{$Transaction->ResponseBytes|number_format}&nbsp;B</td>
                    <td class="col-client-ip">{$Transaction->ClientIP|long2ip}</td>
                    <td class="col-key">{if $Transaction->Key}{apiKey $Transaction->Key}{else}<small class="muted">&mdash;</small></td>
                </tr>
            {foreachelse}
                <tr>
                    <td colspan="7" class="col-empty-text">No requests logged yet.</td>
                </tr>
            {/foreach}
            </tbody>
        </table>
        <a class="button" href="/transactions?endpoint={$Endpoint->Handle}">View Full Log &rarr;</a>
    </section>
{/block}