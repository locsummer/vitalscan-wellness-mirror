package com.vitalscan.mirror;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000@\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u000b\n\u0002\b\b\n\u0002\u0018\u0002\n\u0002\b\u0005\n\u0002\u0018\u0002\n\u0002\u0010\u000e\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0010\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\u0018\u00002\u00020\u0001:\u0001 B\u0005\u00a2\u0006\u0002\u0010\u0002J\b\u0010\u001b\u001a\u00020\u001cH\u0002J\u0012\u0010\u001d\u001a\u00020\u001c2\b\u0010\u001e\u001a\u0004\u0018\u00010\u001fH\u0014R+\u0010\u0005\u001a\u00020\u00042\u0006\u0010\u0003\u001a\u00020\u00048B@BX\u0082\u008e\u0002\u00a2\u0006\u0012\n\u0004\b\n\u0010\u000b\u001a\u0004\b\u0006\u0010\u0007\"\u0004\b\b\u0010\tR\u001b\u0010\f\u001a\u00020\r8BX\u0082\u0084\u0002\u00a2\u0006\f\n\u0004\b\u0010\u0010\u0011\u001a\u0004\b\u000e\u0010\u000fR\u001c\u0010\u0012\u001a\u0010\u0012\f\u0012\n \u0015*\u0004\u0018\u00010\u00140\u00140\u0013X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u001b\u0010\u0016\u001a\u00020\u00178BX\u0082\u0084\u0002\u00a2\u0006\f\n\u0004\b\u001a\u0010\u0011\u001a\u0004\b\u0018\u0010\u0019\u00a8\u0006!"}, d2 = {"Lcom/vitalscan/mirror/MainActivity;", "Landroidx/activity/ComponentActivity;", "()V", "<set-?>", "", "hasCameraPermission", "getHasCameraPermission", "()Z", "setHasCameraPermission", "(Z)V", "hasCameraPermission$delegate", "Landroidx/compose/runtime/MutableState;", "historyViewModel", "Lcom/vitalscan/mirror/viewmodel/HistoryViewModel;", "getHistoryViewModel", "()Lcom/vitalscan/mirror/viewmodel/HistoryViewModel;", "historyViewModel$delegate", "Lkotlin/Lazy;", "requestPermissionLauncher", "Landroidx/activity/result/ActivityResultLauncher;", "", "kotlin.jvm.PlatformType", "scannerViewModel", "Lcom/vitalscan/mirror/viewmodel/ScannerViewModel;", "getScannerViewModel", "()Lcom/vitalscan/mirror/viewmodel/ScannerViewModel;", "scannerViewModel$delegate", "checkCameraPermission", "", "onCreate", "savedInstanceState", "Landroid/os/Bundle;", "Screen", "app_debug"})
public final class MainActivity extends androidx.activity.ComponentActivity {
    @org.jetbrains.annotations.NotNull()
    private final kotlin.Lazy scannerViewModel$delegate = null;
    @org.jetbrains.annotations.NotNull()
    private final kotlin.Lazy historyViewModel$delegate = null;
    @org.jetbrains.annotations.NotNull()
    private final androidx.compose.runtime.MutableState hasCameraPermission$delegate = null;
    @org.jetbrains.annotations.NotNull()
    private final androidx.activity.result.ActivityResultLauncher<java.lang.String> requestPermissionLauncher = null;
    
    public MainActivity() {
        super();
    }
    
    private final com.vitalscan.mirror.viewmodel.ScannerViewModel getScannerViewModel() {
        return null;
    }
    
    private final com.vitalscan.mirror.viewmodel.HistoryViewModel getHistoryViewModel() {
        return null;
    }
    
    private final boolean getHasCameraPermission() {
        return false;
    }
    
    private final void setHasCameraPermission(boolean p0) {
    }
    
    @java.lang.Override()
    protected void onCreate(@org.jetbrains.annotations.Nullable()
    android.os.Bundle savedInstanceState) {
    }
    
    private final void checkCameraPermission() {
    }
    
    @kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000\f\n\u0002\u0018\u0002\n\u0002\u0010\u0010\n\u0002\b\u0004\b\u0086\u0081\u0002\u0018\u00002\b\u0012\u0004\u0012\u00020\u00000\u0001B\u0007\b\u0002\u00a2\u0006\u0002\u0010\u0002j\u0002\b\u0003j\u0002\b\u0004\u00a8\u0006\u0005"}, d2 = {"Lcom/vitalscan/mirror/MainActivity$Screen;", "", "(Ljava/lang/String;I)V", "Scanner", "History", "app_debug"})
    public static enum Screen {
        /*public static final*/ Scanner /* = new Scanner() */,
        /*public static final*/ History /* = new History() */;
        
        Screen() {
        }
        
        @org.jetbrains.annotations.NotNull()
        public static kotlin.enums.EnumEntries<com.vitalscan.mirror.MainActivity.Screen> getEntries() {
            return null;
        }
    }
}