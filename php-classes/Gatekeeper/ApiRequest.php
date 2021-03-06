<?php

namespace Gatekeeper;

use Gatekeeper\Endpoints\Endpoint;
use Gatekeeper\Keys\Key;
use Gatekeeper\Exemptions\Exemption;
use Gatekeeper\Transactions\Transaction;
use Emergence\Site\Client;

class ApiRequest
{
    protected $startTime;
    protected $pathStack = [];
    protected $endpoint;
    protected $clientAddress;
    protected $key;
    protected $exemption;
    protected $url = '';
    protected $transaction;

    public function __construct(array $pathStack = null)
    {
        $this->startTime = time();

        if ($pathStack !== null) {
            $this->pathStack = $pathStack;
        }
    }

    public function getStartTime()
    {
        return $this->startTime;
    }

    public function getPathStack()
    {
        return $this->pathStack;
    }

    public function setPathStack(array $pathStack)
    {
        $this->pathStack = $pathStack;
    }

    public function shiftPathStack()
    {
        return array_shift($this->pathStack);
    }

    public function peekPathStack()
    {
        return count($this->pathStack) ? $this->pathStack[0] : null;
    }

    public function getEndpoint()
    {
        return $this->endpoint;
    }

    public function setEndpoint(Endpoint $Endpoint)
    {
        $this->endpoint = $Endpoint;
    }

    public function getClientAddress()
    {
        return $this->clientAddress;
    }

    public function setClientAddress($clientAddress)
    {
        $this->clientAddress = $clientAddress;
    }

    public function getKey()
    {
        return $this->key;
    }

    public function setKey(Key $Key)
    {
        $this->key = $Key;
    }

    public function getExemption()
    {
        return $this->exemption;
    }

    public function setExemption(Exemption $Exemption)
    {
        $this->exemption = $Exemption;
    }

    public function getUrl()
    {
        return $this->url;
    }

    public function setUrl($url)
    {
        $this->url = is_array($url) ? implode('/', $url) : $url;
    }

    public function getTransaction()
    {
        return $this->transaction;
    }

    public function setTransaction(Transaction $Transaction)
    {
        $this->transaction = $Transaction;
    }

    public function isReady()
    {
        return $this->endpoint && is_a($this->endpoint, Endpoint::class);
    }

    public function getUserIdentifier()
    {
        return $this->key
            ? 'key:' . $this->key->ID
            : 'ip:' . ($this->clientAddress ?: Client::getAddress());
    }
}
