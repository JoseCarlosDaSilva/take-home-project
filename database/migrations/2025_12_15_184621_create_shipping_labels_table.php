<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('shipping_labels', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->json('from_address');
            $table->json('to_address');
            $table->json('parcel_info');
            $table->string('easypost_shipment_id')->unique();
            $table->string('tracking_number')->nullable();
            $table->string('label_url');
            $table->string('carrier')->default('USPS');
            $table->string('service')->nullable();
            $table->decimal('rate', 10, 2)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('shipping_labels');
    }
};
