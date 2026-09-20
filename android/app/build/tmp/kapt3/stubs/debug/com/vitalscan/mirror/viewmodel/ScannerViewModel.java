package com.vitalscan.mirror.viewmodel;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000l\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0006\n\u0000\n\u0002\u0010 \n\u0000\n\u0002\u0010\b\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000b\n\u0000\n\u0002\u0018\u0002\n\u0002\b\n\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0005\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u0002\n\u0002\b\u000b\n\u0002\u0010\t\n\u0002\b\u0002\u0018\u00002\u00020\u00012\u00020\u0002B\r\u0012\u0006\u0010\u0003\u001a\u00020\u0004\u00a2\u0006\u0002\u0010\u0005J\u0006\u0010)\u001a\u00020*J\b\u0010+\u001a\u00020*H\u0002J\u0006\u0010,\u001a\u00020*J\u000e\u0010-\u001a\u00020*H\u0082@\u00a2\u0006\u0002\u0010.J\u0012\u0010/\u001a\u00020*2\b\u00100\u001a\u0004\u0018\u00010\bH\u0016J(\u00101\u001a\u00020*2\u0006\u00102\u001a\u00020\n2\u0006\u00103\u001a\u00020\n2\u0006\u00104\u001a\u00020\n2\u0006\u00105\u001a\u000206H\u0016J\u0006\u00107\u001a\u00020*R\u0016\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\b0\u0007X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\t\u001a\b\u0012\u0004\u0012\u00020\n0\u0007X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u001a\u0010\u000b\u001a\u000e\u0012\n\u0012\b\u0012\u0004\u0012\u00020\n0\f0\u0007X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\r\u001a\b\u0012\u0004\u0012\u00020\u000e0\u0007X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\u000f\u001a\b\u0012\u0004\u0012\u00020\u00100\u0007X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\u0011\u001a\b\u0012\u0004\u0012\u00020\u00120\u0007X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0019\u0010\u0013\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\b0\u0014\u00a2\u0006\b\n\u0000\u001a\u0004\b\u0015\u0010\u0016R\u0017\u0010\u0017\u001a\b\u0012\u0004\u0012\u00020\n0\u0014\u00a2\u0006\b\n\u0000\u001a\u0004\b\u0018\u0010\u0016R\u000e\u0010\u0019\u001a\u00020\u0012X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u001d\u0010\u001a\u001a\u000e\u0012\n\u0012\b\u0012\u0004\u0012\u00020\n0\f0\u0014\u00a2\u0006\b\n\u0000\u001a\u0004\b\u001b\u0010\u0016R\u0017\u0010\u001c\u001a\b\u0012\u0004\u0012\u00020\u000e0\u0014\u00a2\u0006\b\n\u0000\u001a\u0004\b\u001d\u0010\u0016R\u000e\u0010\u001e\u001a\u00020\u001fX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0010\u0010 \u001a\u0004\u0018\u00010!X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u0017\u0010\"\u001a\b\u0012\u0004\u0012\u00020\u00100\u0014\u00a2\u0006\b\n\u0000\u001a\u0004\b#\u0010\u0016R\u0017\u0010$\u001a\b\u0012\u0004\u0012\u00020\u00120\u0014\u00a2\u0006\b\n\u0000\u001a\u0004\b%\u0010\u0016R\u000e\u0010&\u001a\u00020\'X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010(\u001a\u00020\u000eX\u0082D\u00a2\u0006\u0002\n\u0000\u00a8\u00068"}, d2 = {"Lcom/vitalscan/mirror/viewmodel/ScannerViewModel;", "Landroidx/lifecycle/AndroidViewModel;", "Lcom/vitalscan/mirror/camera/OnFaceRoiExtractedListener;", "application", "Landroid/app/Application;", "(Landroid/app/Application;)V", "_faceRoi", "Lkotlinx/coroutines/flow/MutableStateFlow;", "Lcom/vitalscan/mirror/rppg/FaceRoiData;", "_instantBpm", "", "_liveWaveform", "", "_remainingSeconds", "", "_scannerState", "Lcom/vitalscan/mirror/rppg/ScannerState;", "_showDisclaimer", "", "faceRoi", "Lkotlinx/coroutines/flow/StateFlow;", "getFaceRoi", "()Lkotlinx/coroutines/flow/StateFlow;", "instantBpm", "getInstantBpm", "isActivelyMeasuring", "liveWaveform", "getLiveWaveform", "remainingSeconds", "getRemainingSeconds", "repository", "Lcom/vitalscan/mirror/data/VitalRepository;", "scanJob", "Lkotlinx/coroutines/Job;", "scannerState", "getScannerState", "showDisclaimer", "getShowDisclaimer", "signalProcessor", "Lcom/vitalscan/mirror/rppg/PosSignalProcessor;", "totalScanSeconds", "acceptDisclaimer", "", "beginMeasurement", "cancelScanning", "finishMeasurement", "(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "onFaceRoiDetected", "roiData", "onRgbDataExtracted", "r", "g", "b", "timestamp", "", "startScanning", "app_debug"})
public final class ScannerViewModel extends androidx.lifecycle.AndroidViewModel implements com.vitalscan.mirror.camera.OnFaceRoiExtractedListener {
    @org.jetbrains.annotations.NotNull()
    private final com.vitalscan.mirror.data.VitalRepository repository = null;
    @org.jetbrains.annotations.NotNull()
    private final com.vitalscan.mirror.rppg.PosSignalProcessor signalProcessor = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.MutableStateFlow<com.vitalscan.mirror.rppg.ScannerState> _scannerState = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.StateFlow<com.vitalscan.mirror.rppg.ScannerState> scannerState = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.MutableStateFlow<com.vitalscan.mirror.rppg.FaceRoiData> _faceRoi = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.StateFlow<com.vitalscan.mirror.rppg.FaceRoiData> faceRoi = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.MutableStateFlow<java.util.List<java.lang.Double>> _liveWaveform = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.StateFlow<java.util.List<java.lang.Double>> liveWaveform = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.MutableStateFlow<java.lang.Double> _instantBpm = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.StateFlow<java.lang.Double> instantBpm = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.MutableStateFlow<java.lang.Integer> _remainingSeconds = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.StateFlow<java.lang.Integer> remainingSeconds = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.MutableStateFlow<java.lang.Boolean> _showDisclaimer = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlinx.coroutines.flow.StateFlow<java.lang.Boolean> showDisclaimer = null;
    @org.jetbrains.annotations.Nullable()
    private kotlinx.coroutines.Job scanJob;
    private boolean isActivelyMeasuring = false;
    private final int totalScanSeconds = 20;
    
    public ScannerViewModel(@org.jetbrains.annotations.NotNull()
    android.app.Application application) {
        super(null);
    }
    
    @org.jetbrains.annotations.NotNull()
    public final kotlinx.coroutines.flow.StateFlow<com.vitalscan.mirror.rppg.ScannerState> getScannerState() {
        return null;
    }
    
    @org.jetbrains.annotations.NotNull()
    public final kotlinx.coroutines.flow.StateFlow<com.vitalscan.mirror.rppg.FaceRoiData> getFaceRoi() {
        return null;
    }
    
    @org.jetbrains.annotations.NotNull()
    public final kotlinx.coroutines.flow.StateFlow<java.util.List<java.lang.Double>> getLiveWaveform() {
        return null;
    }
    
    @org.jetbrains.annotations.NotNull()
    public final kotlinx.coroutines.flow.StateFlow<java.lang.Double> getInstantBpm() {
        return null;
    }
    
    @org.jetbrains.annotations.NotNull()
    public final kotlinx.coroutines.flow.StateFlow<java.lang.Integer> getRemainingSeconds() {
        return null;
    }
    
    @org.jetbrains.annotations.NotNull()
    public final kotlinx.coroutines.flow.StateFlow<java.lang.Boolean> getShowDisclaimer() {
        return null;
    }
    
    public final void acceptDisclaimer() {
    }
    
    public final void startScanning() {
    }
    
    public final void cancelScanning() {
    }
    
    private final void beginMeasurement() {
    }
    
    private final java.lang.Object finishMeasurement(kotlin.coroutines.Continuation<? super kotlin.Unit> $completion) {
        return null;
    }
    
    @java.lang.Override()
    public void onFaceRoiDetected(@org.jetbrains.annotations.Nullable()
    com.vitalscan.mirror.rppg.FaceRoiData roiData) {
    }
    
    @java.lang.Override()
    public void onRgbDataExtracted(double r, double g, double b, long timestamp) {
    }
}