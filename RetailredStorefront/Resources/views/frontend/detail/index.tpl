{extends file="parent:frontend/detail/index.tpl"}

{block name='frontend_index_header_javascript_tracking'}
    {$smarty.block.parent}
    {if $rrConfig.displayType != 'disabled'}
        <script type='text/javascript' src='https://cdn.retail.red/omni/retailred-storefront-library-v1.js'></script>
        <script type="text/javascript">
            try {
                window.addEventListener('load', function () {
                    var localization = {$rrConfig.translations|default:null|json_encode} || { } ;
                    localization.countries = {$rrConfig.countries|json_encode} || ["de"];
                    if (!Array.isArray(localization.countries)) {
                        localization.countries = [localization.countries];
                    }

                    var variants = {$sArticle.sConfigurator|json_encode} || [];
                    var hasVariants = !!variants.length;
                    var selectedVariants = variants.filter(function(variant) {
                        return variant.selected === true;
                    }) || [];
                    var isVariantSelected = !!selectedVariants.length;

                    var retailred = window.RetailRedStorefront.create({
                        apiKey: '{$rrConfig.apiKey}',
                        apiStage: '{$rrConfig.apiStage}',
                        useGeolocationImmediately: {$rrConfig.useGeolocationImmediately|json_encode},
                        browserHistory: {$rrConfig.browserHistory|json_encode},
                        testMode: {$rrConfig.testMode|json_encode},
                        unitSystem: '{$rrConfig.unitSystem}',
                        localization: localization,
                        inventory: {
                            hideNumber: {$rrConfig.inventoryHideNumber|json_encode},
                            showExactUntil: {$rrConfig.inventoryShowExactUntil|default:null|json_encode},
                            showLowUntil: {$rrConfig.inventoryShowLowUntil},
                        },
                        legal: {
                            terms: {$rrConfig.termsLink|default:null|json_encode},
                            privacy: {$rrConfig.privacyLink|default:null|json_encode},
                        },
                        customer: {
                            code: '{$userData.additional.user.customernumber}',
                            firstName: '{$userData.additional.user.firstname}',
                            lastName: '{$userData.additional.user.lastname}',
                            phone: '{$userData.additional.user.phone}',
                            emailAddress: '{$userData.additional.user.email}',
                        },
                        product: {
                            code: '{if $rrConfig.productCodeMapping == 'ean'}{$sArticle.ean}{else}{$sArticle.ordernumber}{/if}',
                            name: '{$sArticle.articleName}',
                            quantity: 1,
                            imageUrl: '{$sArticle.image.source}',
                            price: {$sArticle.price_numeric},
                            currencyCode: '{$Shop->getCurrency()->getCurrency()}',
                            options: selectedVariants.map(function (variant) {
                                return {
                                    name: variant.groupname,
                                    value: variant.values[variant.selected_value].optionname,
                                };
                            })
                        },
                    });

                    var render = function () {
                        {if $rrConfig.displayType == 'reserveButton'}
                        retailred.renderReserveButton('#rr-reserve-button');
                        {elseif $rrConfig.displayType == 'liveInventory'}
                        retailred.renderLiveInventory('#rr-live-inventory', {
                            variant: '{$rrConfig.renderLiveInventoryMode}'
                        });
                        {/if}

                        if (hasVariants) {
                            setTimeout(function() {
                                $('#rr-omni-reserve-button, #rr-inventory-find, #rr-inventory-select').prop('disabled', !isVariantSelected);
                            }, 50);
                        }
                    }

                    render();

                    $('#sQuantity').change(function() {
                        retailred.updateConfig({
                            product: {
                                quantity: parseInt($(this).val()),
                            },
                        });
                    });

                    $.subscribe('plugin/swAjaxVariant/onRequestData', function(e, me, response, values) {
                        try {
                            {if $rrConfig.productCodeMapping == 'ean'}
                                var $response = $($.parseHTML(response, document))
                                var productCode = $.trim($response.find('meta[itemprop^=gtin]').attr('content'));
                            {else}
                                var productCode = $.trim(me.$el.find(me.opts.orderNumberSelector).text());
                            {/if}

                            var newData = {
                                code: productCode,
                            };

                            var newImg = me.$el.find('.product--image-container img').get(0);
                            if (newImg) {
                                newData.imageUrl = newImg.src;
                            }

                            var newName = me.$el.find('.product--title[itemprop="name"]').first().text();
                            if (newName) {
                                newData.name = newName.replace(/\s+/g, " ").trim();
                            }

                            var newPrice = me.$el.find('.price--content meta[itemprop=price]').attr('content');
                            if (newPrice) {
                                newData.price = parseFloat(newPrice);
                            }

                            var newVariant = variants.map(function (variant) {
                                var selected_value = values[`group[${ variant.groupID }]`]

                                if (!selected_value) {
                                    return null;
                                }

                                return {
                                    name: variant.groupname,
                                    value: variant.values[selected_value].optionname,
                                };
                            }).filter(Boolean);

                            isVariantSelected = newVariant.length === variants.length;

                            if (newImg) {
                                newData.options = newVariant;
                            }

                            retailred.updateConfig({
                                product: newData,
                            });

                            // shopware replaces the html after variant switch. so we need to add our buttons again
                            render();
                        } catch (e) {
                            console.error(e);
                        }
                    });
                });
            } catch (e) {
                console.error(e);
            }
        </script>
    {/if}
{/block}


