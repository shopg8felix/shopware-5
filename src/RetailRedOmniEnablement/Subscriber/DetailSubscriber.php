<?php

namespace RetailRedOmniEnablement\Subscriber;

use Enlight\Event\SubscriberInterface;
use Shopware\Components\Plugin\DBALConfigReader;

class DetailSubscriber implements SubscriberInterface
{
    /**
     * @var DBALConfigReader
     */
    private $configReader;

    /**
     * @var string
     */
    private $pluginName;

    /**
     * @param DBALConfigReader $configReader
     * @param $pluginName
     */
    public function __construct(DBALConfigReader $configReader, $pluginName)
    {
        $this->configReader = $configReader;
        $this->pluginName = $pluginName;
    }

    public static function getSubscribedEvents()
    {
        return [
            'Enlight_Controller_Action_PostDispatchSecure_Frontend_Detail' => 'onPostDispatchFrontendDetail'
        ];
    }

    public function onPostDispatchFrontendDetail(\Enlight_Event_EventArgs $args)
    {
        /** @var \Shopware_Controllers_Frontend_Detail $subject */
        $subject = $args->get('subject');

        $config = $this->configReader->getByPluginName($this->pluginName);
        $userData = Shopware()->Modules()->Admin()->sGetUserData();

        $subject->View()->assign('rrConfig', $config);
        $subject->View()->assign('userData', $userData);
    }
}
