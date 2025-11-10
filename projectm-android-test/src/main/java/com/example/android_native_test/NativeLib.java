package com.example.android_native_test;

public class NativeLib {

    // Used to load the 'android_native_test' library on application startup.
    static {
        System.loadLibrary("android_native_test");
    }

    /**
     * A native method that is implemented by the 'android_native_test' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();
}