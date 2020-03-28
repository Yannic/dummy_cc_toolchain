load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "feature",
    "flag_group",
    "flag_set",
    "tool",
)

# A list of all actions the C/C++/ObjC/ObjC++ toolchain defines tools for.
_all_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cc_flags_make_variable,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.lto_indexing,
    ACTION_NAMES.lto_backend,
    ACTION_NAMES.lto_index_for_executable,
    ACTION_NAMES.lto_index_for_dynamic_library,
    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_static_library,
    ACTION_NAMES.strip,
    ACTION_NAMES.objc_archive,
    ACTION_NAMES.objc_compile,
    ACTION_NAMES.objc_executable,
    ACTION_NAMES.objc_fully_link,
    ACTION_NAMES.objcpp_compile,
    ACTION_NAMES.objcpp_executable,
    ACTION_NAMES.clif_match,
]

def _create_feature(name, enabled = False, flag_sets = []):
    return struct(
        name = name,
        feature = feature(
            name = name,
            enabled = enabled,
            flag_sets = flag_sets,
        ),
    )

def _create_action_config(action_name, tool_path):
    return action_config(
        action_name = action_name,
        enabled = True,
        tools = [
            tool(
                path = tool_path,
            ),
        ],
    )

def _create_action_configs(action_names, tool_path):
    return [_create_action_config(name, tool_path) for name in action_names]

def _dummy_cc_toolchain_config_impl(ctx):
    source_file_feature = _create_feature(
        name = "source_file_feature",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = _all_actions,
                flag_groups = [
                    flag_group(
                        flags = ["--source_file", "%{source_file}"],
                        expand_if_available = "source_file",
                    ),
                ],
            ),
        ],
    )

    output_file_feature = _create_feature(
        name = "output_file_feature",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = _all_actions,
                flag_groups = [
                    flag_group(
                        flags = ["--output_file", "%{output_file}"],
                        expand_if_available = "output_file",
                    ),
                    flag_group(
                        flags = ["--output_file", "%{output_execpath}"],
                        expand_if_available = "output_execpath",
                    ),
                ],
            ),
        ],
    )

    dependency_file_feature = _create_feature(
        name = "dependency_file_feature",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = _all_actions,
                flag_groups = [
                    flag_group(
                        flags = ["--dependency_file", "%{dependency_file}"],
                        expand_if_available = "dependency_file",
                    ),
                ],
            ),
        ],
    )

    tool_path = "/bin/echo"  # "/usr/local/bin/clang"
    tci = cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "dummy",
        host_system_name = "dummy",
        target_system_name = "dummy",
        target_cpu = "dummy",
        target_libc = "dummy",
        compiler = "dummy",
        abi_version = "dummy",
        abi_libc_version = "dummy",
        features = [
            feature(name = "no_legacy_features"),
            source_file_feature.feature,
            output_file_feature.feature,
            dependency_file_feature.feature,
        ],
        action_configs = _create_action_configs(_all_actions, tool_path),
    )
    return [
        tci,
    ]

dummy_cc_toolchain_config = rule(
    implementation = _dummy_cc_toolchain_config_impl,
    provides = [
        CcToolchainConfigInfo,
    ],
)
