package com.vitalscan.mirror.rppg;

/**
 * Bộ xử lý tín hiệu rPPG toàn diện trên Android bằng thuật toán POS (Plane-Orthogonal-to-Skin)
 */
@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000X\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0006\n\u0000\n\u0002\u0010\b\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0010\t\n\u0000\n\u0002\u0010\u0002\n\u0002\b\u0005\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0013\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\b\u0005\n\u0002\u0010 \n\u0002\b\u0003\u0018\u00002\u00020\u0001B#\u0012\b\b\u0002\u0010\u0002\u001a\u00020\u0003\u0012\b\b\u0002\u0010\u0004\u001a\u00020\u0005\u0012\b\b\u0002\u0010\u0006\u001a\u00020\u0005\u00a2\u0006\u0002\u0010\u0007J&\u0010\u0013\u001a\u00020\u00142\u0006\u0010\u0015\u001a\u00020\u00032\u0006\u0010\u0016\u001a\u00020\u00032\u0006\u0010\u0017\u001a\u00020\u00032\u0006\u0010\u0018\u001a\u00020\u0012J\u001c\u0010\u0019\u001a\u000e\u0012\u0004\u0012\u00020\u0003\u0012\u0004\u0012\u00020\u00030\u001a2\u0006\u0010\u001b\u001a\u00020\u001cH\u0002J\u0010\u0010\u001d\u001a\u00020\u00032\u0006\u0010\u001e\u001a\u00020\u001cH\u0002J\b\u0010\u001f\u001a\u0004\u0018\u00010 J \u0010!\u001a\u00020\u001c2\u0006\u0010\"\u001a\u00020\u001c2\u0006\u0010#\u001a\u00020\u001c2\u0006\u0010$\u001a\u00020\u001cH\u0002J\u0016\u0010%\u001a\b\u0012\u0004\u0012\u00020\u00030&2\b\b\u0002\u0010\'\u001a\u00020\u0005J\u0006\u0010(\u001a\u00020\u0014R\u000e\u0010\b\u001a\u00020\tX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\n\u001a\b\u0012\u0004\u0012\u00020\u00030\u000bX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\f\u001a\u00020\rX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\u000e\u001a\b\u0012\u0004\u0012\u00020\u00030\u000bX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\u000f\u001a\b\u0012\u0004\u0012\u00020\u00030\u000bX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0010\u001a\u00020\tX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\u0011\u001a\b\u0012\u0004\u0012\u00020\u00120\u000bX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0005X\u0082\u0004\u00a2\u0006\u0002\n\u0000\u00a8\u0006)"}, d2 = {"Lcom/vitalscan/mirror/rppg/PosSignalProcessor;", "", "sampleRate", "", "bufferCapacity", "", "windowSize", "(DII)V", "bandpassFilter", "Lcom/vitalscan/mirror/rppg/BandpassFilter;", "blueBuffer", "Ljava/util/ArrayList;", "fftTransformer", "Lcom/vitalscan/mirror/rppg/FftTransformer;", "greenBuffer", "redBuffer", "respirationFilter", "timestamps", "", "appendRgb", "", "r", "g", "b", "timestamp", "calculateHrv", "Lkotlin/Pair;", "signal", "", "calculateStdDev", "array", "computeVitalMetrics", "Lcom/vitalscan/mirror/rppg/VitalMetrics;", "extractPosPulse", "red", "green", "blue", "getLatestFilteredWaveform", "", "count", "reset", "app_debug"})
public final class PosSignalProcessor {
    private final double sampleRate = 0.0;
    private final int bufferCapacity = 0;
    private final int windowSize = 0;
    @org.jetbrains.annotations.NotNull()
    private final java.util.ArrayList<java.lang.Double> redBuffer = null;
    @org.jetbrains.annotations.NotNull()
    private final java.util.ArrayList<java.lang.Double> greenBuffer = null;
    @org.jetbrains.annotations.NotNull()
    private final java.util.ArrayList<java.lang.Double> blueBuffer = null;
    @org.jetbrains.annotations.NotNull()
    private final java.util.ArrayList<java.lang.Long> timestamps = null;
    @org.jetbrains.annotations.NotNull()
    private final com.vitalscan.mirror.rppg.BandpassFilter bandpassFilter = null;
    @org.jetbrains.annotations.NotNull()
    private final com.vitalscan.mirror.rppg.BandpassFilter respirationFilter = null;
    @org.jetbrains.annotations.NotNull()
    private final com.vitalscan.mirror.rppg.FftTransformer fftTransformer = null;
    
    public PosSignalProcessor(double sampleRate, int bufferCapacity, int windowSize) {
        super();
    }
    
    @kotlin.jvm.Synchronized()
    public final synchronized void appendRgb(double r, double g, double b, long timestamp) {
    }
    
    @kotlin.jvm.Synchronized()
    @org.jetbrains.annotations.NotNull()
    public final synchronized java.util.List<java.lang.Double> getLatestFilteredWaveform(int count) {
        return null;
    }
    
    @kotlin.jvm.Synchronized()
    @org.jetbrains.annotations.Nullable()
    public final synchronized com.vitalscan.mirror.rppg.VitalMetrics computeVitalMetrics() {
        return null;
    }
    
    private final double[] extractPosPulse(double[] red, double[] green, double[] blue) {
        return null;
    }
    
    private final kotlin.Pair<java.lang.Double, java.lang.Double> calculateHrv(double[] signal) {
        return null;
    }
    
    private final double calculateStdDev(double[] array) {
        return 0.0;
    }
    
    @kotlin.jvm.Synchronized()
    public final synchronized void reset() {
    }
    
    public PosSignalProcessor() {
        super();
    }
}