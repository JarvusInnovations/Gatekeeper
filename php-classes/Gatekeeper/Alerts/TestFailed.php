<?php

namespace Gatekeeper\Alerts;

class TestFailed extends AbstractAlert
{
    public static $notificationTemplate = 'testFailed';
    public static $isFatal = true;
}