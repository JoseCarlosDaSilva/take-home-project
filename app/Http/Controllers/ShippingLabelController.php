<?php

namespace App\Http\Controllers;

use App\Models\ShippingLabel;
use App\Services\EasyPostService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Inertia\Inertia;

class ShippingLabelController extends Controller
{
    protected $easyPostService;

    public function __construct(EasyPostService $easyPostService)
    {
        $this->easyPostService = $easyPostService;
    }

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $labels = ShippingLabel::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return Inertia::render('ShippingLabels/Index', [
            'labels' => $labels,
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return Inertia::render('ShippingLabels/Create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'from_address.name' => 'required|string|max:255',
            'from_address.street1' => 'required|string|max:255',
            'from_address.city' => 'required|string|max:255',
            'from_address.state' => 'required|string|max:2',
            'from_address.zip' => 'required|string|max:10',
            'from_address.country' => 'required|string|in:US',
            'to_address.name' => 'required|string|max:255',
            'to_address.street1' => 'required|string|max:255',
            'to_address.city' => 'required|string|max:255',
            'to_address.state' => 'required|string|max:2',
            'to_address.zip' => 'required|string|max:10',
            'to_address.country' => 'required|string|in:US',
            'parcel_info.length' => 'required|numeric|min:0.1',
            'parcel_info.width' => 'required|numeric|min:0.1',
            'parcel_info.height' => 'required|numeric|min:0.1',
            'parcel_info.weight' => 'required|numeric|min:0.1',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        try {
            $labelData = $this->easyPostService->createShippingLabel(
                $request->from_address,
                $request->to_address,
                $request->parcel_info
            );

            $label = ShippingLabel::create([
                'user_id' => auth()->id(),
                'from_address' => $request->from_address,
                'to_address' => $request->to_address,
                'parcel_info' => $request->parcel_info,
                'easypost_shipment_id' => $labelData['shipment_id'],
                'tracking_number' => $labelData['tracking_number'],
                'label_url' => $labelData['label_url'],
                'carrier' => $labelData['carrier'],
                'service' => $labelData['service'],
                'rate' => $labelData['rate'],
            ]);

            return redirect()->route('shipping-labels.show', $label->id)
                ->with('success', 'Shipping label created successfully!');
        } catch (\Exception $e) {
            return redirect()->back()
                ->withErrors(['error' => $e->getMessage()])
                ->withInput();
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(ShippingLabel $shippingLabel)
    {
        // Ensure user can only view their own labels
        if ($shippingLabel->user_id !== auth()->id()) {
            abort(403);
        }

        return Inertia::render('ShippingLabels/Show', [
            'label' => $shippingLabel,
        ]);
    }
}
