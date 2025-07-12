#!/usr/bin/env python3
# -*- python -*-

import os
import sys


def apply_ips(patch, original, force=False):
    IPS_MAGIC = b'PATCH'
    IPS_EOF = b'EOF'
    if not force:
        assert patch != IPS_MAGIC + IPS_EOF  # Don't apply empty patch
    assert patch[:len(IPS_MAGIC)] == IPS_MAGIC
    assert (patch[-len(IPS_EOF):] ==
            IPS_EOF or patch[-(len(IPS_EOF) + 3):-3] == IPS_EOF)
    changed = original
    BAD_OFFSET = (IPS_EOF[0] << 16) | (IPS_EOF[1] << 8) | IPS_EOF[2]
    cursor = len(IPS_MAGIC) - len(patch)
    next_offset = 0
    while cursor < 0:
        assert cursor <= -3
        block_offset = (patch[cursor] << 16) | (
            patch[cursor + 1] << 8) | patch[cursor + 2]
        if cursor in (-len(IPS_EOF), -(len(IPS_EOF) + 3)):
            assert block_offset == BAD_OFFSET
            cursor += len(IPS_EOF)
            if cursor == -3:
                truncate_length = (patch[cursor] << 16) | (
                    patch[cursor + 1] << 8) | patch[cursor + 2]
                if not force:
                    assert truncate_length >= next_offset  # Don't truncate patched parts
                if not force:
                    # Too short to truncate
                    assert len(changed) >= truncate_length
                changed = changed[:truncate_length]
                cursor = 0
            break
        assert patch[cursor:cursor + len(IPS_EOF)] != IPS_EOF
        if not force:
            assert block_offset >= next_offset  # No out-of-order blocks
        if not force:
            assert block_offset <= len(changed)  # No unmapped gaps
        cursor += 3
        assert cursor <= -(3 + len(IPS_EOF))  # Space for length + byte + EOF
        block_length = (patch[cursor] << 8) | patch[cursor + 1]
        cursor += 2
        if block_length == 0:
            # Space for run length + byte + EOF
            assert cursor <= -(3 + len(IPS_EOF))
            block_length = (patch[cursor] << 8) | patch[cursor + 1]
            cursor += 2
            data = block_length * patch[cursor:cursor + 1]
            cursor += 1
        else:
            assert cursor <= -(block_length + len(IPS_EOF)
                               )  # Space for data + EOF
            data = patch[cursor:cursor + block_length]
            cursor += block_length
        if len(changed) < block_offset:
            changed = changed + (b'\0' * (block_offset - len(changed)))
        if not force:
            assert changed[block_offset:block_offset +
                           block_length] != data  # Already applied?
        changed = changed[:block_offset] + data + \
            changed[block_offset + block_length:]
        next_offset = block_offset + block_length
    assert cursor == 0
    return changed


def main(ips_file_name, original_file_name, changed_file_name, force=False):
    if not force:
        assert os.path.splitext(ips_file_name)[-1].lower() == '.ips'
    patch = open(ips_file_name, 'rb').read()
    original = open(original_file_name, 'rb').read()
    changed = apply_ips(patch, original, force=force)
    open(changed_file_name, 'wb').write(changed)


if __name__ == '__main__':
    force = False
    if sys.argv[1:2] in (['-force'], ['--force']):
        force = True
        try:
            (_, _force, ips_file_name, original_file_name) = sys.argv
            changed_file_name = os.path.join(os.path.split(original_file_name)[0], os.path.splitext(
                os.path.split(ips_file_name)[1])[0] + os.path.splitext(original_file_name)[1])
        except:
            (_, _force, ips_file_name, original_file_name,
             changed_file_name) = sys.argv
        assert _force in ('-force', '--force')
    else:
        try:
            (_, ips_file_name, original_file_name) = sys.argv
            changed_file_name = os.path.join(os.path.split(original_file_name)[0], os.path.splitext(
                os.path.split(ips_file_name)[1])[0] + os.path.splitext(original_file_name)[1])
        except:
            (_, ips_file_name, original_file_name, changed_file_name) = sys.argv
    main(ips_file_name, original_file_name, changed_file_name, force=force)
