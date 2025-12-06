#!/usr/bin/env python3
"""
Fix kernel build issues for Ubuntu 24.04 / glibc 2.38+
"""
import re

def fix_strlcpy():
    """Fix strlcpy redeclaration for glibc 2.38+"""
    file_path = "linux-5.4/tools/include/linux/string.h"

    with open(file_path, 'r') as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        new_lines.append(line)
        if '#if defined(__GLIBC__) && !defined(__UCLIBC__)' in line:
            new_lines.append('#if !__GLIBC_PREREQ(2, 38)\n')
        elif 'extern size_t strlcpy' in line:
            new_lines.append('#endif\n')

    with open(file_path, 'w') as f:
        f.writelines(new_lines)

    print("[+] Fixed strlcpy redeclaration")

def fix_xrealloc():
    """Fix use-after-free in xrealloc function"""
    file_path = "linux-5.4/tools/lib/subcmd/subcmd-util.h"

    with open(file_path, 'r') as f:
        content = f.read()

    # Match and replace entire xrealloc function including nested braces
    # Need to match from function start to its closing brace properly
    pattern = r'static inline void \*xrealloc\(void \*ptr, size_t size\)\s*\{(?:[^{}]|\{[^}]*\})*\}'

    new_func = '''static inline void *xrealloc(void *ptr, size_t size)
{
\tvoid *ret = ptr ? realloc(ptr, size ? size : 1) : malloc(size ? size : 1);
\tif (!ret) {
\t\tdie("Out of memory, realloc failed");
\t}
\treturn ret;
}'''

    # Use re.DOTALL and count to ensure we only replace once
    content = re.sub(pattern, new_func, content, count=1, flags=re.DOTALL)

    with open(file_path, 'w') as f:
        f.write(content)

    print("[+] Fixed xrealloc use-after-free")

if __name__ == '__main__':
    fix_strlcpy()
    fix_xrealloc()
