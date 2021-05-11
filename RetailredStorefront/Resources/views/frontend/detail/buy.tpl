{extends file="parent:frontend/detail/buy.tpl"}

{block name='frontend_detail_buy_button'}
    {if $rrConfig.displayType != 'disabled'}
        <style type="text/css">
            #rr-omni-reserve-button{
                width: 100%;
                line-height: 38px;
                font-size: 1rem;
                text-align: center;
                margin-top: 5px;
            }

            #rr-omni #rr-omni-custom, #rr-omni-reserve-button {
                {$rrConfig.colors}
            }

            .rr-live-inventory {
                margin-top: 50px;
            }

            {if $rrConfig.customCSS}
                {$rrConfig.customCSS}
            {/if}
        </style>
        {$smarty.block.parent}
        <div id="rr-reserve-button"></div>
        <div id="rr-live-inventory"></div>
    {else}
        {$smarty.block.parent}
    {/if}
{/block}
