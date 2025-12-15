<?php

namespace App\Services;

use EasyPost\EasyPostClient;
use Illuminate\Support\Facades\Log;

class EasyPostService
{
    protected $client;

    public function __construct()
    {
        // Use config() instead of env() to work with cached configuration in production
        $apiKey = config('services.easypost.api_key');
        if (empty($apiKey)) {
            throw new \Exception('EASYPOST_API_KEY is not configured. Please set it in .env file and run: php artisan config:cache');
        }
        $this->client = new EasyPostClient($apiKey);
    }

    /**
     * Create a shipping label
     *
     * @param array $fromAddress
     * @param array $toAddress
     * @param array $parcelInfo
     * @return array
     * @throws \Exception
     */
    public function createShippingLabel(array $fromAddress, array $toAddress, array $parcelInfo): array
    {
        try {
            // Validate that addresses are in the US
            if (strtoupper($fromAddress['country'] ?? '') !== 'US') {
                throw new \Exception('From address must be in the United States');
            }
            if (strtoupper($toAddress['country'] ?? '') !== 'US') {
                throw new \Exception('To address must be in the United States');
            }

            // Create shipment using the new EasyPost 8.4 API
            $shipment = $this->client->shipment->create([
                'from_address' => [
                    'name' => $fromAddress['name'],
                    'street1' => $fromAddress['street1'],
                    'street2' => $fromAddress['street2'] ?? null,
                    'city' => $fromAddress['city'],
                    'state' => $fromAddress['state'],
                    'zip' => $fromAddress['zip'],
                    'country' => 'US',
                    'phone' => $fromAddress['phone'] ?? null,
                ],
                'to_address' => [
                    'name' => $toAddress['name'],
                    'street1' => $toAddress['street1'],
                    'street2' => $toAddress['street2'] ?? null,
                    'city' => $toAddress['city'],
                    'state' => $toAddress['state'],
                    'zip' => $toAddress['zip'],
                    'country' => 'US',
                    'phone' => $toAddress['phone'] ?? null,
                ],
                'parcel' => [
                    'length' => $parcelInfo['length'],
                    'width' => $parcelInfo['width'],
                    'height' => $parcelInfo['height'],
                    'weight' => $parcelInfo['weight'],
                ],
            ]);

            // Check if shipment has rates
            if (empty($shipment->rates) || count($shipment->rates) === 0) {
                throw new \Exception('No shipping rates available for this shipment. Please check addresses and parcel dimensions.');
            }

            // Filter for USPS rates only
            $uspsRates = array_filter($shipment->rates, function($rate) {
                return strtoupper($rate->carrier ?? '') === 'USPS';
            });

            if (empty($uspsRates)) {
                throw new \Exception('No USPS rates available for this shipment. Please check addresses and parcel dimensions.');
            }

            // Get the lowest USPS rate (syntax: lowestRate(['USPS']))
            $lowestRate = $shipment->lowestRate(['USPS']);

            if (!$lowestRate) {
                throw new \Exception('Could not determine the lowest USPS rate. Please try again.');
            }

            // Buy the shipment (purchase the label)
            $boughtShipment = $this->client->shipment->buy($shipment->id, $lowestRate);

            return [
                'shipment_id' => $boughtShipment->id,
                'tracking_number' => $boughtShipment->tracker->tracking_code ?? null,
                'label_url' => $boughtShipment->postage_label->label_url ?? null,
                'carrier' => $boughtShipment->selected_rate->carrier ?? 'USPS',
                'service' => $boughtShipment->selected_rate->service ?? null,
                'rate' => $boughtShipment->selected_rate->rate ?? null,
            ];
        } catch (\Exception $e) {
            Log::error('EasyPost API Error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);
            throw new \Exception('Failed to create shipping label: ' . $e->getMessage());
        }
    }
}
