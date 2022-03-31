<?php

namespace SgateClickAndReserve;

use Shopware\Bundle\CookieBundle\CookieCollection;
use Shopware\Bundle\CookieBundle\Structs\CookieGroupStruct;
use Shopware\Bundle\CookieBundle\Structs\CookieStruct;
use Shopware\Components\Plugin;

class SgateClickAndReserve extends Plugin
{
    public static function getSubscribedEvents(): array
    {
        return [
            'CookieCollector_Collect_Cookies' => 'addComfortCookie'
        ];
    }

    public function addComfortCookie(): CookieCollection
    {
        $pluginNamespace = $this->container->get('snippets')->getNamespace('i18n');

        $collection = new CookieCollection();
        $collection->add(new CookieStruct(
            'allow_local_storage',
            '/^match_no_cookie_djk5GA1P89dkUa2$/',
            $pluginNamespace->get('cookie'),
            CookieGroupStruct::COMFORT
        ));

        return $collection;
    }
}
