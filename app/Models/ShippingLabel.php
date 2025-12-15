<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ShippingLabel extends Model
{
    protected $fillable = [
        'user_id',
        'from_address',
        'to_address',
        'parcel_info',
        'easypost_shipment_id',
        'tracking_number',
        'label_url',
        'carrier',
        'service',
        'rate',
    ];

    protected $casts = [
        'from_address' => 'array',
        'to_address' => 'array',
        'parcel_info' => 'array',
        'rate' => 'decimal:2',
    ];

    /**
     * Get the user that owns the shipping label.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
