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
                    var selectedVariants = variants.filter(function(variant) {
                        return variant.selected === true;
                    }) || [];

                    var retailred = window.RetailRedStorefront.create({
                        apiKey: '{$rrConfig.apiKey}',
                        apiStage: '{$rrConfig.apiStage}',
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
                            code: '{$sArticle.ordernumber}',
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
                    }

                    render();

                    $('#sQuantity').change(function() {
                        retailred.updateConfig({
                            product: {
                                quantity: $(this).val(),
                            },
                        });
                    });

                    $.subscribe('plugin/swAjaxVariant/onRequestData', function(e, me, response, values) {
                        var orderNumber = $.trim(me.$el.find(me.opts.orderNumberSelector).text());
                        var newData = {
                            code: orderNumber,
                        };

                        var newImg = me.$el.find('.product--image-container img').get(0);
                        if (newImg) {
                            newData.imageUrl = newImg.src;
                        }

                        var newName = me.$el.find('.product--title').text();
                        if (newName) {
                            newData.name = newName.replace(/\s+/g, " ").trim();
                        }

                        var newPrice = me.$el.find('.price--content meta[itemprop=price]').attr('content');
                        if (newPrice) {
                            newData.price = parseFloat(newPrice);
                        }

                        var newVariant = variants.map(function (variant) {
                            const selected_value = values[`group[${ variant.groupID }]`]

                            return {
                                name: variant.groupname,
                                value: variant.values[selected_value].optionname,
                            };
                        });
                        if (newImg) {
                            newData.options = newVariant;
                        }

                        console.warn(newData);

                        retailred.updateConfig({
                            product: newData,
                        });

                        // shopware replaces the html after variant switch. so we need to add our buttons again
                        render();
                    });
                });
            } catch (e) {
                console.error(e);
            }
        </script>
    {/if}
{/block}


