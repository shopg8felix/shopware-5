{extends file="parent:frontend/detail/buy.tpl"}

{block name='frontend_detail_buy_button'}
    {if $rrConfig.displayType != 'disabled'}
        {if $rrConfig.customCSS}
            <style>
                {$rrConfig.customCSS}
            </style>
        {/if}
        {$smarty.block.parent}
        <div id="rr-reserve-button"></div>
        <div id="rr-live-inventory"></div>
    {else}
        {$smarty.block.parent}
    {/if}
{/block}
