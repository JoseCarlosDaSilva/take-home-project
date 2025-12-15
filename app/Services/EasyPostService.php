<?php

namespace App\Services;

use EasyPost\EasyPost;
use EasyPost\Address;
use EasyPost\Parcel;
use EasyPost\Shipment;
use Illuminate\Support\Facades\Log;

class EasyPostService
{
    public function __construct()
    {
        EasyPost::setApiKey(env('EASYPOST_API_KEY'));
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

            // Create from address
            $fromAddressObj = Address::create([
                'name' => $fromAddress['name'],
                'street1' => $fromAddress['street1'],
                'street2' => $fromAddress['street2'] ?? null,
                'city' => $fromAddress['city'],
                'state' => $fromAddress['state'],
                'zip' => $fromAddress['zip'],
                'country' => 'US',
                'phone' => $fromAddress['phone'] ?? null,
            ]);

            // Create to address
            $toAddressObj = Address::create([
                'name' => $toAddress['name'],
                'street1' => $toAddress['street1'],
                'street2' => $toAddress['street2'] ?? null,
                'city' => $toAddress['city'],
                'state' => $toAddress['state'],
                'zip' => $toAddress['zip'],
                'country' => 'US',
                'phone' => $toAddress['phone'] ?? null,
            ]);

            // Create parcel
            $parcel = Parcel::create([
                'length' => $parcelInfo['length'],
                'width' => $parcelInfo['width'],
                'height' => $parcelInfo['height'],
                'weight' => $parcelInfo['weight'],
            ]);

            // Create shipment
            $shipment = Shipment::create([
                'from_address' => $fromAddressObj,
                'to_address' => $toAddressObj,
                'parcel' => $parcel,
            ]);

            // Buy the shipment (purchase the label)
            $shipment->buy([
                'rate' => $shipment->lowest_rate(['carriers' => ['USPS']]),
            ]);

            return [
                'shipment_id' => $shipment->id,
                'tracking_number' => $shipment->tracker->tracking_code ?? null,
                'label_url' => $shipment->postage_label->label_url,
                'carrier' => $shipment->selected_rate->carrier ?? 'USPS',
                'service' => $shipment->selected_rate->service ?? null,
                'rate' => $shipment->selected_rate->rate ?? null,
            ];
        } catch (\Exception $e) {
            Log::error('EasyPost API Error: ' . $e->getMessage());
            throw new \Exception('Failed to create shipping label: ' . $e->getMessage());
        }
    }
}
