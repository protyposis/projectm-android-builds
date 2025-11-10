#include <jni.h>
#include <string>
#include <projectM-4/projectM.h>
#include <projectM-4/playlist.h>

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_android_1native_1test_NativeLib_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "Hello from C++";

    // Call both libraries to ensure they are linked correctly
    projectm_handle instance = projectm_create();
    projectm_playlist_handle playlist = projectm_playlist_create(instance);

    return env->NewStringUTF(hello.c_str());
}