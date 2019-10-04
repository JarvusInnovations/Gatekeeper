<?php

namespace Gatekeeper\Keys;

use DB;
use Cache;
use Gatekeeper\Metrics\Metrics;
use Gatekeeper\Endpoints\Endpoint;
use Gatekeeper\Transactions\Transaction;

class Key extends \ActiveRecord
{
    public static $metricTTL = 60;
    protected $_metricsCache = [
        'counters' => [],
        'averages' => []
    ];

    // ActiveRecord configuration
    public static $collectionRoute = '/keys';
    public static $tableName = 'keys';
    public static $singularNoun = 'key';
    public static $pluralNoun = 'keys';
    public static $useCache = true;

    public static $fields = [
        'Key' => [
            'unique' => true
        ],
        'Status' => [
            'type' => 'enum',
            'values' => ['active', 'revoked'],
            'default' => 'active'
        ],
        'OwnerName',
        'ContactName' => [
            'notnull' => false
        ],
        'ContactEmail' => [
            'notnull' => false
        ],
        'ExpirationDate' => [
            'type' => 'timestamp',
            'notnull' => false
        ],
        'AllEndpoints' => [
            'type' => 'boolean',
            'default' => false
        ]
    ];

    public static $relationships = [
        'Endpoints' => [
            'type' => 'many-many',
            'class' => Endpoint::class,
            'linkClass' => KeyEndpoint::class
        ]
    ];

    public static $dynamicFields = [
        'Endpoints'
    ];

    public static $validators = [
        'OwnerName' => [
            'minlength' => 2
        ],
        'ContactEmail' => [
            'validator' => 'email',
            'required' => false
        ]
        // TODO: validate expiration date
    ];

    public static $sorters = [
        'calls-total' => [__CLASS__, 'sortMetric'],
        'calls-week' => [__CLASS__, 'sortMetric'],
        'calls-day-avg' => [__CLASS__, 'sortMetric'],
        'endpoints' => [__CLASS__, 'sortMetric']
    ];

    public static function getByKey($key)
    {
        return static::getByField('Key', $key);
    }

    public static function getByHandle($handle)
    {
        return static::getByKey($handle);
    }

    public function save($deep = true)
    {
        if (!$this->Key) {
            $this->Key = static::generateUniqueKey();
        }

        parent::save($deep);
    }

    public function getCounterMetric($counterName)
    {
        if (!array_key_exists($counterName, $this->_metricsCache['counters'])) {
            $this->_metricsCache['counters'][$counterName] = Metrics::estimateCounter("users/key:$this->ID/$counterName");
        }

        return $this->_metricsCache['counters'][$counterName];
    }

    public function getAverageMetric($averageName, $counterName)
    {
        if (!array_key_exists($averageName, $this->_metricsCache['averages'])) {
            $this->_metricsCache['averages'][$averageName] = Metrics::estimateAverage("users/key:$this->ID/$averageName", "users/key:$this->ID/$counterName");
        }

        return $this->_metricsCache['averages'][$averageName];
    }

    public function getUnlinkedEndpoints()
    {
        $currentEndpoints = array_map(function($Endpoint) {
            return $Endpoint->ID;
        }, $this->Endpoints);

        return count($currentEndpoints) ? Endpoint::getAllByWhere('ID NOT IN ('.implode(',', $currentEndpoints).')') : Endpoint::getAll();
    }

    public function getMetric($metricName, $forceUpdate = false)
    {
        $cacheKey = "metrics/keys/$this->ID/$metricName";

        if (false !== ($metricValue = Cache::fetch($cacheKey))) {
            return $metricValue;
        }

        $metricValue = DB::oneValue('SELECT %s FROM `%s` `Gatekeeper_Keys_Key` WHERE `Gatekeeper_Keys_Key`.ID = %u', [
            static::getMetricSQL($metricName),
            static::$tableName,
            $this->ID
        ]);

        Cache::store($cacheKey, $metricValue, static::$metricTTL);

        return $metricValue;
    }

    public function canAccessEndpoint(Endpoint $Endpoint)
    {
        if ($this->AllEndpoints) {
            return true;
        }

        $cacheKey = "keys/$this->ID/endpoints";
        if (false == ($allowedEndpoints = Cache::fetch($cacheKey))) {
            $allowedEndpoints = DB::allValues(
                'EndpointID',
                'SELECT EndpointID FROM `%s` KeyEndpoint WHERE KeyID = %u',
                [
                    KeyEndpoint::$tableName,
                    $this->ID
                ]
            );

            Cache::store($cacheKey, $allowedEndpoints);
        }

        return in_array($Endpoint->ID, $allowedEndpoints);
    }

    public static function generateUniqueKey()
    {
        do {
            $key = md5(mt_rand(0, mt_getrandmax()));
        }
        while (static::getByKey($key));

        return $key;
    }

    public static function getMetricSQL($metricName)
    {
        switch($metricName)
        {
            case 'calls-total':
                return sprintf('(SELECT COUNT(*) FROM `%s` WHERE KeyID = `Gatekeeper_Keys_Key`.ID)', Transaction::$tableName);
            case 'calls-week':
                return sprintf('(SELECT COUNT(*) FROM `%s` WHERE KeyID = `Gatekeeper_Keys_Key`.ID AND Created >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 WEEK))', Transaction::$tableName);
            case 'calls-day-avg':
                return sprintf('(SELECT COUNT(*) / (DATEDIFF(MAX(Created), MIN(Created)) + 1) FROM `%s` WHERE KeyID = `Gatekeeper_Keys_Key`.ID)', Transaction::$tableName);
            case 'endpoints':
                return sprintf('IF(`Gatekeeper_Keys_Key`.AllEndpoints, (SELECT COUNT(*) FROM `%s`), (SELECT COUNT(*) FROM `%s` WHERE KeyID = `Gatekeeper_Keys_Key`.ID))', Endpoint::$tableName, KeyEndpoint::$tableName);
            default:
                return 'NULL';
        }
    }

    public static function sortMetric($dir, $name)
    {
        return static::getMetricSQL($name) . ' ' . $dir;
    }

    public static function getFromRequest()
    {
        if (!empty($_SERVER['HTTP_AUTHORIZATION']) && preg_match('/^Gatekeeper-Key\s+(\w+)$/i', $_SERVER['HTTP_AUTHORIZATION'], $keyMatches)) {
            $keyString = $keyMatches[1];
        } elseif (!empty($_REQUEST['gatekeeperKey'])) {
            $keyString = $_REQUEST['gatekeeperKey'];
        }

        if (empty($keyString)) {
            return null;
        }

        if (!$Key = Key::getByKey($keyString)) {
            throw new InvalidKeyException();
        }

        return $Key;
    }

    public function getTitle()
    {
        return "$this->OwnerName [$this->Key]";
    }

    public function getHandle()
    {
        return $this->Key;
    }
}
