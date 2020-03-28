def _transition_impl(settings, attr):
    return {"//command_line_option:cpu": "dummy"}

build_in_debug_mode = transition(
    implementation = _transition_impl,
    inputs = [],
    outputs = ["//command_line_option:cpu"],
)

def _impl(ctx):
    return [
        DefaultInfo(
            files = depset(ctx.files.deps),
        ),
    ]

foo = rule(
    implementation = _impl,
    attrs = {
        "deps": attr.label_list(
            mandatory = True,
            providers = [CcInfo],
        ),
        "_whitelist_function_transition": attr.label(
            default = "@bazel_tools//tools/whitelists/function_transition_whitelist",
        ),
    },
    cfg = build_in_debug_mode,
)
