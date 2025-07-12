#!/usr/bin/env python3

from collections import namedtuple

import codecs
import os.path
import struct
import sys

RamRelocation = namedtuple('RamRelocation', ('relocation_offset', 'referenced_line_pointer',
                           'containing_line', 'relocation_text_offset', 'relocation_text_token'))

RomRelocation = namedtuple(
    'RomRelocation', ('relocation_offset', 'referenced_line', 'containing_line'))


def basfloat_to_str(b):
    """
    Converts BASIC BCD floating-point to string.
    It will blindly convert values that do not round-trip or aren't even BCD, similarly to STR$().
    If too few bytes are given it will pad with 0x00 bytes.
    Some of the returned conversions containing 'E' are ambiguous as to whether the number was stored as single-precision or double-precision.
    We could show exponent -65 as plain unsigned zero as BASIC sometimes does, but choose not to so that data may be seen less ambiguously.
    """
    while len(b) < 8 and len(b) != 4:
        b += b'\x00'
    assert len(b) in (4, 8)
    format_disambiguator = '!#'[len(b) == 8]
    sign_and_biased_exponent, hex_mantissa = ord(
        b[:1]), codecs.encode(b[1:], 'hex').decode('iso-8859-1')
    sign_prefix = '-'[:sign_and_biased_exponent >= 0x80]
    exponent = (sign_and_biased_exponent & 0x7f) - 65
    decimal_mantissa = ''.join(chr(0x30 + int(digit, 16))
                               for digit in hex_mantissa)
    if exponent > -3 and exponent < 14:
        decimal_mantissa, exponent = ('000'+decimal_mantissa+'00000000000000')[
            :4+exponent] + '.' + ('000'+decimal_mantissa+'00000000000000')[4+exponent:], 0
        while decimal_mantissa[:1] == '0':
            decimal_mantissa = decimal_mantissa[1:]
        while decimal_mantissa[-1:] == '0':
            decimal_mantissa = decimal_mantissa[:-1]
    else:
        decimal_mantissa = decimal_mantissa[:1] + '.' + decimal_mantissa[1:]
    while decimal_mantissa[-1:] == '0' and '.' in decimal_mantissa:
        decimal_mantissa = decimal_mantissa[:-1]
    if decimal_mantissa[-1:] == '.':
        decimal_mantissa = decimal_mantissa[:-1]
    if decimal_mantissa == '0' and sign_prefix == '':
        exponent = 0
    while exponent != 0 and len(''.join(decimal_mantissa.lstrip('0').split('.'))) < 7 and format_disambiguator == '#':
        if '.' not in decimal_mantissa:
            decimal_mantissa += '.'
        decimal_mantissa += '0'
    return sign_prefix + decimal_mantissa + (('E' + '-+'[exponent > 0] + ('%02d' % abs(exponent))) if exponent != 0 else format_disambiguator[:('.' not in decimal_mantissa) or (format_disambiguator == '#')])


def test_basfloat():
    basfloat_test_expectations = {
        '00000000': '0!',
        '0000000000000000': '0#',
        '0000000000000001': '0.0000000000001E-65',
        '00000001': '0.00001E-65',
        '0000000100000000': '0.0000100E-65',
        '00100000': '1E-65',
        '0010000000000000': '1.000000E-65',
        '01100000': '1E-64',
        '0110000000000000': '1.000000E-64',
        '01234567': '2.34567E-64',
        '0123456700000000': '2.345670E-64',
        '0123456789ABCDEF': '2.3456789:;<=>?E-64',
        '11111111': '1.11111E-48',
        '1111111100000000': '1.111110E-48',
        '1111111111111111': '1.1111111111111E-48',
        '2020202020202020': '2.020202020202E-33',
        '3E100000': '1E-03',
        '3E10000000000000': '1.000000E-03',
        '3E999999': '9.99999E-03',
        '3E99999900000000': '9.999990E-03',
        '3E99999999999999': '9.9999999999999E-03',
        '3F100000': '.01',
        '3F10000000000000': '.01#',
        '40100000': '.1',
        '4010000000000000': '.1#',
        '40999999': '.999999',
        '4099999900000000': '.999999#',
        '4099999999999999': '.99999999999999#',
        '41100000': '1!',
        '4110000000000000': '1#',
        '41900000': '9!',
        '4190000000000000': '9#',
        '41999999': '9.99999',
        '4199999900000000': '9.99999#',
        '4199999999999999': '9.9999999999999#',
        '43123123': '123.123',
        '4312312300000000': '123.123#',
        '4312312345678901': '123.12345678901#',
        '46123456': '123456!',
        '4612345600000000': '123456#',
        '4612345612345678': '123456.12345678#',
        '46999999': '999999!',
        '4699999900000000': '999999#',
        '47100000': '1000000!',
        '4710000000000000': '1000000#',
        '4710000010000000': '1000001#',
        '4E100000': '10000000000000!',
        '4E10000000000000': '10000000000000#',
        '4E999999': '99999900000000!',
        '4E99999900000000': '99999900000000#',
        '4E99999999999999': '99999999999999#',
        '4F100000': '1E+14',
        '4F10000000000000': '1.000000E+14',
        '4F10000000000001': '1.0000000000001E+14',
        '60272C2E60272C2E': '2.72<2>60272<2>E+31',
        '7975636B': '7.5636;E+56',
        '7F7F7F7F': '7.?7?7?E+62',
        '7F7F7F7F00000000': '7.?7?7?0E+62',
        '7F7F7F7F7F7F7F7F': '7.?7?7?7?7?7?7?E+62',
        '7F999999': '9.99999E+62',
        '7F99999900000000': '9.999990E+62',
        '7F99999999999999': '9.9999999999999E+62',
        '7FFFFFFF': '?.?????E+62',
        '7FFFFFFF00000000': '?.?????0E+62',
        '7FFFFFFFFFFFFFFF': '?.?????????????E+62',
        '80000000': '-0E-65',
        '8000000000000000': '-0.0000000E-65',
        '8000000000000001': '-0.0000000000001E-65',
        '80000001': '-0.00001E-65',
        '8000000100000000': '-0.0000100E-65',
        '80100000': '-1E-65',
        '8010000000000000': '-1.000000E-65',
        '81100000': '-1E-64',
        '8110000000000000': '-1.000000E-64',
        '99999999': '-9.99999E-40',
        '9999999900000000': '-9.999990E-40',
        '9999999999999999': '-9.9999999999999E-40',
        'BE100000': '-1E-03',
        'BE10000000000000': '-1.000000E-03',
        'BE999999': '-9.99999E-03',
        'BE99999900000000': '-9.999990E-03',
        'BE99999999999999': '-9.9999999999999E-03',
        'BF100000': '-.01',
        'BF10000000000000': '-.01#',
        'C0100000': '-.1',
        'C010000000000000': '-.1#',
        'C0999999': '-.999999',
        'C099999900000000': '-.999999#',
        'C099999999999999': '-.99999999999999#',
        'C1100000': '-1!',
        'C110000000000000': '-1#',
        'C1900000': '-9!',
        'C190000000000000': '-9#',
        'C1999999': '-9.99999',
        'C199999900000000': '-9.99999#',
        'C199999999999999': '-9.9999999999999#',
        'C3123123': '-123.123',
        'C312312300000000': '-123.123#',
        'C312312345678901': '-123.12345678901#',
        'C6123456': '-123456!',
        'C612345600000000': '-123456#',
        'C612345612345678': '-123456.12345678#',
        'C6999999': '-999999!',
        'C699999900000000': '-999999#',
        'C7100000': '-1000000!',
        'C710000000000000': '-1000000#',
        'C710000010000000': '-1000001#',
        'CCCCCCCCCCCCCCCC': '-<<<<<<<<<<<<.<<#',
        'CE100000': '-10000000000000!',
        'CE10000000000000': '-10000000000000#',
        'CE999999': '-99999900000000!',
        'CE99999900000000': '-99999900000000#',
        'CE99999999999999': '-99999999999999#',
        'CF100000': '-1E+14',
        'CF10000000000000': '-1.000000E+14',
        'CF10000000000001': '-1.0000000000001E+14',
        'FF999999': '-9.99999E+62',
        'FF99999900000000': '-9.999990E+62',
        'FF99999999999999': '-9.9999999999999E+62',
        'FFFFFFFF': '-?.?????E+62',
        'FFFFFFFF00000000': '-?.?????0E+62',
        'FFFFFFFFFFFFFFFF': '-?.?????????????E+62',
    }
    basfloat_test_failures = {
        basfloat_hex: results
        for (basfloat_hex, results) in
        {
            basfloat_hex: dict(
                actual=basfloat_to_str(codecs.decode(basfloat_hex, 'hex')),
                expected=expected,
            )
            for (basfloat_hex, expected) in basfloat_test_expectations.items()
        }.items()
        if results['actual'] != results['expected']
    }
    assert not basfloat_test_failures, basfloat_test_failures


def basld(load_addr, bas, verbose=True):
    """
    Converts BASIC token stream from serialized format to runtime
    format relocated to the given load address, and also outputs a
    text serialization. In can also relocate a token stream that is
    already in memory format.
    """
    assert load_addr == int(load_addr)
    load_addr = int(load_addr)
    assert load_addr >= 0x8000
    assert load_addr < 0xFFFF
    # sanity check: serialized tokenized BASIC on disk starts with a single 0xFF byte; in memory it starts with a single 0x00 byte
    assert bas[:1] in b'\x00\xff'
    line_map = {}
    line_unmap = {}
    ram_relocations = []
    rom_relocations = []
    ram_start = None
    ram_address = None
    previous_line_number = None
    previous_line_start = 0
    bld = b'\x00'  # tokenized BASIC loaded into RAM or ROM always begins with a single 0x00 byte
    text = ''
    while True:
        next_ram_address, = struct.unpack('<H', bas[len(bld):2+len(bld)])
        if ram_address is not None:
            previous_ram_address = ram_address - \
                (len(bld) - previous_line_start)
            if ram_start is None:
                ram_start = previous_ram_address - len(bld)
            line_unmap[previous_ram_address - 1] = previous_line_number
        if next_ram_address == 0x0000:
            bld += struct.pack('<H', next_ram_address)
            if (len(bas) > len(bld)) and bas[:1] == '\xff':
                print(
                    'Extra bytes after token stream in serialized tokenized BASIC disk format')
            bld += bas[len(bld):]
            text += '\x1a'
            break
        assert next_ram_address >= 0x8000 and next_ram_address < 0xFFFF, "next_ram_address = 0x%(next_ram_address)x should be 0x8000 or higher" % {
            'next_ram_address': next_ram_address}
        if ram_address is not None:
            assert next_ram_address > ram_address
        line_number, = struct.unpack('<H', bas[2+len(bld):4+len(bld)])
        text += str(line_number) + ' '
        if previous_line_number is not None:
            assert line_number >= previous_line_number
        previous_line_number = line_number
        previous_line_start = len(bld)
        line_map[line_number] = len(bld) - 1
        offset = 4+len(bld)
        reference_type = None
        multiple_reference_possible = False
        do_not_resolve = False
        zero_means_off = False
        while True:
            token = bas[offset:1+offset]
            if bas[:1] == b'\xFF':
                assert token != b'\x0D'  # RAM relocation should not be present in serialized input
            offset += 1
            if token == b':':
                reference_type = None
                multiple_reference_possible = False
                do_not_resolve = False
                zero_means_off = False
            if token == b'\xFF':
                token += bas[offset:1+offset]
                offset += 1
            elif token == b':' and bas[offset:offset+2] == b'\x8f\xe6':
                token += bas[offset:2+offset]
                offset += 2
            elif token == b':' and bas[offset:offset+1] == b'\xa1':
                token += bas[offset:1+offset]
                offset += 1
            elif token == b'\xa1':
                text += '\b'  # not quite right, but as close as we can easily get
            text_token = {
                b'\x00': '\r\n',
                b'\x0B': '&O%o' % struct.unpack('<H', bas[offset:2+offset]),
                b'\x0C': '&H%X' % struct.unpack('<H', bas[offset:2+offset]),
                b'\x0D': '\N{right-pointing magnifying glass}\N{fullwidth left white parenthesis}@ 0x%X\N{fullwidth right white parenthesis}' % struct.unpack('<H', bas[offset:2+offset]),
                b'\x0E': '%u' % struct.unpack('<H', bas[offset:2+offset]),
                b'\x0F': '%u' % ord(bas[offset:1+offset]),
                b'\x11': '0',
                b'\x12': '1',
                b'\x13': '2',
                b'\x14': '3',
                b'\x15': '4',
                b'\x16': '5',
                b'\x17': '6',
                b'\x18': '7',
                b'\x19': '8',
                b'\x1a': '9',
                b'\x1c': '%d' % struct.unpack('<h', bas[offset:2+offset]),
                b'\x1d': basfloat_to_str(bas[offset:4+offset]),
                b'\x1f': basfloat_to_str(bas[offset:8+offset]),
                b':\x8F\xE6': "'",
                b':\xA1': 'ELSE',
                b'\x81': 'END',
                b'\x82': 'FOR',
                b'\x83': 'NEXT',
                b'\x84': 'DATA',
                b'\x85': 'INPUT',
                b'\x86': 'DIM',
                b'\x87': 'READ',
                b'\x88': 'LET',
                b'\x89': 'GOTO',
                b'\x8A': 'RUN',
                b'\x8B': 'IF',
                b'\x8C': 'RESTORE',
                b'\x8D': 'GOSUB',
                b'\x8E': 'RETURN',
                b'\x8F': 'REM',
                b'\x90': 'STOP',
                b'\x91': 'PRINT',
                b'\x92': 'CLEAR',
                b'\x93': 'LIST',
                b'\x94': 'NEW',
                b'\x95': 'ON',
                b'\x96': 'WAIT',
                b'\x97': 'DEF',
                b'\x98': 'POKE',
                b'\x99': 'CONT',
                b'\x9A': 'CSAVE',
                b'\x9B': 'CLOAD',
                b'\x9C': 'OUT',
                b'\x9D': 'LPRINT',
                b'\x9E': 'LLIST',
                b'\x9F': 'CLS',
                b'\xA0': 'WIDTH',
                b'\xA1': 'ELSE',  # this should not happen, b':\xA1' is the canonical form
                b'\xA2': 'TRON',
                b'\xA3': 'TROFF',
                b'\xA4': 'SWAP',
                b'\xA5': 'ERASE',
                b'\xA6': 'ERROR',
                b'\xA7': 'RESUME',
                b'\xA8': 'DELETE',
                b'\xA9': 'AUTO',
                b'\xAA': 'RENUM',
                b'\xAB': 'DEFSTR',
                b'\xAC': 'DEFINT',
                b'\xAD': 'DEFSNG',
                b'\xAE': 'DEFDBL',
                b'\xAF': 'LINE',
                b'\xB0': 'OPEN',
                b'\xB1': 'FIELD',
                b'\xB2': 'GET',
                b'\xB3': 'PUT',
                b'\xB4': 'CLOSE',
                b'\xB5': 'LOAD',
                b'\xB6': 'MERGE',
                b'\xB7': 'FILES',
                b'\xB8': 'LSET',
                b'\xB8': 'LSET',
                b'\xB9': 'RSET',
                b'\xBA': 'SAVE',
                b'\xBB': 'LFILES',
                b'\xBC': 'CIRCLE',
                b'\xBD': 'COLOR',
                b'\xBE': 'DRAW',
                b'\xBF': 'PAINT',
                b'\xC0': 'BEEP',
                b'\xC1': 'PLAY',
                b'\xC2': 'PSET',
                b'\xC3': 'PRESET',
                b'\xC4': 'SOUND',
                b'\xC5': 'SCREEN',
                b'\xC6': 'VPOKE',
                b'\xC7': 'SPRITE',
                b'\xC8': 'VDP',
                b'\xC9': 'BASE',
                b'\xCA': 'CALL',
                b'\xCB': 'TIME',
                b'\xCC': 'KEY',
                b'\xCD': 'MAX',
                b'\xCE': 'MOTOR',
                b'\xCF': 'BLOAD',
                b'\xD0': 'BSAVE',
                b'\xD1': 'DSKO$',
                b'\xD2': 'SET',
                b'\xD3': 'NAME',
                b'\xD4': 'KILL',
                b'\xD5': 'IPL',
                b'\xD6': 'COPY',
                b'\xD7': 'CMD',
                b'\xD8': 'LOCATE',
                b'\xD9': 'TO',
                b'\xDA': 'THEN',
                b'\xDB': 'TAB(',
                b'\xDC': 'STEP',
                b'\xDD': 'USR',
                b'\xDE': 'FN',
                b'\xDF': 'SPC(',
                b'\xE0': 'NOT',
                b'\xE1': 'ERL',
                b'\xE2': 'ERR',
                b'\xE3': 'STRING$',
                b'\xE4': 'USING',
                b'\xE5': 'INSTR',
                b'\xE7': 'VARPTR',
                b'\xE8': 'CSRLIN',
                b'\xE9': 'ATTR$',
                b'\xEA': 'DSKI$',
                b'\xEB': 'OFF',
                b'\xEC': 'INKEY$',
                b'\xED': 'POINT',
                b'\xEE': '>',
                b'\xEF': '=',
                b'\xF0': '<',
                b'\xF1': '+',
                b'\xF2': '-',
                b'\xF3': '*',
                b'\xF4': '/',
                b'\xF5': '^',
                b'\xF6': 'AND',
                b'\xF7': 'OR',
                b'\xF8': 'XOR',
                b'\xF9': 'EQV',
                b'\xFA': 'IMP',
                b'\xFB': 'MOD',
                b'\xFC': '\\',
                b'\xFF\x81': 'LEFT$',
                b'\xFF\x82': 'RIGHT$',
                b'\xFF\x83': 'MID$',
                b'\xFF\x84': 'SGN',
                b'\xFF\x85': 'INT',
                b'\xFF\x86': 'ABS',
                b'\xFF\x87': 'SQR',
                b'\xFF\x88': 'RND',
                b'\xFF\x89': 'SIN',
                b'\xFF\x8A': 'LOG',
                b'\xFF\x8B': 'EXP',
                b'\xFF\x8C': 'COS',
                b'\xFF\x8D': 'TAN',
                b'\xFF\x8E': 'ATN',
                b'\xFF\x8F': 'FRE',
                b'\xFF\x90': 'INP',
                b'\xFF\x91': 'POS',
                b'\xFF\x92': 'LEN',
                b'\xFF\x93': 'STR$',
                b'\xFF\x94': 'VAL',
                b'\xFF\x95': 'ASC',
                b'\xFF\x96': 'CHR$',
                b'\xFF\x97': 'PEEK',
                b'\xFF\x98': 'VPEEK',
                b'\xFF\x99': 'SPACE$',
                b'\xFF\x9A': 'OCT$',
                b'\xFF\x9B': 'HEX$',
                b'\xFF\x9C': 'LPOS',
                b'\xFF\x9D': 'BIN$',
                b'\xFF\x9E': 'CINT',
                b'\xFF\x9F': 'CSNG',
                b'\xFF\xA0': 'CDBL',
                b'\xFF\xA1': 'FIX',
                b'\xFF\xA2': 'STICK',
                b'\xFF\xA3': 'STRIG',
                b'\xFF\xA4': 'PDL',
                b'\xFF\xA5': 'PAD',
                b'\xFF\xA6': 'DSKF',
                b'\xFF\xA7': 'FPOS',
                b'\xFF\xA8': 'CVI',
                b'\xFF\xA9': 'CVS',
                b'\xFF\xAA': 'CVD',
                b'\xFF\xAB': 'EOF',
                b'\xFF\xAC': 'LOC',
                b'\xFF\xAD': 'LOF',
                b'\xFF\xAE': 'MKI$',
                b'\xFF\xAF': 'MKS$',
                b'\xFF\xB0': 'MKD$',
            }.get(token, token.decode('iso-8859-1'))
            text += text_token
            is_possible_reference = False
            next_reference_type = None
            if text_token == '\r\n':
                # end of line
                break
            elif text_token == 'ON':
                multiple_reference_possible = True
                do_not_resolve = False
            elif text_token == 'SPRITE' and multiple_reference_possible:
                # ON SPRITE GOSUB does not work with resolved line numbers
                do_not_resolve = True
            elif text_token == 'ERROR':
                if multiple_reference_possible:
                    multiple_reference_possible = False
                    zero_means_off = True
            elif text_token == ' ':
                next_reference_type = reference_type
            elif text_token == ',':
                next_reference_type = reference_type if multiple_reference_possible else None
            elif (text_token in ('REM', "'")) and (token != b"'"):
                while bas[offset:1+offset] != b'\x00':
                    text += chr(ord(bas[offset:1+offset]))
                    offset += 1
            elif text_token in ('_', 'CALL', 'DATA'):
                # note that regular parsing of DATA and READ's parsing
                # of DATA work differently. this tries to mimic
                # regular parsing.
                while bas[offset:1+offset] not in b'\x00:':
                    text += chr(ord(bas[offset:1+offset]))
                    offset += 1
                    if text[-1:] == '"':
                        while bas[offset:1+offset] not in b'\x00"':
                            text += chr(ord(bas[offset:1+offset]))
                            offset += 1
                        if bas[offset:1+offset] == b'"':
                            text += '"'
                            offset += 1
            elif token == b'"':
                while bas[offset:1+offset] not in b'\x00"':
                    text += chr(ord(bas[offset:1+offset]))
                    offset += 1
                if bas[offset:1+offset] == b'"':
                    text += '"'
                    offset += 1
            elif token in b'\x0B\x0C\x1C':
                assert reference_type is None  # not a line number reference
                # non-line number integer in word format. signed, but non-decimal bases are displayed unsigned.
                offset += 2
            elif token == b'\x0D':
                # line number reference (RAM)
                assert reference_type is not None
                line_pointer_value, = struct.unpack('<H', bas[offset:2+offset])
                offset += 2
                ram_relocations.append(RamRelocation(relocation_offset=offset-3, referenced_line_pointer=line_pointer_value,
                                       containing_line=line_number, relocation_text_offset=len(text) - len(text_token), relocation_text_token=text_token))
                # some reference tokens allow multiple line numbers with commas
                next_reference_type = reference_type if multiple_reference_possible else None
            elif token == b'\x0E':
                # line number reference (unresolved)
                assert reference_type is not None
                decimal_unsigned_integer_value, = struct.unpack(
                    '<H', bas[offset:2+offset])
                offset += 2
                if (reference_type == 'RESTORE') or do_not_resolve or (zero_means_off and decimal_unsigned_integer_value == 0):
                    # RESTORE references do not work when resolved
                    # ON SPRITE GOSUB references do not work when resolved
                    # ON ERROR GOTO 0 does not actually jump to zero even if line 0 exists
                    pass
                else:
                    rom_relocations.append(RomRelocation(
                        relocation_offset=offset-3, referenced_line=decimal_unsigned_integer_value, containing_line=line_number))
                # some reference tokens allow multiple line numbers with commas
                next_reference_type = reference_type if multiple_reference_possible else None
            elif token in b'\x0F':
                assert reference_type is None  # not a line number reference
                # non-line number unsigned integer in unsigned-word format
                offset += 1
            elif token >= b'\x11' and token <= b'\x1A':
                assert reference_type is None  # not a line number reference
                # small decimal unsigned integer in bias-0x11 format
            elif token == b'\x1D':
                assert reference_type is None  # not a line number reference
                # four-byte single-precision float
                offset += 4
            elif token == b'\x1F':
                assert reference_type is None  # not a line number reference
                # eight-byte double-precision float
                offset += 8
            elif text_token in (
                    'AUTO',
                    'DELETE',
                    'ELSE',
                    'GOSUB',
                    'GOTO',
                    'LIST',
                    'LLIST',
                    'RENUM',
                    'RESTORE',
                    'RESUME',
                    'RETURN',
                    'RUN',
                    'THEN',
            ):
                # tokens possibly followed by one or more line references
                next_reference_type = text_token
            reference_type = next_reference_type
            pass
        assert text.endswith('\r\n')
        if ram_address is None:
            ram_address = next_ram_address - (offset - len(bld))
        if ram_start is None:
            ram_start = ram_address - len(bld)
        for i in range(len(ram_relocations))[::-1]:
            # process last-to-first to simplify text patching
            relocation_offset, referenced_line_pointer, containing_line, relocation_text_offset, relocation_text_token = ram_relocations[
                i]
            if containing_line != line_number:
                break
            if referenced_line_pointer < ram_start or referenced_line_pointer > (ram_start + len(bas) - 3):
                continue
            resolved_line, = struct.unpack(
                '<H', bas[referenced_line_pointer - ram_start + 3:][:2])
            if referenced_line_pointer in line_unmap:
                assert resolved_line == line_unmap[referenced_line_pointer]
            old_relocation_text_token = relocation_text_token
            relocation_text_token = str(resolved_line)
            text = text[:relocation_text_offset] + relocation_text_token + \
                text[relocation_text_offset + len(old_relocation_text_token):]
            relocation_text_token_size_delta = len(
                relocation_text_token) - len(old_relocation_text_token)
            ram_relocations[i] = ram_relocations[i]._replace(
                relocation_text_token=relocation_text_token)
            for j in range(i + 1, len(ram_relocations)):
                ram_relocations[j] = ram_relocations[j]._replace(
                    relocation_text_offset=ram_relocations[j].relocation_text_offset + relocation_text_token_size_delta)
        if verbose:
            print(('0x%04X' + ['\N{rightwards arrow}0x%04X' % (load_addr + len(bld)), '']
                  [ram_address == (load_addr + len(bld))] + ':') % ram_address, text.split('\r\n')[-2])
        line_unmap[(
            ram_address if ram_address is not None else next_ram_address - offset) - 1] = line_number
        if ram_address is not None:
            assert next_ram_address == ram_address + (offset - len(bld)), 'next_ram_address 0x%(next_ram_address)x should be == 0x%(expected_next_ram_address)x, i.e. ram_address 0x%(ram_address)x + (%(delta)x, i.e. offset 0x%(offset)x - len(bld) 0x%(len_bld)x)' % dict(
                next_ram_address=next_ram_address, expected_next_ram_address=ram_address + (offset - len(bld)), ram_address=ram_address, delta=offset - len(bld), offset=offset, len_bld=len(bld))
        ram_address = next_ram_address
        bld += struct.pack('<HH', offset + load_addr,
                           line_number) + bas[4+len(bld):offset]
    assert len(bas) == len(bld)
    unresolved_ram_relocations = 0
    while len(ram_relocations):
        # process last-to-first to simplify text patching
        relocation_offset, referenced_line_pointer, containing_line, relocation_text_offset, relocation_text_token = ram_relocations.pop()
        assert ram_start is not None
        if referenced_line_pointer not in line_unmap:
            print('Undefined line reference &H%(referenced_line_pointer)X (%(referenced_line_pointer)d) in %(containing_line)d' % dict(
                referenced_line_pointer=referenced_line_pointer, containing_line=containing_line))
            unresolved_ram_relocations += 1
            continue
        resolved_line = line_unmap[referenced_line_pointer]
        rom_relocations.append(RomRelocation(relocation_offset=relocation_offset,
                               referenced_line=resolved_line, containing_line=containing_line))
        bld = bld[:relocation_offset] + b'\x0E' + \
            struct.pack('<H', resolved_line) + bld[3+relocation_offset:]
        text = text[:relocation_text_offset] + \
            str(resolved_line) + \
            text[relocation_text_offset + len(relocation_text_token):]
    assert unresolved_ram_relocations == 0, '%(unresolved_ram_relocations)d unresolved RAM relocations' % dict(
        unresolved_ram_relocations=unresolved_ram_relocations)
    unresolved_rom_relocations = 0
    for rom_relocation in rom_relocations:
        relocation_offset, referenced_line, containing_line = rom_relocation
        if referenced_line not in line_map:
            print('Undefined line %(referenced_line)d in %(containing_line)d' % dict(
                referenced_line=referenced_line, containing_line=containing_line))
            unresolved_rom_relocations += 1
            continue
        resolved_rom_address = load_addr + line_map[referenced_line]
        bld = bld[:relocation_offset] + b'\x0D' + \
            struct.pack('<H', resolved_rom_address) + bld[3+relocation_offset:]
    if unresolved_rom_relocations > 0:
        print('Warning: %(unresolved_rom_relocations)d unresolved ROM relocations' %
              dict(unresolved_rom_relocations=unresolved_rom_relocations))
    return bld, text


def main():
    optional_verbose_flag = None
    try:
        prog_name, optional_verbose_flag, load_addr_hex, bas_file_name, bld_file_name, txt_file_name = sys.argv
        assert optional_verbose_flag in ('-v', '-verbose', '--verbose')
    except:
        prog_name, load_addr_hex, bas_file_name, bld_file_name, txt_file_name = sys.argv
    verbose = optional_verbose_flag is not None
    load_addr = int(load_addr_hex, 16)
    bas = open(bas_file_name, "rb").read()
    bld, text = basld(load_addr, bas, verbose=verbose)
    assert len(bld) == len(bas)
    bld2, text2 = basld(load_addr, bld, verbose=False)
    assert bld2 == bld  # loading twice to the same address should not change the binary output
    assert text2 == text  # loading twice to the same address should not change the text output
    open(bld_file_name, "wb").write(bld)
    open(txt_file_name, "wb").write(text.encode('iso-8859-1'))


if __name__ == "__main__":
    test_basfloat()
    main()
