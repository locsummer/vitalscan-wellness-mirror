package com.vitalscan.mirror.rppg;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000&\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0007\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\b6\u0018\u00002\u00020\u0001:\u0006\u0003\u0004\u0005\u0006\u0007\bB\u0007\b\u0004\u00a2\u0006\u0002\u0010\u0002\u0082\u0001\u0006\t\n\u000b\f\r\u000e\u00a8\u0006\u000f"}, d2 = {"Lcom/vitalscan/mirror/rppg/ScannerState;", "", "()V", "Completed", "FaceAligned", "Failed", "Idle", "Measuring", "SearchingFace", "Lcom/vitalscan/mirror/rppg/ScannerState$Completed;", "Lcom/vitalscan/mirror/rppg/ScannerState$FaceAligned;", "Lcom/vitalscan/mirror/rppg/ScannerState$Failed;", "Lcom/vitalscan/mirror/rppg/ScannerState$Idle;", "Lcom/vitalscan/mirror/rppg/ScannerState$Measuring;", "Lcom/vitalscan/mirror/rppg/ScannerState$SearchingFace;", "app_debug"})
public abstract class ScannerState {
    
    private ScannerState() {
        super();
    }
    
    @kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000*\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0006\n\u0002\u0010\u000b\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\b\n\u0000\n\u0002\u0010\u000e\n\u0000\b\u0086\b\u0018\u00002\u00020\u0001B\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0002\u0010\u0004J\t\u0010\u0007\u001a\u00020\u0003H\u00c6\u0003J\u0013\u0010\b\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u0003H\u00c6\u0001J\u0013\u0010\t\u001a\u00020\n2\b\u0010\u000b\u001a\u0004\u0018\u00010\fH\u00d6\u0003J\t\u0010\r\u001a\u00020\u000eH\u00d6\u0001J\t\u0010\u000f\u001a\u00020\u0010H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\b\n\u0000\u001a\u0004\b\u0005\u0010\u0006\u00a8\u0006\u0011"}, d2 = {"Lcom/vitalscan/mirror/rppg/ScannerState$Completed;", "Lcom/vitalscan/mirror/rppg/ScannerState;", "metrics", "Lcom/vitalscan/mirror/rppg/VitalMetrics;", "(Lcom/vitalscan/mirror/rppg/VitalMetrics;)V", "getMetrics", "()Lcom/vitalscan/mirror/rppg/VitalMetrics;", "component1", "copy", "equals", "", "other", "", "hashCode", "", "toString", "", "app_debug"})
    public static final class Completed extends com.vitalscan.mirror.rppg.ScannerState {
        @org.jetbrains.annotations.NotNull()
        private final com.vitalscan.mirror.rppg.VitalMetrics metrics = null;
        
        public Completed(@org.jetbrains.annotations.NotNull()
        com.vitalscan.mirror.rppg.VitalMetrics metrics) {
        }
        
        @org.jetbrains.annotations.NotNull()
        public final com.vitalscan.mirror.rppg.VitalMetrics getMetrics() {
            return null;
        }
        
        @org.jetbrains.annotations.NotNull()
        public final com.vitalscan.mirror.rppg.VitalMetrics component1() {
            return null;
        }
        
        @org.jetbrains.annotations.NotNull()
        public final com.vitalscan.mirror.rppg.ScannerState.Completed copy(@org.jetbrains.annotations.NotNull()
        com.vitalscan.mirror.rppg.VitalMetrics metrics) {
            return null;
        }
        
        @java.lang.Override()
        public boolean equals(@org.jetbrains.annotations.Nullable()
        java.lang.Object other) {
            return false;
        }
        
        @java.lang.Override()
        public int hashCode() {
            return 0;
        }
        
        @java.lang.Override()
        @org.jetbrains.annotations.NotNull()
        public java.lang.String toString() {
            return null;
        }
    }
    
    @kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000\f\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\b\u00c6\u0002\u0018\u00002\u00020\u0001B\u0007\b\u0002\u00a2\u0006\u0002\u0010\u0002\u00a8\u0006\u0003"}, d2 = {"Lcom/vitalscan/mirror/rppg/ScannerState$FaceAligned;", "Lcom/vitalscan/mirror/rppg/ScannerState;", "()V", "app_debug"})
    public static final class FaceAligned extends com.vitalscan.mirror.rppg.ScannerState {
        @org.jetbrains.annotations.NotNull()
        public static final com.vitalscan.mirror.rppg.ScannerState.FaceAligned INSTANCE = null;
        
        private FaceAligned() {
        }
    }
    
    @kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000&\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0002\b\u0006\n\u0002\u0010\u000b\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\b\n\u0002\b\u0002\b\u0086\b\u0018\u00002\u00020\u0001B\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0002\u0010\u0004J\t\u0010\u0007\u001a\u00020\u0003H\u00c6\u0003J\u0013\u0010\b\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u0003H\u00c6\u0001J\u0013\u0010\t\u001a\u00020\n2\b\u0010\u000b\u001a\u0004\u0018\u00010\fH\u00d6\u0003J\t\u0010\r\u001a\u00020\u000eH\u00d6\u0001J\t\u0010\u000f\u001a\u00020\u0003H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\b\n\u0000\u001a\u0004\b\u0005\u0010\u0006\u00a8\u0006\u0010"}, d2 = {"Lcom/vitalscan/mirror/rppg/ScannerState$Failed;", "Lcom/vitalscan/mirror/rppg/ScannerState;", "reason", "", "(Ljava/lang/String;)V", "getReason", "()Ljava/lang/String;", "component1", "copy", "equals", "", "other", "", "hashCode", "", "toString", "app_debug"})
    public static final class Failed extends com.vitalscan.mirror.rppg.ScannerState {
        @org.jetbrains.annotations.NotNull()
        private final java.lang.String reason = null;
        
        public Failed(@org.jetbrains.annotations.NotNull()
        java.lang.String reason) {
        }
        
        @org.jetbrains.annotations.NotNull()
        public final java.lang.String getReason() {
            return null;
        }
        
        @org.jetbrains.annotations.NotNull()
        public final java.lang.String component1() {
            return null;
        }
        
        @org.jetbrains.annotations.NotNull()
        public final com.vitalscan.mirror.rppg.ScannerState.Failed copy(@org.jetbrains.annotations.NotNull()
        java.lang.String reason) {
            return null;
        }
        
        @java.lang.Override()
        public boolean equals(@org.jetbrains.annotations.Nullable()
        java.lang.Object other) {
            return false;
        }
        
        @java.lang.Override()
        public int hashCode() {
            return 0;
        }
        
        @java.lang.Override()
        @org.jetbrains.annotations.NotNull()
        public java.lang.String toString() {
            return null;
        }
    }
    
    @kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000\f\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\b\u00c6\u0002\u0018\u00002\u00020\u0001B\u0007\b\u0002\u00a2\u0006\u0002\u0010\u0002\u00a8\u0006\u0003"}, d2 = {"Lcom/vitalscan/mirror/rppg/ScannerState$Idle;", "Lcom/vitalscan/mirror/rppg/ScannerState;", "()V", "app_debug"})
    public static final class Idle extends com.vitalscan.mirror.rppg.ScannerState {
        @org.jetbrains.annotations.NotNull()
        public static final com.vitalscan.mirror.rppg.ScannerState.Idle INSTANCE = null;
        
        private Idle() {
        }
    }
    
    @kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u00000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0007\n\u0000\n\u0002\u0010\u0006\n\u0002\b\t\n\u0002\u0010\u000b\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\b\n\u0000\n\u0002\u0010\u000e\n\u0000\b\u0086\b\u0018\u00002\u00020\u0001B\u0015\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0005\u00a2\u0006\u0002\u0010\u0006J\t\u0010\u000b\u001a\u00020\u0003H\u00c6\u0003J\t\u0010\f\u001a\u00020\u0005H\u00c6\u0003J\u001d\u0010\r\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u00032\b\b\u0002\u0010\u0004\u001a\u00020\u0005H\u00c6\u0001J\u0013\u0010\u000e\u001a\u00020\u000f2\b\u0010\u0010\u001a\u0004\u0018\u00010\u0011H\u00d6\u0003J\t\u0010\u0012\u001a\u00020\u0013H\u00d6\u0001J\t\u0010\u0014\u001a\u00020\u0015H\u00d6\u0001R\u0011\u0010\u0004\u001a\u00020\u0005\u00a2\u0006\b\n\u0000\u001a\u0004\b\u0007\u0010\bR\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\b\n\u0000\u001a\u0004\b\t\u0010\n\u00a8\u0006\u0016"}, d2 = {"Lcom/vitalscan/mirror/rppg/ScannerState$Measuring;", "Lcom/vitalscan/mirror/rppg/ScannerState;", "progress", "", "currentBpm", "", "(FD)V", "getCurrentBpm", "()D", "getProgress", "()F", "component1", "component2", "copy", "equals", "", "other", "", "hashCode", "", "toString", "", "app_debug"})
    public static final class Measuring extends com.vitalscan.mirror.rppg.ScannerState {
        private final float progress = 0.0F;
        private final double currentBpm = 0.0;
        
        public Measuring(float progress, double currentBpm) {
        }
        
        public final float getProgress() {
            return 0.0F;
        }
        
        public final double getCurrentBpm() {
            return 0.0;
        }
        
        public final float component1() {
            return 0.0F;
        }
        
        public final double component2() {
            return 0.0;
        }
        
        @org.jetbrains.annotations.NotNull()
        public final com.vitalscan.mirror.rppg.ScannerState.Measuring copy(float progress, double currentBpm) {
            return null;
        }
        
        @java.lang.Override()
        public boolean equals(@org.jetbrains.annotations.Nullable()
        java.lang.Object other) {
            return false;
        }
        
        @java.lang.Override()
        public int hashCode() {
            return 0;
        }
        
        @java.lang.Override()
        @org.jetbrains.annotations.NotNull()
        public java.lang.String toString() {
            return null;
        }
    }
    
    @kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000\f\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\b\u00c6\u0002\u0018\u00002\u00020\u0001B\u0007\b\u0002\u00a2\u0006\u0002\u0010\u0002\u00a8\u0006\u0003"}, d2 = {"Lcom/vitalscan/mirror/rppg/ScannerState$SearchingFace;", "Lcom/vitalscan/mirror/rppg/ScannerState;", "()V", "app_debug"})
    public static final class SearchingFace extends com.vitalscan.mirror.rppg.ScannerState {
        @org.jetbrains.annotations.NotNull()
        public static final com.vitalscan.mirror.rppg.ScannerState.SearchingFace INSTANCE = null;
        
        private SearchingFace() {
        }
    }
}