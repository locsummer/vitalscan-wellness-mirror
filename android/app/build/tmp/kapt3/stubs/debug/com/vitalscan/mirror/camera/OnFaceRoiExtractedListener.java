package com.vitalscan.mirror.camera;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000&\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u0006\n\u0002\b\u0003\n\u0002\u0010\t\n\u0000\bf\u0018\u00002\u00020\u0001J\u0012\u0010\u0002\u001a\u00020\u00032\b\u0010\u0004\u001a\u0004\u0018\u00010\u0005H&J(\u0010\u0006\u001a\u00020\u00032\u0006\u0010\u0007\u001a\u00020\b2\u0006\u0010\t\u001a\u00020\b2\u0006\u0010\n\u001a\u00020\b2\u0006\u0010\u000b\u001a\u00020\fH&\u00a8\u0006\r"}, d2 = {"Lcom/vitalscan/mirror/camera/OnFaceRoiExtractedListener;", "", "onFaceRoiDetected", "", "roiData", "Lcom/vitalscan/mirror/rppg/FaceRoiData;", "onRgbDataExtracted", "r", "", "g", "b", "timestamp", "", "app_debug"})
public abstract interface OnFaceRoiExtractedListener {
    
    public abstract void onFaceRoiDetected(@org.jetbrains.annotations.Nullable()
    com.vitalscan.mirror.rppg.FaceRoiData roiData);
    
    public abstract void onRgbDataExtracted(double r, double g, double b, long timestamp);
}