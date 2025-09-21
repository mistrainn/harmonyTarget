//
// Created on 2025/9/8.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include "napi/native_api.h" // 引入 NAPI 框架头文件，这是与 ArkTS 通信的桥梁
#include <string>

// ======================= 漏洞点 =======================
// 将一个敏感的密钥字符串直接定义为 C++ 的常量。
// 当编译成 .so 文件后，这个字符串会以明文形式存在于二进制文件中。
static const char* SECRET_KEY = "key_from_native_lib_in_so_file";
// =====================================================

/**
 * @brief 这是我们要暴露给 ArkTS 的原生函数。
 * @param env NAPI 的环境句柄，可以理解为当前的 JS/ArkTS 运行环境。
 * @param info 回调信息，包含函数的入参等。
 * @return 返回一个 napi_value，这是可以在 ArkTS 中使用的数据类型。
 */
static napi_value GetSecretKeyFromNative(napi_env env, napi_callback_info info) {
    napi_value result;
    // 使用 napi_create_string_utf8 函数，将 C++ 的字符串 (const char*) 转换为 ArkTS 可以识别的字符串 (napi_value)。
    napi_create_string_utf8(env, SECRET_KEY, std::string(SECRET_KEY).length(), &result);
    return result;
}

// NAPI 模块初始化函数。当 ArkTS `import` 这个模块时，此函数会被调用。
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    // 定义一个属性描述符，用于描述我们要暴露的函数
    napi_property_descriptor desc[] = {
        // "getSecretKeyFromNative" 是暴露给 ArkTS 的函数名
        // GetSecretKeyFromNative 是上面我们实现的 C++ 函数指针
        { "getSecretKeyFromNative", nullptr, GetSecretKeyFromNative, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    // 将这个属性定义到 `exports` 对象上，这样 ArkTS 就能通过 `exports.getSecretKeyFromNative` 调用了
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

// 定义 NAPI 模块本身
static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init, // 注册初始化函数
    .nm_modname = "entry",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

// 在模块被加载时，调用 napi_module_register 注册我们的模块
extern "C" __attribute__((constructor)) void RegisterModule(void) {
    napi_module_register(&demoModule);
}
