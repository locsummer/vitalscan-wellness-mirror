package com.vitalscan.mirror.rppg;

/**
 * Bộ lọc dải thông kỹ thuật số Butterworth (Digital IIR Butterworth Bandpass Filter)
 * Mặc định: fs = 30 Hz, dải thông 0.75 Hz – 3.5 Hz (45 - 210 BPM)
 */
@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000\"\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0006\n\u0002\b\r\n\u0002\u0010\u0002\n\u0002\b\u0003\n\u0002\u0010\u0013\n\u0002\b\u0003\u0018\u00002\u00020\u0001B#\u0012\b\b\u0002\u0010\u0002\u001a\u00020\u0003\u0012\b\b\u0002\u0010\u0004\u001a\u00020\u0003\u0012\b\b\u0002\u0010\u0005\u001a\u00020\u0003\u00a2\u0006\u0002\u0010\u0006J\b\u0010\u0010\u001a\u00020\u0011H\u0002J\u000e\u0010\u0012\u001a\u00020\u00032\u0006\u0010\u0013\u001a\u00020\u0003J\u000e\u0010\u0014\u001a\u00020\u00152\u0006\u0010\u0016\u001a\u00020\u0015J\u0006\u0010\u0017\u001a\u00020\u0011R\u000e\u0010\u0007\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\b\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\t\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\n\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u000b\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0005\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0004\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\f\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\r\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u000e\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u000f\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000\u00a8\u0006\u0018"}, d2 = {"Lcom/vitalscan/mirror/rppg/BandpassFilter;", "", "sampleRate", "", "lowCutoff", "highCutoff", "(DDD)V", "a1", "a2", "b0", "b1", "b2", "x1", "x2", "y1", "y2", "calculateCoefficients", "", "filterSample", "x", "filterSignal", "", "signal", "reset", "app_debug"})
public final class BandpassFilter {
    private final double sampleRate = 0.0;
    private final double lowCutoff = 0.0;
    private final double highCutoff = 0.0;
    private double b0 = 0.0;
    private double b1 = 0.0;
    private double b2 = 0.0;
    private double a1 = 0.0;
    private double a2 = 0.0;
    private double x1 = 0.0;
    private double x2 = 0.0;
    private double y1 = 0.0;
    private double y2 = 0.0;
    
    public BandpassFilter(double sampleRate, double lowCutoff, double highCutoff) {
        super();
    }
    
    private final void calculateCoefficients() {
    }
    
    public final double filterSample(double x) {
        return 0.0;
    }
    
    /**
     * Lọc hai chiều thuận nghịch (Zero-Phase Forward-Backward Filter) để triệt tiêu độ lệch pha
     */
    @org.jetbrains.annotations.NotNull()
    public final double[] filterSignal(@org.jetbrains.annotations.NotNull()
    double[] signal) {
        return null;
    }
    
    public final void reset() {
    }
    
    public BandpassFilter() {
        super();
    }
}