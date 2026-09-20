package com.vitalscan.mirror.camera;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000>\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\b\n\u0002\b\u0004\u0018\u00002\u00020\u0001B\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0002\u0010\u0004J\u0010\u0010\t\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\fH\u0017J \u0010\r\u001a\u00020\u000e2\u0006\u0010\u000f\u001a\u00020\u00102\u0006\u0010\u0011\u001a\u00020\u00122\u0006\u0010\u0013\u001a\u00020\u0012H\u0002J\u0018\u0010\u0014\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\f2\u0006\u0010\u0015\u001a\u00020\u000eH\u0003R\u000e\u0010\u0005\u001a\u00020\u0006X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\bX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000\u00a8\u0006\u0016"}, d2 = {"Lcom/vitalscan/mirror/camera/FaceRoiAnalyzer;", "Landroidx/camera/core/ImageAnalysis$Analyzer;", "listener", "Lcom/vitalscan/mirror/camera/OnFaceRoiExtractedListener;", "(Lcom/vitalscan/mirror/camera/OnFaceRoiExtractedListener;)V", "detector", "Lcom/google/mlkit/vision/face/FaceDetector;", "detectorOptions", "Lcom/google/mlkit/vision/face/FaceDetectorOptions;", "analyze", "", "imageProxy", "Landroidx/camera/core/ImageProxy;", "computeFaceRoi", "Lcom/vitalscan/mirror/rppg/FaceRoiData;", "face", "Lcom/google/mlkit/vision/face/Face;", "imgWidth", "", "imgHeight", "extractRgbFromYuv", "roiData", "app_debug"})
public final class FaceRoiAnalyzer implements androidx.camera.core.ImageAnalysis.Analyzer {
    @org.jetbrains.annotations.NotNull()
    private final com.vitalscan.mirror.camera.OnFaceRoiExtractedListener listener = null;
    @org.jetbrains.annotations.NotNull()
    private final com.google.mlkit.vision.face.FaceDetectorOptions detectorOptions = null;
    @org.jetbrains.annotations.NotNull()
    private final com.google.mlkit.vision.face.FaceDetector detector = null;
    
    public FaceRoiAnalyzer(@org.jetbrains.annotations.NotNull()
    com.vitalscan.mirror.camera.OnFaceRoiExtractedListener listener) {
        super();
    }
    
    @java.lang.Override()
    @androidx.annotation.OptIn(markerClass = {androidx.camera.core.ExperimentalGetImage.class})
    public void analyze(@org.jetbrains.annotations.NotNull()
    androidx.camera.core.ImageProxy imageProxy) {
    }
    
    private final com.vitalscan.mirror.rppg.FaceRoiData computeFaceRoi(com.google.mlkit.vision.face.Face face, int imgWidth, int imgHeight) {
        return null;
    }
    
    @androidx.annotation.OptIn(markerClass = {androidx.camera.core.ExperimentalGetImage.class})
    private final void extractRgbFromYuv(androidx.camera.core.ImageProxy imageProxy, com.vitalscan.mirror.rppg.FaceRoiData roiData) {
    }
}